require 'rails_helper'

describe Operations::Contractor::Create do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:payload) {{
    identities: payload_identities
  }}

  describe "when identities are not provided" do
    let(:payload_identities) { [] }

    it "returns invalid error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:invalid)

    end
  end

  describe "when identities are provided only with email and password" do
    let(:payload_identities) { [
      {
        provider: :email,
        uid: payload_email,
        token: payload_password
      }
    ] }

    let(:payload_email) { "test@test.com" }
    let(:payload_password) { "Qwer123$" }

    it "returns invalid error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:invalid)
    end
  end

  describe "when identities are provided only with phone and password" do
    let(:payload_identities) { [
      {
        provider: :phone,
        uid: payload_phone,
        token: payload_password
      }
    ] }

    let(:payload_phone) { "+380454454456" }
    let(:payload_password) { "Qwer123$" }

    it "returns invalid error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:invalid)
    end
  end

  describe "when identities are provided with email, phone, password" do
    let(:payload_identities) { [
      {
        provider: :email,
        uid: payload_email,
        token: payload_password
      },
      {
        provider: :phone,
        uid: payload_phone,
        token: payload_password
      }
    ] }

    let(:payload_email) { "test@test.com" }
    let(:payload_password) { "Qwer123$" }
    let(:payload_phone) { "+380454454456" }

    describe "and email is incorrect" do
      ["test@test", "test", "", "test@test.$$.com"].each do |email|
        describe "`#{email}`" do
          let(:payload_email) { email }

          it "returns incorrect email error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_email)
          end
        end
      end
    end

    describe "and phone is incorrect" do
      ["34333", "test", "", "+1234"].each do |phone|
        describe "`#{phone}`" do
          let(:payload_phone) { phone }

          it "returns incorrect phone error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_phone)
          end
        end
      end
    end

    describe "and password is incorrect" do
      ["qwer", "qwer1234", "", "12345678"].each do |password|
        describe "`#{password}`" do
          let(:payload_password) { password }

          it "returns incorrect password error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_password)
          end
        end
      end
    end

    describe "and user exists" do
      describe "with email" do
        let!(:contractor) { create(:contractor, :with_email_identity, email: payload_email, password: password) }

        describe "and same password" do
          let(:password) { payload_password }

          it "returns already exists error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:already_exists)
          end
        end

        describe "and does not same password" do
          let(:password) { "SecondPassword123" }

          it "returns already exists error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:already_exists)
          end
        end
      end

      describe "with phone" do

        let(:phone) { PhoneNumber.new(payload_phone).value }

        let!(:contractor) { create(:contractor, :with_phone_identity, phone: phone, password: password) }

        describe "and same password" do
          let(:password) { payload_password }

          it "does not produce database changes" do
            expect { subject }
              .to  change(Contractor, :count).by(0)
              .and change(User, :count).by(0)
              .and change(ContractorIdentity, :count).by(0)
          end

          it "returns already exists error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:already_exists)
          end
        end

        describe "and does not same password" do
          let(:password) { "SecondPassword123" }

          it "returns already exists error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:already_exists)
          end
        end
      end
    end

    describe "and user does not exist" do

      let(:phone) { PhoneNumber.new(payload_phone).value }

      it "produces database changes" do
        expect { subject }
          .to  change(Contractor, :count).by(1)
          .and change(User, :count).by(1)
          .and change(ContractorIdentity, :count).by(2)
      end

      it "returns success result" do
        expect(result.success?).to eq(true)
        expect(result[:contractor]).not_to be_nil

        expect(result[:contractor].email_identities.first.uid).to eq(payload_email)
        expect(result[:contractor].phone_identities.first.uid).to eq(phone)
      end
    end
  end
end
