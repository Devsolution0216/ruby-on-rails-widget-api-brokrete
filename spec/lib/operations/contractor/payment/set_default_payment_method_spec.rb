require 'rails_helper'

describe Operations::Contractor::Payment::SetDefaultPaymentMethod do

  subject { described_class.(payload) }

  let(:result) { subject }

  let(:payload) {{
    contractor: contractor,
    provider: provider,
    card_id: card_id
  }}

  let(:contractor) { create(:contractor) }

  describe "when provider is paypal" do

    let(:provider) { :paypal }
    let(:card_id) { nil }

    it "returns success result" do
      expect(result.success?).to eq(true)
    end

    it "saves default payment method" do
      subject

      contractor.reload
      expect(contractor.default_payment_method).to eq({
        provider: "paypal",
        card_id: nil
      }.as_json)
    end

    describe "and is passed correct `card_id`" do

      let(:card_id) { contractor.payment_cards.first[:id] }

      before do
        contractor.add_payment_card({ name: "test"} )
        contractor.save!
      end

      it "returns success result" do
        expect(result.success?).to eq(true)
      end

      it "ignores `card_id` and saves default payment method without `card_id`" do
        subject

        contractor.reload
        expect(contractor.default_payment_method).to eq({
          provider: "paypal",
          card_id: nil
        }.as_json)
      end

    end

    describe "and is passed incorrect `card_id`" do

      let(:card_id) { 123 }

      it "returns success result" do
        expect(result.success?).to eq(true)
      end

      it "ignores `card_id` and saves default payment method without `card_id`" do
        subject

        contractor.reload
        expect(contractor.default_payment_method).to eq({
          provider: "paypal",
          card_id: nil
        }.as_json)
      end

    end
  end

  describe "when provider is card" do
    let(:provider) { :card }

    describe "and is passed correct `card_id`" do

      let(:card_id) { contractor.payment_cards.first[:id] }

      before do
        contractor.add_payment_card({ name: "test"} )
        contractor.save!
      end

      it "returns success result" do
        expect(result.success?).to eq(true)
      end

      it "saves default payment method with `card_id`" do
        subject

        contractor.reload
        expect(contractor.default_payment_method).to eq({
          provider: "card",
          card_id: card_id
        }.as_json)
      end

    end

    describe "and is passed incorrect `card_id`" do

      let(:card_id) { 123 }

      it "returns error" do
        expect(result.success?).to eq(false)
      end

      it "does not save default payment method" do
        subject

        contractor.reload
        expect(contractor.default_payment_method).to eq({}.as_json)
      end

    end
  end
end
