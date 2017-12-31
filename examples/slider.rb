# encoding: utf-8

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new
prompt.slider("Volume", min: 0, max: 100, step: 5, format: "|:slider| %d%")
