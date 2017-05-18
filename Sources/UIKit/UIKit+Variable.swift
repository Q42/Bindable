//
//  UIKit+Variable.swift
//  Bindable
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

  public func bind(backgroundColor variable: Variable<UIColor?>) {
    bindableProperties.set(key: Keys.backgroundColor, variable: variable) { [weak self] value in
      self?.backgroundColor = value
    }
  }

  public func bind(backgroundColor variable: Variable<UIColor>) {
    bind(backgroundColor: variable.asOptional)
  }
}

extension UILabel {
  public func bind(text variable: Variable<String?>?) {
    bindableProperties.set(key: Keys.text, variable: variable) { [weak self] value in
      self?.text = value
    }
  }

  public func bind(text variable: Variable<String>) {
    bind(text: variable.asOptional)
  }
}

extension UIButton {
  public func bind(attributedTitle bindable: Variable<NSAttributedString?>?, for state: UIControlState) {
    bindableProperties.set(key: Keys.attributedTitleColor, variable: bindable) { [weak self] value in
      self?.setAttributedTitle(value, for: state)
    }
  }

  public func bind(attributedTitle variable: Variable<NSAttributedString>, for state: UIControlState) {
    bind(attributedTitle: variable.asOptional, for: state)
  }
}

extension Variable {
  public var asOptional: Variable<Value?> {
    return map { $0 }
  }
}
