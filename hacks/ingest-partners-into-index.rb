require './config/environment'

module Searcher
  extend self

  def client
    @client ||= OpenSearch::Client.new(
      host: 'https://localhost:9200',
      user: 'admin',
      password: 'viewoo6ohvaogh9Raish',
      transport_options: { ssl: { verify: false } }
    )
  end


  def ingest
    puts client.cluster.health

    client.indices.delete(index: 'partners')
    client.indices.create(index: 'partners')
    
    partners = Partner.select(:id, :name, :summary, :description).as_json

    partners.each do |partner|
      client.index index: 'partners', id: partner[:id], body: partner, refresh: true
    end
  end

  def query
    puts client.search(index: 'partners')
  end
end

#Searcher.ingest

Searcher.query
