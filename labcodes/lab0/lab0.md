# lab0 ucore 实验准备工作
>  [jack-lio的github主页](https://github.com/Jack-Lio)  关于ucore系统实现准备工作记录        
> *2019年９月28日最新修改*

## 1. 实验环境搭建(挖坑和填坑之路)
操作系统的实验基本基于Linux系统的环境,而且觉得真机安装的Ubuntu双系统操作起来应该会流畅一些,主要是自己实在忍受不了虚拟机卡顿的操作(可能是自己的机器有点老了的原因吧),于是在有的同学装机失败的教训下毅然决定装双系统。。。。此后走上了一条挖坑填坑的不归路。下面记录一下自己装机遇到的一些坑和填坑的过程吧。。。
### 1.1 系统盘制作（UBUNTU 18.04）
双系统安装需要用U盘制作启动盘，这里我使用的是16G的U盘，一般还是**要求在８G以上的盘**比较好，制作系统盘的过程还是比较友好和顺利的。这一步大多数的博客的流程还是比较可信的，一下贴上几个在这一步可以参考的链接。

[U盘启动盘制作](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-windows?_ga=2.23429182.504028352.1569656346-51080868.1569656346#0)：***官网的推荐教程，使用的是Rufus,基本参考官网的制作流程最好。***

[系统镜像下载-官网](http://www.ubuntu.com/download/desktop)

[制作启动盘参考博客](http://www.ubuntu.com/download/desktop)

### 1.2　磁盘分区
在自己的磁盘分出一块空闲区域，***这里我给ubuntu分了１５０个Ｇ的磁盘空间，主要是考虑到要长久使用。
磁盘分区很简单***，网上也由很多的[参考资料](https://jingyan.baidu.com/article/425e69e6bbd0c7be14fc164a.html)。

### 1.3 Ｕ盘启动
这一步也基本没有什么坑，很顺利就能够进入Ｕ盘启动的安装引导页面，这里我用的是Dell的电脑，基本在开机按F12就可以直接进入BIOS设置页面选择U盘启动。

![BIOS启动页面](.\figures\bios-setup.jpg)

之后可以选择进入try ubuntu 系统还是直接安装，安装后会出现安装引导。

![安装引导](.\figures\setup.jpg)

在这里有个选择安装的方式，网上很多的博客都是说选择“其他选项”安装，好像直接选择共存安装会因为一些默认设置导致和原系统冲突安装失败，所以我也没有尝试，直接选择了其他选项，其他选项最重要的工作就是引导分区和系统分区大小以及挂载点的设置，这里也是我掉的第一个坑。

![分区](.\figures\area.jpg)

![设置分区](.\figures\set1.jpg)
对于分区大小到底怎么设置，网上的说法各种各样，第一次安装参考的博客推荐的分区基本正确，***但是在boot分区上只设置了200MB，装完系统后基本就满了，只有四个内核就装不下了，启动问题也比较多***。参考多方资料几次折腾之后，确定的分区为

```
/boot         1G              系统内核存储区，挂载点/boot   
efi                500MB     引导分区    选择用efi工作区
/                   15G           根目录，系统文件目录 挂载点/  
/home       约64G        挂载点/home  用户目录
/usr              约60G       挂载点/usr  用户程序默认下载目录      
swap         8G          一般和物理内存一样   选择用作swap

其他的选择用于ext4日志文件系统，分区类型都选择逻辑分区
```

分区设置完成之后直接点击安装即可，这里会进行基本的语言、地区、用户密码的设置等等，不出意外安装就成功了，因为在安装过程中还是比较顺利的就不多说了。

### 1.4 Ubuntu系统引导损坏
正常安装完成之后进行重启应该会弹出这样的引导页面，但是因为引导损坏，导致重启之后会直接进入Windows的开机界面而不会出现Ubuntu系统引导。解决方案如下：
- 进入Ubuntu系统启动U盘
- 进入try  Ubuntu
- 使用Clt+Alt+T打开terminal
- 运行以下两条命令

```
# 添加boot-repair所在源并更新
sudo add-apt-repository ppa:yannubuntu/boot-repair && sudo apt-get update
#安装boot-repair并进行启动
sudo apt-get install -y boot-repair && boot-repair
```
- 启动后boot-repair扫描机器状况后会显示修复引导选项

![修复](.\figures\repair.jpg)
-  点击箭头所指向选项即可，修复成功之后会提示重启

> 上述操作之后，有可能不会出现引导界面，可能需要进入 ***BIOS setup 修改引导的优先级***，将Ubuntu引导设置在最前面；也有可能 ***出现的系统引导页面有许多奇怪的引导选项***，可以选择进入Ubuntu系统进行grub修改，消除这些多余的引导。具体做法可参考[ubuntu引导修复](https://blog.csdn.net/piaocoder/article/details/50589667)


### 1.5 ubuntu 18.04 系统不支持NVIDIA独立显卡
ubuntu系统作为开源的操作系统，对于许多的闭源生态的软件兼容性比较差，Ubuntu18.04只预装了Intel的集成显卡驱动，没有安装NVIDIA的显卡驱动，导致电脑一直卡在Ubuntu的开启启动logo处，然后自动关机。可行的暂时解决方案是 ***在系统引导页面，按e键进入grub设置页面，在Linux开头的一行末尾添加‘nomodeset_’,然后按Ctrl+X或F10进入Ubuntu系统。***

虽然在这之前的安装遇到了一些问题，但是这个显卡冲突的问题解决了很久才成功，虽然不至于影响很大，但是每次开机都需要进行手动设置，太麻烦了。

可以手动添加NVIDIA的驱动程序，但是在安装过程中多次失败，查找了很多的资料和相关的博客和问题记录后才成功安装了NVIDIA驱动程序，到这里Ubuntu系统总算安装成功。

[驱动修复相关参考博客1](https://blog.csdn.net/u014561933/article/details/79958017)

[驱动修复相关参考博客2](https://blog.csdn.net/qq_37935670/article/details/80377196)

### 1.6 总结（牢骚）
>   安装双系统确实很麻烦，但是Ubuntu系统用起来确实也很爽，***相比与使用虚拟机进行操作，真机运行起来更加的流畅，相关的软件安装也比较顺利***，后面的安装qemu的时候没有遇到太大的坑，也算是装双系统的优点吧。       而且装系统的过程中我对于系统的基本启动流程也有了简单的认识，了解了一些分区引导和文件挂载相关的知识，也算有了一些收获。

>    同时在这次安装Ubuntu系统的过程中，我也深切感受到了 ***网上铺天盖地的的博客和个人经验分享的质量有多美参差不齐，有效的信息很少，    大多数的博客内容都比较片面，不太实用***，有些甚至是错误的，这也给我自己一个教训——以后要好好得辨别这些博客的质量，不能再随便掉坑了。


## 2 实验常用工具和环境配置
在ucore实验中，一些基本的常用工具如下(来自[chyyuugit项目文档](https://github.com/chyyuu/ucore_os_docs/edit/master/lab0/lab0_ref_ucore-tools.md))：
>  - 命令行shell: bash shell -- 有对文件和目录操作的各种命令，如ls、cd、rm、pwd...
  - 系统维护工具：apt、git
    - apt：安装管理各种软件，主要在debian, ubuntu linux系统中
    - git：开发软件的版本维护工具
  - 源码阅读与编辑工具：eclipse-CDT、understand、gedit、vim
    - Eclipse-CDT：基于Eclipse的C/C++集成开发环境、跨平台、丰富的分析理解代码的功能，可与qemu结合，联机源码级Debug uCore OS。
    - Understand：商业软件、跨平台、丰富的分析理解代码的功能，Windows上有类似的sourceinsight软件
    - gedit：Linux中的常用文本编辑，Windows上有类似的notepad
    - vim: Linux/unix中的传统编辑器，类似有emacs等，可通过exuberant-ctags、cscope等实现代码定位
  - 源码比较和打补丁工具：diff、meld，用于比较不同目录或不同文件的区别, patch是打补丁工具
    - diff, patch是命令行工具，使用简单
    - meld是图形界面的工具，功能相对直观和方便，类似的工具还有 kdiff3、diffmerge、P4merge
  - 开发编译调试工具：gcc 、gdb 、make
    - gcc：C语言编译器
    - gdb：执行程序调试器
    - ld：链接器
    - objdump：对ELF格式执行程序文件进行反编译、转换执行格式等操作的工具
    - nm：查看执行文件中的变量、函数的地址
    - readelf：分析ELF格式的执行程序文件
    - make：软件工程管理工具， make命令执行时，需要一个 makefile 文件，以告诉make命令如何去编译和链接程序
    - dd：读写数据到文件和设备中的工具
  - 硬件模拟器：qemu -- qemu可模拟多种CPU硬件环境，本实验中，用于模拟一台 intel x86-32的计算机系统。类似的工具还有BOCHS, SkyEye等
  - markdown文本格式的编写和阅读工具(比如阅读ucore_docs)
    - 编写工具 haroopad
    - 阅读工具 gitbook

### 2.1 工具学习笔记
> 主要参考实验文档中提供的相关实验工具技术文档进行基础的学习，在这里记录一些简单的笔记

- Linux命令
  - cat是一次性显示整个文件的内容，还可以将多个文件连接起来显示，它常与重定向符号配合使用，适用于文件内容少的情况；
  - more和less一般用于显示文件内容超过一屏的内容，并且提供翻页的功能。more比cat强大，提供分页显示的功能，less比more更强大，提供翻页，跳转，查找等命令。而且more和less都支持：用空格显示下一页，按键b显示上一页。下面详细介绍这3个命令。

    参考：https://blog.csdn.net/xyw_blog/article/details/16861681

    ```
cat常用参数列表
  -A, --show-all            等于-vET
  -b, --number-nonblank 对非空输出行编号
  -e                        等于-vE
  -E, --show-ends           在每行结束处显示"$"
  -n, --number          对输出的所有行编号
  -s, --squeeze-blank       不输出多行空行
  -t                        与-vT 等价
  -T, --show-tabs           将跳格字符显示为^I
  -u                        (被忽略)
  -v, --show-nonprinting    使用^ 和M- 引用，除了LFD和 TAB 之外
      --help                显示此帮助信息并退出
      --version             显示版本信息并退出
```
```
more：
1、命令格式
 more [-dlfpcsu] [-num] [+/pattern] [+linenum] [file ...]
2、命令功能
more命令和cat的功能一样都是查看文件里的内容，但有所不同的是more可以按页来查看文件的内容，还支持直接跳转行等功能。
3、常用参数列表
     -num  一次显示的行数
     -d    在每屏的底部显示友好的提示信息
     -l    忽略 Ctrl+l （换页符）。如果没有给出这个选项，则more命令在显示了一个包含有 Ctrl+l 字符的行后将暂停显示，并等待接收命令。
     -f     计算行数时，以实际上的行数，而非自动换行过后的行数（有些单行字数太长的会被扩展为两行或两行以上）
     -p     显示下一屏之前先清屏。
     -c    从顶部清屏然后显示。
     -s    文件中连续的空白行压缩成一个空白行显示。
     -u    不显示下划线
     +/    先搜索字符串，然后从字符串之后显示
4、more操作命令：
     +num  从第num行开始显示   
     Enter    向下n行，需要定义。默认为1行
      Ctrl+F   向下滚动一屏
      空格键   向下滚动一屏
      Ctrl+B   返回上一屏
      =        输出当前行的行号
      ：f      输出文件名和当前行的行号
      v        调用vi编辑器
      !命令    调用Shell，并执行命令 
      q        退出more
```
```
less：
1．命令格式：
less [参数]  文件
2．命令功能：
less 与 more 类似，但使用 less 可以随意浏览文件，而 more 仅能向前移动，却不能向后移动，而且 less 在查看之前不会加载整个文件。
3．命令参数：
-b <缓冲区大小> 设置缓冲区的大小
-e  当文件显示结束后，自动离开
-f  强迫打开特殊文件，例如外围设备代号、目录和二进制文件
-g  只标志最后搜索的关键词
-i  忽略搜索时的大小写
-m  显示类似more命令的百分比
-N  显示每行的行号
-o <文件名> 将less 输出的内容在指定文件中保存起来
-Q  不使用警告音
-s  显示连续空行为一行
-S  行过长时间将超出部分舍弃
-x <数字> 将“tab”键显示为规定的数字空格
/字符串：向下搜索“字符串”的功能
?字符串：向上搜索“字符串”的功能
n：重复前一个搜索（与 / 或 ? 有关）
N：反向重复前一个搜索（与 / 或 ? 有关）
b  向后翻一页
d  向后翻半页
h  显示帮助界面
Q  退出less 命令
u  向前滚动半页
y  向前滚动一行
空格键 滚动一页
回车键 滚动一行
```


- apt
软件安装：
  -  apt-get update  更新sources.list或者preferences之后运行这个命令使改动生效
  - apt-get upgrade 更新所有的软件包
  - apt-get -f install 修正依赖关系损毁的软件包，出现unmet dependencies 时使用
  - apt-get  autoclean & clean 分别用来清除已安装文件的.deb文件和所有无用的软件安装包

  软件删除：
  - apt-get remove packagename 删除已安装的软件包（保留配置文件）
  - apt-get --purge remove packagename 删除已安装软件包（不保留配置文件）
  - apt-get  autoremove 删除依赖相关而安装的多余软件包

  软件搜索：
  - apt-cache search 搜索软件包
  - apt-cache show显示软件包信息
  - dpkg -L 显示软件包安装了哪些文件以及文件路径


- diff & patch
  - diff 用来比较两个文件或者目录中的每一个文件的不同
> *语法格式为：* **diff  【选项】源文件{夹} 目标文件{夹}**            

    三种常用选项：
> -r 是一个递归选项，设置了这个选项，diff会将两个不同版本源代码目录中的所有对应文件全部都进行一次比较，包括子目录文件。
    -N 选项确保补丁文件将正确地处理已经创建或删除文件的情况。
    -u 选项以统一格式创建补丁文件，这种格式比缺省格式更紧凑些。

  - patch就是利用diff制作的补丁来实现源文件（夹）和目的文件（夹）的转换。这样说就意味着你可以有源文件（夹）――>目的文件（夹），也可以目的文件（夹）――>源文件（夹）。

    >  -p0 选项要从当前目录查找目的文件（夹）
-p1 选项要忽略掉第一层目录，从当前目录开始查找。
-E 选项说明如果发现了空文件，那么就删除它
-R 选项说明在补丁文件中的“新”文件和“旧”文件现在要调换过来了（实际上就是给新版本打补丁，让它变成老版本）

    ```
  单个文件：
diff –uN from-file to-file >to-file.patch
patch –p0 < to-file.patch
patch –RE –p0 < to-file.patch
多个文件：
diff –uNr from-docu to-docu >to-docu.patch
patch –p1 < to-docu.patch
patch –R –p1 <to-docu.patch
  ```
- gcc & gdb
  gcc 作为一个强大的编译器，配合gdb在Linux的命令行操作页面中非常好用，一下记录一下常用的命令选项功能[参考blog](https://blog.csdn.net/goodman_lqifei/article/details/55539100)

    ```
  1、无选项编译链接
  例：命令：gcc test.c //会默认生成a.out可执行程序
  2、-E: 进行预处理和编译，生成汇编文件。
  命令：gcc -E test.c //会生成test.i文件
  3、-S: 进行预处理，编译，汇编等步骤，生成”.s”文件
  例：命令：gcc -S test.c //会生成test.s文件
  4、-c: 会直接生成二进制目标文件
  例：命令：gcc -c test.c //会生成test.o文件
  5、-o :对生成的目标进行重命名
  例：命令：gcc -o test test.c //会生成名字是test可执行文件而不是默认的a.out
  6、-pipe: 使用管道代替编译中的临时文件
  例：命令：gcc -pipe -o test test.c
  7、-include file :包含某个代码。相当于在文件中加入#include
  例：gcc test.c -include /root/file.h
  8、-Idir：当你使用#include”file”的时候，会先到你定制的目录里面查找
  9、-I-：取消前一个参数的功能。一般在-Idir之后使用
  10、-C：在预处理的时候不删除注释信息，一般和-E使用。
  11、-M：生成文件关联信息。包含目标文件所依赖的所有源代码。
  12、-MM：和-M一样，只不过忽略由#include所造成的依赖关系。
  13、-MD:和-M相同，只不过将输出导入到”.d”文件里面
  14、-MMD:和-MM相同，将输出导入到”.d”文件里面。
  15、-llibrary:定制编译的时候使用的库
  例：gcc -lpthread test.c //在编译的时候要依赖pthread这个库
  16、-Ldir:定制编译的时候搜索库的路径。如果是自己定制的库，可以用它来定制搜索目录，否则编译器只在标准库目录里面找，dir就是目录的名字
  17、-O0(字母o和数字0):没有优化
  -O1：-O1位缺省值
  -O2：二级优化
  -O3：最高级优化
  级别越大优化越好，但编译时间边长。
  18、-g:在编译的时候假如debug调试信息，用于gdb调试
  19、-share：此选项尽量的使用动态库，所以生成文件比较小，但是必须是系统有动态库。
  20、-shared:生成共享目标文件，通常用在建立共享库。
  21、-static:链接时使用静态链接，但是要保证系统中有静态库。
  22、-w：不生成任何警告信息
  22、-Wall：生成所有警告信息
  ```

    gdb是用来调试程序的工具，具有很好的操作性，在使用gdb进行调试之前需要先通过gcc -g 参数进行编译，同时gdb还可以通过-s 、 -d 、 -c等命令选项对gdb的启动进行设置。

    gdb中命令不需要打全，只用打命令的钱几个字符进行辨别就可，同时敲击两次TAB键能够补齐命令的全称，如果有重复的会列出来，同样对于命令的函数和函数参数表也可以进行同样的操作

    gdb通过shell 命令可以运行shell中的相关命令

    通过make命令可以执行make文件，等价于shell  make <Makefile>命令

  >  - 常用的gdb命令有以下：
     - 1、运行程序
     ```
    set args 指定参数
    show args  查看设置好的参数
    path  <dir>  设定运行路径
    show path 查看运行路径
    set  environment varname  【=value】 设置环境变量
    show  environment varname 查看环境变量
    cd dir
    pwd    显示工作目录
    info terminal 显示程序用到的终端的模式
    tty 可以制定写输入输出的终端设备  tty  /dev/ttyb
    ```
  -  2、调试程序
      - 断点
```
    break  function 进入制定函数时停住
    break linenum   指定断点行号
    break +offset/-offset  在当前行号的前面或者后面offse行打断点
    break filename：linenum  在源文件的某一行打断点
    break filename：function  同上
    break  *address  在程序运行的内存地址处打断点
    break if condition  条件满足停住
    info break 【n】查看断点信息
    ```
      - 观察点用来观察表达式，一旦有变化马上停住程序
  ```
    watch  expression   表达式值变化停住程序
    rwatch  expr expr被读的时候停住
    awatch expr 表达式被读或写的时候停住
    info watchpoints  列出所有观察点
  ```
      - 捕捉点用来捕捉程序运行的事件
```
    catch event  
    当event发生时，停住程序。event可以是下面的内容：
throw 一个C++抛出的异常。（throw为关键字）
catch 一个C++捕捉到的异常。（catch为关键字）
exec 调用系统调用exec时。（exec为关键字，目前此功能只在HP-UX下有用）
fork 调用系统调用fork时。（fork为关键字，目前此功能只在HP-UX下有用）
vfork 调用系统调用vfork时。（vfork为关键字，目前此功能只在HP-UX下有用）
load 或 load <libname> 载入共享库（动态链接库）时。（load为关键字，目前此功能只在HP-UX下有用）
unload 或 unload <libname> 卸载共享库（动态链接库）时。（unload为关键字，目前此功能只在HP-UX下有用）
tcatch <event>
只设置一次捕捉点，当程序停住以後，该点被自动删除
  ```
      - 停止点（上述三种）可以通过 delete 、enable、diable、clear命令来维护
      - 还可以为停止点设置运行命令，使用commonds【】end包括命令即可
      - 恢复程序运行采用continue命令，单步调试采用next、step、stepi、nexti等命令，其中stepi(si),nexti(ni)功能为单步跟踪一条机器指令，类似的命令还有`display/i $pc`
      - 信号是一种软中断，是一种处理异步事件的方法
          ```
命令格式：handle <signal> <keywords...>
          nostop
    当被调试的程序收到信号时，GDB不会停住程序的运行，但会打出消息告诉你收到这种信号。
    stop
    当被调试的程序收到信号时，GDB会停住你的程序。
    print
    当被调试的程序收到信号时，GDB会显示出一条信息。
    noprint
    当被调试的程序收到信号时，GDB不会告诉你收到信号的信息。
    pass
    noignore
    当被调试的程序收到信号时，GDB不处理信号。这表示，GDB会把这个信号交给被调试程序处理。
    nopass
    ignore
    当被调试的程序收到信号时，GDB不会让被调试程序来处理这个信号。
    info signals
    info handle
    查看有哪些信号在被GDB检测中。
      ```
    - 3、源代码相关
      - 使用list命令显示源代码
      - `forward-search- 、search -` 向前搜索源代码      `reverse-search` 全部搜索
      -  `info line` 查看源代码在内存中的地址，info line后面可以跟“行号”，“函数名”，“文件名:行号”，“文件名:函数名”，这个命令会打印出所指定的源码在运行时的内存地址
      ```
      (gdb) info line tst.c:func
Line 5 of "tst.c" starts at address 0x8048456 <func+6> and ends at 0x804845d <func+13>.
      ```
      - `disassemble`可以查看当前执行的机器码的汇编指令
      - 调试程序时，当程序被停住时，你可以使用print命令（简写命令为p），或是同义命令inspect来查看当前程序的运行数据。print命令的格式是：
      ```
      print <expr>
      print /<f> <expr>
      <expr>是表达式，是你所调试的程序的语言的表达式（GDB可以调试多种编程语言），<f>是输出的格式，比如，如果要把表达式按16进制的格式输出，那么就是/x。
      ```
      - 变量输出格式
      ```
      x  按十六进制格式显示变量。
d  按十进制格式显示变量。
u  按十六进制格式显示无符号整型。
o  按八进制格式显示变量。
t  按二进制格式显示变量。
a  按十六进制格式显示变量。
c  按字符格式显示变量。
f  按浮点数格式显示变量。
(gdb) p i
$21 = 101   
(gdb) p/a i
$22 = 0x65
(gdb) p/c i
$23 = 101 'e'
(gdb) p/f i
$24 = 1.41531145e-43
(gdb) p/x i
$25 = 0x65
(gdb) p/t i
$26 = 1100101
      ```
-  shell 编程
  - 变量赋值和引用。shell中变量赋值和引用与c中基本一致，不过shell中变量的使用时必须在变量名之前加上$符号
  - shell中的流程控制
>   1. if-then-else语句的特别在于结束使用fi作为关键字标示
```
-f "filename"
判断是否是一个文件
-x "/bin/ls"
判断/bin/ls是否存在并有可执行权限
-n "$var"
判断 $var 变量是否有值
"$a" == "$b"
判断$a和$b是否相等
&&和||操作符
[ -f "/etc/shadow" ] && echo "This computer uses shadow passwords"这里的
判断是否是一个文件
-x "/bin/ls"
判断/bin/ls是否存在并有可执行权限
-n "$var"
判断 $var 变量是否有值
"$a" == "$b"
判断$a和$b是否相等
```
>   2. &&和||操作符
```
[ -f "/etc/shadow" ] && echo "This computer uses shadow  passwords"
```
这里的 && 就是一个快捷操作符，如果左边的表达式为真（返回 0——“成功”）则执行右边的语句，你也可以把它看作逻辑运算里的与操作。上述脚本表示如果/etc/shadow文件存在，则打印“This computer uses shadow passwords”。
      ```
#!/bin/bash
mailfolder=/var/spool/mail/james
[ -r "$mailfolder" ] || { echo "Can not read $mailfolder"; exit 1; }
echo "$mailfolder has mail from:"
grep "^From " $mailfolder
      ```
该脚本首先判断mailfolder是否可读，如果可读则打印该文件中以"From"开头的行。如果不可读则或操作生效，打印错误信息后脚本退出。需要注意的是，这里我们必须使用如下两个命令：
    -   ***花括号将两个命令组合起来当做一个命令使用***    
  >   3.  case 语句    
        ```
  case ... in
   ...) do something here
   ;;
   esac
   ```
 >   4.  select语句
  `select var in ... ;do ...; done`
 >   5.  while/for循环
  `while ... ;do ...;done`
  `for var in ...;do ... ; done`
