require_relative "lib/cerealizer/version"

Gem::Specification.new do |spec|
  spec.name           = "cerealizer"
  spec.version        = ::Cerealizer::VERSION
  spec.platform       = ::Gem::Platform::RUBY
  spec.authors        = ["Kien La"]
  spec.email          = ["la.kien@gmail.com"]
  spec.description    = "Cerealizer is a simple json serialization library for Ruby"
  spec.summary        = spec.description
  spec.homepage       = "https://github.com/kla/cerealizer"
  spec.files          = ::Dir.glob("{lib}/**/*")
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]

  spec.add_dependency("multi_json")
  spec.add_dependency("activesupport", ">= 5.0.0")

  spec.add_development_dependency("rake")
  spec.add_development_dependency("minitest")
  spec.add_development_dependency("activerecord", ">= 5.0.0")
  spec.add_development_dependency("sqlite3")
  spec.add_development_dependency("oj")
end
