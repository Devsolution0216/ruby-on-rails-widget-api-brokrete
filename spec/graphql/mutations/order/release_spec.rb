require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Order::Release, type: :mutation do

  subject { mutation build_query, context: {current_user: contractor.user} }

  let(:mutation_type) { :orderRelease }
  let(:mutation_response) { gql_response&.data&.[](mutation_type) }
  let(:mutation_success) { mutation_response&.[](:success) || false }
  let(:mutation_errors) { gql_response.errors }

  let(:contractor) { create(:contractor) }

  let(:order_id) { order1.id }

  let(:city1) { create(:city) }
  let(:product1) { create(:product) }
  let(:product_strength1) { create(:product_strength, product: product1) }

  let(:order1) {
    create(:order, quantity: 30, total_price: 707, latitude: 0, longitude: 0,
           city: city1, product: product1, product_strength: product_strength1)
  }

  describe "when order is valid" do
    it "calls operation and returns success" do
      expect(Operations::Order::Release).to receive(:call).with(
        contractor: contractor,
        order_id: order_id
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
    end
  end

  def build_query
    body = <<~GQL
      orderId: #{serialize(order_id)}
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
