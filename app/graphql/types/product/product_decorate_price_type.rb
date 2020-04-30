module Types
  class Product::ProductDecoratePriceType < BaseObject
    field :product_decorate, Types::Product::ProductDecorateType, null: false
    field :price, Types::PriceType, null: false
  end
end
