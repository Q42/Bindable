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

  let s1 = lhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  let s2 = rhs.subscribe { event in
    resultSource.setValue((lhs.value, rhs.value), animated: event.animated)
  }

  let subscription = Subscription {
    s1.unsubscribe()
    s2.unsubscribe()
  }

  return Variable(source: resultSource, relatedSubscription: subscription)
}

public func ||<A>(lhs: Variable<A>, rhs: Variable<A>) -> Variable<A> {
  let resultSource = VariableSource<A>(value: lhs.value)

  let s1 = lhs.subscribe { event in
    resultSource.setValue(lhs.value, animated: event.animated)
  }

  let s2 = rhs.subscribe { event in
    resultSource.setValue(rhs.value, animated: event.animated)
  }

  let subscription = Subscription {
    s1.unsubscribe()
    s2.unsubscribe()
  }

  return Variable(source: resultSource, relatedSubscription: subscription)
}

// MARK: Channel

public func ||<A>(lhs: Channel<A>, rhs: Channel<A>) -> Channel<A> {
  let resultSource = ChannelSource<A>()

  let s1 = lhs.subscribe { event in
    resultSource.post(event)
  }

  let s2 = rhs.subscribe { event in
    resultSource.post(event)
  }

  let subscription = Subscription {
    s1.unsubscribe()
    s2.unsubscribe()
  }

  return Channel(source: resultSource, relatedSubscription: subscription)
}

extension ChannelSource where Event == Void {
  func post() {
    self.post(())
  }
}

