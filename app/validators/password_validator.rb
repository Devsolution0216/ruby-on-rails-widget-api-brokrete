# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  PASSWORD_FORMAT = /\A
    (?=.{8,})   # Must contain 8 or more characters
    (?=.*[a-z]) # Must contain a lower case character
    (?=.*[A-Z]) # Must contain an upper case character
  /x.freeze

  def validate_each(record, attribute, value)
    unless self.class.valid?(value)
      record.errors[attribute] << I18n.t('errors.incorrect_password')
    end
  end

  def self.valid?(value)
    !!(value =~ PASSWORD_FORMAT)
  end
end
