class PagesController < ApplicationController

  def index
    @categories = Category.all

  end
  def home
  end

  def search
    @categories = Category.all
    @category = Category.find(params[:category]) if params[:category].present?
  end
end
