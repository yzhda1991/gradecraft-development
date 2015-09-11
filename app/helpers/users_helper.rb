module UsersHelper
  def generate_random_password
    Sorcery::Model::TemporaryToken.generate_random_token
  end

  def flagged_user_icon(course, flagger, flagged_id)
    flagged = FlaggedUser.flagged? course, flagger, flagged_id
    raw("<i class=\"fa fa-flag fa-fw #{"flagged" if flagged}\"></i>")
  end
end
