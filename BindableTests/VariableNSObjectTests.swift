//
//  VariableNSObjectTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-05-02.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
import Bindable

private class Person: NSObject {
  @objc dynamic var name: String?
  @objc dynamic var age: Int = 0
}

class VariableNSObjectTests: XCTestCase {

  func testChange() {
    let source = VariableSource(value: 1)
    let person = Person()
    person.bind(\.age, to: source.variable)

    XCTAssertEqual(person.age, 1)

    source.value += 1
    XCTAssertEqual(person.age, 2)
  }

  func testChangeOptional() {
    let source = VariableSource<String?>(value: nil)
    let person = Person()
    person.bind(\.name, to: source.variable)

    XCTAssertNil(person.name)

    source.value = "Alice"
    XCTAssertEqual(person.name, "Alice")

    source.value = nil
    XCTAssertEqual(person.name, nil)
  }

  func testRebind() {
    let source1 = VariableSource(value: 1)
    let source2 = VariableSource(value: 5)
    let person = Person()
    person.bind(\.age, to: source1.variable)
    person.bind(\.age, to: source2.variable)

    XCTAssertEqual(person.age, 5)

    source1.value = 2
    XCTAssertEqual(person.age, 5)
  }

  func testRebindOptional() {
    let source1 = VariableSource(value: "Alice")
    let person = Person()
    person.bind(\.name, to: source1.variable)
    person.bind(\.name, to: nil)

    XCTAssertEqual(person.name, nil)

    source1.value = "Bob"
    XCTAssertEqual(person.name, nil)
  }

  func testUnbind() {
    let source1 = VariableSource(value: 1)
    let person = Person()
    person.bind(\.age, to: source1.variable)
    person.unbind(\.age, resetTo: 0)

    XCTAssertEqual(person.age, 0)

    source1.value = 2
    XCTAssertEqual(person.age, 0)
  }

  func testUnbindOptional() {
    let source1 = VariableSource(value: "Alice")
    let person = Person()
    person.bind(\.name, to: source1.variable)
    person.unbind(\.name)

    XCTAssertNil(person.name)

    source1.value = "Bob"
    XCTAssertNil(person.name)
  }
}
