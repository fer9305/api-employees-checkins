class CheckInsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_employee
  before_action :validate_check_in, only: [:create]
  before_action :validate_present_check_in, only: [:update]

  # POST /employees/:employee_id/check_ins
  def create
    check_in = @employee.check_ins.create!(create_params)

    render json: check_in, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PUT /employees/:employee_id/check_ins
  def update
    check_in = @employee.check_ins.today.take
    check_in.update!(update_params)

    render json: check_in, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /employees/:employee_id/check_ins
  def show
    @employees = User.accessible_by(current_ability).
      employees.
      where(id: params[:employee_id]).
      includes(:check_ins)
  end

  private
    def validate_check_in
      if @employee.check_ins.today.present?
        return render json: { error: "Begin time already registered for today" }, status: :conflict
      end
    end

    def validate_present_check_in
      unless @employee.check_ins.today.present?
        return render json: { error: "Begin time have not been registered for today" }, status: :conflict
      end
    end

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
