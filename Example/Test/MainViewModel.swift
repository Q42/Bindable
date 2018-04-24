//
//  MainPresenter.swift
//  Test
//
//  Created by Tom Lokhorst on 2017-03-16.
//  Copyright © 2017 Q42. All rights reserved.
//

import UIKit
import Bindable

class MainViewModel {
  private let ageSource = VariableSource<Int>(value: 0)
  private let colorSource = VariableSource<UIColor>(value: UIColor.yellow)
  private let titleSource = VariableSource<NSAttributedString>(value: NSAttributedString())
  private let alertSource = ChannelSource<String>()

  var age: Variable<Int>
  var color: Variable<UIColor>
  var title: Variable<NSAttributedString>
  var messages: Channel<String>

  var tick = false

  init() {
    print("MainViewModel.init")

    age = ageSource.variable
    color = colorSource.variable
    title = titleSource.variable
    messages = alertSource.channel

    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
      let x = self?.tick ?? false
      self?.tick = !x

      self?.colorSource.value = UIColor(red: x ? 0.3 : 1, green: 1, blue: 1, alpha: 1)
    }


    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
      let attrs: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)]
      self?.titleSource.value = NSAttributedString(string: "Close", attributes: attrs)
    }
  }

  func up() {
    ageSource.value += 1

    if ageSource.value == 18 {
      alertSource.post("Congrats! You just became an adult!")
    }
  }

  func down() {
    ageSource.value -= 1
  }

  func changeColor() {
    self.colorSource.value = .red
  }

  deinit {
    print("MainViewModel.deinit")
  }
}
