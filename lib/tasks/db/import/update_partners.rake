
namespace :db do
  namespace :import do
    desc 'Imports partner updates from snapshot'
    task :update_placecal_partners, [:snapshot_path] => :environment do |_t, args|
      PartnerImportUpdater.process_from args[:snapshot_path]
    end
  end
end
