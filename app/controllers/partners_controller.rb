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
    end
  end
end
