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

public class Variable<Value> {
  internal let source: VariableSource<Value>

  public var value: Value {
    return source.value
  }

  internal init(source: VariableSource<Value>) {
    self.source = source
  }

  deinit {
    source.internalState.removeVariable(self)
  }

  public func subscribe(_ handler: @escaping (VariableEvent<Value>) -> Void) -> Subscription {

    let h = VariableHandler(variable: self, handler: handler)
    source.internalState.addHandler(h)

    return h
  }

  public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Variable<NewValue> {
    let resultSource = VariableSource<NewValue>(value: transform(source.value), queue: source.queue)
    resultSource.observations = source.observations

    _ = self.subscribe { event in
      resultSource.setValue(transform(self.source.value), animated: event.animated)
    }

    return resultSource.variable
  }

  public func dispatch(on dispatchQueue: DispatchQueue) -> Variable<Value> {
    let resultSource = VariableSource(value: source.value, queue: dispatchQueue)
    resultSource.observations = source.observations

    _ = self.subscribe { event in
      resultSource.setValue(self.source.value, animated: event.animated)
    }

    return resultSource.variable
  }
}

public class VariableSource<Value> {
  private let dispatchKey = DispatchSpecificKey<Void>()

  fileprivate let internalState: VariableSourceState

  internal let queue: DispatchQueue
  internal var observations: [NSKeyValueObservation] = []

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
    return Variable(source: self)
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
    let handlers: [VariableHandler<Value>]
  }

  fileprivate class VariableSourceState {
    private let lock = NSLock()
    private var handlers: [VariableHandler<Value>] = []

    private var value: Value

    init(value: Value) {
      self.value = value
    }

    func readValue() -> Value {
      lock.lock(); defer { lock.unlock() }

      return value
    }

    func handlersCount() -> Int {
      lock.lock(); defer { lock.unlock() }

      return handlers.count
    }

    func addHandler(_ handler: VariableHandler<Value>) {
      lock.lock(); defer { lock.unlock() }

      handlers.append(handler)
    }

    func removeSubscription(_ subscription: Subscription) {
      lock.lock(); defer { lock.unlock() }

      for (ix, handler) in handlers.enumerated() {
        if handler === subscription {
          handlers.remove(at: ix)
        }
      }
    }

    func removeVariable(_ variable: Variable<Value>) {
      lock.lock(); defer { lock.unlock() }

      for (ix, handler) in handlers.enumerated() {
        if handler.variable === variable {
          handlers.remove(at: ix)
        }
      }
    }

    func setValue(_ value: Value, animated: Bool) -> VariableSourceAction {
      lock.lock(); defer { lock.unlock() }

      let oldValue = self.value
      self.value = value

      let event = VariableEvent(oldValue: oldValue, value: value, animated: animated)

      return VariableSourceAction(event: event, handlers: handlers)
    }
  }
}

class VariableHandler<Value>: Equatable, Subscription {
  weak var variable: Variable<Value>?
  private(set) var handler: ((VariableEvent<Value>) -> Void)?

  init(variable: Variable<Value>, handler: @escaping (VariableEvent<Value>) -> Void) {
    self.variable = variable
    self.handler = handler
  }

  func unsubscribe() {
    variable?.source.internalState.removeSubscription(self)
    handler = nil
  }

  static func ==(lhs: VariableHandler<Value>, rhs: VariableHandler<Value>) -> Bool {
    return lhs === rhs
  }
}
