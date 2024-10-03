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

  def fancy_time_format(time)
    time.strftime(time.min == 0 ? '%l%P' : '%l.%M%P')
  end

  def fancy_date_format(time)
    day_s = time.day.ordinalize

    time.strftime "%A #{day_s} %B, %Y"
  end

  def fancy_time_period_format(start_at, end_at)
    # minutes
    delta = ((end_at - start_at) / 60).floor
    return 'zero minutes' if delta < 1
    return 'all day' if delta >= 1410 # 11 hours, 30 minutes

    hour_v = delta / 60
    minute_v = delta % 60

    minute_s = pluralize(minute_v, 'minute')

    if hour_v == 0
      return minute_v == 30 ? 'half an hour' : minute_s
    end

    hour_s = "#{hour_v} hours"
    if minute_v == 0
      return hour_v == 1 ? 'an hour' : hour_s
    end

    if minute_v == 30
      return "#{hour_v == 1 ? 'one' : hour_v} and a half hours"
    end

    "#{hour_s} and #{minute_s}"
  end
  # hmm: why am i not using `distance_of_time_in_words`?
end
