module DbInfoTask
  extend self

  IGNORE_TABLES = %w[ar_internal_metadata delayed_jobs schema_migrations seed_migration_data_migrations].freeze

  def run
    puts 'Database Info:'
    puts "  Rails.env=#{Rails.env}"
    puts "  adapter='#{db_config['adapter']}'"
    puts "  database='#{db_config['database']}'"

    if db_config['adapter'] != 'sqlite3'
      puts "  host='#{db_config['host']}'"
      puts "  user='#{db_config['username']}'"
      puts "  password=[#{'*' * db_config['password'].to_s.length}]"
    end
    puts ''

    table_info, max_len = read_table_info

    table_info.each do |name, count|
      count_s = count.positive? ? count : '.'
      puts "  #{name.rjust(max_len)}  #{count_s}"
    end

    puts ''
  end

  def read_table_info
    max_len = 0
    table_info = []

    ActiveRecord::Base.connection.tables.sort.each do |table|
      next if IGNORE_TABLES.include?(table)

      sql = "select count(*) as count from #{table}"
      result = ActiveRecord::Base.connection.execute(sql)
      count = result.first['count']

      max_len = table.length if table.length > max_len
      table_info << [table, count]
    end

    [ table_info, max_len ]
  end

  def db_config
    @db_config ||= Rails.configuration.database_configuration[Rails.env]
  end
end

namespace :db do
  desc 'Prints out a list of tables and their counts'
  task info: :environment do
    DbInfoTask.run
  end
end

