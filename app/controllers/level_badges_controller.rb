class LevelBadgesController< ApplicationController
  before_filter :ensure_staff?

  def create
    level_badge = LevelBadge.create params[:level_badge]
    render json: level_badge, serializer: ExistingLevelBadgeSerializer
  end

  def destroy
    LevelBadge.find(params[:id]).destroy
    render nothing: true
  end
end
