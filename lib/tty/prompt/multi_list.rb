# encoding: utf-8

require 'tty/prompt/list'

module TTY
  class Prompt
    # A class responsible for rendering multi select list menu.
    # Used by {Prompt} to display interactive choice menu.
    #
    # @api private
    class MultiList < List
      HELP = '(Use arrow%s keys, press Space to select and Enter to finish)'.freeze

      # Create instance of TTY::Prompt::MultiList menu.
      #
      # @param [Prompt] :prompt
      # @param [Hash] options
      #
      # @api public
      def initialize(prompt, options)
        super
        @selected = []
        @help    = options[:help]
        @default = Array(options[:default])
      end

      # Callback fired when space key is pressed
      #
      # @api private
      def keyspace(*)
        active_choice = @choices[@active - 1]
        if @selected.include?(active_choice)
          @selected.delete(active_choice)
        else
          @selected << active_choice
        end
      end

      private

      # Setup default options and active selection
      #
      # @api private
      def setup_defaults
        validate_defaults
        @selected = @choices.values_at(*@default.map { |d| d - 1 })
        @active = @default.last unless @selected.empty?
      end

      # Generate selected items names
      #
      # @return [String]
      #
      # @api private
      def selected_names
        @selected.map(&:name).join(', ')
      end

      # Render initial help text and then currently selected choices
      #
      # @api private
      def render_header
        instructions = @prompt.decorate(help, :bright_black)
        if @done
          @prompt.decorate(selected_names, @active_color)
        elsif @selected.size.nonzero?
          selected_names + (@first_render ? " #{instructions}" : '')
        elsif @first_render
          instructions
        end
      end

      # All values for the choices selected
      #
      # @return [Array[nil,Object]]
      #
      # @api private
      def render_answer
        @selected.map(&:value)
      end

      # Render menu with choices to select from
      #
      # @api private
      def render_menu
        output = ''
        @paginator.paginate(@choices, @active) do |choice, index|
          num = enumerate? ? (index + 1).to_s + @enum + Symbols::SPACE : ''
          indicator = (index + 1 == @active) ?  @marker : Symbols::SPACE
          indicator += Symbols::SPACE
          message = if @selected.include?(choice)
                      selected = @prompt.decorate(Symbols::RADIO_CHECKED, @active_color)
                      selected + Symbols::SPACE + num + choice.name
                    else
                      Symbols::RADIO_UNCHECKED + Symbols::SPACE + num + choice.name
                    end
          newline = (index == @paginator.max_index) ? '' : "\n"
          output << indicator + message + newline
        end
        output
      end
    end # MultiList
  end # Prompt
end # TTY
