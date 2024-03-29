# frozen_string_literal: true

require_relative "lib/tty/prompt/version"

Gem::Specification.new do |spec|
  spec.name = "tty-prompt"
  spec.version = TTY::Prompt::VERSION
  spec.authors = ["Piotr Murach"]
  spec.email = ["piotr@piotrmurach.com"]
  spec.summary = "A beautiful and powerful interactive command line prompt."
  spec.description = "A beautiful and powerful interactive command line " \
                     "prompt with a robust API for getting and validating " \
                     "complex inputs."
  spec.homepage = "https://ttytoolkit.org"
  spec.license = "MIT"
  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "bug_tracker_uri" => "https://github.com/piotrmurach/tty-prompt/issues",
    "changelog_uri" =>
      "https://github.com/piotrmurach/tty-prompt/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/tty-prompt",
    "funding_uri" => "https://github.com/sponsors/piotrmurach",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/piotrmurach/tty-prompt"
  }
  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["CHANGELOG.md", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "pastel", "~> 0.8"
  spec.add_dependency "tty-reader", "~> 0.8"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
