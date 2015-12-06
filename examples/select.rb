# encoding: utf-8

require 'tty-prompt'

prompt = TTY::Prompt.new

warriors = %w(Scorpion Kano Jax)
prompt.select('Choose your destiny?', warriors)

drinks = %w(vodka beer wine whisky bourbon)
prompt.multi_select('Choose your favourite drink?', drinks)
