# frozen_string_literal: true

require_relative "../lib/tty-prompt"

@prompt = TTY::Prompt.new(quiet: true)
@cool = 0

def main_menu(_from = nil)
  name = @prompt.select("Cool Menu") do |menu|
    menu.enum "."

    menu.choice "Coolness Status", :status_menu
    menu.choice "Manage Coolness", :manage_menu
    menu.choice "Exit", "exit"
  end

  next_menu(name, :main_menu)
end

def next_menu(name, from)
  if name.is_a?(Symbol)
    send(name, from)
  else
    eval(name)
  end
end

def status_menu(from)
  name = @prompt.select("Coolness is at #{@cool}") do |menu|
    menu.enum "."

    menu.choice "Back", from
    menu.choice "Exit", "exit"
  end

  next_menu(name, :status_menu)
end

def manage_menu(_from)
  name = @prompt.select("Coolness is at #{@cool}.\nManage") do |menu|
    menu.enum "."

    menu.choice "Add coolness", :add_cool
    menu.choice "Back", :main_menu
    menu.choice "Exit", "exit"
  end

  next_menu(name, :manage_menu)
end

def add_cool(from)
  @cool += 1
  next_menu(from, from)
end

main_menu
