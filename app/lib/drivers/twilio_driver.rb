# frozen_string_literal: true

require 'uri'
require 'twilio-ruby'

module Drivers
  module TwilioDriver

    def deliver(options)
      twilio_params = {}.tap do |h|
        h[:body] = options[:message]
        h[:to] = options[:to]
        h[:from] = options[:from]
      end

      Rails.logger.info "Try to send SMS: #{twilio_params.inspect}"

      driver_messages.create(twilio_params).tap do |result|
        Rails.logger.info "Sent SMS to #{options[:to]}, message is #{options[:message]}. Result: #{result.inspect}"
      end
    end

    def validate_number(phone_number)
      encoded_phone_number = URI.encode(phone_number)
      driver_lookups.phone_numbers(encoded_phone_number).fetch.tap do
        Rails.logger.info "*** Number Validation Request for #{phone_number}."
      end
    rescue Twilio::REST::RestError => e
      # Twilio Error code 20404 means "Resource not found" which we intrepret to
      # mean the phone number is invalid.
      # https://www.twilio.com/docs/api/errors/20404
      return false if e.code == 20404
    end

    private

    def client
      Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTHTOKEN"])
    end

    def driver_messages
      client.messages
    end

    def driver_lookups
      client.lookups
    end
  end
end
