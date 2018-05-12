//
//  Extensions.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2018-05-11.
//  Copyright © 2018 Q42. All rights reserved.
//

import Foundation

// MARK: Variable

public func &&<A, B>(lhs: Variable<A>, rhs: Variable<B>) -> Variable<(A, B)> {
  let resultSource = VariableSource<(A, B)>(value: (lhs.value, rhs.value))
  resultSource.observations = lhs.source.observations + rhs.source.observations

  _ = lhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  _ = rhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  return resultSource.variable
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)
  resultSource.observations = lhs.source.observations + rhs.source.observations

  _ = lhs.subscribe { event in
    resultSource.setValue(lhs.value, animated: event.animated)
  }

  _ = rhs.subscribe { event in
    resultSource.setValue(rhs.value, animated: event.animated)
  }

  return resultSource.variable
}

// MARK: Channel

public func ||<A>(lhs: Channel<A>, rhs: Channel<A>) -> Channel<A> {
  let resultSource = ChannelSource<A>()

  _ = lhs.subscribe { event in
    resultSource.post(event)
  }

  _ = rhs.subscribe { event in
    resultSource.post(event)
  }

  return resultSource.channel
}

extension ChannelSource where Event == Void {
  func post() {
    self.post(())
  }
}

