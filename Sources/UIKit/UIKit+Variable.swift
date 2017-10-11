//
//  UIKit+Variable.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-01-31.
//
//

import UIKit

extension UIButton {

  public func bindAttributedTitle(_ variable: Variable<NSAttributedString?>, for state: UIControlState) {
    // NOTE: Calling bindAttributedTitle twice, doesn't remove previous subscription
    // TODO: Fix this
    setAttributedTitle(variable.value, for: state)
    variable.subscribe { [weak self] event in
      self?.setAttributedTitle(variable.value, for: state)
    }.disposed(by: disposeBag)
  }
}
