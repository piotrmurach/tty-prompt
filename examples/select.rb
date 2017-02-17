# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

warriors = %w(Scorpion Kano Jax Kitana Raiden)

prompt.on(:keypress) do |event|
  if event.value == 'j'
    prompt.emit(:keydown)
  end
  if event.value == 'k'
    prompt.emit(:keyup)
  end
end

prompt.select('Choose your destiny?', warriors)
