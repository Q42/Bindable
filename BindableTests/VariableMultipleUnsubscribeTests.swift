//
//  VariableMultipleUnsubscribeTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-19.
//  Copyright © 2017 Q42. All rights reserved.
//


import XCTest
import Bindable

class VariableMultipleUnsubscribeTests: XCTestCase {

  func testChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable.subscribe { event in
      callbacks += 1
    }

    variable.subscribe { event in
      callbacks += 1
      if callbacks == 3 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value += 1
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapChange1() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable.subscribe { event in
      callbacks += 1
    }

    variable.subscribe { event in
      callbacks += 1
      if callbacks == 3 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value = 3
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapChange2() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable1.subscribe { event in
      callbacks += 1
    }

    source.value = 3
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    variable2.subscribe { event in
      callbacks += 1
      if callbacks == 2 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapMapChange1() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }.map { $0 * 10 }

    XCTAssertEqual(variable.value, 20)

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable.subscribe { event in
      callbacks += 1
    }

    source.value = 3
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    variable.subscribe { event in
      callbacks += 1
      if callbacks == 2 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapMapChange2() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }
    let variable3 = variable2.map { $0 * 10 }

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable1.subscribe { event in
      callbacks += 1
    }

    source.value = 3
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    variable2.subscribe { event in
      callbacks += 1
    }.disposed(by: disposeBag)

    variable3.subscribe { event in
      callbacks += 1
      if callbacks == 2 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapMapChange3() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }
    let variable3 = variable2.map { $0 * 10 }

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable1.subscribe { event in
      callbacks += 1
    }

    source.value = 3
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    var subscription2: Subscription? = variable2.subscribe { event in
      callbacks += 1
    }

    source.value += 1
    subscription2 = nil
    subscription2?.disposed(by: disposeBag)

    variable3.subscribe { event in
      callbacks += 1
      if callbacks == 3 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAndChange() {
    let disposeBag = DisposeBag()
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: true)
    let variableL = leftSource.variable
    let variableR = rightSource.variable
    let variable = variableL && variableR

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable.subscribe { event in
      callbacks += 1
    }

    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    variable.subscribe { event in
      callbacks += 1
      if callbacks == 2 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    leftSource.value = 3
    rightSource.value = false

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testOrChange() {
    let disposeBag = DisposeBag()
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: -1)
    let variableL = leftSource.variable
    let variableR = rightSource.variable
    let variable = variableL || variableR

    let ex = self.expectation(description: "Expectation didn't finish")
    var callbacks = 0

    var subscription1: Subscription? = variable.subscribe { event in
      callbacks += 1
    }

    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    variable.subscribe { event in
      callbacks += 1
      if callbacks == 2 {
        ex.fulfill()
      }
    }.disposed(by: disposeBag)

    leftSource.value = 3
    rightSource.value = -2

    waitForExpectations(timeout: 0.1, handler: nil)
  }

}
