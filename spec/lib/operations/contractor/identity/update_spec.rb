require 'rails_helper'

describe Operations::Contractor::Identity::Update do

  subject { described_class.(payload) }

  let(:result) { subject }

  let!(:contractor) { create(:contractor) }

  describe "when identity does not exist" do
    let(:payload) {{
      contractor: contractor,
      id: 123,
      new_uid: "fake"
    }}

    it "return not_found error" do
      expect(result.error?).to eq(true)
      expect(result.code).to eq(:not_found)
    end
  end

  describe "when identity exists" do
    describe "and belongs to another contractor" do
      let!(:contractor2) { create(:contractor, :with_email_identity) }

      let(:payload) {{
        contractor: contractor,
        id: contractor2.identities.first.id,
        new_uid: "fake"
      }}

      it "return not_found error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:not_found)
      end

    end

    describe "and uid and token are not provided" do
      let!(:identity) { create(:email_contractor_identity, contractor: contractor)}

      let(:payload) {{
        contractor: contractor,
        id: identity.id
      }}

      it "return invalid error" do
        expect(result.error?).to eq(true)
        expect(result.code).to eq(:invalid)
      end
    end

    describe "with provider `email`" do
      let!(:identity) { create(:email_contractor_identity, contractor: contractor)}

      describe "and is passed incorrect email" do
        ["test@test", "test", "test@test.$$.com"].each do |email|
          describe "`#{email}`" do
            let(:payload) {{
              contractor: contractor,
              id: identity.id,
              new_uid: email
            }}

            it "returns incorrect email error" do
              expect(result.error?).to eq(true)
              expect(result.code).to eq(:incorrect_email)
            end
          end
        end
      end

      describe "and is passed incorrect password" do
        ["qwer", "qwer1234", "12345678"].each do |password|
          describe "`#{password}`" do
            let(:payload) {{
              contractor: contractor,
              id: identity.id,
              new_token: password
            }}

            it "returns incorrect password error" do
              expect(result.error?).to eq(true)
              expect(result.code).to eq(:incorrect_password)
            end
          end
        end
      end

      describe "and another identity exists with same uid" do
        let!(:contractor2) { create(:contractor, :with_email_identity) }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_uid: contractor2.identities.first.uid
        }}

        it "returns already_exists error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:already_exists)
        end
      end

      describe "and is passed correct email" do
        let(:email) { "new_email@test.com" }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_uid: email
        }}

        it "updates identity" do
          expect(result.success?).to eq(true)

          reloaded_identity = identity.reload

          expect(reloaded_identity.uid).to eq(email)
        end

        it "updates confirmed status of identity" do
          identity.confirm!

          subject

          reloaded_identity = identity.reload

          expect(reloaded_identity.confirmed?).to eq(false)
        end
      end

      describe "and is passed correct password" do
        let(:password) { "Qwer123$New" }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_token: password
        }}

        it "updates identity" do
          expect(result.success?).to eq(true)

          reloaded_identity = identity.reload

          expect(reloaded_identity.token).to eq(password)
        end

        it "does not updates confirmed status of identity" do
          identity.confirm!

          subject

          reloaded_identity = identity.reload

          expect(reloaded_identity.confirmed?).to eq(true)
        end
      end
    end

    describe "with provide `phone`" do
      let!(:identity) { create(:phone_contractor_identity, contractor: contractor)}

      describe "and is passed incorrect phone" do
        ["34333", "test", "+1234"].each do |phone|
          describe "`#{phone}`" do
            let(:payload) {{
              contractor: contractor,
              id: identity.id,
              new_uid: phone
            }}

            it "returns incorrect phone error" do
              expect(result.error?).to eq(true)
              expect(result.code).to eq(:incorrect_phone)
            end
          end
        end
      end

      describe "and is passed incorrect password" do
        ["qwer", "qwer1234", "12345678"].each do |password|
          describe "`#{password}`" do
            let(:payload) {{
              contractor: contractor,
              id: identity.id,
              new_token: password
            }}

            it "returns incorrect password error" do
              expect(result.error?).to eq(true)
              expect(result.code).to eq(:incorrect_password)
            end
          end
        end
      end

      describe "and another identity exists with same uid" do
        let!(:contractor2) { create(:contractor, :with_phone_identity, phone: "+380971231212") }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_uid: contractor2.identities.first.uid
        }}

        it "returns already_exists error" do
          expect(result.error?).to eq(true)
          expect(result.code).to eq(:already_exists)
        end
      end

      describe "and is passed correct phone" do
        let(:phone) { "+380974342321" }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_uid: phone
        }}

        it "updates identity" do
          expect(result.success?).to eq(true)

          reloaded_identity = identity.reload

          expect(reloaded_identity.uid).to eq(phone)
        end

        it "updates confirmed status of identity" do
          identity.confirm!

          subject

          reloaded_identity = identity.reload

          expect(reloaded_identity.confirmed?).to eq(false)
        end
      end

      describe "and is passed correct password" do
        let(:password) { "Qwer123$New" }

        let(:payload) {{
          contractor: contractor,
          id: identity.id,
          new_token: password
        }}

        it "updates identity" do
          expect(result.success?).to eq(true)

          reloaded_identity = identity.reload

          expect(reloaded_identity.token).to eq(password)
        end

        it "does not updates confirmed status of identity" do
          identity.confirm!

          subject

          reloaded_identity = identity.reload

          expect(reloaded_identity.confirmed?).to eq(true)
        end
      end
    end
  end
end
