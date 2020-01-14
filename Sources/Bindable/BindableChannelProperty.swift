//
//  BindableChannelProperty.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2020-01-14.
//

import Foundation

@propertyWrapper
public struct BindableChannel<Event> {
  private let source: ChannelSource<Event>

  public init() {
    source = ChannelSource()
  }

  public var wrappedValue: Channel<Event> {
    get { source.channel }
  }

  public func post(_ event: Event) {
    source.post(event)
  }
}

extension BindableChannel where Event == Void {
  public func post() {
    self.post(())
  }
}

