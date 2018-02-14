# frozen_string_literal: true

require_relative "lib/kbsecret/version"

Gem::Specification.new do |s|
  s.name                  = "kbsecret"
  s.version               = KBSecret::VERSION
  s.summary               = "kbsecret - A KBFS (Keybase) backed secret manager."
  s.description           = "Manages your passwords, environment, and more via KBFS."
  s.authors               = ["William Woodruff"]
  s.email                 = "william@tuffbizz.com"
  s.files                 = Dir["LICENSE", "*.md", ".yardopts", "lib/**/*"]
  s.executables           = Dir["bin/*"].map { |p| File.basename(p) }
  s.required_ruby_version = ">= 2.3.0"
  s.homepage              = "https://kbsecret.github.io"
  s.license               = "MIT"

  # these need to be installed by developers alone
  s.add_development_dependency "aruba", "~> 1.0.0.pre.alpha.2" # make test-cli
  s.add_development_dependency "minitest", "~> 5.10" # make test
  s.add_development_dependency "rake", "~> 12.0" # make test
  s.add_development_dependency "ronn", "~> 0.7.3" # make man
  s.add_development_dependency "rubocop", "~> 0.51" # make lint
  s.add_development_dependency "simplecov", "~> 0" # make coverage
  s.add_development_dependency "yard", "~> 0.9.9" # make doc

  # these need to be installed by users and developers alike
  s.add_runtime_dependency "clipboard", "~> 1.1"
  s.add_runtime_dependency "dreck", "~> 0.2.1"
  s.add_runtime_dependency "inih", "~> 1.1"
  s.add_runtime_dependency "keybase-unofficial", "~> 1.1", ">= 1.1.1"
  s.add_runtime_dependency "pastel", "~> 0.7"
  s.add_runtime_dependency "slop", "~> 4.6"
  s.add_runtime_dependency "tty-prompt", "~> 0.13"
end
