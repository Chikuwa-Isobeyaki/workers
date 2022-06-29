class WorksController < ApplicationController
  before_action :authenticate_user!


  def new
    @site = Site.find(params[:site_id])
    if @site.user_id == current_user.id
      @work = Work.new
      @work.personnels.build
      @site_users = @site.users
      render 'new'
    else
      redirect_to '/'
    end
  end


  def create
    @work = Work.new(work_params)
    @site = Site.find(params[:site_id])
    @site_users = @site.users

    if !duplicate_company? && @work.save
      current_user.create_notification_work(current_user, @site_users, @site, @work)
      redirect_to site_work_path(@site, @work), notice: '予定を作成しました'
    else
      flash.now[:alert] = '予定を作成できませんでした'
      render 'new'
    end

  end

  def index
    @site = Site.find_by(id: params[:site_id])
    @site_users = @site.users
    @works = @site.works
    if @site.user_id == current_user.id || site_users?(@site_users, current_user)
      render 'index'
    else
      redirect_to '/'
    end

  end


  def show
    @work = Work.find(params[:id])
    @site = @work.site
    @site_users = @site.users
    if @site.user_id == current_user.id || site_users?(@site_users, current_user)
      @personnels = @work.personnels
      render 'show'
    else
      redirect_to '/'
    end

  end


  def edit
    @site = Site.find(params[:site_id])
    @work = Work.find(params[:id])
    if @site.user_id == current_user.id && @work.work_started?(@work)
      @site_users = @site.users
      @work_personnels = @work.personnels

      # jsにデータを渡す
      @work_company_names = []
      gon.names = @work.personnels.pluck(:company_name)
      render 'edit'
    else
      redirect_to '/'
    end

  end


  # ドラッグドロップ用のアップデートアクション
  def update
    @work = Work.find(params[:id])
    @site = @work.site
    @site_users = @site.users
    result = false
    # 現場を作成したユーザーのみ変更可能
    if @site.user_id == current_user.id && @work.work_started?(@work)
      if @work.update(start_date: params[:start_date], end_date: params[:end_date])
        result = true
      end
    end

    if result
      current_user.create_notification_work(current_user, @site_users, @site, @work)
    end

  end


  def update_all
    @work = Work.find(params[:id])
    @site = Site.find(@work.site_id)
    @site_users = @site.users
    # 現場を作成したユーザーのみ変更可能
    result = false
    if @site.user_id == current_user.id && !duplicate_company? && @work.work_started?(@work)
      if @work.update(work_params)
        result = true
      end
    else
      result = false
    end

    if result
      current_user.create_notification_work(current_user, @site_users, @site, @work)
      redirect_to site_work_path(@site, @work), notice: '予定を更新しました'
    else
      flash.now[:alert] = '予定を更新できませんでした'
      render 'edit'
    end
  end


  def destroy
    @work = Work.find(params[:id])
    @site = @work.site_id
    @work.destroy
    redirect_to site_works_path(@site), notice: '予定を削除しました'
  end


  private


  def work_params
    params.require(:work).permit(
      :site_id, :name, :content, :start_date, :end_date,
      personnels_attributes: [:id, :work_id, :company_name, :count, :_destroy])
  end

  # 現場作成者かどうか
  def site_owner?(site)
    site.user_id == current_user.id
  end


  # 送られてきた会社名に同じのものがあるかどうか
  def duplicate_company?
    work_params[:personnels_attributes].to_h
                                       .map {|k, hash| hash[:company_name]}
                                       .group_by {|e|e}.select {|k,v| v.size > 1}
                                       .any? {|k, v|v.size>1}
  end


  # 現場ユーザーかどうか
  def site_users?(site_users, user)
    site_users.include?(user)
  end



end
