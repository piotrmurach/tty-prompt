# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.ask("What is your secret?") do |q|
  q.mask "*"
end
