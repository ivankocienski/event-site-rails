module ApplicationHelper
  def page_title_text
    title = content_for(:title)
    return "Event Site Rails" if title.blank?
    "#{title} - Event Site Rails"
  end

  def external_link_to(url, text: nil, target: '_blank')
    text ||= url.sub(/^https?:\/\/(www.)?/, '').sub(/\/$/, '')

    link = link_to(text, url, target:)
    "<span class='external-link'>#{link}</span>".html_safe
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
