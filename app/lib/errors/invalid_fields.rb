# frozen_string_literal: true
module Errors
  class InvalidFields < ::Error
    attr_reader :model
    private :model

    def initialize(model, details: nil, builder: nil)
      @model = model
      @details = details
      @builder = builder
    end

    def code
      :invalid_fields
    end

    def status_code
      422
    end

    def details
      @details ||= builder.to_h
    end

    def builder
      @builder ||= FieldErrorSerializer.new(model: model).builder
    end

    def inspect
      "#<#{self.class.name} #{details.inspect}>"
    end
  end
end
