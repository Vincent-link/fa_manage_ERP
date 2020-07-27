class AddDataToNews < ActiveRecord::Migration[6.0]
  def change
    20.times.each do
      News.create(title: "小鹏汽车宣布启动22亿元B轮融资，阿里巴巴、富士康、IDG资本", source: "IT桔子")
    end
  end
end
