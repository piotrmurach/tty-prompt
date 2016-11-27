# encoding: utf-8

module TTY
  class Prompt
    class Reader
      module Codes
        BACKSPACE = "\x7f"
        DELETE   = "\004"
        ESCAPE   = "\e"
        LINEFEED = "\n"
        RETURN   = "\r"
        SPACE    = " "
        TAB      = "\t"

        KEY_UP     = "[A"
        KEY_DOWN   = "[B"
        KEY_RIGHT  = "[C"
        KEY_LEFT   = "[D"
        KEY_CLEAR  = "[E"
        KEY_END    = "[F"
        KEY_HOME   = "[H"
        KEY_DELETE = "[3"

        KEY_UP_XTERM     = "OA"
        KEY_DOWN_XTERM   = "OB"
        KEY_RIGHT_XTERM  = "OC"
        KEY_LEFT_XTERM   = "OD"
        KEY_CLEAR_XTERM  = "OE"
        KEY_END_XTERM    = "OF"
        KEY_HOME_XTERM   = "OH"
        KEY_DELETE_XTERM = "O3"

        KEY_UP_SHIFT    = "[a"
        KEY_DOWN_SHIFT  = "[b"
        KEY_RIGHT_SHIFT = "[c"
        KEY_LEFT_SHIFT  = "[d"
        KEY_CLEAR_SHIFT = "[e"

        CTRL_J = "\x0A"
        CTRL_N = "\x0E"
        CTRL_K = "\x0B"
        CTRL_P = "\x10"
        SIGINT = "\x03"
        CTRL_C = "\x03"
        CTRL_H = "\b"
        CTRL_L = "\f"

        F1_XTERM = "OP"
        F2_XTERM = "OQ"
        F3_XTERM = "OR"
        F4_XTERM = "OS"

        F1_GNOME = "[11~"
        F2_GNOME = "[12~"
        F3_GNOME = "[13~"
        F4_GNOME = "[14~"

        F1_WIN = "[[A"
        F2_WIN = "[[B"
        F3_WIN = "[[C"
        F4_WIN = "[[D"
        F5_WIN = "[[E"

        F5 =  "[15~"
        F6 =  "[17~"
        F7 =  "[18~"
        F8 =  "[19~"
        F9 =  "[20~"
        F10 = "[21~"
        F11 = "[23~"
        F12 = "[24~"
      end # Codes
    end # Reader
  end # Prompt
end # TTY
