module Types
  class Product::ProductDecorateType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :details, Types::Product::ProductDecorateDetailsType, null: false
  end
end
