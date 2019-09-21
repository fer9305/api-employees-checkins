class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        include ActionController::ImplicitRender

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :first_name, :last_name, :birthday, :gender])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :birthday, :gender])
  end
end
