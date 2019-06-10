//
//  VariableUnsubscribeVariableTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-09-04.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
@testable import Bindable
import BindableNSObject


class VariableUnsubscribeVariableTests: XCTestCase {

  func testChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    var variable = source.variable

    XCTAssertEqual(source.handlersCount, 0)

    var result = 0
    variable.subscribe { event in
      result = event.value
    }.disposed(by: disposeBag)


    XCTAssertEqual(source.handlersCount, 1)

    variable = VariableSource(value: -1).variable

    XCTAssertEqual(source.handlersCount, 1)

    source.value = 2

    XCTAssertEqual(result, 2)
  }

  func testMapChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    var variable1 = source.variable
    var variable2 = variable1.map { $0 + 1 }

    XCTAssertEqual(source.handlersCount, 1)

    var result1 = 0
    variable1.subscribe { event in
      result1 = event.value
    }.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 2)

    var result2 = 0
    variable2.subscribe { event in
      result2 = event.value
    }.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 2)

    variable1 = VariableSource(value: -1).variable
    variable2 = VariableSource(value: -1).variable

    XCTAssertEqual(source.handlersCount, 2)

    source.value = 2

    XCTAssertEqual(result1, 2)
    XCTAssertEqual(result2, 3)
  }

  func testMapChange2() {
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    var variable2 = variable1.map { $0 + 1 }

    XCTAssertEqual(source.handlersCount, 1)

    variable2 = VariableSource(value: -1).variable
    _ = variable2

    XCTAssertEqual(source.handlersCount, 0)

    source.value = 2
  }

  func testMapMapChange() {
    var disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    var variable1 = source.variable
    var variable2 = variable1.map { $0 + 1 }
    var variable3 = variable2.map { $0 * 10 }

    XCTAssertEqual(source.handlersCount, 1)

    var result1 = 0
    variable1.subscribe { event in
      result1 = event.value
    }.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 2)

    var result2 = 0
    variable2.subscribe { event in
      result2 = event.value
    }.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 2)

    var result3 = 0
    variable3.subscribe { event in
      result3 = event.value
    }.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 2)

    variable1 = VariableSource(value: -1).variable
    variable2 = VariableSource(value: -1).variable
    variable3 = VariableSource(value: -1).variable

    XCTAssertEqual(source.handlersCount, 2)

    disposeBag = DisposeBag()

    XCTAssertEqual(source.handlersCount, 0)

    source.value = 2

    XCTAssertEqual(result1, 0)
    XCTAssertEqual(result2, 0)
    XCTAssertEqual(result3, 0)
  }

}
