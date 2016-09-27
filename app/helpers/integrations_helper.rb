module IntegrationsHelper
  include ExternalAuthorization

  def integration_card_for(provider, course)
    if course.linked?(provider)
      linked_integration_card_for(course.linked_for(provider))
    else
      unlinked_integration_card_for provider
    end
  end

  def linked_integration_card_for(linked_course)
    render partial: "integrations/courses/linked_card",
      locals: { linked_course: syllabus_course(linked_course),
                provider: linked_course.provider }
  end

  def unlinked_integration_card_for(provider)
    render partial: "integrations/courses/unlinked_#{provider}_card"
  end

  private

  def syllabus_course(linked_course)
    authorization = validate_authorization(linked_course.provider)
    syllabus = ActiveLMS::Syllabus.new linked_course.provider, authorization.access_token
    syllabus.course(linked_course.provider_resource_id)
  end
end
