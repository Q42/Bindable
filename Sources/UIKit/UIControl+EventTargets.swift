//
//  UIControl+EventTargets.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import UIKit


private var associatedObjectHandle: UInt8 = 0
private let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

extension UIControl {

  var controlEventTargets: ControlEventTargets {
    let obj = objc_getAssociatedObject(self, &associatedObjectHandle)
    let properites: ControlEventTargets

    if let obj = obj as? ControlEventTargets {
      properites = obj
    }
    else {
      let obj = ControlEventTargets()

      objc_setAssociatedObject(self, &associatedObjectHandle, obj, associationPolicy)
      properites = obj
    }

    return properites
  }
}

class ControlEventTargets : NSObject {

  internal let internalDisposeBag = DisposeBag()
  private var sources: [UInt: UIControlChannelSource] = [:]

  func streamSource(for controlEvents: UIControlEvents) -> UIControlChannelSource {
    if let source = sources[controlEvents.rawValue] {
      return source
    }

    let source = UIControlChannelSource()
    sources[controlEvents.rawValue] = source

    return source
  }

}

class UIControlChannelSource : ChannelSource<UIControl> {

  init() {
    super.init()
  }

  @objc func action(_ sender: UIControl) {
    post(sender)
  }
}
