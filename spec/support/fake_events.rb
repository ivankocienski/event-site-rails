
module FakeEvents

  NOW = Time.new(2020, 6, 1, 12, 30).freeze
  
  def self.make_fake_event(on_day)
    # "2023-03-01T22:00:00+00:00"

    #on_day.strftime('%Y-%m-%dT%H:%M:%s-%z')

    {
      "id" => Faker::Number.number(digits: 10).to_s,
      "name" => Faker::Company.name,
      "description" => Faker::Lorem.paragraph,
      "summary" => Faker::Lorem.sentence,
      "startDate" => on_day.strftime('%Y-%m-%dT%H:%M:%S%:z'),
      "endDate" => (on_day + 1.hour).strftime('%Y-%m-%dT%H:%M:%S%:z'),
      "publisherUrl" => "https://#{Faker::Alphanumeric.alphanumeric(number: 30)}.com",
      "address" => {
        "streetAddress" => Faker::Address.street_address,
        "postalCode" => Faker::Address.postcode
      },
      "organizer" => {
        "id" => Faker::Number.number(digits: 10).to_s
      }
    }
  end

  def self.given_some_fake_events_exist
    return @fake_events if @fake_events.present?

    @fake_events = []

    # yesterday
    4.times do |n|
      @fake_events << make_fake_event(NOW - 1.day)
    end

    # today
    5.times do |n|
      @fake_events << make_fake_event(NOW)
    end

    # tomorrow
    6.times do |n|
      @fake_events << make_fake_event(NOW + 1.day)
    end

    # the next day
    7.times do |n|
      @fake_events << make_fake_event(NOW + 2.days)
    end

    # the next week
    8.times do |n|
      @fake_events << make_fake_event(NOW + 7.days)
    end

    Event.load_from_fake @fake_events
  end
end

