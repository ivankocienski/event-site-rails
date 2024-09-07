require 'json'

module Hack
  extend self

  def main
    path = File.expand_path(File.join(File.dirname(__FILE__), '../db/fixtures/events.json'))
    puts "Loading events from #{path}"
    data = JSON.parse(File.open(path).read)
    events = data['data']['eventsByFilter']
    puts "  Loaded #{events.count} events"

    events_by_name = {}
    events.each do |event|
      name = event['name']
      events_by_name[name] = (events_by_name[name] || 0) + 1
    end

    repeating = events_by_name.reduce(0) { |result, (name, count)| result + (count > 1 ? count : 0) }

    puts "found #{repeating} repeating events"

  end
end

Hack.main
