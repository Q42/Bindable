//
//  VariableKvoTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-05-02.
//  Copyright © 2018 Q42. All rights reserved.
//


import XCTest
@testable import Bindable
import BindableNSObject


private class Person: NSObject {
  @objc dynamic var name: String = ""
}

class VariableKvoTests: XCTestCase {

  func testVariableChange() {
    let person = Person()
    let name = person.variable(kvoKeyPath: \.name)

    XCTAssertEqual(name.value, "")

    person.name = "Alice"
    XCTAssertEqual(name.value, "Alice")

    person.name = "Bob"
    XCTAssertEqual(name.value, "Bob")
  }

  func testWeak() {
    var person: Person? = Person()
    weak var weakPerson = person
    let name = weakPerson!.variable(kvoKeyPath: \.name)

    XCTAssertNotNil(weakPerson)

    person?.name = "Alice"
    person = nil

    XCTAssertNil(weakPerson)
    XCTAssertEqual(name.value, "Alice")
  }

  func testMap() {
    let person = Person()
    let name = person.variable(kvoKeyPath: \.name)
    let count = name.map { $0.count }

    XCTAssertEqual(count.value, 0)

    person.name = "Alice"

    XCTAssertEqual(count.value, 5)

    person.name = "Bob"

    XCTAssertEqual(count.value, 3)
  }

  func testWeakMap() {
    var person: Person? = Person()
    weak var weakPerson = person
    let name = weakPerson!.variable(kvoKeyPath: \.name)
    let count = name.map { $0.count }

    XCTAssertEqual(count.value, 0)

    person?.name = "Alice"

    XCTAssertEqual(count.value, 5)

    person = nil

    XCTAssertNil(weakPerson)
    XCTAssertEqual(count.value, 5)
  }

  func testReset() {
    let person = Person()
    let name1 = person.variable(kvoKeyPath: \.name)

    XCTAssertEqual(name1.value, "")

    person.name = "Alice"
    XCTAssertEqual(name1.value, "Alice")

    let name2 = person.variable(kvoKeyPath: \.name)

    person.name = "Bob"
    XCTAssertEqual(name2.value, "Bob")
    XCTAssertEqual(name1.value, "Bob")
  }

  func testResetMap() {
    let person = Person()
    let name1 = person.variable(kvoKeyPath: \.name)
    let count = name1.map { $0.count }

    XCTAssertEqual(count.value, 0)

    person.name = "Alice"
    XCTAssertEqual(count.value, 5)

    let name2 = person.variable(kvoKeyPath: \.name)

    person.name = "Bob"
    XCTAssertEqual(count.value, 3)
    XCTAssertEqual(name2.value, "Bob")
  }

  func testDeinit() {
    let person = Person()
    var name: Variable<String>? = person.variable(kvoKeyPath: \.name)

    XCTAssertEqual(name!.value, "")

    person.name = "Alice"
    XCTAssertEqual(name!.value, "Alice")

    name = nil

    person.name = "Bob"
  }

  func testDeinitMap1() {
    let person = Person()
    var name: Variable<String>? = person.variable(kvoKeyPath: \.name)
    let count = name!.map { $0.count }

    XCTAssertEqual(count.value, 0)

    person.name = "Alice"
    XCTAssertEqual(count.value, 5)

    name = nil

    person.name = "Bob"
    XCTAssertEqual(count.value, 3)
  }

  func testDeinitMap2() {
    let person = Person()
    var name: Variable<String>? = person.variable(kvoKeyPath: \.name)
    let name2 = name!.map { $0 }

    XCTAssertEqual(name?.value, "")
    XCTAssertEqual(name2.value, "")

    person.name = "Alice"
    XCTAssertEqual(name?.value, "Alice")
    XCTAssertEqual(name2.value, "Alice")

    name = nil

    person.name = "Bob"
    XCTAssertEqual(name2.value, "Bob")
  }

}
