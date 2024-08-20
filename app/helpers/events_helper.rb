module EventsHelper
  
  def render_event_by_day_list(events)
    return if events.empty?

    html = []
    last_day = events.first.start_date.beginning_of_day
    day_count = 1

    html << "<h2>#{link_to last_day, events_path(day: last_day.strftime('%Y-%m-%d'))}</h2>"

    events.each do |event|
      if event.start_date.beginning_of_day != last_day
        day_count += 1
        break if day_count > 7

        html << "<h2>#{link_to last_day, events_path(day: last_day.strftime('%Y-%m-%d'))}</h2>"
        last_day = event.start_date.beginning_of_day
      end
      html << "<p>#{link_to(event.name, event_path(event.id))}</p>"
    end

    html.join.html_safe
  end

  def render_day_navigator(first_day, show_day)
    first_day_s = first_day.strftime('%Y-%m-%d')
    day = first_day.dup
    html = []
    # html << "<span>#{day.strftime('%Y-%m-%d')}</span>"

    7.times do 
      date_s = day.strftime('%Y-%m-%d')

      if day == show_day
        html << "<span>#{date_s}</span>"
      else
        html << link_to(date_s, events_path(first: first_day_s, day: date_s))
        # html << link_to(date_s, events_path(first: first_day_s, day: date_s), data: { 'turbo-frame': 'events-on-day-list' })
      end
      day += 1.day
    end

    html.join(' | ').html_safe
  end
end
