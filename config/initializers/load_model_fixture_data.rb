
# load the fixture data into the fake models on startup

if Rails.env.development?
  require Rails.root.join('app/models/partner')
  require Rails.root.join('app/models/event')

  Partner.load_from_fixture Rails.root.join('db/fixtures/partners.json')
  Event.load_from_fixture Rails.root.join('db/fixtures/events.json')
end

