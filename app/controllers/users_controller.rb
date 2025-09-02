class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update, :destroy]

  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      render json: {
        message: "Account successfully created",
        user: {
          user_id: user.user_id,
          nickname: user.nickname || user.user_id
        }
      }, status: :ok
    else
      render json: {
        message: "Account creation failed",
        cause: user.errors.full_messages.first
      }, status: :bad_request
    end
  end

  # GET /users/:user_id
  def show
    if @current_user.user_id == params[:user_id]
      render json: {
        message: "User details by user_id",
        user: {
          user_id: @current_user.user_id,
          nickname: @current_user.nickname,
          comment: @current_user.comment
        }
      }, status: :ok
    else
      user = User.find_by(user_id: params[:user_id])
      if user
        render json: {
          message: "User details by user_id",
          user: {
            user_id: user.user_id,
            nickname: user.nickname,
            comment: user.comment
          }
        }, status: :ok
      else
        render json: { message: "User not found" }, status: :not_found
      end
    end
  end

  # PATCH /users/:user_id
  def update
    if @current_user.user_id != params[:user_id]
      render json: { message: "No permission for update" }, status: :forbidden
      return
    end

    if @current_user.update(update_params)
      render json: { message: "User successfully updated" }, status: :ok
    else
      render json: {
        message: "Account update failed",
        cause: @current_user.errors.full_messages.first
      }, status: :bad_request
    end
  end

  # POST /close
  def destroy
    if @current_user
      @current_user.destroy
      render json: { message: "Account and user successfully removed" }, status: :ok
    else
      render json: { message: "Authentication failed" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def update_params
    params.permit(:password, :nickname, :comment)
  end

  def authenticate_user
    authenticate_or_request_with_http_basic do |user_id, password|
      user = User.find_by(user_id: user_id)
      if user&.password == password
        @current_user = user
      end
    end
    unless @current_user
      render json: { message: "Authentication failed" }, status: :unauthorized
    end
  end
end
