module ApplicationHelper
  include CustomNamedRoutes

  # current_user_is_student/professor/gsi/admin/staff?
  Role.all_with_staff.each do |role|
    define_method("current_user_is_#{role}?") do
      return unless current_user && current_course
      current_user.send("is_#{role}?", current_course)
    end
  end

  def impersonating_agent(user)
    session[:impersonating_agent_id] = user.id
  end

  def delete_impersonating_agent
    session.delete :impersonating_agent_id
  end

  def impersonating_agent_id
    session[:impersonating_agent_id]
  end

  def student_impersonation?
    impersonating_agent_id.present?
  end

  # Adding current user role to page class
  def body_class
    classes = []
    if logged_in?
      classes << "logged-in"
      classes << "staff" if current_user_is_staff?
      classes << current_user.role(current_course)
    else
      classes << "logged-out"
    end
    classes.join " "
  end

  # Return a title on a per-page basis.
  # def title
  #   base_title = ""
  #   if @title.nil?
  #     base_title
  #   else
  #     "#{@title}"
  #   end
  # end
  def title
    if content_for?(:title)
      # allows the title to be set in the view by using t(".title")
      content_for :title
    else
      # look up translation key based on controller path, action name and .title
      # this works identical to the built-in lazy lookup
      t("#{ controller_path.tr('/', '.') }.#{ action_name }.title", default: "#{current_course.name}")
    end
  end

  # Add class="active" to navigation item of current page
  def cp(path)
    "active" if current_page?(path)
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, "#", class: "add_fields", data: {
      id: id, fields: fields.delete("\n", "")
      })
  end

  def json_for(target, options = {})
    options[:scope] ||= self
    options[:url_options] ||= url_options
    target.active_model_serializer.new(target, options).to_json
  end

  # Commas in numbers!
  def points(value)
    number_with_delimiter(value)
  end

  def multi_cache_key(category, *args)
    arguments = args.map do
      |arg| arg.respond_to?(:cache_key) ? arg.cache_key : arg
    end
    "#{category}/#{arguments.join("/")}"
  end
end
