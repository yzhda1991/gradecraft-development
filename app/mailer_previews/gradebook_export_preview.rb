class GradebookExportPreview
  def gradebook_export
    ExportsMailer.gradebook_export
  end
end