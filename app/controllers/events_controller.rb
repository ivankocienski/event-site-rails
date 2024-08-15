class EventsController < ApplicationController
  def index
    @epoch = Time.now
    @events = Event.find_in_future(@epoch)
  end

  def show
    @event = Event.find_by_id(params[:id])
    if @event.blank?
      @message = "Could not find event with that ID"
      render 'home/not_found', status: :not_found
    end
  end
end
