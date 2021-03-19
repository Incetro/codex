Pod::Spec.new do |spec|
  spec.name          = 'Codex'
  spec.version       = '0.1.2'
  spec.license       = 'MIT'
  spec.authors       = { 'incetro' => 'incetro@ya.ru' }
  spec.homepage      = "https://github.com/Incetro/codex.git"
  spec.summary       = 'Elegant Codable wrapper which makes your work a little bit sweety'

  spec.ios.deployment_target     = "12.0"
  spec.osx.deployment_target     = "10.15"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target    = "12.4"

  spec.swift_version = '5.0'
  spec.source        = { :git => "https://github.com/Incetro/codex.git", :tag => spec.version.to_s }
  spec.source_files  = "Sources/Codex/**/*.{h,swift}"
end
