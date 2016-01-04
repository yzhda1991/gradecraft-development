module Historical
  extend ActiveSupport::Concern

  included do
    has_paper_trail
  end

  def has_history?
    !history.empty?
  end

  def history
    self.versions.reverse.map do |version|
      changeset = version.changeset.dup
      changeset.merge!("object" => self.class.name)
      changeset.merge!("event" => version.event)
      changeset.merge!("actor_id" => version.whodunnit)
    end
  end
end
