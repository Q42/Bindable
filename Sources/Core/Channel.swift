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

    let subscription = source.channel.subscribe { event in
      resultSource.post(transform(event))
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.channel
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Channel<Event> {
    let resultSource = ChannelSource<Event>(queue: dispatchQueue)

    let subscription = self.subscribe { event in
      resultSource.post(event)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.channel
  }
}

public class ChannelSource<Event>: SubscriptionMaintainer {
  fileprivate var handlers: [Handler<Event>] = []
  let dispatchKey = DispatchSpecificKey<Void>()

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  public init(queue: DispatchQueue = DispatchQueue.main) {
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public func post(_ event: Event) {
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
    for (ix, handler) in handlers.enumerated() {
      if handler === subscription {
        handlers.remove(at: ix)
      }
    }

    if handlers.isEmpty {
      emptySubscriptionsHandler?()
      emptySubscriptionsHandler = nil
    }
  }
}

public func ||<A>(lhs: Channel<A>, rhs: Channel<A>) -> Channel<A> {
  let resultSource = ChannelSource<A>()

  let lhsSubscription = lhs.subscribe { event in
    resultSource.post(event)
  }
  let rhsSubscription = rhs.subscribe { event in
    resultSource.post(event)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.channel
}
