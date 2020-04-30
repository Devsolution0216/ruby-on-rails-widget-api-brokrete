module Types
  class Product::ProductType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :details, Types::Product::ProductDetailsType, null: false
  end
end
