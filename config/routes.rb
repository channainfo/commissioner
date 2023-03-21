Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    namespace :vectors do
      resources :icons, only: [:index]
      resources :option_values, only: %i[index update] do
        collection do
          post :update
        end
      end
    end

    namespace :merchant do
      scope ':vendor_id' do
        resources :users do
          resources :subscriptions
        end
      end

      get '/forbidden', to: 'errors#forbidden', as: :forbidden
      root to: redirect('/admin/merchant/:vendor_id/users')
    end

    resources :vendors do
      resources :vendor_photos do
        collection do
          post :update_positions
        end
      end
      resources :vendor_kind_option_types, only: %i[index update] do
        collection do
          patch :update
          patch :update_positions
        end
      end
      resources :nearby_places do
        collection do
          post :update_positions
        end
      end
    end

    resources :products do
      resources :master_variant, only: %i[index update] do
        collection do
          patch :update
        end
      end
    end

    namespace :calendars do
      resources :orders, only: %i[index]
    end

    resources :taxonomies do
      resources :taxons do
        member do
          delete :remove_category_icon
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resources :accommodations, only: %i[index show]
        resources :account_checker
        resources :provinces, only: %i[index]
        resources :user_deletion_reasons, only: [:index]
        resources :vendors do
          resources :nearby_places, only: %i[index]
        end
      end
    end
  end
end
