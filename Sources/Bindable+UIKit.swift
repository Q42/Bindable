//
//  Bindable+UIKit.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import UIKit

extension Keys {
  public static let text = Key<String?>(name: "UILabel.text")
  public static let backgroundColor = Key<UIColor?>(name: "UIView.backgroundColor")
}

extension UIView {

  public func bind(backgroundColor bindable: Bindable<UIColor?>) {
    self.backgroundColor  = bindable.value
    bindable.subscribe { [weak self] value in
      self?.backgroundColor = value
    }
  }

  public func bind(backgroundColor bindable: Bindable<UIColor>) {
    bind(backgroundColor: bindable.asOptional)
  }
}

extension UILabel {
  public func bind(text bindable: Bindable<String?>?) {
    bindableProperties.set(key: Keys.text, bindable: bindable) { value in
      self.text = value
    }
  }

  public func bind(text bindable: Bindable<String>) {
    bind(text: bindable.asOptional)
  }
}

extension Bindable {
  public var asOptional: Bindable<Value?> {
    return map { $0 }
  }
}
