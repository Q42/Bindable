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

  let viewModel = MainViewModel()

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

    view.bind(\.backgroundColor, to: viewModel.$color)
    label.bind(\.text, to: viewModel.$age.map { "Age: \($0)" })

    closeButton.setAttributedTitle(viewModel.$title.value, for: .normal)
    viewModel.$title.subscribe { [weak closeButton] event in
      closeButton?.setAttributedTitle(event.value, for: .normal)
    }.disposed(by: disposeBag)

    on(viewModel.messages) { [weak self] in self?.alertMessage($0) }

    testButton.addTarget(viewModel, action: #selector(MainViewModel.changeColor), for: .touchUpInside)

    let x = viewModel.$color.map { $0.cgColor.components![0] }
    let y = viewModel.$age.map { CGFloat($0) }
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
      viewModel.up()
    }
    else {
      viewModel.down()
    }
  }

  @IBAction func close(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}
