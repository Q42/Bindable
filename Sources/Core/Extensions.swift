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
  let resultVariable = resultSource.variable

  let s1 = lhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  let s2 = rhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  resultVariable.disposeBag.insert(s1)
  resultVariable.disposeBag.insert(s2)

  return resultVariable
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)
  let resultVariable = resultSource.variable

  let s1 = lhs.subscribe { event in
    resultSource.setValue(lhs.value, animated: event.animated)
  }

  let s2 = rhs.subscribe { event in
    resultSource.setValue(rhs.value, animated: event.animated)
  }

  resultVariable.disposeBag.insert(s1)
  resultVariable.disposeBag.insert(s2)

  return resultVariable
}

// MARK: Channel

public func ||<A>(lhs: Channel<A>, rhs: Channel<A>) -> Channel<A> {
  let resultSource = ChannelSource<A>()
  let resultChannel = resultSource.channel

  let s1 = lhs.subscribe { event in
    resultSource.post(event)
  }

  let s2 = rhs.subscribe { event in
    resultSource.post(event)
  }

  resultChannel.disposeBag.insert(s1)
  resultChannel.disposeBag.insert(s2)

  return resultChannel
}

extension ChannelSource where Event == Void {
  func post() {
    self.post(())
  }
}

