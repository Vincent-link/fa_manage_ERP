class TagApi < Grape::API
  resource :tags do
    desc '获取投资人tag'
    params do
      requires :category, type: String, desc: 'tag类别', values: ['member_hot_spot']
    end
    get do
      present Tag.send("category_#{params[:category]}"), with: Entities::Tag
    end
  end
end