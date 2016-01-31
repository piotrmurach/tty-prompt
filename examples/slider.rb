# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new
prompt.slider("What size?", min: 32, max: 54, step: 2)
