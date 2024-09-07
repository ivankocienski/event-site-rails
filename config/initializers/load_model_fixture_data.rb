
# require Rails.root.join('db/stores/partner_store')
require Rails.root.join('db/stores/event_store')

# load the fixture data into the fake models on startup

Rails.application.config.after_initialize do
  next unless Rails.env.development?

  puts "Loading data"

  # PartnerStore.load_from_fixture Rails.root.join('db/fixtures/partners.json')
  EventStore.load_from_fixture Rails.root.join('db/fixtures/events.json')
end
