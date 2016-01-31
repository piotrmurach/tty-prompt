# encoding: utf-8

module TTY
  class Prompt
    module Symbols
      SPACE   = " "
      SUCCESS = "✓"
      FAILURE = "✘"

      ITEM_SECURE     = "•"
      ITEM_SELECTED   = "‣"
      RADIO_CHECKED   = "⬢"
      RADIO_UNCHECKED = "⬡"
      SLIDER_HANDLE   = 'O'
      SLIDER_RANGE    = '-'
      SLIDER_END      = '|'
    end # Symbols
  end # Prompt
end # TTY
