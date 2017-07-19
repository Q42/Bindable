//
//  VariableSubscribeTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-17.
//  Copyright © 2017 Q42. All rights reserved.
//

import XCTest
import Bindable

class VariableSubscribeTests: XCTestCase {

  func testChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable

    XCTAssertEqual(variable.value, 1)

    let ex = self.expectation(description: "Expectation didn't finish")
    _ = variable.subscribe { event in

      XCTAssertEqual(event.value, 2)

      if event.value == 2 {
        ex.fulfill()
      }
    }

    source.value += 1

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }

    XCTAssertEqual(variable.value, 2)

    let ex = self.expectation(description: "Expectation didn't finish")
    _ = variable.subscribe { event in

      XCTAssertEqual(event.value, 4)

      if event.value == 4 {
        ex.fulfill()
      }
    }

    source.value = 3

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testMapMapChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }.map { $0 * 10 }

    XCTAssertEqual(variable.value, 20)

    let ex = self.expectation(description: "Expectation didn't finish")
    _ = variable.subscribe { event in

      XCTAssertEqual(event.value, 40)

      if event.value == 40 {
        ex.fulfill()
      }
    }

    source.value = 3

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAndChange() {
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: true)
    let variable = leftSource.variable && rightSource.variable

    XCTAssertEqual("\(variable.value)", "\((1, true))")

    var state = 0
    let ex = self.expectation(description: "Expectation didn't finish")
    _ = variable.subscribe { event in

      switch state {
      case 0:
        XCTAssertEqual("\(event.value)", "\((3, true))")

      case 1:
        XCTAssertEqual("\(variable.value)", "\((3, false))")

      default:
        break
      }
      state += 1

      if state == 2 {
        ex.fulfill()
      }
    }

    leftSource.value = 3
    rightSource.value = false

    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testOrChange() {
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: -1)
    let variable = leftSource.variable || rightSource.variable

    XCTAssertEqual(variable.value, 1)

    var state = 0
    let ex = self.expectation(description: "Expectation didn't finish")
    _ = variable.subscribe { event in

      switch state {
      case 0:
        XCTAssertEqual(variable.value, 3)

      case 1:
        XCTAssertEqual(variable.value, -2)

      default:
        break
      }
      state += 1

      if state == 2 {
        ex.fulfill()
      }
    }

    leftSource.value = 3
    rightSource.value = -2

    waitForExpectations(timeout: 0.1, handler: nil)
  }

}
