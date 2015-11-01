# encoding: utf-8

require 'forwardable'

module TTY
  class Prompt
    module ResponseDelegation
      extend Forwardable

      def_delegators :dispatch, :read,
                                :read_bool,
                                :read_char,
                                :read_choice,
                                :read_date,
                                :read_datetime,
                                :read_email,
                                :read_file,
                                :read_float,
                                :read_input,
                                :read_int,
                                :read_keypress,
                                :read_multiple,
                                :read_password,
                                :read_range,
                                :read_regex,
                                :read_string,
                                :read_symbol,
                                :read_text

      # Create response instance when question readed is invoked
      #
      # @param [Response] response
      #
      # @api private
      def dispatch(response = Response.new(self, shell))
        @response ||= response
      end

    end # ResponseDelegation
  end # Prompt
end # TTY
