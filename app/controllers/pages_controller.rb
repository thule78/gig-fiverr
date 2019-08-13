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
    @q = params[:q]
    @min = params[:min]
    @max = params[:max]
    @delivery = params[:delivery].present? ? params[:delivery] : "0"
    @sort = params[:sort].present? ? params[:sort] : "price asc"


    query_condition = []
    query_condition[0] = "gigs.active = true " #in lessons gigs.active = true, but since we set it default: false
    query_condition[0] += "AND ((gigs.has_single_pricing = true AND pricings.pricing_type = 0) OR (gigs.has_single_pricing = false))"

    if !@q.blank?
      query_condition[0] += "AND gigs.title ILIKE ? "
      query_condition << "%#{@q}%"
    end

    if !params[:category].blank?
      query_condition[0] += "AND category_id = ? "
      query_condition << params[:category]
    end

    if !params[:min].blank?
      query_condition[0] += "AND pricings.price >= ? "
      query_condition << @min
    end

    if !params[:max].blank?
      query_condition[0] += "AND pricings.price <= ? "
      query_condition << @max
    end

    if !params[:delivery].blank? && params[:delivery] != "0"
      query_condition[0] += "AND pricings.delivery_time <= ? "
      query_condition << @delivery
    end

    @gigs = Gig.select("gigs.id, gigs.title, gigs.user_id, MIN(pricings.price) AS price")
                .joins(:pricings)
                .where(query_condition)
                .group("gigs.id")
                .order(@sort)
                .page(params[:page])
                .per(6)
  end
end
