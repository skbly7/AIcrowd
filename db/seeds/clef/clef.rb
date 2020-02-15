  # CLEF Organizers
  Organizer.create!([
    {id: 22, organizer: "ImageCLEF", image_file: open('https://www.imageclef.org/files/tech_logo.png'), address: "Institute of Information Systems, HES-SO Valais", description: "", approved: true, slug: "imageclef", tagline: "ImageCLEF", challenge_proposal: "", api_key: "14b4a11368bb0e22134137aa55bf86af", clef_organizer: true},
    {id: 23, organizer: "LifeCLEF", image_file: open('http://www.imageclef.org/system/files/Lifeclef.logo_.jpg'), address: "INRIA", description: "my description", approved: true, slug: "my slug", tagline: "my tagline", challenge_proposal: "", api_key: "", clef_organizer: true}
  ])


  member_imageclef_ids = [101634, 101635, 101636, 101637, 101638]

  member_imageclef_ids.each_with_index do |id, index|
    Participant.create!(
      id: id,
      organizer_id: 22,
      email: "o-imageclef-#{index}@example.com",
      password: 'password',
      password_confirmation: 'password',
      name: "o-imageclef-#{index}",
      confirmed_at: Time.now,
      bio: "I am test imageclef organizer nbr #{index}")
  end

  member_lifeclef_ids = [102634, 102635, 102636, 102637, 102638]

  member_lifeclef_ids.each_with_index do |id, index|
    Participant.create!(
      id: id,
      organizer_id: 23,
      email: "o-lifeclef-#{index}@example.com",
      password: 'password',
      password_confirmation: 'password',
      name: "o-lifeclef-#{index}",
      confirmed_at: Time.now,
      bio: "I am test lifeclef organizer nbr #{index}")
  end
