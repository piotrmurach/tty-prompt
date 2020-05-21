# frozen_string_literal: true

module TTY
  class Prompt
    module Const
      Undefined = Object.new.tap do |obj|
        def obj.to_s
          "undefined"
        end

        def obj.inspect
          "undefined".inspect
        end
      end
    end # Const
  end # Prompt
end # TTY
