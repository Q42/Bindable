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
    let value = source.value

    source.queue.async {
      handler(value)
    }

    let h = Handler(source: source, handler: handler)
    source.handlers.append(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Bindable<NewValue> {
    let resultSource = BindableSource<NewValue>(value: transform(source.value), queue: source.queue)

    _ = source.bindable.subscribe { value in
      resultSource.value = transform(value)
    }

    return resultSource.bindable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Bindable<Value> {
    let resultSource = BindableSource(value: source.value, queue: dispatchQueue)

    _ = self.subscribe { value in
      resultSource.value = value
    }

    return resultSource.bindable
  }
}

public class BindableSource<Value> {
  fileprivate var handlers: [Handler<Value>] = []
  internal let queue: DispatchQueue

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
}

public protocol Subscription {
  func unsubscribe()
}

class Handler<Value> : Subscription {
  weak var source: BindableSource<Value>?
  let handler: (Value) -> Void

  init(source: BindableSource<Value>, handler: @escaping (Value) -> Void) {
    self.source = source
    self.handler = handler
  }

  func unsubscribe() {
    guard let source = source else { return }

    for (ix, handler) in source.handlers.enumerated() {
      if handler === self {
        source.handlers.remove(at: ix)
      }
    }
  }
}

public func &&<A, B>(lhs: Bindable<A>, rhs: Bindable<B>) -> Bindable<(A, B)> {
  let resultSource = BindableSource<(A, B)>(value: (lhs.value, rhs.value))

  _ = lhs.subscribe { _ in
    resultSource.value = (lhs.value, rhs.value)
  }
  _ = rhs.subscribe { _ in
    resultSource.value = (lhs.value, rhs.value)
  }

  return resultSource.bindable
}

public func ||<A>(lhs: Bindable<A>, rhs: Bindable<A>) -> Bindable<(A)> {
  let resultSource = BindableSource<A>(value: lhs.value)

  _ = lhs.subscribe { value in
    resultSource.value = value
  }
  _ = rhs.subscribe { value in
    resultSource.value = value
  }

  return resultSource.bindable
}
