# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    error_code = problem
    if error_code.present?
      render plain: error_code, status: 500
    else
      render plain: "OK"
    end
  end

  private

  def problem
    nil
  end
end
