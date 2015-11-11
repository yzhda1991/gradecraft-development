class MultipliedGradebookExportPerformer < GradebookExportPerformer

  protected

  def fetch_csv_data
    @csv_data = @course.csv_multiplied_gradebook
  end
end
