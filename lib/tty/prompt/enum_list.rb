# encoding: utf-8

require_relative 'choices'
require_relative 'enum_paginator'
require_relative 'paginator'

module TTY
  class Prompt
    # A class reponsible for rendering enumerated list menu.
    # Used by {Prompt} to display static choice menu.
    #
    # @api private
    class EnumList
      PAGE_HELP = '(Press tab/right or left to reveal more choices)'.freeze

      # Create instance of EnumList menu.
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt       = prompt
        @prefix       = options.fetch(:prefix) { @prompt.prefix }
        @enum         = options.fetch(:enum) { ')' }
        @default      = options.fetch(:default) { 1 }
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color   = options.fetch(:help_color)   { @prompt.help_color }
        @error_color  = options.fetch(:error_color)  { @prompt.error_color }
        @input        = nil
        @done         = false
        @first_render = true
        @failure      = false
        @active       = @default
        @choices      = Choices.new
        @per_page     = options[:per_page]
        @page_help    = options[:page_help] || PAGE_HELP
        @paginator    = EnumPaginator.new
        @page_active  = @default

        @prompt.subscribe(self)
      end

      # Set default option selected
      #
      # @api public
      def default(default)
        @default = default
      end

      # Set number of items per page
      #
      # @api public
      def per_page(value)
        @per_page = value
      end

      def page_size
        (@per_page || Paginator::DEFAULT_PAGE_SIZE)
      end

      # Check if list is paginated
      #
      # @return [Boolean]
      #
      # @api private
      def paginated?
        @choices.size > page_size
      end

      # @param [String] text
      #   the help text to display per page
      # @api pbulic
      def page_help(text)
        @page_help = text
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
        block[self] if block
        setup_defaults
        render
      end

      def keypress(event)
        if [:backspace, :delete].include?(event.key.name)
          return if @input.empty?
          @input.chop!
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
      alias keyenter keyreturn

      def keyright(*)
        if (@page_active + page_size) <= @choices.size
          @page_active += page_size
        else
          @page_active = 1
        end
      end
      alias keytab keyright

      def keyleft(*)
        if (@page_active - page_size) >= 0
          @page_active -= page_size
        else
          @page_active = @choices.size - 1
        end
      end

      private

      # Find active choice or set to default
      #
      # @return [nil]
      #
      # @api private
      def mark_choice_as_active
        if (@input.to_i > 0) && !@choices[@input.to_i - 1].nil?
          @active = @input.to_i
        else
          @active = @default
        end
        @page_active = @active
      end

      # Validate default indexes to be within range
      #
      # @api private
      def validate_defaults
        return if @default >= 1 && @default <= @choices.size
        raise PromptConfigurationError,
              "default index `#{d}` out of range (1 - #{@choices.size})"
      end

      # Setup default option and active selection
      #
      # @api private
      def setup_defaults
        validate_defaults
        mark_choice_as_active
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
          question = render_question
          @prompt.print(question)
          @prompt.print(render_error) if @failure
          if paginated? && !@done
            @prompt.print(render_page_help)
          end
          @prompt.read_keypress
          @prompt.print(refresh(question.lines.count))
        end
        @prompt.print(render_question)
        answer
      end

      # Find value for the choice selected
      #
      # @return [nil, Object]
      #
      # @api private
      def answer
        @choices[@active - 1].value
      end

      # Determine area of the screen to clear
      #
      # @param [Integer] lines
      #   the lines to clear
      #
      # @return [String]
      #
      # @api private
      def refresh(lines)
        @prompt.clear_lines(lines) +
          @prompt.cursor.clear_screen_down
      end

      # Render question with the menu options
      #
      # @return [String]
      #
      # @api private
      def render_question
        header = "#{@prefix}#{@question} #{render_header}\n"
        unless @done
          header << render_menu
          header << render_footer
        end
        header
      end

      # Error message when incorrect index chosen
      #
      # @api private
      def error_message
        error = 'Please enter a valid number'
        "\n" + @prompt.decorate('>>', @error_color) + ' ' + error
      end

      # Render error message and return cursor to position of input
      #
      # @return [String]
      #
      # @api private
      def render_error
        error = error_message.dup
        if !paginated?
          error << @prompt.cursor.prev_line
          error << @prompt.cursor.forward(render_footer.size)
        end
        error
      end

      # Render chosen option
      #
      # @return [String]
      #
      # @api private
      def render_header
        return '' unless @done
        return '' unless @active
        selected_item = @choices[@active - 1].name.to_s
        @prompt.decorate(selected_item, @active_color)
      end

      # Render footer for the indexed menu
      #
      # @return [String]
      #
      # @api private
      def render_footer
        "  Choose 1-#{@choices.size} [#{@default}]: #{@input}"
      end

      # Pagination help message
      #
      # @return [String]
      #
      # @api private
      def page_help_message
        return '' unless paginated?
        "\n" + @prompt.decorate(@page_help, @help_color)
      end

      # Render page help
      #
      # @return [String]
      #
      # @api private
      def render_page_help
        help = page_help_message.dup
        if @failure
          help << @prompt.cursor.prev_line
        end
        help << @prompt.cursor.prev_line
        help << @prompt.cursor.forward(render_footer.size)
      end

      # Render menu with indexed choices to select from
      #
      # @return [String]
      #
      # @api private
      def render_menu
        output = ''
        @paginator.paginate(@choices, @page_active, @per_page) do |choice, index|
          num = (index + 1).to_s + @enum + ' '
          selected = ' ' * 2 + num + choice.name
          output << if index + 1 == @active
                      @prompt.decorate(selected.to_s, @active_color)
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
