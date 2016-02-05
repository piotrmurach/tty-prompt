# encoding: utf-8

module TTY
  class Prompt
    # A class reponsible for rendering enumerated list menu.
    # Used by {Prompt} to display static choice menu.
    #
    # @api private
    class EnumList
      # Create instance of EnumList menu.
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt  = prompt
        @done    = false
        @failure = false
        @enum    = options.fetch(:enum) { ')' }
        @default = options.fetch(:default) { 1 }
        @active  = @default
        @choices = Choices.new
        @color   = options.fetch(:color) { :green }

        @prompt.subscribe(self)
      end

      # Set default option selected
      #
      # @api public
      def default(default)
        @default = default
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

      def keypress(event)
        if [:backspace, :delete].include?(event.key.name)
          @input.chop! unless @input.empty?
          mark_choice_as_active
        elsif event.value =~ /^\d+$/
          @input += event.value
          mark_choice_as_active
        end
      end

      def keyreturn(*)
        @failure = false
        if (@input.to_i > 0 && @input.to_i <= @choices.size) || @input.empty?
          @done = true
        else
          @input = ''
          @failure = true
        end
      end
      alias_method :keyenter, :keyreturn

      private

      def mark_choice_as_active
        if !@choices[@input.to_i - 1].nil?
          @active = @input.to_i
        else
          @active = nil
        end
      end

      # Setup default option and active selection
      #
      # @api private
      def setup_defaults
        validate_defaults
        @active = @default
      end

      # Validate default indexes to be within range
      #
      # @api private
      def validate_defaults
        return if @default >= 1 && @default <= @choices.size
        fail PromptConfigurationError,
             "default index `#{d}` out of range (1 - #{@choices.size})"
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
        @input = ''
        until @done
          render_question
          @prompt.read_keypress
          refresh
        end
        render_question
        render_answer
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
        lines = @question.scan("\n").length + @choices.length + 2
        @prompt.print(@prompt.clear_lines(lines))
        @prompt.print(@prompt.cursor.clear_screen_down)
      end

      # Render question with the menu options
      #
      # @api private
      def render_question
        header = "#{@prompt.prefix}#{@question} #{render_header}"
        @prompt.puts(header)
        return if @done
        @prompt.print(render_menu)
        @prompt.print(render_footer)
        render_error if @failure
      end

      # @api private
      def render_error
        error = 'Please enter a valid index'
        @prompt.print("\n" + @prompt.decorate('>>', :red) + ' ' + error)
        @prompt.print(@prompt.cursor.prev_line)
        @prompt.print(@prompt.cursor.forward(render_footer.size))
      end

      # Render chosen option
      #
      # @return [String]
      #
      # @api private
      def render_header
        return '' unless @done
        return '' unless @active
        selected_item = "#{@choices[@active - 1].name}"
        @prompt.decorate(selected_item, @color)
      end

      # Render footer for the indexed menu
      #
      # @return [String]
      #
      # @api private
      def render_footer
        "  Choose 1-#{@choices.size} [#{@default}]: #{@input}"
      end

      # Render menu with indexed choices to select from
      #
      # @return [String]
      #
      # @api private
      def render_menu
        output = ''
        @choices.each_with_index do |choice, index|
          num = (index + 1).to_s + @enum + Symbols::SPACE
          selected = Symbols::SPACE * 2 + num + choice.name
          output << if index + 1 == @active
                      @prompt.decorate("#{selected}", @color)
                    else
                      selected
                    end
          output << "\n"
        end
        output
      end
    end # EnumList
  end # Prompt
end # TTY
