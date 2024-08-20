class EventsController < ApplicationController
  #helper_method :day_param
  #helper_method :first_day_param

  def index
    @epoch = day_param || Time.now
    @first_day = first_day_param || @epoch
    @day_mode = day_param.present?

    if @day_mode
      @events = Event.find_on_day(@epoch)
      render :events_by_day

    else
      @events = Event.find_in_future(@epoch)
    end
  end

  def show
    @event = Event.find_by_id(params[:id])
    if @event.blank?
      @message = "Could not find event with that ID"
      render 'home/not_found', status: :not_found
    end
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
