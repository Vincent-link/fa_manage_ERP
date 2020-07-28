module V1
  class UserApi < Grape::API
    format :json

    include ZombieService
    source_model :User
    model_attrs :_all_attrs

    model_class_methods_in_get  :can_operate_eva_batch
  end
end