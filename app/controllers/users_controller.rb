class UsersController < ApplicationController
  before_action :check_auth, only: [:show, :update, :destroy]

  # POST /signup
  def signup
    Rails.logger.info "Signup attempt with params: #{params.inspect}"
    user = User.new(user_params)
    if user.save
      Rails.logger.info "Signup successful for user_id=#{user.user_id}"
      render json: {
        message: "Account successfully created",
        user: {
          user_id: user.user_id,
          nickname: user.nickname || user.user_id
        }
      }, status: :ok
    else
      Rails.logger.warn "Signup failed: #{user.errors.full_messages.inspect}"
      render json: {
        message: "Account creation failed",
        cause: "Required user_id and password"
      }, status: :bad_request
    end
  end

  # GET /users/:user_id
  def show
    Rails.logger.info "Fetching user with user_id=#{params[:user_id]}"
    user = User.find_by(user_id: params[:user_id])
    if user
      Rails.logger.info "User found: #{user.inspect}"
      render json: {
        message: "User details by user_id",
        user: {
          user_id: user.user_id,
          nickname: user.nickname,
          comment: user.comment
        }
      }, status: :ok
    else
      Rails.logger.warn "User not found with user_id=#{params[:user_id]}"
      render json: { message: "User not found" }, status: :not_found
    end
  end

  # PUT /users/:user_id
  def update
    Rails.logger.info "Update attempt for user_id=#{params[:user_id]} with params: #{params.inspect}"
    user = User.find_by(user_id: params[:user_id])
    if user&.update(user_params)
      Rails.logger.info "User updated successfully: #{user.inspect}"
      render json: { message: "User successfully updated" }, status: :ok
    else
      Rails.logger.warn "User update failed for user_id=#{params[:user_id]}"
      render json: { message: "User update failed" }, status: :bad_request
    end
  end

  # DELETE /users/:user_id
  def destroy
    Rails.logger.info "Delete attempt for user_id=#{params[:user_id]}"
    user = User.find_by(user_id: params[:user_id])
    if user&.destroy
      Rails.logger.info "User deleted successfully: user_id=#{params[:user_id]}"
      render json: { message: "Account and user successfully removed" }, status: :ok
    else
      Rails.logger.warn "Delete failed: user not found with user_id=#{params[:user_id]}"
      render json: { message: "User not found" }, status: :not_found
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def check_auth
    auth_header = request.headers['Authorization']
    Rails.logger.debug "Auth header received: #{auth_header}"

    if auth_header.present? && auth_header.start_with?('Basic ')
      encoded = auth_header.split(' ', 2).last
      decoded = Base64.decode64(encoded).split(':', 2)
      user_id, password = decoded
      Rails.logger.debug "Decoded credentials: user_id=#{user_id}, password=#{password}"

      user = User.find_by(user_id: user_id)
      if user && user.password == password
        Rails.logger.info "Authentication successful for user_id=#{user_id}"
        return true
      else
        Rails.logger.warn "Authentication failed for user_id=#{user_id}"
      end
    else
      Rails.logger.warn "No valid Authorization header present"
    end

    render json: { message: "Authentication failed" }, status: :unauthorized
  end
end
