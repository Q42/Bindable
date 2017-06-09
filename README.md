<img src="https://cloud.githubusercontent.com/assets/75655/26639485/3dd02ab4-4625-11e7-9085-a4d0967a782e.png" width="126" alt="Bindable">

<hr>

This is the first development version of the Bindable UI databinding library.
API is not yet stable, use at your own risk.

## Example

```swift
class MainPresenter {
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


let p = MainPresenter()
p.age.subscribe { event in
  print("New age: \(event.value)")
}

titleLabel.bind(text: p.title)
```

Releases
--------

 - **0.1.0** - 2017-05-31 - Initial public release
 - 0.0.0 - 2016-12-14 - Initial private version for project at [Q42](http://q42.com)

## License & Credits

Bindable is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) of [Q42](https://q42.com) and available under the [MIT license](https://github.com/Q42/Bindable/blob/develop/LICENSE), so feel free to use it in commercial and non-commercial projects.

