class PartnersController < ApplicationController

  before_action :find_partner_for_param, only: %i[ show previous_events ]

  def index
    @partner_filter = PartnersFilter.new(params)
  end

  def show
    @today = Time.now.beginning_of_day

    @upcoming_events = EventInstance
      .for_partner(@partner)
      .from_day_onward(@today)
      .order(:starts_at)

    @previous_events = EventInstance
      .for_partner(@partner)
      .before_date(@today)
  end

  def previous_events
    @today = Time.now.beginning_of_day
    @previous_event_instances = EventInstance
      .for_partner(@partner)
      .before_date(@today)
      .order(starts_at: :desc)
  end

  private

  def find_partner_for_param
    @partner = Partner.with_slug(params[:id]).first
    return if @partner.present?

    @message = "Could not find partner with that ID"
    render 'home/not_found', status: :not_found
  end
end
