class ErrorsController < ApplicationController
  def show
    @code    = params[:code]&.to_i || 500
    @message = t(@code, scope: 'http_error', default: @code.to_s)
    if request.format&.symbol == :json
      render json: JSON.pretty_generate({ error: { code: @code, message: @message } }), status: @code
    else
      # use full filename to force html format
      render 'errors/show.html.erb', layout: 'error', status: @code
    end
  end
end
