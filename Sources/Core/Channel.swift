//
//  Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation

public class Channel<Event> {
  internal let source: ChannelSource<Event>
  internal let relatedSubscription: Subscription?

  internal init(source: ChannelSource<Event>, relatedSubscription: Subscription?) {
    self.source = source
    self.relatedSubscription = relatedSubscription
  }

  deinit {
    source.internalState.removeChannel(self)
  }

  public func subscribe(_ handler: @escaping (Event) -> Void) -> Subscription {

    let channelHandler = ChannelHandler(channel: self, handler: handler)
    source.internalState.addHandler(channelHandler)

    let subscription = Subscription { [source] in
      source.internalState.removeHandler(channelHandler)
    }

    return subscription
  }

  public func map<NewEvent>(_ transform: @escaping (Event) -> NewEvent) -> Channel<NewEvent> {
    let resultSource = ChannelSource<NewEvent>(queue: source.queue)

    let subscription = source.channel.subscribe { event in
      resultSource.post(transform(event))
    }

    return Channel<NewEvent>(source: resultSource, relatedSubscription: subscription)
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Channel<Event> {
    let resultSource = ChannelSource<Event>(queue: dispatchQueue)

    let subscription = self.subscribe { event in
      resultSource.post(event)
    }

    return Channel(source: resultSource, relatedSubscription: subscription)
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
    return Channel(source: self, relatedSubscription: nil)
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
    private var handlers: [ChannelHandler<Event>] = []

    func addHandler(_ handler: ChannelHandler<Event>) {
      lock.lock(); defer { lock.unlock() }

      handlers.append(handler)
    }

    func getHandlers() -> [ChannelHandler<Event>] {
      lock.lock(); defer { lock.unlock() }

      return handlers
    }

    func removeHandler(_ handler: ChannelHandler<Event>) {
      lock.lock(); defer { lock.unlock() }

      for (ix, h) in handlers.enumerated() {
        if h === handler {
          handlers.remove(at: ix)
        }
      }
    }

    func removeChannel(_ channel: Channel<Event>) {
      lock.lock(); defer { lock.unlock() }

      for (ix, handler) in handlers.enumerated() {
        if handler.channel === channel {
          handlers.remove(at: ix)
        }
      }
    }

  }
}

class ChannelHandler<Value> {
  weak var channel: Channel<Value>?
  private(set) var handler: ((Value) -> Void)?

  init(channel: Channel<Value>, handler: @escaping (Value) -> Void) {
    self.channel = channel
    self.handler = handler
  }
}
