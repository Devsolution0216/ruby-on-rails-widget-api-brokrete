# frozen_string_literal: true
class Error < Exception
  def initialize(*args)
    super
    check_translation_exists!
  end

  def success?
    false
  end

  def error?
    true
  end

  def success!
    raise "Expected success, got: #{inspect}"
  end

  def description
    I18n.t("errors.#{code}", i18n_params)
  end

  def check_translation_exists!
    description
  end

  def code
    raise NotImplementedError, 'Must be implemented if error exposed on api!'
  end

  def status_code
    raise NotImplementedError, 'Must be implemented if error exposed on api!'
  end

  def self.code(arg)
    define_method(:code) { arg }
  end

  def self.status_code(arg)
    define_method(:status_code) { arg }
  end

  def inspect
    "<#{self.class.name} [#{code}] #{description}>"
  end

  def i18n_params
    {}
  end

  def self.i18n_params(arg)
    define_method(:i18n_params) { arg }
  end
end
