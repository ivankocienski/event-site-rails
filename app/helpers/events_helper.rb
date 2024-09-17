module EventsHelper
  DATE_TIME_FORMAT = '%H:%M'.freeze
  DATE_DAY_FORMAT = '%A %-d %B, %Y'.freeze
  
  def link_to_day(date)
    link_to fancy_date_format(date), events_path(day: date.strftime('%Y-%m-%d'))
  end

  def fancy_time_format(time)
    time.strftime(time.min == 0 ? '%l%P' : '%l.%M%P')
  end

  def fancy_date_format(time)
    day_s = time.day.ordinalize

    time.strftime "%A #{day_s} %B, %Y"
  end

  def link_to_event_instance_with_time_and_partner(event_instance)
    event = event_instance.event
    time_part = fancy_time_format(event_instance.starts_at)
    event_name_part = link_to(event.name, event_path(event_instance.id))
    partner_part = link_to("<em>#{event.organizer.name}</em>".html_safe, partner_path(event.organizer))
    "<p><span class='time'>#{time_part}</span> #{event_name_part} &mdash; #{partner_part}</p>".html_safe
  end

  def render_event_by_day_list(event_instances)
    return if event_instances.empty?

    html = []
    last_day = event_instances.first.starts_at.beginning_of_day
    day_count = 1

    html << "<h2>#{link_to_day(last_day)}</h2>"

    event_instances.each do |event_instance|
      if event_instance.starts_at.beginning_of_day != last_day
        day_count += 1
        break if day_count > 7

        last_day = event_instance.starts_at.beginning_of_day

        html << "<h2>#{link_to_day(last_day)}</h2>"
      end

      html << link_to_event_instance_with_time_and_partner(event_instance)
    end

    html.join("\n").html_safe
  end

#  def render_day_navigator(first_day, show_day)
#    first_day_s = first_day.strftime('%Y-%m-%d')
#    day = first_day.dup
#    html = []
#    month = day.month
#
#    7.times do
#      day_s = day.day.ordinalize
#      format = "%A #{day_s}" # day number
#      if month != day.month
#        format += ' %B' # month name
#        month = day.month
#      end
#
#      date_s = day.strftime(format)
#
#      if day == show_day
#        html << "<span>#{date_s}</span>"
#      else
#        day_param_s = day.strftime('%Y-%m-%d')
#        html << link_to(date_s, events_path(first: first_day_s, day: day_param_s))
#      end
#      day += 1.day
#    end
#
#    day_param_s = day.strftime('%Y-%m-%d')
#    html << link_to('Later >>', events_path(first: day_param_s, day: day_param_s))
#
#    html.join(' | ').html_safe
#  end
end
