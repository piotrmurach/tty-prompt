# frozen_string_literal: true

module TTY
  class Prompt
    # @api private
    class SelectedChoices
      include Enumerable

      attr_reader :size

      # Create selected choices
      #
      # @param [Array<Choice>] selected
      # @param [Array<Integer>] indexes
      #
      # @api public
      def initialize(selected = [], indexes = [])
        @selected = selected
        @indexes = indexes
        @size = @selected.size
      end

      # Clear selected choices
      #
      # @api public
      def clear
        @indexes.clear
        @selected.clear
        @size = 0
      end

      # Iterate over selected choices
      #
      # @api public
      def each(&block)
        return to_enum unless block_given?

        @selected.each(&block)
      end

      # Insert choice at index
      #
      # @param [Integer] index
      # @param [Choice] choice
      #
      # @api public
      def insert(index, choice)
        insert_idx = find_index_by { |i| index < @indexes[i] }
        insert_idx ||= -1
        @indexes.insert(insert_idx, index)
        @selected.insert(insert_idx, choice)
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
        delete_idx = @indexes.each_index.find { |i| index == @indexes[i] }
        return nil unless delete_idx

        @indexes.delete_at(delete_idx)
        choice = @selected.delete_at(delete_idx)
        @size -= 1
        choice
      end

      def find_index_by(&search)
        (0...@size).bsearch(&search)
      end
    end # SelectedChoices
  end # Prompt
end # TTY
