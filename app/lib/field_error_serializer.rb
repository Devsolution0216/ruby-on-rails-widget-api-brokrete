require_relative 'field_error_builder'

class FieldErrorSerializer
  include Virtus.model

  attribute :model
  attribute :request

  def to_h
    details
  end

  def details
    builder.to_h
  end

  def builder
    field_errors_for(model, request)
  end

  private

  def field_errors_for(model, request)
    request ||= NullRequest

    builder = FieldErrorBuilder.new

    nested_fields = {}
    model.errors.to_h.each do |field, message|
      if message == 'is invalid' && is_nested_field?(model, field)
        nested_fields[field] = model.public_send(field)
        nil
      elsif request.blank? || request.has_key?(field)
        builder.add_message(field, message)
      end
    end

    nested_fields.each do |field, nested_models_or_collection|
      nested_request = Array(request[field])
      nested_builders = Array(nested_models_or_collection).to_enum.with_index.map do |nested_model, index|
        if nested_model.errors.any?
          field_errors_for(nested_model, nested_request[index])
        end
      end
      builder.set_nested(field, nested_builders)
    end

    builder
  end

  def is_nested_field?(model, field)
    return false if !model.respond_to?(field)
    obj = model.public_send(field)
    obj = obj.first if obj.respond_to?(:first)
    obj.respond_to?(:errors)
  end

  class NullRequest
    def self.[](index)
      self
    end

    def self.present?
      false
    end

    def self.blank?
      true
    end
  end
end
