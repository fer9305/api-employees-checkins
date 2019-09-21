class CheckInsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee

  # POST /employees/:employee_id/check_ins
  def create
    if CheckIn.today.present?
      return render json: { error: "Begin time already registered for today" }, status: :conflict
    end

    check_in = @employee.check_ins.create!(create_params)

    render json: check_in, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PUT /employees/:employee_id/check_ins
  def update
    unless CheckIn.today.present?
      return render json: { error: "Begin time have not been registered for today" }, status: :conflict
    end

    check_in = @employee.check_ins.today.take
    check_in.update!(update_params)

    render json: check_in, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

    def set_employee
      @employee = User.employees.find(params[:employee_id])
    rescue
      render json: {error: "Employee does not exists"}, status: :not_found  
    end

    def create_params
      params.permit(:begin_time)
    end

    def update_params
      params.permit(:end_time)
    end
end
