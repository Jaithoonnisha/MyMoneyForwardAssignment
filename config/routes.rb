Rails.application.routes.draw do
  post "/signup", to: "users#signup"
  get "/users/:user_id", to: "users#show"
  patch "/users/:user_id", to: "users#update"
  post "/close", to: "users#destroy"
end
