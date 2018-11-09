class Admin::TasksController < ApplicationController
  before_action :ensure_admin?

  def unlocks
  end
end
