//
//  VariableHandlersTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-21.
//  Copyright © 2017 Q42. All rights reserved.
//


import XCTest
@testable import Bindable

class VariableHandlersTests: XCTestCase {

  func testChange() {
    let source = VariableSource(value: 1)

    XCTAssertEqual(source.handlers.count, 0)

    let variable = source.variable

    XCTAssertEqual(source.handlers.count, 0)

    let subscription1 = variable.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    _ = variable.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 2)

    source.value += 1
    subscription1.unsubscribe()

    XCTAssertEqual(source.handlers.count, 1)
  }

  func testMapChange1() {
    let source = VariableSource(value: 1)

    XCTAssertEqual(source.handlers.count, 0)

    var variable: Variable<Int>? = source.variable.map { $0 + 1 }

    XCTAssertEqual(source.handlers.count, 1)

    let subscription1 = variable?.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    _ = variable?.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    source.value = 3
    subscription1?.unsubscribe()

    XCTAssertEqual(source.handlers.count, 1)

    variable = nil

    XCTAssertEqual(source.handlers.count, 0)
  }

  func testMapChange2() {
    let source = VariableSource(value: 1)
    let variable1 = source.variable

    XCTAssertEqual(source.handlers.count, 0)

    var variable2: Variable<Int>? = variable1.map { $0 + 1 }

    XCTAssertEqual(source.handlers.count, 1)

    let subscription1 = variable1.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 2)

    source.value = 3
    subscription1.unsubscribe()

    XCTAssertEqual(source.handlers.count, 1)

    _ = variable2?.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    variable2 = nil

    XCTAssertEqual(source.handlers.count, 0)
  }

  func testMapMapChange1() {
    let source = VariableSource(value: 1)

    XCTAssertEqual(source.handlers.count, 0)

    var variable: Variable<Int>? = source.variable.map { $0 + 1 }.map { $0 * 10 }

    XCTAssertEqual(source.handlers.count, 1)

    let subscription1 = variable?.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    source.value = 3
    subscription1?.unsubscribe()

    XCTAssertEqual(source.handlers.count, 1)

    _ = variable?.subscribe { event in
    }

    XCTAssertEqual(source.handlers.count, 1)

    variable = nil

    XCTAssertEqual(source.handlers.count, 0)
  }

  func testMapMapChange2() {
    let source = VariableSource(value: 1)

    XCTAssertEqual(source.handlers.count, 0)

    var variable1: Variable<Int>? = source.variable
    var variable2: Variable<Int>? = variable1?.map { $0 + 1 }

    XCTAssertEqual(source.handlers.count, 1)

    var variable3: Variable<Int>? = variable2?.map { $0 * 10 }

    XCTAssertEqual(source.handlers.count, 1)

    let subscription1 = variable1?.subscribe { event in
    }

    source.value = 3
    subscription1?.unsubscribe()

    XCTAssertEqual(source.handlers.count, 1)

    _ = variable2?.subscribe { event in
    }

    _ = variable3?.subscribe { event in
    }

    source.value += 1

    variable1 = nil

    XCTAssertEqual(source.handlers.count, 1)

    variable2 = nil

    XCTAssertEqual(source.handlers.count, 1)

    variable3 = nil

    XCTAssertEqual(source.handlers.count, 0)
  }

  func testMapMapChange3() { // TODO
  }

  func testAndChange() { // TODO
  }

  func testOrChange() { // TODO
  }

}
