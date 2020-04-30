module Operations
  module Contractor
    module Payment
      class SetDefaultPaymentMethod < Operation

        attribute :contractor

        attribute :provider
        attribute :card_id

        validates :contractor, presence: true

        validates :provider, presence: true, inclusion: { in: [:card, :native, :paypal, :account] }

        validate :validate_card

        def process
          contractor.set_default_payment_method(
            provider: provider,
            card_id: card&.[](:id)
          )
          contractor.save!

          success
        end

        private

        def is_provider_card?
          provider == :card
        end

        def card
          return nil unless is_provider_card?
          return nil if card_id.blank?

          contractor.get_payment_card card_id
        end

        def validate_card
          if is_provider_card? && card.blank?
            halt! Errors::Custom
          end
        end
      end
    end
  end
end
