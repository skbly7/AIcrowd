class SuccessStoriesController < ApplicationController
  before_action :authenticate_participant!,
                except: [:show, :index]
  before_action :set_success_story, only: :show

  def index
    @success_stories = policy_scope(SuccessStory)
    .page(params[:page])
    .per(20)
  end

  def show; end

  private

  def set_success_story
    @success_story = SuccessStory.friendly.find(params[:id])
    authorize @success_story
  end

  def success_story_params
    params.require(:success_story).permit(:title, :byline, :published, :image_file)
  end
end
