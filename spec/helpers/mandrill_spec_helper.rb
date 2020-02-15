res = [
  [{ "email"         => "lela@lang.co.uk",
     "status"        => "sent",
     "_id"           => "03153045634d41ef92b229c0bdeae317",
     "reject_reason" => nil }],
  { subject:           "[AIcrowd/Possimus qui consequatur et debitis.] Quia accusamus esse qui corrupti corporis quis et.",
    from_name:         "AIcrowd",
    from_email:        "no-reply@aicrowd.com",
    to:                [{ email: "lela@example.com", type: "to" }, { email: "lela2@example.com", type: "to" }],
    global_merge_vars: [{ name: "NAME", content: "Example_name_10" },
                        { name: "BODY", content: "<p>A new post has been made to the <br/>[\"consequatur\", \"non\", \"cupiditate\", \"et\"]<br/>yo" },
                        { name: "UNSUBSCRIBE_LINK", content: "http://localhost:3000/participants/151/email_preferences/151/edit?unsubscribe_token=VHMZh4IHVyIf937vRC1W2JgerNwxpP1h" }] }
]

describe MandrillSpecHelper do
  let(:man) { described_class.new(res) }

  it '#status' do
    expect(man.status).to eq('sent')
  end

  it '#reject_reason' do
    expect(man.reject_reason).to eq(nil)
  end

  it '#merge_var' do
    expect(man.merge_var('NAME')).to eq("Example_name_10")
    expect(man.merge_var('UNSUBSCRIBE_LINK')).to eq("http://localhost:3000/participants/151/email_preferences/151/edit?unsubscribe_token=VHMZh4IHVyIf937vRC1W2JgerNwxpP1h")
  end

  it '#subject' do
    expect(man.subject).to eq("[AIcrowd/Possimus qui consequatur et debitis.] Quia accusamus esse qui corrupti corporis quis et.")
  end

  it '#from_name' do
    expect(man.from_name).to eq("AIcrowd")
  end

  it '#from_email' do
    expect(man.from_email).to eq("no-reply@aicrowd.com")
  end

  it '#email_array' do
    expect(man.email_array).to match_array(["lela@example.com", "lela2@example.com"])
  end
end
