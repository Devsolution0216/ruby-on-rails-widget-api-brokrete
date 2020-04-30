# frozen_string_literal: true
class ConfirmController < ApplicationController

  def email

    code = code_params

    result = Operations::Contractor::Identity::Confirm.(token: code)

    if result.error?
      render plain: result.description, status: 500
    else
      render plain: "OK"
    end
  end

  private

  def code_params
    params.require(:code)
  end
end
