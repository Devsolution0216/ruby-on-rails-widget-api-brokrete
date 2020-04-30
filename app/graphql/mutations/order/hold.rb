module Mutations
  class Order::Hold < ContractorBase
    argument :order_id, ID, required: true

    def resolve(order_id:)
      result = Operations::Order::Hold.(
        contractor: contractor,
        order_id: order_id
      )
      raise result if result.error?

      success
    rescue Error => e
      error! e
    end
  end
end
