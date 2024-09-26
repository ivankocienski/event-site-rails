
module KeywordLoaderAndTagger
  extend self

  def run
    Keyword.destroy_all

    load_keywords

    Partner.all.each do |partner|
      classify_partner partner
    end
  end

  private

  def load_keywords
    path = Rails.root.join('db/fixtures/keyword-list.txt')

    @keywords = 
      File.open(path).readlines
      .map { |line| line =~ /^(\w+)$/ && $1 }
      .keep_if(&:present?)
      .reduce({}) { |keyword_map, word|
        keyword_map[word] ||= Keyword.where(name: word).first || Keyword.create!(name: word)
        keyword_map
      }

    puts "Loaded #{@keywords.count} keywords"
  end

  def classify_partner(partner)
    # puts "[#{partner.id}] #{partner.name}"

    words = 
      [ partner.description, partner.summary ].join(' ')
      .strip
      .downcase
      .split(/\b/)

    words.each do |word|
      kw = @keywords[word]
      next if kw.blank?

      already_keyworded = partner.partner_keywords.where(keyword_id: kw.id).any?
      next if already_keyworded

      partner.keywords << kw
    end

    # puts "  key_words: [#{partner.keywords.count}] #{partner.keywords.pluck(:name).sort.join(', ')}"
  end
end

namespace :db do
  namespace :import do
    desc 'Loads keywords and tags partners'
    task load_keywords_and_tag_partners: :environment do
      KeywordLoaderAndTagger.run
    end
  end
end
