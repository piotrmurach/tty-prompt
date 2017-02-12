# encoding: utf-8

require_relative 'question'

module TTY
  class Prompt
    class ConfirmQuestion < Question
      # Create confirmation question
      #
      # @param [Hash] options
      # @option options [String] :suffix
      # @option options [String] :positive
      # @option options [String] :negative
      #
      # @api public
      def initialize(prompt, options = {})
        super

        @suffix   = options.fetch(:suffix)   { UndefinedSetting }
        @positive = options.fetch(:positive) { UndefinedSetting }
        @negative = options.fetch(:negative) { UndefinedSetting }
        @type     = options.fetch(:type)     { :yes }
      end

      def positive?
        @positive != UndefinedSetting
      end

      def negative?
        @negative != UndefinedSetting
      end

      def suffix?
        @suffix != UndefinedSetting
      end

      # Set question suffix
      #
      # @api public
      def suffix(value)
        @suffix = value
      end

      # Set value for matching positive choice
      #
      # @api public
      def positive(value)
        @positive = value
      end

      # Set value for matching negative choice
      #
      # @api public
      def negative(value)
        @negative = value
      end

      def call(message, &block)
        return if Utils.blank?(message)
        @message = message
        block.call(self) if block
        setup_defaults
        render
      end

      # Render confirmation question
      #
      # @api private
      def render_question
        header = "#{@prefix}#{message} "

        if !@done
          header += @prompt.decorate("(#{@suffix})", @help_color) + ' '
        else
          answer = convert_result(@input)
          label  = answer ? @positive : @negative
          header += @prompt.decorate(label, @active_color)
        end
        @prompt.print(header)
        @prompt.print("\n") if @done
      end

      protected

      # @api private
      def is?(type)
        @type == type
      end

      # @api private
      def setup_defaults
        return if suffix? && positive?

        if suffix? && !positive?
          parts = @suffix.split('/')
          @positive = parts[0]
          @negative = parts[1]
          @convert = conversion
        elsif !suffix? && positive?
          @suffix = create_suffix
          @convert = conversion
        else
          create_default_labels
          @convert  = :bool
        end
      end

      def create_default_labels
        if is?(:yes)
          @suffix   = default? ? 'Y/n' : 'y/N'
          @positive = default? ? 'Yes' : 'yes'
          @negative = default? ? 'no' : 'No'
        else
          @suffix   = default? ? 'y/N' : 'Y/n'
          @positive = default? ? 'Yes' : 'yes'
          @negative = default? ? 'No'  : 'no'
        end
      end

      # @api private
      def create_suffix
        result = ''
        if is?(:yes)
          result << "#{default? ? @positive.capitalize : @positive.downcase}"
          result << '/'
          result << "#{default? ? @negative.downcase : @negative.capitalize}"
        else
          result << "#{default? ? @positive.downcase : @positive.capitalize}"
          result << '/'
          result << "#{default? ? @negative.capitalize : @negative.downcase}"
        end
      end

      # Create custom conversion
      #
      # @api private
      def conversion
        proc { |input| !input.match(/^#{@positive}|#{@positive[0]}$/i).nil? }
      end
    end # ConfirmQuestion
  end # Prompt
end # TTY
