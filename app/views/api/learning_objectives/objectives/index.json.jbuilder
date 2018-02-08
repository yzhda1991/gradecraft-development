json.data @objectives do |objective|
  json.type "learning_objective"
  json.id objective.id

  json.attributes do
    json.partial! 'api/learning_objectives/objectives/objective', objective: objective

    json.category_name objective.category.name unless objective.category.nil?
  end

  json.relationships do
    json.linked_assignments do
      json.data objective.assignments do |assignment|
        json.type "linked_assignments"
        json.id assignment.id
      end
    end
  end
end

json.included do
  @objectives.each do |o|
    json.array! o.levels do |level|
      json.type "levels"
      json.id level.id.to_s

      json.attributes do
        json.merge! level.attributes
      end
    end

    json.array! o.assignments do |assignment|
      json.type "linked_assignments"
      json.id assignment.id

      json.attributes do
        json.assignment_id assignment.id
        json.objective_id o.id
      end
    end
  end
end

json.meta do
  json.term_for_learning_objective term_for :learning_objective
  json.term_for_learning_objectives term_for :learning_objectives
end
