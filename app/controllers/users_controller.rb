class UsersController < ApplicationController
  # POST /signup
  def signup
    user = User.new(user_params)
    if user.save
      render json: {
        message: "Account successfully created",
        user: { user_id: user.user_id, nickname: user.nickname || user.user_id }
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
      render json: { user_id: user.user_id, nickname: user.nickname, comment: user.comment }
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  # PATCH /users/:user_id
  def update
    user = User.find_by(user_id: params[:user_id])
    if user&.update(update_params)
      render json: { message: "Account successfully updated" }
    else
      render json: {
        message: "Account update failed",
        cause: user&.errors&.full_messages&.first || "User not found"
      }, status: :bad_request
    end
  end

  # POST /close
  def destroy
    user = User.find_by(user_id: params[:user_id])
    if user
      user.destroy
      render json: { message: "Account successfully removed" }
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
end
