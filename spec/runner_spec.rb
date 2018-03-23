require 'bjob/runner'

RSpec.describe BJob::Runner do
  let(:job_const) { 'DumbJob' }
  let(:job_class) { stub_const(job_const, Class.new) }
  let(:job_method) { 'do_it' }
  let(:job_params) { [:some_param_value, :other_param] }
  let(:job_result) { 'done' }

  let(:job) { {'class' => job_const.to_s, 'method' => job_method, 'params' => job_params } }

  let(:logger) { instance_double(Logger) }
  before { allow(logger).to receive(:info) }
  subject { described_class.new(logger: logger) }

  context 'job implementation exists in the system' do
    before do
      allow_any_instance_of(job_class).to receive(job_method).with(*job_params).and_return(job_result)
    end

    it 'creates a job instance, run it and returns the call result' do
      expect_any_instance_of(job_class).to receive(job_method).with(*job_params)
      expect(subject.run(job)).to eq(job_result)
    end
  end

  context 'job implementation is missed' do
    before do
      job.update('class' => 'UndefinedClass')
    end

    it 'logs warning and does not run a job' do
      expect(logger).to receive(:warn).with(/UndefinedClass/)
      subject.run(job)
    end
  end

  context 'job raises some standard error' do
    before do
      job.update('class' => 'String', 'method' => 'undefined')
    end

    it 'logs error about failed job' do
      expect(logger).to receive(:error).with(/failed/)
      subject.run(job)
    end
  end
end
