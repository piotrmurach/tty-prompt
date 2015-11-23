# encoding: utf-8

module TTY
  # A class responsible for shell prompt interactions
  class Prompt
    # A class representing a shell response
    class Response
      attr_reader :reader
      private :reader

      attr_reader :question
      private :question

      # Initialize a Response
      #
      # @api public
      def initialize(question, prompt)
        @question  = question
        @prompt    = prompt
        @converter = Necromancer.new
        @reader    = Reader.new(@prompt)
      end

      # Read input from STDIN either character or line
      #
      # @param [Symbol] type
      #
      # @return [undefined]
      #
      # @api public
      def read(type = nil)
        question.evaluate_response read_input
      end

      # @api private
      def read_input
        if question.mask? && question.echo?
          reader.getc(question.mask)
        else
          reader.mode.echo(question.echo) do
            reader.mode.raw(question.raw) do
              if question.raw?
                reader.readpartial(10)
              elsif question.character?
                reader.getc(question.mask)
              else
                reader.gets
              end
            end
          end
        end
      end

      def no_input?(input)
        !input || input == "\n" || input.empty?
      end

      # @api private
      def evaluate_response
        input = read_input
        input = if no_input?(input)
                  nil
                elsif block_given?
                  yield(input)
                else input
                end
        question.evaluate_response(input)
      end

      # Read answer and cast to String type
      #
      # @param [String] error
      #   error to display on failed conversion to string type
      #
      # @api public
      def read_string(error = nil)
        evaluate_response { |input| String(input).strip }
      end

      # Read answer's first character
      #
      # @api public
      def read_char
        question.char(true)
        evaluate_response { |input| String(input).chars.to_a[0] }
      end

      # Read multiple line answer and cast to String type
      #
      # @api public
      def read_text
        evaluate_response { |input| String(input) }
      end

      # Read ansewr and cast to Symbol type
      #
      # @api public
      def read_symbol(error = nil)
        evaluate_response { |input| input.to_sym }
      end

      # Read answer from predifined choicse
      #
      # @api public
      def read_choice(type = nil)
        question.argument(:required) unless question.default?
        evaluate_response
      end

      # Read integer value
      #
      # @api public
      def read_int(error = nil)
        evaluate_response { |input| @converter.convert(input).to(:integer) }
      end

      # Read float value
      #
      # @api public
      def read_float(error = nil)
        evaluate_response { |input| @converter.convert(input).to(:float) }
      end

      # Read regular expression
      #
      # @api public
      def read_regex(error = nil)
        evaluate_response { |input| Kernel.send(:Regex, input) }
      end

      # Read range expression
      #
      # @api public
      def read_range
        evaluate_response { |input| @converter.convert(input).to(:range, strict: true) }
      end

      # Read date
      #
      # @api public
      def read_date
        evaluate_response { |input| @converter.convert(input).to(:date) }
      end

      # Read datetime
      #
      # @api public
      def read_datetime
        evaluate_response { |input| @converter.convert(input).to(:datetime) }
      end

      # Read boolean
      #
      # @api public
      def read_bool(error = nil)
        evaluate_response { |input| @converter.convert(input).to(:boolean, strict: true) }
      end

      # Read file contents
      #
      # @api public
      def read_file(error = nil)
        evaluate_response { |input| File.open(File.join(directory, input)) }
      end

      # Read string answer and validate against email regex
      #
      # @return [String]
      #
      # @api public
      def read_email
        question.validate(/^[a-z0-9._%+-]+@([a-z0-9-]+\.)+[a-z]{2,6}$/i)
        question.call("\n" + question.statement) if question.error?
        with_exception { read_string }
      end

      # Read answer provided on multiple lines
      #
      # @api public
      def read_multiline
        response = ''
        loop do
          value = evaluate_response
          break if !value || value == ''
          next  if value !~ /\S/
          response << value
        end
        response
      end

      # Read password
      #
      # @api public
      def read_password
        question.echo false
        evaluate_response
      end

      # Read a single keypress
      #
      # @api public
      def read_keypress
        question.echo false
        question.raw true
        question.evaluate_response(read_input).tap do |key|
          raise Interrupt if key == "\x03" # Ctrl-C
        end
      end

      # Ignore exception
      #
      # @api private
      def with_exception(&block)
        yield
      rescue
        question.error? ? block.call : raise
      end

      # @param [Symbol] type
      #   :boolean, :string, :numeric, :array
      #
      # @api private
      def read_type(class_or_name = nil)
        case class_or_name
        when :bool
          read_bool
        when :email
          read_email
        when :char
          read_char
        when :date
          read_date
        when :int
          read_int
        when :range
          read_range
        when :multiline
          read_multiline
        when :float, ::Float
          read_float
        when :string, ::String
          read_string
        when :symbol, ::Symbol
          read_symbol
        else
          read
        end
      end
    end # Response
  end # Prompt
end # TTY
