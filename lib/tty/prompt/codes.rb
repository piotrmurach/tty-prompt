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

      KEY_UP     = "\e[A"
      KEY_DOWN   = "\e[B"
      KEY_RIGHT  = "\e[C"
      KEY_LEFT   = "\e[D"
      KEY_CLEAR  = "\e[E"
      KEY_END    = "\e[F"
      KEY_HOME   = "\e[H"
      KEY_DELETE = "\e[3"

      KEY_UP_ALT     = "\eOA"
      KEY_DOWN_ALT   = "\eOB"
      KEY_RIGHT_ALT  = "\eOC"
      KEY_LEFT_ALT   = "\eOD"
      KEY_CLEAR_ALT  = "\eOE"
      KEY_END_ALT    = "\eOF"
      KEY_HOME_ALT   = "\eOH"
      KEY_DELETE_ALT = "\eO3"

      CTRL_J = "\x0A"
      CTRL_N = "\x0E"
      CTRL_K = "\x0B"
      CTRL_P = "\x10"
      SIGINT = "\x03"
      CTRL_C = "\x03"
      CTRL_H = "\b"
      CTRL_L = "\f"

      F1 = "\eOP"
      F2 = "\eOQ"
      F3 = "\eOR"
      F4 = "\eOS"

      F1_ALT = "\e[11~"
      F2_ALT = "\e[12~"
      F3_ALT = "\e[13~"
      F4_ALT = "\e[14~"

      F5 =  "\e[15~"
      F6 =  "\e[17~"
      F7 =  "\e[18~"
      F8 =  "\e[19~"
      F9 =  "\e[20~"
      F10 = "\e[21~"
      F11 = "\e[23~"
      F12 = "\e[24~"

      ITEM_SECURE     = "•"
      ITEM_SELECTED   = "‣"
      RADIO_CHECKED   = "⬢"
      RADIO_UNCHECKED = "⬡"
    end # Codes
  end # Prompt
end # TTY
