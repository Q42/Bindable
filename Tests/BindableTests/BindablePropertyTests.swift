//
//  BindablePropertyTests.swift
//  Bindable
//
//  Created by Tim van Steenis on 15/12/2019.
//

import XCTest
import Bindable
import BindableNSObject

private class MockModel {
  @Bindable var age: Int

  init(age: Int) {
    self.age = age
  }
}

class BindablePropertyTests: XCTestCase {

  func testInitialValue() {
    let model = MockModel(age: 10)

    XCTAssertEqual(model.age, 10)
    XCTAssertEqual(model.$age.value, 10)
  }

  func testChange() {
    let model = MockModel(age: 0)
    model.age = 1

    XCTAssertEqual(model.$age.value, 1)
  }

  func testExclusiveAccess() {
    let model = MockModel(age: 0)
    model.$age.subscribe { _ in
      print(model.age)
    }.disposed(by: disposeBag)
    model.age = 1

    XCTAssertEqual(model.$age.value, 1)
  }
}
