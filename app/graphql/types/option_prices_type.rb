module Types
  class OptionPricesType < BaseObject
    field :option, Types::OptionType, null: false
    field :price, Types::PriceType, null: false
  end
end
