require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Order::Create, type: :mutation do

  subject { mutation build_query, context: {current_user: contractor.user} }

  let(:mutation_type) { :orderCreate}
  let(:mutation_response) { gql_response&.data&.[](mutation_type) }
  let(:mutation_success) { mutation_response&.[](:success) || false }
  let(:mutation_errors) { gql_response.errors }

  let(:contractor) { create(:contractor) }

  let(:main_point) { Location.new 50.488473, 30.494346 }

  let(:request_location) { main_point.to_hash }

  let(:product) { create(:product) }

  let(:product_strength_1) { create(:product_strength, product: product, sort_order: 1) }

  let(:product_strength_price_1) {
    create(:product_strength_price, product_strength: product_strength_1, value: 450)
  }

  let(:product_strength_price_id) { product_strength_price_1.id }

  let(:product_decorate_1) { create(:product_decorate, product: product, sort_order: 1) }

  let(:product_decorate_price_1) {
    create(:product_decorate_price, product_decorate: product_decorate_1, value: 150)
  }

  let(:product_decorate_price_id) { product_decorate_price_1.id }

  let(:request_product) {{
      id: product.id,
      strengthPriceId: product_strength_price_id,
      decoratePriceId: product_decorate_price_id
  }}

  let(:quantity) { 100 }

  let(:options_id) { [1,2,3] }
  let(:fees_id) { [4,5,6] }
  let(:trucks) { [7.5,8.5,9.5] }
  let(:delivery_time) { "2019-10-01 12:00:00" }
  let(:time_between_trucks) { 3600 }

  let(:plant1) { create(:plant, location: main_point.clone.translate(2, 2), delivery_radius: 10) }
  let(:plant2) { create(:plant, location: main_point.clone.translate(3, 3), delivery_radius: 10) }

  let!(:plant_product_1) {
    create(:plant_product, plant: plant1, product: product,
           product_decorate: product_decorate_1, product_strength: product_strength_1)
  }
  let!(:plant_product_2) {
    create(:plant_product, plant: plant2, product: product,
           product_decorate: product_decorate_1, product_strength: product_strength_1)
  }

  describe "when order is valid" do
    before do
      create(:plant_product, plant: plant1, product: product)
    end

    it "calls operation and returns success" do
      expect(Operations::Order::Create).to receive(:call).with(
        contractor: contractor,
        product_id: product.id,
        point: Operations::Types::Point.new(**request_location),
        product_strength_price_id: product_strength_price_id,
        product_decorate_price_id: product_decorate_price_id,
        quantity: quantity,
        options_id: options_id,
        fees_id: fees_id,
        trucks: trucks,
        delivery_time: delivery_time,
        time_between_trucks: time_between_trucks
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
    end
  end

  def build_query
    body = <<~GQL

    GQL

    body += <<~GQL
      product: #{serialize(request_product)}
      location: #{serialize(request_location)}
      quantity: #{quantity}
      optionsId: #{serialize(options_id)}
      feesId: #{serialize(fees_id)}
      trucks: #{serialize(trucks)}
      deliveryTime: #{serialize(delivery_time)}
      timeBetweenTrucks: #{time_between_trucks}
    GQL

    request = <<~GQL
      success
    GQL

    <<~GQL
      mutation {
        #{mutation_type}(
          #{body}
        ) {
          #{request}
        }
      }
    GQL
  end
end
