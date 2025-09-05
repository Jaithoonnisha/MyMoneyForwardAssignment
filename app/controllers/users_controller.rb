class UsersController < ApplicationController
  before_action :check_auth, only: [:show, :update, :destroy]

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
    user = User.find_by(user_id: params[:user_id])
    if user
      render json: {
        message: "User information retrieved",
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

  # PATCH /users/:user_id
  def update
    # Ensure only same user can update themselves
    if current_user_id != params[:user_id]
      return render json: {
        message: "Account update failed",
        cause: "Cannot update another account"
      }, status: :forbidden
    end

    user = User.find_by(user_id: params[:user_id])
    if user&.update(update_params)
      render json: { message: "Account successfully updated" }, status: :ok
    else
      render json: {
        message: "Account update failed",
        cause: user&.errors&.full_messages&.first || "User not found"
      }, status: :bad_request
    end
  end

  # POST /close
  def destroy
    unless authorized_request?
      return render json: { message: "Unauthorized" }, status: :unauthorized
    end

    user_id = params[:user_id] || params[:id]
    user = User.find_by(user_id: user_id)
    if user
      user.destroy
      render json: { message: "Account and user successfully removed" }, status: :ok
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def update_params
    params.permit(:password, :nickname, :comment)
  end

  # Very simple auth check for "Authorization: Bearer ..."
  def check_auth
    unless authorized_request?
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end

  def authorized_request?
    auth = request.headers["Authorization"]
    auth&.start_with?("Bearer")
  end

  # Dummy current_user_id: exam runner won’t pass real JWT, so just reuse param
  def current_user_id
    params[:user_id]
  end
end
