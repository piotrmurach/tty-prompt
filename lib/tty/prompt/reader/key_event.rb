# encoding: utf-8

module TTY
  class Prompt
    class Reader
      # Responsible for meta-data information about key pressed
      #
      # @api private
      class Key < Struct.new(:name, :ctrl, :meta, :shift)
        def initialize(*)
          super(nil, false, false, false)
        end
      end

      # Represents key event emitted during keyboard press
      #
      # @api public
      class KeyEvent < Struct.new(:value, :key)
        # Create key event from read input codes
        #
        # @param [Hash[Symbol]] keys
        #   the keys and codes mapping
        # @param [Array[Integer]] codes
        #
        # @return [KeyEvent]
        #
        # @api public
        def self.from(keys, char)
          key = Key.new
          ctrls = keys.keys.grep(/ctrl/)

          case char
          when keys[:return] then key.name = :return
          when keys[:enter]  then key.name = :enter
          when keys[:tab]    then key.name = :tab
          when keys[:backspace] then key.name = :backspace
          when keys[:delete] then key.name = :delete
          when keys[:space]  then key.name = :space
          when keys[:escape] then key.name = :escape
          when proc { |c| c =~ /^[a-z]{1}$/ }
            key.name = :alpha
          when proc { |c| c =~ /^[A-Z]{1}$/ }
            key.name = :alpha
            key.shift = true
          when proc { |c| c =~ /^\d+$/ }
            key.name = :num
          # arrows
          when keys[:up]    then key.name = :up
          when keys[:down]  then key.name = :down
          when keys[:left]  then key.name = :left
          when keys[:right] then key.name = :right
          # editing
          when keys[:clear] then key.name = :clear
          when keys[:end]   then key.name = :end
          when keys[:home]  then key.name = :home
          when keys[:insert]    then key.name = :insert
          when keys[:page_up]   then key.name = :page_up
          when keys[:page_down] then key.name = :page_down
          when proc { |cs| ctrls.any? { |name| keys[name] == cs } }
            key.name = keys.key(char)
            key.ctrl = true
          # f1 - f12
          when keys[:f1], keys[:f1_xterm] then key.name = :f1
          when keys[:f2], keys[:f2_xterm] then key.name = :f2
          when keys[:f3], keys[:f3_xterm] then key.name = :f3
          when keys[:f4], keys[:f4_xterm] then key.name = :f4
          when keys[:f5] then key.name = :f5
          when keys[:f6] then key.name = :f6
          when keys[:f7] then key.name = :f7
          when keys[:f8] then key.name = :f8
          when keys[:f9] then key.name = :f9
          when keys[:f10] then key.name = :f10
          when keys[:f11] then key.name = :f11
          when keys[:f12] then key.name = :f12
          end

          new(char, key)
        end

        # Check if key event can be triggered
        #
        # @return [Boolean]
        #
        # @api public
        def trigger?
          !key.nil? && !key.name.nil?
        end
      end # KeyEvent
    end # Reader
  end # Prompt
end # TTY
