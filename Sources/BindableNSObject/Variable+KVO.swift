//
//  Variable+KVO.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2018-04-25.
//

import Foundation
import Bindable

extension NSObjectProtocol where Self: NSObject {
  public func variable<T>(kvoKeyPath keyPath: KeyPath<Self, T>) -> Variable<T> {
    let initialValue = self[keyPath: keyPath]
    let resultSource = VariableSource<T>(value: initialValue)

    let observation = self.observe(keyPath, options: [.new]) { [weak resultSource] (_, change) in
      if let newValue = change.newValue {
        resultSource?.value = newValue
      }
    }

    let resultSubscription = Subscription {
      observation.invalidate()
    }

    return Variable.makeVariable(source: resultSource, sourceSubscription: resultSubscription)
  }

  public func bind<Object: NSObject, T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to kvoObject: Object, at kvoKeyPath: KeyPath<Object, T>) {
    let variable = kvoObject.variable(kvoKeyPath: kvoKeyPath)

    bind(keyPath, to: variable)
  }

  public func bind<Object: NSObject, T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, to kvoObject: Object?, at kvoKeyPath: KeyPath<Object, T>) {
    let variable: Variable<T>?
    if let kvoObject = kvoObject {
      variable = kvoObject.variable(kvoKeyPath: kvoKeyPath)
    } else {
      variable = nil
    }

    bind(keyPath, to: variable)
  }
}
