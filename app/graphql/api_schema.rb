class ApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  def self.unauthorized_object(error)
    raise GraphQL::ExecutionError.new("Unauthorized", extensions: {
      code: 401
    })
  end

  def self.unauthorized_field(error)
    raise GraphQL::ExecutionError.new("Unauthorized", extensions: {
      code: 401
    })
  end

  GraphQL::Errors.configure(ApiSchema) do
    rescue_from ActiveRecord::RecordNotFound do |exception|
      nil
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      GraphQL::ExecutionError.new(exception.record.errors.full_messages.join("\n"))
    end

    rescue_from StandardError do |exception|
      GraphQL::ExecutionError.new("Please try to execute the query for this field later")
    end

    rescue_from ::Error do |exception, object, arguments, context|
      GraphQL::ExecutionError.new exception.description, extensions: {
        code: exception.code,
        status_code: exception.status_code
      }
    end
  end
end
