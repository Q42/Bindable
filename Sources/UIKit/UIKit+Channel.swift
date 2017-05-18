//
//  UIKit+Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import UIKit

extension UIControl {
  public func channel(for controlEvents: UIControlEvents) -> Channel<UIControl> {
    let source = controlEventTargets.streamSource(for: controlEvents)
    addTarget(source, action: #selector(UIControlChannelSource.action(_:)), for: controlEvents)

    return source.channel
  }

  @discardableResult
  public func on(touchUpInside handler: @escaping () -> Void) -> Self {
    channel(for: .touchUpInside)
      .subscribe { _ in handler() }
      .disposed(by: controlEventTargets.internalDisposeBag)

    return self
  }

  @discardableResult
  public func on(valueChanged handler: @escaping () -> Void) -> Self {
    channel(for: .valueChanged)
      .subscribe { _ in handler() }
      .disposed(by: controlEventTargets.internalDisposeBag)

    return self
  }
}
