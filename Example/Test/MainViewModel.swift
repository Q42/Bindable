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
  private let alertSource = ChannelSource<String>()

  @Bindable private(set) var age: Int = 0
  @Bindable private(set) var color: UIColor = .yellow
  @Bindable private(set) var title: NSAttributedString = NSAttributedString()
  var messages: Channel<String>

  var tick = false

  init() {
    print("MainViewModel.init")

    messages = alertSource.channel

    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
      let x = self?.tick ?? false
      self?.tick = !x

      self?.color = UIColor(red: x ? 0.3 : 1, green: 1, blue: 1, alpha: 1)
    }


    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
      let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
      self?.title = NSAttributedString(string: "Close", attributes: attrs)
    }
  }

  func up() {
    age += 1

    if age == 18 {
      alertSource.post("Congrats! You just became an adult!")
    }
  }

  func down() {
    age -= 1
  }

  @objc func changeColor() {
    self.color = .red
  }

  deinit {
    print("MainViewModel.deinit")
  }
}
