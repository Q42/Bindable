//
//  ViewControllers.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-21.
//
//

import UIKit

open class BindableViewController : UIViewController {
  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }

  public func subscribe<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableCollectionViewController : UICollectionViewController {
  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }

  public func subscribe<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableNavigationController : UINavigationController {
  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }

  public func subscribe<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableTableViewController : UITableViewController {
  override open func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    disposeBag = DisposeBag()
  }

  public func subscribe<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }

  public func subscribe<T>(_ variable: Variable<T>, handler: @escaping (T) -> Void) {
    variable.subscribe(handler).disposed(by: disposeBag)
  }
}
