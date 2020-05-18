class UserTitleApi < Grape::API
  resource :user_titles do

    desc '所有对外title', entity: Entities::UserTitle
    get do
      present UserTitle.all, with: Entities::UserTitle
    end

    desc "新增对外title", entity: Entities::UserTitle
    params do
      optional :name, type: String, desc: 'Title'
    end
    post do
      present UserTitle.create!(declared(params)), with: Entities::UserTitle
    end

    resources ':id' do
      before do
        @user_title = UserTitle.find(params[:id])
      end

      desc '删除Title'
      delete do
        @user_title.destroy!
      end

      desc '更新Title', entity: Entities::UserTitle
      params do
        requires :name, type: String, desc: '名称'
      end
      patch do
        @user_title.update(declared(params))
        present @user_title, with: Entities::UserTitle
      end

      # desc 'Title对应用户', entity: Entities::User
      # get :users do
      #   @users = User.where(user_title_id: @user_title.id)
      #   present @users, with: Entities::User
      # end
      
    end

  end
end