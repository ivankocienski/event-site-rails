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

    def present?
      @street_address.present? || @post_code.present?
    end

    def to_s
      [ @street_address, @post_code ].filter(&:present?).join(', ')
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
    @organizer_id = data['organizer']['id'].to_i

    @address = EventAddress.new(data['address'])
  end

  def organizer
    @organizer ||= Partner.find_by_id(@organizer_id)
  end

  def self.all
    EventStore.events
  end

  def self.count
    EventStore.events.count
  end

  def self.find_in_future(date)
    date = date.beginning_of_day

    EventStore.events.filter { |event| event.start_date.beginning_of_day >= date }
  end

  def self.find_on_day(date)
    date = date.beginning_of_day

    EventStore.events.filter { |event| event.start_date.beginning_of_day == date }
  end

  def self.find_by_id(want_id)
    return unless want_id.present?
    want_id = want_id.to_i
    EventStore.events.find { |event| event.id == want_id }
  end

  def self.find_by_organizer_id(organizer_id)
    EventStore.events.filter { |event| event.organizer_id == organizer_id }
  end
end


