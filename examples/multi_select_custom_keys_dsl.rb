# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

drinks = %w[vodka beer wine whisky bourbon]
prompt.multi_select("Choose your favourite drink?") do |menu|
  menu.choices drinks
  menu.confirm_keys :return, {escape: "Esc"}, "."
  menu.select_keys({space: "Spacebar"}, :ctrl_s, ",")
end
