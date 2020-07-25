namespace :syn_company do
  desc "This task does nothing"
  task :everyday do
    every 1.day, at: '00:00 am' do
      Zombie::DmCompany.pluck(:id).each {|e| Company.syn(e)}
    end
  end

  desc "This task does nothing"
  task :initial do
    Zombie::DmCompany.pluck(:id).each {|e| Company.syn(e)}
  end
end
