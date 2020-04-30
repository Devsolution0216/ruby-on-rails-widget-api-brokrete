module Types
  class PriceType < BaseObject
    field :id, ID, null: false
    field :value, Int, null: false
    field :content, String, null: false
  end
end

