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
    source.addHandler(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Variable<NewValue> {
    let resultSource = VariableSource<NewValue>(value: transform(source.value), queue: source.queue)

    _ = source.variable.subscribe { event in
      resultSource.setValue(transform(event.value), animated: event.animated)
    }

    return resultSource.variable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Variable<Value> {
    let resultSource = VariableSource(value: source.value, queue: dispatchQueue)

    _ = self.subscribe { event in
      resultSource.setValue(event.value, animated: event.animated)
    }

    return resultSource.variable
  }
}

public class VariableSource<Value> : SubscriptionMaintainer {
  private let lock = NSLock()

  private var _value: Value

  private var handlers: [Handler<VariableEvent<Value>>] = []
  private let dispatchKey = DispatchSpecificKey<Void>()

  internal let queue: DispatchQueue

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self._value = value
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public var value: Value {
    get { return _value }
    set { setValue(newValue, animated: false) }
  }

  public var variable: Variable<Value> {
    return Variable(source: self)
  }

  public func setValue(_ value: Value, animated: Bool) {
    lock.lock(); defer { lock.unlock() }

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

  internal var handlersCount: Int {
    return handlers.count
  }

  func addHandler(_ handler: Handler<VariableEvent<Value>>) {
    lock.lock(); defer { lock.unlock() }

    handlers.append(handler)
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

public func &&<A, B>(lhs: Variable<A>, rhs: Variable<B>) -> Variable<(A, B)> {
  let resultSource = VariableSource<(A, B)>(value: (lhs.value, rhs.value))

  _ = lhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  _ = rhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  return resultSource.variable
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)

  _ = lhs.subscribe { event in
    resultSource.setValue(event.value, animated: event.animated)
  }

  _ = rhs.subscribe { event in
    resultSource.setValue(event.value, animated: event.animated)
  }

  return resultSource.variable
}
