
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "auth_dns_check/version"

Gem::Specification.new do |spec|
  spec.name          = "auth_dns_check"
  spec.version       = AuthDnsCheck::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]

  spec.summary       = %q{Authoritative DNS check}
  spec.description   = %q{Checks that all authoritatives answer for a new record.}
  spec.homepage      = "https://github.com/starjuice/auth_dns_check"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "< 3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
