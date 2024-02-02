# frozen_string_literal: true

require 'algorithms'

module TTY
  class Prompt
    # A prompt responsible for inputting commands with help text
    #
    # @api private
    class CommandList
      # Create instance of CommandList
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt = prompt
        @commands = Containers::Trie.new()
        @current_displayed_commands = []
        @done = false
        @max_command_len = 0
        @current_command = ''

        @num_commands_shown  = options.fetch(:num_commands_shown, 5)
        @prefix             = options.fetch(:prefix) { @prompt.prefix }
        @help_color         = options.fetch(:help_color) { @prompt.help_color }
        @quiet              = options.fetch(:quiet) { @prompt.quiet }
      end

      # Add a command to the list
      #
      # @api public
      def command(name, arguments)
        if name.length > @max_command_len
          @max_command_len = name.length
        end
        @commands.push(name, arguments)
      end

      # Add multiple commands to the list
      #
      # @api public
      def commands(commands)
        commands.each do |command, arguments|
          command(command, arguments)
        end
      end

      # Set quiet mode.
      #
      # @api public
      def quiet(value)
        @quiet = value
      end

      # Set number of commands shown.
      #
      # @api public
      def num_commands_shown(value)
        @num_commands_shown = value
      end

      # Execute this prompt
      #
      # @api public
      def call(message, commands, &block)
        commands(commands)
        @message = message
        block.call(self) if block
        @prompt.subscribe(self) do
          render
        end
        @prompt.reader.add_to_history(@current_command)
        @current_command
      end

      # Respond to submit event
      #
      # @api public
      def keyenter(*)
        @done = true
      end
      alias keyreturn keyenter

      # Respond to key press event
      #
      # @api public
      def keypress(event)
        return unless event.key.name == :alpha || event.key.name == :space || event.key.name == :num || event.key.name == :ignore
        @current_command += event.value
      end

      # Respond to key backspace event
      #
      # @api public
      def keybackspace(*)
        @current_command = @current_command.chop
      end

      # Respond to key tab event
      def keytab(*)
        @current_command = @current_displayed_commands.first if @current_displayed_commands.size > 0
      end

      # Respond to key up event
      def keyup(*)
        @current_command = @prompt.reader.history_previous if @prompt.reader.history_previous?
      end

      # Respond to key down event
      def keydown(*)
        if @prompt.reader.history_next?
          @current_command = @prompt.reader.history_next
        else
          @current_command = ''
        end
      end

      private

      # @api private
      def render
        until @done
          @prompt.print(render_header)
          commands = render_commands
          if commands && !@quiet
            @prompt.print("\n" + commands)
          end
          @prompt.read_keypress
          @prompt.print(refresh)
        end

        @prompt.print(@prompt.clear_line + render_header + "\n")
      end

      # Render the header
      #
      # @return [String]
      #
      # @api private
      def render_header
        @prefix + @message + @current_command
      end

      # Render the commands
      #
      # @return [nil, String]
      #
      # @api private
      def render_commands
        command_wildcard = @current_command + ('*' * [@max_command_len - @current_command.size, 0].max)[0..@max_command_len]
        possible_commands = @commands.wildcard(command_wildcard) || []
        @current_displayed_commands = possible_commands[0...@num_commands_shown]
        command_render = if @current_displayed_commands.empty?
          return nil
        else
          commands_and_args = ""
          @current_displayed_commands.each do |command|
            args = @commands[command]
            commands_and_args += "#{command} #{args.join(" ")}\n"
          end
          commands_and_args
        end
        @prompt.decorate(command_render +
            @prompt.cursor.up(@current_displayed_commands.size + 1) +
            @prompt.cursor.column(0) +
            @prompt.cursor.forward(render_header.size),
          @help_color)
      end

      # Refresh the current input
      #
      # @return [String]
      #
      # @api private
      def refresh
        clear = unless @current_displayed_commands.empty?
          @prompt.clear_lines(@current_displayed_commands.size + 1, :down) +
            @prompt.cursor.up(@current_displayed_commands.size)
        end
        (clear || "") + @prompt.clear_line
      end
    end
  end
end
