# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

answer = prompt.ask('Password?', echo: false) do |q|
  q.validate(/^[^\.]+\.[^\.]+/)
end

#puts answer
