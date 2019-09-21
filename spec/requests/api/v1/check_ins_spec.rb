require 'rails_helper'

RSpec.describe "CheckIns API", type: :request do
  let!(:user) { create(:user) }
  let!(:employee) { create(:user, :employee) }
  let(:auth_headers) { user.create_new_auth_token }

  describe '#create' do
    let(:create_params) do
      {
        begin_time: Time.current
      }
    end

    it 'returns an error without auth headers' do
      post "/employees/#{employee.id}/check_ins", params: create_params

      expected_error = {
        "errors"=> ["You need to sign in or sign up before continuing."]
      }

      expect(response_body).to eq(expected_error)
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
    end
  end

  describe '#update' do
    let!(:check_in) { create(:check_in, user: employee) }
    let(:update_params) do
      {
        end_time: Time.current + 1.minute
      }
    end

    it 'returns an error without auth headers' do
      put "/employees/#{employee.id}/check_ins", params: update_params

      expected_error = {
        "errors"=> ["You need to sign in or sign up before continuing."]
      }

      expect(response_body).to eq(expected_error)
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
    end
  end
end