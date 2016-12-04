# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

alfabet = ('A'..'Z').to_a

prompt.select('Choose your destiny?', alfabet, per_page: 8)
