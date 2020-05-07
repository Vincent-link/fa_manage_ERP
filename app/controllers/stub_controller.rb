class StubController < ApplicationController
  def index
    current_user
    render json: {}
  end
end
