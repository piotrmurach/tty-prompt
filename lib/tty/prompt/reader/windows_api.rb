# encoding: utf-8

require 'fiddle/importer'

module TTY
  class Prompt
    class Reader
      module WindowsAPI
        extend Fiddle::Importer

        dlload 'crtdll'

        extern 'int _getch(void)'
        extern 'int _getche(void)'
      end # WindowsAPI
    end # Reader
  end # Prompt
end # TTY
