require 'json'
require 'faker'

=begin
generates a JSON file for loading in to integration
specs that is an approximation of live data.

partners: [] {
  name:
  summary:
  description:
  ...
  events: [] {
    name:
    summary:
    description:
    starts_at:
    ends_at:
  }
}

=end

module FixtureProcessor
  extend self

  def main
    load_partner_data
    puts "Loaded #{@original_partner_data.count} partners"

    partner_sample = @original_partner_data.shuffle.take(10)

    # puts JSON.pretty_generate(partner_sample)

    output_path = File.join(root_dir, '/spec/fixtures/live_data_sample.json')
    File.open(output_path, 'w') do |file|
      file.print partner_sample.to_json
    end
  end

  def load_partner_data
    data_path = File.join(root_dir, '/db/fixtures/partners.json')
    raw_data = JSON.parse(File.open(data_path).read)

    @original_partner_data =
      raw_data['data']['partnersByTag']
      .map { |data|
        data['address'] ||= {}
        data['contact'] ||= {}
             
        { 
          id: data['id'].to_i,
          name: data['name'],
          summary: data['summary'],
          description: data['description'],
          logo_url: data['logo'],
          url: data['url'],

          address_street: data['address']['streetAddress'],
          address_postcode: data['address']['postalCode'],
          contact_email: data['contact']['email'],
          contact_telephone: data['contact']['telephone']
        }
      }
  end

  def root_dir 
    @root_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end

FixtureProcessor.main
