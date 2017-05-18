//
//  DisposeBag.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import Foundation

public class DisposeBag {
  var subscriptions: [Subscription] = []

  public init() { 
  }

  public func insert(_ subscription: Subscription) {
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
