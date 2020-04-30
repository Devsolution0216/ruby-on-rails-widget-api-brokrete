module Mutations
  class Order::Validate < ContractorBase
    argument :product, Types::Product::ProductInputType, required: true
    argument :location, Types::LocationInputType, required: true

    def resolve(product:, location:)

      point = Operations::Types::Point.new(location)

      result = Operations::Order::Validate.(
        contractor: contractor,
        product_id: product.id,
        point: point
      )
      raise result if result.error?

      success
    rescue Error => e
      error! e
    end
  end
end
