# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt::new(interrupt: :exit)

prompt.on(:keypress) do |event|
  puts "name: #{event.key.name}, value: #{event.value.dump}"
end

prompt.on(:keyescape) do |event|
  exit
end

prompt.read_keypress
