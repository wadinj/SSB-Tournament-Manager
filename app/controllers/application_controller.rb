class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :authenticate_user!, except: [:index, :show, :location, :unregistered]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :get_top_players
  before_action :get_next_tournaments
  before_action :prepare_exception_notifier

  protected

  def configure_permitted_parameters
    #new
    added_attrs = [:username, :email, :password, :password_confirmation,
      :remember_me, :challonge_username, :challonge_api_key, :full_name,
      :mobile_number, :area_of_responsibility, :is_club_member,
      :wants_major_email, :wants_weekly_email, :canton, :gender, :birth_year,
      :prefix, :discord_username]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def user_for_paper_trail
    current_user.try(:username)
  end

  def after_sign_in_path_for(resource)
    if request.referer.nil? or request.referer.include?('/users/')
     root_path
    else
     request.referer
    end
  end

  def after_sign_out_path_for(resource)
    request.referrer
  end

  def get_top_players
    @topPlayers = []
    helpers.top_players_s1_19.each do |p|
      player = Player.find_by(gamer_tag: p)
      @topPlayers << player unless player.nil?
      break if @topPlayers.size >= 10 # limit(10)
    end
  end

  def get_next_tournaments
    @nextTournaments = Tournament.active_2019.upcoming.order(date: :asc).includes(:players).limit(10)
  end

  private
    def set_locale
      if params[:locale].present?
        cookies.permanent[:locale] = params[:locale]
      end
      localeCookie = cookies[:locale]
      if localeCookie.present?
        I18n.locale = localeCookie
      else
        I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
        cookies.permanent[:locale] = I18n.locale.to_s
      end
    end

    def prepare_exception_notifier
      request.env["exception_notifier.exception_data"] = {
        current_user: current_user
      }
    end

end
