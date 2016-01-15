require "rails_spec_helper"

describe Assignment do
  include AssignmentsToolkit

  subject { build(:assignment) }

  describe "fetching student submissions from an assignment", working: true do
    before(:each) do
      clear_rails_cache
      setup_submissions_environment_with_users
    end

    describe "submissions by team", working: true do
      it "returns submissions for the students on the given team" do
        expect(@assignment.student_submissions_for_team(@team).sort_by(&:id)).to eq(@submissions)
      end

      it "does not return submissions for students not on the team" do
        @submission = create_teamless_student_with_submission
        expect(@assignment.student_submissions_for_team(@team).sort_by(&:id)).not_to include([@submission])
      end

      describe "eager loading" do
        let(:submissions) { @assignment.student_submissions_for_team(@team) }

        it "makes queries for data on the initial call" do
          expect { submissions }.to make_database_queries
        end

        describe "subsequent calls on eager-loaded data" do
          before { @submission_results = @assignment.student_submissions_for_team(@team) }

          it "doesn't trigger queries for the first submission" do
            expect { @submission_results.first.submission_files }.not_to make_database_queries
          end

          it "doesn't trigger queries for the last submission" do
            expect { @submission_results.last.submission_files }.not_to make_database_queries
          end

          it "doesn't trigger queries when looking for a student on a submission" do
            expect { @submission_results.first.student }.not_to make_database_queries
          end
        end
      end
    end

    describe "student submissions" do
      it "should return a list of submissions for that assignment" do
        expect(@assignment.student_submissions.sort_by(&:id)).to eq(@submissions)
      end
      describe "eager loading" do
        let(:submissions) { @assignment.student_submissions }

        it "makes queries for data on the initial call" do
          expect { submissions }.to make_database_queries
        end

        describe "subsequent calls on eager-loaded data" do
          before { @submission_results = @assignment.student_submissions }

          it "doesn't trigger queries for the first submission" do
            expect { @submission_results.first.submission_files }.not_to make_database_queries
          end

          it "doesn't trigger queries for the last submission" do
            expect { @submission_results.last.submission_files }.not_to make_database_queries
          end

          it "doesn't trigger queries when looking for a student on a submission" do
            expect { @submission_results.first.student }.not_to make_database_queries
          end
        end
      end
    end
  end

  describe "finding students with submissions", working: true do
    context "basic finders" do
      before(:each) do
       setup_submissions_environment_with_users
      end

      context "no team is provided" do
        it "should find all students with submissions for the assignment" do
          expect(@assignment.students_with_submissions.sort_by(&:id)).to eq(@students)
        end

        it "should not include students who don't have a submission for the assignment" do
          @students << create_student_for_course
          expect(@assignment.students_with_submissions.sort_by(&:id)).not_to include(@students)
        end
      end

      context "team is provided" do
        it "should find all students with submissions who are on the team" do
          expect(@assignment.students_with_submissions_on_team(@team).sort_by(&:id)).to eq(@students)
        end

        it "should exclude students with submissions who are not on the team" do
          expect(@assignment.students_with_submissions.sort_by(&:id)).not_to include(@students)
        end
      end
    end

    context "ordering students by name" do
      before(:each) do
        @course = create(:course_accepting_groups)
        @students = []
        @professor = create_professor_for_course
        @assignment = create_assignment_for_course
        @students += create_students_with_names("Stephen Applebaum", "Jeffrey Applebaum", "Herman Merman")
        @alpha_student_order = [@student2, @student1, @student3]
        @submissions = create_submissions_for_students
        @team = create_team_and_add_students
      end

      it "should sort by last_name, first_name ascending" do
        expect(@assignment.students_with_submissions).to eq(@alpha_student_order)
      end

      it "should sort by first_name if last_name matches" do
        expect(@assignment.students_with_submissions_on_team(@team)).to eq(@alpha_student_order)
      end
    end
  end
end
