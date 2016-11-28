# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

warriors = %w(Scorpion Kano Jax)

prompt.on(:keypress) do |event|
  if event.key.name == 'j'
    prompt.publish(:keydown)
  end
  if event.key.name == 'k'
    prompt.publish(:keyup)
  end
end

prompt.select('Choose your destiny?', warriors)
