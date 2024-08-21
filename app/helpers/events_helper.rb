module EventsHelper
  DATE_TIME_FORMAT = '%H:%M'
  DATE_DAY_FORMAT = '%A %e %B, %Y'
  
  def link_to_day(date)
    link_to date.strftime(DATE_DAY_FORMAT), events_path(day: date.strftime('%Y-%m-%d'))
  end

  def render_event_by_day_list(events)
    return if events.empty?

    html = []
    last_day = events.first.start_date.beginning_of_day
    day_count = 1

    html << "<h2>#{link_to_day(last_day)}</h2>"

    events.each do |event|
      if event.start_date.beginning_of_day != last_day
        day_count += 1
        break if day_count > 7

        last_day = event.start_date.beginning_of_day

        html << "<h2>#{link_to_day(last_day)}</h2>"
      end
      html << "<p><span class='time'>#{event.start_date.strftime(DATE_TIME_FORMAT)}</span> #{link_to(event.name, event_path(event.id))}</p>"
    end

    html.join("\n").html_safe
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
