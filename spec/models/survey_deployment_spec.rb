# spec/models/survey_deployment_spec.rb
require 'rails_helper'

RSpec.describe SurveyDeployment, type: :model do
  describe 'validations' do
    it 'is invalid without a start_date' do
      sd = SurveyDeployment.new(end_date: Time.now + 1.day)
      expect(sd).not_to be_valid
      expect(sd.errors[:start_date]).to include("can't be blank")
    end

    it 'is invalid without an end_date' do
      sd = SurveyDeployment.new(start_date: Time.now)
      expect(sd).not_to be_valid
      expect(sd.errors[:end_date]).to include("can't be blank")
    end

    it 'is invalid when both start_date and end_date are nil' do
      sd = SurveyDeployment.new
      expect(sd).not_to be_valid
      expect(sd.errors[:base]).to include('The start and end time should be specified.')
    end

    it 'is invalid if end_date is before start_date' do
      sd = SurveyDeployment.new(start_date: Time.now + 2.days, end_date: Time.now + 1.day)
      expect(sd).not_to be_valid
      expect(sd.errors[:base]).to include('The End Date should be after the Start Date.')
    end

    it 'is invalid if end_date is in the past' do
      sd = SurveyDeployment.new(start_date: Time.now - 1.day, end_date: Time.now - 1.hour)
      expect(sd).not_to be_valid
      expect(sd.errors[:base]).to include('The End Date should be in the future.')
    end

    it 'is valid with correct start_date and end_date' do
      sd = SurveyDeployment.new(start_date: Time.now, end_date: Time.now + 1.day)
      expect(sd).to be_valid
    end
  end

  describe 'abstract methods' do
    let(:sd) { SurveyDeployment.new(start_date: Time.now, end_date: Time.now + 1.day) }

    it 'responds to parent_name' do
      expect { sd.parent_name }.not_to raise_error
    end

    it 'responds to response_maps' do
      expect { sd.response_maps }.not_to raise_error
    end
  end
end
