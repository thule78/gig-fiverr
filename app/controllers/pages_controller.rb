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

    if params[:category].present? && params[:q].present?
      @gigs = Gig.where("category_id = ? AND gigs.title ILIKE ?", params[:category], "%#{params[:q]}%")
    elsif params[:category].present?
      @gigs = Gig.where("category_id = ?", params[:category])
    elsif params[:category].blank? && params[:q].present?
      @gigs = Gig.where("gigs.title ILIKE ?", "%#{params[:q]}%")
    else
      @gigs = Gig.all
    end
  end
end
