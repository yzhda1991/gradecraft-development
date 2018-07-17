class MultipliersController < ApplicationController
    before_action :ensure_staff?
    before_action :find_course

    def export
        if !@course.total_weights
            redirect_to downloads_path, flash: { error: "This course doesn't have multipliers"}
            return
        end

        respond_to do |format|
            format.csv { send_data MultipliersExporter.new(@course).export(), filename: "#{ @course.name } multipliers - #{ Date.today }.csv" }
        end
    end

    private

    def find_course
        @course = current_user.courses.find(params[:course_id])
    end
end
