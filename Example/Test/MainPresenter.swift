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
  private let ageSource = VariableSource<Int>(value: 0)
  private let colorSource = VariableSource<UIColor>(value: UIColor.yellow)
  private let titleSource = VariableSource<NSAttributedString>(value: NSAttributedString())
  private let alertSource = EventSource<String>()

  var age: Variable<Int> { return ageSource.variable }
  var color: Variable<UIColor> { return colorSource.variable }
  var title: Variable<NSAttributedString> { return titleSource.variable }
  var messages: Event<String> { return alertSource.event }

  var tick = false

  func up() {
    ageSource.value += 1

    if ageSource.value == 18 {
      alertSource.emit("Congrats! You just became an adult!")
    }
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

  func changeColor() {
    self.colorSource.value = .red
  }

  deinit {
    print("MainPresenter.deinit")
  }
}
