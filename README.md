# Bindable

Example:

```swift
class MainPresenter {
  private let ageSource = BindableSource<Int>(value: 0)

  var age: Bindable<Int> { return ageSource.bindable }


  func up() {
    ageSource.value += 1
  }

  func down() {
    ageSource.value -= 1
  }
}


let p = MainPresenter()
p.age.subscribe { print($0) }
```

