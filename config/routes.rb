Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'employees#index'
  
  resources :employees, only: [:index], format: "json" do
    # resource :check_ins, only: [:create, :update, :show, :edit]
    resources :check_ins, only: [:create, :update, :index]
  end
end
