# frozen_string_literal: true

require "forwardable"

require_relative "choice"

module TTY
  class Prompt
    # A class responsible for storing a collection of choices
    #
    # @api private
    class Choices
      include Enumerable
      extend Forwardable

      def_delegators :choices, :length, :size, :to_ary, :empty?,
                     :values_at, :index, :==

      # Convenience for creating choices
      #
      # @param [Array[Object]] choices
      #   the choice objects
      #
      # @return [Choices]
      #   the choices collection
      #
      # @api public
      def self.[](*choices)
        new(choices)
      end

      # Create Choices collection
      #
      # @param [Array[Choice]] choices
      #   the choices to add to collection
      #
      # @api public
      def initialize(choices = [])
        @choices = choices.map do |choice|
          Choice.from(choice)
        end
      end

      # Scope of choices which are not disabled
      #
      # @api public
      def enabled
        reject(&:disabled?)
      end

      def enabled_indexes
        each_with_index.reduce([]) do |acc, (choice, idx)|
          acc << idx unless choice.disabled?
          acc
        end
      end

      # Iterate over all choices in the collection
      #
      # @yield [Choice]
      #
      # @api public
      def each(&block)
        return to_enum unless block_given?

        choices.each(&block)
      end

      # Add choice to collection
      #
      # @param [Object] choice
      #   the choice to add
      #
      # @api public
      def <<(choice)
        choices << Choice.from(choice)
      end

      # Access choice by index
      #
      # @param [Integer] index
      #
      # @return [Choice]
      #
      # @api public
      def [](index)
        @choices[index]
      end

      # Pluck a choice by its name from collection
      #
      # @param [String] name
      #   the label name for the choice
      #
      # @return [Choice]
      #
      # @api public
      def pluck(name)
        map { |choice| choice.public_send(name) }
      end

      # Find a matching choice
      #
      # @example
      #   choices.find_by(:name, "small")
      #
      # @param [Symbol] attr
      #   the attribute name
      # @param [Object] value
      #
      # @return [Choice]
      #
      # @api public
      def find_by(attr, value)
        find { |choice| choice.public_send(attr) == value }
      end

      protected

      # The actual collection choices
      #
      # @return [Array[Choice]]
      #
      # @api private

      attr_reader :choices
    end # Choices
  end # Prompt
end # TTY
