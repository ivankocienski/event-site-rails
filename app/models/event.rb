class Event

  attr_reader :id
  attr_reader :name
  attr_reader :summary
  attr_reader :description
  attr_reader :start_date
  attr_reader :end_date
  attr_reader :publisher_url
  attr_reader :address
  attr_reader :organizer_id

  class EventAddress
    attr_reader :street_address
    attr_reader :post_code

    def initialize(from)
      return unless from.is_a?(Hash)
      @street_address = from['streetAddress']
      @post_code = from['postalCode']
    end
  end

  def initialize(data)
    return unless data.is_a?(Hash)
    @id = data['id'].to_i
    @name = data['name']
    @summary = data['summary']
    @description = data['description']
    @start_date = Time.zone.parse(data['startDate'])
    @end_date = Time.zone.parse(data['endDate'])
    @publisher_url = data['publisherUrl']
    @organizer_id = data['organizer']['id']

    @address = EventAddress.new(data['address'])
  end

  def self.load_from_fixture(path)
    Rails.logger.info "Loading event data from #{path}"
    data = JSON.parse(File.open(path).read)
    @events = data['data']['eventsByFilter'].map { |event_data| Event.new(event_data) }
  end

  def self.count
    (@events || []).count
  end

  def self.find_in_future(date)
    date = date.beginning_of_day

    (@events || []).filter { |event| event.start_date.beginning_of_day >= date }
  end

  def self.find_on_day(date)
    date = date.beginning_of_day

    (@events || []).filter { |event| event.start_date.beginning_of_day == date }
  end

  def self.find_by_id(want_id)
    return unless want_id.present?
    want_id = want_id.to_i
    (@events || []).find { |event| event.id == want_id }
  end
end


