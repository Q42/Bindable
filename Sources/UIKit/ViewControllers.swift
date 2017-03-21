//
//  ViewControllers.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-21.
//
//

import UIKit

public protocol DisposeBagController {
  var disposeBag: DisposeBag { get }
}

extension DisposeBagController {
  public func subscribe<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableViewController : UIViewController, DisposeBagController {
  public var disposeBag = DisposeBag()

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }
}

open class BindableCollectionViewController : UICollectionViewController, DisposeBagController {
  public var disposeBag = DisposeBag()

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }
}

open class BindableNavigationController : UINavigationController, DisposeBagController {
  public var disposeBag = DisposeBag()

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }
}

open class BindableTableViewController : UITableViewController, DisposeBagController {
  public var disposeBag = DisposeBag()

  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }
}
