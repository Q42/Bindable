// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Bindable",
  products: [
    .library(name: "Bindable", targets: ["Bindable"]),
    .library(name: "BindableNSObject", targets: ["BindableNSObject"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "Bindable"),
    .target(name: "BindableNSObject", dependencies: ["Bindable"]),
    .testTarget(name: "BindableTests", dependencies: ["BindableNSObject"]),
  ]
)

