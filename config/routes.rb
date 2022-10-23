Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    resources :vendors do
      resources :vendor_photos do
        collection do
          post :update_positions
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :user_registration_with_socials, only: [:create]
      end
    end
  end
end
