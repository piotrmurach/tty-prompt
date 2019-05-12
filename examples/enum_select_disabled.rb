# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

choices = [
  {name: "Emacs", disabled: '(not installed)'},
  "Atom",
  "GNU nano",
  {name: "Notepad++", disabled: '(not installed)'},
  "Sublime",
  "Vim"
]

prompt.enum_select('Select an editor', choices)
