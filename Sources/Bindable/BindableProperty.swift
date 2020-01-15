//
//  Bindable.swift
//  Bindable
//
//  Created by Tim van Steenis on 15/12/2019.
//

import Foundation

@propertyWrapper
public struct Bindable<Value> {
  private let source: VariableSource<Value>

  public let projectedValue: Variable<Value>

  public init(wrappedValue: Value) {
    source = VariableSource(value: wrappedValue)
    projectedValue = source.variable
  }

  public var wrappedValue: Value {
    get { source.value }
    set { source.value = newValue }
  }
}
