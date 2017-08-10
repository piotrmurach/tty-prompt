# encoding: utf-8

require 'fiddle'

module TTY
  class Prompt
    class Reader
      module WinAPI
        include Fiddle

        Handle = RUBY_VERSION >= "2.0.0" ? Fiddle::Handle : DL::Handle

        CRT_HANDLE = Handle.new("msvcrt") rescue Handle.new("crtdll")

        def getch
          @@getch ||= Fiddle::Function.new(CRT_HANDLE["_getch"], [], TYPE_INT)
          @@getch.call
        end
        module_function :getch

        def getche
          @@getche ||= Fiddle::Function.new(CRT_HANDLE["_getche"], [], TYPE_INT)
          @@getche.call
        end
        module_function :getche

        # Check the console for recent keystroke. If the function
        # returns a nonzero value, a keystroke is waiting in the buffer.
        #
        # @return [Integer]
        #   return a nonzero value if a key has been pressed. Otherwirse,
        #   it returns 0.
        #
        # @api public
        def kbhit
          @@kbhit ||= Fiddle::Function.new(CRT_HANDLE["_kbhit"], [], TYPE_INT)
          @@kbhit.call
        end
        module_function :kbhit
      end # WinAPI
    end # Reader
  end # Prompt
end # TTY
