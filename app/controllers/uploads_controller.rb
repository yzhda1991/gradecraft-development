class UploadsController < ApplicationController
  before_filter :fetch_upload, only: :remove

  def remove
    if upload.remove # delete from s3
      upload.destroy # destroy the actual persisted active record object resource
    else
      flash[:error] = "File could not be deleted from the server."
    end

    redirect_to :back
  end

  protected

  def fetch_upload
    @upload = params[:model].classify.constantize.find params[:upload_id]
  end
end
