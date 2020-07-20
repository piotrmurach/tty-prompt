# frozen_string_literal: true

require "json"
require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new
envs = %w[local development test staging production]
platforms = %w[Debian Ubuntu Fedora Windows macOS]

puts TTY::Cursor.save

result = prompt.collect do
  key(:username).ask("Username:")
  key(:password).mask("Password:")
  key(:env).select("Environment:", envs)
  key(:version).ask("Version (1-10)?", convert: :int, in: (1..10))
  key(:verbose).yes?("Verbose?")
  key(:platforms).multi_select("Platforms?", platforms)
  key(:nodes).slider("Number of nodes?", max: 20, step: 1)
end

print TTY::Cursor.clear_screen_up
print TTY::Cursor.restore + TTY::Cursor.show
puts
puts JSON.pretty_generate(result)
puts
