module Types
  class Product::ProductDetailsType < BaseObject
    field :service_key, String, null: false
    field :units, String, null: false
  end
end
