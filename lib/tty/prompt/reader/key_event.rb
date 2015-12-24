# encoding: utf-8

require 'tty/prompt/reader/codes'

module TTY
  class Prompt
    class Reader
      # Responsible for meta-data information about key pressed
      #
      # @api private
      class Key < Struct.new(:name, :ctrl, :meta, :shift)
        def initialize(*)
          super
          @ctrl = false
          @meta = false
          @shift = false
        end
      end

      # Represents key event emitted during keyboard press
      #
      # @api public
      class KeyEvent < Struct.new(:value, :key)
        META_KEY_CODE_RE = /^(?:\x1b+)(O|N|\[|\[\[)(?:(\d+)(?:;(\d+))?([~^$])|(?:1;)?(\d+)?([a-zA-Z]))/

        def self.from(char)
          key = Key.new
          case char
          when Codes::RETURN
            key.name = :return
          when Codes::LINEFEED
            key.name = :enter
          when Codes::TAB
            key.name = :tab
          when Codes::BACKSPACE
            key.name = :backspace
          when Codes::SPACE
            key.name = :space
          when Codes::CTRL_C, Codes::ESCAPE
            key.name = :escape
          when proc { |c| c <= "\x1a" }
            codes = char.each_codepoint.to_a
            key.name = "#{codes}"
            key.ctrl = true
          when /\d/
            key.name = :num
          when META_KEY_CODE_RE
            key.meta = true
            case char
            when Codes::KEY_UP, Codes::CTRL_K, Codes::CTRL_P
              key.name = :up
            when Codes::KEY_DOWN, Codes::CTRL_J, Codes::CTRL_N
              key.name = :down
            when Codes::KEY_RIGHT, Codes::CTRL_L
              key.name = :right
            when Codes::KEY_LEFT, Codes::CTRL_H
              key.name = :left
            end
          end
          new(char, key)
        end
      end # KeyEvent
    end # Reader
  end # Prompt
end # TTY
