# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.yes?('Do you like Ruby?')
