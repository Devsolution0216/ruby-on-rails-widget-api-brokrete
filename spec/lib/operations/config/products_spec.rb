require 'rails_helper'

describe Operations::Config::Products do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_products) { result[:products] }

  let!(:contractor) { create(:contractor) }

  let(:payload) {{
    contractor: contractor
  }}

  describe "when products are not exist" do
    it "returns empty products list" do
      expect(result.success?).to eq(true)
      expect(result_products).to eq([])
    end
  end

  describe "when products are exist" do

    let(:product1) { create(:product, name: "Product1", sort_order: 1) }
    let(:product2) { create(:product, name: "Product2", sort_order: 2) }
    let(:product3) { create(:product, name: "Product3", sort_order: 3) }
    let(:product4) { create(:product, name: "Product4", sort_order: 4) }

    let(:main_point) { Location.new 0, 0 }

    # right 10km with radius 20
    let(:plant1) {
      create(:plant,
        location: main_point.clone.translate(0, 10),
        delivery_radius: 20
      )
    }

    # top 10km with radius 5
    let(:plant2) {
      create(:plant,
        location: main_point.clone.translate(90, 10),
        delivery_radius: 5
      )
    }

    # top right 10km with radius 10
    let(:plant3) {
      create(:plant,
        location: main_point.clone.translate(45, 10),
        delivery_radius: 7
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

    describe "and no filters was passed" do
      it "returns all products" do
        expect(result.success?).to eq(true)
        expect(result_products).to eq([product1, product2, product3, product4])
      end
    end

    describe "and region is passed" do

      let(:region) {
        delta = main_point.delta(1)

        {
          latitude: main_point.latitude,
          longitude: main_point.longitude,
          delta_latitude: delta.latitude,
          delta_longitude: delta.longitude
        }
      }

      let(:payload) {{
        contractor: contractor,
        region: region
      }}

      it "returns correct products" do
        expect(result.success?).to eq(true)
        expect(result_products).to eq([product1, product2])
      end
    end
  end
end
