class PartnersController < ApplicationController

  before_action :find_partner_for_param, only: %i[ show previous_events ]

  def index
    @partner_name_filter = params[:name].to_s.strip

    partner_keyword_param = params[:keyword].to_s.strip
    @keyword_for_filter = Keyword.where(name: partner_keyword_param).first if partner_keyword_param.present?

    @partners = Partner.all

    # name
    @partners = @partners.with_fuzzy_name(@partner_name_filter) if @partner_name_filter.present?

    # keyword
    @partners = @partners.with_keyword(@keyword_for_filter) if @keyword_for_filter.present?

    @partners = @partners.order(:name)
  end

  def show
    @today = Time.now.beginning_of_day

    @upcoming_events = @partner.events.from_day_onward(@today)
    @previous_events = @partner.events.before_date(@today)
  end

  def previous_events
    @today = Time.now.beginning_of_day
    @previous_events = @partner.events.before_date(@today)
  end

  private

  def find_partner_for_param
    @partner = Partner.where(id: params[:id]).first
    return if @partner.present?

    @message = "Could not find partner with that ID"
    render 'home/not_found', status: :not_found
  end
end
