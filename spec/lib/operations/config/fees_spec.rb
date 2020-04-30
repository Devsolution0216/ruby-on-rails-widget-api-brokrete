require 'rails_helper'

describe Operations::Config::Fees do
  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_fees) { result[:fees] }

  let!(:contractor) { create(:contractor) }

  let(:product1) { create(:product, name: "Product1") }
  let(:product) { product1 }

  let(:payload) {{
    contractor: contractor,
    product_id: product.id,
    point: user_point
  }}

  let(:main_point) { Location.new 0, 0 }
  let(:user_point) { main_point.clone.translate(0, 10) }

  describe "when one fee with one product available" do
    let(:fee_1) {create(:common_fee)}
    let!(:fee_price_1) { create(:fee_price, fee: fee_1, product: product1, value: 46) }

    it "returns one fee" do
      expect(result.success?).to eq(true)
      expect(result_fees).to eq([{
        fee: fee_price_1.fee,
        price: fee_price_1
      }])
    end
  end

end
