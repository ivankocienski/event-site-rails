module EventsHelper
  
  def render_event_by_day_list(events)
    return if events.empty?

    html = []
    last_day = events.first.start_date.beginning_of_day
    day_count = 1

    html << "<h2>#{link_to last_day, events_path(day: last_day.strftime('%Y-%m-%d'))}</h2>"

    events.each do |event|
      if event.start_date.beginning_of_day != last_day
        html << "<h2>#{link_to last_day, events_path(day: last_day.strftime('%Y-%m-%d'))}</h2>"
        last_day = event.start_date.beginning_of_day
        day_count += 1
        break if day_count > 7
      end
      html << "<p>#{link_to(event.name, event_path(event.id))}</p>"
    end

    html.join.html_safe
  end

  def render_day_navigator(start_day)
    day = start_day.dup
    html = []
    html << "<span>#{day.strftime('%Y-%m-%d')}</span>"

    7.times do 
      date_s = day.strftime('%Y-%m-%d')
      html << link_to(date_s, events_path(day: date_s))
      day += 1.day
    end

    html.join(' | ').html_safe
  end
end
