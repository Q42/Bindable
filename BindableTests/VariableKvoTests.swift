//
//  VariableKvoTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-05-02.
//  Copyright © 2018 Q42. All rights reserved.
//


import XCTest
@testable import Bindable

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

}
