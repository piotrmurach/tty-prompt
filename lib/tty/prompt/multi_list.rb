# encdoing: utf

require 'tty/prompt/list'

module TTY
  class Prompt
    # A class responsible for rendering multi select list menu.
    # Used by {Prompt} to display interactive choice menu.
    #
    # @api private
    class MultiList < List

      HELP = '(Use arrow keys, press Space to select and Enter to finish)'.freeze

      # Create instance of TTY::Prompt::MultiList menu.
      #
      # @api public
      def initialize(prompt, options)
        super
        @selected = []
        @help     = options.fetch(:help) { HELP }
      end

      def process_input
        chars = @reader.read_keypress
        case chars
        when Codes::SIGINT, Codes::ESCAPE
          exit 130
        when Codes::RETURN
          @done = true
        when Codes::KEY_UP, Codes::CTRL_K, Codes::CTRL_P
          @active = (@active == 1) ? @choices.length : @active - 1
        when Codes::KEY_DOWN, Codes::CTRL_J, Codes::CTRL_N
          @active = (@active == @choices.length) ? 1 : @active + 1
        when Codes::SPACE
          active_choice = @choices[@active - 1]
          if @selected.include?(active_choice)
            @selected.delete(active_choice)
          else
            @selected << active_choice
          end
        end
      end

      # Render question with instructions
      #
      # @api private
      def render_question
        header = @question + Codes::SPACE + render_header
        @prompt.output.puts(header)
        @first_render = false
        render_menu unless @done
      end

      # @api private
      def render_header
        if @done
          @pastel.decorate(@selected.map(&:name).join(', '), :green)
        elsif @selected.size.nonzero?
          @selected.map(&:name).join(', ')
        elsif @first_render
          @pastel.decorate(@help, :bright_white)
        else
          ''
        end
      end

      # @api private
      def render_answer
        @selected.map(&:value)
      end

      # Render menu with choices to select from
      #
      # @api private
      def render_menu
        @choices.each_with_index do |choice, index|
          indicator = (index + 1 == @active) ?  @marker : Codes::SPACE
          indicator += Codes::SPACE
          message = if @selected.include?(choice)
                      selected = @pastel.decorate(Codes::RADIO_CHECKED, :green)
                      selected + Codes::SPACE + choice.name
                    else
                      Codes::RADIO_UNCHECKED + Codes::SPACE + choice.name
                    end
          @prompt.output.puts(indicator + message)
        end
      end
    end # MultiList
  end # Prompt
end # TTY
