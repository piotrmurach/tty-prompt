# encoding: utf-8

module TTY
  class Prompt
    # A class responsible for rendering select list menu
    # Used by {Prompt} to display interactive menu.
    #
    # @api private
    class List
      HELP = '(Use arrow%s keys, press Enter to select)'.freeze

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
      # @option options [String] :enum
      #   the delimiter for the item index
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @first_render = true
        @done         = false
        @enum         = options.fetch(:enum) { nil }
        @default      = Array[options.fetch(:default) { 1 }]
        @active       = @default.first
        @choices      = Choices.new
        @color        = options.fetch(:color) { :green }
        @marker       = options.fetch(:marker) { Symbols::ITEM_SELECTED }
        @help         = options[:help]

        @prompt.subscribe(self)
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
      def default(*default_values)
        @default = default_values
      end

      # Set selecting active index using number pad
      #
      # @api public
      def enum(value)
        @enum = value
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
        setup_defaults
        render
      end

      # Check if list is enumerated
      #
      # @return [Boolean]
      def enumerate?
        !@enum.nil?
      end

      def keynum(event)
        return unless enumerate?
        value = event.value.to_i
        return unless (1..@choices.count).include?(value)
        @active = value
      end

      def keyescape(event)
        exit 130
      end

      def keyspace(event)
        @done = true
      end

      def keyreturn(event)
        @done = true
      end

      def keyup(event)
        @active = (@active == 1) ? @choices.length : @active - 1
      end

      def keydown(event)
        @active = (@active == @choices.length) ? 1 : @active + 1
      end

      private

      # Setup default option and active selection
      #
      # @api private
      def setup_defaults
        validate_defaults
        @active = @default.first
      end

      # Validate default indexes to be within range
      #
      # @api private
      def validate_defaults
        @default.each do |d|
          if d < 1 || d > @choices.size
            fail PromptConfigurationError,
                 "default index `#{d}` out of range (1 - #{@choices.size})"
          end
        end
      end

      # Render a selection list.
      #
      # By default the result is printed out.
      #
      # @return [Object] value
      #   return the selected value
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

      # Find value for the choice selected
      #
      # @return [nil, Object]
      #
      # @api private
      def render_answer
        @choices[@active - 1].value
      end

      # Determine area of the screen to clear
      #
      # @api private
      def refresh
        lines = @question.scan("\n").length + @choices.length + 1
        @prompt.print(@prompt.clear_lines(lines))
      end

      # Render question with instructions and menu
      #
      # @api private
      def render_question
        header = "#{@prompt.prefix}#{@question} #{render_header}"
        @prompt.puts(header)
        @first_render = false
        render_menu unless @done
      end

      # Provide help information
      #
      # @return [String]
      def help
        return @help if !@help.nil?
        self.class::HELP % [enumerate? ? ' or number (0-9)' : '']
      end

      # Render initial help and selected choice
      #
      # @return [String]
      #
      # @api private
      def render_header
        if @done
          selected_item = "#{@choices[@active - 1].name}"
          @prompt.decorate(selected_item, @color)
        elsif @first_render
          @prompt.decorate(help, :bright_black)
        else
          ''
        end
      end

      # Render menu with choices to select from
      #
      # @api private
      def render_menu
        @choices.each_with_index do |choice, index|
          num = enumerate? ? (index + 1).to_s + @enum + Symbols::SPACE : ''
          message = if index + 1 == @active
                      selected = @marker + Symbols::SPACE + num + choice.name
                      @prompt.decorate("#{selected}", @color)
                    else
                      Symbols::SPACE * 2 + num + choice.name
                    end
          newline = (index == @choices.length - 1) ? '' : "\n"
          @prompt.print(message + newline)
        end
      end
    end # List
  end # Prompt
end # TTY
