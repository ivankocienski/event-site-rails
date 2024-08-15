
# load the fixture data into the fake models on startup

if Rails.env.development?
  require Rails.root.join('app/models/partner')

  Partner.load_from_fixture Rails.root.join('db/fixtures/partners.json')
end

