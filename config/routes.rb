require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  resources :campaigns, only: %i[index new create show]
  root "campaigns#index"
end
