# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

puts prompt.ask('Password?', echo: false)
