# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

answer = prompt.yes?("Do you like Ruby?")

puts "Answer: #{answer}"
