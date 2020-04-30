# frozen_string_literal: true

module Clients
  class Stripe < Base
    include ::Drivers::StripeDriver

    def charge_create(amount:, currency:, source:)
      stoplight("Stripe.charge_create") do
        super(
          amount: amount,
          currency: currency,
          source: source
        )
      end
    end

  end
end
