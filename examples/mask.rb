# frozen_string_literal: true

require_relative "../lib/tty-prompt"
require 'pastel'

prompt = TTY::Prompt.new
heart = prompt.decorate(prompt.symbols[:heart] + ' ', :magenta)

res = prompt.mask('What is your secret?', mask: heart) do |q|
  q.validate(/[a-z\ ]{5,15}/)
end

puts "Secret: \"#{res}\""
