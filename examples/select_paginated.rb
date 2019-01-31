# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

alfabet = ('A'..'Z').to_a

answer = prompt.select('Which letter?', alfabet, per_page: 7, cycle: true, default: 5)

puts answer.inspect
