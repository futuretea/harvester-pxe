# harvester-pxe
使用软路由做pxe服务器，全自动安装Harvester集群

## 准备
```bash
# clone本项目
git clone https://github.com/futuretea/harvester-pxe.git
cd harvester-pxe

# 根据版本下载iso的资源
# 可以下载不同的版本，在后续的步骤中可以选择使用的版本
./1-download-artifacts.sh v1.0.2

```
```bash
$ tree ./artifacts/v1.0.2

artifacts/v1.0.2
├── harvester-amd64.iso
├── harvester-initrd-amd64
├── harvester-rootfs-amd64.squashfs
└── harvester-vmlinuz-amd64

0 directories, 4 files

```

## 将本目录暴露为http服务
比如使用nginx，主机ip为192.168.5.79, 当前目录为/mnt/harvester-pxe
```nginx
  server {
        listen       80;
        server_name  192.168.5.79;
        location / {
        	autoindex on;
        	autoindex_exact_size off;
        	autoindex_localtime on;
        	root /mnt/harvester-pxe;
        }
    }
```

## 生成菜单配置文件
假设指向本目录的http访问路径为http://192.168.5.79, 第一个节点的mac地址为00:50:56:0b:46:a2, 安装的版本为v1.0.2
```bash
./2-create-menu-ipxe.sh http://192.168.5.79 00:50:56:0b:46:a2 v1.0.2
```
这个菜单在安装的时候效果如下
![image](https://user-images.githubusercontent.com/15064560/114909046-4c9e9b80-9e4f-11eb-9d59-e256bc114aa9.png)
如果匹配到第一个节点的mac地址，则会自动选择create模式，否则自动选为join模式。默认有5秒的时间可以进行手动切换

## 编译undionly.kpxe并上传到软路由, 如果编译出错则根据提示安装依赖
假设软路由的ssh配置为root@192.168.5.1,tftp服务根目录为/root,http服务根目录为/www
![image](https://user-images.githubusercontent.com/15064560/114910456-83c17c80-9e50-11eb-97a5-74ed9bd35849.png)

```bash
./3-build-upload-kpxe.sh root 192.168.5.1 /root /www
```
编译出的undionly.kpxe会被上传到tftp服务根目录下

生成的menu.ipxe会被上传到http服务根目录下


## 修改configs目录下配置文件
可以将第一个节点设为静态ip,也可以通过绑定mac地址进行ip绑定
```bash
$ tree ./configs
configs
├── create.yaml
└── join.yaml

0 directories, 2 files
```

## 启动机器进行自动安装
注意第一个节点的mac地址要与生成的menu.ipxe配置中的匹配

引导顺序：dhcp -> 编译的undionly.kpxe -> 生成的menu.ipxe -> 下载的initrd,kernel,iso与配置的config

