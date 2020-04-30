require 'rails_helper'

describe Operations::Config::Cities do

  subject { described_class.(payload) }

  let(:result) { subject }
  let(:result_cities) { result[:cities] }

  let!(:contractor) { create(:contractor) }

  let(:payload) {{
    contractor: contractor
  }}

  let!(:city1) { create(:city) }
  let!(:city2) { create(:city) }

  it "returns list of cities" do
    expect(result.success?).to eq(true)
    expect(result_cities).to eq([city1, city2])
  end

end
