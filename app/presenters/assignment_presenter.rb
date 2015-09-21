require "active_support/inflector"
require "./lib/presenter"
require_relative "view_context"

class AssignmentPresenter < Presenter::Base
  include Presenter::ViewContext

  def assignment
    properties[:assignment]
  end

  def title
    title = assignment.name
    if assignment.pass_fail?
      title += " (#{view_context.term_for :pass}/#{view_context.term_for :fail})"
    else
      title += " (#{view_context.number_with_delimiter assignment.point_total} #{"points".pluralize(assignment.point_total)})"
    end
    title
  end
end
