require 'rails_helper'

describe Operations::Plant::Find do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:contractor) { create(:contractor) }

  let(:main_point) { Location.new 0, 0 }

  let(:supplier_1) { create(:supplier) }
  let(:supplier_2) { create(:supplier) }

  # right 10km with radius 20
  let!(:plant_1) {
    create(:plant,
      location: main_point.clone.translate(0, 10),
      delivery_radius: 20,
      supplier: supplier_1
    )
  }

  # top 5km with radius 2
  let!(:plant_2) {
    create(:plant,
      location: main_point.clone.translate(90, 5),
      delivery_radius: 2,
      supplier: supplier_1
    )
  }

  # top 8km with radius 10
  let!(:plant_3) {
    create(:plant,
      location: main_point.clone.translate(90, 8),
      delivery_radius: 10,
      supplier: supplier_1
    )
  }

  # top 7km with radius 10
  let!(:plant_4) {
    create(:plant,
      location: main_point.clone.translate(90, 7),
      delivery_radius: 10,
      supplier: supplier_2
    )
  }

  let(:product) { create(:product)}

  let(:product_strength_1) { create(:product_strength, product: product)}
  let(:product_strength_2) { create(:product_strength, product: product)}

  let(:product_strength_price_1) { create(:product_strength_price, product_strength: product_strength_1, supplier: supplier_1, value: 100) }

  before do
    create(:plant_product, plant: plant_1, product_strength: product_strength_1)
    create(:plant_product, plant: plant_2, product_strength: product_strength_1)
    create(:plant_product, plant: plant_4, product_strength: product_strength_1)

    create(:plant_product, plant: plant_1, product_strength: product_strength_2)
    create(:plant_product, plant: plant_2, product_strength: product_strength_2)
    create(:plant_product, plant: plant_3, product_strength: product_strength_2)
    create(:plant_product, plant: plant_4, product_strength: product_strength_2)
  end

  let(:payload) {{
    contractor: contractor,
    point: main_point,
    product_strength_price_id: product_strength_price_1.id
  }}

  it "returns success and correct plant" do
    expect(result.success?).to eq(true)
    expect(result[:plant]).to eq(plant_1)
  end
end
