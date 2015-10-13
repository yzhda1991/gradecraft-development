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
end
