class EventsController < ApplicationController
  #helper_method :day_param
  #helper_method :first_day_param

  def index
    @epoch = day_param || Time.now
    @first_day = first_day_param || @epoch
    @day_mode = day_param.present?

    if @day_mode
      @event_instances = EventInstance
        .on_day(@epoch)
        .joins(:event)
        .order(:starts_at)
      render :events_by_day

    else
      @event_instances = EventInstance
        .from_day_onward(@epoch)
        .joins(:event)
        .order(:starts_at)
    end
  end

  def show
    @event_instance = EventInstance
      .where( id: params[:id] )
      #.joins(:event)
      .first
    if @event_instance.blank?
      @message = "Could not find event with that ID"
      render 'home/not_found', status: :not_found
      return
    end

    today = Time.now
    @event = @event_instance.event

    # TODO:
    #   should we show upcoming events from partner?
    #   OR other instances of this event?
    #   (or both?)
    @upcoming_partner_events = []
#    @upcoming_partner_events = @event
#      .organizer
#      .events
#      .joins(:event_instances)
#      .from_day_onward(today)
#      .where( "event_instances.id != ?", @event_instance.id )
  end

  private

  def day_param
    return @day_param if @day_param

    value = params[:day] || ''
    return unless value =~ /^(\d{4})-(\d{2})-(\d{2})$/

    @day_param = (Time.utc($1.to_i, $2.to_i, $3.to_i) rescue nil)
  end

  def first_day_param
    return @first_day_param if @first_day_param

    value = params[:first] || ''
    return unless value =~ /^(\d{4})-(\d{2})-(\d{2})$/

    @first_day_param = (Time.utc($1.to_i, $2.to_i, $3.to_i) rescue nil)
  end
end
