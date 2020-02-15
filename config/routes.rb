require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  get '/robots.txt' => RobotsTxt
  use_doorkeeper

  get 'test_gauge', to: 'test#gauge'
  get 'sso', to: 'participants#sso'

  admin = lambda do |request|
    request.env['warden'].authenticate? && request.env['warden'].user.admin?
  end

  constraints admin do
    mount Blazer::Engine => '/blazer'
    mount Sidekiq::Web => '/sidekiq'
    begin
      ActiveAdmin.routes(self)
    rescue StandardError
      ActiveAdmin::DatabaseHitDuringLoad
    end
    namespace :admin do
      resources :team_participants, only: []
      resources :challenges, only: [] do
        resources :teams, only: [], param: :name do
          resources :team_participants
          resources :team_invitations
        end
      end
    end
  end

  namespace :api do
    resources :external_graders, only: [:create, :show, :update] do
      get :challenge_config, on: :collection
      get :presign, on: :member
      get :submission_info, on: :member
    end

    resources :challenges, only: [:index, :show] do
      resources :submissions, only: :index
    end

    resources :clef_tasks, only: [:show]
    resources :participants, only: :show, constraints: { id: /.+/ }, format: false
    resources :submissions, only: [:index, :show]

    get 'old_submissions/:id' => 'old_submissions#show'
    get 'old_submissions' => 'old_submissions#index'

    get 'user', to: 'oauth_credentials#show'
    get 'mailchimps/webhook' => 'mailchimps#verify', :as => :verify_webhook
    post 'mailchimps/webhook' => 'mailchimps#webhook', :as => :update_webhook
  end

  namespace :components do
    resources :notifications, only: [:index]
  end

  devise_for :participants, controllers: { omniauth_callbacks: 'participants/omniauth_callbacks' }

  resources :participants, only: [:show, :edit, :update, :destroy, :index] do
    get :sync_mailchimp
    get :regen_api_key
    get :remove_image
    patch :accept_terms
    match '/notifications', to: 'email_preferences#edit', via: :get
    match '/notifications', to: 'email_preferences#update', via: :patch
  end

  resources :job_postings, path: "jobs", only: [:index, :show]
  resources :gdpr_exports, only: [:create]
  resources :landing_page, only: [:index]
  match '/landing_page/host', to: 'landing_page#host', via: :get

  resources :organizer_applications, only: [:create]
  resources :organizers, except: [:new, :index] do
    get :remove_image
    get :regen_api_key
    get :clef_email
    resources :clef_tasks
    resources :members
  end
  resources :blogs do
    resources :votes, only: [:create, :destroy]
  end

  resources :teams, only: [:show], param: :name, constraints: { name: %r{[^?/]+} }, format: false # legacy
  resources :claim_emails, only: [:index, :create], controller: 'team_invitations/claim_emails'
  resources :team_invitations, only: [], param: :uuid do
    resources :acceptances, only: [:index, :create], controller: 'team_invitations/acceptances'
    resources :declinations, only: [:index, :create], controller: 'team_invitations/declinations'
    resources :cancellations, only: [:create], controller: 'team_invitations/cancellations'
  end

  resources :success_stories, only: [:index, :show]

  resources :clef_tasks do
    resources :task_dataset_files
  end

  resources :participant_clef_tasks

  resources :task_dataset_files do
    resources :task_dataset_file_downloads, only: :create
  end

  resources :participation_terms, only: [:index]

  # TODO: Move below challenge routes into Challenges module
  resources :challenges, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :reorder
      post :assign_order
    end
    member do
      get :remove_image
      get :clef_task
    end

    resources :teams, only: [:create, :show], param: :name, constraints: { name: %r{[^?/]+} }, format: false, controller: 'challenges/teams' do
      resources :invitations, only: [:create], controller: 'challenges/team_invitations'
    end
    resources :dataset_files
    resources :participant_challenges, only: [:index] do
      get :approve, on: :collection
      get :deny, on: :collection
    end
    resources :events
    resources :winners, only: [:index]
    resources :submissions do
      post :filter, on: :collection
    end
    resources :dynamic_contents, only: [:index]
    resources :leaderboards, only: :index
    resources :votes, only: [:create, :destroy]
    resources :follows, only: [:create, :destroy]
    resources :invitations, only: [] do
      collection { post :import }
    end
    resources :dataset_terms, only: [:update]
    resources :participation_terms, only: [:show, :create, :index]
    resources :challenge_rules, only: [:show]
    resources :challenge_participants
  end

  get '/load_more_challenges', to: 'challenges#load_more', as: :load_more_challenges

  resources :dataset_files, only: [] do
    resources :dataset_file_downloads, only: [:create]
  end

  resources :team_members, path: "our_team", only: [:index]

  match '/contact', to: 'pages#contact', via: :get
  match '/privacy', to: 'pages#privacy', via: :get
  match '/terms',   to: 'pages#terms',   via: :get
  match '/faq',     to: 'pages#faq',     via: :get
  match '/cookies', to: 'pages#cookies_info', via: :get
  match '/crowdai_migration', to: 'crowdai_migration#new', via: :get
  match '/crowdai_migration/save', to: 'crowdai_migration#create', via: :post

  resources :markdown_editors, only: [:index, :create] do
    put :presign, on: :collection
  end

  resources :challenge_calls, only: [] do
    resources :challenge_call_responses, only: [:create]
  end
  get '/call-for-challenges/:challenge_call_id/apply' => 'challenge_call_responses#new', :as => 'challenge_call_apply'
  get '/call-for-challenges/:challenge_call_id/applications/:id' => 'challenge_call_responses#show', :as => 'challenge_call_show'
  get 'SDSC' => 'challenge_call_responses#new', :challenge_call_id => 3

  ['400', '403', '404', '422', '500'].each do |code|
    get code, controller: :errors, action: :show, code: code
  end

  root 'landing_page#index'

  # catch all
  get '*short', to: 'short_urls#show'
end
