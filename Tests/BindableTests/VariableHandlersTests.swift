//
//  VariableHandlersTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-21.
//  Copyright © 2017 Q42. All rights reserved.
//


import XCTest
@testable import Bindable
import BindableNSObject


class VariableHandlersTests: XCTestCase {

  func testChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)

    XCTAssertEqual(source.handlersCount, 0)

    let variable = source.variable

    XCTAssertEqual(source.handlersCount, 0)

    var subscription1: Subscription? = variable.subscribe { event in
    }

    XCTAssertEqual(source.handlersCount, 1)

    _ = variable.subscribe { event in
    }

    XCTAssertEqual(source.handlersCount, 1)

    source.value += 1
    subscription1 = nil
    subscription1?.disposed(by: disposeBag)

    XCTAssertEqual(source.handlersCount, 0)
  }

}
