//
//  Subscription.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import Foundation

public protocol Subscription : class {
  func unsubscribe()
}

internal protocol SubscriptionMaintainer : class {
  func unsubscribe(_ subscription: Subscription)
}

class Handler<Value> : Subscription {
  weak var source: SubscriptionMaintainer?
  private(set) var handler: ((Value) -> Void)?

  init(source: SubscriptionMaintainer, handler: @escaping (Value) -> Void) {
    self.source = source
    self.handler = handler
  }

  func unsubscribe() {
    source?.unsubscribe(self)
    handler = nil
  }
}
