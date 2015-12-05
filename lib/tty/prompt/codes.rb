# encoding: utf-8

module TTY
  class Prompt
    module Codes
      BACKSPACE = "\177"
      DELETE   = "\004"
      ESCAPE   = "\e"
      LINEFEED = "\n"
      RETURN   = "\r"
      SPACE    = " "
      TAB      = "\t"

      KEY_UP        = "\e[A"
      KEY_DOWN      = "\e[B"
      KEY_RIGHT     = "\e[C"
      KEY_LEFT      = "\e[D"
      KEY_DELETE    = "\e[3"

      CTRL_J = "\x0A"
      CTRL_N = "\x0E"
      CTRL_K = "\x0B"
      CTRL_P = "\x10"
      SIGINT = "\x03"
      CTRL_C = "\x03"

      ITEM_SECURE     = "•"
      ITEM_SELECTED   = "‣"
      RADIO_CHECKED   = "⬢"
      RADIO_UNCHECKED = "⬡"
    end # Codes
  end # Prompt
end # TTY
