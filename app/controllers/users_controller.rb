class UsersController < ApplicationController
  before_action :log_request
  before_action :check_auth, only: [:show, :update, :destroy]

  # POST /signup
  def signup
    Rails.logger.info "[REQUEST] Signup with params: #{params.inspect}"
    user = User.new(user_params)
    if user.save
      Rails.logger.info "[SIGNUP] Success for user_id=#{user.user_id}"
      render json: {
        message: "Account successfully created",
        user: {
          user_id: user.user_id,
          nickname: user.nickname || user.user_id
        }
      }, status: :ok
    else
      Rails.logger.warn "[SIGNUP] Failed with errors: #{user.errors.full_messages.inspect}"
      render json: {
        message: "Account creation failed",
        cause: "Required user_id and password"
      }, status: :bad_request
    end
  end

  # GET /users/:user_id
  def show
    Rails.logger.info "[SHOW] Fetching user_id=#{params[:user_id]}"
    user = User.find_by(user_id: params[:user_id])
    if user
      Rails.logger.info "[SHOW] Found user: #{user.inspect}"
      render json: {
        message: "User details by user_id",
        user: {
          user_id: user.user_id,
          nickname: user.nickname,
          comment: user.comment
        }
      }, status: :ok
    else
      Rails.logger.warn "[SHOW] User not found with user_id=#{params[:user_id]}"
      render json: { message: "User not found" }, status: :not_found
    end
  end

  # PUT /users/:user_id
  def update
    Rails.logger.info "[UPDATE] Attempt for user_id=#{params[:user_id]} with params: #{params.inspect}"
    user = User.find_by(user_id: params[:user_id])
    if user&.update(user_params)
      Rails.logger.info "[UPDATE] Success for user_id=#{params[:user_id]}"
      render json: { message: "User successfully updated" }, status: :ok
    else
      Rails.logger.warn "[UPDATE] Failed for user_id=#{params[:user_id]}"
      render json: { message: "User update failed" }, status: :bad_request
    end
  end

  # DELETE /users/:user_id
  def destroy
    Rails.logger.info "[DELETE] Attempt for user_id=#{params[:user_id]}"
    user = User.find_by(user_id: params[:user_id])
    if user&.destroy
      Rails.logger.info "[DELETE] Success for user_id=#{params[:user_id]}"
      render json: { message: "Account and user successfully removed" }, status: :ok
    else
      Rails.logger.warn "[DELETE] Failed → user not found with user_id=#{params[:user_id]}"
      render json: { message: "User not found" }, status: :not_found
    end
  end

  private

  def user_params
    params.permit(:user_id, :password, :nickname, :comment)
  end

  def log_request
    Rails.logger.info "[REQUEST] #{request.method} #{request.fullpath}"
    Rails.logger.info "[REQUEST] Params: #{params.inspect}"
    Rails.logger.info "[REQUEST] Body: #{request.raw_post.presence || 'EMPTY'}"
    Rails.logger.info "[REQUEST] Headers: Authorization=#{request.headers['Authorization']}"
  end

  def check_auth
    auth_header = request.headers['Authorization']
    Rails.logger.debug "[AUTH] Raw header: #{auth_header}"

    if auth_header.present? && auth_header.start_with?('Basic ')
      encoded = auth_header.split(' ', 2).last
      Rails.logger.debug "[AUTH] Encoded: #{encoded}"

      begin
        decoded = Base64.decode64(encoded)
        Rails.logger.debug "[AUTH] Decoded: #{decoded}"

        user_id, password = decoded.split(':', 2)
        Rails.logger.debug "[AUTH] user_id=#{user_id}, password=#{password}"

        user = User.find_by(user_id: user_id)
        if user
          Rails.logger.debug "[AUTH] Found user in DB: #{user.inspect}"
          if user.password == password
            Rails.logger.info "[AUTH] ✅ Success for user_id=#{user_id}"
            return true
          else
            Rails.logger.warn "[AUTH] ❌ Password mismatch for user_id=#{user_id}"
          end
        else
          Rails.logger.warn "[AUTH] ❌ No user in DB for user_id=#{user_id}"
        end
      rescue => e
        Rails.logger.error "[AUTH] Exception during decode: #{e.message}"
      end
    else
      Rails.logger.warn "[AUTH] ❌ No valid Authorization header"
    end

    Rails.logger.error "[AUTH] Authentication failed → 401"
    render json: { message: "Authentication failed" }, status: :unauthorized
  end
end
