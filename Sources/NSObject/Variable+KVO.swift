//
//  Variable+KVO.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2018-04-25.
//  Copyright © 2018 Q42. All rights reserved.
//

import Foundation

extension Variable {
  public init<Object: NSObject>(kvoObject: Object, keyPath: KeyPath<Object, Value>) {
    let value = kvoObject[keyPath: keyPath]
    let source = VariableSource<Value>(value: value)

    let observation = kvoObject.observe(keyPath, options: [.new]) { (_, change) in
      if let newValue = change.newValue {
        source.value = newValue
      }
    }

    kvoObject.bindableProperties.observations.append(observation)

    self = source.variable
  }
}

extension NSObjectProtocol {
  public func variable<Value>(kvoKeyPath keyPath: KeyPath<Self, Value>) -> Variable<Value> where Self: NSObject {
    return Variable(kvoObject: self, keyPath: keyPath)
  }
}
