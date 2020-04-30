require 'rails_helper'

describe Operations::Config::ProductPrices do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_prices) { result[:prices] }

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
  let(:location2) { main_point.clone.translate(90, 10) }
  let(:location3) { main_point.clone.translate(180, 10) }
  let(:location4) { main_point.clone.translate(270, 10) }

  let(:plant1) { create(:plant, supplier: supplier1, city: city1, location: location1, delivery_radius: 10) }
  let(:plant2) { create(:plant, supplier: supplier1, city: city2, location: location3, delivery_radius: 10) }
  let(:plant3) { create(:plant, supplier: supplier2, city: city1, location: location2, delivery_radius: 10) }
  let(:plant4) { create(:plant, supplier: supplier2, city: city2, location: location4, delivery_radius: 10) }

  let(:product) { create(:product) }

  let(:product_decorate1) { create(:product_decorate, product: product, sort_order: 1) }
  let(:product_decorate2) { create(:product_decorate, product: product, sort_order: 2) }

  let(:product_strength1) { create(:product_strength, product: product, sort_order: 1) }
  let(:product_strength2) { create(:product_strength, product: product, sort_order: 2) }

  before do
    [plant1, plant2, plant3, plant4].each do |plant|
      [
        { product_decorate: product_decorate1 },
        { product_decorate: product_decorate2 },
        { product_strength: product_strength1 },
        { product_strength: product_strength2 }
      ].each do |options|
        create(:plant_product, plant: plant, product: product, **options)
      end
    end
  end

  let(:user_point) { main_point.clone.translate(45, 10) }

  describe "when each plant has price list" do
    before do
      [plant1, plant2, plant3, plant4].each_with_index do |plant, plant_index|
        [product_decorate1, product_decorate2].each_with_index do |product_decorate, product_decorate_index|
          create(:product_decorate_price,
            product_decorate: product_decorate,
            plant: plant,
            value: (plant_index+1)*100 + (product_decorate_index+1)*10)
        end

        [product_strength1, product_strength2].each_with_index do |product_strength, product_strength_index|
          create(:product_strength_price,
            product_strength: product_strength,
            plant: plant,
            value: (plant_index+1)*100 + (product_strength_index+1))
        end
      end
    end

    it "returns success with available prices" do
      expect(result.success?).to eq(true)
      expect(result_prices).to eq({
        decorates: [{
          product_decorate: product_decorate1,
          price: ProductDecoratePrice.find_by(value: 110)
        }, {
          product_decorate: product_decorate2,
          price: ProductDecoratePrice.find_by(value: 120)
        }],
        strengths: [{
          product_strength: product_strength1,
          price: ProductStrengthPrice.find_by(value: 101)
        }, {
          product_strength: product_strength2,
          price: ProductStrengthPrice.find_by(value: 102)
        }]
      })
    end
  end

  describe "when suppliers have general prices" do
    before do
      [product_strength1, product_strength2].each_with_index do |product_strength, product_strength_index|
        create(:product_strength_price,
          product_strength: product_strength,
          supplier: supplier1,
          value: 100 + (product_strength_index+1))

        create(:product_strength_price,
          product_strength: product_strength,
          supplier: supplier2,
          value: 200 + (product_strength_index+1))
      end
    end

    describe "and one supplier has special price for city" do
      before do
        [product_strength1, product_strength2].each_with_index do |product_strength, product_strength_index|
          create(:product_strength_price,
            product_strength: product_strength,
            supplier: supplier2,
            city: city1,
            value: 50 + (product_strength_index+1))
        end
      end

      describe "and another supplier has special price for contractor" do
        before do
          [product_strength2].each_with_index do |product_strength, product_strength_index|
            create(:product_strength_price,
              product_strength: product_strength,
              supplier: supplier1,
              contractor: contractor,
              value: 10 + (product_strength_index+1))
          end
        end

        it "returns success with available prices" do
          expect(result.success?).to eq(true)
          expect(result_prices).to eq({
            decorates: [],
            strengths: [{
              product_strength: product_strength1,
              price: ProductStrengthPrice.find_by(value: 51)
            }, {
              product_strength: product_strength2,
              price: ProductStrengthPrice.find_by(value: 11)
            }]
          })
        end
      end
    end
  end
end
