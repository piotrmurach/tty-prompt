# encoding: utf-8

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering numeric input from range
    #
    # @api public
    class Slider
      HELP = '(Use arrow keys, press Enter to select)'.freeze

      # Initailize a Slider
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @first_render = true
        @done         = false
        @color        = options.fetch(:color) { :green }
        @min          = options.fetch(:min) { 0 }
        @max          = options.fetch(:max) { 10 }
        @step         = options.fetch(:step) { 1 }
        @default      = options[:default]

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
        @active += 1 if (@active + @step) <= range.size
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
          render_question
          @prompt.read_keypress
          refresh
        end
        render_question
        answer = render_answer
      ensure
        @prompt.print(@prompt.show)
        answer
      end

      # Clear screen
      #
      # @api private
      def refresh
        lines = @question.scan("\n").length + 2
        @prompt.print(@prompt.clear_lines(lines))
      end

      # @return [Integer]
      #
      # @api private
      def render_answer
        range[@active]
      end

      # Render question with the slider
      #
      # @api private
      def render_question
        header = "#{@prompt.prefix}#{@question} #{render_header}"
        @prompt.puts(header)
        @first_render = false
        @prompt.print(render_slider) unless @done
      end

      # Render actual answer or help
      #
      # @api private
      def render_header
        if @done
          @prompt.decorate(render_answer.to_s, @color)
        elsif @first_render
          @prompt.decorate(HELP, :bright_black)
        end
      end

      # Render slider representation
      #
      # @return [String]
      #
      # @api private
      def render_slider
        output = ''
        output << Symbols::SLIDER_END
        output << '-' * @active
        output << @prompt.decorate(Symbols::SLIDER_HANDLE, @color)
        output << '-' * (range.size - @active - 1)
        output << Symbols::SLIDER_END
        output << " #{range[@active]}"
        output
      end
    end # Slider
  end # Prompt
end # TTY
