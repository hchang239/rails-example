class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by_id(params[:followed_id])
    current_user.follow(@user)

    # After create, current_user is redirected to the same page that the user comes from
    # This is redundancy because we don't need to re-render whole page
    # Thus this is a good case to use AJAX
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find_by_id(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
