require 'rails_helper'

describe Operations::Contractor::Identity::SendReset do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

  describe "when provider is `email`" do
    let(:email) { "test@test.com" }

    let(:payload) {{
      provider: :email,
      uid: email
    }}

    describe "and identity does not exist" do
      it "returns not_found error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "and identity exists" do
      let!(:identity) { create(:email_contractor_identity, contractor: contractor, email: email)}

      # TODO temporary remove
      # describe "and has not confirmed" do
      #   before do
      #     identity.reset_confirm!
      #   end
      #
      #   it "returns not confirmed error" do
      #     expect(result.error?).to eq(true)
      #     expect(result.code).to eq(:not_confirmed)
      #   end
      # end

      describe "and has confirmed" do
        let(:code) { "123456" }

        before do
          identity.confirm!

          allow_any_instance_of(Operations::Contractor::Identity::SendReset)
            .to receive(:code).and_return(code)

          expect_any_instance_of(::Clients::Email::ResetPasswordEmail).to receive(:deliver)
            .with(name: contractor.name, to: email, code: code)
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

          expect(reloaded_identity.reset_token).to eq(code)
          expect(reloaded_identity.reset_token_sent_at).to eq(@time_now)
        end
      end
    end
  end

  describe "when provider is `phone`" do
    let(:phone) { "+380971234567" }

    let(:payload) {{
      provider: :phone,
      uid: phone
    }}

    describe "and identity does not exist" do
      it "returns not_found error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "and identity exists" do
      let!(:identity) { create(:phone_contractor_identity, contractor: contractor, phone: phone)}

      # TODO temporary remove
      # describe "and has not confirmed" do
      #   before do
      #     identity.reset_confirm!
      #   end
      #
      #   it "returns not confirmed error" do
      #     expect(result.error?).to eq(true)
      #     expect(result.code).to eq(:not_confirmed)
      #   end
      # end

      describe "and has confirmed" do
        let(:code) { "123456" }

        before do
          identity.confirm!

          allow_any_instance_of(Operations::Contractor::Identity::SendReset)
            .to receive(:code).and_return(code)

          expect_any_instance_of(::Clients::Sms::ResetPasswordPhone).to receive(:deliver)
            .with(name: contractor.name, to: phone, code: code)
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

          expect(reloaded_identity.reset_token).to eq(code)
          expect(reloaded_identity.reset_token_sent_at).to eq(@time_now)
        end
      end
    end
  end
end
