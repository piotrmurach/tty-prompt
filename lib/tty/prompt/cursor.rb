# encoding: utf-8

module TTY
  class Prompt
    class Cursor
      ECMA_CSI = "\e[".freeze
      DEC_RST  = 'l'.freeze
      DEC_SET  = 'h'.freeze
      DEC_TCEM = '?25'.freeze
      ECMA_CLR = 'K'.freeze

      attr_reader :shell

      def initialize(stream = nil, options = {})
        @stream = stream || $stdout
        @shell  = options.fetch(:shell, false)
        @hidden = options.fetch(:hidden, false)
      end

      def print
        self.class.new(@stream, shell: true)
      end

      def show
        @hidden = false
        ECMA_CSI + DEC_TCEM + DEC_SET
      end

      def hide
        show if @hidden
        @hidden = true
        ECMA_CSI + DEC_TCEM + DEC_RST
      end

      # Switch off cursor for the block
      # @api public
      def invisible
        hide
        yield
      ensure
        show
      end

      # Save current position
      # @api public
      def save
        ECMA_CSI + "s"
      end

      # Restore cursor position
      # @api public
      def restore
        ECMA_CSI + "u"
      end

      def current
        ECMA_CSI + "6n"
      end

      # Move cursor relative to its current position
      # @api public
      def move(x, y)
      end

      # Move cursor up by number of lines
      #
      # @param [Integer] count
      #
      # @api public
      def move_up(count = nil)
        ECMA_CSI + "#{(count || 1)}A"
      end

      def move_down(count = nil)
        ECMA_CSI + "#{(count || 1)}B"
      end

      # Move to start of the line
      #
      # @api public
      def move_start
        ECMA_CSI + '1000D'
      end

      # @param [Integer] count
      #   how far to go left
      # @api public
      def move_left(count = nil)
        ECMA_CSI + "#{count || 1}D"
      end

      # @api public
      def move_right(count = nil)
        ECMA_CSI + "#{count || 1}C"
      end

      def next_line
        ECMA_CSI + 'E'
      end

      def prev_line
        ECMA_CSI + 'F'
      end

      # @api public
      def clear_line
        move_start + ECMA_CSI + ECMA_CLR
      end

      # @api public
      def clear_lines(amount, direction = :up)
        amount.times.reduce("") do |acc|
          dir = direction == :up ? move_up : move_down
          acc << dir + clear_line
        end
      end

      # Clear screen down from current position
      # @api public
      def clear_down
        ECMA_CSI + "J"
      end

      # Clear screen up from current position
      # @api public
      def clear_up
        ECMA_CSI + "1J"
      end
    end # Cursor
  end # Prompt
end # TTY
