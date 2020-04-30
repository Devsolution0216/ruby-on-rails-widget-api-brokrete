module Mutations
  class Payment::Create < ContractorBase

    argument :amount, Int, required: true
    argument :currency, String, required: true
    argument :source, String, required: true

    def resolve(amount:, currency:, source:)

      result = Operations::Contractor::Payment::Create.(
        contractor: contractor,
        amount: amount,
        currency: currency,
        source: source
      )

      raise result if result.error?

      success
    rescue Error => e
      error! e
    end

  end
end
