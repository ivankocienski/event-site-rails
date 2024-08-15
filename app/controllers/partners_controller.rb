class PartnersController < ApplicationController
  def index
    @partner_count = Partner.count
    @partners = Partner.find_all_by_name
  end

  def show
    @partner = Partner.find_by_id(params[:id])
    if @partner.blank?
      @message = "Could not find partner with that ID"
      render 'home/not_found', status: :not_found
    end
  end
end
