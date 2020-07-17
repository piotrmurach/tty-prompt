# frozen_string_literal: true

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering numeric input from range
    #
    # @api public
    class Slider
      HELP = "(Use %s arrow keys, press Enter to select)"

      FORMAT = ":slider %d"

      # Initailize a Slider
      #
      # @param [Prompt] prompt
      #   the prompt
      # @param [Hash] options
      #   the options to configure this slider
      # @option options [Integer] :min The minimum value
      # @option options [Integer] :max The maximum value
      # @option options [Integer] :step The step value
      # @option options [String] :format The display format
      #
      # @api public
      def initialize(prompt, **options)
        @prompt       = prompt
        @prefix       = options.fetch(:prefix) { @prompt.prefix }
        @min          = options.fetch(:min) { 0 }
        @max          = options.fetch(:max) { 10 }
        @step         = options.fetch(:step) { 1 }
        @default      = options[:default]
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color   = options.fetch(:help_color) { @prompt.help_color }
        @format       = options.fetch(:format) { FORMAT }
        @quiet        = options.fetch(:quiet) { @prompt.quiet }
        @help         = options[:help]
        @show_help    = options.fetch(:show_help) { :start }
        @symbols      = @prompt.symbols.merge(options.fetch(:symbols, {}))
        @first_render = true
        @done         = false
      end

      # Change symbols used by this prompt
      #
      # @param [Hash] new_symbols
      #   the new symbols to use
      #
      # @api public
      def symbols(new_symbols = (not_set = true))
        return @symbols if not_set

        @symbols.merge!(new_symbols)
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

      # Default help text
      #
      # @api public
      def default_help
        arrows = @symbols[:arrow_left] + "/" + @symbols[:arrow_right]
        sprintf(HELP, arrows)
      end

      # Set help text
      #
      # @param [String] text
      #
      # @api private
      def help(text = (not_set = true))
        return @help if !@help.nil? && not_set

        @help = (@help.nil? && not_set) ? default_help : text
      end

      # Change when help is displayed
      #
      # @api public
      def show_help(value = (not_set = true))
        return @show_ehlp if not_set

        @show_help = value
      end

      # Range of numbers to render
      #
      # @return [Array[Integer]]
      #
      # @api private
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

      def format(value)
        @format = value
      end

      # Set quiet mode.
      #
      # @api public
      def quiet(value)
        @quiet = value
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
        @prompt.subscribe(self) do
          render
        end
      end

      def keyleft(*)
        @active -= 1 if @active > 0
      end
      alias keydown keyleft

      def keyright(*)
        @active += 1 if (@active + 1) < range.size
      end
      alias keyup keyright

      def keyreturn(*)
        @done = true
      end
      alias keyspace keyreturn
      alias keyenter keyreturn

      private

      # Check if help is shown only on start
      #
      # @api private
      def help_start?
        @show_help =~ /start/i
      end

      # Check if help is always displayed
      #
      # @api private
      def help_always?
        @show_help =~ /always/i
      end

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
        @prompt.print(render_question) unless @quiet
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
        header = ["#{@prefix}#{@question} "]
        if @done
          header << @prompt.decorate(answer.to_s, @active_color)
          header << "\n"
        else
          header << render_slider
        end
        if @first_render && (help_start? || help_always?) ||
            (help_always? && !@done)
          header << "\n" + @prompt.decorate(help, @help_color)
          @first_render = false
        end
        header.join
      end

      # Render slider representation
      #
      # @return [String]
      #
      # @api private
      def render_slider
        slider = (@symbols[:line] * @active) +
                 @prompt.decorate(@symbols[:bullet], @active_color) +
                 (@symbols[:line] * (range.size - @active - 1))
        value = range[@active]
        case @format
        when Proc
          @format.call(slider, value)
        else
          @format.gsub(":slider", slider) % [value]
        end
      end
    end # Slider
  end # Prompt
end # TTY
