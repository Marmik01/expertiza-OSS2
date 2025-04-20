RSpec.describe SurveyDeploymentHelper, type: :helper do
  describe '#get_responses_for_question_in_a_survey_deployment' do
    let(:question) { build_stubbed(:question) }
    let(:survey_deployment) { build_stubbed(:survey_deployment, id: 9999) }
    let(:response_map) { create(:review_response_map, reviewee_id: survey_deployment.id) }
    let(:response) { create(:response, response_map: response_map) }

    before do
      helper.instance_variable_set(:@range_of_scores, (0..5).to_a)

      create_list(:answer, 2, question_id: question.id, response_id: response.id, answer: 3)

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
      result = helper.get_responses_for_question_in_a_survey_deployment(question.id, survey_deployment.id)
      expect(result[3]).to eq(2)
      expect(result.sum).to eq(2)
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
  end
end
