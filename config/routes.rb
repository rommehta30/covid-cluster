Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :hexagons, only: [:new, :create]
  get '/hexagons/:name', to: 'hexagons#show', as: 'hexagon'
  patch '/hexagons/:name/remove', to: 'hexagons#remove', as: 'remove_hexagon'
end
