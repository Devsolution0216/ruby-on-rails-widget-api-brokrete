require 'rails_helper'

describe Operations::Config::Options do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_options) { result[:options] }

  let!(:contractor) { create(:contractor) }

  let(:payload) {{
      contractor: contractor,
      product_id: product.id,
      point: user_point
  }}

  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }

  let(:city1) { create(:city) }
  let(:city2) { create(:city) }

  let(:main_point) { Location.new 0, 0 }

  let(:location1) { main_point.clone.translate(0, 10) }
  let(:location3) { main_point.clone.translate(180, 10) }

  let(:plant1) { create(:plant, supplier: supplier1, city: city1, location: location1, delivery_radius: 10) }
  let(:plant2) { create(:plant, supplier: supplier1, city: city2, location: location3, delivery_radius: 10) }

  let(:product) { product1 }

  let(:product1) { create(:product, name: "Product1", sort_order: 1) }
  let(:product2) { create(:product, name: "Product2", sort_order: 2) }

  let(:option_1) { create(:option, name: "option_1", sort_order: 1) }
  let(:option_2) { create(:option, name: "option_2", sort_order: 2) }

  before do
    create(:plant_product, plant: plant1, product: product1)
    create(:plant_product, plant: plant1, product: product2)
  end

  let(:user_point) { main_point.clone.translate(0, 10) }

  describe "when product available in region" do
    let!(:option_price_1) {
      create(:option_price,
        option: option_1,
        supplier: supplier1,
        plant: plant1,
        city: city1,
        value: 100)}

    let!(:option_price_2) {
      create(:option_price,
        option: option_2,
        supplier: supplier1,
        plant: plant2,
        city: city1,
        value: 200)}

    it "returns available option prices" do
      expect(result.success?).to eq(true)
      expect(result_options).to eq([
        { option: option_1, price: option_price_1 },
        { option: option_2, price: option_price_2 }
      ])
    end
  end
end
