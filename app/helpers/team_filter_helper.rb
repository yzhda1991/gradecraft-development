module TeamFilterHelper

  def team_filter(redirect_to)
    capture_haml do
      haml_tag :div, class: "team-filter" do
        haml_tag :form_tag, redirect_to

        # = form_tag redirect_to, name: "see_team", onchange: ("javascript: document.see_team.submit();"), method: :get do
        #   %label.sr-only{:for => "team_id"}
        #     Select #{term_for :team} –
        #   = select_tag :team_id, options_for_select(presenter.teams.map { |t| [t.name, t.id] }, presenter.team.try(:id)), prompt: "– Select #{(term_for :team).titleize} –"
      end
    end
  end

end
