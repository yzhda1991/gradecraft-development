module TeamFilterHelper

  def team_filter
    content_tag :div, class: 'team-filter' do
      form_tag(request.url, name: "see_team", onchange: ("javascript: document.see_team.submit();"), method: :get) do
        label_tag :team_id, "Select #{(term_for :team).titleize}", class: 'sr-only'
        select_tag(:team_id, options_for_select(current_course.teams.map { |t| [t.name, t.id] }, params[:team_id]), prompt: "– Select #{(term_for :team).titleize} –")
      end
    end
  end
end
