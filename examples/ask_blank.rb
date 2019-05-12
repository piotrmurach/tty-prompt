# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new(prefix: ">")

answer= prompt.ask

puts "Answer: \"#{answer}\""
