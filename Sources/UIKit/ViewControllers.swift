//
//  ViewControllers.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-21.
//
//

import UIKit

open class BindableViewController : UIViewController {
  deinit {
    disposeBag = DisposeBag()
  }

  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableCollectionViewController : UICollectionViewController {
  deinit {
    disposeBag = DisposeBag()
  }

  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableNavigationController : UINavigationController {
  deinit {
    disposeBag = DisposeBag()
  }

  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindablePageViewController : UIPageViewController {
  deinit {
    disposeBag = DisposeBag()
  }

  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}

open class BindableTableViewController : UITableViewController {
  deinit {
    disposeBag = DisposeBag()
  }

  public func on<T>(_ event: Event<T>, handler: @escaping (T) -> Void) {
    event.subscribe(handler).disposed(by: disposeBag)
  }
}
