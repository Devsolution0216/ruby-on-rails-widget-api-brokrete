# frozen_string_literal: true

module Clients
  class Sms::Base < Base
    include ::Drivers::TwilioDriver

    def deliver(options)
      stoplight("Twilio.message.#{options[:to]}") do
        super(options)
      end
    end

    def validate(phone_number)
      stoplight("Twilio.lookups.#{phone_number}") do
        validate_number(phone_number)
      end
    end
  end
end
