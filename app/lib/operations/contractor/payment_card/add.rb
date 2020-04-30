module Operations
  module Contractor
    module PaymentCard
      class Add < Operation

        attribute :contractor

        attribute :card

        validates :contractor, presence: true

        validates :card, presence: true

        def process
          contractor.add_payment_card(card)

          contractor.save!

          success
        end
      end
    end
  end
end
