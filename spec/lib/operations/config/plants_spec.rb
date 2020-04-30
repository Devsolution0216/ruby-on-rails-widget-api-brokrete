require 'rails_helper'

describe Operations::Config::Plants do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_plants) { result[:plants] }

  let!(:contractor) { create(:contractor) }

  let(:payload) {{
    contractor: contractor
  }}

  let(:main_point) { Location.new 0, 0 }

  # right 10km with radius 20
  let!(:plant1) {
    create(:plant,
      location: main_point.clone.translate(0, 10),
      delivery_radius: 20
    )
  }

  # top 10km with radius 5
  let!(:plant2) {
    create(:plant,
      location: main_point.clone.translate(90, 10),
      delivery_radius: 5
    )
  }

  # top right 10km with radius 10
  let!(:plant3) {
    create(:plant,
      location: main_point.clone.translate(45, 10),
      delivery_radius: 7
    )
  }


  describe "when filters was passed" do
    it "returns error" do
      expect(result.success?).to eq(false)
      expect(result.code).to eq(:invalid_fields)
    end
  end

  describe "when region is passed" do

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

    it "returns correct plants" do
      expect(result.success?).to eq(true)
      expect(result_plants).to eq([plant1])
    end
  end
end
