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
        META_KEY_CODE_RE = /^(?:\e)(O|N|\[|\[\[)(?:(\d+)(?:;(\d+))?([~^$])|(?:1;)?(\d+)?([a-zA-Z]))/

        def self.from(char)
          key = Key.new
          case char
          when Codes::RETURN   then key.name = :return
          when Codes::LINEFEED then key.name = :enter
          when Codes::TAB      then key.name = :tab
          when Codes::BACKSPACE, Codes::CTRL_H,
              "#{Codes::ESCAPE}#{Codes::BACKSPACE}",
              "#{Codes::ESCAPE}#{Codes::CTRL_H}"
            key.name = :backspace
          when Codes::DELETE   then key.name = :delete
          when Codes::SPACE    then key.name = :space
          when Codes::CTRL_C, Codes::ESCAPE then key.name = :escape
          when proc { |c| c.length == 1 && c =~ /[a-z]/ }
            key.name = char
          when proc { |c| c.length == 1 && c =~ /[A-Z]/ }
            key.name = char.downcase
            key.shift = true
          when /^\d+$/
            key.name = :num
          when META_KEY_CODE_RE # ansi escape
            key.meta = true

            case char
            # f1 - f12
            when Codes::F1_XTERM, Codes::F1_GNOME, Codes::F1_WIN then key.name = :f1
            when Codes::F2_XTERM, Codes::F2_GNOME, Codes::F2_WIN then key.name = :f2
            when Codes::F3_XTERM, Codes::F3_GNOME, Codes::F3_WIN then key.name = :f3
            when Codes::F4_XTERM, Codes::F4_GNOME, Codes::F4_WIN then key.name = :f4
            when Codes::F5 then key.name = :f5
            when Codes::F6 then key.name = :f6
            when Codes::F7 then key.name = :f7
            when Codes::F8 then key.name = :f8
            when Codes::F9 then key.name = :f9
            when Codes::F10 then key.name = :f10
            when Codes::F11 then key.name = :f11
            when Codes::F12 then key.name = :f12
            # navigation
            when Codes::KEY_UP, Codes::KEY_UP_ALT, Codes::CTRL_K, Codes::CTRL_P
              key.name = :up
            when Codes::KEY_DOWN, Codes::KEY_DOWN_ALT, Codes::CTRL_J, Codes::CTRL_N
              key.name = :down
            when Codes::KEY_RIGHT, Codes::KEY_RIGHT_ALT, Codes::CTRL_L
              key.name = :right
            when Codes::KEY_LEFT, Codes::KEY_LEFT_ALT, Codes::CTRL_H
              key.name = :left
            when Codes::KEY_CLEAR, Codes::KEY_CLEAR_ALT
              key.name = :clear
            when Codes::KEY_END, Codes::KEY_END_ALT
              key.name = :end
            when Codes::KEY_HOME, Codes::KEY_HOME_ALT
              key.name = :home
            end
          end
          new(char, key)
        end

        # Check if key event can be emitted
        #
        # @return [Boolean]
        #
        # @api public
        def emit?
          !key.nil? && !key.name.nil?
        end
      end # KeyEvent
    end # Reader
  end # Prompt
end # TTY
