namespace :courses do
  desc "Updates all the administrators in the system to have access to all courses"
  task update_admins: :environment do
    courses = Course.all
    CourseMembership.where(role: "admin").select(:user_id).uniq.each do |membership|
      user = User.find membership.user_id
      user.admin = true
      user.save
      courses.each do |course|
        if !CourseMembership.where(user_id: user.id, role: "admin").exists?
          CourseMembership.create! course_id: course.id, user_id: user.id, role: "admin"
        end
      end
    end
  end

  desc "Sets all existing courses as Published"
  task publish_all: :environment do
    Course.update_all(published: true)
  end

  desc "Removes all the orphaned data for course memberships"
  task :remove_orphaned_memberships, [:dry_run] => :environment do |t, args|
    args.with_defaults(dry_run: true)
    dry_run = args[:dry_run] != "false"

    puts "*** DRY RUN: NO DATA WILL BE DELETED ***" if dry_run
    memberships = CourseMembership.where(role: :student)
    puts "There are #{memberships.count} student #{"membership".pluralize(memberships.count)} to validate"

    # Submissions
    remove_orphans collect_orphans(memberships, Submission.all),
      Submission, dry_run

    # Grades
    remove_orphans collect_orphans(memberships, Grade.all),
      Grade, dry_run

    # CriterionGrades
    criterion_grades = collect_orphans memberships, CriterionGrade.all do |rg, m|
      CriterionGrade.for_course(m.course).where(student_id: m.user_id).present?
    end
    remove_orphans criterion_grades, CriterionGrade, dry_run

    # AssignmentTypeWeights
    remove_orphans collect_orphans(memberships, AssignmentTypeWeight.all),
      AssignmentTypeWeight, dry_run

    # EarnedBadges
    remove_orphans collect_orphans(memberships, EarnedBadge.all),
      EarnedBadge, dry_run

    # PredictedEarnedBadges
    badges = collect_orphans memberships, PredictedEarnedBadge.joins(:badge).all do |peb, m|
      peb.badge.present? && peb.badge.course_id == m.course_id &&
        peb.student_id == m.user_id
    end
    remove_orphans badges, PredictedEarnedBadge, dry_run

    # PredictedEarnedChallenges
    challenges = collect_orphans memberships, PredictedEarnedChallenge.joins(:challenge).all do |pec, m|
      pec.challenge.present? && pec.challenge.course_id == m.course_id &&
        pec.student_id == m.user_id
    end
    remove_orphans challenges, PredictedEarnedChallenge, dry_run

    # GroupMemberships
    groups = collect_orphans memberships, GroupMembership.joins(:group).all do |gm, m|
      gm.group.present? && gm.group.course_id == m.course_id &&
        gm.student_id == m.user_id
    end
    remove_orphans groups, GroupMembership, dry_run

    # TeamMemberships
    teams = collect_orphans memberships, TeamMembership.joins(:team).all do |tm, m|
      tm.team.present? && tm.team.course_id == m.course_id &&
        tm.student_id == m.user_id
    end
    remove_orphans teams, TeamMembership, dry_run

    # AnnouncementStates
    states = collect_orphans memberships, AnnouncementState.joins(:announcement).all do |as, m|
      as.announcement.present? && as.announcement.course_id == m.course_id &&
        as.student_id == m.user_id
    end
    remove_orphans states, AnnouncementState, dry_run

    # FlaggedUsers
    remove_orphans collect_orphans(memberships, FlaggedUser.all, :course_id, :flagged_id), FlaggedUser, dry_run
  end

  def collect_orphans(memberships, query, course_id_method=:course_id,
                      student_id_method=:student_id)
    orphans = []
    query.find_in_batches do |group|
      group.each do |orphan|
        orphans << orphan if memberships.none? do |m|
          if block_given?
            yield orphan, m
          else
            m.course_id == orphan.send(course_id_method) &&
              m.user_id == orphan.send(student_id_method)
          end
        end
      end
    end
    orphans
  end

  def remove_orphans(orphans, type, dry_run)
    puts "Deleting #{orphans.size} #{type.name.pluralize(orphans.size)}..."
    orphans.each(&:destroy) unless dry_run
  end
end
