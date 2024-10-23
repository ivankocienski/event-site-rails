require './config/environment'

module Searcher
  extend self

  class PartnerMatch
    attr_reader :partner_id
    attr_reader :name
    attr_reader :summary
    attr_reader :desciption

    def initialize(record)
      @score = record['_score']

      partner = record['_source']
      @partner_id = partner['id']
      @name = partner['name']
      @summary = partner['summary']
      @description = partner['description']
    end

    def partner
      @partner ||= Partner.where(id: @partner_id).first
    end
  end
  
  class QueryResult
    attr_reader :count
    attr_reader :max_score

    def initialize(response)
      result = response['hits']

      @partner_hits = result['hits']
      @count        = result['total']['value']
      @max_score    = result['max_score']
    end

    def partners
      @partners ||= @partner_hits.map do |record|
        PartnerMatch.new(record)
      end
    end
  end
  
  def client
    @client ||= OpenSearch::Client.new(
      host: 'https://localhost:9200',
      user: 'admin',
      password: 'viewoo6ohvaogh9Raish',
      transport_options: { ssl: { verify: false } }
    )
  end


  def ingest
    Partner.reindex
#    puts client.cluster.health
#
#    client.indices.delete(index: 'partners')
#    client.indices.create(index: 'partners')
#    
#    partners = Partner.select(:id, :name, :summary, :description).as_json
#
#    partners.each do |partner|
#      client.index index: 'partners', id: partner[:id], body: partner, refresh: true
#    end
  end

  def query
    # puts client.search(index: 'partners')

    # filter = PartnersFilter.new()
    filter = PartnersFilter.new(name: 'lgbt')

    puts JSON.pretty_generate(filter.result.as_json)
    puts "\n\n===\nFound #{filter.result.length} results"
  end

  def health
    client = Searchkick.client.cluster.health

    puts client
  end
end

# Searcher.ingest

#Searcher.query

Searcher.health





__END__


# the old way with SQL:
#
#

  def index
    @partner_name_filter = params[:name].to_s.strip

    partner_keyword_param = params[:keyword].to_s.strip
    @keyword_for_filter = Keyword.where(name: partner_keyword_param).first if partner_keyword_param.present?

    geo_param = params[:geo]
    @geo_enclosure = GeoEnclosure.where(id: geo_param).first if geo_param.present?

    @partners = PartnersIndex.find_all

#    @partners = Partner.all
#
#    # name
#    @partners = @partners.with_fuzzy_name(@partner_name_filter) if @partner_name_filter.present?
#
#    # keyword
#    @partners = @partners.with_keyword(@keyword_for_filter) if @keyword_for_filter.present?
#
#    # geo
#    @partners = @partners.in_geo_enclosure(@geo_enclosure) if @geo_enclosure.present?
#    
#    @partners = @partners.order(:name)
  end






# the newer way with opensearch
#
#
#
#
#

  def client
    @client ||= OpenSearch::Client.new(
      host: ENV['OPENSEARCH_URL'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: ({ ssl: { verify: false } } unless Rails.env.production?)
    )
  end
  
  def result
    @result ||=
      begin
        query = {}

        args = {
          index: 'partners',
          query: {
            fuzzy: {
              name: {
                value: (name_value if name_value.present?)
              }
            }
          }
        }

        QueryResult.new(client.search(args))
      end
  end



  # from /app/models/partner.rb
#  scope :with_fuzzy_name, lambda { |name_string|
#    name_string = name_string.to_s.gsub(/\s+/, '') # remove whitespace
#    return none if name_string.blank?
#
#    name_pattern = name_string
#      .chars
#      .map { |ch| sanitize_sql(ch) }
#      .join('%')
#
#    where('name LIKE ?', "%#{name_pattern}%")
#  }
partners_test/_search 
{"query":{"bool":{"should":[{"dis_max":{"queries":[{"multi_match":{"query":"zulu alpha","boost":10,"operator":"and","analyzer":"searchkick_search","fields":["*.analyzed"],"type":"best_fields"}},{"multi_match":{"query":"zulu alpha","boost":10,"operator":"and","analyzer":"searchkick_search2","fields":["*.analyzed"],"type":"best_fields"}},{"multi_match":{"query":"zulu alpha","boost":1,"operator":"and","analyzer":"searchkick_search","fuzziness":1,"prefix_length":0,"max_expansions":3,"fuzzy_transpositions":true,"fields":["*.analyzed"],"type":"best_fields"}},{"multi_match":{"query":"zulu alpha","boost":1,"operator":"and","analyzer":"searchkick_search2","fuzziness":1,"prefix_length":0,"max_expansions":3,"fuzzy_transpositions":true,"fields":["*.analyzed"],"type":"best_fields"}}]}}]}},"timeout":"11000ms","_source":["id"],"size":10000}
