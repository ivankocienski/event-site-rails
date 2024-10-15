
require './config/environment'

module IndexPeeker
  extend self

  attr_reader :name_value

  class PartnerMatch
    attr_reader :partner_id
    #attr_reader :name
    #attr_reader :summary
    #attr_reader :desciption

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

  def run
    @name_value = "hoxton"

    puts JSON.pretty_generate(result.partners.as_json)
  end

  def client
    @client ||=
      begin
        args = {
          host: ENV['OPENSEARCH_URL'],
          user: ENV['OPENSEARCH_USER'],
          password: ENV['OPENSEARCH_PASSWORD'],
          transport_options: ({ ssl: { verify: false } } unless Rails.env.production?)
        }
        # puts "client: args=#{args}"

        OpenSearch::Client.new args
      end
  end
  
  def result
    @result ||=
      begin
        query_args = {
          query: {
            fuzzy: {
              name: {
                value: (name_value if name_value.present?)
              }
            }
          }
        }
        # puts "result: args=#{query_args}"

        QueryResult.new(client.search(index: 'partners', body: query_args))
      end
  end
end

IndexPeeker.run

