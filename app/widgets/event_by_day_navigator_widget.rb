
class EventByDayNavigatorWidget < WidgetBase
  attr_reader :first_day
  attr_reader :show_day

  def grab_args(args)
    @first_day = args[:first_day]
    @show_day = args[:show_day]
  end

  def render
    first_day_s = first_day.strftime('%Y-%m-%d')
    day = first_day.dup
    html = []
    month = day.month

    7.times do
      day_s = day.day.ordinalize
      format = "%A #{day_s}" # day number
      if month != day.month
        format += ' %B' # month name
        month = day.month
      end

      date_s = day.strftime(format)

      if day == show_day
        html << "<span>#{date_s}</span>"
      else
        day_param_s = day.strftime('%Y-%m-%d')
        html << view.link_to(date_s, view.events_path(first: first_day_s, day: day_param_s))
      end
      day += 1.day
    end

    day_param_s = day.strftime('%Y-%m-%d')
    html << view.link_to('Later >>', view.events_path(first: day_param_s, day: day_param_s))

    html.join(' | ')
  end

end

