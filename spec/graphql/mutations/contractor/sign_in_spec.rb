require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe Mutations::Contractor::SignIn, type: :mutation do

  subject { mutation build_query }

  let(:mutation_type) { :contractorSignIn }
  let(:mutation_response) { gql_response.data[mutation_type] }
  let(:mutation_success) { mutation_response[:success]}
  let(:mutation_errors) { gql_response.errors }

  let(:email) { nil }
  let(:phone) { nil }
  let(:password) { "Qwer123$" }

  describe "when any identity is not provided" do
    it "does not call operation" do
      subject

      expect(Operations::Contractor::Find).not_to receive(:call)
    end

    it "returns not found error" do
      subject

      expect(mutation_success).to be_falsey
      expect(mutation_errors).to be_truthy
      expect(mutation_errors[0].symbolize_keys).to include(message: I18n.t("errors.not_found"))
    end
  end

  describe "when email identity is provided" do
    let(:email) { "test@test.com" }

    describe "and used does not exist" do

      it "returns not found error" do
        expect(Operations::Contractor::Find)
          .to receive(:call)
          .with(provider: :email, uid: email, token: password)
          .exactly(1).times
          .and_return Errors::NotFound.new

        subject

        expect(mutation_success).to be_falsey
        expect(mutation_errors).to be_truthy
        expect(mutation_errors[0])
          .to match(hash_including({
            message: I18n.t("errors.not_found")
          }))
      end

    end

    describe "and used exists" do

      let(:contractor) { create(:contractor, :with_email_identity)}

      it "returns contractor and token" do
        expect(Operations::Contractor::Find)
          .to receive(:call)
          .with(provider: :email, uid: email, token: password)
          .exactly(1).times
          .and_return ::Success.new({contractor: contractor})

        subject

        expect(mutation_success).to be_truthy
        expect(mutation_errors).to be_nil
        expect(mutation_response)
          .to match(hash_including({
            contractor: hash_including({
              info: {
                name: contractor.name
              }
            }),
            token: /^.+$/
          }))
      end

    end
  end

  describe "when phone identity is provided" do
    let(:phone) { "+1234567890000" }

    describe "and used does not exist" do

      it "returns not found error" do
        expect(Operations::Contractor::Find)
          .to receive(:call)
          .with(provider: :phone, uid: phone, token: password)
          .exactly(1).times
          .and_return Errors::NotFound.new

        subject

        expect(mutation_success).to be_falsey
        expect(mutation_errors).to be_truthy
        expect(mutation_errors[0])
          .to match(hash_including({
            message: I18n.t("errors.not_found")
          }))
      end

    end

    describe "and used exists" do

      let(:contractor) { create(:contractor, :with_phone_identity)}

      it "returns contractor and token" do
        expect(Operations::Contractor::Find)
          .to receive(:call)
          .with(provider: :phone, uid: phone, token: password)
          .exactly(1).times
          .and_return ::Success.new({contractor: contractor})

        subject

        expect(mutation_success).to be_truthy
        expect(mutation_errors).to be_nil
        expect(mutation_response)
          .to match(hash_including({
            contractor: hash_including({
              info: {
                name: contractor.name
              }
            }),
            token: /^.+$/
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
        #{body}
      ) {
        success
        contractor {
          info {
            name
          }      
        }
        token       
      }
    }
    GQL
  end
end
