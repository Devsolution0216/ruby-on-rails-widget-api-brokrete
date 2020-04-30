require 'rails_helper'

describe Operations::Contractor::Identity::Remove do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }
  let!(:identity) { create(:email_contractor_identity, contractor: contractor) }

  let!(:contractor2) { create(:contractor) }
  let!(:identity2) { create(:email_contractor_identity, contractor: contractor2) }

  describe "when identity belongs to contractor" do
    let(:payload) {{
      contractor: contractor,
      id: identity.id
    }}

    it "produces database changes" do
      expect { subject }.to  change(ContractorIdentity, :count).by(-1)
    end

    it "removes identity" do
      expect(result.error?).to eq(false)

      expect(contractor.email_identities).to be_empty
    end
  end

  describe "when identity belongs to another contractor" do
    let(:payload) {{
      contractor: contractor2,
      id: identity.id
    }}

    it "does not produce database changes" do
      expect { subject }.to  change(ContractorIdentity, :count).by(0)
    end

    it "returns not_found error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:not_found)
    end
  end

  describe "when identity does not exist" do
    let(:payload) {{
      contractor: contractor,
      id: 12345
    }}

    it "does not produce database changes" do
      expect { subject }.to  change(ContractorIdentity, :count).by(0)
    end

    it "returns not_found error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:not_found)
    end
  end
end
