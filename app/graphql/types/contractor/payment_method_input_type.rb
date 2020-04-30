module Types
  class Contractor::PaymentMethodInputType < BaseInputObject
    argument :provider, String,   required: true
    argument :card_id, Int,       required: false
  end
end
