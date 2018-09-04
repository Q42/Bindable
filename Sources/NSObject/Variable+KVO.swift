//
//  Variable+KVO.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2018-04-25.
//  Copyright © 2018 Q42. All rights reserved.
//

import Foundation

extension Variable {
  public convenience init<Object: NSObject>(kvoObject: Object, keyPath: KeyPath<Object, Value>) {
    let value = kvoObject[keyPath: keyPath]
    let source = VariableSource<Value>(value: value)

    let observation = kvoObject.observe(keyPath, options: [.new]) { [weak source] (_, change) in
      if let newValue = change.newValue {
        source?.value = newValue
      }
    }

    let subscription = Subscription {
      observation.invalidate()
    }

    self.init(source: source)

    disposeBag.insert(subscription)
  }
}

extension NSObjectProtocol where Self: NSObject {
  public func variable<T>(kvoKeyPath keyPath: KeyPath<Self, T>) -> Variable<T> {
    return Variable(kvoObject: self, keyPath: keyPath)
  }

  public func bind<Object: NSObject, T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to kvoObject: Object, at kvoKeyPath: KeyPath<Object, T>) {
    let variable = Variable(kvoObject: kvoObject, keyPath: kvoKeyPath)

    bind(keyPath, to: variable)
  }

  public func bind<Object: NSObject, T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, to kvoObject: Object?, at kvoKeyPath: KeyPath<Object, T>) {
    let variable: Variable<T>?
    if let kvoObject = kvoObject {
      variable = Variable(kvoObject: kvoObject, keyPath: kvoKeyPath)
    } else {
      variable = nil
    }

    bind(keyPath, to: variable)
  }
}
