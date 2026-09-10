Rails.application.routes.draw do
  resources :pedidos
  resources :produtos
  resources :clientes do
    # Rota aninhada: GET /clientes/1/pedidos lista os pedidos daquele cliente.
    # only: [:index] porque criar pedido continua sendo POST /pedidos.
    resources :pedidos, only: [ :index ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Raiz da API: lista os endpoints disponiveis.
  root "raiz#show"
end
