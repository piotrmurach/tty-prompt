# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new(track_history: true)

commands = {
  "read" => ["key"],
  "write" => ["key", "value"]
}

answer = prompt.command(">", commands)
answer = prompt.command(">", commands)

puts answer.inspect
