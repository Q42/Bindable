//
//  Bindable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2016-12-08.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation


public struct Bindable<Value> {
  private let source: BindableSource<Value>

  internal init(source: BindableSource<Value>) {
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

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Bindable<NewValue> {
    let resultSource = BindableSource<NewValue>(value: transform(source.value), queue: source.queue)

    let subscription = source.bindable.subscribe { value in
      resultSource.value = transform(value)
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.bindable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Bindable<Value> {
    let resultSource = BindableSource(value: source.value, queue: dispatchQueue)

    let subscription = self.subscribe { value in
      resultSource.value = value
    }

    resultSource.emptySubscriptionsHandler = subscription.unsubscribe

    return resultSource.bindable
  }
}

public class BindableSource<Value> : SubscriptionMaintainer {
  fileprivate var handlers: [Handler<Value>] = []

  let queue: DispatchQueue
  var emptySubscriptionsHandler: (() -> Void)?

  public var value: Value {
    didSet {
      for h in handlers {
        queue.async {
          h.handler(self.value)
        }
      }
    }
  }

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self.value = value
    self.queue = queue
  }

  public var bindable: Bindable<Value> {
    return Bindable(source: self)
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

public func &&<A, B>(lhs: Bindable<A>, rhs: Bindable<B>) -> Bindable<(A, B)> {
  let resultSource = BindableSource<(A, B)>(value: (lhs.value, rhs.value))

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

  return resultSource.bindable
}

public func ||<A>(lhs: Bindable<A>, rhs: Bindable<A>) -> Bindable<(A)> {
  let resultSource = BindableSource<A>(value: lhs.value)

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

  return resultSource.bindable
}
