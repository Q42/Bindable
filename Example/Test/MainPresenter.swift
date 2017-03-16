//
//  MainPresenter.swift
//  Test
//
//  Created by Tom Lokhorst on 2017-03-16.
//  Copyright © 2017 Q42. All rights reserved.
//

import UIKit
import Bindable

class MainPresenter {
  private let ageSource = BindableSource<Int>(value: 0)
  private let colorSource = BindableSource<UIColor>(value: UIColor.yellow)
  private let titleSource = BindableSource<NSAttributedString>(value: NSAttributedString())

  var age: Bindable<Int> { return ageSource.bindable }
  var color: Bindable<UIColor> { return colorSource.bindable }
  var title: Bindable<NSAttributedString> { return titleSource.bindable }

  var tick = false

  func up() {
    ageSource.value += 1
  }

  func down() {
    ageSource.value -= 1
  }

  init() {
    print("MainPresenter.init")

    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
      let x = self?.tick ?? false
      self?.tick = !x

      self?.colorSource.value = UIColor(red: x ? 0.3 : 1, green: 1, blue: 1, alpha: 1)
    }


    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
      let attrs: [String: Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)]
      self?.titleSource.value = NSAttributedString(string: "Close", attributes: attrs)
    }
  }

  deinit {
    print("MainPresenter.deinit")
  }
}
