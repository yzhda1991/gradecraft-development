describe CourseAnalyticsExportPerformer do
  subject { described_class.new export_id: export.id }

  let(:export) { create :course_analytics_export }
  let(:owner) { export.owner }
  let(:course) { export.course }

  it "has some readable attributes" do
    expect(subject.export).to eq export
    expect(subject.course).to eq export.course
    expect(subject.owner).to eq export.owner
  end

  describe "#setup" do
    # note that #setup is called whenever a descendant of ResqueJob::Performer
    # is instantiated, so just building a new subject here will automatically
    # call setup for us unless we expressly call skip_setup: true in the attrs

    it "finds the export by id and assigns it to @export" do
      subject
      expect(subject.export).to eq export
    end

    it "assigns some export attributes to the performer" do
      subject
      expect(subject.course).to eq export.course
      expect(subject.owner).to eq export.owner
    end

    it "updates the export started time" do
      expect_any_instance_of(export.class).to receive(:update_export_started_time)
      subject
    end
  end

  describe "#do_the_work" do
    before do
      # let's stub out #build_the_export and #deliver mailer so it doesn' take
      # until Tuesday to run the suite
      #
      allow(subject).to receive_messages \
        build_the_export: ["the-export"],
        deliver_mailer: true
    end

    it "builds the export" do
      expect(subject).to receive(:build_the_export)
      subject.do_the_work
    end

    it "delivers the mailer" do
      expect(subject).to receive(:deliver_mailer)
      subject.do_the_work
    end

    it "updates the export with the update completed time" do
      expect(subject.export).to receive(:update_export_completed_time)
      subject.do_the_work
    end
  end

  describe "#deliver_mailer" do
    let(:mailer) { double(:mailer).as_null_object }

    before do
      allow(subject).to receive_messages \
        success_mailer: mailer,
        failure_mailer: mailer
    end

    context "the export archive has been successfully uploaded to s3" do
      it "uses the success mailer" do
        allow(subject.export).to receive(:s3_object_exists?) { true }
        expect(subject).to receive(:success_mailer)
        subject.deliver_mailer
      end
    end

    context "the export archive failed to upload to s3" do
      it "users the failure mailer" do
        allow(subject.export).to receive(:s3_object_exists?) { false }
        expect(subject).to receive(:failure_mailer)
        subject.deliver_mailer
      end
    end

    it "delivers the mailer" do
      expect(mailer).to receive(:deliver_now)
      subject.deliver_mailer
    end
  end

  describe "sending mailers" do
    let(:mailer_class) { CourseAnalyticsExportsMailer }

    before(:each) do
      # stub this out because we're going to test the mailer in the mailer
      # spec, not in the performer spec. let's just make sure it's being
      # called but don't actually call it
      allow(mailer_class).to receive_messages \
        export_success: true, export_failure: true
    end

    it "builds a mailer for course analytics export success" do
      token = double(:secure_token)
      allow(subject.export).to receive(:generate_secure_token) { token }

      expect(mailer_class).to receive(:export_success)
        .with export: export, token: token

      subject.success_mailer
    end

    it "builds a mailer for course analytics export failure" do
      expect(mailer_class).to receive(:export_failure)
        .with export: export

      subject.failure_mailer
    end
  end

  describe "#build_the_export" do
    before do
      allow(subject.export).to receive_messages \
        upload_builder_archive_to_s3: true,
        build_archive!: true
    end

    it "tells the export to build an archive" do
      expect(subject.export).to receive(:build_archive!)
      subject.instance_eval { build_the_export }
    end

    it "uploads the builder archive to s3" do
      expect(subject.export).to receive(:upload_builder_archive_to_s3)
      subject.instance_eval { build_the_export }
    end

    it "updates the export completed time" do
      expect(subject.export).to receive(:update_export_completed_time)
      subject.instance_eval { build_the_export }
    end
  end
end
