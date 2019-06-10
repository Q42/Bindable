//
//  VariableDisposeBagTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-09-03.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
import Bindable
import BindableNSObject


class VariableDisposeBagTests: XCTestCase {

  func testChange() {
    var disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable

    var results: [Int] = []

    variable.subscribe { event in
      results.append(event.value)
    }.disposed(by: disposeBag)

    source.value = 2
    source.value = 3
    disposeBag = DisposeBag()
    source.value = 4
    source.value = 5

    XCTAssertEqual(results, [2, 3])
  }

  func testChange2() {
    var disposeBag1 = DisposeBag()
    let disposeBag2 = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable

    var results1: [Int] = []

    variable.subscribe { event in
      results1.append(event.value)
    }.disposed(by: disposeBag1)

    var results2: [Int] = []

    variable.subscribe { event in
      results2.append(event.value)
    }.disposed(by: disposeBag2)

    source.value = 2
    source.value = 3
    disposeBag1 = DisposeBag()
    source.value = 4
    source.value = 5

    XCTAssertEqual(results1, [2, 3])
    XCTAssertEqual(results2, [2, 3, 4, 5])
  }

  func testMapChange() {
    var disposeBag1 = DisposeBag()
    let disposeBag2 = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }

    var results1: [Int] = []

    variable1.subscribe { event in
      results1.append(event.value)
    }.disposed(by: disposeBag1)

    var results2: [Int] = []

    variable2.subscribe { event in
      results2.append(event.value)
    }.disposed(by: disposeBag2)

    source.value = 2
    source.value = 3
    disposeBag1 = DisposeBag()
    source.value = 4
    source.value = 5

    XCTAssertEqual(results1, [2, 3])
    XCTAssertEqual(results2, [3, 4, 5, 6])
  }

  func testMapMapChange() {
    var disposeBag1 = DisposeBag()
    var disposeBag2 = DisposeBag()
    let disposeBag3 = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }
    let variable3 = variable2.map { $0 * 10 }

    var results1: [Int] = []

    variable1.subscribe { event in
      results1.append(event.value)
    }.disposed(by: disposeBag1)

    var results2: [Int] = []

    variable2.subscribe { event in
      results2.append(event.value)
    }.disposed(by: disposeBag2)

    var results3: [Int] = []

    variable3.subscribe { event in
      results3.append(event.value)
    }.disposed(by: disposeBag3)

    source.value = 2
    source.value = 3
    disposeBag1 = DisposeBag()
    source.value = 4
    disposeBag2 = DisposeBag()
    source.value = 5

    XCTAssertEqual(results1, [2, 3])
    XCTAssertEqual(results2, [3, 4, 5])
    XCTAssertEqual(results3, [30, 40, 50, 60])
  }

}
