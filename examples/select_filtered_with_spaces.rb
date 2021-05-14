# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

warriors = ["Jax", "Jax Jr", "Kitana", "Raiden ft. Thunder"]

answer = prompt.select("Choose your destiny?", warriors, filter: true, submit_keys: [:return, :tab])

puts answer.inspect
