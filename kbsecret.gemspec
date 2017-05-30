# frozen_string_literal: true

require_relative "lib/kbsecret"

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
  s.add_runtime_dependency "keybase-unofficial", "~> 0.0.6"
  s.add_runtime_dependency "slop", "~> 4.4"
  s.add_runtime_dependency "tty-prompt", "~> 0.10.0"
  s.add_runtime_dependency "pastel", "~> 0.7"
  s.add_runtime_dependency "clipboard", "~> 1.1"
end
