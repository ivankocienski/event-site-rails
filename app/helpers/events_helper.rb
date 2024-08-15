module EventsHelper
  
  def render_event_by_day_list(events)
    html = []
    last_day = events.first.start_date.beginning_of_day
    day_count = 1

    html << "<h2>#{last_day}</h2>"

    events.each do |event|
      if event.start_date.beginning_of_day != last_day
        html << "<h2>#{last_day}</h2>"
        last_day = event.start_date.beginning_of_day
        day_count += 1
        break if day_count > 7
      end
      html << "<p>#{link_to(event.name, event_path(event.id))}</p>"
    end

    html.join.html_safe
  end

end
