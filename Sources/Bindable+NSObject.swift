//
//  Bindable+NSObject.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-02-20.
//
//

import Foundation


var associatedObjectHandle: UInt8 = 0
let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

extension NSObject {

  public var bindableProperties: BindableProperties {
    let obj = objc_getAssociatedObject(self, &associatedObjectHandle)
    let properites: BindableProperties

    if let obj = obj as? BindableProperties {
      properites = obj
    }
    else {
      let obj = BindableProperties()

      objc_setAssociatedObject(self, &associatedObjectHandle, obj, associationPolicy)
      properites = obj
    }

    return properites
  }
}

public class BindableProperties {

  private var subscriptions: [String: Subscription] = [:]

  public func set<T>(key: Key<T>, bindable: Bindable<T>?, handler: @escaping (T) -> Void) {
    subscriptions[key.name]?.unsubscribe()
    subscriptions[key.name] = nil

    if let bindable = bindable {
      handler(bindable.value)
      let subscription = bindable.subscribe(handler)
      subscriptions[key.name] = subscription
    }
  }

  deinit {
    for subscription in subscriptions.values {
      subscription.unsubscribe()
    }

    subscriptions = [:]
  }
}


public struct Key<T> {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}

public struct Keys { }
