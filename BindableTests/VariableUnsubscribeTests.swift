//
//  VariableUnsubscribeTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-18.
//  Copyright © 2017 Q42. All rights reserved.
//

import XCTest
import Bindable

class VariableUnsubscribeTests: XCTestCase {

  func testChange() {
    let source = VariableSource(value: 1)
    let variable = source.variable


    // Strong object

    var strongObject: NSObject? = NSObject()
    weak var weakObj = strongObject

    let subscription = variable.subscribe { [strongObject] event in
      XCTAssertNotNil(strongObject)
    }
    strongObject = nil

    XCTAssertNotNil(weakObj)
    subscription.unsubscribe()
    XCTAssertNil(weakObj)
  }

  func testMapChange() {
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }


    // Strong object 1

    var strongObject1: NSObject? = NSObject()
    weak var weakObj1 = strongObject1

    let subscription1 = variable1.subscribe { [strongObject1] event in
      XCTAssertNotNil(strongObject1)
    }
    strongObject1 = nil

    XCTAssertNotNil(weakObj1)
    subscription1.unsubscribe()
    XCTAssertNil(weakObj1)


    // Strong object 2

    var strongObject2: NSObject? = NSObject()
    weak var weakObj2 = strongObject2

    let subscription2 = variable2.subscribe { [strongObject2] event in
      XCTAssertNotNil(strongObject2)
    }
    strongObject2 = nil

    XCTAssertNotNil(weakObj2)
    subscription2.unsubscribe()
    XCTAssertNil(weakObj2)
  }

  func testMapMapChange() {
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }
    let variable3 = variable2.map { $0 * 10 }


    // Strong object 1

    var strongObject1: NSObject? = NSObject()
    weak var weakObj1 = strongObject1

    let subscription1 = variable1.subscribe { [strongObject1] event in
      XCTAssertNotNil(strongObject1)
    }
    strongObject1 = nil

    XCTAssertNotNil(weakObj1)
    subscription1.unsubscribe()
    XCTAssertNil(weakObj1)


    // Strong object 2

    var strongObject2: NSObject? = NSObject()
    weak var weakObj2 = strongObject2

    let subscription2 = variable2.subscribe { [strongObject2] event in
      XCTAssertNotNil(strongObject2)
    }
    strongObject2 = nil

    XCTAssertNotNil(weakObj2)
    subscription2.unsubscribe()
    XCTAssertNil(weakObj2)


    // Strong object 3

    var strongObject3: NSObject? = NSObject()
    weak var weakObj3 = strongObject3

    let subscription3 = variable3.subscribe { [strongObject3] event in
      XCTAssertNotNil(strongObject3)
    }
    strongObject3 = nil

    XCTAssertNotNil(weakObj3)
    subscription3.unsubscribe()
    XCTAssertNil(weakObj3)
  }

}
