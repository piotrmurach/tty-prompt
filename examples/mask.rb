# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.mask('What is your secret?') do |q|
  q.validate /[a-z]{5,8}/
end
