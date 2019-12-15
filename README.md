<img src="https://cloud.githubusercontent.com/assets/75655/26639485/3dd02ab4-4625-11e7-9085-a4d0967a782e.png" width="126" alt="Bindable">

<hr>

This is the first development version of the Bindable UI databinding library.
API is not yet stable, use at your own risk.

## Installation

Include the following line in your Podfile:

```bash
pod 'Bindable/NSObject', :git => 'git@github.com:Q42/Bindable.git'
```

Or, via HTTPS:
```
pod 'Bindable/NSObject', :git => 'https://github.com/Q42/Bindable.git'
```

## Example

Create a view model:

```swift
class MainViewModel {
  private let ageSource = VariableSource<Int>(value: 0)

  let age: Variable<Int>
  let title: Variable<String>
  
  init() {
    age = ageSource.variable
    title = age.map { "Age: \($0)" }
  }


  func up() {
    ageSource.value += 1
  }

  func down() {
    ageSource.value -= 1
  }
}
```

And use it in your view controller:

```swift
let viewModel = MainViewModel()

// Manually subscribe for change events
ageSubscription = viewModel.age.subscribe { event in
  print("New age: \(event.value)")
}

// Or data bind a UILabel
titleLabel.bind(\.text, to: viewModel.title)
```

Since `0.0.8` it is also possible to use `@Bindable` instead of a source. Using the same example:

```swift
class MainViewModel {
  @Bindable var age: Int = 0  
  
  let title: Variable<String>
  
  init() {
    title = $age.map { "Age: \($0)" }
  }


  func up() {
    age += 1
  }

  func down() {
    age -= 1
  }
}
```
The variable's will be exposed by using:

```
```swift
let viewModel = MainViewModel()

// Manually subscribe for change events
ageSubscription = viewModel.$age.subscribe { event in
  print("New age: \(event.value)")
}

// Or data bind a UILabel
titleLabel.bind(\.text, to: viewModel.$title)
```

CocoaHeadsNL presentation
-------------------------

Tom Lokhorst presented at the September 2017 CocoaHeadsNL meetup.
Comparing several methods for reactivally updating UI's, including Bindable. The description of Bindable starts at 27:33:

<a href="https://vimeo.com/237530468#t=27m33s"><img src="https://user-images.githubusercontent.com/75655/31451656-f63bfb88-aeac-11e7-8d6c-d65216dd10a1.jpg" width="560"></a>

[https://vimeo.com/237530468#t=27m33s](https://vimeo.com/237530468#t=27m33s)

Releases
--------

 - 0.7.0 - 2019-06-10 - Swift 5.1 in podspec, remove UIKit extension
 - 0.6.2 - 2019-05-09 - Change retain logic of NSObject.bind
 - 0.6.1 - 2019-04-28 - Add convenient extension functions
 - **0.6.0** - 2019-04-25 - Strong references to subscriptions are now required
 - **0.5.0** - 2018-09-13 - Update to Swift 4.2, refactor internal to use classes
 - 0.4.1 - 2018-05-02 - Add Variable+KVO
 - 0.3.0 - 2018-04-24 - Split out NSObject subspec
 - 0.2.0 - 2018-02-26 - Fix occasional "execute on wrong queue" issue
 - **0.1.0** - 2017-05-31 - Initial public release
 - 0.0.0 - 2016-12-14 - Initial private version for project at [Q42](http://q42.com)

## License & Credits

Bindable is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) of [Q42](https://q42.com) and available under the [MIT license](https://github.com/Q42/Bindable/blob/develop/LICENSE), so feel free to use it in commercial and non-commercial projects.

