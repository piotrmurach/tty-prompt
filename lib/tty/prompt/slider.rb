# encoding: utf-8

require_relative 'symbols'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering numeric input from range
    #
    # @api public
    class Slider
      include Symbols

      HELP = '(Use arrow keys, press Enter to select)'.freeze

      # Initailize a Slider
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @prefix       = options.fetch(:prefix) { @prompt.prefix }
        @min          = options.fetch(:min) { 0 }
        @max          = options.fetch(:max) { 10 }
        @step         = options.fetch(:step) { 1 }
        @default      = options[:default]
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color   = options.fetch(:help_color) { @prompt.help_color }
        @first_render = true
        @done         = false

        @prompt.subscribe(self)
      end

      # Setup initial active position
      #
      # @return [Integer]
      #
      # @api private
      def initial
        if @default.nil?
          range.size / 2
        else
          range.index(@default)
        end
      end

      # Range of numbers to render
      #
      # @return [Array[Integer]]
      #
      # @apip private
      def range
        (@min..@max).step(@step).to_a
      end

      # @api public
      def default(value)
        @default = value
      end

      # @api public
      def min(value)
        @min = value
      end

      # @api public
      def max(value)
        @max = value
      end

      # @api public
      def step(value)
        @step = value
      end

      # Call the slider by passing question
      #
      # @param [String] question
      #   the question to ask
      #
      # @apu public
      def call(question, &block)
        @question = question
        block.call(self) if block
        @active = initial
        render
      end

      def keyleft(*)
        @active -= 1 if @active > 0
      end
      alias_method :keydown, :keyleft

      def keyright(*)
        @active += 1 if (@active + @step) < range.size
      end
      alias_method :keyup, :keyright

      def keyreturn(*)
        @done = true
      end
      alias_method :keyspace, :keyreturn

      private

      # Render an interactive range slider.
      #
      # @api private
      def render
        @prompt.print(@prompt.hide)
        until @done
          question = render_question
          @prompt.print(question)
          @prompt.read_keypress
          refresh(question.lines.count)
        end
        @prompt.print(render_question)
        answer
      ensure
        @prompt.print(@prompt.show)
      end

      # Clear screen
      #
      # @param [Integer] lines
      #   the lines to clear
      #
      # @api private
      def refresh(lines)
        @prompt.print(@prompt.clear_lines(lines))
      end

      # @return [Integer]
      #
      # @api private
      def answer
        range[@active]
      end

      # Render question with the slider
      #
      # @return [String]
      #
      # @api private
      def render_question
        header = "#{@prefix}#{@question} #{render_header}\n"
        @first_render = false
        header << render_slider unless @done
        header
      end

      # Render actual answer or help
      #
      # @return [String]
      #
      # @api private
      def render_header
        if @done
          @prompt.decorate(answer.to_s, @active_color)
        elsif @first_render
          @prompt.decorate(HELP, @help_color)
        end
      end

      # Render slider representation
      #
      # @return [String]
      #
      # @api private
      def render_slider
        output = ''
        output << symbols[:pipe]
        output << symbols[:line] * @active
        output << @prompt.decorate(symbols[:handle], @active_color)
        output << symbols[:line] * (range.size - @active - 1)
        output << symbols[:pipe]
        output << " #{range[@active]}"
        output
      end
    end # Slider
  end # Prompt
end # TTY
