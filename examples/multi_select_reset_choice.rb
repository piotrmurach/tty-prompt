# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

drinks = %w[vodka beer wine whisky bourbon none]
prompt.multi_select("Choose your favourite drink?", drinks, reset_choice: "none")

genres = {
  a: "Action games",
  b: "Arcade games",
  c: "Fighting games",
  d: "First-person shooters",
  e: "Music Games",
  f: "Party games",
  g: "Racing games",
  h: "Role-playing games",
  i: "Sports games",
  j: "Strategy games",
  k: "None of the above"
}

opts = { max: 3, reset_choice: ["None of the above", :k] }
prompt.multi_select("Choose your favourite game genres", opts) do |input|
  genres.each_pair do |key, value|
    input.choice value, key
  end
end
