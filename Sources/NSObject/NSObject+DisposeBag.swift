//
//  NSObject+DisposeBag.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-02-20.
//
//

import Foundation

private var associatedObjectHandle: UInt8 = 0
private let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

extension NSObject {

  internal var bindableProperties: BindableProperties {
    let obj = objc_getAssociatedObject(self, &associatedObjectHandle)

    if let obj = obj as? BindableProperties {
      return obj
    }

    let bindableProperties = BindableProperties()
    objc_setAssociatedObject(self, &associatedObjectHandle, bindableProperties, associationPolicy)

    return bindableProperties
  }

  public var disposeBag: DisposeBag {
    get { return bindableProperties.disposeBag }
    set { bindableProperties.disposeBag = newValue }
  }

}

internal class BindableProperties {
  internal var subscriptions: [AnyKeyPath: Subscription] = [:]
  internal var disposeBag = DisposeBag()
}
