class EmployeesController < ApplicationController
  before_action :authenticate_user!

  # GET /employees
  def index
    @employees = User.employees
  end
end