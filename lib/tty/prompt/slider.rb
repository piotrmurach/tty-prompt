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

        @range = (@min..@max).step(@step).to_a
        if @default.nil?
          @active = @range.size / 2
        else
          @active = @range.index(@default)
        end

        @prompt.subscribe(self)
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
        render
      end

      def keyleft(*)
        @active -= 1 if @active > 0
      end
      alias_method :keydown, :keyleft

      def keyright(*)
        @active += 1 if @active < @range.size
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

      def render_answer
        @range[@active]
      end

      def render_question
        header = "#{@prompt.prefix}#{@question} #{render_header}"
        @prompt.puts(header)
        @first_render = false
        render_slider unless @done
      end

      def render_header
        if @done
          @prompt.decorate(@range[@active].to_s, @color)
        elsif @first_render
          @prompt.decorate(HELP, :bright_black)
        else
          ''
        end
      end

      def render_slider
        slider = ''
        slider << Symbols::SLIDER_END
        slider << '-' * @active
        slider << @prompt.decorate(Symbols::SLIDER_HANDLE, @color)
        slider << '-' * (@range.size - @active - 1)
        slider << Symbols::SLIDER_END
        slider << " #{@range[@active]}"
        @prompt.print(slider)
      end

      def refresh
        lines = @question.scan("\n").length + 2
        @prompt.print(@prompt.clear_lines(lines))
      end
    end # Slider
  end # Prompt
end # TTY
