module ResqueJobSharedExamplesToolkit
  RSpec.shared_examples "a successful resque job" do |job_klass|
    it "increases the queue size by one" do
      expect{ subject }.to change { queue(job_klass).size }.by(1)
    end

    it "queues the job" do
      subject
      expect(job_klass).to have_queued(job_attributes)
    end

    it "builds a new #{job_klass}" do
      subject
      expect(assigns(job_klass.to_s.underscore.to_sym).class).to eq(job_klass)
    end
  end


  RSpec.shared_examples "a failed resque job" do |job_klass|
    it "doesn't change the queue size" do
      expect{ subject }.to change { queue(job_klass).size }.by(0)
    end

    it "doesn't queue the job" do
      subject
      expect(job_klass).not_to have_queued(job_attributes)
    end

    it "shouldn't build a new #{job_klass}" do
      subject
      expect(assigns(job_klass.to_s.underscore.to_sym)).to eq(nil)
    end
  end

  RSpec.shared_examples "a batch of successful resque jobs" do |batch_size, job_klass|
    it "increases the queue size by the batch size" do
      expect{ subject }.to change { queue(job_klass).size }.by(batch_size)
    end

    it "queues each job with the correct attributes" do
      subject

      # @mz todo: figure out how these are supposed to be sorted in the controller
      queuelike_attrs = batch_attributes.sort_by{|item| item[:user_id]}.collect do |job_attributes|
        {class: job_klass.to_s, args: [job_attributes]}
      end

      expect(queuelike_attrs).to eq(queue(job_klass).sort_by{|job| job[:args].first[:user_id]})
    end

    it "builds a batch of new #{job_klass} instances" do
      allow(job_klass).to receive(:new) { double(job_klass).as_null_object }
      expect(job_klass).to receive(:new).exactly(batch_size).times
      subject
    end

    it "adds the #{job_klass} instances to an array" do
      subject
      expect(assigns(job_klass.to_s.underscore.pluralize.to_sym).size).to eq(batch_size)
    end
  end
end
