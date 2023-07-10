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

    resources :customer_notifications do
      post :send_test
      resources :feature_images do
        collection do
          post :update_positions
        end
      end
    end

    resources :users do
      resources :device_tokens
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

    resource :homepage_feed, only: %i[edit update], controller: :homepage_feed do
      resources :homepage_banner do
        collection do
          post :update_positions
        end
      end

      resources :homepage_background do
        collection do
          post :update_positions
        end
      end
    end
  end

  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :billing do
      resource :report, only: %i[show], controller: :report do
        get '/paid', to: 'report#paid', as: :paid
        get '/balance_due', to: 'report#balance_due', as: :balance_due
        get '/overdue', to: 'report#overdue', as: :overdue
        get '/active_subscribers', to: 'report#active_subscribers', as: :active_subscribers
      end
      resources :customers do
        resources :subscriptions
        resources :addresses
      end
      resources :roles
      resources :users
      resources :products do
        member do
          get :stock
        end
        resources :variants do
          collection do
            post :update_positions
          end
        end
        resources :refunds, only: %i[new create edit update]
      end
      resources :variants do
        collection do
          post :update_positions
        end

        resources :variants_including_master, only: [:update]
      end
      resources :orders do
        resource :invoice, only: %i[show create], controller: :invoice
        resources :payments do
          member do
            put :fire
          end
          resources :refunds, only: %i[new create edit update]
        end
        resources :adjustments
      end
      put '/switch_vendor', to: 'base#switch_vendor'
      get '/forbidden', to: 'errors#forbidden', as: :forbidden
      root to: redirect('/billing/report')
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resources :accommodations, only: %i[index show]
        resources :account_checker
        resources :provinces, only: %i[index]
        resources :user_deletion_reasons, only: [:index]

        resources :notifications, only: %i[index show]
        resources :customer_notifications, only: [:show]
        resources :user_device_token_registrations, only: %i[create destroy]
        resources :vendors do
          resources :nearby_places, only: %i[index]
        end
        resource :homepage_data, only: [:show]
      end
    end
  end
end
