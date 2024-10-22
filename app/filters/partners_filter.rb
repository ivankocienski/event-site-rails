
class PartnersFilter
  def initialize(params)
    @params = params
  end

  def active?
    [ name_value, keyword_value, geo_value ].any?(&:present?)
  end
  
  def empty?
    active? && result.empty?
  end

  def name_value
    @name_value ||= @params[:name].to_s.strip
  end

  #def link_to(title, options={})
  #end

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

  #
  #

  def result
    @result ||=
      begin
        return Partner.order(:name) unless active?

        partners = Partner.all

        # TODO: ordering by match score if name value present

        if name_value.present?
          partners = partners.with_fuzzy_string(name_value)
          return Partner.none if partners.empty?
        end

        # keyword
        partners = partners.with_keyword(keyword_value) if keyword_value.present?

        # geo
        partners = partners.in_geo_enclosure(geo_value) if geo_value.present?

        partners = partners.order(:name)
      end
  end
end

