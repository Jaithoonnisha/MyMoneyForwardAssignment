class UsersController < ApplicationController
  before_action :check_auth, only: [:show, :update, :destroy]

  # POST /signup
  def signup
    Rails.logger.info "[REQUEST] Signup with params: #{params.inspect}"
    user = User.new(user_params)
    if user.save
      Rails.logger.info "[SIGNUP] ✅ Created user_id=#{user.user_id}"
      render json: {
        message: "Account successfully created",
        user: {
          user_id: user.user_id,
          nickname: user.nickname || user.user_id
        }
      }, status: :ok
    else
      Rails.logger.warn "[SIGNUP] ❌ Failed: #{user.errors.full_messages.inspect}"
      render json: {
        message: "Account creation failed",
        cause: "Required user_id and password"
      }, status: :bad_request
    end
  end

  # GET /users/:user_id
  def show
    if @current_user.user_id == params[:user_id]
      Rails.logger.info "[SHOW] ✅ Returning details for user_id=#{@current_user.user_id}"
      render json: {
        message: "User details by user_id",
        user: {
          user_id: @current_user.user_id,
          nickname: @current_user.nickname,
          comment: @current_user.comment
        }
      }, status: :ok
    else
      Rails.logger.warn "[SHOW] ❌ Forbidden: auth=#{@current_user.user_id}, param=#{params[:user_id]}"
      render json: { message: "Forbidden" }, status: :forbidden
    end
  end

  # PUT /users/:user_id
  def update
    if @current_user.user_id == params[:user_id]
      if @current_user.update(user_params)
        Rails.logger.info "[UPDATE] ✅ Updated user_id=#{@current_user.user_id}"
        render json: { message: "User successfully updated" }, status: :ok
      else
        Rails.logger.warn "[UPDATE] ❌ Failed for user_id=#{@current_user.user_id}"
        render json: { message: "User update failed" }, status: :bad_request
      end
    else
      Rails.logger.warn "[UPDATE] ❌ Forbidden: auth=#{@current_user.user_id}, param=#{params[:user_id]}"
      render json: { message: "Forbidden" }, status: :forbidden
    end
  end

  # DELETE /users/:user_id
  def destroy
    if @current_user.user_id == params[:user_id]
      if @current_user.destroy
        Rails.logger.info "[DELETE] ✅ Deleted user_id=#{@current_user.user_id}"
        render json: { message: "Account and user successfully removed" }, status: :ok
      else
        Rails.logger.warn "[DELETE] ❌ Failed to delete user_id=#{@current_user.user_id}"
        render json: { message: "User not found" }, status: :not_found
      end
    else
      Rails.logger.warn "[DELETE] ❌ Forbidden: auth=#{@current_user.user_id}, param=#{params[:user_id]}"
      render json: { message: "no permission for update" }, status: :forbidden
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def check_auth
    auth_header = request.headers['Authorization']
    Rails.logger.debug "[AUTH] Header: #{auth_header}"

    if auth_header.present? && auth_header.start_with?('Basic ')
      encoded = auth_header.split(' ', 2).last
      decoded = Base64.decode64(encoded) rescue nil
      user_id, password = decoded.to_s.split(':', 2)

      Rails.logger.debug "[AUTH] Decoded user_id=#{user_id}, password=#{password}"

      user = User.find_by(user_id: user_id)
      if user && user.password == password
        @current_user = user
        Rails.logger.info "[AUTH] ✅ Success for user_id=#{user_id}"
        return true
      else
        Rails.logger.warn "[AUTH] ❌ Invalid credentials for user_id=#{user_id}"
      end
    else
      Rails.logger.warn "[AUTH] ❌ Missing or malformed Authorization header"
    end

    render json: { message: "Authentication failed" }, status: :unauthorized
  end
end