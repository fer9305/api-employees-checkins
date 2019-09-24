class EmployeesController < ApplicationController
  before_action :authenticate_user!

  # GET /employees
  def index
    @employees =  User.accessible_by(current_ability).employees
  end
end