# frozen_string_literal: true
module Errors
  class Custom < ::Error

    def initialize(code = :invalid, message = nil, status_code = 422)
      @message = message
      @code = code
      @status_code = status_code
    end

    attr_reader :message, :code, :status_code

    def details
    end

    def description
      @message || super
    end
  end
end
