class CriterionGradesController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_criterion_grade, except: [:new, :create]
  after_action :respond_with_criterion_grade

  def new
    @criterion_grade = CriterionGrade.new params[:criterion_grade]
  end

  def create
    @criterion_grade = CriterionGrade.create params[:criterion_grade]
  end

  def destroy
    @criterion_grade.destroy
  end

  def update
    @criterion_grade.update_attributes params[:criterion_grade]
  end

  private
  
  def find_criterion_grade
    @criterion_grade = CriterionGrade.find params[:id]
  end

  def respond_with_criterion_grade
    respond_with @criterion_grade
  end
end
