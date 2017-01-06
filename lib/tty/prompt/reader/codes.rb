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
            backspace: [?\C-?.ord],
            insert:    "\e[2~".bytes.to_a,
            delete:    "\e[3~".bytes.to_a,
            page_up:   "\e[5~".bytes.to_a,
            page_down: "\e[6~".bytes.to_a,

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
            # ctrl_i: [?\C-i.ord],
            # ctrl_j: [?\C-j.ord],
            ctrl_k: [?\C-k.ord],
            ctrl_l: [?\C-l.ord],
            # ctrl_m: [?\C-m.ord],
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

        def win_keys
          {
            tab:       ["\t".ord],
            enter:     ["\r".ord],
            return:    ["\r".ord],
            escape:    ["\e".ord],
            space:     [" ".ord],
            backspace: ["\b".ord],
            insert:    [224, 82],
            delete:    [224, 83],

            up:     [224, 72],
            down:   [224, 80],
            right:  [224, 77],
            left:   [224, 75],
            clear:  "\e[E".bytes.to_a,
            end:    "\e[F".bytes.to_a,
            home:   "\e[H".bytes.to_a,

            f1:  "\eOP".bytes.to_a,
            f2:  "\eOQ".bytes.to_a,
            f3:  "\eOR".bytes.to_a,
            f4:  "\eOS".bytes.to_a,
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
        module_function :win_keys

      end # Codes
    end # Reader
  end # Prompt
end # TTY
