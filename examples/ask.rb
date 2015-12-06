# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

prompt.ask('Do you like Ruby?', required: true, default: true)
