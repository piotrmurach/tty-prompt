# frozen_string_literal: true

require_relative "../lib/tty-prompt"

prompt = TTY::Prompt.new

prompt.ask("What\nis your\nname?", default: ENV['USER'])
