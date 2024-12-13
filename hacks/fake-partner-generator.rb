require 'faker'
require 'json'

module FakePartnerGenerator
  extend self

  def run
    Faker::Config.locale = 'en-GB'

    partners = 15.times.map { |n|
      {}.tap do |partner|
        partner[:name] = Faker::Company.name
        partner[:id] = 10_000 + (n * 100)

        partner[:description] = Faker::Lorem.paragraphs(number: 4 + Random.rand(4)).join if Random.rand(2) < 1
        partner[:summary] = Faker::Lorem.sentences(number: 2 + Random.rand(6)).join if Random.rand(2) < 1
        partner[:url] = Faker::Internet.url if Random.rand(2) < 1
        partner[:logo] = Faker::Company.logo if Random.rand(2) < 1

        partner[:contact] = {}
        partner[:contact][:email] = Faker::Internet.email if Random.rand(2) < 1
        partner[:contact][:telephone] = Faker::PhoneNumber.phone_number if Random.rand(2) < 1

        partner[:address] = {}
        partner[:address][:streetAddress] = Faker::Address.street_address if Random.rand(2) < 1
        partner[:address][:postalCode] = Faker::Address.postcode if Random.rand(2) < 1 
      end
    }

    # has the same shape as the import script output from placecal
    payload = {
      data: {
        partnersByTag: partners
      }
    }

    puts JSON.pretty_generate(payload)
  end
end

FakePartnerGenerator.run if $0 == __FILE__
