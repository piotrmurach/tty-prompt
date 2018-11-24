# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt::new

answer = prompt.keypress("Press any key to continue")

puts "Answer: #{answer.inspect}"
