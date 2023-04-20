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
        resources :customers do
          resources :subscriptions
          resources :addresses
        end
        resources :roles
        resources :users
        resources :orders do
          resource :invoice, only: %i[show create], controller: :invoice
          resources :payments do
            member do
              put :fire
            end

            resources :refunds, only: %i[new create edit update]
          end
        end
        resource :report, only: %i[show], controller: :report
      end

      get '/forbidden', to: 'errors#forbidden', as: :forbidden
      root to: redirect('/admin/merchant/:vendor_id/report')
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
      resources :vendor_service_calendars, except: %i[update] do
        member do
          patch :update_status
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
      resources :listing_prices, only: %i[index]
    end

    resources :taxonomies do
      resources :taxons do
        member do
          delete :remove_category_icon
        end
      end
    end

    resource :home_page_feed, only: %i[edit update], controller: :home_page_feed
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
        resource :homepage_data, only: [:show]
      end
    end
  end
end
