module Types
  class Contractor::UpdatePaymentsInfoInputType < BaseInputObject

    argument :add_payment_card, [Types::Contractor::PaymentCardInputType],        required: false
    argument :remove_payment_card, [Int],                                         required: false
    argument :default_payment_method, Types::Contractor::PaymentMethodInputType,  required: false

  end
end
