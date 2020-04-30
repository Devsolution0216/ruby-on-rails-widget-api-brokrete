require 'rails_helper'
require 'graphql/graphql_spec_helper'

include GraphQL::SpecHelpers

describe "Queries::Contractor", type: :query do

  subject { query build_query, context: {current_user: contractor.user} }

  let(:query_type) { :contractor }
  let(:query_response) { gql_response.data[query_type] }

  let(:name) { "MyTestName" }
  let(:type) { "concrete" }

  let(:email) { "test@test.com" }
  let(:phone) { "+380971234567" }

  let!(:contractor) { create(:contractor, name: name, type: type)}

  it "returns correct data" do
    subject

    expect(query_response)
      .to match({
        id: contractor.id,
        info: {
          name: name,
          type: type
        },
        paymentsInfo: {
          savedCards: [],
          defaultMethod: {
            provider: nil,
            cardId: nil
          }
        }

      })
  end

  describe "with saved cards" do
    let(:card1) {{ cardId: "1" }}

    before do
      contractor.add_payment_card(card1)
      contractor.save!
    end

    it "returns correct data" do
      subject

      expect(query_response)
        .to match({
          id: contractor.id,
          info: {
            name: name,
            type: type
          },
          paymentsInfo: {
            savedCards: [{
              details: {
                cardId: "1"
              }
            }],
            defaultMethod: {
              provider: nil,
              cardId: nil
            }
          }

        })
    end

  end

  describe "with default payment method" do
    let(:card) {{ name: "test" }}

    before do
      payment_card = contractor.add_payment_card(card)
      contractor.set_default_payment_method(provider: :card, card_id: payment_card[:id])
      contractor.save!
    end

    it "returns correct data" do
      subject

      expect(query_response)
        .to match({
          id: contractor.id,
          info: {
            name: name,
            type: type
          },
          paymentsInfo: {
            savedCards: [{
              details: {
                name: card[:name]
              }
            }],
            defaultMethod: {
              provider: contractor.default_payment_method[:provider],
              cardId: contractor.default_payment_method[:card_id]
            }
          }

        })
    end
  end

  def build_query
    <<~GQL
    query {
      contractor {
        id
        info {
          name
          type
        }
        paymentsInfo {
          savedCards {
            details
          }
          defaultMethod {
            provider
            cardId
          }
        }    
      }
    }
    GQL
  end
end
