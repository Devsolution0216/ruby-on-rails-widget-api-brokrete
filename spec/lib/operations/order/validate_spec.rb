require 'rails_helper'

describe Operations::Order::Validate do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:contractor) { create(:contractor) }

  let(:product) { create(:product) }

  let(:location) { main_point }

  let(:main_point) { Location.new 0, 0 }

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

  let(:payload) {{
    contractor: contractor,
    point: location,
    product_id: product.id
  }}

  describe "when order valid" do
    before do
      create(:plant_product, plant: plant1, product: product)
    end
    it "return success" do
      expect(result.success?).to eq(true)
    end
  end

  describe "when no plants products" do
    it "order invalid" do
      expect(result.success?).to eq(false)
    end
  end

  describe "when plants is too far from contractor" do
    before do
      create(:plant_product, plant: plant2, product: product)
    end
    it "order can't be delivered" do
      expect(result.success?).to eq(false)
    end
  end

end