# encoding: utf-8

class Error

  attr_reader :errors

  def initialize(question, errors=[])
    @question = question
    @errors = errors
  end

  def <<(type, message)
    @errors << [type, message]
  end


  # Handle exception
  #
  # @api private
  def error_wrapping(&block)
    yield
  rescue
    question.error? ? block.call : raise
  end

end # Error
