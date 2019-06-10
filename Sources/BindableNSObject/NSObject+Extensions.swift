//
//  NSObject+Extension.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-04-19.
//
//

import Foundation
import Bindable

extension NSObject {
  public func on<T>(_ channel: Channel<T>, handler: @escaping (T) -> Void) {
    channel.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (VariableEvent<T>) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }

  public func bind<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe { handler($0.value) }.disposed(by: disposeBag)
    handler(variable.value)
  }
}
