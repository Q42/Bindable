//
//  DisposeBag.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import Foundation

public class Subscription {
  public let unsubscribe: () -> Void

  internal init(unsubscribe: @escaping () -> Void) {
    self.unsubscribe = unsubscribe
  }

  deinit {
    unsubscribe()
  }
}

public class DisposeBag {
  var subscriptions: [Subscription] = []

  public init() { 
  }

  public func insert(_ subscription: Subscription) {
    subscriptions.append(subscription)
  }
}

extension Subscription {
  public func disposed(by disposeBag: DisposeBag) {
    disposeBag.insert(self)
  }
}

internal class Handler<Value> {
  private(set) var handler: ((Value) -> Void)?

  init(handler: @escaping (Value) -> Void) {
    self.handler = handler
  }
}
