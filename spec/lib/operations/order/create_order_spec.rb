require 'rails_helper'

describe Operations::Order::Create do

  subject { described_class.(payload) }
  let(:result) { subject }

  let(:contractor) { create(:contractor) }

  let(:product) { create(:product, name: "concrete") }
  let(:product_id) { product.id }

  let(:product_strength1) { create(:product_strength, product: product, sort_order: 1) }

  let(:product_strength_price1) {
    create(:product_strength_price, product_strength: product_strength1, value: 100)
  }

  let(:product_strength_price_id) { product_strength_price1.id }

  let(:product_decorate_1) { create(:product_decorate, product: product, sort_order: 1) }

  let(:product_decorate_price_1) {
    create(:product_decorate_price, product_decorate: product_decorate_1, value: 150)
  }

  let(:product_decorate_price_id) { product_decorate_price_1.id }

  let(:location) { main_point }
  let(:main_point) { Location.new 50.488473, 30.494346 }

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
           product_decorate: product_decorate_1, product_strength: product_strength1)
  }
  let!(:plant_product_2) {
    create(:plant_product, plant: plant2, product: product,
           product_decorate: product_decorate_1, product_strength: product_strength1)
  }

  let(:payload) {{
      contractor: contractor,
      point: location,
      product_id: product_id,
      product_strength_price_id: product_strength_price_id,
      product_decorate_price_id: product_decorate_price_id,
      quantity: quantity,
      options_id: options_id,
      fees_id: fees_id,
      trucks: trucks,
      delivery_time: delivery_time,
      time_between_trucks: time_between_trucks
  }}

  describe "when order created successfully" do
    it "return success" do
      expect(result.success?).to eq(true)
      # TODO
      # expect(Order.all.count).to eq(1)
    end
  end

  describe "when input data is incorrect" do
    describe "when product id is incorrect" do
      let(:product_id) { 123 }

      it "returns invalid_fields error" do
        expect(result.success?).to eq(false)
        expect(result.code).to eq(:invalid_fields)
      end
    end

    describe "when product strength price id is incorrect" do
      let(:product_strength_price_id) { 123 }

      it "returns invalid_fields error" do
        expect(result.success?).to eq(false)
        expect(result.code).to eq(:invalid_fields)
      end
    end
  end

end
