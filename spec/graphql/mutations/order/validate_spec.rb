require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Order::Validate, type: :mutation do

  subject { mutation build_query, context: {current_user: contractor.user} }

  let(:mutation_type) { :orderValidate }
  let(:mutation_response) { gql_response&.data&.[](mutation_type) }
  let(:mutation_success) { mutation_response&.[](:success) || false }
  let(:mutation_errors) { gql_response.errors }

  let(:contractor) { create(:contractor) }

  let(:main_point) { Location.new 0, 0 }

  let(:request_location) { main_point.to_hash }

  let!(:product) { create(:product) }

  let(:request_product) {{
      id: product.id
  }}

  let(:plant1) {
    create(:plant,
      location: main_point.clone.translate(0, 0),
      delivery_radius: 10
    )
  }

  let(:plant2) {
    create(:plant,
      location: main_point.clone.translate(60, 60),
      delivery_radius: 20
    )
  }

  describe "when order is valid" do
    before do
      create(:plant_product, plant: plant1, product: product)
    end

    it "calls operation and returns success" do
      expect(Operations::Order::Validate).to receive(:call).with(
        contractor: contractor,
         product_id: product.id,
         point: Operations::Types::Point.new(**request_location)
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
    end
  end

  describe "when order is invalid" do

    describe "because no product delivery to contractors location" do
      before do
        create(:plant_product, plant: plant2, product: product)
      end

      it "calls operation and returns error" do
        expect(Operations::Order::Validate).to receive(:call).with(
          contractor: contractor,
          product_id: product.id,
          point: Operations::Types::Point.new(**request_location)
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(false)
      end
    end

  end

  def build_query
    body = <<~GQL

    GQL

    body += <<~GQL
      product: #{serialize(request_product)}
      location: #{serialize(request_location)}
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
