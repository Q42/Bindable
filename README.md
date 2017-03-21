# Bindable

Example:

```swift
class MainPresenter {
  private let ageSource = VariableSource<Int>(value: 0)

  var age: Variable<Int> { return ageSource.variable }
  let title: Variable<String> { return ageSource.variable }


  func up() {
    ageSource.value += 1
  }

  func down() {
    ageSource.value -= 1
  }
}


let p = MainPresenter()
p.age.subscribe { print($0) }

let title = age.map { "Age: \($0)" }
titleLabel.bind(text: title)
```

