class RubricGradesController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_rubric_grade, except: [:new, :create]
  after_action :respond_with_rubric_grade

  def new
    @rubric_grade = RubricGrade.new params[:rubric_grade]
  end

  def create
    @rubric_grade = RubricGrade.create params[:rubric_grade]
  end

  def destroy
    @rubric_grade.destroy
  end

  def update
    @rubric_grade.update_attributes params[:rubric_grade]
  end

  private
  def find_rubric_grade
    @rubric_grade = RubricGrade.find params[:id]
  end

  def respond_with_rubric_grade
    respond_with @rubric_grade
  end
end
