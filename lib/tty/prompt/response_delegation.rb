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
                                :read_float,
                                :read_input,
                                :read_int,
                                :read_multiple,
                                :read_range,
                                :read_regex,
                                :read_string

      #
      # delegatable_method :dispatch, :read_text
      #
      # delegatable_method :dispatch, :read_symbol
      #
      # delegatable_method :dispatch, :read_file
      #
      # delegatable_method :dispatch, :read_password
      #
      # delegatable_method :dispatch, :read_keypress

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
