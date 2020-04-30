module Types
  class Contractor::PaymentMethodType < BaseObject
    field :provider, String,  null: true
    field :card_id, Int,      null: true
  end
end
