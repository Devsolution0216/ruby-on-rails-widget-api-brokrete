module Types
  class Product::ProductPricesType < BaseObject
    field :product, Types::Product::ProductType, null: false
    field :decorates, [Types::Product::ProductDecoratePriceType], null: false
    field :strengths, [Types::Product::ProductStrengthPriceType], null: false
  end
end
