# encoding: utf-8

require 'tty/prompt/mode/echo'
require 'tty/prompt/mode/raw'

module TTY
  class Prompt
    class Mode
      # Initialize a Terminal
      #
      # @api public
      def initialize(options = {})
        @echo  = TTY::Prompt::Mode::Echo.new
        @raw   = TTY::Prompt::Mode::Raw.new
      end

      # Switch echo on
      #
      # @api public
      def echo_on
        @echo.on
      end

      # Switch echo off
      #
      # @api public
      def echo_off
        @echo.off
      end

      # Echo given block
      #
      # @param [Boolean] is_on
      #
      # @api public
      def echo(is_on = true, &block)
        @echo.echo(is_on, &block)
      end

      # Switch raw mode on
      #
      # @api public
      def raw_on
        @raw.on
      end

      # Switch raw mode off
      #
      # @api public
      def raw_off
        @raw.off
      end

      # Use raw mode in the given block
      #
      # @param [Boolean] is_on
      #
      # @api public
      def raw(is_on = true, &block)
        @raw.raw(is_on, &block)
      end
    end # Mode
  end # Prompt
end # TTY
