include Recaptcha::Adapters::ViewMethods
include Recaptcha::Adapters::ControllerMethods

# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if params['noReCaptcha'] == 'true' || verify_recaptcha(action: 'login', minimum_score: 0.5)
      super
    else
      render 'new'
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
