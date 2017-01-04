# encoding: utf-8

require 'fiddle'

module TTY
  class Prompt
    class Reader
      module WindowsAPI
        include Fiddle

        CRT_HANDLE = Handle.new("msvcrt") rescue Handle.new("crtdll")

        def getch
          @@getch ||= Function.new(CRT_HANDLE["_getch"], [], TYPE_INT)
          @@getch.call
        end
        module_function :getch

        def getche
          @@getche ||= Function.new(CRT_HANDLE["_getche"], [], TYPE_INT)
          @@getche.call
        end
        module_function :getche
      end # WindowsAPI
    end # Reader
  end # Prompt
end # TTY
