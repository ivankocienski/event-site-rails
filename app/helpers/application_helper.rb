module ApplicationHelper
  def external_link_to(url, text: nil, target: '_blank')
    text ||= url.sub(/^https?:\/\/(www.)?/, '').sub(/\/$/, '')

    link = link_to(text, url, target:)
    "<span class='external-link'>#{link}</span>".html_safe
  end
end
