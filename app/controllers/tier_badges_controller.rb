class TierBadgesController< ApplicationController
  before_filter :ensure_staff?

  before_action :find_tier_badge, only: [:update, :destroy]

  respond_to :html, :json

  def create
    @tier_badge = TierBadge.create params[:tier_badge]
    respond_with @tier_badge, layout: false, serializer: ExistingTierBadgeSerializer
  end

  def destroy
    @tier_badge.destroy
    render :nothing => true
  end

  private

  def serialized_tier
    ExistingTierSerializer.new(@tier.includes(:tiers)).to_json
  end

  def find_tier_badge
    @tier_badge = TierBadge.find params[:id]
  end
end
