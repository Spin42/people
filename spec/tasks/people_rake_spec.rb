require 'spec_helper'
require 'rake'

describe AvailabilityChecker do
  let!(:user) { create(:user, role: role, available: nil) }
  let(:role) { create(:role, technical: true) }

  describe 'people namespace rake task' do
    before :all do
      Rake.application.rake_require 'tasks/people'
      Rake::Task.define_task(:environment)
    end

    describe 'people:AvailabilityChecker' do
      before do
        AvailabilityCheckerJob.any_instance.stub(:perform)
      end

      let :run_rake_task do
        Rake::Task['people:available_checker'].reenable
        Rake.application.invoke_task 'people:available_checker'
      end

      it 'should receive perform' do
        AvailabilityCheckerJob.any_instance.should_receive :perform
        run_rake_task
      end
    end
  end
end