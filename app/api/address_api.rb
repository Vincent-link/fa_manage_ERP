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
        Zombie::DmAddress._by_id(params[:id]).destroy
      end

      desc '修改地址'
      params do
        requires :location_id, type: Integer, desc: '地区id'
        requires :address_desc, type: String, desc: '地址详细'
      end
      patch do
        # Dm更新method：DmAddress.update_address(id, iso_location_id, location_id, address_desc)
        Zombie::DmAddress.update_address(params[:id], nil, params[:location_id], params[:address_desc])
      end
    end

    desc '创建其他地址'
    params do
      requires :location_id, type: Integer, desc: '地区id'
      requires :address_desc, type: String, desc: '地址详细'
    end
    post do
      # Dm create method：DmAddress.create_address(owner_type, owner_id, iso_location_id, location_id, address_desc)
      Zombie::DmAddress.create_address('FaCustomer', nil, nil, params[:location_id], params[:address_desc])
    end

    desc '获取其他地址'
    get do
      present Zombie::DmAddress.where(owner_type: 'FaCustomer').inspect, with: Entities::Address
    end
  end
end