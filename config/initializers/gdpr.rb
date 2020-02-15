GDPR_FIELDS = [
  {
    table:    'Participant',
    id_field: 'id',
    fields:   [
      :id,
      :email,
      :created_at,
      :updated_at,
      :timezone,
      :name,
      :bio,
      :website,
      :github,
      :linkedin,
      :twitter,
      :image_file,
      :affiliation,
      :country_cd,
      :address,
      :first_name,
      :last_name
    ]
  }
].freeze
