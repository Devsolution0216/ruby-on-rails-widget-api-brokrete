module Types
  class Product::ProductInputType < BaseInputObject
    argument :id, ID, required: true
    argument :decorate_price_id, ID, required: false
    argument :strength_price_id, ID, required: false
  end
end
