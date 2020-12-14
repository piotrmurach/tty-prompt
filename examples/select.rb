# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

warriors = %i[Scorpion Kano Jax Kitana Raiden]

prompt.on(:keypress) do |event|
  prompt.trigger(:keydown) if event.value == "j"
  prompt.trigger(:keyup) if event.value == "k"
end

prompt.on(:keyescape) do |event|
  exit(1)
end

answer = prompt.select("Choose your destiny?", warriors)

puts answer.inspect
