## 欢迎光临NTFS
你可以访问[NTFS](https://fkv587.github.io/MACNTFS/) 获取详细信息

# 实现方案 
控制台操作  
第一步：控制台输入 diskutil list
获取到磁盘信息
![Image text](https://github.com/FKV587/MACNTFS/blob/master/files/3847f7b46b1f352db552338443213a48.png)  
第一种方案  
第二步：diskutil unmount /dev/IDENTIFIER  
第三步：sudo vi /etc/fstab  
第四步：LABEL=NAME none ntfs rw,auto,nobrowse  
第五步：diskutil mount /dev/IDENTIFIER  
第二种方案
第二步：diskutil unmount /dev/IDENTIFIER  
第三步：sudo vi /etc/fstab  
第四步：UUID=%@ none ntfs rw,auto,nobrowse  
第五步：diskutil mount /dev/IDENTIFIER  

然后就应该开启读写了

IDENTIFIER是磁盘对应磁盘名称  
NAME对应磁盘名称   
NAME中的空格用\040代替  
NAME如果为空请输入Untitled

基于MAC系统自带的NTFS实现的 使用退出磁盘请手动退出后在拔出磁盘  
![Image text](https://github.com/FKV587/MACNTFS/blob/master/files/f7b7571f6eca95f8aa140bad6bbdfde6.png)

## 获取安装 
获取：单击以安装  
适用于MAC的NTFS解决方案免费提供。你现在可以在这里找到它[NTFS](https://fkv587.github.io/MACNTFS)。

### 你的打赏是我前进的动力！
### 谢谢打赏，我会再接再厉！
![Image text](https://github.com/FKV587/MACNTFS/blob/master/files/36afdd175de8cf5031879d91b6f036e8.png)  
支付宝 谢谢大佬
