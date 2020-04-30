require 'rails_helper'

describe Operations::Contractor::Find do

  subject { described_class.(payload) }

  let(:result) { subject }

  describe "with provider `email`" do

    let(:payload) {{
        provider: :email,
        uid: payload_email,
        token: payload_password
    }}

    let(:payload_email) { "test@test.com" }
    let(:payload_password) { "Qwer123$" }

    describe "and is passed incorrect email" do
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

    describe "when user does not exist" do
      it "returns not found error" do
        expect(Contractor.count).to eq(0)

        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "when user exists" do

      let(:email) { "test@test.com" }

      let!(:contractor) { create(:contractor, :with_email_identity, email: email, password: "Qwer123$") }

      describe "and password matches" do
        let(:payload_password) { "Qwer123$" }

        it "does not produce database changes" do
          expect { subject }
            .to  change(Contractor, :count).by(0)
            .and change(User, :count).by(0)
            .and change(ContractorIdentity, :count).by(0)
        end

        it "returns success result" do
          expect(result.success?).to eq(true)
          expect(result[:contractor]).not_to be_nil
          expect(result[:contractor].id).to eq(contractor.id)

          expect(result[:contractor].email_identities.first.uid).to eq(email)
        end
      end

      describe "and password does not match" do
        let(:payload_password) { "SecondPassword123" }

        it "returns wrong password error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:wrong_password)
        end
      end
    end
  end

  describe "with provider `phone`" do

    let(:payload) {{
        provider: :phone,
        uid: payload_phone,
        token: payload_password
    }}

    let(:payload_phone) { "+380454454456" }
    let(:payload_password) { "Qwer123$" }

    describe "and is passed incorrect phone" do
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

    describe "when user does not exist" do
      it "returns not found error" do
        expect(Contractor.count).to eq(0)

        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "when user exists" do

      let(:phone) { payload_phone }

      let!(:contractor) { create(:contractor, :with_phone_identity, phone: phone, password: "Qwer123$") }

      describe "and password matches" do
        let(:payload_password) { "Qwer123$" }

        it "does not produce database changes" do
          expect { subject }
            .to  change(Contractor, :count).by(0)
            .and change(User, :count).by(0)
            .and change(ContractorIdentity, :count).by(0)
        end

        it "returns success result" do
          expect(result.success?).to eq(true)
          expect(result[:contractor]).not_to be_nil
          expect(result[:contractor].id).to eq(contractor.id)

          expect(result[:contractor].phone_identities.first.uid).to eq(phone)
        end
      end

      describe "and password does not match" do
        let(:payload_password) { "SecondPassword123" }

        it "returns wrong password error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:wrong_password)
        end
      end
    end
  end
end
