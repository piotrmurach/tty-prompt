# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

commands = [
  {
    "read" => value: ["key"],
    "write" => value: ["key", "value"]
  }
]

answer = prompt.command(">", commands)

puts answer.inspect
