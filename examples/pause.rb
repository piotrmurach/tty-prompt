# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt::new

prompt.keypress("Press space or enter to continue", keys: [:space, :return], timeout: 3)
