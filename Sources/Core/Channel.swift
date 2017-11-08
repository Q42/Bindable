//
//  Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation

public struct Channel<Event> {
  private let source: ChannelSource<Event>

  internal init(source: ChannelSource<Event>) {
    self.source = source
  }

  public func subscribe(_ handler: @escaping (Event) -> Void) -> Subscription {

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewEvent>(_ transform: @escaping (Event) -> NewEvent) -> Channel<NewEvent> {
    let resultSource = ChannelSource<NewEvent>(queue: source.queue)

    _ = source.channel.subscribe { event in
      resultSource.post(transform(event))
    }

    return resultSource.channel
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Channel<Event> {
    let resultSource = ChannelSource<Event>(queue: dispatchQueue)

    _ = self.subscribe { event in
      resultSource.post(event)
    }

    return resultSource.channel
  }
}

public class ChannelSource<Event>: SubscriptionMaintainer {
  private let lock = NSLock()

  internal var handlers: [Handler<Event>] = []
  internal let dispatchKey = DispatchSpecificKey<Void>()

  internal let queue: DispatchQueue

  public init(queue: DispatchQueue = DispatchQueue.main) {
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public func post(_ event: Event) {
    lock.lock(); defer { lock.unlock() }

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

  public var channel: Channel<Event> {
    return Channel(source: self)
  }

  func unsubscribe(_ subscription: Subscription) {
    lock.lock(); defer { lock.unlock() }

    for (ix, handler) in handlers.enumerated() {
      if handler === subscription {
        handlers.remove(at: ix)
      }
    }
  }
}

public func ||<A>(lhs: Channel<A>, rhs: Channel<A>) -> Channel<A> {
  let resultSource = ChannelSource<A>()

  _ = lhs.subscribe { event in
    resultSource.post(event)
  }

  _ = rhs.subscribe { event in
    resultSource.post(event)
  }

  return resultSource.channel
}
