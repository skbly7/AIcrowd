ActiveAdmin.register Doorkeeper::Application do
  actions :index, :show

  index do
    column :id
    column :name
    column :redirect_uri
    column :scopes
    column :reponses do |res|
      res.access_grants.count
    end
    column :reponses do |res|
      res.access_tokens.count
    end
    actions
  end
end
