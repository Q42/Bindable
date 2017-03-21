//
//  Bindable+UIKit.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import UIKit

extension Keys {

  // UIView
  public static let backgroundColor = Key<UIColor?>(name: "UIView.backgroundColor")

  // UILabel
  public static let text = Key<String?>(name: "UILabel.text")

  // UIButton
  public static let attributedTitleColor = Key<NSAttributedString?>(name: "UIButton.attributedTitle")
}

extension UIView {

  public func bind(backgroundColor bindable: Bindable<UIColor?>) {
    bindableProperties.set(key: Keys.backgroundColor, bindable: bindable) { [weak self] value in
      self?.backgroundColor = value
    }
  }

  public func bind(backgroundColor bindable: Bindable<UIColor>) {
    bind(backgroundColor: bindable.asOptional)
  }
}

extension UILabel {
  public func bind(text bindable: Bindable<String?>?) {
    bindableProperties.set(key: Keys.text, bindable: bindable) { [weak self] value in
      self?.text = value
    }
  }

  public func bind(text bindable: Bindable<String>) {
    bind(text: bindable.asOptional)
  }
}

extension UIButton {
  public func bind(attributedTitle bindable: Bindable<NSAttributedString?>?, for state: UIControlState) {
    bindableProperties.set(key: Keys.attributedTitleColor, bindable: bindable) { [weak self] value in
      self?.setAttributedTitle(value, for: state)
    }
  }

  public func bind(attributedTitle bindable: Bindable<NSAttributedString>, for state: UIControlState) {
    bind(attributedTitle: bindable.asOptional, for: state)
  }
}

extension Bindable {
  public var asOptional: Bindable<Value?> {
    return map { $0 }
  }
}
