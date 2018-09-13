//
//  DisposeBag.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import Foundation

public protocol Subscription: class {
  func unsubscribe()
}

public class DisposeBag {
  private let lock = NSLock()

  var subscriptions: [Subscription] = []

  public init() { 
  }

  public func insert(_ subscription: Subscription) {
    lock.lock(); defer { lock.unlock() }

    subscriptions.append(subscription)
  }

  deinit {
    for subscription in subscriptions {
      subscription.unsubscribe()
    }

    subscriptions = []
  }
}

extension Subscription {
  public func disposed(by disposeBag: DisposeBag) {
    disposeBag.insert(self)
  }
}
