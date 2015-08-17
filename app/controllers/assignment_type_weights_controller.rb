class AssignmentTypeWeightsController < ApplicationController

  # Students set their assignment type weights all at once
  def mass_edit
    if current_user_is_staff?
      @title =  "Editing #{current_student.name}'s #{term_for :weights}"
    else
      @title =  "Editing My #{term_for :weight} Choices"
    end

    @assignment_types = current_course.assignment_types
    respond_with @form = AssignmentTypeWeightForm.new(current_student, current_course)
  end

  def mass_update
    @form = AssignmentTypeWeightForm.new(current_student, current_course)

    @form.update_attributes(student_params)

    if @form.save
      if current_user_is_student?
        redirect_to syllabus_path , :notice => "You have successfully updated your #{(term_for :weight).titleize} choices!"
      else
        redirect_to multiplier_choices_path, :notice => "You have successfully updated #{current_student.name}'s #{(term_for :weight).capitalize} choices."
      end
    else
      redirect_to assignment_type_weights_path
    end
  end

  def update
    assignment_type = current_course.assignment_types.find(params[:id])
    weight = params[:weight]
    if assignment_type and weight
      assignment_type_weight = AssignmentTypeWeight.new(current_student, assignment_type)
      assignment_type_weight.weight = weight
    end
    respond_to do |format|
      format.json do
        if assignment_type_weight and assignment_type_weight.save
          render :json => {assignment_type: assignment_type.id, weight: assignment_type.weight_for_student(current_student)}
        else
          render :json => { errors:  "Unable to update assignment type weight" }, :status => 400
        end
      end
    end
  end

  def student_predictor_data
    if current_user.is_student?(current_course)
      @student = current_student
    else
      @student = User.find(params[:id])
    end
    @assignment_types = current_course.assignment_types
    .select(
      :course_id,
      :id,
      :name,
      :points_predictor_display,
      :resubmission,
      :max_value,
      :predictor_description,
      :student_weightable,
      :include_in_predictor,
      :is_attendance,
      :position,
    )
  end

  private

  def student_params
    params.require(:student).permit(:assignment_type_weights_attributes => [:assignment_type_id, :weight])
  end

  def interpolation_options
    { weights_term: term_for(:weights) }
  end
end
