
# load the fixture data into the fake models on startup

Rails.application.config.after_initialize do
  next unless Rails.env.development?

  puts "Loading data"

  Partner.load_from_fixture Rails.root.join('db/fixtures/partners.json')
  Event.load_from_fixture Rails.root.join('db/fixtures/events.json')
end
