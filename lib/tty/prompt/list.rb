# encoding: utf-8

module TTY
  class Prompt
    # A class responsible for rendering select list menu
    # Used by {Prompt} to display interactive menu.
    #
    # @api private
    class List
      HELP = '(Use arrow keys, press Enter to select)'.freeze

      # Create instance of TTY::Prompt::List menu.
      #
      # @param Hash options
      #   the configuration options
      # @option options [Symbol] :default
      #   the default active choice, defaults to 1
      # @option options [Symbol] :color
      #   the color for the selected item, defualts to :green
      # @option options [Symbol] :marker
      #   the marker for the selected item
      #
      # @api public
      def initialize(prompt, options)
        @prompt = prompt
        @reader = Reader.new(@prompt)
        @pastel = Pastel.new
        @cursor = Cursor.new

        @first_render = true
        @selected     = false
        @active       = options.fetch(:default) { 1 }
        @choices      = Choices.new
        @color        = options.fetch(:color) { :green }
        @marker       = options.fetch(:marker) { Codes::ITEM_SELECTED }
        @help         = options.fetch(:help) { HELP }
      end

      # Set marker
      #
      # @api public
      def marker(value)
        @marker = value
      end

      # Set default option selected
      #
      # @api public
      def default(value)
        @active = value
      end

      # Add a single choice
      #
      # @api public
      def choice(*value, &block)
        if block
          @choices << (value << block)
        else
          @choices << value
        end
      end

      # Add multiple choices
      #
      # @param [Array[Object]] values
      #   the values to add as choices
      #
      # @api public
      def choices(values)
        values.each { |val| choice(*val) }
      end

      # Call the list menu by passing question and choices
      #
      # @param [String] question
      #
      # @param
      # @api public
      def call(question, possibilities, &block)
        choices(possibilities)
        @question = question
        block.call(self) if block
        render
      end

      private

      # Render a selection list.
      #
      # By default the result is printed out.
      #
      # @return [Object] value
      #   return the selected value
      #
      # @api private
      def render
        @prompt.output.print(@cursor.hide)
        until @selected
          render_question
          process_input
          refresh
        end
        render_question
        result = @choices[@active - 1].value
      ensure
        @prompt.output.print(@cursor.show)
        result
      end

      # Process keyboard input
      #
      # @api private
      def process_input
        chars = @reader.read_keypress
        case chars
        when Codes::SIGINT, Codes::ESCAPE
          exit 130
        when Codes::RETURN, Codes::SPACE
          @selected = true
        when Codes::KEY_UP, Codes::CTRL_K, Codes::CTRL_P
          @active = (@active == 1) ? @choices.length : @active - 1
        when Codes::KEY_DOWN, Codes::CTRL_J, Codes::CTRL_N
          @active = (@active == @choices.length) ? 1 : @active + 1
        end
      end

      # Determine area of the screen to clear
      #
      # @api private
      def refresh
        lines = @question.scan("\n").length + @choices.length + 1
        @prompt.output.print(@cursor.clear_lines(lines))
      end

      # Render actual question with menu
      #
      # @api private
      def render_question
        message = @question
        message += Codes::SPACE + @help if @first_render
        @prompt.output.puts(message)

        if @selected
          selected_item = "#{@choices[@active - 1].value}"
          colored = @pastel.decorate(selected_item, @color)
          @prompt.output.puts(colored)
        else
          render_menu
        end

        @first_render = false
      end

      # @api private
      def render_menu
        @choices.each_with_index do |choice, index|
          message = if index + 1 == @active
                      selected = @marker + Codes::SPACE + choice.name
                      @pastel.decorate("#{selected}", @color)
                    else
                      Codes::SPACE * 2 + choice.name
                    end
          @prompt.output.puts(message)
        end
      end
    end # List
  end # Prompt
end # TTY
