# frozen_string_literal: true

require 'stripe'

module Drivers
  module StripeDriver

    protected

    def charge_create(params)
      Stripe::Charge.create(params, opts)
    end

    private

    def opts
      { api_key: ENV["STRIPE_API_KEY"] }
    end

  end
end
