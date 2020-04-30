# frozen_string_literal: true
module Errors
  class Unauthorized < ::Error
    def initialize(message = nil)
      @message = message
    end

    def code
      :unauthorized
    end

    def status_code
      403
    end

    def description
      @message || super
    end

    def details
    end
  end
end
