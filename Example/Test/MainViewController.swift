//
//  MainViewController.swift
//  Test
//
//  Created by Tom on 2016-12-08.
//  Copyright © 2016 Q42. All rights reserved.
//

import Foundation
import UIKit
import Bindable


class MainViewController: UIViewController {

  let presenter = MainPresenter()

  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var label2: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    label.textBinding = presenter.age.map { "Age: \($0)" }
    view.backgroundColorBinding = presenter.color

    let x = presenter.color.map { $0.cgColor.components![0] }
    let y = presenter.age.map { CGFloat($0) }

    label2.textBinding = (x || y).map { "\($0)" }
  }

  @IBAction func stepperAction(_ sender: UIStepper) {
    let isUp = sender.value > 0
    sender.value = 0

    if isUp {
      presenter.up()
    }
    else {
      presenter.down()
    }
  }

  @IBAction func close(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

class MainPresenter {
  private let ageSource = BindableSource<Int>(value: 0)
  private let colorSource = BindableSource<UIColor>(value: .white)

  var age: Bindable<Int> { return ageSource.bindable }
  var color: Bindable<UIColor> { return colorSource.bindable }

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
  }

  deinit {
    print("MainPresenter.deinit")
  }
}

extension UILabel {
  var textBinding: Bindable<String> {
    get {
      fatalError()
    }
    set {
      _ = newValue.subscribe { [weak self] in self?.text = $0 }
    }
  }
}

extension UIView {
  var backgroundColorBinding: Bindable<UIColor> {
    get {
      fatalError()
    }
    set {
      _ = newValue.subscribe { [weak self] in self?.backgroundColor = $0 }
    }
  }
}
