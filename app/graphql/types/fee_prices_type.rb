module Types
  class FeePricesType < BaseObject
    field :fee, Types::FeeType, null: false
    field :price, Types::PriceType, null: false
  end
end
