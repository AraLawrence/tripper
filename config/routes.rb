Rails.application.routes.draw do

  get 'static/new'

  root 'trip#index'

  get 'trip/index'

  post 'trip/create' => 'trip#create'

  get 'trip/:id/new' => 'trip#new', as: 'trip_new'

  get 'trip/:id/edit' => 'trip#edit'

  get 'trip/show'

  get 'trip/:id/update' => 'trip#update', as: 'trip_update'

  get 'trip/destroy'

  get 'user/index'

  get 'user/create'

  get 'user/new'

  get 'user/edit'

  get 'user/show'

  get 'user/update'

  get 'user/destroy'

  get 'auth/logout' => 'auth#logout'
  get 'auth/failure' => 'auth#failure'
  get 'auth/:provider/callback' => 'auth#callback'

  post '/' => 'sessions#create', as: 'sessions_create1'
  post '/' => 'user#create', as: 'user_create1'

  resources :user
  resources :trip
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
