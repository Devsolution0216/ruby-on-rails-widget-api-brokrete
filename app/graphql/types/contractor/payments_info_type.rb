module Types
  class Contractor::PaymentsInfoType < BaseObject
    field :saved_cards, [Contractor::PaymentCardType], null: false
    field :default_method, Contractor::PaymentMethodType, null: false

    def saved_cards
      object.payment_cards
    end

    def default_method
      object.default_payment_method
    end
  end
end
