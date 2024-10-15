module PartnersHelper
  def partner_contact_info(partner)
    contact = partner.contact

    parts = []
    parts << link_to(contact.email, "mailto:#{contact.email}") if contact.email.present?
    parts << link_to(contact.telephone, "tel:#{contact.telephone}") if contact.telephone.present?

    parts.join(', ').html_safe
  end

  def partner_address_info(partner)
    parts = []
    parts << external_link_to(partner.url) if partner.url.present?
    parts << address_map_link_to(partner.address, :partners_path) if partner.address.present?

    parts.join(' | ').html_safe
  end

  def render_partner_event_by_day_list(event_instances)
    return if event_instances.empty?

    html = []
    last_day = event_instances.first.starts_at.beginning_of_day
    day_count = 1

    event_instances.each do |event_instance|
      day_of_event = event_instance.starts_at.beginning_of_day
      if day_of_event != last_day
        day_count += 1
        break if day_count > 7
        last_day = day_of_event

        html << "<h3>#{fancy_date_format(last_day)}</h3>"
      end

      time_part = fancy_time_format(event_instance.starts_at)
      event_name_part = link_to(event_instance.event.name, event_path(event_instance))

      html << "<p><span class='time'>#{time_part}</span> #{event_name_part}</p>"
    end

    html.join("\n").html_safe
  end

  def keywords_for_partner(partner)
    extra_params = {
      name: (@partner_name_filter if @partner_name_filter.present?),
      geo: (@geo_enclosure.id if @geo_enclosure.present?)
    }

    partner
      .keywords
      .order(:name)
      .map { |kw|
        link_to kw.name,
          partners_path(extra_params.merge({keyword: kw.name})),
          class: 'keyword' }
      .join(' &bull; ')
      .html_safe
  end
end
