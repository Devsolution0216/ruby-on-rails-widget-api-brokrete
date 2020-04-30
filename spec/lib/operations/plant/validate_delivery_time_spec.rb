require 'rails_helper'

describe Operations::Plant::ValidateDeliveryTime do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

  let(:plant_id) { nil }
  let(:delivery_time) { nil }

  let(:plant1) { create(:plant, location: main_point, delivery_radius: 20) }

  let(:main_point) { Location.new 0, 0 }

  let!(:plant_availability_time1) {
    create(:plant_availability_time,
      plant: plant1,
      status: 'opened',
      value: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;BYHOUR=7,8,9,10,11,12,13,14,15,16,17;BYMINUTE=15,30,45'
    )

    create(:plant_availability_time,
      plant: plant1,
      status: 'opened',
      value: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;BYHOUR=7,8,9,10,11,12,13,14,15,16,17,18;BYMINUTE=0'
    )
  }

  let(:payload) {{
    contractor: contractor,
    plant: plant1,
    delivery_time: delivery_time
  }}

  describe "when delivery time is correct" do
    describe "and equals start of day" do
      let(:delivery_time) { "2019-09-30 07:00:00 UTC" }

      it "returns success" do
        expect(result.success?).to eq(true)
      end
    end

    describe "and equals end of day" do
      let(:delivery_time) { "2019-09-30 18:00:00 UTC" }

      it "returns success" do
        expect(result.success?).to eq(true)
      end
    end

    describe "and equals some time" do
      let(:delivery_time) { "2019-09-30 10:15:00 UTC" }

      it "returns success" do
        expect(result.success?).to eq(true)
      end
    end

    describe "and equals outside of day" do
      let(:delivery_time) { "2019-09-30 20:00:00 UTC" }

      it "returns error" do
        expect(result.success?).to eq(false)
      end
    end
  end
end
