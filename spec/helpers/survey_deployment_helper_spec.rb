require 'rails_helper'

RSpec.describe SurveyDeploymentHelper, type: :helper do
  describe '#get_responses_for_question_in_a_survey_deployment' do
    let(:question) { create(:question) }
    let(:survey_deployment) { create(:survey_deployment, id: 9999) } # used as reviewee_id
    let(:response_map) { create(:review_response_map, reviewee_id: survey_deployment.id) }
    let(:response) { create(:response, response_map: response_map) }

    before do
      # Ensure the helper method has access to expected score range
      helper.instance_variable_set(:@range_of_scores, (0..5).to_a)

      # Simulate user submitted two answers with score 3
      create_list(:answer, 2, question_id: question.id, response_id: response.id, answer: 3)

      # Prevent unwanted DB hits for other scores by stubbing return counts as 0
      (0..5).each do |score|
        next if score == 3
        allow(Answer).to receive(:where).with(
          question_id: question.id,
          answer: score,
          response_id: response.id
        ).and_return(double(count: 0))
      end
    end

    it 'returns correct counts for scores' do
      # Verifies that scores are aggregated properly across responses for a given question
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result[3]).to eq(2)
      expect(result.sum).to eq(2)
    end
  end

  describe '#allowed_question_type?' do
    it 'returns true for Criterion' do
      # Checks if statistical computation is allowed on questions of type "Criterion"
      question = build(:question, type: 'Criterion')
      expect(helper.allowed_question_type?(question)).to be true
    end

    it 'returns true for Checkbox' do
      # Ensures support for checkbox-type questions in response distribution analysis
      question = build(:multiple_choice_checkbox, type: 'Checkbox')
      expect(helper.allowed_question_type?(question)).to be true
    end

    it 'returns false for other types' do
      # Validates that unsupported question types like TextArea are excluded from statistical operations
      question = build(:text_area, type: 'TextArea')
      expect(helper.allowed_question_type?(question)).to be false
    end

    it 'returns false for nil type' do
      # Covers edge case where question type is nil, preventing possible errors or false positives
      question = build(:question, type: nil)
      expect(helper.allowed_question_type?(question)).to be false
    end
  end
end
