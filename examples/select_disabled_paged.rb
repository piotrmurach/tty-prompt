# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

numbers = [
  {name: '1', disabled: 'out'},
  '2',
  {name: '3', disabled: 'out'},
  '4',
  '5',
  {name: '6', disabled: 'out'},
  '7',
  '8',
  '9',
  {name: '10', disabled: 'out'}
]

answer = prompt.select('Which letter?', numbers, per_page: 4, cycle: true)

puts answer.inspect
