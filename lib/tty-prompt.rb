# encoding: utf-8

require 'necromancer'
require 'pastel'
require 'tty-cursor'
require 'tty-platform'

require 'tty/prompt'
require 'tty/prompt/choice'
require 'tty/prompt/choices'
require 'tty/prompt/enum_list'
require 'tty/prompt/evaluator'
require 'tty/prompt/list'
require 'tty/prompt/multi_list'
require 'tty/prompt/question'
require 'tty/prompt/mask_question'
require 'tty/prompt/confirm_question'
require 'tty/prompt/reader'
require 'tty/prompt/slider'
require 'tty/prompt/statement'
require 'tty/prompt/suggestion'
require 'tty/prompt/answers_collector'
require 'tty/prompt/symbols'
require 'tty/prompt/test'
require 'tty/prompt/utils'
require 'tty/prompt/version'

# A collection of small libraries for building CLI apps,
# each following unix philosophy of focused task
module TTY
  class Prompt
    ConfigurationError = Class.new(StandardError)

    ConversionError = Class.new(StandardError)
  end
end # TTY
