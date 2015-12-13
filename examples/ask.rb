# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.ask('Do you like Ruby?', required: true, default: true)

prompt.ask('What is your username?') do |q|
  q.validate(/^[^\.]+\.[^\.]+/)
end

prompt.ask('How do you like it on scale 1 - 10?', read: :int) do |q|
  q.in('1-10')
end
