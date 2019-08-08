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
                        "&access_token=AA|#{facebook_id}|#{"facebook_secret"}";
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

  private
  def current_user_params
    params.require(:user).permit(:from, :about, :status, :language, :full_name, :avatar)

  end
end
