# encoding: utf-8

module TTY
  class Prompt
     # A class responsible for storing shell interactions
     class History

       attr_reader :max_size

       def initialize(max_size=nil)
         @max_size = max_size
       end

    end # History
  end # Prompt
end # TTY
