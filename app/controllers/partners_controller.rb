class PartnersController < ApplicationController
  def index
    @partner_name_filter = params[:name].to_s.strip
    if @partner_name_filter.present?
      @partners = Partner.find_by_name_fuzzy(@partner_name_filter)
    else
      @partners = Partner.find_all_by_name
    end
  end

  def show
    @partner = Partner.find_by_id(params[:id])
    if @partner.blank?
      @message = "Could not find partner with that ID"
      render 'home/not_found', status: :not_found

    else
      @today = Time.now.beginning_of_day
      @upcoming_events = @partner.events.keep_if { |event| event.start_date.beginning_of_day >= @today }
    end
  end
end
