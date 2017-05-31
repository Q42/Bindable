//
//  Variable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2016-12-08.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation

public struct VariableEvent<Value> {
  public let oldValue: Value
  public let value: Value
  public let animated: Bool

  public init(oldValue: Value, value: Value, animated: Bool) {
    self.oldValue = oldValue
    self.value = value
    self.animated = animated
  }
}

public struct Variable<Value> {
  private let source: VariableSource<Value>

  internal init(source: VariableSource<Value>) {
    self.source = source
  }

  public var value: Value {
    return source.value
  }

  public func subscribe(_ handler: @escaping (VariableEvent<Value>) -> Void) -> Subscription {

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Variable<NewValue> {
    let resultSource = VariableSource<NewValue>(value: transform(source.value), queue: source.queue)

    let subscription = source.variable.subscribe { event in
      resultSource.setValue(transform(event.value), animated: event.animated)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Variable<Value> {
    let resultSource = VariableSource(value: source.value, queue: dispatchQueue)

    let subscription = self.subscribe { event in
      resultSource.setValue(event.value, animated: event.animated)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }
}

public class VariableSource<Value> : SubscriptionMaintainer {
  fileprivate var handlers: [Handler<VariableEvent<Value>>] = []
  let dispatchKey = DispatchSpecificKey<Void>()

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  private var _value: Value

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self._value = value
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public var value: Value {
    get { return _value }
    set { setValue(newValue, animated: true) }
  }

  public var variable: Variable<Value> {
    return Variable(source: self)
  }

  public func setValue(_ value: Value, animated: Bool) {
    let oldValue = _value
    _value = value

    let event = VariableEvent(oldValue: oldValue, value: value, animated: animated)
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

public func &&<A, B>(lhs: Variable<A>, rhs: Variable<B>) -> Variable<(A, B)> {
  let resultSource = VariableSource<(A, B)>(value: (lhs.value, rhs.value))

  let lhsSubscription = lhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }
  let rhsSubscription = rhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)

  let lhsSubscription = lhs.subscribe { event in
    resultSource.setValue(event.value, animated: event.animated)
  }
  let rhsSubscription = rhs.subscribe { event in
    resultSource.setValue(event.value, animated: event.animated)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}
