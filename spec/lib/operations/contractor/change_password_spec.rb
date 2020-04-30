require 'rails_helper'

describe Operations::Contractor::ChangePassword do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

  let(:email) { "test@test.com" }
  let(:phone) { "+380971234567" }
  let(:password) { "Qwer123$" }

  let!(:identity_email) { create(:email_contractor_identity, contractor: contractor, email: email, password: password)}
  let!(:identity_phone) { create(:phone_contractor_identity, contractor: contractor, phone: phone, password: password)}

  let(:new_password) { "NewQwe123$" }

  describe "when contractor passed" do

    let(:current_password) { password }

    let(:payload) {{
      contractor: contractor,
      current_token: current_password,
      token: new_password
    }}

    describe "with wrong password" do
      let(:current_password) { "WrongPassword" }

      it "returns wrong password error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:wrong_password)
      end
    end

    ["qwer", "qwer1234", "", "12345678"].each do |password|
      describe "and new password `#{password}` is incorrect" do
        let(:new_password) { password }

        it "returns incorrect password error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:incorrect_password)
        end
      end
    end

    describe "with correct current and new passwords" do
      it "changes all password based identities" do
        expect(result.success?).to eq(true)

        reloaded_identity_email = identity_email.reload
        reloaded_identity_phone = identity_phone.reload

        expect(reloaded_identity_email.token).to eq(new_password)
        expect(reloaded_identity_phone.token).to eq(new_password)
      end
    end
  end

  describe "when reset token passed" do
    let(:reset_token) { "token123" }

    let(:payload) {{
      provider: :email,
      uid: email,
      reset_token: reset_token,
      token: new_password
    }}

    before do
      identity_email.set_reset_token! "token123"
    end

    describe "with wrong token" do
      let(:reset_token) { "WrongToken123" }

      it "returns wrong code error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:wrong_code)
      end
    end

    ["qwer", "qwer1234", "", "12345678"].each do |password|
      describe "and new password `#{password}` is incorrect" do
        let(:new_password) { password }

        it "returns incorrect password error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:incorrect_password)
        end
      end
    end

    describe "with correct reset token and new password" do
      it "changes all password based identities" do
        expect(result.success?).to eq(true)

        reloaded_identity_email = identity_email.reload
        reloaded_identity_phone = identity_phone.reload

        expect(reloaded_identity_email.token).to eq(new_password)
        expect(reloaded_identity_phone.token).to eq(new_password)
      end

      it "clears reset token" do
        expect(result.success?).to eq(true)

        reloaded_identity_email = identity_email.reload

        expect(reloaded_identity_email.reset_token).to be_nil
      end
    end
  end
end
