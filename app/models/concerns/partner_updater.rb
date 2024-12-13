
class PartnerUpdater
  attr_reader :partner

  def initialize(partner)
    @partner = partner
  end

  def update_and_save(new_values)
    Partner.transaction do

      update_fields new_values

      render_description_html

      scan_for_keywords

      #reindex_text_fields

      #lookup_postcode

      save!
    end
  end

  def update_fields(new_values)
    new_values.each do |field, value|
      partner[field] = value
    end
  end

  def save!
    partner.save!
  end


  def render_description_html
    return unless partner.description_changed?

    # TODO: maybe filter out HTML from text as well
    partner.description_html = Kramdown::Document.new(partner.description).to_html
  end

  def scan_for_keywords
    return unless partner.description_changed? || partner.summary_changed?

    partner_keyword_set = partner.partner_keywords.pluck(:keyword_id)

    # (not the fastest word scanner)
    all_partner_words = 
      [ partner.name, partner.description, partner.summary ].join(' ')
      .strip
      .downcase
      .split(/\b/)
      .delete_if { |word| word =~ /^\s+$/ }
      .uniq

    # add new/existing back again
    all_partner_words.each do |partner_word|
      found = Keyword.where(name: partner_word).first
      next if found.blank?

      # maybe add this
      partner.partner_keywords.build(keyword_id: found.id) unless partner_keyword_set.include?(found.id)

      # remove this from the delete set
      partner_keyword_set.delete found.id
    end

    partner.partner_keywords.where( keyword_id: partner_keyword_set ).destroy_all

    true
  end

  def reindex_text_fields
    # does this happen automatically?
    # what about deleting the partner, does that de-index automatically?
  end

  def lookup_postcode
  end
end

__END__

I decided to use this pattern so I could keep the models thin, make the updater
scripts less complicated and hopefully make this logic testable in specs.
