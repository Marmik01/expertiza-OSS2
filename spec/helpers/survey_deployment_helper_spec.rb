RSpec.describe SurveyDeploymentHelper, type: :helper do
  describe '#get_responses_for_question_in_a_survey_deployment' do
    let(:question) { create(:question) }
    let(:survey_deployment) do
      create(:survey_deployment,
             id: 9999,
             type: 'AssignmentSurveyDeployment',
             start_date: Time.now + 1.day,
             end_date: Time.now + 2.days)
    end    
    let(:response_map) do
      create(:review_response_map, reviewee_id: survey_deployment.id, type: 'AssignmentSurveyResponseMap')
    end
    let(:response) { create(:response, map_id: response_map.id) }

    before do
      helper.instance_variable_set(:@range_of_scores, (0..5).to_a)
    end

    it 'returns correct counts for scores' do
      create_list(:answer, 2, question_id: question.id, response_id: response.id, answer: 3)
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result[3]).to eq(2)
    end

    it 'returns zero counts when no answers exist' do
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result).to eq([0, 0, 0, 0, 0, 0])
    end

    it 'returns correct distribution across multiple scores' do
      create(:answer, question_id: question.id, response_id: response.id, answer: 1)
      create(:answer, question_id: question.id, response_id: response.id, answer: 2)
      create_list(:answer, 2, question_id: question.id, response_id: response.id, answer: 5)
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result).to eq([0, 1, 1, 0, 0, 2])
    end

    it 'aggregates answer counts from multiple response maps' do
      create(:answer, question_id: question.id, response_id: response.id, answer: 3)

      # Create another response map and response
      another_map = create(:review_response_map, reviewee_id: survey_deployment.id, type: 'AssignmentSurveyResponseMap')
      another_response = create(:response, map_id: another_map.id)
      create(:answer, question_id: question.id, response_id: another_response.id, answer: 3)

      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result[3]).to eq(2)
    end

    # new: handles invalid survey_deployment id
    it 'returns all zeros if survey_deployment id is invalid' do
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, -1)
      expect(result).to eq([0, 0, 0, 0, 0, 0])
    end

    # new: handles invalid question id
    it 'raises error when invalid question id is used' do
      expect {
        helper.get_responses_for_question_in_a_survey_deployment(-123, survey_deployment.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    # new: handles nil @range_of_scores
    it 'returns empty array when @range_of_scores is nil' do
      helper.instance_variable_set(:@range_of_scores, nil)
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result).to eq([])
    end

    # new: handles custom score range
    it 'works correctly with custom @range_of_scores (1 to 3)' do
      helper.instance_variable_set(:@range_of_scores, (1..3).to_a)
      create(:answer, question_id: question.id, response_id: response.id, answer: 2)
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result).to eq([0, 1, 0])
    end
  end

  describe '#allowed_question_type?' do
    it 'returns true for Criterion' do
      question = double('Question', type: 'Criterion')
      expect(helper.allowed_question_type?(question)).to be true
    end

    it 'returns true for Checkbox' do
      question = double('Question', type: 'Checkbox')
      expect(helper.allowed_question_type?(question)).to be true
    end

    it 'returns false for other types' do
      question = double('Question', type: 'TextArea')
      expect(helper.allowed_question_type?(question)).to be false
    end

    it 'returns false for nil type' do
      question = double('Question', type: nil)
      expect(helper.allowed_question_type?(question)).to be false
    end

    it 'returns false for an empty string type' do
      question = double('Question', type: '')
      expect(helper.allowed_question_type?(question)).to be false
    end

    # new: verifies a type that is unknown/unsupported
    it 'returns false for an unknown type' do
      question = double('Question', type: 'Dropdown')
      expect(helper.allowed_question_type?(question)).to be false
    end
  end
end
