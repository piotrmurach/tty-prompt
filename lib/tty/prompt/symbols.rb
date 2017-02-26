# encoding: utf-8

module TTY
  class Prompt
    # Cross platform common Unicode symbols.
    #
    # @api public
    module Symbols
      KEYS = {
        tick: '✓',
        cross: '✘',
        star: '★',
        dot: '•',
        pointer: '‣',
        line: '─',
        pipe: '|',
        handle: 'O',
        ellipsis: '…',
        radio_on: '⬢',
        radio_off: '⬡',
        checkbox_on: '☒',
        checkbox_off: '☐',
        circle_on: 'ⓧ',
        circle_off: 'Ⓘ'
      }.freeze

      WIN_KEYS = {
        tick: '√',
        cross: '×',
        star: '*',
        dot: '.',
        pointer: '>',
        line: '-',
        pipe: '|',
        handle: 'O',
        ellipsis: '...',
        radio_on: '(*)',
        radio_off: '( )',
        checkbox_on: '[×]',
        checkbox_off: '[ ]',
        circle_on: '(x)',
        circle_off: '( )'
      }.freeze

      def symbols
        @symbols ||= windows? ? WIN_KEYS : KEYS
      end
      module_function :symbols

      # Check if Windowz
      #
      # @return [Boolean]
      #
      # @api public
      def windows?
        ::File::ALT_SEPARATOR == "\\"
      end
      module_function :windows?
    end # Symbols
  end # Prompt
end # TTY
