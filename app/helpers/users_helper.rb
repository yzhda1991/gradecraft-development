module UsersHelper
  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end

  def flagged_user_icon(course, flagger, flagged_id)
    flagged = FlaggedUser.flagged? course, flagger, flagged_id
    style = flagged ? "fa-star" : "fa-star-o"
    text = flagged ? "Unflag" : "Flag"
    raw("<i class=\"fa #{style} fa-fw\"></i> #{text}")
  end
end
