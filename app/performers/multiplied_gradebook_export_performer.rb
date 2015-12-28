class MultipliedGradebookExportPerformer < GradebookExportPerformer

  protected

  def fetch_csv_data(course)
    @csv_data = MultipliedGradebookExporter.new.gradebook(course)
  end

  def notify_gradebook_export
    NotificationMailer
      .gradebook_export(@course, @user, "multiplied gradebook export", @csv_data)
      .deliver_now
  end
end
