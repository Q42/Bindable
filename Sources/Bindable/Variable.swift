//
//  Variable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2016-12-08.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation

public class Variable<Value> {
  private let source: VariableSource<Value>
  private let sourceSubscription: Subscription

  public var value: Value {
    return source.value
  }

  internal init(source: VariableSource<Value>, sourceSubscription: Subscription) {
    self.source = source
    self.sourceSubscription = sourceSubscription
  }

  public static func makeVariable(source: VariableSource<Value>, sourceSubscription: Subscription) -> Variable<Value> {
    return Variable(source: source, sourceSubscription: sourceSubscription)
  }

  public func subscribe(_ handler: @escaping (VariableEvent<Value>) -> Void) -> Subscription {

    let handler = Handler(handler: handler)
    source.internalState.addHandler(handler)

    let subscription = Subscription { [source, sourceSubscription] in
      source.internalState.removeHandler(handler)

      // Captures orignial sourceSubscription, so source will be updated
      _ = sourceSubscription
    }

    return subscription
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Variable<NewValue> {
    let resultSource = VariableSource<NewValue>(value: transform(source.value), queue: source.queue)

    let resultSubscription = self.subscribe { event in
      resultSource.setValue(transform(event.value), animated: event.animated)
    }

    return Variable<NewValue>(source: resultSource, sourceSubscription: resultSubscription)
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Variable<Value> {
    let resultSource = VariableSource(value: source.value, queue: dispatchQueue)

    let resultSubscription = self.subscribe { event in
      resultSource.setValue(event.value, animated: event.animated)
    }

    return Variable(source: resultSource, sourceSubscription: resultSubscription)
  }
}

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


public class VariableSource<Value> {
  private let dispatchKey = DispatchSpecificKey<Void>()

  fileprivate let internalState: VariableSourceState

  internal let queue: DispatchQueue

  public init(value: Value, queue: DispatchQueue = DispatchQueue.main) {
    self.internalState = VariableSourceState(value: value)
    self.queue = queue

    queue.setSpecific(key: dispatchKey, value: ())
  }

  deinit {
    queue.setSpecific(key: dispatchKey, value: nil)
  }

  public var value: Value {
    get { return internalState.readValue() }
    set { setValue(newValue, animated: false) }
  }

  public var variable: Variable<Value> {
    return Variable(source: self, sourceSubscription: Subscription {})
  }

  public func setValue(_ value: Value, animated: Bool) {
    let action = internalState.setValue(value, animated: animated)
    let async = DispatchQueue.getSpecific(key: dispatchKey) == nil

    for h in action.handlers {
      guard let handler = h.handler else { continue }

      if async {
        queue.async {
          handler(action.event)
        }
      }
      else {
        handler(action.event)
      }
    }
  }

  internal var handlersCount: Int {
    return internalState.handlersCount()
  }

}

extension VariableSource {

  fileprivate struct VariableSourceAction {
    let event: VariableEvent<Value>
    let handlers: [Handler<VariableEvent<Value>>]
  }

  fileprivate class VariableSourceState {
    private let lock = NSLock()
    private var handlers: [Handler<VariableEvent<Value>>] = []

    private var value: Value

    init(value: Value) {
      self.value = value
    }

    func readValue() -> Value {
      lock.lock(); defer { lock.unlock() }

      return value
    }

    func setValue(_ value: Value, animated: Bool) -> VariableSourceAction {
      lock.lock(); defer { lock.unlock() }

      let oldValue = self.value
      self.value = value

      let event = VariableEvent(oldValue: oldValue, value: value, animated: animated)

      return VariableSourceAction(event: event, handlers: handlers)
    }

    func handlersCount() -> Int {
      lock.lock(); defer { lock.unlock() }

      return handlers.count
    }

    func addHandler(_ handler: Handler<VariableEvent<Value>>) {
      lock.lock(); defer { lock.unlock() }

      handlers.append(handler)
    }

    func removeHandler(_ handler: Handler<VariableEvent<Value>>) {
      lock.lock(); defer { lock.unlock() }

      for (ix, h) in handlers.enumerated() {
        if h === handler {
          handlers.remove(at: ix)
        }
      }
    }

  }
}
