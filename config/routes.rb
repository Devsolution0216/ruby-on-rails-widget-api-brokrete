Rails.application.routes.draw do
  post "/gql", to: "graphql#execute"

  get 'health', to: 'health#show'

  get "/confirm/email", to: "confirm#email"
  
  get 'brokrete_widget', to: 'partner#widget'
end
