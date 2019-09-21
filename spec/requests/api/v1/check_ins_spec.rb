require 'rails_helper'

RSpec.describe "CheckIns API", type: :request do
  let!(:user) { create(:user) }
  let!(:employee) { create(:user, :employee) }
  let(:auth_headers) { user.create_new_auth_token }
  
  path '/employees/{employee_id}/check_ins' do
    get 'Retrieve employee check ins' do
      tags 'Employee Check Ins'
      consumes 'application/json'
      parameter name: :employee_id, in: :path, type: :integer, required: true
      parameter name: :'access-token', in: :header, type: :string, required: true
      parameter name: :client, in: :header, type: :string, required: true
      parameter name: :uid, in: :header, type: :string, required: true

      response '200', 'employee check ins retrieved' do
        run_test!
      end
    end

    post 'Create employee check ins' do
      tags 'Employee Check Ins'
      consumes 'application/json'
      parameter name: :employee_id, in: :path, type: :integer, required: true
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          begin_time: { type: :string }
        },
        required: %w[ begin_time ]
      }
      parameter name: :'access-token', in: :header, type: :string, required: true
      parameter name: :client, in: :header, type: :string, required: true
      parameter name: :uid, in: :header, type: :string, required: true

      response '201', 'Creates check in with begin_time for employee' do
        run_test!
      end
    end

    put 'Update employee check ins' do
      tags 'Employee Check Ins'
      consumes 'application/json'
      parameter name: :employee_id, in: :path, type: :integer, required: true
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          end_time: { type: :string }
        },
        required: %w[ end_time ]
      }
      parameter name: :'access-token', in: :header, type: :string, required: true
      parameter name: :client, in: :header, type: :string, required: true
      parameter name: :uid, in: :header, type: :string, required: true

      response '200', 'Updates check in with begin_time for employee' do
        run_test!
      end
    end
  end

  describe '#create' do
    let(:create_params) do
      {
        begin_time: Time.current
      }
    end

    it 'creates a new check in for employee' do
      expect do
        post "/employees/#{employee.id}/check_ins", params: create_params, headers: auth_headers
      end.to change { employee.check_ins.count }.by(1)

      check_in = employee.check_ins.last
      expect(check_in.begin_time.to_i).to eq(create_params[:begin_time].to_i)
    end

    context 'failures' do
      context 'with already registered Checkin for today' do
        let!(:check_in) { create(:check_in, user: employee) }

        it 'raises an error' do
          post "/employees/#{employee.id}/check_ins", params: create_params, headers: auth_headers

          expected_error = {
            "error"=>"Begin time already registered for today"
          }

          expect(response_body).to eq(expected_error)
        end
      end

      context 'with empty begin_time' do
        it 'raises an error' do
          post "/employees/#{employee.id}/check_ins", params: {}, headers: auth_headers

          expected_error = {
            "error"=>"Validation failed: Begin time can't be blank"
          }
          
          expect(response_body).to eq(expected_error)
        end
      end

      context 'when employee tries to do a check in' do
        it 'raises an error' do
          employee_auth = employee.create_new_auth_token

          expect do
            post "/employees/#{employee.id}/check_ins", params: create_params, headers: employee_auth
          end.to raise_error(CanCan::AccessDenied, /You are not authorized to access this page./)
        end
      end
    end
  end

  describe '#update' do
    let!(:check_in) { create(:check_in, user: employee) }
    let(:update_params) do
      {
        end_time: Time.current + 1.minute
      }
    end

    it 'updates check in with end_time' do
      put "/employees/#{employee.id}/check_ins", params: update_params, headers: auth_headers

      check_in = employee.check_ins.last
      expect(check_in.end_time.to_i).to eq(update_params[:end_time].to_i)
    end

    context 'failures' do
      context 'with not previous registered Checkin for today' do
        it 'raises an error' do
          check_in.delete
          put "/employees/#{employee.id}/check_ins", params: update_params, headers: auth_headers

          expected_error = {
            "error"=>"Begin time have not been registered for today"
          }

          expect(response_body).to eq(expected_error)
        end
      end

      context 'with end_time < begin_time' do
        it 'raises an error' do
          update_params[:end_time] = Time.current - 3.hours
          put "/employees/#{employee.id}/check_ins", params: update_params, headers: auth_headers

          expected_error = {
            "error"=>"Validation failed: End time must be after the begin time"
          }
          
          expect(response_body).to eq(expected_error)
        end
      end

      context 'when employee tries to do a check in' do
        it 'raises an error' do
          employee_auth = employee.create_new_auth_token

          expect do
            put "/employees/#{employee.id}/check_ins", params: update_params, headers: employee_auth
          end.to raise_error(CanCan::AccessDenied, /You are not authorized to access this page./)
        end
      end
    end
  end

  describe '#show' do
    let!(:check_ins) { create_list(:check_in, 5, user: employee) }
    let!(:other_employee) { create(:user, :employee) }
    let!(:other_check_ins) { create_list(:check_in, 5, user: other_employee) }

    it 'returns user with checkins' do
      get "/employees/#{employee.id}/check_ins", headers: auth_headers

      expect(response_body['employees'].first['check_ins'].size).to eq(check_ins.size)
    end

    context 'when employee tries to get its checkins' do
      it 'returns checkins' do
        employee_auth = employee.create_new_auth_token

        get "/employees/#{employee.id}/check_ins", headers: employee_auth
        expect(response_body['employees'].first['check_ins'].size).to eq(check_ins.size)
      end
    end

    context 'when employee tries to get checkins from other employee' do
      it 'returns an error' do
        employee_auth = employee.create_new_auth_token

        get "/employees/#{other_employee.id}/check_ins", headers: employee_auth
        expect(response_body['employees']).to be_empty
      end
    end
  end
end
