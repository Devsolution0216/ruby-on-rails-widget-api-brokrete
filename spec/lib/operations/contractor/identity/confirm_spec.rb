require 'rails_helper'

describe Operations::Contractor::Identity::Confirm do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor, :with_email_identity) }

  describe "when token is not exist" do

    let(:payload) {{
      token: "fake123"
    }}

    it "returns not_found error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:not_found)
    end

  end

  describe "when token exists" do
    let(:token) { "token123" }

    let(:identity) { contractor.email_identities.first }

    let(:payload) {{
      token: token
    }}

    before do
      identity.set_confirmation_token! token
    end

    it "confirms identity" do
      @time_now = Time.now
      allow(Time).to receive(:now).and_return(@time_now)

      expect(result.error?).to eq(false)

      reloaded_identity = identity.reload

      expect(reloaded_identity.confirmation_token).to be_nil
      expect(reloaded_identity.confirmation_sent_at).to be_nil
      expect(reloaded_identity.confirmed_at).to eq(@time_now)
      expect(reloaded_identity.confirmed?).to eq(true)
    end
  end
end
