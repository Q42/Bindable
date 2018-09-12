//
//  Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation

public class Channel<Event> {
  private let subscriptions: [Subscription]
  private let source: ChannelSource<Event>

  internal init(source: ChannelSource<Event>, subscriptions: [Subscription]) {
    self.source = source
    self.subscriptions = subscriptions
  }

  public func subscribe(_ handler: @escaping (Event) -> Void) -> Subscription {

    let handler = Handler(handler: handler)
    source.internalState.addHandler(handler)

    let subscription = Subscription { [subscriptions, source] in
      _ = subscriptions
      source.internalState.removeHandler(handler)
    }

    return subscription
  }

  public func map<NewEvent>(_ transform: @escaping (Event) -> NewEvent) -> Channel<NewEvent> {
    let resultSource = ChannelSource<NewEvent>(queue: source.queue)

    let subscription = self.subscribe { event in
      resultSource.post(transform(event))
    }

    return Channel<NewEvent>(source: resultSource, subscriptions: [subscription])
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Channel<Event> {
    let resultSource = ChannelSource<Event>(queue: dispatchQueue)

    let subscription = self.subscribe { event in
      resultSource.post(event)
    }

    return Channel(source: resultSource, subscriptions: [subscription])
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
    return Channel(source: self, subscriptions: [])
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
