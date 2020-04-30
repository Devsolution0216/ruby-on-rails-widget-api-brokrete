module GraphQL::SpecHelpers

  attr_accessor :gql_response

  class GQLResponse
    attr_reader :data, :errors

    def initialize(args)
      @data = args[:data] || nil
      @errors = args[:errors] || nil
    end
  end

  # basic query to interact with the GraphQL API.
  # @param [query] required The query string that would be passed to the schema.
  def query(query, variables: {}, context: {})

    converted = variables.deep_transform_keys! {|key| key.to_s.camelize(:lower)} || {}

    Rails.logger.info("GQL Query: #{query}")

    res = ApiSchema.execute(query, variables: converted, context: context, operation_name: nil)
    @gql_response = GQLResponse.new(res.to_h.deep_symbolize_keys)

    Rails.logger.info("GQL Response: #{@gql_response.inspect}")

    @gql_response
  end

  alias_method :mutation, :query

  def serialize(value)
    return "" if value.nil?

    if value.is_a? Array
      return "[#{value.map { |item| serialize(item)}.join(", ")}]"
    end

    if value.is_a? Hash
      return "{#{value.map { |key, item| "#{key}: #{serialize(item)}"}.join(", ")}}"
    end

    if value.is_a? String
      return "\"#{value}\""
    end

    return value
  end
end
