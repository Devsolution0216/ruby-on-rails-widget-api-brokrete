require 'rails_helper'

describe Operations::Order::Hold do

  subject { described_class.(payload) }
  let(:result) { subject }

  let(:contractor) { create(:contractor) }
  let(:order_id) { order1.id }

  let(:city1) { create(:city) }
  let(:product1) { create(:product) }
  let(:product_strength1) { create(:product_strength, product: product1) }
  let(:product_decorate11) { create(:product_decorate, product: product1) }

  let(:order1) {
    create(:order, quantity: 18, total_price: 890, latitude: 0, longitude: 0,
           city: city1, product: product1, product_strength: product_strength1)
  }

  let(:payload) {{
    contractor: contractor,
    order_id: order_id
  }}

  describe "when input data correct" do
    it "return success" do
      expect(result.success?).to eq(true)
    end
  end

  describe "when input data incorrect" do
    let(:order_id) { 123 }

    it "return error" do
      expect(result.success?).to eq(false)
    end
  end

end
