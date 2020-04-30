require 'rails_helper'

describe Operations::Contractor::Payment::Create do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:payload) {{
    contractor: contractor,
    amount: 5,
    currency: "usd",
    source: "token_12345"
  }}

  let(:contractor) { create(:contractor) }

  let(:client_response) {{
    status: 200,
    source: payload[:source]
  }}

  before do
    allow_any_instance_of(::Clients::Stripe).to receive(:charge_create)
      .with(amount: payload[:amount]*100, currency: payload[:currency], source: payload[:source])
      .and_return(client_response)
  end

  it "produces database changes" do
    expect { subject }
      .to  change(Transaction, :count).by(1)
  end

  it "returns success result" do
    expect(result.success?).to eq(true)
  end

  it "saves client response to Transaction table" do
    Transaction.delete_all

    subject
    transaction = Transaction.first

    expect(transaction.provider_stripe?).to be(true)
    expect(transaction.type_charge?).to be(true)
    expect(transaction.status_success?).to be(true)
    expect(transaction.amount).to eq(payload[:amount])
    expect(transaction.currency).to eq(payload[:currency])
    expect(transaction.details).to eq(client_response.as_json)
  end

end
