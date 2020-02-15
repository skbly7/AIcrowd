class TaskDatasetFileDownloadsController < InheritedResources::Base
  before_action :load_task_dataset_file, only: :create

  def create
    @task_dataset_file
      .task_dataset_file_downloads
      .create!(
        participant_id: current_participant.id,
        ip_address:     request.remote_ip)
    head :ok
  end

  private

  def load_task_dataset_file
    @task_dataset_file = TaskDatasetFile.find(params[:task_dataset_file_id])
  end
end
