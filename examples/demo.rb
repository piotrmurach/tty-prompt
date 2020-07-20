# frozen_string_literal: true

require "json"
require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new
warriors = [
 "Baraka", "Jade", "Jax", "Johnny Cage", "Kano", "Kintaro",  "Kitana",
 "Liu Kang", "Raiden", "Scorpion", "Sonya Blade", "Sub-Zero", "Goro",
 "Reptile", "Mileena",
]
cheats = [
  "Freeplay",
  "No Damage to P1",
  "No Damage to P2",
  "1 Hit Kills P1",
  "1 Hit Kills P2",
  "Soak Test",
  "Stop clock"
]

puts TTY::Cursor.save

result = prompt.collect do
  key(:name).ask("Player name:")
  key(:player).select("Character:", warriors)
  key(:level).ask("Level (1-10)?", convert: :int, in: (1..10))
  key(:blood).yes?("Blood?")
  key(:cheats).multi_select("Cheats:", cheats)
  key(:volume).slider("Volume", max: 10, step: 1)
end

print TTY::Cursor.clear_screen_up
print TTY::Cursor.restore + TTY::Cursor.show
puts
puts JSON.pretty_generate(result)
puts
