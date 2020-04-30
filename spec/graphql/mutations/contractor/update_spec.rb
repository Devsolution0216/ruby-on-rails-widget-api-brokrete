require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Contractor::Update, type: :mutation do

  subject { mutation build_query, context: {current_user: contractor.user} }

  let(:mutation_type) { :contractorUpdate }
  let(:mutation_response) { gql_response.data[mutation_type] }
  let(:mutation_success) { mutation_response[:success]}
  let(:mutation_errors) { gql_response.errors }

  let(:identity_payload) { nil }
  let(:info_payload) { nil }
  let(:payments_info_payload) { nil }

  let(:contractor) { create(:contractor) }

  describe "#identity" do
    let(:change_payload) { [] }
    let(:add_payload) { [] }
    let(:remove_payload) { [] }

    let(:identity_payload) {{
      change: change_payload,
      add: add_payload,
      remove: remove_payload
    }}

    let(:email) { "test@test.com" }
    let(:phone) { "+380971234567" }
    let(:password) { "Qwer123$" }

    let!(:email_identity) { create(:email_contractor_identity, contractor: contractor, email: email, password: password)}
    let!(:phone_identity) { create(:phone_contractor_identity, contractor: contractor, phone: phone, password: password)}

    describe "change email" do
      let(:new_email) { "new@test.com" }

      let(:email_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "email" }
      }

      let(:change_payload) {[{
        email: {
          from: email,
          to: new_email
        }
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Update).to receive(:call).with(
          contractor: contractor,
          provider: :email,
          uid: email,
          new_uid: new_email
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(email_identities_response).to eq([{provider: "email", uid: new_email}])

        expect(email_identity.reload.uid).to eq(new_email)
        expect(email_identity.reload.token).to eq(password)
      end
    end

    describe "change phone" do
      let(:new_phone) { "+380979876543" }

      let(:phone_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "phone" }
      }

      let(:change_payload) {[{
        phone: {
          from: phone,
          to: new_phone
        }
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Update).to receive(:call).with(
          contractor: contractor,
          provider: :phone,
          uid: phone,
          new_uid: new_phone
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(phone_identities_response).to eq([{provider: "phone", uid: Phonelib.parse(new_phone).e164}])

        expect(phone_identity.reload.uid).to eq(Phonelib.parse(new_phone).e164)
        expect(email_identity.reload.token).to eq(password)
      end
    end

    describe "change password" do
      let(:new_password) { "NewQwer123$" }

      let(:change_payload) {[{
        password: {
          from: password,
          to: new_password
        }
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::ChangePassword).to receive(:call).with(
          contractor: contractor,
          current_token: password,
          token: new_password
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)

        expect(email_identity.reload.token).to eq(new_password)
        expect(phone_identity.reload.token).to eq(new_password)
      end
    end

    describe "add email" do
      let(:new_email) { "new@test.com" }

      let(:email_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "email" }
      }

      let(:add_payload) {[{
        email: new_email
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Create).to receive(:call).with(
          contractor: contractor,
          provider: :email,
          uid: new_email
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(email_identities_response).to eq([{provider: "email", uid: email}, {provider: "email", uid: new_email}])

        new_email_identity = contractor.email_identities.find_by(uid: new_email)
        expect(new_email_identity.confirmed?).to eq(false)
        expect(new_email_identity.token).to eq(password)
      end
    end

    describe "add phone" do
      let(:new_phone) { "+380979876543" }

      let(:phone_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "phone" }
      }

      let(:add_payload) {[{
        phone: new_phone
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Create).to receive(:call).with(
          contractor: contractor,
          provider: :phone,
          uid: new_phone
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(phone_identities_response).to eq([
          {provider: "phone", uid: Phonelib.parse(phone).e164},
          {provider: "phone", uid: Phonelib.parse(new_phone).e164}
        ])

        new_phone_identity = contractor.phone_identities.find_by(uid: new_phone)
        expect(new_phone_identity.confirmed?).to eq(false)
        expect(new_phone_identity.token).to eq(password)
      end
    end

    describe "remove email" do
      let(:email_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "email" }
      }

      let(:remove_payload) {[{
        email: email
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Remove).to receive(:call).with(
          contractor: contractor,
          provider: :email,
          uid: email
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(email_identities_response).to eq([])

        expect(contractor.reload.email_identities.count).to eq(0)
      end
    end

    describe "remove phone" do
      let(:phone_identities_response) {
        mutation_response[:contractor][:identities].filter { |item| item[:provider] == "phone" }
      }

      let(:remove_payload) {[{
        phone: phone
      }]}

      it "calls operation and returns success" do
        expect(Operations::Contractor::Identity::Remove).to receive(:call).with(
          contractor: contractor,
          provider: :phone,
          uid: phone
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(phone_identities_response).to eq([])

        expect(contractor.reload.phone_identities.count).to eq(0)
      end
    end
  end

  describe "#info" do
    let(:info_payload) {{
      name: name,
      type: type,
      companyName: company_name
    }}

    let(:name) { "New Name" }
    let(:type) { "pool" }
    let(:company_name) { "Company Name"}

    let(:info_response) {
      mutation_response[:contractor][:info]
    }

    it "calls operation and returns success" do
      expect(Operations::Contractor::Update).to receive(:call).with(
        contractor: contractor,
        name: name,
        type: type,
        company_name: company_name
      ).once.and_call_original

      subject

      expect(mutation_success).to eq(true)
      expect(info_response).to eq({
        name: name,
        type: type,
        companyName: company_name
      })
    end

  end

  describe "#payments_info" do
    let(:payments_info_payload) {{
      addPaymentCard: add_payment_card_payload,
      removePaymentCard: remove_payment_card_payload
    }}

    let(:add_payment_card_payload) { [] }
    let(:remove_payment_card_payload) { [] }

    let(:payments_info_response) {
      mutation_response[:contractor][:paymentsInfo]
    }

    let(:saved_cards_response) {
      payments_info_response[:savedCards]
    }

    let(:default_method_response) {
      payments_info_response[:defaultMethod]
    }

    describe "add card" do
      let(:card_1) {{
        card_id: "1111"
      }}

      let(:card_2) {{
        card_id: "2222"
      }}

      let(:card_new) {{
        card_id: "1234"
      }}

      let(:add_payment_card_payload) {[{
        card: card_new
      }]}

      before do
        contractor.add_payment_card card_1
        contractor.add_payment_card card_2
        contractor.save!
      end

      it "calls operation and returns success" do
        expect(contractor.payment_cards.map(&:deep_symbolize_keys)).to match([
          {id: 0, details: card_1},
          {id: 1, details: card_2}
        ])

        expect(Operations::Contractor::PaymentCard::Add).to receive(:call).with(
          contractor: contractor,
          card: card_new.as_json
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(saved_cards_response).to eq([
          {id: 0, details: card_1},
          {id: 1, details: card_2},
          {id: 2, details: card_new}
        ])
      end
    end

    describe "remove card" do
      let(:card_1) {{
        card_id: "1111"
      }}

      let(:card_2) {{
        card_id: "2222"
      }}

      let(:card_3) {{
        card_id: "3333"
      }}

      let(:remove_payment_card_payload) {[
        1
      ]}

      before do
        contractor.add_payment_card card_1
        contractor.add_payment_card card_2
        contractor.add_payment_card card_3
        contractor.save!
      end

      it "calls operation and returns success" do
        expect(contractor.payment_cards.map(&:deep_symbolize_keys)).to match([
          {id: 0, details: card_1},
          {id: 1, details: card_2},
          {id: 2, details: card_3}
        ])

        expect(Operations::Contractor::PaymentCard::Remove).to receive(:call).with(
          contractor: contractor,
          id: 1
        ).once.and_call_original

        subject

        expect(mutation_success).to eq(true)
        expect(saved_cards_response).to eq([
          {id: 0, details: card_1},
          {id: 2, details: card_3}
        ])
      end

      describe "when card is in default payment method" do
        before do
          contractor.set_default_payment_method(provider: :card, card_id: 1)
          contractor.save!
        end

        it "returns success" do
          subject

          expect(mutation_success).to eq(true)
        end

        it "resets default payment method" do
          subject

          expect(default_method_response).to eq({
            provider: nil,
            cardId: nil
          })
        end
      end

    end

    describe "default payment method" do
      let(:payments_info_payload) {{
        addPaymentCard: add_payment_card_payload,
        removePaymentCard: remove_payment_card_payload,
        defaultPaymentMethod: default_payment_method
      }}

      describe "without `card_id`" do
        let(:default_payment_method) {{
          provider: :paypal
        }}

        it "calls operation and returns success" do
          expect(contractor.default_payment_method).to eq({})

          expect(Operations::Contractor::Payment::SetDefaultPaymentMethod).to receive(:call).with(
            contractor: contractor,
            provider: :paypal,
            card_id: nil
          ).once.and_call_original

          subject

          expect(mutation_success).to eq(true)
          expect(default_method_response).to eq({
            provider: "paypal",
            cardId: nil
          })
        end
      end

      describe "with `card_id`" do
        let(:default_payment_method) {{
          provider: :card,
          cardId: payment_card[:id]
        }}

        let(:card) {{
          card_id: "1111"
        }}

        let(:payment_card) { contractor.add_payment_card! card }

        it "calls operation and returns success" do
          expect(contractor.default_payment_method).to eq({})

          expect(Operations::Contractor::Payment::SetDefaultPaymentMethod).to receive(:call).with(
            contractor: contractor,
            provider: :card,
            card_id: payment_card[:id]
          ).once.and_call_original

          subject

          expect(mutation_success).to eq(true)
          expect(default_method_response).to eq({
            provider: "card",
            cardId: payment_card[:id]
          })
        end
      end
    end
  end

  def build_query
    body = ""
    if identity_payload.present?
      body += <<~GQL
        identity: #{serialize(identity_payload)}
      GQL
    end

    if info_payload.present?
      body += <<~GQL
        info: #{serialize(info_payload)}
      GQL
    end

    if payments_info_payload.present?
      body += <<~GQL
        paymentsInfo: #{serialize(payments_info_payload)}
      GQL
    end

    <<~GQL
    mutation {
      #{mutation_type}(
        #{body}
      ) {
        success 
        contractor {
          info {
            name
            type
            companyName
          }
          paymentsInfo {
            savedCards {
              id
              details
            }
            defaultMethod {
              provider
              cardId
            }
          }
          identities {
            provider
            uid
          }
        }    
      }
    }
    GQL
  end
end
