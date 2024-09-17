
class WidgetBase
  attr_reader :view

  def initialize(view_instance, args)
    @view = view_instance
    grab_args args
  end

  def render_html
    render.html_safe
  end

  #
  # these methods should be overriden in subclass
  #

  def grab_args(args)
  end

  def render
    raise "This widget has no render() method!"
  end
end
