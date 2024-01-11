# frozen_string_literal: true

module TTY
  class Prompt
    # @api private
    class OrderedSelectedChoices
      include Enumerable

      attr_reader :size

      # Create ordered selected choices
      #
      # @param [Array<Choice>] selected
      # @param [Array<Integer>] indexes (ignored)
      #
      # @api public
      def initialize(selected = [], _indexes = [])
        @selected = selected
        @size = @selected.size
      end

      # Clear ordered selected choices
      #
      # @api public
      def clear
        @selected.clear
        @size = 0
      end

      # Iterate over ordered selected choices
      #
      # @api public
      def each(&block)
        return to_enum unless block_given?

        @selected.each(&block)
      end

      # Insert choice at the end
      #
      # @param [Integer] index (ignored)
      # @param [Choice] choice
      #
      # @api public
      def insert(_index, choice)
        @selected << choice
        @size += 1
        self
      end

      # Delete choice at index
      #
      # @return [Choice]
      #   the deleted choice
      #
      # @api public
      def delete_at(index)
        return nil if index < 0
        return nil if index >= @size

        choice = @selected.delete_at(index)
        @size -= 1
        choice
      end

      def find_index_by(&search)
        (0...@size).bsearch(&search)
      end
    end # OrderedSelectedChoices
  end # Prompt
end # TTY
