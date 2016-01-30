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
        include Codes

        META_KEY_CODE_RE = /^(?:\e)(O|N|\[|\[\[)(?:(\d+)(?:;(\d+))?([~^$])|(?:1;)?(\d+)?([a-zA-Z]))/

        def self.from(char)
          key = Key.new
          case char
          when RETURN   then key.name = :return
          when LINEFEED then key.name = :enter
          when TAB      then key.name = :tab
          when BACKSPACE, CTRL_H, "#{ESCAPE}#{BACKSPACE}", "#{ESCAPE}#{CTRL_H}"
            key.name = :backspace
          when DELETE   then key.name = :delete
          when SPACE    then key.name = :space
          when CTRL_C, ESCAPE then key.name = :escape
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
            when F1_XTERM, F1_GNOME, F1_WIN then key.name = :f1
            when F2_XTERM, F2_GNOME, F2_WIN then key.name = :f2
            when F3_XTERM, F3_GNOME, F3_WIN then key.name = :f3
            when F4_XTERM, F4_GNOME, F4_WIN then key.name = :f4
            when F5 then key.name = :f5
            when F6 then key.name = :f6
            when F7 then key.name = :f7
            when F8 then key.name = :f8
            when F9 then key.name = :f9
            when F10 then key.name = :f10
            when F11 then key.name = :f11
            when F12 then key.name = :f12
            # navigation
            when KEY_UP, KEY_UP_ALT, CTRL_K, CTRL_P
              key.name = :up
            when KEY_DOWN, KEY_DOWN_ALT, CTRL_J, Codes::CTRL_N
              key.name = :down
            when KEY_RIGHT, KEY_RIGHT_ALT, CTRL_L
              key.name = :right
            when KEY_LEFT, KEY_LEFT_ALT, CTRL_H
              key.name = :left
            when KEY_CLEAR, KEY_CLEAR_ALT
              key.name = :clear
            when KEY_END, KEY_END_ALT
              key.name = :end
            when KEY_HOME, KEY_HOME_ALT
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
