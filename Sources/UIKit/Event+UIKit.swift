//
//  Event+UIKit.swift
//  Pods
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import UIKit

extension UIControl {
  public func event(for controlEvents: UIControlEvents) -> Event<UIControl> {
    let source = eventTargets.eventSource(for: controlEvents)
    addTarget(source, action: #selector(UIControlEventSource.action(_:)), for: controlEvents)

    return source.event
  }

  @discardableResult
  public func on(touchUpInside handler: @escaping () -> Void) -> Self {
    event(for: .touchUpInside)
      .subscribe { _ in handler() }
      .disposed(by: eventTargets.internalDisposeBag)

    return self
  }

  @discardableResult
  public func on(valueChanged handler: @escaping () -> Void) -> Self {
    event(for: .valueChanged)
      .subscribe { _ in handler() }
      .disposed(by: eventTargets.internalDisposeBag)

    return self
  }
}
