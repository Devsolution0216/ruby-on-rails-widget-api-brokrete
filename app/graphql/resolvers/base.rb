module Resolvers
  class Base < GraphQL::Schema::Resolver

    def authorized?(**args)
      raise GraphQL::UnauthorizedFieldError, "Unauthorized access" if current_user.blank?
      true
    end

    protected

    def current_user
      context[:current_user]
    end
  end
end
