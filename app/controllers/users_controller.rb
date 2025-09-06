class UsersController < ApplicationController

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
        message: "user details by user_id",
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
    user = authenticate_user(params[:user_id], params[:password])
    unless user
      return render json: { message: "Authentication failed" }, status: :unauthorized
    end

    if user.user_id != params[:user_id]
      return render json: {
        message: "Account update failed",
        cause: "Cannot update another account"
      }, status: :forbidden
    end

    if user.update(update_params)
      render json: { message: "Account successfully updated" }, status: :ok
    else
      render json: {
        message: "Account update failed",
        cause: user.errors.full_messages.first || "User not found"
      }, status: :bad_request
    end
  end

  # POST /close
  def destroy
    user = authenticate_user(params[:user_id], params[:password])
    unless user
      return render json: { message: "Authentication failed" }, status: :unauthorized
    end

    user.destroy
    render json: { message: "Account and user successfully removed" }, status: :ok
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def update_params
    params.permit(:password, :nickname, :comment)
  end

  def authenticate_user(user_id, password)
    User.find_by(user_id: user_id, password: password)
  end

  # Dummy current_user_id for compatibility
  def current_user_id
    params[:user_id]
  end
end
