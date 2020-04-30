require 'rails_helper'

describe Operations::Contractor::Identity::Find do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

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

    describe "when identity does not exist" do
      it "returns not found error" do
        expect(ContractorIdentity.count).to eq(0)

        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "when identity exists" do

      let(:email) { "test@test.com" }

      let!(:identity) { create(:email_contractor_identity, contractor: contractor, email: email, password: "Qwer123$") }

      describe "and password matches" do
        let(:payload_password) { "Qwer123$" }

        it "does not produce database changes" do
          expect { subject }
            .to change(ContractorIdentity, :count).by(0)
        end

        it "returns success result" do
          expect(result.success?).to eq(true)
          expect(result[:identity]).not_to be_nil
          expect(result[:identity].id).to eq(identity.id)
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

    describe "and `reset_token`" do

      let(:reset_token) { "123456" }

      let(:payload) {{
        provider: :email,
        uid: payload_email,
        reset_token: reset_token
      }}

      describe "when identity does not exist" do
        it "returns not found error" do
          expect(ContractorIdentity.count).to eq(0)

          expect(result.error?).to eq(true)
          expect(result.code).to eq(:not_found)
        end
      end

      describe "when identity exists" do

        let(:email) { "test@test.com" }

        let!(:identity) { create(:email_contractor_identity, contractor: contractor, email: email, password: "Qwer123$") }

        describe "and has reset token" do

          before do
            identity.set_reset_token! reset_token
          end

          it "does not produce database changes" do
            expect { subject }
              .to change(ContractorIdentity, :count).by(0)
          end

          it "returns success result" do
            expect(result.success?).to eq(true)
            expect(result[:identity]).not_to be_nil
            expect(result[:identity].id).to eq(identity.id)
          end
        end

        describe "and has another reset token" do
          before do
            identity.set_reset_token! "other123"
          end

          it "returns wrong password error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:wrong_code)
          end
        end

        describe "and does not have reset token" do
          before do
            identity.clear_reset_token!
          end

          it "returns wrong password error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:wrong_code)
          end
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
        expect(ContractorIdentity.count).to eq(0)

        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end
    end

    describe "when user exists" do

      let(:phone) { payload_phone }

      let!(:identity) { create(:phone_contractor_identity, contractor: contractor, phone: phone, password: "Qwer123$") }

      describe "and password matches" do
        let(:payload_password) { "Qwer123$" }

        it "does not produce database changes" do
          expect { subject }
            .to change(ContractorIdentity, :count).by(0)
        end

        it "returns success result" do
          expect(result.success?).to eq(true)
          expect(result[:identity]).not_to be_nil
          expect(result[:identity].id).to eq(identity.id)
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
