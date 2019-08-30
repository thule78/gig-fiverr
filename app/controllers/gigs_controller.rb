class GigsController < ApplicationController
  protect_from_forgery except: [:upload_photo]
  before_action :authenticate_user!, except: [:show]
  before_action :set_gig, except: [:new, :create]
  before_action :is_authorised, only: [:edit, :update, :upload_photo, :delete_photo]
  before_action :set_step, only: [:update, :edit]
  before_action :set_category, only: [:show, :edit, :new]
  def new
    @gig = current_user.gigs.build
    set_category
  end

  def create
    @gig = current_user.gigs.build(gig_params)

    if @gig.save
      @gig.pricings.create(Pricing.pricing_types.values.map{|x| {pricing_type: x}})
      return redirect_to edit_gig_path(@gig), notice: "Save..."
    else
      return redirect_to request.referrer, flash: {error: @gig.errors.full_messages}
    end
  end

  def edit
    set_category
  end

  def update

    if @step == 2
      gig_params[:pricings_attributes].each do |index, pricing|
        if @gig.has_single_pricing && pricing[:pricing_type] != Pricing.pricing_types.key(0)
          next;
        else
          if pricing[:title].blank? || pricing[:description].blank? || pricing[:delivery_time].blank? || pricing[:price].blank?
            return redirect_to request.referrer, flash:{error: "Invalid pricing"}
          end
        end
      end
    end


    if @step == 3 && gig_params[:description].blank?
      return redirect_to request.referrer, flash:{error: "Description cannot be blank"}
    end

    if @step == 4 && @gig.photos.blank?
      return redirect_to request.referrer, flash:{error: "You don't have any photos"}
    end

    if @step == 5
      @gig.pricings.each do |pricing|
        if @gig.has_single_pricing && !pricing.basic?
          next;
        else
          if pricing[:title].blank? || pricing[:description].blank? || pricing[:delivery_time].blank? || pricing[:price].blank?
            return redirect_to edit_gig_path(@gig, step: 2), flash:{error: "Invalid Pricing"}
          end
        end
      end

      if @gig.description.blank?
        return redirect_to edit_gig_path(@gig, step: 3), flash:{error: "Description cannot be blank"}
      elsif @gig.photos.blank?
        return redirect_to edit_gig_path(@gig, step: 4), flash:{error: "You don't have any photos"}
      end
    end

    if @gig.update(gig_params)
      flash[:notice] = "Saved..."
    else
      return redirect_to request.referrer, flash: {error: @gig.errors.full_messages}
    end

    if @step < 5
      return redirect_to edit_gig_path(@gig, step: @step + 1)
    else
      return redirect_to dashboard_path
    end
  end

  def show
    set_category
  end

  def upload_photo
    @gig.photos.attach(params[:file])
    render json: { success: true}
  end

  def delete_photo
    @image = ActiveStorage::Attachment.find(params[:photo_id])
    @image.purge
    return redirect_to edit_gig_path(@gig, step: 4)
  end

  def checkout

    subscription = Subscription.find_by_user_id(current_user.id)
    if subscription.present? && subscription.success?
      plan = Stripe::plan.retrieve(subscription.plan_id)
      @rate = plan.metadata.commission.to_f/100
    else
      @rate = 10.0/100

    end

    if current_user.stripe_id
      @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_id)

      @gig = Gig.find(params[:id])
      @pricing = @gig.pricings.find_by(pricing_type: params[:pricing_type])
    else
      redirect_to setting_payment_path, alert: "Please add yor card first"
    end

  end

  private

  def set_category
    @categories = Category.all
  end

  def set_step
    @step = params[:step].to_i > 0 ? params[:step].to_i : 1

    if @step > 5
      @step = 5
    end
  end

  def set_gig
    @gig = Gig.find(params[:id])

  end

  def is_authorised
    redirect_to root_path, alert: "You do not have permission" unless current_user.id == @gig.user_id
  end

  def gig_params
    params.require(:gig).permit(:title, :video, :active, :category_id, :has_single_pricing, :description, :photos[],
                                pricings_attributes: [:id, :title, :description, :delivery_time, :price, :pricing_type])

  end
end
