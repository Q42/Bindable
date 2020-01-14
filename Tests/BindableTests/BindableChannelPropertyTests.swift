//
//  BindableChannelPropertyTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2020-01-14.
//

import XCTest
import Bindable
import BindableNSObject

private class MockModel {
  @BindableChannel var messages: Channel<String>

  init() {
  }

  func sendMessage() {
    _messages.post("Test")
  }
}

class BindableChannelPropertyTests: XCTestCase {

  func testEvent() {
    let disposeBag = DisposeBag()
    let model = MockModel()

    var result = ""

    model.messages.subscribe { x in
      result = x
    }.disposed(by: disposeBag)

    model.sendMessage()
    XCTAssertEqual(result, "Test")
  }
}
