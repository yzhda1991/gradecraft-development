class MultipliedGradebookExportPerformer < GradebookExportPerformer

  protected

  def fetch_csv_data
    @csv_data = @course.csv_multipled_gradebook
  end
end
