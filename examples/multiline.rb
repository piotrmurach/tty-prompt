# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt::new

answer = prompt.multiline("Description:")

puts "Answer: #{answer.inspect}"
