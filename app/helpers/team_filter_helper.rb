module TeamFilterHelper

  def team_filter(teams)
    content_tag :div, class: 'team-filter' do
      form_tag(request.url, class: "team-selector", onchange: "$('.team-selector').submit();", method: :get) do
        label_tag :team_id, "Select #{(term_for :team).titleize}", class: 'sr-only'
        select_tag(:team_id, options_for_select(teams.alpha.sort_by{|f| f.name.split(" ").last.to_i }.map { |t| [t.name, t.id] }, params[:team_id]), prompt: "– Select #{(term_for :team).titleize} –")
      end
    end
  end
end
