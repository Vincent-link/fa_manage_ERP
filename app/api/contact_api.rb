class ContactApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '所有联系人', entity: Entities::Contact
        get :contacts do
          present Contact.where(company_id: params[:id]), with: Entities::Contact
        end

        desc '新建联系人'
        params do
          requires :name, type: String, desc: '姓名'
          optional :position, type: Integer, desc: '职位'
          optional :tel, type: String, desc: '电话'
          optional :email, type: String, desc: '邮箱'
          optional :wechat, type: String, desc: '微信'
        end
        post :contacts do
          Contact.create!(declared(params).merge(company_id: params[:id]))
        end
      end
    end
  end

  resources :contacts do
    resource ':id' do
      before do
        @contact = Contact.find(params[:id])
      end

      desc '编辑联系人'
      params do
        requires :name, type: String, desc: '姓名'
        optional :position, type: Integer, desc: '职位'
        optional :tel, type: String, desc: '电话'
        optional :email, type: String, desc: '邮箱'
        optional :wechat, type: String, desc: '微信'
      end
      patch do
        @contact.update(declared(params))
      end

      desc '删除联系人'
      delete do
        @contact.destroy()
      end
    end
  end

end
