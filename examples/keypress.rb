# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt::new

answer = prompt.keypress("Press any key to continue")

puts "Answer: #{answer}"
