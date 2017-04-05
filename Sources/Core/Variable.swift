//
//  Variable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2016-12-08.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation


public struct Variable<Value> {
  private let source: VariableSource<Value>

  internal init(source: VariableSource<Value>) {
    self.source = source
  }

  public var value: Value {
    return source.value
  }

  public func subscribe(_ handler: @escaping (Value) -> Void) -> Subscription {

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Variable<NewValue> {
    let resultSource = VariableSource<NewValue>(value: transform(source.value), queue: source.queue)

    let subscription = source.variable.subscribe { value in
      resultSource.value = transform(value)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Variable<Value> {
    let resultSource = VariableSource(value: source.value, queue: dispatchQueue)

    let subscription = self.subscribe { value in
      resultSource.value = value
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.variable
  }
}

public class VariableSource<Value> : SubscriptionMaintainer {
  fileprivate var handlers: [Handler<Value>] = []
  let dispatchKey = DispatchSpecificKey<Void>()

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  public var value: Value {
    didSet {
      // Copy value for async dispatch
      let val = value
      let async = DispatchQueue.getSpecific(key: dispatchKey) == nil

      for h in handlers {
        guard let handler = h.handler else { continue }

        if async {
          queue.async {
            handler(val)
          }
        }
        else {
          handler(val)
        }
      }
    }
  }

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self.value = value
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  public var variable: Variable<Value> {
    return Variable(source: self)
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

  let lhsSubscription = lhs.subscribe { _ in
    resultSource.value = (lhs.value, rhs.value)
  }
  let rhsSubscription = rhs.subscribe { _ in
    resultSource.value = (lhs.value, rhs.value)
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)

  let lhsSubscription = lhs.subscribe { value in
    resultSource.value = value
  }
  let rhsSubscription = rhs.subscribe { value in
    resultSource.value = value
  }

  resultSource.emptySubscriptionsHandler = {
    lhsSubscription.unsubscribe()
    rhsSubscription.unsubscribe()
  }

  return resultSource.variable
}
