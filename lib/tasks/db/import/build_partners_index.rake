
module Indexer
  extend self

  def client
    @client ||= OpenSearch::Client.new(
      host: ENV['OPENSEARCH_URL'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: ({ ssl: { verify: false } } unless Rails.env.production?)
    )
  end

  def ingest_partners
    client.indices.delete(index: 'partners')
    client.indices.create(index: 'partners')
    
    partners = Partner.select(:id, :name, :summary, :description).as_json
    if partners.empty?
      puts "No partners found?"
      return
    end

    partners.each do |partner|
      client.index index: 'partners', id: partner[:id], body: partner, refresh: true
    end

    puts "done. indexed #{partners.count} partners"
  end

  def poke
    found = PartnersIndex.find_all
    puts "found="
    puts JSON.pretty_generate(found.partners.as_json)
  end
end

namespace :db do
  namespace :import do
    desc 'Scan partners table and send it to the opensearch index'
    task build_partners_index: :environment do
      # Indexer.ingest_partners
      Indexer.poke
    end
  end
end
