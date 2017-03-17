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

  public func on(touchUpInside handler: @escaping () -> Void) {
    _ = event(for: .touchUpInside).subscribe { _ in handler() }
  }

  public func on(valueChanged handler: @escaping () -> Void) {
    _ = event(for: .valueChanged).subscribe { _ in handler() }
  }
}
