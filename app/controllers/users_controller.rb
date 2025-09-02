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
