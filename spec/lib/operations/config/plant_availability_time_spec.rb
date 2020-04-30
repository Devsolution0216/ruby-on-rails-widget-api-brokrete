require 'rails_helper'

describe Operations::Config::PlantAvailabilityTime do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_times) { result[:availability_times] }

  let(:contractor) { create(:contractor) }
  let(:plant_id) { plant1.id }

  let(:payload) {{
    contractor: contractor,
    plant_id: plant_id
  }}

  let(:main_point) { Location.new 0, 0 }

  let(:plant1) {
    create(:plant, location: main_point, delivery_radius: 20)
  }

  let(:plant2) {
    create(:plant, location: main_point, delivery_radius: 5)
  }

  let!(:plant_availability_time1) {
    create(:plant_availability_time, plant: plant1, status: 'opened', value: 'time_value')
  }

  let!(:plant_availability_time2) {
    create(:plant_availability_time, plant: plant2, status: 'closed', value: 'time_value')
  }

  describe "when plant id is correct" do
    it "returns plant availability time" do
      expect(result.success?).to eq(true)
      expect(result_times).to eq([plant_availability_time1])
    end
  end

  describe "when plant id is incorrect" do
    let(:plant_id) { 123 }

    it "returns invalid_fields" do
      expect(result.success?).to eq(false)
      expect(result.code).to eq(:invalid_fields)
    end
  end

  describe "when plant status is" do
    describe "opened" do
      it "returns success" do
        expect(result.success?).to eq(true)

        plant_available_time = result_times[0]
        expect(plant_available_time[:status]).to eq('opened')
      end
    end

    describe "closed" do
      let(:plant_id) { plant2.id }

      it "returns success" do
        expect(result.success?).to eq(true)

        plant_available_time = result_times[0]
        expect(plant_available_time[:status]).to eq('closed')
      end
    end
  end
end
