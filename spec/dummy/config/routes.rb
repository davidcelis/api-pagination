Dummy::Application.routes.draw do
  resources :numbers, only: [:index]
end
