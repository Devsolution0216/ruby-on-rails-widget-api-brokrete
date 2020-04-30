require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Config, type: :mutation do

  subject { mutation build_query, context: {current_user: contractor.user} }

  let(:mutation_type) { :config }
  let(:mutation_response) { gql_response&.data&.[](mutation_type) }
  let(:mutation_success) { mutation_response&.[](:success) || false }
  let(:mutation_errors) { gql_response.errors }

  let(:contractor) { create(:contractor) }

  let(:selected_region) { nil }
  let(:selected_location) { nil }
  let(:selected_product) { nil }

  let(:request_cities) { false }
  let(:request_products) { false }
  let(:request_plants) { false }
  let(:request_product_prices) { false }
  let(:request_options) { false }
  let(:request_fee_prices) { false }
  let(:request_availability_times) { false }

  let(:product1) { create(:product, name: "Product1", sort_order: 1) }
  let(:product2) { create(:product, name: "Product2", sort_order: 2) }
  let(:product3) { create(:product, name: "Product3", sort_order: 3) }
  let(:product4) { create(:product, name: "Product4", sort_order: 4) }

  let!(:city1) { create(:city) }
  let!(:city2) { create(:city) }

  let(:main_point) { Location.new 0, 0 }

  let(:plant_id) { nil }

  # right 10km with radius 20
  let(:plant1) {
    create(:plant,
      location: main_point.clone.translate(0, 10),
      delivery_radius: 20,
      city: city1
    )
  }

  # top 10km with radius 5
  let(:plant2) {
    create(:plant,
      location: main_point.clone.translate(90, 10),
      delivery_radius: 5,
      city: city2
    )
  }

  # top right 10km with radius 10
  let(:plant3) {
    create(:plant,
      location: main_point.clone.translate(45, 10),
      delivery_radius: 7,
      city: city1
    )
  }

  # top 10km right 10km with radius 20
  let(:plant4) {
    create(:plant,
           location: main_point.clone.translate(10, 10),
           delivery_radius: 20,
           city: city2
    )
  }

  before do
    create(:plant_product, plant: plant1, product: product1)
    create(:plant_product, plant: plant1, product: product2)

    create(:plant_product, plant: plant2, product: product1)
    create(:plant_product, plant: plant2, product: product3)

    create(:plant_product, plant: plant3, product: product4)
    create(:plant_product, plant: plant3, product: product2)
  end

  describe "#cities" do
    let(:request_cities) { true }

    it "calls operation and returns success" do
      expect(Operations::Config::Cities).to receive(:call).with(
        contractor: contractor
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
      expect(mutation_response[:cities]).to eq([city1, city2].map {|value| {id: value.id, name: value.name}})
    end
  end

  describe "#plants" do
    let(:request_plants) { true }

    describe "with selected region" do
      let(:selected_region) {{
          latitude: main_point.latitude,
          longitude: main_point.longitude,
          radius: 1
        }}

      it "calls operation and returns success" do
        expect(Operations::Config::Plants).to receive(:call).with(
          contractor: contractor,
          product_id: nil,
          region: Operations::Types::Region.new(**(selected_region.deep_transform_keys { |key| key.to_s.underscore.to_sym }))
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:plants]).to eq([plant1].map {|value| {id: value.id, name: value.name}})
      end
    end

    describe "with selected region and product" do
      let(:selected_region) {{
        latitude: main_point.latitude,
        longitude: main_point.longitude,
        radius: 4
      }}

      let(:selected_product) {{
        id: product4.id
      }}

      it "calls operation and returns success" do
        expect(Operations::Config::Plants).to receive(:call).with(
          contractor: contractor,
          product_id: product4.id,
          region: Operations::Types::Region.new(**(selected_region.deep_transform_keys { |key| key.to_s.underscore.to_sym }))
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:plants]).to eq([plant3].map {|value| {id: value.id, name: value.name}})
      end
    end
  end

  describe "#products" do
    let(:request_products) { true }

    describe "with selected region" do
      let(:selected_region) {
        delta = main_point.delta(1)

        {
          latitude: main_point.latitude,
          longitude: main_point.longitude,
          deltaLatitude: delta.latitude,
          deltaLongitude: delta.longitude
        }
      }

      it "calls operation and returns success" do
        expect(Operations::Config::Products).to receive(:call).with(
          contractor: contractor,
          region: Operations::Types::Region.new(**(selected_region.deep_transform_keys { |key| key.to_s.underscore.to_sym }))
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:products]).to eq([product1, product2].map {|value| {id: value.id, name: value.name}})
      end
    end
  end

  describe "#product_prices" do
    let(:selected_location) { main_point.to_hash }
    let(:request_product_prices) { true }

    let(:product1_decorates) { (1..2).map { |value| create(:product_decorate, product: product1, sort_order: value) } }
    let(:product2_decorates) { (1..2).map { |value| create(:product_decorate, product: product2, sort_order: value) } }

    let(:product1_strength) { (1..2).map { |value| create(:product_strength, product: product1, sort_order: value) } }
    let(:product2_strength) { (1..2).map { |value| create(:product_strength, product: product2, sort_order: value) } }

    before do
      PlantProduct.destroy_all
      ProductDecoratePrice.destroy_all
      ProductStrengthPrice.destroy_all

      [plant1, plant2].each_with_index do |plant, plant_index|

        [product1_decorates, product2_decorates][plant_index].each do |product_decorate|
          create(:plant_product, plant: plant, product_decorate: product_decorate)
          create(:product_decorate_price,
            product_decorate: product_decorate,
            plant: plant,
            value: 100,
            content: 'unit')
        end

        [product1_strength, product2_strength][plant_index].each do |product_strength|
          create(:plant_product, plant: plant, product_strength: product_strength)
          create(:product_strength_price,
            product_strength: product_strength,
            plant: plant,
            value: 10,
            content: 'unit')
        end
      end
    end

    describe "when product unavailable in region" do
      let(:selected_product) {{
        id: product2.id
      }}

      it "returns empty prices" do
        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:productPrices]).to eq({
          product: {id: product2.id, name: product2.name},
          decorates: [],
          strengths: []
        })
      end
    end

    describe "when product available in region" do
      let(:selected_product) {{
        id: product1.id
      }}

      it "returns available prices" do
        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:productPrices]).to eq({
          product: {id: product1.id, name: product1.name},
          decorates: product1_decorates.map {|product_decorate| {
            productDecorate: {id: product_decorate.id, name: product_decorate.name},
            price: {
              id: ProductDecoratePrice.find_by(target: product_decorate, plant: plant1).id,
              value: 100,
              content: 'unit'
            }
          }},
          strengths: product1_strength.map {|product_strength| {
            productStrength: {id: product_strength.id, name: product_strength.name},
            price: {
              id: ProductStrengthPrice.find_by(target: product_strength, plant: plant1).id,
              value: 10,
              content: 'unit'
            }
          }}
        })
      end
    end
  end

  describe "#option_prices" do
    let(:selected_location) { main_point.to_hash }
    let(:request_options) { true }

    let(:option_1) { create(:option, name: "option_1") }
    let(:option_2) { create(:option, name: "option_2") }
    let(:option_3) { create(:option, name: "option_3") }

    let!(:option_price_1) {
      create(:option_price,
              option: option_1,
              supplier: create(:supplier),
              plant: plant1,
              city: city1,
              value: 100,
              content: 'unit')}

    let!(:option_price_2) {
      create(:option_price,
              option: option_2,
              supplier: create(:supplier),
              plant: plant2,
              city: city1,
              value: 200,
              content: 'unit')}

    let!(:option_price_3) {
      create(:option_price,
              option: option_3,
              supplier: create(:supplier),
              plant: plant4,
              city: city2,
              value: 300,
              content: 'unit')}

    describe "when product unavailable in region" do
      let(:selected_product) {{
        id: product3.id
      }}

      it "returns empty prices" do
        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:options]).to eq([])
      end
    end

    describe "when product available in region" do
      let(:selected_product) {{
        id: product1.id
      }}

      it "returns available option prices" do
        subject

        expect(mutation_success).to eq(true)
        expect(mutation_response[:options]).to eq([
          {option: { id: option_1.id, name: option_1.name },
           price: { id: option_price_1.id, value: option_price_1.value, content: 'unit' }},
          {option: { id: option_2.id, name: option_2.name },
           price: { id: option_price_2.id, value: option_price_2.value, content: 'unit' }}
        ])
      end
    end

  end

  describe "#fees" do
    let(:selected_location) { main_point.to_hash }
    let(:request_fee_prices) { true }

    let(:fee_1) {create(:common_fee)}
    let!(:fee_price_1) { create(:fee_price, fee: fee_1, city: city1, value: 46, content: 'unit') }

    describe "when product available in region" do
      let(:selected_product) {{
        id: product1.id
      }}

      it "returns prices" do
        subject
        expect(mutation_success).to eq(true)
        expect(mutation_response[:fees]).to eq([{
          fee: {id: fee_price_1.fee.id, name: fee_price_1.fee.name, type: fee_price_1.fee.type},
          price: {id: fee_price_1.id, value: fee_price_1.value, content: 'unit'}
        }])
      end
    end

    describe "when product unavailable in region" do
      let(:selected_product) {{
        id: product3.id
      }}

      it "returns empty prices" do
        subject
        expect(mutation_success).to eq(true)
        expect(mutation_response[:fees]).to eq([])
      end
    end

    describe "when one fee with one product available" do
      let(:product5) { create(:product, name: "Product5") }
      let(:selected_product) {{
        id: product5.id
      }}
      let!(:fee_price_2) { create(:fee_price, fee: fee_1, product: product5, value: 88, content: 'unit') }

      it "returns one price" do
        subject
        expect(mutation_success).to eq(true)
        expect(mutation_response[:fees]).to eq([{
          fee: {id: fee_price_2.fee.id, name: fee_price_2.fee.name, type: fee_price_2.fee.type},
          price: {id: fee_price_2.id, value: fee_price_2.value, content: 'unit'}
        }])
      end
    end

  end

  describe "#availability times" do
    let(:request_availability_times) { true }

    let(:selected_location) { main_point.to_hash }
    let(:selected_product) {{
      id: product1.id,
      strengthPriceId: product_strength_price.id
    }}

    let(:product_strength) { create(:product_strength, product: product1) }

    let!(:product_strength_price) {
      create(:product_strength_price,
        product_strength: product_strength,
        plant: plant1,
        value: 10,
        content: 'unit')
    }

    let!(:plant_availability_time1) {
      create(:plant_availability_time, plant: plant1, status: 'opened', value: 'time_value')
    }

    it "calls operation and returns success" do
      expect(Operations::Config::PlantAvailabilityTime).to receive(:call).with(
        contractor: contractor,
        plant: plant1
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
      expect(mutation_response[:availabilityTimes]).to eq([{
        status: plant_availability_time1.status,
        value: plant_availability_time1.value
      }])
    end
  end

  def build_query
    body = <<~GQL
    GQL

    if selected_region.present?
      body += <<~GQL
        selectedRegion: #{serialize(selected_region)}
      GQL
    end

    if selected_location.present?
      body += <<~GQL
        selectedLocation: #{serialize(selected_location)}
      GQL
    end

    if selected_product.present?
      body += <<~GQL
        selectedProduct: #{serialize(selected_product)}
      GQL
    end

    if plant_id.present?
      body += <<~GQL
        plantId: #{serialize(plant_id)}
      GQL
    end

    request = <<~GQL
      success
    GQL

    if request_cities.present?
      request += <<~GQL
        cities {
          id
          name
        }
      GQL
    end

    if request_products.present?
      request += <<~GQL
        products {
          id
          name
        }
      GQL
    end

    if request_plants.present?
      request += <<~GQL
        plants {
          id
          name
        }
      GQL
    end

    if request_product_prices.present?
      request += <<~GQL
        productPrices {
          product {
            id
            name
          }
          decorates {
            productDecorate {
              id
              name
            }
            price {
              id
              value
              content
            }
          }
          strengths {
            productStrength {
              id
              name
            }
            price {
              id
              value
              content
            }
          }
          
        }
      GQL
    end

    if request_options.present?
      request += <<~GQL
        options {
          option {
            id
            name
          }
          price {
            id
            value
            content
          }
        }
      GQL
    end

    if request_fee_prices.present?
      request += <<~GQL
        fees {
          fee {
            id
            name
            type
          }
          price {
            id
            value
            content
          }
        }
      GQL
    end

    if request_availability_times.present?
      request += <<~GQL
        availabilityTimes {
          status
          value
        }
      GQL
    end

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
