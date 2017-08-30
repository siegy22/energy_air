# coding: utf-8

require_relative 'lib/energy_air/version'

Gem::Specification.new do |spec|
  spec.name          = "energy_air"
  spec.version       = EnergyAir::VERSION
  spec.authors       = ["Yves Siegrist"]
  spec.email         = ["Elektron1c97@gmail.com"]

  spec.summary       = "Automatically win energy air tickets without playing by yourself."
  spec.homepage      = "https://github.com/siegy22/energy_air"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara", "~> 2.15"
  spec.add_dependency "poltergeist", "~> 1.16"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
end
