#------------------------------------------------------------------------------#
# Learning objectives
#------------------------------------------------------------------------------#

@learning_objective_default_config = {
  quotes: {
    learning_objective_created: "A learning objective has been created"
  },
  attributes: {
    name: "Generic Learning Objective",
    description: nil,
    count_to_achieve: 3,
    category: nil
  }
}

@learning_objectives = {
  global_awareness: {
    attributes: {
      name: "Global Self-Awareness",
      category: :global,
      description: "Describe ways that an individual's personal decisions might affect
        local and global issues"
    }
  },
  perspective_taking: {
    attributes: {
      name: "Perspective Taking",
      description: "Identify and provide a somewhat neutral description of a perspective
        other than one's own perspective"
    }
  },
  cultural_diversity: {
    attributes: {
      name: "Cultural Diversity",
      category: :intercultural,
      description: "Demonstrate respectful interaction with varied cultures and world
        views"
    }
  },
  personal_and_social_responsibility: {
    attributes: {
      name: "Personal and Social Responsibility",
      category: :global,
      description: "Take actions to make small-scale contributions to a global issue"
    }
  },
  understanding_global_systems: {
    attributes: {
      name: "Understanding Global Systems",
      category: :global,
      description: "Describe a previously unfamiliar global system in the human or
        natural world"
    }
  },
  applying_knowledge: {
    attributes: {
      name: "Applying Knowledge to Contemporary Global Contexts",
      category: :interdisciplinary,
      description: "Apply principles from two or more classes in different disciplines
        toward solving a problem"
    }
  }
}

#------------------------------------------------------------------------------#
# Learning objective categories
#------------------------------------------------------------------------------#

@learning_objective_category_default_config = {
  quotes: {
    learning_objective_category_created: "A learning objective category has been created"
  },
  attributes: {
    name: "Generic Learning Objective Category",
    description: nil
  }
}

@learning_objective_categories = {
  global: {
    attributes: {
      name: "Global",
      description: "Global Impact"
    }
  },
  cultural: {
    attributes: {
      name: "Intercultural",
      description: "Cultural Impact"
    }
  },
  interdisciplinary: {
    attributes: {
      name: "Interdisciplinary",
      description: "Interdisciplinary concepts"
    }
  }
}

#------------------------------------------------------------------------------#
# Learning objective levels
#------------------------------------------------------------------------------#

@learning_objective_level_default_config = {
  quotes: {
    learning_objective_level_created: "A learning objective level has been created"
  },
  attributes: {
    name: "Generic Learning Objective Level",
    description: nil,
    flagged_value: :proficient
  }
}

@learning_objective_levels = {
  not_proficient: {
    attributes: {
      name: "Not Proficient",
      description: "Not good!",
      flagged_value: :not_proficient
    }
  },
  proficient: {
    attributes: {
      name: "Proficient",
      description: "Good job!",
      flagged_value: :proficient
    }
  }
}

def create_sample_learning_objectives
  categories = {}
  course = Course.where(course_number: "GC107", name: "Course with Learning Objectives").first

  puts "Creating learning objective categories"
  @learning_objective_categories.each do |lo_category_name, config|
    categories[lo_category_name] = LearningObjectiveCategory.create! do |c|
      @learning_objective_category_default_config[:attributes].keys.each do |attr|
        c[attr] = config[:attributes].key?(attr) ?
          config[:attributes][attr] :
            @learning_objective_category_default_config[:attributes][attr]
      end
      c.course = course
    end
  end
  puts ">> Learning objective categories created"

  puts "Creating learning objectives"
  @learning_objectives.each do |lo_name, config|
    course = Course.where(course_number: "GC107", name: "Course with Learning Objectives").first

    learning_objective = LearningObjective.create! do |lo|
      @learning_objective_default_config[:attributes].keys.each do |attr|
        if attr == :category
          lo.category = categories[config[:attributes][attr]]
        else
          lo[attr] = config[:attributes].key?(attr) ?
            config[:attributes][attr] :
              @learning_objective_default_config[:attributes][attr]
        end
      end
      lo.course = course

      puts "Adding learning objective levels"
      lo.levels << @learning_objective_levels.map do |level_name, config|
        LearningObjectiveLevel.new do |l|
          @learning_objective_level_default_config[:attributes].keys.each do |attr|
            l[attr] = config[:attributes].key?(attr) ?
              config[:attributes][attr] :
                @learning_objective_level_default_config[:attributes][attr]
          end
          l.course = course
          l.objective = lo
        end
      end
    end
  end
  puts ">> Learning objectives created"
end
