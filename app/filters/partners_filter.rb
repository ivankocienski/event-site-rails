
class PartnersFilter
  def initialize(params)
    @params = params
  end

  def active?
    [ name_value, keyword_value, geo_value ].any?(&:present?)
  end
  
  #def result
  #  return Partner.all unless active?
  #  []
  #end

  def empty?
    active? && result.empty?
  end

  def name_value
    @name_value ||= @params[:name].to_s.strip
  end

  def keyword_value
    @keyword_value ||= 
      begin
        keyword_param = @params[:keyword].to_s.strip
        return if keyword_param.blank?

        Keyword.where(name: keyword_param).first
      end
  end

  def geo_value
    @geo_value ||=
      begin
        geo_param = @params[:geo]
        return if geo_param.blank?
        
        GeoEnclosure.where(id: geo_param).first
      end
  end

  def search_form(view)
    name_field = view.text_field_tag(:name, name_value, placeholder: 'Filter by name')
    keyword_field = (view.hidden_field_tag(:keyword, keyword_value.name) if keyword_value.present?)
    geo_field = (view.hidden_field_tag(:geo, geo_value.id) if geo_value.present?)

    html =<<-HTML
    <form action="#{view.partners_path}" method="GET">
      #{name_field}
      #{keyword_field}
      #{geo_field}
      <button>Apply</button>
    </form>
    HTML

    html.html_safe
  end

  def title_part(view)
    return unless active?

    text = [
      ("by title with '<em>#{name_value}</em>'" if name_value.present?),
      ("on keyword '<em>#{keyword_value.name}</em>'" if keyword_value.present?),
      ("in area <em>#{geo_value.name}</em>" if geo_value.present?)
    ].keep_if(&:present?).join(' and ')

    reset_link_part = view.link_to('Reset filter', view.partners_path)

    html = <<-HTML
    <h2>Filtering #{text}</h2>
    <p>#{reset_link_part}</p>
    HTML

    html.html_safe
  end

  # def link_to(text, name: nil, keyword: nil, geo: nil)
  # end


  class PartnerMatch
    attr_reader :partner_id
    attr_reader :name
    attr_reader :summary
    attr_reader :desciption

    def initialize(record)
      @score = record['_score']

      partner = record['_source']
      @partner_id = partner['id']
      @name = partner['name']
      @summary = partner['summary']
      @description = partner['description']
    end

    def partner
      @partner ||= Partner.where(id: @partner_id).first
    end
  end

  class QueryResult
    attr_reader :count
    attr_reader :max_score

    def initialize(response)
      result = response['hits']

      @partner_hits = result['hits']
      @count        = result['total']['value']
      @max_score    = result['max_score']
    end

    def partners
      @partners ||= @partner_hits.map do |record|
        PartnerMatch.new(record)
      end
    end
  end

  #
  #

  def client
    @client ||= OpenSearch::Client.new(
      host: ENV['OPENSEARCH_URL'],
      user: ENV['OPENSEARCH_USER'],
      password: ENV['OPENSEARCH_PASSWORD'],
      transport_options: ({ ssl: { verify: false } } unless Rails.env.production?)
    )
  end
  
  def result
    @result ||=
      begin
        query = {}

        args = {
          index: 'partners',
          query: {
            fuzzy: {
              name: {
                value: (name_value if name_value.present?)
              }
            }
          }
        }

        QueryResult.new(client.search(args))
      end
  end
end

__END__


  def index
    @partner_name_filter = params[:name].to_s.strip

    partner_keyword_param = params[:keyword].to_s.strip
    @keyword_for_filter = Keyword.where(name: partner_keyword_param).first if partner_keyword_param.present?

    geo_param = params[:geo]
    @geo_enclosure = GeoEnclosure.where(id: geo_param).first if geo_param.present?

    @partners = PartnersIndex.find_all

#    @partners = Partner.all
#
#    # name
#    @partners = @partners.with_fuzzy_name(@partner_name_filter) if @partner_name_filter.present?
#
#    # keyword
#    @partners = @partners.with_keyword(@keyword_for_filter) if @keyword_for_filter.present?
#
#    # geo
#    @partners = @partners.in_geo_enclosure(@geo_enclosure) if @geo_enclosure.present?
#    
#    @partners = @partners.order(:name)
  end



# /app/views/partners/index.html.haml

- content_for(:title) { "Partners" }

%h1 Partners

= form_tag partners_path, method: 'GET' do
  = text_field_tag :name, @partner_filter.name_value, placeholder: 'Filter by name'
  = hidden_field_tag :keyword, @partner_filter.keyword_valuename if @keyword_for_filter.present?
  = hidden_field_tag :geo, @partner_filter.geo_value.id if @geo_enclosure.present?
  = button_tag 'Apply', name: ''

- if @partner_filter.active?
  %h2= partner_index_filter_title_text(@partner_name_filter, @keyword_for_filter, @geo_enclosure)
  %p= link_to 'Reset filter', partners_path
  %br

  - if @partners.empty?
    %h2 No results found :(

- @partners.each do |partner|
  %article.partner
    %h3= link_to partner.name, partner_path(partner.slug)
    .indent
      %p= partner.summary
      - if partner.address.ward.present?
        %p in #{link_to partner.address.ward.name, partners_path(geo: partner.address.ward.id)}
      - if partner.partner_keywords.any?
        %p= keywords_for_partner partner
      %br
