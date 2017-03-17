//
//  Event+UIControl.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import UIKit


private var associatedObjectHandle: UInt8 = 0
private let associationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC

extension UIControl {

  var eventTargets: EventTargets {
    let obj = objc_getAssociatedObject(self, &associatedObjectHandle)
    let properites: EventTargets

    if let obj = obj as? EventTargets {
      properites = obj
    }
    else {
      let obj = EventTargets()

      objc_setAssociatedObject(self, &associatedObjectHandle, obj, associationPolicy)
      properites = obj
    }

    return properites
  }
}

class EventTargets : NSObject {

  private var sources: [UInt: UIControlEventSource] = [:]

  func eventSource(for controlEvents: UIControlEvents) -> UIControlEventSource {
    if let source = sources[controlEvents.rawValue] {
      return source
    }

    let source = UIControlEventSource()
    sources[controlEvents.rawValue] = source

    return source
  }

}

class UIControlEventSource : EventSource<UIControl> {

  init() {
    super.init()
  }

  @objc func action(_ sender: UIControl) {
    emit(sender)
  }
}
