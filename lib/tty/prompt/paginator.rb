# encoding: utf-8

module TTY
  class Prompt
    class Paginator
      DEFAULT_PAGE_SIZE = 6

      # Create a Paginator
      #
      # @api private
      def initialize(options = {})
        @last_index  = options.fetch(:default)  { 0 }
        @per_page    = options.fetch(:per_page) { DEFAULT_PAGE_SIZE }
        @lower_index = options.fetch(:default) { 0 }
        @upper_index = max_index
      end

      # Maximum index for current pagination
      #
      # @return [Integer]
      #
      # @api public
      def max_index
        @lower_index + @per_page - 1
      end

      # Paginate collection given an active index
      #
      # @param [Array[Choice]] list
      #   a collection of choice items
      # @param [Integer] active
      #   current choice active index
      #
      # @return [Enumerable]
      #
      # @api public
      def paginate(list, active)
        current_index = active - 1

        if current_index > @last_index # going up
          if current_index > @upper_index && current_index < list.size - 1
            @lower_index = @lower_index + 1
          end
        elsif current_index < @last_index # going down
          if current_index < @lower_index && current_index > 0
            @lower_index = @lower_index - 1
          end
        end

        if current_index == 0
          @lower_index = 0
        elsif current_index == list.size - 1
          @lower_index = list.size - 1 - (@per_page - 1)
        end

        @upper_index = @lower_index + (@per_page - 1)
        @last_index = current_index

        sliced_list = list[@lower_index..@upper_index]
        indices = (@lower_index..@upper_index)

        return sliced_list.zip(indices).to_enum unless block_given?

        sliced_list.each_with_index do |item, index|
          yield(item, @lower_index + index)
        end
      end
    end # Paginator
  end # Prompt
end # TTY
