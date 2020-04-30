module Mutations
  class Order::Create < ContractorBase

    graphql_name "OrderCreate"

    argument :product, Types::Product::ProductInputType, required: true
    argument :location, Types::LocationInputType, required: true
    argument :quantity, Int, required: true

    argument :options_id, [Int], required: true
    argument :fees_id, [Int], required: true
    argument :trucks, [Float], required: true
    argument :delivery_time, String, required: true
    argument :time_between_trucks, Int, required: true

    def resolve(product:, location:, quantity:, options_id:, fees_id:, trucks:, delivery_time:, time_between_trucks:)
      point = Operations::Types::Point.new(location)

      result = Operations::Order::Create.(
        contractor: contractor,
        product_id: product.id,
        product_strength_price_id: product.strength_price_id,
        product_decorate_price_id: product.decorate_price_id,
        quantity: quantity,
        point: point,
        options_id: options_id,
        fees_id: fees_id,
        trucks: trucks,
        delivery_time: delivery_time,
        time_between_trucks: time_between_trucks
      )
      raise result if result.error?

      success
    rescue Error => e
      error! e
    end
  end
end
