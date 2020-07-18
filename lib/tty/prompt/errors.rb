# frozen_string_literal: true

module TTY
  class Prompt
    Error = Class.new(StandardError)

    # Raised when wrong parameter is used to configure prompt
    ConfigurationError = Class.new(Error)

    # Raised when type conversion cannot be performed
    ConversionError = Class.new(Error)

    # Raised when the passed in validation argument is of wrong type
    ValidationCoercion = Class.new(Error)

    # Raised when the required argument is not supplied
    ArgumentRequired = Class.new(Error)

    # Raised when the argument validation fails
    ArgumentValidation = Class.new(Error)

    # Raised when the argument is not expected
    InvalidArgument = Class.new(Error)

    # Raised when overriding already defined conversion
    ConversionAlreadyDefined = Class.new(Error)

    # Raised when conversion type isn't registered
    UnsupportedConversion = Class.new(Error)
  end # Prompt
end # TTY
