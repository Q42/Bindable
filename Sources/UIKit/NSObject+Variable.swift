//
//  NSObject+Variable.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-04-19.
//
//

import Foundation

extension NSObject {
  public func bind<T: Any>(_ keyPath: String, to variable: Variable<T>) {
    self.setValue(variable.value, forKeyPath: keyPath)
    variable.subscribe { [weak self] value in
      self?.setValue(variable.value, forKeyPath: keyPath)
    }.disposed(by: disposeBag)
  }
}
