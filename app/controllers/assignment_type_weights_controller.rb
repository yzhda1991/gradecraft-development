class AssignmentTypeWeightsController < ApplicationController

  before_filter :ensure_student?, only: [:update]

  # Students set their assignment type weights all at once
  def mass_edit
    @title =
      "Editing My #{term_for :weight} Choices" if current_user_is_student?
    @title =
      "Editing #{current_student.name}'s #{term_for :weight} Choices" if current_user_is_staff?
    @assignment_types = current_course.assignment_types
    respond_with @form =
      AssignmentTypeWeightForm.new(current_student, current_course)
  end

  def mass_update
    @form = AssignmentTypeWeightForm.new(current_student, current_course)

    @form.update_attributes(student_params)

    if @form.save
      if current_user_is_student?
        redirect_to syllabus_path, notice: "You have successfully updated your
          #{(term_for :weight).titleize} choices!"
      else
        redirect_to multiplier_choices_path,
          notice: "You have successfully updated #{current_student.name}'s
            #{(term_for :weight).capitalize} choices."
      end
    else
      respond_to do |format|
        if current_user_is_student?
          format.html { render action: "mass_edit" }
        else
          format.html {
            render action: "mass_edit", student_id: current_student
          }
        end
      end
    end
  end

  # Updates weights from the predictor
  def update
    assignment_type = current_course.assignment_types.find(params[:id])
    weight = params[:weight]
    if assignment_type && weight && assignment_type.student_weightable?
      assignment_type_weight = AssignmentTypeWeight.new(current_student,
        assignment_type)
      assignment_type_weight.weight = weight
    end
    respond_to do |format|
      format.json do
        if assignment_type_weight && assignment_type_weight.save
          render json: { assignment_type: assignment_type.id,
            weight: assignment_type.weight_for_student(current_student)
          }
        else
          render json: {
            errors:  "Unable to update assignment type weight"
            }, status: 400
        end
      end
    end
  end

  # Faculty have access to student weights, so we send the same information to
  # the student and faculty predictor views
  # Individual Student weighting is sent in on the assignment types
  def predictor_data
    if current_user.is_student?(current_course)
      @student = current_student
      @update_weights = true
    elsif params[:id]
      @student = User.find(params[:id])
      @update_weights = false
    else
      @student = NullStudent.new
      @update_weights = false
    end
    assignment_types =
      current_course.assignment_types.select(:id, :student_weightable)
    @assignment_types_weightable = assignment_types.each_with_object([]) {
      |at, ary| ary << at.id if at.student_weightable?
    }
    @total_weights =  current_course.try(:total_assignment_weight)
    @close_at =  current_course.try(:assignment_weight_close_at)
    @max_weights =  current_course.max_assignment_weight
    @max_types_weighted =  current_course.max_assignment_types_weighted
    @default_weight =  current_course.default_assignment_weight
  end

  private

  def student_params
    params.require(:student).permit(assignment_type_weights_attributes:
      [:assignment_type_id, :weight])
  end
end
