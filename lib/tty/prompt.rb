# encoding: utf-8

module TTY
  class Prompt
    # Raised when the passed in validation argument is of wrong type
    class ValidationCoercion < TypeError; end

    # Raised when the required argument is not supplied
    class ArgumentRequired < ArgumentError; end

    # Raised when the argument validation fails
    class ArgumentValidation < ArgumentError; end

    # Raised when the argument is not expected
    class InvalidArgument < ArgumentError; end

    # @api private
    attr_reader :input

    # @api private
    attr_reader :output

    # Prompt prefix
    #
    # @api private
    attr_reader :prefix

    # Initialize a Prompt
    #
    # @api public
    def initialize(*args)
      options = Utils.extract_options!(args)
      @input  = options.fetch(:input) { $stdin }
      @output = options.fetch(:output) { $stdout }
      @prefix = options.fetch(:prefix) { '' }
    end

    # Ask a question.
    #
    # @example
    #   shell = TTY::Prompt.new
    #   shell.ask("What is your name?")
    #
    # @param [String] statement
    #   string question to be asked
    #
    # @yieldparam [TTY::Question] question
    #   further configure the question
    #
    # @yield [question]
    #
    # @return [TTY::Question]
    #
    # @api public
    def ask(message, *args, &block)
      options = Utils.extract_options!(args)

      question = Question.new(self, options)
      question.call(message, &block)
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
      options = Utils.extract_options!(args)
      choices = if block
                  []
                elsif args.empty?
                  options
                else
                  args.flatten
                end

      list = List.new(self, options)
      list.call(question, choices, &block)
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
      options = Utils.extract_options!(args)
      choices = if block
                  []
                elsif args.empty?
                  options
                else
                  args.flatten
                end

      list = MultiList.new(self, options)
      list.call(question, choices, &block)
    end

    # A shortcut method to ask the user positive question and return
    # true for 'yes' reply, false for 'no'.
    #
    # @return [Boolean]
    #
    # @api public
    def yes?(statement, *args, &block)
      ask(statement, {read: :bool}, &block)
    end

    # A shortcut method to ask the user negative question and return
    # true for 'no' reply.
    #
    # @return [Boolean]
    #
    # @api public
    def no?(statement, *args, &block)
      !yes?(statement, *args, &block)
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
    def say(message = '', options = {})
      message = message.to_s
      return unless message.length > 0

      statement = Statement.new(self, options)
      statement.call(message)
    end

    # Print statement(s) out in red green.
    #
    # @example
    #   shell.confirm "Are you sure?"
    #   shell.confirm "All is fine!", "This is fine too."
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def confirm(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :green) }
    end

    # Print statement(s) out in yellow color.
    #
    # @example
    #   shell.warn "This action can have dire consequences"
    #   shell.warn "Carefull young apprentice", "This is potentially dangerous"
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def warn(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :yellow) }
    end

    # Print statement(s) out in red color.
    #
    # @example
    #   shell.error "Shutting down all systems!"
    #   shell.error "Nothing is fine!", "All is broken!"
    #
    # @param [Array] messages
    #
    # @return [Array] messages
    #
    # @api public
    def error(*args)
      options = Utils.extract_options!(args)
      args.each { |message| say message, options.merge(color: :red) }
    end

    # Takes the string provided by the user and compare it with other possible
    # matches to suggest an unambigous string
    #
    # @example
    #   shell.suggest('sta', ['status', 'stage', 'commit', 'branch'])
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
    def suggest(message, possibilities, options = {})
      suggestion = Suggestion.new(options)
      say(suggestion.suggest(message, possibilities))
    end

    # Check if outputing to shell
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
  end # Prompt
end # TTY
