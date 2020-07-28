Zombie.host = Settings.zombie.host
Zombie.app_name = Settings.zombie.app_name


ZombieService.service_host = Settings.zombie.local_host         # 服务端本机地址和端口
ZombieService.service_name = Settings.zombie.app_name           # 服务端本机地址和端口
ZombieService.service_root_path = "/micro"                      # 服务端接口根路径
ZombieService.router_conf_path = "http://router.canary.huaxing.com:9777/set_model_path"  # 测试路由服务器动态配置路径
ZombieService.service_prefix = Settings.zombie_prefix if Settings.zombie_prefix
appid = '26ced78887798b35dd4031cc02d05e19'
secret = 'a5186354e6da9750ba0a393852225b33'
ZombieService.appid = appid
ZombieService.secret = secret
Zombie.appid = appid
Zombie.secret = secret

# ZombieService.service_host = "http://127.0.0.1:3003"           # 服务端本机地址和端口
# ZombieService.service_name = "arrow_for_fa"                     # 服务端本机地址和端口
# ZombieService.service_root_path = "/micro"                      # 服务端接口根路径
# ZombieService.router_conf_path = "http://127.0.0.1:8770/set_model_path"  # 测试路由服务器动态配置路径
# ZombieService.service_prefix = Settings.zombie_prefix if Settings.zombie_prefix