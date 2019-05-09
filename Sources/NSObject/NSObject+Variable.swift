//
//  NSObject+Variable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-04-19.
//
//

import Foundation

extension NSObjectProtocol where Self : NSObject {
  public func bind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to variable: Variable<T>) {
    bindableProperties.subscriptions[keyPath] = nil

    self[keyPath: keyPath] = variable.value
    let subscription = variable.subscribe { [weak self] event in
      guard let self = self else { return }

      self[keyPath: keyPath] = event.value
    }

    bindableProperties.subscriptions[keyPath] = subscription
  }

  public func bind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, to variable: Variable<T>?) {
    bindableProperties.subscriptions[keyPath] = nil

    if let variable = variable {
      self[keyPath: keyPath] = variable.value
      let subscription = variable.subscribe { [weak self] event in
        guard let self = self else { return }

        self[keyPath: keyPath] = event.value
      }
      bindableProperties.subscriptions[keyPath] = subscription
    }
    else {
      self[keyPath: keyPath] = nil
    }
  }

  public func unbind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, resetTo value: T) {
    bindableProperties.subscriptions[keyPath] = nil

    self[keyPath: keyPath] = value
  }

  public func unbind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, resetTo value: T? = nil) {
    bindableProperties.subscriptions[keyPath] = nil

    self[keyPath: keyPath] = value
  }
}
