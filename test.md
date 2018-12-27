**1.各个平台环境科学上网的搭建**

**Linux 构建科学上网环境 (命令行版)**

1.安装PIP

sudo apt-get install python-pip

2.安装shadowsocks

sudo pip install shadowsocks

3.启动SS客户端

sslocal -s 23.106.150.37  -p  444 -k "*******"  

PS:

开机启动

sudo gedit /etc/rc.local

nohup sslocal -s 23.106.150.37 -p 444 -k "*********" &

**Linux 构建科学上网环境 (图形界面版)**

安装 [https://github.com/shadowsocks/shadowsocks-qt5/releases](https://github.com/shadowsocks/shadowsocks-qt5/releases)

里面的参数怎么填写参考下面Windows构建

**安卓用户**

Android users: install from Google Play: [Shadowsocks-Android](https://play.google.com/store/apps/details?id=com.github.shadowsocks)

**iOS 用户**

install from App Store: 

ssrconnect

[Shadowsocks-iOS](https://itunes.apple.com/us/app/shadowsocks/id665729974?ls=1&mt=8) [Help: [Link](https://github.com/shadowsocks/shadowsocks-iOS/wiki/Help)]

**Windows构建**

For Windows 7 or earlier, download [shadowsocks-win-2.3.zip](https://kiwivm.64clouds.com/dist/shadowsocks-win-2.3.zip)

For Windows 8 or later, download [shadowsocks-win-dotnet4.0-2.3.zip](https://kiwivm.64clouds.com/dist/shadowsocks-win-dotnet4.0-2.3.zip)

[ip：](https://kiwivm.64clouds.com/dist/shadowsocks-win-dotnet4.0-2.3.zip)23.106.150.37

密码是*******

端口444

（请找所有者询问密码）

![clipboard.png](https://upload-images.jianshu.io/upload_images/685455-c19edc0ef3c30103.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



**2\. 配置chrome/chromium浏览器**

这里拿chrome来示范，因为火狐那个代理插件老是订阅不了gfwlist所以配置自动模式的话不好使。Chromium也可以的。

安装代理插件SwitchyOmega(链接: [http://pan.baidu.com/s/1nvr2erZ](http://pan.baidu.com/s/1nvr2erZ))

然后浏览器地址打开chrome://extensions/，将下载的插件拖进去。

新建情景模式比如命名为SS，其他默认之后创建

之后在代理协议选择SOCKS5，地址为127.0.0.1,端口默认1080 

然后保存即应用选项。

接着点击自动切换（auto switch）

上面的不用管，

规则列表设置选择AutoProxy 

然后将这个地址填进去

[https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt](https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt)

点击下面的立即更新情景模式，会有提示更新成功！

Finally,按照规则列表匹配请求后面选择刚才新建的SS，默认情景模式选择直接连接。点击应用选项保存。

然后点那个圆圈，可选自动切换或者SS

打开google.com试试！

mint linux开机后台自动运行

鼠标点菜单-->首选项目-->开机自启动程序-->添加-->自定义命令-->  名称随意，命令输入 sslocal -s 23.106.150.37  -p  443 -k "******"  

然后

ubuntu

nohup sslocal -s 23.106.150.37 -p 444 -k "*****" >/dev/null 2>log &

nohup ssserver -c /etc/shadowsocks.json >/dev/null 2>log &
