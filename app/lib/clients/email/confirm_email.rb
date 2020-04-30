# frozen_string_literal: true

module Clients::Email
  class ConfirmEmail < Base

    def deliver(name:, to:, code:)
      super(
        from: from_address,
        name: name,
        to: to,
        subject: subject,
        plain_text: plain_text(code),
        html_text: html_text(code)
      )
    end

    private

    def html_text(code)
      <<~HTML
        <p>Security code: #{code}</p>
      HTML
    end

    def plain_text(code)
      <<~PLAIN
        Security code: #{code}
      PLAIN
    end

    def from_address
      ENV["CONFIRMATION_EMAIL_FROM"]
    end

    def subject
      'Confirm your email'
    end
  end
end
