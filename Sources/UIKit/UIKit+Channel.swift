//
//  UIKit+Channel.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-03-16.
//
//

import UIKit

extension UIControl {
  public func channel(for controlEvents: UIControl.Event) -> Channel<UIControl> {
    let source = controlEventTargets.streamSource(for: controlEvents)
    addTarget(source, action: #selector(UIControlChannelSource.action(_:)), for: controlEvents)

    return source.channel
  }
}
