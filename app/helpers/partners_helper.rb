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
    parts << link_to(partner.url, partner.url, target: '_blank' ) if partner.url.present?
    parts << partner.address.to_s if partner.address.present?

    parts.join(' | ').html_safe
  end

  def render_partner_event_by_day_list(events)
    return if events.empty?

    html = []
    last_day = events.first.start_date.beginning_of_day
    day_count = 1

    events.each do |event|
      day_of_event = event.start_date.beginning_of_day
      if day_of_event != last_day
        day_count += 1
        break if day_count > 7
        last_day = day_of_event

        html << "<h3>#{last_day.strftime(EventsHelper::DATE_DAY_FORMAT)}</h3>"
      end

      time_part = event.start_date.strftime(EventsHelper::DATE_TIME_FORMAT)
      event_name_part = link_to(event.name, event_path(event.id))

      html << "<p><span class='time'>#{time_part}</span> #{event_name_part}</p>"
    end

    html.join("\n").html_safe
  end
end
