# encoding: utf-8

module TTY
  class Prompt
    class Reader
      module Codes
        def keys
          {
            tab:       ["\t".ord],
            enter:     ["\n".ord],
            return:    ["\r".ord],
            escape:    ["\e".ord],
            space:     [" ".ord],
            backspace: ["\x7f".ord],
            insert:    "\e[2~".bytes.to_a,
            delete:    "\e[3~".bytes.to_a,

            up:     "\e[A".bytes.to_a,
            down:   "\e[B".bytes.to_a,
            right:  "\e[C".bytes.to_a,
            left:   "\e[D".bytes.to_a,
            clear:  "\e[E".bytes.to_a,
            end:    "\e[F".bytes.to_a,
            home:   "\e[H".bytes.to_a,

            ctrl_a: [?\C-a.ord],
            ctrl_b: [?\C-b.ord],
            ctrl_c: [?\C-c.ord],
            ctrl_d: [?\C-d.ord],
            ctrl_e: [?\C-e.ord],
            ctrl_f: [?\C-f.ord],
            ctrl_g: [?\C-g.ord],
            ctrl_h: [?\C-h.ord],
            ctrl_i: [?\C-i.ord],
            ctrl_j: [?\C-j.ord],
            ctrl_k: [?\C-k.ord],
            ctrl_l: [?\C-l.ord],
            ctrl_m: [?\C-m.ord],
            ctrl_n: [?\C-n.ord],
            ctrl_o: [?\C-o.ord],
            ctrl_p: [?\C-p.ord],
            ctrl_q: [?\C-q.ord],
            ctrl_r: [?\C-r.ord],
            ctrl_s: [?\C-s.ord],
            ctrl_t: [?\C-t.ord],
            ctrl_u: [?\C-u.ord],
            ctrl_v: [?\C-v.ord],
            ctrl_w: [?\C-w.ord],
            ctrl_x: [?\C-x.ord],
            ctrl_y: [?\C-y.ord],
            ctrl_z: [?\C-z.ord],

            f1_xterm: "\eOP".bytes.to_a,
            f2_xterm: "\eOQ".bytes.to_a,
            f3_xterm: "\eOR".bytes.to_a,
            f4_xterm: "\eOS".bytes.to_a,

            f1:  "\e[11~".bytes.to_a,
            f2:  "\e[12~".bytes.to_a,
            f3:  "\e[13~".bytes.to_a,
            f4:  "\e[14~".bytes.to_a,
            f5:  "\e[15~".bytes.to_a,
            f6:  "\e[17~".bytes.to_a,
            f7:  "\e[18~".bytes.to_a,
            f8:  "\e[19~".bytes.to_a,
            f9:  "\e[20~".bytes.to_a,
            f10: "\e[21~".bytes.to_a,
            f11: "\e[23~".bytes.to_a,
            f12: "\e[24~".bytes.to_a
          }
        end
        module_function :keys

        # KEY_UP_XTERM     = "OA"
        # KEY_DOWN_XTERM   = "OB"
        # KEY_RIGHT_XTERM  = "OC"
        # KEY_LEFT_XTERM   = "OD"
        # KEY_CLEAR_XTERM  = "OE"
        # KEY_END_XTERM    = "OF"
        # KEY_HOME_XTERM   = "OH"
        # KEY_DELETE_XTERM = "O3"

        # KEY_UP_SHIFT    = "[a"
        # KEY_DOWN_SHIFT  = "[b"
        # KEY_RIGHT_SHIFT = "[c"
        # KEY_LEFT_SHIFT  = "[d"
        # KEY_CLEAR_SHIFT = "[e"

        # KEY_UP_CTRL    = "0a"
        # KEY_DOWN_CTRL  = "0b"
        # KEY_RIGHT_CTRL = "0c"
        # KEY_LEFT_CTRL  = "0d"
        # KEY_CLEAR_CTRL = "0e"

        # F1_XTERM = "OP"
        # F2_XTERM = "OQ"
        # F3_XTERM = "OR"
        # F4_XTERM = "OS"

        # F1_WIN = "[[A"
        # F2_WIN = "[[B"
        # F3_WIN = "[[C"
        # F4_WIN = "[[D"
        # F5_WIN = "[[E"
      end # Codes
    end # Reader
  end # Prompt
end # TTY
