# frozen_string_literal: true

require 'stoplight'

module Clients
  class Base
    def stoplight(key, &block)
      light = Stoplight(key, &block)
        .with_threshold(4)
        .with_cool_off_time(60)
        .with_error_handler do |error, handle|
          Rails.logger.error error
          handle.call(error)
        end

      light.run
    end
  end
end
