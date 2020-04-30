require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Contractor::SignUp, type: :mutation do

  subject { mutation build_query }

  let(:mutation_type) { :contractorSignUp }
  let(:mutation_response) { gql_response.data&.[](mutation_type) }
  let(:mutation_success) { mutation_response&.[](:success) || false }
  let(:mutation_errors) { gql_response.errors }

  let(:email) { nil }
  let(:phone) { nil }
  let(:password) { "Qwer123$" }

  describe "when any identity is not provided" do
    it "returns error" do

      expect(Operations::Contractor::Create)
        .to receive(:call)
        .with(identities: [])
        .exactly(1).times.and_call_original

      subject

      expect(mutation_success).to be_falsey
      expect(mutation_errors).to be_truthy
      expect(mutation_errors[0].symbolize_keys).to include(message: "No identities were provided")
    end
  end

  describe "when only email identity is provided" do
    let(:email) { "test@test.com" }

    it "returns error" do
      expect(Operations::Contractor::Create)
        .to receive(:call)
        .with(identities: [{provider: :email, uid: email, token: password}])
        .exactly(1).times
        .and_call_original

      subject

      expect(mutation_success).to be_falsey
      expect(mutation_errors).to be_truthy
      expect(mutation_errors[0])
        .to match(hash_including({
          message: "No phone identity was provided"
        }))
    end
  end

  describe "when only phone identity is provided" do
    let(:phone) { "+380971234567" }

    it "returns error" do
      expect(Operations::Contractor::Create)
        .to receive(:call)
        .with(identities: [{provider: :phone, uid: phone, token: password}])
        .exactly(1).times
        .and_call_original

      subject

      expect(mutation_success).to be_falsey
      expect(mutation_errors).to be_truthy
      expect(mutation_errors[0])
        .to match(hash_including({
          message: "No email identity was provided"
        }))
    end
  end

  describe "when both email and phone identities are provided" do
    let(:email) { "test@test.com" }
    let(:phone) { "+380971234567" }

    describe "and user does not exist" do

      it "returns contractor and token" do
        expect(Operations::Contractor::Create)
          .to receive(:call)
            .with(identities: [
              {provider: :email, uid: email, token: password},
              {provider: :phone, uid: phone, token: password}
            ])
            .exactly(1).times
            .and_call_original

        subject

        expect(mutation_success).to be_truthy
        expect(mutation_response)
          .to match(hash_including({
            contractor: hash_including({
              identities: [hash_including({
                uid: email,
                provider: "email"
              }), hash_including({
                uid: phone,
                provider: "phone"
              })]
            }),
            token: /^.+$/
          }))
      end

    end

    describe "and user has already exist" do

      it "returns contractor and token" do
        expect(Operations::Contractor::Create)
          .to receive(:call)
            .with(identities: [
              {provider: :email, uid: email, token: password},
              {provider: :phone, uid: phone, token: password}
            ])
            .exactly(1).times
            .and_return Errors::AlreadyExists.new

        subject

        expect(mutation_success).to be_falsey
        expect(mutation_errors).to be_truthy
        expect(mutation_errors[0])
          .to match(hash_including({
            message: I18n.t("errors.already_exists")
          }))

      end

    end
  end

  def build_query
    body = ""
    if email.present?
      body += <<~GQL
        email: {
          email: "#{email}"
          password: "#{password}"
        }
      GQL
    end

    if phone.present?
      body += <<~GQL
        phone: {
          phone: "#{phone}"
          password: "#{password}"
        }
      GQL
    end

    <<~GQL
    mutation {
      #{mutation_type}(
        identity: {
          #{body}
        }
      ) {
        success
        contractor {
          identities {
            uid
            provider
          }      
        }
        token       
      }
    }
    GQL
  end
end
