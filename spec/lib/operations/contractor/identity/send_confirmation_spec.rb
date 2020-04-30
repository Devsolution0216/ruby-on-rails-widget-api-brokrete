require 'rails_helper'

describe Operations::Contractor::Identity::SendConfirmation do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

  let(:payload) {{
    contractor: contractor,
    provider: identity.provider,
    uid: identity.uid
  }}

  describe "when `id` is incorrect" do
    let(:payload) {{
      contractor: contractor,
      id: 12345
    }}

    it "returns invalid_fields error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:invalid_fields)
    end
  end

  describe "when `id` belongs to another contractor" do

    let!(:contractor2) { create(:contractor, :with_email_identity) }

    let(:identity) { contractor2.email_identities.first }

    it "returns invalid_fields error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:invalid_fields)
    end
  end

  describe "when provider is `email`" do
    let!(:identity) { create(:email_contractor_identity, contractor: contractor)}

    describe "and identity has already confirmed" do
      before do
        identity.confirm!
      end

      it "returns invalid error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:invalid)
      end
    end

    describe "and identity can be confirmed" do
      let(:code) { "123456" }

      before do
        allow_any_instance_of(Operations::Contractor::Identity::SendConfirmation::SendEmailConfirmation)
          .to receive(:code).and_return(code)

        expect_any_instance_of(::Clients::Email::ConfirmEmail).to receive(:deliver)
          .with(name: contractor.name, to: identity.uid, code: code)
      end

      it "returns status was_sent" do
        expect(result.error?).to eq(false)
        expect(result[:status]).to eq(:was_sent)
      end

      it "updates identity" do
        @time_now = Time.now
        allow(Time).to receive(:now).and_return(@time_now)

        subject

        expect(result.error?).to eq(false)

        reloaded_identity = identity.reload

        expect(reloaded_identity.confirmation_token).to eq(code)
        expect(reloaded_identity.confirmation_sent_at).to eq(@time_now)
      end

    end
  end

  describe "when provider is `phone`" do
    let(:phone) { "+380971234567" }
    let!(:identity) { create(:phone_contractor_identity, contractor: contractor, phone: phone)}

    describe "and identity has already confirmed" do
      before do
        identity.confirm!
      end

      it "return invalid error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:invalid)
      end
    end

    describe "and identity can be confirmed" do
      let(:code) { "123456" }

      before do
        allow_any_instance_of(Operations::Contractor::Identity::SendConfirmation::SendSmsConfirmation)
          .to receive(:code).and_return(code)

        expect_any_instance_of(::Clients::Sms::ConfirmPhone).to receive(:deliver)
          .with(to: phone, code: code)
      end

      it "returns status was_sent" do
        expect(result.error?).to eq(false)
        expect(result[:status]).to eq(:was_sent)
      end

      it "updates identity" do
        @time_now = Time.now
        allow(Time).to receive(:now).and_return(@time_now)

        subject

        expect(result.error?).to eq(false)

        reloaded_identity = identity.reload

        expect(reloaded_identity.confirmation_token).to eq(code)
        expect(reloaded_identity.confirmation_sent_at).to eq(@time_now)
      end
    end
  end
end
