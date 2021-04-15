# harvester-pxe
使用软路由做pxe服务器全自动安装Harvester集群

## 准备
```bash
# clone本项目
git clone https://github.com/futuretea/harvester-pxe.git
cd harvester-pxe

# 根据版本下载iso的资源
./download-artifacts.sh v0.2.0-rc2

$ tree ./artifacts
./artifacts
└── v0.2.0-rc2
    ├── harvester-amd64.iso
    ├── harvester-initrd-amd64
    └── harvester-vmlinuz-amd64

1 directory, 3 files
```

## 将本目录暴露为http服务
比如使用nginx，主机ip为192.168.1.79, 当前目录为/mnt/harvester-pxe
```nginx
  server {
        listen       80;
        server_name  192.168.1.79;
        location / {
        	autoindex on;
        	autoindex_exact_size off;
        	autoindex_localtime on;
        	root /mnt/harvester-pxe;
        }
    }
```

## 生成配置文件
假设指向本目录的http访问路径为http://192.168.1.79, 第一个节点的mac地址为00:50:56:0b:46:a2, 安装的版本为v0.2.0-rc2
```bash
./create-menu-ipxe.sh http://192.168.1.79 00:50:56:0b:46:a2 v0.2.0-rc2
```

## 编译undionly.kpxe并上传到软路由, 如果编译出错则根据提示安装依赖
假设软路由的ssh配置为root@192.168.1.1,tftp服务根目录为/root,http服务根目录为/www
```bash
./build-upload-kpxe.sh root@192.168.1.1 /root /www
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
![image](https://user-images.githubusercontent.com/15064560/114909046-4c9e9b80-9e4f-11eb-9d59-e256bc114aa9.png)

