# frozen_string_literal: true
module Errors
  class NotFound < ::Error
    def initialize(message = nil)
      @message = message
    end

    def code
      :not_found
    end

    def status_code
      404
    end

    def description
      @message || super
    end

    def details
    end
  end
end
