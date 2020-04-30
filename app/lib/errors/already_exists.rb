# frozen_string_literal: true
module Errors
  class AlreadyExists < ::Error
    def initialize(message = nil)
      @message = message
    end

    def code
      :already_exists
    end

    def status_code
      422
    end

    def description
      @message || super
    end

    def details
    end
  end
end
