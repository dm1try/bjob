require 'bjob/runner'

RSpec.describe BJob::Runner do
  let(:job_const) { DumbJob = Class.new }
  let(:job_method) { 'do_it' }
  let(:job_params) { [:some_param_value, :other_param] }
  let(:job_result) { 'done' }

  let(:job) { {'class' => job_const.to_s, 'method' => job_method, 'params' => job_params } }

  context 'job implementation exists in the system' do
    before do
      allow_any_instance_of(job_const).to receive(job_method).with(*job_params).and_return(job_result)
    end

    it 'creates a job instance, run it and returns the call result' do
      expect_any_instance_of(job_const).to receive(job_method).with(*job_params)
      expect(subject.run(job)).to eq(job_result)
    end
  end
end
