require 'spec_helper'

RSpec.describe GradebookExporterJob do
  include InQueueHelper # pulled from ResqueSpec

  describe "#enqueue" do
    before(:each) { ResqueSpec.reset! }

    it "increases the queue size by one" do
      expect{
        GradebookExporterJob.new(user_id: 18, course: 1).enqueue
      }.to change { queue(GradebookExporterJob).size }.by(1)
    end

    it "queues what it was supposed to" do
      GradebookExporterJob.new(user_id: 18, course: 1).enqueue
      pp queue(GradebookExporterJob)
      # expect(GradebookExporterJob).to have_queued({user_id: 18, course: 1}).in(:grade_exporter)
    end
  end

  describe "#enqueue_in" do
    it "creates a new GradebookExporterJob and triggers enqueue" do
      expect{
        GradebookExporterJob.new(user_id: 18, course: 1).enqueue
      }.to change { queue(GradebookExporterJob).size }.by(1)
    end
  end
end
