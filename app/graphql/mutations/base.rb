module Mutations
  # This class is used as a parent for all mutations, and it is the place to have common utilities
  class Base < GraphQL::Schema::Mutation

    class << self
      def field(name, *args, **args2)
        unless args2.has_key? :resolve
          args2[:resolve] = -> (obj, args, ctx) {
            begin
              value = obj[name]
              return value.call if value.respond_to?(:call)
              value
            rescue ::Error => e
              GraphQL::ExecutionError.new e.description, extensions: {
                code: e.code,
                status_code: e.status_code
              }
            end
          }
        end

        super(name, *args, **args2)
      end
    end

    null false

    field :success, Boolean, null: false

    def authorized?(**args)
      raise GraphQL::UnauthorizedFieldError, "Unauthorized access" if current_user.blank?
      true
    end

    protected

    def success(result = true, **fields)
      { success: result }.merge! fields
    end

    def error! e
      context.add_error(
        GraphQL::ExecutionError.new e.description, extensions: {
          code: e.code,
          status_code: e.status_code
        }
      )

      { success: false }
    end

    def current_user
      context[:current_user]
    end

    def generate_access_token(user)
      TokenHelper.generate_access_token user, response
    end

    def response
      context[:response]
    end
  end
end
