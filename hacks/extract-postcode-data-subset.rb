require 'zip'
require 'json'

=begin

Small script to extract a subset of postcode / enclosure data for saving
in to the test fixture directory

=end

module PostcodeExtractor
  extend self

  GEO_DATA_SRC = 'db/fixtures/geo-data.json.zip'
  OUTPUT_DIR = 'spec/fixtures/'

  def run
    load_geo_data

    subset_enclosures = {}
    subset_postcodes = {}

    postcode_strings = @postcodes.keys[0..100]

    postcode_strings.each do |postcode_s|
      subset_postcodes[postcode_s] =
        (@postcodes[postcode_s] || (raise "postcode not found `#{postcode_s}`"))

      @postcodes[postcode_s]['enclosure_codes'].each do |enclosure_code|
        next if enclosure_code == 'S99999999'
        subset_enclosures[enclosure_code] = 
          (@enclosures[enclosure_code] || (raise "enclosure not found `#{enclosure_code}`"))
      end
    end

    # saving
    payload = {
      version: @version,
      postcodes: subset_postcodes,
      enclosures: subset_enclosures
    }

    # puts '---'
    # puts payload.to_json

    output_path = File.join(OUTPUT_DIR, 'geo-data-subset.json.zip')
    puts "saving to #{output_path}"

    Zip::File.open(output_path, create: true) do |zip|
      zip.get_output_stream('geo-data.json') do |file|
        file.write payload.to_json
      end
    end
  end

  private

  def load_geo_data
    data = nil
    
    puts "loading Geo Data from #{GEO_DATA_SRC}"

    Zip::File.open(GEO_DATA_SRC) do |zip|
      data = JSON.parse(zip.read('geo-data.json'))
    end

    @version = data['version']
    @enclosures = data['enclosures']
    @postcodes = data['postcodes']

    puts "  version: #{@version}"
    puts "  enclosures: #{@enclosures.count}"
    puts "  postcodes: #{@postcodes.count}"
  end
end

PostcodeExtractor.run if $0 == __FILE__
