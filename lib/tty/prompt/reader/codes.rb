# encoding: utf-8

module TTY
  class Prompt
    class Reader
      module Codes
        def ctrl_keys
          {
            ctrl_a: ?\C-a,
            ctrl_b: ?\C-b,
            ctrl_c: ?\C-c,
            ctrl_d: ?\C-d,
            ctrl_e: ?\C-e,
            ctrl_f: ?\C-f,
            ctrl_g: ?\C-g,
            ctrl_h: ?\C-h,
            ctrl_i: ?\C-i,
            ctrl_j: ?\C-j,
            ctrl_k: ?\C-k,
            ctrl_l: ?\C-l,
            ctrl_m: ?\C-m,
            ctrl_n: ?\C-n,
            ctrl_o: ?\C-o,
            ctrl_p: ?\C-p,
            ctrl_q: ?\C-q,
            ctrl_r: ?\C-r,
            ctrl_s: ?\C-s,
            ctrl_t: ?\C-t,
            ctrl_u: ?\C-u,
            ctrl_v: ?\C-v,
            ctrl_w: ?\C-w,
            ctrl_x: ?\C-x,
            ctrl_y: ?\C-y,
            ctrl_z: ?\C-z
          }
        end
        module_function :ctrl_keys

        def keys
          {
            tab:       "\t",
            enter:     "\n",
            return:    "\r",
            escape:    "\e",
            space:     " ",
            backspace: ?\C-?,
            home:      "\e[1~",
            insert:    "\e[2~",
            delete:    "\e[3~",
            end:       "\e[4~",
            page_up:   "\e[5~",
            page_down: "\e[6~",

            up:     "\e[A",
            down:   "\e[B",
            right:  "\e[C",
            left:   "\e[D",
            clear:  "\e[E",

            f1_xterm: "\eOP",
            f2_xterm: "\eOQ",
            f3_xterm: "\eOR",
            f4_xterm: "\eOS",

            f1:  "\e[11~",
            f2:  "\e[12~",
            f3:  "\e[13~",
            f4:  "\e[14~",
            f5:  "\e[15~",
            f6:  "\e[17~",
            f7:  "\e[18~",
            f8:  "\e[19~",
            f9:  "\e[20~",
            f10: "\e[21~",
            f11: "\e[23~",
            f12: "\e[24~"
          }.merge(ctrl_keys)
        end
        module_function :keys

        def win_keys
          {
            tab:       "\t",
            enter:     "\r",
            return:    "\r",
            escape:    "\e",
            space:     " ",
            backspace: "\b",
            home:      [224, 71].pack('U*'),
            end:       [224, 79].pack('U*'),
            insert:    [224, 82].pack('U*'),
            delete:    [224, 83].pack('U*'),
            page_up:   [224, 73].pack('U*'),
            page_down: [224, 81].pack('U*'),

            up:     [224, 72].pack('U*'),
            down:   [224, 80].pack('U*'),
            right:  [224, 77].pack('U*'),
            left:   [224, 75].pack('U*'),
            clear:  [224, 83].pack('U*'),

            f1:  "\x00;",
            f2:  "\x00<",
            f3:  "\x00",
            f4:  "\x00=",
            f5:  "\x00?",
            f6:  "\x00@",
            f7:  "\x00A",
            f8:  "\x00B",
            f9:  "\x00C",
            f10: "\x00D",
            f11: "\x00\x85",
            f12: "\x00\x86"
          }.merge(ctrl_keys)
        end
        module_function :win_keys

      end # Codes
    end # Reader
  end # Prompt
end # TTY
