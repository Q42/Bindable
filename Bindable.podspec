Pod::Spec.new do |s|
  s.name              = "Bindable"
  s.version           = "0.6.0"
  s.summary           = "A Variable<Value> data binding UI"

  s.description       = <<-DESC
                        A `Variable<Value>` data binding UI.
                        DESC

  s.homepage          = "https://github.com/Q42/Bindable"
  s.license           = 'MIT'
  s.author            = { "Tom Lokhorst" => "tom@lokhorst.eu" }

  s.source            = { :git => "https://github.com/Q42/Bindable.git", :tag => s.version }
  s.default_subspec   = "Core"
  s.swift_version     = '4.2'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '4.0'

  s.subspec "Core" do |ss|
    ss.source_files  = ["Sources/Core"]
  end

  s.subspec "NSObject" do |ss|
    ss.ios.deployment_target = '9.0'
    ss.osx.deployment_target = '10.11'
    ss.tvos.deployment_target = '9.0'
    ss.watchos.deployment_target = '4.0'

    ss.source_files = ["Sources/NSObject"]
    ss.dependency "Bindable/Core"
  end

  s.subspec "UIKit" do |ss|
    ss.ios.deployment_target = '9.0'
    ss.tvos.deployment_target = '9.0'

    ss.source_files = ["Sources/UIKit"]
    ss.dependency "Bindable/NSObject"
  end
end

