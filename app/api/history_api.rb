class HistoryApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '获取字段history（假）'
        params do
          requires :column, type: String, desc: '字段名'
          optional :page, type: Integer, desc: '页数'
          optional :per_page, type: Integer, desc: '每页条数'
        end
        get :column_history do
          versions = configuration[:owner].classify.constantize.find(params[:id]).versions.where("object_changes ? :column", column: params[:column])
          present versions, with: Entities::ColumnHistory, column: params[:column]
        end
      end
    end
  end
end