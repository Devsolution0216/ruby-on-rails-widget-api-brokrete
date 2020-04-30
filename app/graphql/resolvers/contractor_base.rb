module Resolvers
  class ContractorBase < Base

    protected

    def contractor
      @contractor ||= ::Contractor.find_by user: current_user
    end

  end
end
