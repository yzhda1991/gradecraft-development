# require 'rails_spec_helper'

# this has been commented out for the time being in groups controllers
# and in the notifications mailer
#
# if this is being re-activated please uncomment all corresponding parts
#
# specs for submission notifications that are sent to students
# describe NotificationMailer do
#   let(:sender) { NotificationMailer::SENDER_EMAIL }
#   let(:professor) { create(:user) }
#   let(:group) { create(:group, course: course) }
#   let(:course) { create(:course) }
# 
#   describe "#group_created" do
#     let(:email) { ActionMailer::Base.deliveries.last }
# 
#     before(:each) do
#       NotificationMailer.group_created(group.id, professor).deliver_now
#     end
# 
#     it "is sent from gradecraft's default mailer email" do
#       expect(email.from).to eq [sender]
#     end
# 
#     it "is sent to the professor's email" do
#       expect(email.to).to eq [professor.email]
#     end
# 
#     it "has the correct subject" do
#       expect(email.subject).to eq "#{course.courseno} - New Group to Review"
#     end
# 
#     describe "text email part body" do
#       subject { email.body }
# 
#       it "includes the professor's last name" do
#         should include professor.last_name
#       end
# 
#       it "doesn't include a template" do
#         should_not include "Regents of The University of Michigan"
#       end
# 
#       it "includes the course name" do
#         should include course.name
#       end
#     end
#   end
# end
