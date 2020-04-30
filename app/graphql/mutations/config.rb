module Mutations
  class Config < ContractorBase

    argument :selected_region, Types::RegionInputType, required: false
    argument :selected_location, Types::LocationInputType, required: false

    argument :selected_product, Types::Product::ProductInputType, required: false

    argument :plant_id, ID, required: false

    field :cities, [Types::CityType], null: false
    field :products, [Types::Product::ProductType], null: false
    field :plants, [Types::PlantType], null: false

    field :product_prices, Types::Product::ProductPricesType, null: false
    field :options, [Types::OptionPricesType], null: false
    field :fees, [Types::FeePricesType], null: false

    field :availability_times, [Types::AvailabilityTimeType], null: false

    def resolve(selected_region: nil, selected_location: nil, selected_product: nil, plant_id: nil)

      region = Operations::Types::Region.new(selected_region) if selected_region.present?

      success(
        cities: -> {
          result = Operations::Config::Cities.(contractor: contractor)
          raise result if result.error?
          result[:cities]
        },
        products: -> {
          result = Operations::Config::Products.(
            contractor: contractor,
            region: region
          )
          raise result if result.error?
          result[:products]
        },
        plants: -> {
          result = Operations::Config::Plants.(
            contractor: contractor,
            region: region,
            product_id: selected_product&.id,
          )
          raise result if result.error?
          result[:plants]
        },
        product_prices: -> {
          result = Operations::Config::ProductPrices.(
            contractor: contractor,
            product_id: selected_product&.id,
            point: selected_location
          )
          raise result if result.error?

          { product: result[:product], **result[:prices] }
        },
        options: -> {
          result = Operations::Config::Options.(
            product_id: selected_product&.id,
            point: selected_location
          )
          raise result if result.error?
          result[:options]
        },
        fees: -> {
          result = Operations::Config::Fees.(
            contractor: contractor,
            product_id: selected_product&.id,
            point: selected_location
          )
          raise result if result.error?
          result[:fees]
        },
        availability_times: -> {
          result = Operations::Plant::Find.(
            contractor: contractor,
            product_strength_price_id: selected_product&.strength_price_id,
            point: selected_location,
          )

          raise result if result.error?

          result = Operations::Config::PlantAvailabilityTime.(
            contractor: contractor,
            plant: result[:plant]
          )
          raise result if result.error?

          result[:availability_times]
        }
      )

    rescue Error => e
      error! e
    end
  end
end
