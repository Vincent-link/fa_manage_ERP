Zombie.host = Settings.zombie.host
Zombie.app_name = Settings.zombie.app_name


# ZombieService.service_host = "http://127.0.0.1:3000"           # 服务端本机地址和端口
# ZombieService.service_name = "arrow_for_fa"                    # 服务端本机地址和端口
# ZombieService.service_root_path = "/micro"                     # 服务端接口根路径
# ZombieService.router_conf_path = "http://10.101.98.4:8770/set_model_path"  # 测试路由服务器动态配置路径
# ZombieService.service_prefix = Settings.zombie_prefix if Settings.zombie_prefix


ZombieService.service_host = "http://127.0.0.1:3003"           # 服务端本机地址和端口
ZombieService.service_name = "arrow_for_fa"                     # 服务端本机地址和端口
ZombieService.service_root_path = "/micro"                      # 服务端接口根路径
ZombieService.router_conf_path = "http://127.0.0.1:8770/set_model_path"  # 测试路由服务器动态配置路径
ZombieService.service_prefix = Settings.zombie_prefix if Settings.zombie_prefix