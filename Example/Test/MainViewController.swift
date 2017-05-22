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

  @IBOutlet var label: UILabel!
  @IBOutlet weak var label2: UILabel!
  @IBOutlet weak var testButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    print("MainViewController.init")
  }

  deinit {
    print("MainViewController.deinit")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.bind(backgroundColor: presenter.color)
    label.bind(text: presenter.age.map { "Age: \($0)" })
    closeButton.bind(attributedTitle: presenter.title, for: .normal)

    on(presenter.messages) { [weak self] in self?.alertMessage($0) }

    testButton.on(touchUpInside: presenter.changeColor)

    let x = presenter.color.map { $0.cgColor.components![0] }
    let y = presenter.age.map { CGFloat($0) }
    let z = (x || y)

    z.subscribe { [weak self] event in
      self?.label2.text = "-\(event.value)-"
    }.disposed(by: disposeBag)
  }

  func alertMessage(_ message: String) {
    let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    present(vc, animated: true, completion: nil)
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
