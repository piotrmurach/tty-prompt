# frozen_string_literal: true

require "forwardable"
require "pastel"
require "tty-cursor"
require "tty-reader"
require "tty-screen"

require_relative "prompt/answers_collector"
require_relative "prompt/confirm_question"
require_relative "prompt/errors"
require_relative "prompt/expander"
require_relative "prompt/enum_list"
require_relative "prompt/keypress"
require_relative "prompt/list"
require_relative "prompt/multi_list"
require_relative "prompt/multiline"
require_relative "prompt/mask_question"
require_relative "prompt/question"
require_relative "prompt/slider"
require_relative "prompt/statement"
require_relative "prompt/suggestion"
require_relative "prompt/symbols"
require_relative "prompt/utils"
require_relative "prompt/version"

module TTY
  # A main entry for asking prompt questions.
  class Prompt
    extend Forwardable

    # @api private
    attr_reader :input

    # @api private
    attr_reader :output

    attr_reader :reader

    attr_reader :cursor

    # Prompt prefix
    #
    # @example
    #   prompt = TTY::Prompt.new(prefix: [?])
    #
    # @return [String]
    #
    # @api private
    attr_reader :prefix

    # Theme colors
    #
    # @api private
    attr_reader :active_color, :help_color, :error_color, :enabled_color

    # Quiet mode
    #
    # @api private
    attr_reader :quiet

    # The collection of display symbols
    #
    # @example
    #   prompt = TTY::Prompt.new(symbols: {marker: ">"})
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :symbols

    def_delegators :@pastel, :strip

    def_delegators :@cursor, :clear_lines, :clear_line,
                   :show, :hide

    def_delegators :@reader, :read_char, :read_keypress, :read_line,
                   :read_multiline, :on, :subscribe, :unsubscribe, :trigger,
                   :count_screen_lines

    def_delegators :@output, :print, :puts, :flush

    def self.messages
      {
        range?: "Value %{value} must be within the range %{in}",
        valid?: "Your answer is invalid (must match %{valid})",
        required?: "Value must be provided",
        convert?: "Cannot convert `%{value}` to '%{type}' type"
      }
    end

    # Initialize a Prompt
    #
    # @param [IO] :input
    #   the input stream
    # @param [IO] :output
    #   the output stream
    # @param [Hash] :env
    #   the environment variables
    # @param [Hash] :symbols
    #   the symbols displayed in prompts such as :marker, :cross
    # @param options [Boolean] :quiet
    #   enable quiet mode, don't re-echo the question
    # @param [String] :prefix
    #   the prompt prefix, by default empty
    # @param [Symbol] :interrupt
    #   handling of Ctrl+C key out of :signal, :exit, :noop
    # @param [Boolean] :track_history
    #   disable line history tracking, true by default
    # @param [Boolean] :enable_color
    #   enable color support, true by default
    # @param [String,Proc] :active_color
    #   the color used for selected option
    # @param [String,Proc] :help_color
    #   the color used for help text
    # @param [String] :error_color
    #   the color used for displaying error messages
    #
    # @api public
    def initialize(input: $stdin, output: $stdout, env: ENV, symbols: {},
                   prefix: "", interrupt: :error, track_history: true,
                   quiet: false, enable_color: nil, active_color: :green,
                   help_color: :bright_black, error_color: :red)
      @input  = input
      @output = output
      @env    = env
      @prefix = prefix
      @enabled_color = enable_color
      @active_color  = active_color
      @help_color    = help_color
      @error_color   = error_color
      @interrupt     = interrupt
      @track_history = track_history
      @symbols       = Symbols.symbols.merge(symbols)
      @quiet         = quiet

      @cursor = TTY::Cursor
      @pastel = enabled_color.nil? ? Pastel.new : Pastel.new(enabled: enabled_color)
      @reader = TTY::Reader.new(
        input: input,
        output: output,
        interrupt: interrupt,
        track_history: track_history,
        env: env
      )
    end

    # Decorate a string with colors
    #
    # @param [String] :string
    #   the string to color
    # @param [Array<Proc|Symbol>] :colors
    #   collection of color symbols or callable object
    #
    # @api public
    def decorate(string, *colors)
      if Utils.blank?(string) || @enabled_color == false || colors.empty?
        return string
      end

      coloring = colors.first
      if coloring.respond_to?(:call)
        coloring.call(string)
      else
        @pastel.decorate(string, *colors)
      end
    end

    # Invoke a question type of prompt
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.invoke_question(Question, "Your name? ")
    #
    # @return [String]
    #
    # @api public
    def invoke_question(object, message, **options, &block)
      options[:messages] = self.class.messages
      question = object.new(self, **options)
      question.(message, &block)
    end

    # Ask a question.
    #
    # @example
    #   propmt = TTY::Prompt.new
    #   prompt.ask("What is your name?")
    #
    # @param [String] message
    #   the question to be asked
    #
    # @yieldparam [TTY::Prompt::Question] question
    #   further configure the question
    #
    # @yield [question]
    #
    # @return [TTY::Prompt::Question]
    #
    # @api public
    def ask(message = "", **options, &block)
      invoke_question(Question, message, **options, &block)
    end

    # Ask a question with a keypress answer
    #
    # @see #ask
    #
    # @api public
    def keypress(message = "", **options, &block)
      invoke_question(Keypress, message, **options, &block)
    end

    # Ask a question with a multiline answer
    #
    # @example
    #   prompt.multiline("Description?")
    #
    # @return [Array[String]]
    #
    # @api public
    def multiline(message = "", **options, &block)
      invoke_question(Multiline, message, **options, &block)
    end

    # Invoke a list type of prompt
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   editors = %w(emacs nano vim)
    #   prompt.invoke_select(EnumList, "Select editor: ", editors)
    #
    # @return [String]
    #
    # @api public
    def invoke_select(object, question, *args, &block)
      options = Utils.extract_options!(args)
      choices = if args.empty? && !block
                  possible = options.dup
                  options = {}
                  possible
                elsif args.size == 1 && args[0].is_a?(Hash)
                  Utils.extract_options!(args)
                else
                  args.flatten
                end

      list = object.new(self, **options)
      list.(question, choices, &block)
    end

    # Ask masked question
    #
    # @example
    #   propmt = TTY::Prompt.new
    #   prompt.mask("What is your secret?")
    #
    # @return [TTY::Prompt::MaskQuestion]
    #
    # @api public
    def mask(message = "", **options, &block)
      invoke_question(MaskQuestion, message, **options, &block)
    end

    # Ask a question with a list of options
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.select("What size?", %w(large medium small))
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.select("What size?") do |menu|
    #     menu.choice :large
    #     menu.choices %w(:medium :small)
    #   end
    #
    # @param [String] question
    #   the question to ask
    #
    # @param [Array[Object]] choices
    #   the choices to select from
    #
    # @api public
    def select(question, *args, &block)
      invoke_select(List, question, *args, &block)
    end

    # Ask a question with multiple attributes activated
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   choices = %w(Scorpion Jax Kitana Baraka Jade)
    #   prompt.multi_select("Choose your destiny?", choices)
    #
    # @param [String] question
    #   the question to ask
    #
    # @param [Array[Object]] choices
    #   the choices to select from
    #
    # @return [String]
    #
    # @api public
    def multi_select(question, *args, &block)
      invoke_select(MultiList, question, *args, &block)
    end

    # Ask a question with indexed list
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   editors = %w(emacs nano vim)
    #   prompt.enum_select(EnumList, "Select editor: ", editors)
    #
    # @param [String] question
    #   the question to ask
    #
    # @param [Array[Object]] choices
    #   the choices to select from
    #
    # @return [String]
    #
    # @api public
    def enum_select(question, *args, &block)
      invoke_select(EnumList, question, *args, &block)
    end

    # A shortcut method to ask the user positive question and return
    # true for "yes" reply, false for "no".
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.yes?("Are you human?")
    #   # => Are you human? (Y/n)
    #
    # @return [Boolean]
    #
    # @api public
    def yes?(message, **options, &block)
      opts = { default: true }.merge(options)
      question = ConfirmQuestion.new(self, **opts)
      question.call(message, &block)
    end

    # A shortcut method to ask the user negative question and return
    # true for "no" reply.
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.no?("Are you alien?") # => true
    #   # => Are you human? (y/N)
    #
    # @return [Boolean]
    #
    # @api public
    def no?(message, **options, &block)
      opts = { default: false }.merge(options)
      question = ConfirmQuestion.new(self, **opts)
      !question.call(message, &block)
    end

    # Expand available options
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   choices = [{
    #     key: "Y",
    #     name: "Overwrite",
    #     value: :yes
    #   }, {
    #     key: "n",
    #     name: "Skip",
    #     value: :no
    #   }]
    #   prompt.expand("Overwirte Gemfile?", choices)
    #
    # @return [Object]
    #   the user specified value
    #
    # @api public
    def expand(message, *args, &block)
      invoke_select(Expander, message, *args, &block)
    end

    # Ask a question with a range slider
    #
    # @example
    #   prompt = TTY::Prompt.new
    #   prompt.slider("What size?", min: 32, max: 54, step: 2)
    #   prompt.slider("What size?", [ 'xs', 's', 'm', 'l', 'xl' ])
    #
    # @param [String] question
    #   the question to ask
    #
    # @param [Array] choices
    #   the choices to display
    #
    # @return [String]
    #
    # @api public
    def slider(question, choices = nil, **options, &block)
      slider = Slider.new(self, **options)
      slider.call(question, choices, &block)
    end

    # Print statement out. If the supplied message ends with a space or
    # tab character, a new line will not be appended.
    #
    # @example
    #   say("Simple things.", color: :red)
    #
    # @param [String] message
    #
    # @return [String]
    #
    # @api public
    def say(message = "", **options)
      message = message.to_s
      return if message.empty?

      statement = Statement.new(self, **options)
      statement.call(message)
    end

    # Print statement(s) out in red green.
    #
    # @example
    #   prompt.ok "Are you sure?"
    #   prompt.ok "All is fine!", "This is fine too."
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def ok(*args, **options)
      opts = { color: :green }.merge(options)
      args.each { |message| say(message, **opts) }
    end

    # Print statement(s) out in yellow color.
    #
    # @example
    #   prompt.warn "This action can have dire consequences"
    #   prompt.warn "Carefull young apprentice", "This is potentially dangerous"
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def warn(*args, **options)
      opts = { color: :yellow }.merge(options)
      args.each { |message| say(message, **opts) }
    end

    # Print statement(s) out in red color.
    #
    # @example
    #   prompt.error "Shutting down all systems!"
    #   prompt.error "Nothing is fine!", "All is broken!"
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def error(*args, **options)
      opts = { color: :red }.merge(options)
      args.each { |message| say(message, **opts) }
    end

    # Print debug information in terminal top right corner
    #
    # @example
    #   prompt.debug "info1", "info2"
    #
    # @param [Array] messages
    #
    # @retrun [nil]
    #
    # @api public
    def debug(*messages)
      longest = messages.max_by(&:length).size
      width = TTY::Screen.width - longest
      print cursor.save
      messages.reverse_each do |msg|
        print cursor.column(width) + cursor.up + cursor.clear_line_after
        print msg
      end
    ensure
      print cursor.restore
    end

    # Takes the string provided by the user and compare it with other possible
    # matches to suggest an unambigous string
    #
    # @example
    #   prompt.suggest("sta", ["status", "stage", "commit", "branch"])
    #   # => "status, stage"
    #
    # @param [String] message
    #
    # @param [Array] possibilities
    #
    # @param [Hash] options
    # @option options [String] :indent
    #   The number of spaces for indentation
    # @option options [String] :single_text
    #   The text for a single suggestion
    # @option options [String] :plural_text
    #   The text for multiple suggestions
    #
    # @return [String]
    #
    # @api public
    def suggest(message, possibilities, **options)
      suggestion = Suggestion.new(**options)
      say(suggestion.suggest(message, possibilities))
    end

    # Gathers more than one aswer
    #
    # @example
    #   prompt.collect do
    #     key(:name).ask("Name?")
    #   end
    #
    # @return [Hash]
    #   the collection of answers
    #
    # @api public
    def collect(**options, &block)
      collector = AnswersCollector.new(self, **options)
      collector.call(&block)
    end

    # Check if outputing to terminal
    #
    # @return [Boolean]
    #
    # @api public
    def tty?
      stdout.tty?
    end

    # Return standard in
    #
    # @api private
    def stdin
      $stdin
    end

    # Return standard out
    #
    # @api private
    def stdout
      $stdout
    end

    # Return standard error
    #
    # @api private
    def stderr
      $stderr
    end

    # Inspect this instance public attributes
    #
    # @return [String]
    #
    # @api public
    def inspect
      attributes = [
        :prefix,
        :quiet,
        :enabled_color,
        :active_color,
        :error_color,
        :help_color,
        :input,
        :output,
      ]
      name = self.class.name
      "#<#{name}#{attributes.map { |attr| " #{attr}=#{send(attr).inspect}" }.join}>"
    end
  end # Prompt
end # TTY
