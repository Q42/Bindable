//
//  Event.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation


public struct Event<Value> {
  private let source: EventSource<Value>

  internal init(source: EventSource<Value>) {
    self.source = source
  }

  public func subscribe(_ handler: @escaping (Value) -> Void) -> Subscription {

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Event<NewValue> {
    let resultSource = EventSource<NewValue>(queue: source.queue)

    let subscription = source.event.subscribe { value in
      resultSource.emit(transform(value))
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.event
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Event<Value> {
    let resultSource = EventSource<Value>(queue: dispatchQueue)

    let subscription = self.subscribe { value in
      resultSource.emit(value)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.event
  }
}

public class EventSource<Value>: SubscriptionMaintainer {
  fileprivate var handlers: [Handler<Value>] = []
  let dispatchKey = DispatchSpecificKey<Void>()

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  public init(queue: DispatchQueue = DispatchQueue.main) {
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public func emit(_ value: Value) {
    let async = DispatchQueue.getSpecific(key: dispatchKey) == nil

    for h in handlers {
      guard let handler = h.handler else { continue }

      if async {
        queue.async {
          handler(value)
        }
      }
      else {
        handler(value)
      }
    }
  }

  public var event: Event<Value> {
    return Event(source: self)
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

public func ||<A>(lhs: Event<A>, rhs: Event<A>) -> Event<A> {
  let resultSource = EventSource<A>()

  let lhsSubscription = lhs.subscribe { value in
    resultSource.emit(value)
  }
  let rhsSubscription = rhs.subscribe { value in
    resultSource.emit(value)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.event
}
