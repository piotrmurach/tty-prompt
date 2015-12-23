# encoding: utf-8

require 'necromancer'
require 'pastel'
require 'tty-cursor'
require 'tty-platform'

require 'tty/prompt'
require 'tty/prompt/choice'
require 'tty/prompt/choices'
require 'tty/prompt/evaluator'
require 'tty/prompt/list'
require 'tty/prompt/multi_list'
require 'tty/prompt/mode'
require 'tty/prompt/question'
require 'tty/prompt/reader'
require 'tty/prompt/statement'
require 'tty/prompt/suggestion'
require 'tty/prompt/symbols'
require 'tty/prompt/test'
require 'tty/prompt/utils'
require 'tty/prompt/version'

# A collection of small libraries for building CLI apps,
# each following unix philosophy of focused task
module TTY
  PromptConfigurationError = Class.new(StandardError)
end
