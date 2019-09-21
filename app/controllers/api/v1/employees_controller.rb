class Api::V1::EmployeesController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/employees
  def index
    @employees = User.employees
  end
end