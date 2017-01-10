# encoding: utf-8

require 'tty/prompt'
require 'tty/prompt/test'
require 'tty/prompt/version'

# A collection of small libraries for building CLI apps,
# each following unix philosophy of focused task
module TTY
  class Prompt
    ConfigurationError = Class.new(StandardError)

    ConversionError = Class.new(StandardError)
  end
end # TTY
