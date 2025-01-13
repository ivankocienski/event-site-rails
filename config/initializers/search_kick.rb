
module AppSearchSystem
  extend self

  def client
    return @client if @client

    raise "FIXME: properly configure opensearch in production" if Rails.env.production?

    Searchkick.client_options[:transport_options] = { ssl: { verify: false } }
    Searchkick.client_options[:host] = ENV['OPENSEARCH_URL']
    Searchkick.client_options[:user] = ENV['OPENSEARCH_USER']
    Searchkick.client_options[:password] = ENV['OPENSEARCH_PASSWORD']

    #client = OpenSearch::Client.new(
    #  host: ENV['OPENSEARCH_URL'],
    #  user: ENV['OPENSEARCH_USER'],
    #  password: ENV['OPENSEARCH_PASSWORD'],
    #  transport_options: ({ ssl: { verify: false } } unless Rails.env.production?)
    #)

    Searchkick.client.cluster.health

    @client = Searchkick.client

  rescue Faraday::ConnectionFailed => e
    abort <<-MSG

      ---------------------------------------------
      -                                           -
      -   ERROR: Opensearch server not running?   -
      -                                           -
      ---------------------------------------------

    MSG
  end
end

AppSearchSystem.client # load this on initialize
