//
//  NSObject+Event.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-04-19.
//
//

import Foundation

extension NSObject {
  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}
