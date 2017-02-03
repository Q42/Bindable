Pod::Spec.new do |s|
  s.name             = "Bindable"
  s.version          = "0.1.0"
  s.summary          = "Simple Bindable<Value> for Swift"

  s.description      = <<-DESC
                       Simple `Bindable<Value>` for Swift.
                       DESC

  s.homepage         = "https://github.com/Q42/Bindable"
  s.license          = 'MIT'
  s.author           = { "Tom Lokhorst" => "tom@lokhorst.eu" }
  s.source           = { :git => "https://github.com/Q42/Bindable.git", :tag => s.version }

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = ["Sources/Bindable.swift", "Sources/DisposeBag.swift"]
  end
end

