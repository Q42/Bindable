//
//  ChannelMultipleSubscribeTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-09-03.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
import Bindable
import BindableNSObject


class ChannelMultipleSubscribeTests: XCTestCase {

  func testPost() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var result1 = 0

    channel.subscribe { x in
      result1 = x
    }.disposed(by: disposeBag)

    var result2 = 0

    channel.subscribe { x in
      result2 = x
    }.disposed(by: disposeBag)

    source.post(3)
    XCTAssertEqual(result1, 3)
    XCTAssertEqual(result2, 3)
  }

  func testPosts() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var results1: [Int] = []

    channel.subscribe { x in
      results1.append(x)
    }.disposed(by: disposeBag)

    var results2: [Int] = []

    channel.subscribe { x in
      results2.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results1, [3, 6, -1, 3])
    XCTAssertEqual(results2, [3, 6, -1, 3])
  }

  func testDisposeSubscription() {
    var disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var results1: [Int] = []

    channel.subscribe { x in
      results1.append(x)
    }.disposed(by: disposeBag)

    var results2: [Int] = []

    channel.subscribe { x in
      results2.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    disposeBag = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results1, [3, 6])
    XCTAssertEqual(results2, [3, 6])
  }

}
