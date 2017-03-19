# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt::new

prompt.keypress("Press space or enter to continue, continuing automatically in :countdown ...", keys: [:space, :return], timeout: 3)
