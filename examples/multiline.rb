# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt::new

answer = prompt.multiline("Description:")

puts "Answer: #{answer.inspect}"
