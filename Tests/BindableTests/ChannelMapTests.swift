//
//  ChannelMapTests.swift
//  BindableTests
//
//  Created by Tom Lokhorst on 2018-09-04.
//  Copyright © 2018 Q42. All rights reserved.
//

import XCTest
import Bindable
import BindableNSObject


class ChannelMapTests: XCTestCase {

  func testPost() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel.map { $0 + 1 }

    var result = 0

    channel.subscribe { x in
      result = x
      }.disposed(by: disposeBag)

    source.post(3)
    XCTAssertEqual(result, 4)
  }

  func testPost2() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()

    var result = 0

    source.channel.map { $0 + 1 }.subscribe { x in
      result = x
    }.disposed(by: disposeBag)

    source.post(3)
    XCTAssertEqual(result, 4)
  }

  func testPosts() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel.map { $0 + 1 }

    var results: [Int] = []

    channel.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [4, 7, 0, 4])
  }

  func testPosts2() {
    let disposeBag = DisposeBag()
    let source = ChannelSource<Int>()

    var results: [Int] = []

    source.channel.map { $0 + 1 }.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [4, 7, 0, 4])
  }

  func testDisposeSubscription() {
    var disposeBag = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel.map { $0 + 1 }

    var results: [Int] = []

    channel.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    disposeBag = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [4, 7])
  }

  func testDisposeSubscription2() {
    var disposeBag = DisposeBag()
    let source = ChannelSource<Int>()

    var results: [Int] = []

    source.channel.map { $0 + 1 }.subscribe { x in
      results.append(x)
    }.disposed(by: disposeBag)

    source.post(3)
    source.post(6)
    disposeBag = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results, [4, 7])
  }

  func testMultipleDispose() {
    var disposeBag1 = DisposeBag()
    let disposeBag2 = DisposeBag()
    let source = ChannelSource<Int>()
    let channel = source.channel.map { $0 + 1 }

    var results1: [Int] = []

    channel.subscribe { x in
      results1.append(x)
    }.disposed(by: disposeBag1)

    var results2: [Int] = []

    channel.subscribe { x in
      results2.append(x)
    }.disposed(by: disposeBag2)

    source.post(3)
    source.post(6)
    disposeBag1 = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results1, [4, 7])
    XCTAssertEqual(results2, [4, 7, 0, 4])
  }

  func testMultipleDispose2() {
    var disposeBag1 = DisposeBag()
    let disposeBag2 = DisposeBag()
    let source = ChannelSource<Int>()

    var results1: [Int] = []

    source.channel.map { $0 + 1 }.subscribe { x in
      results1.append(x)
    }.disposed(by: disposeBag1)

    var results2: [Int] = []

    source.channel.map { $0 + 1 }.subscribe { x in
      results2.append(x)
    }.disposed(by: disposeBag2)

    source.post(3)
    source.post(6)
    disposeBag1 = DisposeBag()
    source.post(-1)
    source.post(3)

    XCTAssertEqual(results1, [4, 7])
    XCTAssertEqual(results2, [4, 7, 0, 4])
  }

}
