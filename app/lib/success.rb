# frozen_string_literal: true
class Success
  def initialize(attributes = {})
    @attributes = attributes
  end

  delegate :[], :slice, to: :@attributes

  def success?
    true
  end

  def error?
    false
  end

  def success!
    self
  end

  def to_h
    @attributes
  end

  def respond_to?(method_name, *)
    @attributes.has_key?(method_name) || super
  end

  def method_missing(method_name, *args, &block)
    if @attributes.has_key?(method_name) && args.empty? && !block_given?
      @attributes[method_name]
    else
      super
    end
  end
end
