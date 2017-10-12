namespace :rubrics do
  desc "add course ids to all rubrics without them"
  task add_course_id: :environment do
    Rubric.where("course_id is NULL").find_each(batch_size: 500) do |rubric|
      rubric.update(course_id: rubric.assignment.course_id)
    end
  end

  desc "resolve errant level badges on copied rubrics"
  # This task attempts to resolve errant EarnedBadges on a copied rubric for the
  # scenario where a LevelBadge still references the old badge id from the original
  # course. Following this, all errant LevelBadges for the rubric on the assignment
  # will also be destroyed.
  #
  # Two scenarios are addressed with EarnedBadges:
  # 1. If the student has earned the errant badge but not the valid badge for the
  #      current course, then the errant badge will be updated accordingly so that
  #       the course_id and badge_id are correct.
  # 2. If the student has earned both the errant badge as well as the valid
  #      valid badge, then the errant earned badge will be destroyed
  #
  # Provide the following arguments:
  # course_id: the affected course id
  # assignment_id: the assignment for which the level badges exist
  # errant_badge_id: the id of the badge that does not exist for the course
  # new_badge_id: the translated badge id corresponding to the copied badge in the current course
  #
  # rails "rubrics:fix_copied_rubrics[course_id, assignment_id, errant_badge_id, new_badge_id]"
  task :fix_copied_rubrics, [:course_id, :assignment_id, :errant_badge_id, :new_badge_id] => [:environment] do |task, args|
    course = Course.find args[:course_id]
    assignment = course.assignments.find args[:assignment_id]
    errant_badge_id = args[:errant_badge_id]
    new_badge_id = args[:new_badge_id]

    grade_ids_for_assignment = Grade.where(assignment_id: assignment.id).pluck(:id)

    # all the earned badge ids for this assignment
    earned_badge_ids = EarnedBadge.where(grade_id: grade_ids_for_assignment).pluck(:id)

    # the student ids from the EarnedBadges in this assignment that have the errant badge id
    bad_ebs = EarnedBadge.where(id: earned_badge_ids, badge_id: errant_badge_id).pluck(:student_id)

    # the student ids from the EarnedBadges in this assignment that have the correct badge id
    good_ebs = EarnedBadge.where(id: earned_badge_ids, badge_id: new_badge_id).pluck(:student_id)

    sida_1 = bad_ebs - good_ebs # Students that have earned the errant badge but not the valid one
    sida_2 = bad_ebs & good_ebs # Students that have earned both the errant badge and the valid one; the intersection of the two arrays

    # Perform the necessary updates/deletions
    EarnedBadge.where(student_id: sida_1, badge_id: errant_badge_id).update(badge_id: new_badge_id, course_id: course.id)
    EarnedBadge.where(student_id: sida_2, badge_id: errant_badge_id).destroy_all

    # target and destroy the errant level badges associated with the rubric on the assignment
    badge_ids_for_course = course.badges.pluck(:id)
    corrupt_level_badges = LevelBadge
      .where(level_id: Level.where(criterion_id: Criterion.where(rubric_id: assignment.rubric.id)))
      .where.not(badge_id: badge_ids_for_course)
    corrupt_level_badges.destroy_all

    # recalculate scores
    course.recalculate_student_scores

    # Rinse and repeat for additional assignments, badge permutations...
  end
end
