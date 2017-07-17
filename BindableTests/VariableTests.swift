//
//  VariableTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2017-07-17.
//  Copyright © 2017 Q42. All rights reserved.
//

import XCTest
import Bindable

class VariableTests: XCTestCase {

  func testChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable

    XCTAssertEqual(variable.value, 1)

    source.value += 1
    XCTAssertEqual(variable.value, 2)
  }

  func testMapChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }

    XCTAssertEqual(variable.value, 2)

    source.value = 3
    XCTAssertEqual(variable.value, 4)
  }

  func testMapMapChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable.map { $0 + 1 }.map { $0 * 10 }

    XCTAssertEqual(variable.value, 20)

    source.value = 3
    XCTAssertEqual(variable.value, 40)
  }

  func testAndChange() {
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: true)
    let variable = leftSource.variable && rightSource.variable

    XCTAssertEqual("\(variable.value)", "\((1, true))")

    leftSource.value = 3
    XCTAssertEqual("\(variable.value)", "\((3, true))")

    rightSource.value = false
    XCTAssertEqual("\(variable.value)", "\((3, false))")
  }

  func testOrChange() {
    let leftSource = VariableSource(value: 1)
    let rightSource = VariableSource(value: -1)
    let variable = leftSource.variable || rightSource.variable

    XCTAssertEqual(variable.value, 1)

    leftSource.value = 3
    XCTAssertEqual(variable.value, 3)

    rightSource.value = -2
    XCTAssertEqual(variable.value, -2)
  }
}
