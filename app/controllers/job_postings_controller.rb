class JobPostingsController < InheritedResources::Base
  before_action :set_job_posting, only: [:show]

  def index
    @job_postings = if current_participant.try(:admin?)
                      JobPosting.all
                    else
                      JobPosting.where(status_cd: 'open')
                    end
  end

  def show
    @job_posting.record_page_view
  end

  private

  def set_job_posting
    @job_posting = JobPosting.friendly.find(params[:id])
  end
end
