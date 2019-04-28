//
//  NSObject+Extension.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-04-19.
//
//

import Foundation

extension NSObject {
  public func on<T>(_ channel: Channel<T>, handler: @escaping (T) -> Void) {
    channel.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (VariableEvent<T>) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}
