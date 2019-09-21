require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Employees API", type: :request do
  let!(:user) { create(:user) }
  let!(:employees) { create_list(:user, 2, :employee) }
  let(:auth_headers) { user.create_new_auth_token }

  path '/employees' do

    get 'Retrieves employees' do
      tags 'Employees'
      consumes 'application/json'
      parameter name: :'access-token', in: :header, type: :string, required: true
      parameter name: :client, in: :header, type: :string, required: true
      parameter name: :uid, in: :header, type: :string, required: true
      
      response '200', 'employees retrieved' do
        run_test!
      end
    end
  end
  
  describe '#index' do
    it 'returns an error without auth headers' do
      get '/employees'

      expected_error = {
        "errors"=> ["You need to sign in or sign up before continuing."]
      }

      expect(response_body).to eq(expected_error)
    end

    it 'returns all employees' do
      get '/employees', headers: auth_headers

      expect(response_body['employees'].size).to eq(2)
    end
  end
end