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

  public var disposeBag: DisposeBag {
    get {
      let obj = objc_getAssociatedObject(self, &associatedObjectHandle)

      if let obj = obj as? DisposeBag {
        return obj
      }

      let disposeBag = DisposeBag()
      objc_setAssociatedObject(self, &associatedObjectHandle, disposeBag, associationPolicy)

      return disposeBag
    }
    set {
      objc_setAssociatedObject(self, &associatedObjectHandle, newValue, associationPolicy)
    }
  }

}
