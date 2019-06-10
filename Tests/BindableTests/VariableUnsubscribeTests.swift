//
//  VariableUnsubscribeTests.swift
//  Bindable
//
//  Created by Tom Lokhorst on 2017-07-18.
//  Copyright © 2017 Q42. All rights reserved.
//

import XCTest
import Bindable
import BindableNSObject


class VariableUnsubscribeTests: XCTestCase {

  func testChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable = source.variable


    // Strong object

    var strongObject: NSObject? = NSObject()
    weak var weakObj = strongObject

    var subscription: Subscription? = variable.subscribe { [strongObject] event in
      XCTAssertNotNil(strongObject)
    }
    strongObject = nil

    XCTAssertNotNil(weakObj)
    subscription = nil
    XCTAssertNil(weakObj)

    subscription?.disposed(by: disposeBag)
  }

  func testMapChange() {
    let disposeBag = DisposeBag()
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }


    // Strong object 1

    var strongObject1: NSObject? = NSObject()
    weak var weakObj1 = strongObject1

    var subscription1: Subscription? = variable1.subscribe { [strongObject1] event in
      XCTAssertNotNil(strongObject1)
    }
    strongObject1 = nil

    XCTAssertNotNil(weakObj1)
    subscription1 = nil
    XCTAssertNil(weakObj1)


    // Strong object 2

    var strongObject2: NSObject? = NSObject()
    weak var weakObj2 = strongObject2

    var subscription2: Subscription? = variable2.subscribe { [strongObject2] event in
      XCTAssertNotNil(strongObject2)
    }
    strongObject2 = nil

    XCTAssertNotNil(weakObj2)
    subscription2 = nil
    XCTAssertNil(weakObj2)

    subscription1?.disposed(by: disposeBag)
    subscription2?.disposed(by: disposeBag)
  }

  func testMapMapChange() {
    let source = VariableSource(value: 1)
    let variable1 = source.variable
    let variable2 = variable1.map { $0 + 1 }
    let variable3 = variable2.map { $0 * 10 }


    // Strong object 1

    var strongObject1: NSObject? = NSObject()
    weak var weakObj1 = strongObject1

    var subscription1: Subscription? = variable1.subscribe { [strongObject1] event in
      XCTAssertNotNil(strongObject1)
    }
    strongObject1 = nil

    XCTAssertNotNil(weakObj1)
    subscription1 = nil
    XCTAssertNil(weakObj1)


    // Strong object 2

    var strongObject2: NSObject? = NSObject()
    weak var weakObj2 = strongObject2

    var subscription2: Subscription? = variable2.subscribe { [strongObject2] event in
      XCTAssertNotNil(strongObject2)
    }
    strongObject2 = nil

    XCTAssertNotNil(weakObj2)
    subscription2 = nil
    XCTAssertNil(weakObj2)


    // Strong object 3

    var strongObject3: NSObject? = NSObject()
    weak var weakObj3 = strongObject3

    var subscription3: Subscription? = variable3.subscribe { [strongObject3] event in
      XCTAssertNotNil(strongObject3)
    }
    strongObject3 = nil

    XCTAssertNotNil(weakObj3)
    subscription3 = nil
    XCTAssertNil(weakObj3)

    subscription1?.disposed(by: disposeBag)
    subscription2?.disposed(by: disposeBag)
    subscription3?.disposed(by: disposeBag)
  }

}
