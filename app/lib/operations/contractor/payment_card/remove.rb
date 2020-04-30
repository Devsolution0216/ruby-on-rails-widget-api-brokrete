module Operations
  module Contractor
    module PaymentCard
      class Remove < Operation

        attribute :contractor

        attribute :id

        validates :contractor, presence: true

        validates :id, presence: true

        def process
          contractor.remove_payment_card(id)
          contractor.save!

          success
        end
      end
    end
  end
end
