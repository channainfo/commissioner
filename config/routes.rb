Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    namespace :vectors do
      resources :icons, only: [:index]
      resources :option_values, only: [:index, :update] do
        collection do
          post :update
        end
      end
    end

    resources :vendors do
      resources :vendor_photos do
        collection do
          post :update_positions
        end
      end
    end

    resources :products do
      resources :master_variant, only: [:index, :update] do
        collection do
          patch :update
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resources :search, only: %i[index]
      end
    end
  end
end
