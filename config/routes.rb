Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    resources :promotions do
      resources :custom_dates_rules, controller: :promotion_custom_dates_rules, only: %i[edit update] do
        member do
          delete :remove_custom_date
        end
      end

      resources :weekend_rules, controller: :promotion_weekend_rules, only: %i[edit update] do
        member do
          delete :remove_exception_date
        end
      end
    end

    namespace :vectors do
      resources :icons, only: [:index]
      resources :option_values, only: %i[index update] do
        collection do
          post :update
        end
      end
    end

    resources :vendors do
      resources :product_commissions, only: [:index] do
        collection do
          post :update_commissions
          post :update_default_commission
        end
      end

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
      resources :vendor_authorized_users do
        collection do
          patch :update_telegram_chat
        end
      end
    end

    resources :customer_notifications do
      resources :notification_users, only: [:index]
      resources :feature_images do
        collection do
          post :update_positions
        end
      end
      resources :notifications, only: [:index]
    end

    resources :notification_sender, only: [:create]

    resources :users do
      resources :device_tokens
      resources :user_identity_providers
    end

    resources :s3_presigned_urls, only: %i[create new]
    resources :guest_qr_codes, only: %i[index]

    resources :products do
      member do
        get 'edit_kyc', to: 'kyc#edit'
        put 'update_kyc', to: 'kyc#update'
      end

      resources :video_on_demands do
        collection do
          post :update_positions
        end
      end

      resources :google_wallets do
        member do
          post  :create_google_wallet_class
          patch :update_google_wallet_class
          delete :remove_logo
          delete :remove_hero_image
        end
      end

      resources :hotel_google_wallets do
        member do
          post  :create_google_wallet_class
          patch :update_google_wallet_class
          delete :remove_logo
          delete :remove_hero_image
        end
      end

      resources :master_variant, only: %i[index update] do
        collection do
          patch :update
        end
      end

      resources :stock_managements

      resources :product_completion_steps do
        collection do
          post :update_positions
        end
      end
    end

    namespace :calendars do
      resources :orders, only: %i[index]
    end

    resources :taxonomies do
      resources :taxons do
        resources :taxon_vendors
        resources :classifications do
          collection do
            post :recalculate_conversions
          end
        end

        member do
          delete :remove_category_icon
          delete :remove_app_banner
          delete :remove_web_banner
          delete :remove_home_banner
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

      resources :homepage_section do
        collection do
          post :update_positions
        end
      end

      resources :homepage_section_relatable do
        collection do
          get :options
          post :update_positions
        end
      end
    end

    resources :webhooks_events

    resources :orders, except: [:show] do
      collection do
        resources :import_orders, only: %i[index new create]
        get :download_order_csv_template, controller: 'import_orders'
      end
      member do
        put :accept_all
        put :reject_all
        put :alert_request_to_vendor

        get :notifications
        put :fire_notification
        put :queue_webhooks_requests
      end

      resources :line_items, only: %i[edit update]
      resources :guests do
        resources :id_cards
        collection do
          post :add_guest
          delete :remove_guest
        end
      end
    end

    resources :user_events, except: %i[show edit update]

    resources :webhooks_subscribers do
      resources :rules, controller: :webhooks_subscriber_rules, except: %i[index show]
      resources :orders, controller: :webhooks_subscriber_orders do
        collection do
          put :queue
        end
      end
    end
  end

  resources :events, controller: 'events/base' do
    root to: 'events/guests#index'
    resources :guests, only: %i[index show edit update], controller: 'events/guests' do
      post :send_email, on: :member, as: :send_email
      collection do
        post :generate_guest_csv
      end
      member do
        post :check_in
        post :uncheck_in
      end
      resources :state_changes, only: %i[index], controller: 'events/state_changes'
    end
    resources :check_ins, only: %i[index], controller: 'events/check_ins'
    resources :data_exports, controller: 'events/data_exports' do
      member do
        post :download
      end
    end
    collection do
      get '/forbidden', to: 'events/errors#forbidden'
      get '/resource_not_found', to: 'events/errors#resource_not_found'
    end
  end

  namespace :telegram do
    resources :orders, only: %i[show update] do
      member do
        patch :reject
        patch :approve
      end
    end

    get '/forbidden', to: 'errors#forbidden'
    get '/resource_not_found', to: 'errors#resource_not_found'
  end

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    namespace :billing do
      resources :reports do
        collection do
          get :failed_orders
          get :paid
          get :balance_due
          get :overdue
          get :active_subscribers
          put :print_all_invoices
        end
      end
      resources :vendors do
        resource :payment_qrcodes, only: %i[destroy]
      end
      resources :customers do
        post 're_create_order', to: 'customers#re_create_order'
        resources :orders
        resources :subscriptions
        resources :addresses
      end
      resources :roles
      resources :users do
        resource :account_deletions, only: [:destroy]
      end
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
        resource :invoice, only: %i[show create], controller: :invoice do
          collection do
            put :print_invoice_date
          end
        end
        resources :payments do
          resources :refunds, only: %i[new create edit update]
        end
        resources :adjustments
      end
      resources :places
      put '/switch_vendor', to: 'base#switch_vendor'
      get '/forbidden', to: 'errors#forbidden', as: :forbidden
      root to: redirect('/billing/reports')
      resources :businesses
      resources :option_types do
        collection do
          post :update_positions
          post :update_values_positions
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :platform do
        resources :homepage_section_relatable_options
      end

      namespace :storefront do
        resource :cart, controller: :cart, only: %i[show create destroy] do
          patch :restart_checkout_flow
        end

        resources :wished_items
        resources :user_promotion
        resources :order_promotions

        resource :cart_guests, only: %i[create destroy]
        resources :cart_payment_method_groups, only: %i[index]

        resources :accommodations, only: %i[index show]
        resources :line_items, only: %i[index show]
        resources :account_checker
        resource :account_recovers, only: [:update]

        namespace :account do
          resource :preferred_payment_method, controller: :preferred_payment_method, only: %i[show update]
        end

        resource :s3_signed_urls
        resources :google_wallet_object_tokens
        resources :provinces, only: %i[index]
        resources :user_deletion_reasons, only: [:index]
        resource :profile_images, only: [:update]
        resource :user_profiles, only: [:update]
        resources :notifications do
          collection do
            patch :mark_all_as_read
          end
          member do
            patch :mark_as_read
          end
        end
        resources :order_request_notifications, only: %i[index show]

        resources :customer_notifications, only: [:show]
        resource :user_contacts, only: [:update]
        resource :reset_passwords, only: [:update]
        resource :user_registration_with_pin_codes, only: [:create]
        resources :user_device_token_registrations, only: %i[create destroy]
        resources :user_account_linkages, only: %i[index create destroy]
        resources :pin_code_otp_generators, only: [:create]
        resource :pin_code_otp_checkers, only: [:update]
        resources :pin_code_generators, only: [:create]
        resource :pin_code_checkers, only: [:update]

        resource :confirm_pin_code_checkers, only: [:update]

        resources :order_products_taxons, only: [:index]

        resource :change_passwords, only: [:update]
        resource :account_deletions, only: %i[destroy]

        resources :vendors do
          resources :nearby_places, only: %i[index]
        end
        resource :homepage_data, only: [:show]
        resources :homepage_sections, only: [:index]
        resources :order_qrs, only: [:show]
        resources :line_item_qrs, only: [:show]
        resources :event_qrs, only: [:show]

        resources :homepage, only: [] do
          resources :homepage_sections, only: [:index]
          resource :homepage_background, controller: :homepage_background, only: [:show]
        end

        resources :guest_qrs, only: [:show]
        resources :guests, only: %i[create update show] do
          resources :id_cards
        end
        resources :pending_line_items, only: %i[show index]
        resources :self_check_in, only: %i[index create]
        resources :guest_orders, only: %i[index show]
        post :user_order_transfer, to: 'user_order_transfer#create'
      end

      namespace :operator do
        resources :line_items, only: %i[index show]
        resources :check_ins, only: %i[index create]
        resource :check_in_bulks, only: %i[index create]
        resources :dashboard_crew_events, only: %i[index]
        resources :event_qrs, only: [:show]
        resources :taxons, only: %i[show] do
          resource :event_ticket_aggregators, only: %i[show]
          resource :pie_chart_event_aggregators, only: %i[show]
        end
      end
    end

    namespace :json_ld do
      resources :vendors, only: %i[index show]
    end

    namespace :webhook do
      resources :orders, only: [:show]
      resources :media_convert_queues, only: [:create]
    end

    namespace :chatrace do
      resources :guests, only: %i[show update]
      resources :check_ins, only: [:create]
    end
  end
end

Rails.application.routes.draw do
  get 'i/:id', to: 'spree_cm_commissioner/qr_images#show', as: 'qr_image'
  get 'o/:id', to: 'spree_cm_commissioner/orders#show', as: 'order'
  get 'li/:id', to: 'spree_cm_commissioner/line_item_qr_images#show', as: 'line_item_qr_image'
end
