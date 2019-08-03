module ApplicationHelper
  def avatar_url(user)
    if user.avatar.attached?
      url_for(user.avatar)
    elsif user.image?
      user.image
    else
      ActionController::Base.helpers.asset_path('avatar.jpg')
    end
  end

  def gig_cover(gig)
    if gig.photos.attached?
        url_for(gig.photos[0])
    else
      ActionController::Base.helpers.asset_path('freelance.png')
    end

  end
end












