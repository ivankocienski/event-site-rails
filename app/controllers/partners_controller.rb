class PartnersController < ApplicationController

  before_action :find_partner_for_param, only: %i[ show previous_events ]

  def index
    @partner_name_filter = params[:name].to_s.strip

    partner_keyword_param = params[:keyword].to_s.strip
    @keyword_for_filter = Keyword.where(name: partner_keyword_param).first if partner_keyword_param.present?

    geo_param = params[:geo]
    @geo_enclosure = GeoEnclosure.where(id: geo_param).first if geo_param.present?

    @partners = Partner.all

    # name
    @partners = @partners.with_fuzzy_name(@partner_name_filter) if @partner_name_filter.present?

    # keyword
    @partners = @partners.with_keyword(@keyword_for_filter) if @keyword_for_filter.present?

    # geo
    @partners = @partners.in_geo_enclosure(@geo_enclosure) if @geo_enclosure.present?
    
    @partners = @partners.order(:name)
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
