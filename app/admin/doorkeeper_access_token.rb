ActiveAdmin.register Doorkeeper::AccessToken do
  actions :index, :show

  index do
    column :id
    column :resource_owner_id
    column :application_id
    column :expires_in
    column :scopes
    actions
  end
end
