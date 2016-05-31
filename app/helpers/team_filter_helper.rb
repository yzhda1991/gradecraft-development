module TeamFilterHelper

  def team_filter(teams)
    content_tag :div, class: 'team-filter' do
      form_tag(request.url, name: "team_selector", onchange: ("javascript: document.team_selector.submit();"), method: :get) do
        label_tag :team_id, "Select #{(term_for :team).titleize}", class: 'sr-only'
        select_tag(:team_id, options_for_select(teams.alpha.map { |t| [t.name, t.id] }, params[:team_id]), prompt: "– Select #{(term_for :team).titleize} –")
      end
    end
  end
end
