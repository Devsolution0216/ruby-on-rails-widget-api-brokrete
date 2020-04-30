# frozen_string_literal: true

module Clients
  class Email::Base < Base
    include ::Drivers::EmailDriver

    def deliver(options)
      stoplight("SendGrid.send") do
        super(options)
      end
    end

  end
end
