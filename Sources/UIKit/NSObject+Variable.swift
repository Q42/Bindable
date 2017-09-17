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
    self[keyPath: keyPath] = variable.value
    variable.subscribe { [weak self] event in
      self?[keyPath: keyPath] = event.value
    }.disposed(by: disposeBag)
  }

  public func bind<T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, to variable: Variable<T>) {
    self[keyPath: keyPath] = variable.value
    variable.subscribe { [weak self] event in
      self?[keyPath: keyPath] = event.value
    }.disposed(by: disposeBag)
  }
}
