class AddressApi < Grape::API
  mounted do
    resource configuration[:owner] do
      resource ':id' do
        desc '机构地址', entity: Entities::Address
        get :addresses do
          raise '不支持非机构的地址' unless configuration[:owner] == 'organizations'
          present Zombie::DmAddress.where(owner_type: 'Investor', owner_id: params[:id]).inspect, with: Entities::Address
        end

        desc '创建地址', entity: Entities::Address
        params do
          requires :location_id, type: Integer, desc: '地区id'
          requires :address_desc, type: String, desc: '地址详细'
        end
        post :addresses do
          # Dm新增method：DmAddress.create_address owner_type, owner_id, iso_location_id, location_id, address_desc
          raise '不支持非机构的地址' unless configuration[:owner] == 'organizations'
          address = Zombie::DmAddress.create_address('Investor', params[:id], nil, params[:location_id], params[:address_desc])
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
  end
end