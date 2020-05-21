# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

answer = prompt.ask("Any digit:", convert: :float)

puts "Digit: #{answer.inspect}"
