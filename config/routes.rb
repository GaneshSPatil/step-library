Rails.application.routes.draw do

  resources :book_copies
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'books#index'


  get 'books' => 'books#index', as: 'books'
  get 'books/list' => 'books#list', as: 'books_list'
  get 'books/manage' => 'books#manage', as: 'books_manage'
  get 'books/:id' => 'books#show' , as: 'books_show'
  get 'books/:isbn/details' => 'books#details' , as: 'books_details'
  get 'book-copy/:id/logs' => 'book_copies#logs' , as: 'book_copy_logs'

  post 'books/:id/borrow' => 'books#borrow' , as: 'borrow_book'
  post 'books' => 'books#create', as: 'books_create'
  post 'books/:id/return' => 'books#return', as: 'return_book'

  devise_for :user, :controllers => { :omniauth_callbacks => "facebook"}
  get 'users' => 'users#index', as: 'users'
  get 'user/books' => 'users#books', as: 'users_books'
  get 'users/disabled/list' => 'users#disabled', as:'disable_user_list'
  get 'users/:id' => 'users#show' , as: 'users_show'

  post 'users/:id/disable' => 'users#disable' , as: 'disable_user'

  match '/403', to: 'errors#forbidden_access_denied', via: :all
  match '/404', to: 'errors#file_not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

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
