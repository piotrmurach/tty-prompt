# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

warriors = %w(Scorpion Kano Jax Kitana Raiden)

prompt.on(:keypress) do |event|
  if event.value == 'j'
    prompt.trigger(:keydown)
  end
  if event.value == 'k'
    prompt.trigger(:keyup)
  end
end

answer = prompt.select('Choose your destiny?', warriors)

puts answer.inspect
