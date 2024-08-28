
module EventStore
  def self.events
    @events || []
  end
  def self.load_from_fixture(path)
    Rails.logger.info "Loading event data from #{path}"
    data = JSON.parse(File.open(path).read)
    @events = data['data']['eventsByFilter'].map { |event_data| Event.new(event_data) }
  end
end
