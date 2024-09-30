module ApplicationHelper
  def page_title_text
    title = content_for(:title)
    return "Event Site Rails" if title.blank?
    "#{title} - Event Site Rails"
  end

  def external_link_to(url, text: nil, target: '_blank', alt: nil)
    text ||= url.sub(/^https?:\/\/(www.)?/, '').sub(/\/$/, '')

    link = link_to(text, url, target:, alt:)
    "<span class='external-link'>#{link}</span>".html_safe
  end

  def address_map_link_to(address, filter_path)
    address_s = address.to_s
    url = "https://maps.google.com/?q=#{URI::DEFAULT_PARSER.escape(address_s)}"
    link = external_link_to(url, text: address_s, alt: 'Open map in new tab')
    ward_part = nil

    ward = address.ward
    if ward.present?
      ward_link = send(filter_path, { geo: ward.id })
      ward_part = " (in #{link_to ward.name, ward_link})"
    end

    "#{link}#{ward_part}".html_safe
  end

  def format_for_content(text)
    content = simple_format(text)
    "<div class='content'>#{content}</div>".html_safe
  end

  def nav_link_to(page, path, route = {})
    active = route.all? { |key, value| params[key] == value }
    link_to(page, path, class: ('active' if active)).html_safe
  end
end
