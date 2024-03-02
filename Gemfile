source "https://rubygems.org"

gemspec

# gem "tty-reader", git: "https://github.com/piotrmurach/tty-reader"
# gem "pastel", git: "https://github.com/piotrmurach/pastel"
gem "json", "2.4.1" if RUBY_VERSION == "2.0.0"

group :test do
  gem "benchmark-ips", "~> 2.13.0"

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0")
    gem "coveralls_reborn", "~> 0.28.0"
    gem "simplecov", "~> 0.22.0"
  end
end
