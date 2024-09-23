module HomeHelper

  def _render_partner_thing(partner)
    link = link_to(partner.name, partner_path(partner))

    "<div class='partner'>" +
      "<h2>#{link}</h2>" +
      "<p>#{partner.summary}</p>" +
      "</div>"
  end

  def _render_keyword_thing(keyword)
    link = link_to(keyword.name, partners_path(keyword: keyword.name))

    "<div class='keyword'>" +
      "<h2>#{link} (#{keyword.partner_keywords.count})</h2>" +
      "</div>"
  end

  def _render_event_thing(event_instance)
    event = event_instance.event

    link = link_to(event.name, event_path(event_instance))
    "<div class='event'>" +
      "<h2>#{link}</h2>" +
      "<p>#{event.summary}</p>" +
      "</div>"
  end

  def render_hot_feed(feed)
    html_chunks = @hot_feed.map do |hot_thing|
      case hot_thing
      when Keyword then _render_keyword_thing(hot_thing)
      when Partner then _render_partner_thing(hot_thing)
      when EventInstance then _render_event_thing(hot_thing)
      else
        raise "Unknown hot_thing: #{hot_thing.class}"
      end
    end

    html_chunks
      # .map { |chunk| "#{chunk}</p>" }
      .join("\n<br />\n")
      .html_safe

  end

  def render_hot_keywords(keywords)
    keywords
      .map { |kw|
        link = link_to(kw.name,
                       partners_path(keyword: kw.name),
                       class: 'keyword')
        "#{link} (#{kw.partner_keywords.count})"
      }
      .join(' &bull; ')
      .html_safe
  end
  # lordy this isn't very testable, lol
end
