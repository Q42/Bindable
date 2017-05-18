//
//  EventVariable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-05-18.
//
//

import Foundation


public struct EventVariable<Value, Event> {
  private let source: EventVariableSource<Value, Event>

  internal init(source: EventVariableSource<Value, Event>) {
    self.source = source
  }

  public var value: Value {
    return source.value
  }

  public func subscribe(_ handler: @escaping (Value, Event) -> Void) -> Subscription {

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> EventVariable<NewValue, Event> {
    let resultSource = EventVariableSource<NewValue, Event>(value: transform(source.value), queue: source.queue)

    let subscription = source.variable.subscribe { (value, event) in
      resultSource.setValue(transform(value), event: event)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> EventVariable<Value, Event> {
    let resultSource = EventVariableSource<Value, Event>(value: source.value, queue: dispatchQueue)

    let subscription = self.subscribe { (value, event) in
      resultSource.setValue(value, event: event)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }
}

public class EventVariableSource<Value, Event> : SubscriptionMaintainer {
  fileprivate var handlers: [Handler<(Value, Event)>] = []
  let dispatchKey = DispatchSpecificKey<Void>()

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  private var _value: Value

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self._value = value
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public var variable: EventVariable<Value, Event> {
    return EventVariable(source: self)
  }

  public var value: Value {
    return _value
  }

  public func setValue(_ value: Value, event: Event) {
    _value = value
    callHandlers(event: event)
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

  private func callHandlers(event: Event) {
    // Copy value for async dispatch
    let val = value
    let async = DispatchQueue.getSpecific(key: dispatchKey) == nil

    for h in handlers {
      guard let handler = h.handler else { continue }

      if async {
        queue.async {
          handler(val, event)
        }
      }
      else {
        handler(val, event)
      }
    }
  }
}

public func &&<A, B, Event>(lhs: EventVariable<A, Event>, rhs: EventVariable<B, Event>) -> EventVariable<(A, B), Event> {
  let resultSource = EventVariableSource<(A, B), Event>(value: (lhs.value, rhs.value))

  let lhsSubscription = lhs.subscribe { (_, event) in
    resultSource.setValue((lhs.value, rhs.value), event: event)
  }
  let rhsSubscription = rhs.subscribe { (_, event) in
    resultSource.setValue((lhs.value, rhs.value), event: event)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}

public func ||<A, Event>(lhs: EventVariable<A, Event>, rhs: EventVariable<A, Event>) -> EventVariable<A, Event> {
  let resultSource = EventVariableSource<A, Event>(value: lhs.value)

  let lhsSubscription = lhs.subscribe { (value, event) in
    resultSource.setValue(value, event: event)
  }
  let rhsSubscription = rhs.subscribe { (value, event) in
    resultSource.setValue(value, event: event)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}
