# encoding: utf-8

module TTY
  class Prompt
    class Paginator
      DEFAULT_PAGE_SIZE = 6

      # Create a Paginator
      #
      # @api private
      def initialize(options = {})
        @last_index  = Array(options[:default]).flatten.first || 0
        @per_page    = options[:per_page]
        @lower_index = Array(options[:default]).flatten.first
      end

      # Maximum index for current pagination
      #
      # @return [Integer]
      #
      # @api public
      def max_index
        raise ArgumentError, 'no max index' unless @per_page
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
      def paginate(list, active, &block)
        current_index = active - 1
        @per_page ||= (list.size <= DEFAULT_PAGE_SIZE ? list.size : DEFAULT_PAGE_SIZE)
        @lower_index ||= current_index
        @upper_index ||= max_index

        # Don't paginate short lists
        if list.size <= @per_page
          @lower_index = 0
          @upper_index = list.size - 1
          if block
            return list.each_with_index(&block)
          else
            return list.each_with_index.to_enum
          end
        end

        if current_index > @last_index # going up
          if current_index > @upper_index && current_index < list.size - 1
            @lower_index += 1
          end
        elsif current_index < @last_index # going down
          if current_index < @lower_index && current_index > 0
            @lower_index -= 1
          end
        end

        # Cycle list
        if current_index.zero?
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
          block[item, @lower_index + index]
        end
      end
    end # Paginator
  end # Prompt
end # TTY
