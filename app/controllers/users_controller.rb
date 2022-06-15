class UsersController < ApplicationController


  def show
    @user = User.find(params[:id])
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user =User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render 'edit'
    end
  end


  def search
    @users = User.all
    if @user = User.find_by(email: params[:search_email])
      render 'search'
    else
      render 'search'
    end
  end



  private

  def user_params
    params.require(:user).permit(:family_name, :name, :kana_family_name, :kana_name, :phone_number, :company_name, :profile_image)
  end


end
