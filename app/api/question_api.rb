class QuestionApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':funding_id' do

        desc '获取问题'
        get :questions do
          questions_answers = Question.joins(:answers).where(funding_id: params[:funding_id])
        end

      end
    end
  end
end
