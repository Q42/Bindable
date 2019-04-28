//
//  ChannelPostTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-09-03.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
import Bindable

class ChannelPostTests: XCTestCase {

  func testPost() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var result = 0

    channel.subscribe { x in
      result = x
    }.disposed(by: disposeBag)

    source.post(3)
    XCTAssertEqual(result, 3)
  }

  func testPosts() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var results: [Int] = []

    channel.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [3, 6, -1, 3])
  }

  func testDisposeSubscription() {
    var disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel

    var results: [Int] = []

    channel.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    disposeBag = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [3, 6])
  }

}
