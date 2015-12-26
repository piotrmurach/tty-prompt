# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.ask('How do you like it on scale 1 - 10?', read: :int) do |q|
  q.in('1-10')
end
