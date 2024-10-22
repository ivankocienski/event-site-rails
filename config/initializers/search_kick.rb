
module SearchKickConfigurator
  extend self

  def run
    raise "FIXME: properly configure opensearch in production" if Rails.env.production?

    # see https://rubydoc.info/gems/opensearch-transport#configuration
    Searchkick.client_options[:transport_options] = { ssl: { verify: false } }

    begin
      Searchkick.client.cluster.health

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
end

SearchKickConfigurator.run

