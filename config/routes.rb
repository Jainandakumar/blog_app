Rails.application.routes.draw do
  root "posts#index"

  resources :users

  resources :posts do
    resources :post_ratings, only: %i[ create ]
    resources :comments, only: %i[ create destroy ] do
      resources :comment_ratings, only: %i[ create ]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
