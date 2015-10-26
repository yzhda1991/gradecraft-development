require_relative './test_helper'

GradebookExporterTest.new.run(3, Rails)
sleep(20)
GradeExportTest.new.run(3)
sleep(20)
GradeUpdaterTest.new.run(3)
sleep(20)
MultipleGradeUpdaterTest.new.run(3)
sleep(20)
ScoreRecalculatorTest.new.run(3)
