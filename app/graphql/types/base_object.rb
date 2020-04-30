module Types
  class BaseObject < GraphQL::Schema::Object
    class << self
      def field(name, *args, **args2)
        super(name, *args, **args2)

        unless method_defined?(name)
          define_method(name) do
            value = object.respond_to?(name) ? object.try(name) : object[name]
            return value.call if value.respond_to?(:call)
            value
          rescue ::Error => e
            GraphQL::ExecutionError.new e.description, extensions: {
              code: e.code,
              status_code: e.status_code
            }
          end
        end
      end
    end

    def initialize(object, context)
      object = object.call if object.respond_to?(:call)
      super object, context
    end
  end
end
