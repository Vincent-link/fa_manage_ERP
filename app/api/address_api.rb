class AddressApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '机构地址', entity: Entities::Address
        get :addresses do
          case configuration[:owner]
          when 'organizations'
            present Zombie::DmAddress.where(owner_type: 'Investor', owner_id: params[:id]).inspect, with: Entities::Address
          when 'companies'
            present Zombie::DmAddress.where(owner_type: 'Company', owner_id: params[:id]).inspect, with: Entities::Address
          else
            raise '不支持该类型的地址'
          end
        end

        desc '创建地址', entity: Entities::Address
        params do
          requires :location_id, type: Integer, desc: '地区id'
          requires :address_desc, type: String, desc: '地址详细'
        end
        post :addresses do
          case configuration[:owner]
          when 'organizations'
            address = Zombie::DmAddress.create_address('Investor', params[:id], nil, params[:location_id], params[:address_desc])
          when 'companies'
            address = Zombie::DmAddress.create_address('Company', params[:id], nil, params[:location_id], params[:address_desc])
          else
            raise '不支持该类型的地址'
          end
          present address, with: Entities::Address
        end
      end
    end
  end

  resource :addresses do
    resource ':id' do
      desc '删除地址'
      delete do
        if params[:id] >= 100001
          Address.find(params[:id]).destroy!
        else
          Zombie::DmAddress._by_id(params[:id]).destroy
        end
      end

      desc '修改地址'
      params do
        requires :location_id, type: Integer, desc: '地区id'
        requires :address_desc, type: String, desc: '地址详细'
      end
      patch do
        if params[:id] >= 100001
          Address.update!(declared(params))
        else
          # Dm更新method：DmAddress.update_address(id, iso_location_id, location_id, address_desc)
          Zombie::DmAddress.update_address(params[:id], nil, params[:location_id], params[:address_desc])
        end
      end
    end

    desc '创建其他地址'
    params do
      requires :location_id, type: Integer, desc: '地区id'
      requires :address_desc, type: String, desc: '地址详细'
    end
    post do
      # Dm create method：DmAddress.create_address(owner_type, owner_id, iso_location_id, location_id, address_desc)
      Address.create declared(params)
    end

    desc '获取其他地址'
    get do
      present Address.customer, with: Entities::Address
    end

    desc '获取华兴地址'
    get :huaxing do
      present Address.huaxing_office, with: Entities::Address
    end
  end
end