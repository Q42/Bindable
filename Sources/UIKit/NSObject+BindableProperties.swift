//
//  NSObject+bindableProperties.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-02-20.
//
//

import Foundation


private var associatedObjectHandle: UInt8 = 0
private let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

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

  public var disposeBag: DisposeBag {
    get { return bindableProperties.externalDisposeBag }
    set { bindableProperties.externalDisposeBag = newValue }
  }
}

public class BindableProperties {

  internal var externalDisposeBag = DisposeBag()
  internal let interalDisposeBag = DisposeBag()
  private var subscriptions: [String: Subscription] = [:]

  public func set<T>(key: Key<T>, variable: Variable<T>?, handler: @escaping (T) -> Void) {
    subscriptions[key.name]?.unsubscribe()
    subscriptions[key.name] = nil

    if let variable = variable {
      handler(variable.value)
      let subscription = variable.subscribe(handler)
      interalDisposeBag.insert(subscription)
      subscriptions[key.name] = subscription
    }
  }
}


public struct Key<T> {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}

public struct Keys { }
