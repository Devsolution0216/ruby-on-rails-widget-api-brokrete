require 'rails_helper'

describe Operations::Contractor::Identity::Create do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:payload) {{
    contractor: contractor,
    provider: provider,
    uid: uid,
    token: token
  }}

  let!(:contractor) { create(:contractor) }


  describe "with provider `email`" do

    let(:provider) { :email }
    let(:uid) { "test@test.com" }
    let(:token) { "Qwer123$" }

    describe "and email is incorrect" do
      ["test@test", "test", "", "test@test.$$.com"].each do |email|
        describe "`#{email}`" do
          let(:uid) { email }

          it "returns incorrect email error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_email)
          end
        end
      end
    end

    describe "and password is incorrect" do
      ["qwer", "qwer1234", "", "12345678"].each do |password|
        describe "`#{password}`" do
          let(:token) { password }

          it "returns incorrect password error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_password)
          end
        end
      end
    end

    describe "and identity exists" do

      before do
        create(:email_contractor_identity, contractor: contractor, email: uid, password: token)
      end

      describe "with same password" do
        it "returns already exists error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:already_exists)
        end
      end

      describe "with not same password" do
        let(:token) { "SecondPassword123" }

        it "returns already exists error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:already_exists)
        end
      end
    end

    describe "and identity does not exist" do

      it "produces database changes" do
        expect { subject }
          .to  change(ContractorIdentity, :count).by(1)
      end

      it "returns success result" do
        expect(result.success?).to eq(true)
        expect(result[:identity]).not_to be_nil

        identity = result[:identity]

        expect(identity.uid).to eq(uid)
        expect(identity.provider).to eq(:email)
        expect(identity.confirmed?).to eq(false)
      end
    end
  end

  describe "with provider `phone`" do

    let(:provider) { :phone }
    let(:uid) { "+380454454456" }
    let(:token) { "Qwer123$" }

    describe "and phone is incorrect" do
      ["34333", "test", "", "+1234"].each do |phone|
        describe "`#{phone}`" do
          let(:uid) { phone }

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
          let(:token) { password }

          it "returns incorrect password error" do
            expect(result.error?).to eq(true)
            expect(result.code).to eq(:incorrect_password)
          end
        end
      end
    end

    describe "and identity exists" do

      let(:phone) { PhoneNumber.new(uid).value }

      before do
        create(:phone_contractor_identity, contractor: contractor, phone: phone, password: token)
      end

      describe "with same password" do
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

      describe "with not same password" do
        let(:token) { "SecondPassword123" }

        it "returns already exists error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:already_exists)
        end
      end
    end

    describe "and identity does not exist" do

      let(:phone) { PhoneNumber.new(uid).value }

      it "produces database changes" do
        expect { subject }
          .to  change(ContractorIdentity, :count).by(1)
      end

      it "returns success result" do
        expect(result.success?).to eq(true)
        expect(result[:identity]).not_to be_nil

        identity = result[:identity]

        expect(identity.uid).to eq(phone)
        expect(identity.provider).to eq(:phone)
        expect(identity.confirmed?).to eq(false)
      end
    end
  end

end
