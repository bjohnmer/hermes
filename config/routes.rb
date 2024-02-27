Rails.application.routes.draw do
  get 'home/index'
  get '/openai/service1', to: 'openai#service1'
  get '/openai/service2', to: 'openai#service2'
  post '/openai/handle_prompt2', to: 'openai#handle_prompt2'
  post '/openai/handle_prompt1', to: 'openai#handle_prompt1'
  devise_for :users
  resources :categories
  root to: "home#index"
end
