# frozen_string_literal: true

require 'sendgrid-ruby'

module Drivers
  module EmailDriver

    def deliver(options)
      driver_mail_transport.post(request_body: json_payload(options)).tap do |result|
        Rails.logger.info "Sent email to #{options[:to]}, message is #{options[:html_text]}. Result: #{result.inspect}"
      end
    end

    private

    def json_payload(options)
      message = SendGrid::Mail.new
      message.from = SendGrid::Email.new(email: options[:from])
      message.subject = options[:subject]

      personalization = SendGrid::Personalization.new
      personalization.add_to(SendGrid::Email.new(email: options[:to], name: options[:name]))
      message.add_personalization(personalization)

      message.add_content(SendGrid::Content.new(type: 'text/plain', value: options[:plain_text]))
      message.add_content(SendGrid::Content.new(type: 'text/html', value: options[:html_text]))

      message.to_json
    end

    def client
      SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    end

    def driver_mail_transport
      client.client.mail._('send')
    end
  end
end
