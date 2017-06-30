# frozen_string_literal: true

require_relative "lib/version"

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
  s.homepage              = "https://github.com/woodruffw/kbsecret"
  s.license               = "MIT"

  # these need to be installed by developers alone
  s.add_development_dependency "fpm", "~> 1.8" # make pkgs
  s.add_development_dependency "rake", "~> 12.0" # make test
  s.add_development_dependency "ronn", "~> 0.7.3" # make man
  s.add_development_dependency "yard", "~> 0.9.9" # make doc

  # this need to be installed by users and developers alike
  s.add_runtime_dependency "clipboard", "~> 1.1"
  s.add_runtime_dependency "colored2", "~> 3.1"
  s.add_runtime_dependency "dreck", "~> 0.0.7"
  s.add_runtime_dependency "keybase-unofficial", "~> 0.0.8"
  s.add_runtime_dependency "slop", "~> 4.4"
  s.add_runtime_dependency "tty-prompt", "~> 0.10.0"
end
