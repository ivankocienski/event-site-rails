require 'rails_helper'
require_relative '../../hacks/data-import-updater'

RSpec.describe DataImporterUpdaterTask do
  # NOTE: the fixture data was created by
  #   /hacks/fake-partner-generator.rb

  context 'adding new partners' do
    it 'creates records' do
      file_path = Rails.root.join('spec/fixtures/partners-new.json')
      DataImporterUpdaterTask.process_from file_path

      expect(Partner.count).to eq 5
    end

    it 'does not create duplicates' do
      file_path = Rails.root.join('spec/fixtures/partners-new.json')
      DataImporterUpdaterTask.process_from file_path
      DataImporterUpdaterTask.process_from file_path

      expect(Partner.count).to eq 5
    end
  end

  context 'updating existing members' do
    it 'updates existing records' do
      file_path = Rails.root.join('spec/fixtures/partners-new.json')
      DataImporterUpdaterTask.process_from file_path

      file_path = Rails.root.join('spec/fixtures/partners-update-1.json')
      DataImporterUpdaterTask.process_from file_path

      expect(Partner.count).to eq 10
    end
  end

  context 'removing partners' do
    it 'destroys records' do
      file_path = Rails.root.join('spec/fixtures/partners-update-1.json')
      DataImporterUpdaterTask.process_from file_path

      expect(Partner.count).to eq 10

      file_path = Rails.root.join('spec/fixtures/partners-remove.json')
      DataImporterUpdaterTask.process_from file_path

      expect(Partner.count).to eq 7
    end
  end

  # TODO: verify that when a Partner is updated all the dependent 
  #   fields get reprocessed when needed: geo_location, description/summary 
  #   HTML, keyword scanning and reindexing
end


__END__

Notes

the update algorithm is tricky.

if the database is empty, just add the "create pile"

if not:
    load the payload file into memory, index off of placecal_id
    load the partners from the database, index off of placecal_id

    for each payload partner:
      if it exists in the database, add it to the "update pile"
      if it DOES NOT exist in the database, add it to the "create pile"

    subtract the payload set from the database set
      add these to the "delete pike"

for all create pile partners:
  create a AR model
    render any HTML needed
    figure out postcode geo location (if present)
    scan for keywords
    send data to index

for all update pile partners:
  if name, summary or description has been changed
    render any HTML needed
    clear and scan for keywords
    send data to index

  if postcode has changed/been added:
    figure out postcode location (or remove if nil)

for all delete pile partners:
  remove from DB
  remove from index


----
all this is just for partners, doing this with events will be trickier

