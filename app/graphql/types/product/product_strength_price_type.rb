module Types
  class Product::ProductStrengthPriceType < BaseObject
    field :product_strength, Types::Product::ProductStrengthType, null: false
    field :price, Types::PriceType, null: false
  end
end
