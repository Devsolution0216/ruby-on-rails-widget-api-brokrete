# frozen_string_literal: true

require 'virtus'

class Operation
  include Virtus.model
  include ActiveModel::Validations

  delegate :transaction, to: ActiveRecord::Base

  def self.call(*args)
    Rails.logger.info "[#{name}] call with #{args.inspect}"
    new(*args).call
  end

  def self.validates(field, *options, error: nil, **hash_options)
    super field, *options, **hash_options

    if error.present?
      _custom_errors[field] = error
    end
  end

  def self._custom_errors
    @_custom_errors ||= {}
  end

  def call
    validate_operation!
    unless errors.any?
      if block_given?
        result = yield
      else
        result = process
      end
    end
    result
  rescue ::Error => error
    Rails.logger.info "[#{self.class.name}] error #{error.inspect}"
    error
  end

  def with_transaction
    transaction do
      yield
    end
  rescue ::Error => error
    halt! error
  end

  protected

  def process
    raise NotImplementedError, "Process must be implemented on subclass #{self.class.name}!"
  end

  def halt!(result, *args)
    if result.respond_to?(:new)
      raise result.new(*args)
    end

    raise result
  end

  def success(result = {})
    Success.new(result)
  end

  def error!(code)
    halt! Errors::Custom.new(code)
  end

  def add_errors_from_model_if_any(model)
    model.validate
    model.errors.each do |k, v|
      errors.add "#{model.class.to_s.underscore}_#{k}", v
    end
    model.reload if model.persisted?
  end



  def halt_invalidate!
    errors.each do |field, message|
      halt! *custom_error(field) if custom_error(field).present?
    end

    halt! ::Errors::InvalidFields.new(self)
  end

  private

  def validate_operation!
    halt_invalidate! if invalid?
  end

  def custom_error(field)
    self.class._custom_errors[field]
  end

end
