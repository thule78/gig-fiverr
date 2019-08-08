class PagesController < ApplicationController

  def index
    @categories = Category.all

  end
  def home
  end

  def search
    @categories = Category.all
    @category = Category.find(params[:category]) if params[:category].present?
    # @gigs = Gig.where("category_id = ? AND gigs.title ILIKE ?", params[:category], "%#{params[:q]}%")
    # @min = params[:min]
    # @max = params[:max]
    # @delivery = params[:delivery].present? params[:delivery] : "0"


    if params[:category].present? && params[:q].present? && params[:min].present? && params[:max].present?
      @gigs = Gig.where("category_id = ? AND gigs.title ILIKE ?", params[:category], "%#{params[:q]}%").joins(:pricings)
    elsif params[:category].present? && params[:min].present? && params[:max].present?
      @gigs = Gig.where("category_id = ?", params[:category]).joins(:pricings)
    elsif params[:category].blank? && params[:q].present? && params[:min].present? && params[:max].present?
      @gigs = Gig.where("gigs.title ILIKE ?", "%#{params[:q]}%").joins(:pricings)
    else
      @gigs = Gig.all
    end
  end
end
