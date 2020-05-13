class ResourceApi < Grape::API
  resource :resources do

    desc '查看所有权限'
    get do
      present Resource.resources, with: Entities::Resource
    end
  end
end