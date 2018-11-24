# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt::new

answer = prompt.keypress("Press space or enter to continue, continuing automatically in :countdown ...", keys: [:space, :return], timeout: 3)

puts "Answer: #{answer.inspect}"
