module Operations
  module Contractor
    module Payment
      class Create < Operation

        attribute :contractor

        attribute :source
        attribute :amount
        attribute :currency

        validates :contractor, presence: true

        validates :source, presence: true
        validates :amount, presence: true
        validates :currency, presence: true

        def process

          result = client.charge_create(
            amount: amount * 100,
            currency: currency,
            source: source
          )

          Transaction::Stripe.create(
            contractor: contractor,
            amount: amount,
            currency: currency,
            details: result
          )

          success result

        rescue Stripe::CardError => e
          # Since it's a decline, Stripe::CardError will be caught
          body = e.json_body
          err  = body[:error]

          halt! ::Errors::Custom, err[:code] || err[:type], err[:message]
        rescue Exception => e
          halt! ::Errors::Custom, :invalid, e.inspect
        end

        private

        def client
          ::Clients::Stripe.new
        end

      end
    end
  end
end
