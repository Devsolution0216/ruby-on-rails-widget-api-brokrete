module Types
  class Product::ProductStrengthType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :details, Types::Product::ProductStrengthDetailsType, null: false
  end
end
