//
//  Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation

public class Channel<Event> {
  internal let disposeBag = DisposeBag()
  internal let source: ChannelSource<Event>

  internal init(source: ChannelSource<Event>) {
    self.source = source
  }

  public func subscribe(_ handler: @escaping (Event) -> Void) -> Subscription {

    let handler = Handler(handler: handler)
    source.internalState.addHandler(handler)

    let subscription = Subscription { [disposeBag, source] in
      _ = disposeBag
      source.internalState.removeHandler(handler)
    }

    return subscription
  }

  public func map<NewEvent>(_ transform: @escaping (Event) -> NewEvent) -> Channel<NewEvent> {
    let resultSource = ChannelSource<NewEvent>(queue: source.queue)
    let resultChannel = resultSource.channel

    let subscription = source.channel.subscribe { [disposeBag] event in
      _ = disposeBag
      resultSource.post(transform(event))
    }

    resultChannel.disposeBag.insert(subscription)

    return resultChannel
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Channel<Event> {
    let resultSource = ChannelSource<Event>(queue: dispatchQueue)
    let resultChannel = resultSource.channel

    let subscription = self.subscribe { [disposeBag] event in
      _ = disposeBag
      resultSource.post(event)
    }

    resultChannel.disposeBag.insert(subscription)

    return resultChannel
  }
}

public class ChannelSource<Event> {
  private let dispatchKey = DispatchSpecificKey<Void>()

  fileprivate let internalState: ChannelSourceState

  internal let queue: DispatchQueue

  public init(queue: DispatchQueue = DispatchQueue.main) {
    self.internalState = ChannelSourceState()
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  deinit {
    queue.setSpecific(key: dispatchKey, value: nil)
  }

  public var channel: Channel<Event> {
    return Channel(source: self)
  }

  public func post(_ event: Event) {
    let handlers = internalState.getHandlers()
    let async = DispatchQueue.getSpecific(key: dispatchKey) == nil

    for h in handlers {
      guard let handler = h.handler else { continue }

      if async {
        queue.async {
          handler(event)
        }
      }
      else {
        handler(event)
      }
    }
  }
}

extension ChannelSource {
  fileprivate class ChannelSourceState {
    private let lock = NSLock()
    private var handlers: [Handler<Event>] = []

    func addHandler(_ handler: Handler<Event>) {
      lock.lock(); defer { lock.unlock() }

      handlers.append(handler)
    }

    func getHandlers() -> [Handler<Event>] {
      lock.lock(); defer { lock.unlock() }

      return handlers
    }

    func removeHandler(_ handler: Handler<Event>) {
      lock.lock(); defer { lock.unlock() }

      for (ix, h) in handlers.enumerated() {
        if h === handler {
          handlers.remove(at: ix)
        }
      }
    }

  }
}
