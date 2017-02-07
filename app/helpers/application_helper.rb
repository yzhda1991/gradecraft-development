module ApplicationHelper
  include CustomNamedRoutes

  # current_user_is_student/professor/gsi/admin/observer/staff?
  Role.all_with_staff.each do |role|
    define_method("current_user_is_#{role}?") do
      return unless current_user && current_course
      current_user.send("is_#{role}?", current_course)
    end
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

  def title
    # look up translation key based on controller path, action name and .title
    # this works identical to the built-in lazy lookup
    title = t("#{ controller_path.tr('/', '.') }.#{ action_name }.title", default: "")
    # evaluate any variables in the title. These should remain
    # restricted to preset titles in /config/locales/views/titles/en.yml
    eval %{ "#{ title }" }
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

  def tooltip(tooltip_id, hover_content)
    content_tag(:span, hover_content, class: "display-on-hover hover-style", id: tooltip_id, role: "tooltip")
  end
end
