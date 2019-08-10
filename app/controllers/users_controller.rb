class UsersController < ApplicationController
  before_action :authenticate_user!
  def dashboard
  end

  def show
    @user = User.find(params[:id])

  end

  def update
    @user = current_user
    if @user.update_attributes(current_user_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Cannot update.."
    end
    return redirect_to dashboard_path
  end

  def callback_phone
    path_access_token = "https://graph.accountkit.com/v1.1/access_token?" +
                        "grant_type=authorization_code" +
                        "&code=#{params[:code]}" +
                        "&access_token=AA|#{ENV['FACEBOOK_APP_ID']}|#{ENV['FACEBOOK_API_SECRET']}";
    response = Net::HTTP.get(URI.parse(path_access_token))
    response = JSON.parse(response)
    if response['access_token']
      path_get_data = "https://graph.accountkit.com/v1.1/me?access_token=#{respone['access_token']}"
      respone = Net::HTTP.get(URI.parse(path_get_data))
      respone = JSON.parse(response)

      if response['phone']['number']
        current_user.update(phone: response['phone']['number'])
        return render json: {success: true}
      end
    end

    return render json: {success: false}
  end

  def update_payment
    if !current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        source: params[:stripeToken]
        )
    else
      customer = Stripe::Customer.update(
        current_user.stripe_id,
        source: params[:stripeToken]
        )
    end
    if current_user.update(stripe_id: customer.id, stripe_last_4: customer.sources.data.first["last4"])
      flash[:notice] = "New card is saved"
    else
      flash[:alert] = "Invalid card"
    end
    return redirect_to request.referrer
    rescue Stripe::CardError => e
      flash[:alert] = e.message
      return redirect_to request.referrer
  end

  def update_payout
    if current_user.update(paypal: params[:paypal])
      flash[:notice] = "Update payout successfully"
    else
      flas[:alert] = "Something went wrong"
    end
    return redirect_to request.referrer
  end

  private
  def current_user_params
    params.require(:user).permit(:from, :about, :status, :language, :full_name, :avatar)

  end
end
