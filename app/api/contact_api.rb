class ContactApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '所有联系人'
        get :contacts do
        end

        desc '新建联系人'
        params do
          requires :name, type: String, desc: '姓名'
          optional :position, type: String, desc: '职位'
          optional :tel, type: String, desc: '电话'
          optional :email, type: String, desc: '邮箱'
          optional :wechat, type: String, desc: '微信'
        end
        post :contacts do

        end
      end
    end
  end

  resources :contacts do
    resource :id do
      before do
      end

      desc '编辑联系人'
      params do
        requires :name, type: String, desc: '姓名'
        optional :position, type: String, desc: '职位'
        optional :tel, type: String, desc: '电话'
        optional :email, type: String, desc: '邮箱'
        optional :wechat, type: String, desc: '微信'
      end
      patch do

      end

      desc '删除联系人'
      delete do

      end
    end
  end

end
