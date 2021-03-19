Pod::Spec.new do |spec|
  spec.name          = 'Codex'
  spec.version       = '0.1.1'
  spec.license       = 'MIT'
  spec.authors       = { 'incetro' => 'incetro@ya.ru' }
  spec.homepage      = "https://github.com/Incetro/codex.git"
  spec.summary       = 'Open Source'

  spec.ios.deployment_target     = "12.0"
  spec.osx.deployment_target     = "10.15"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target    = "12.4"

  spec.swift_version = '5.0'
  spec.source        = { git: "https://github.com/Incetro/codex.git", tag: "#{spec.version}" }
  spec.source_files  = "Sources/Codex/**/*.{h,swift}"
end
