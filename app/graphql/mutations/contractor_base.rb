module Mutations
  class ContractorBase < Base

    field :contractor, Types::ContractorType, null: true

    protected

    def success(result = true, **fields)
      { contractor: -> { contractor } }.merge! super(result, **fields)
    end

    def contractor
      @contractor ||= ::Contractor.find_by user: current_user
    rescue
      nil
    end

  end
end
