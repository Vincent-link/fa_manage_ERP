class CreateNews < ActiveRecord::Migration[6.0]
  def change
    create_table :news do |t|
      t.string :title
      t.string :string
      t.string :url
      t.string :source

      t.timestamps
    end

    News.create(title: "IDG资本宣布正式聘请著名科幻作家刘慈欣担任“首席畅想官", source: "IT桔子")
    News.create(title: "小鹏汽车宣布启动22亿元B轮融资，阿里巴巴、富士康、IDG资本", source: "IT桔子")
    News.create(title: "IDG资本宣布正式聘请著名科幻作家刘慈欣担任“首席畅想官", source: "IT桔子")
    News.create(title: "小鹏汽车宣布启动22亿元B轮融资，阿里巴巴、富士康、IDG资本小鹏汽车宣布启动22亿元B轮融资，阿里巴巴、富士康、IDG资本", source: "IT桔子")
  end
end
