# 操作系统lab2
> [Jack-Lio'github](https://github.com/Jack-Lio)关于ucore实验lab1的相关记录     
> 2019年11月6日最新修改

-   [小小吐槽](#小小吐槽)
-   [练习0 merge lab1](#练习1)
-   [实验内容概括](#实验内容概括)
-   [练习1 FF内存分配算法](#练习1)
-   [练习2 get_pte函数实现](#练习2)
-   [练习3 释放页帧&取消二级页表项](#练习3)
-   [拓展练习](#拓展练习)

##  小小的吐槽一下
- 吐槽一下代码合并，当代码量变大，系统复杂之后，代码的合并就很麻烦了，没学好`diff&patch`哭晕在电脑前，这次就先用meld对付过去了，之后还是要好好学一下`diff&patch`的使用的，可视化工具用起来还是有点麻烦。

## 练习0
在实验一的基础上，合并lab1中添加的编程代码。不过合并难受了，虽然都merge了，但是总是会有一些冲突导致的bug，因为不太熟悉diff&patch的使用，这次的merge代码，使用的是meld可视化合并工具。


## 实验内容概括
lab2中实现了对ucore系统的段页式地址转换机制的理解和完善，需要自己尝试在理解系统的基础上完成对物理内存管理的代码编写。

ucore启动之后对于内存和地址映射的处理主要分为三大块内容和四个阶段，在lab1中学习了系统的启动过程和段式地址映射机制，以及中断处理的过程，在此基础上lab2，引入了内存管理机制。

在BIOS系统启动之后，完成了对于系统的自检和初始化工作之后，加载主引导扇区后将CPＵ控制权限交给bootloader之后，bootloader会完成lab1中体现的从实模式到保护模式的跳转，以及 ELF文件的加载，在此之前bootloader在进入bootmain函数之前会检查硬件的物理内存，将探测结果存储在e820map中，用于之后的pmm构建工作，然后会进入kernel_entry()函数入口，而不是直接调用kernel_init()，这样做的效果是实现了虚地址，线性地址，物理地址映射关系的转变，建立了一个临时的段映射关系，完成这些工作之后才正式调用kernel_init函数将系统控制权限交给操作系统。

在kernel_init中，完成了前面的系统字符信息输出和堆栈信息检查和中断检查之后，添加了对于物理内存管理系统的初始化工作（pmm_init）。

在pmm.c文件中，实现了页式物理内存管理的机制构建，在default_pmm.[ch]中提供了简单的基于first fit页表管理策略的实现，内存管理的主要宏定义在mmu.h文件中完成，pmm.h文件中定义了pmm_manager数据结构，提供了物理内存管理的基本框架。

## 练习1
练习1需要在已有代码的基础上完成一个简单的first fit物理内存分配算法的实现。本来以为需要完成所有的几个函数的编程，结果到源代码中一看，发现都写好了，就想着直接跑一下，还是不行，后来仔细看了代码发现是源代码不是完整的first fit实现，内存块的保存没有顺序，所以需要修改一下这部分的源代码。需要修改的代码位于default_pmm.c文件中，修改之后的代码和相关的解释说明如下：
```c++
free_area_t free_area;    //申明空闲内存管理的数据结构，包含空闲内存块的数量，和一个空闲内存列表


//定义宏
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

//初始化空闲物理内存区
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
/*默认的内存初始化函数
n 指明物理内存的块数量*/
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);     //断言，如果判断为false，直接中断程序的执行，返回初步报告
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));        //判断该页保留位是否为1，如果为内核保留页则清空该标志位
        p->flags = p->property = 0;     //标志为清0，空闲块数量置0
        set_page_ref(p, 0);                   //设置引用量为0，表明可以进行重新分配
    }
    //设置属性参数，指出这个内存空闲块的存储块数量，以第一个页的property参数标明
    base->property = n;
    //设置页表的属性标志位为1，标志该物理页帧可以被分配
    SetPageProperty(base);
    //空闲内存区块数加n
    nr_free += n;
    //应该使用list_add_before,否则使用list_add默认为add_after,
    //原来的函数使用lsit_add，这样新增加的页总是在后面，不适合FFMA算法，应该要按照地址排序
    list_add_before(&free_list, &(base->page_link));    //cc
}

//分配物理页算法
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {      //要求的超过空闲空间大小，返回NULL
        return NULL;
    }
    // 声明一个page变量
    struct Page *page = NULL;
    list_entry_t *le = &free_list;          //查找符合条件的page
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {               //找到符合条件的块，赋值给page变量带出
            page = p;
            break;
        }
    }
    if (page != NULL) {           //找到了符合条件的页，进行设置
        if (page->property > n) {
            struct Page *p = page + n;        //将多余的页空间，重新放入空闲页表目录
            p->property = page->property - n;
            //应该要对剩余的部分空闲页设置属性位，在init中属性位全为0，这里需要设为1,表明空闲块
            SetPageProperty(p);                 //原函数没有属性位置位操作++
            list_add_after(&(page->page_link), &(p->page_link));  //cc注意一定要添加在后面,按地址排序
    }
      list_del(&(page->page_link));     // 先要处理完剩余空间再删除该页，从空闲页表目录页删除该页
      nr_free -= n;       //总空闲块数减去分配页块数
      ClearPageProperty(page);//将属性位置0，标记该页已被分配
    }
    return page;
}

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过保留页，和空闲页
        assert(!PageReserved(p) && !PageProperty(p));     //否则为用户态的占用区
        p->flags = 0;         //标志位清零，释放
        set_page_ref(p, 0);
    }
    base->property = n;//可用空闲块为n
    SetPageProperty(base);  //可分配置位
    list_entry_t *le = list_next(&free_list);    //获取头页地址
    while (le != &free_list) {            //合并空页
        p = le2page(le, page_link);
        le = list_next(le);
         //如果该页为当前释放页的紧邻后页，则直接释放后面一页的属性位，将之和当前页合并
        if (base + base->property == p) {    
            base->property += p->property;
            ClearPageProperty(p);     //清楚属性位
            list_del(&(p->page_link));    //在空闲页表中删除该页
        }
        else if (p + p->property == base) {   //如果找到紧邻前一页是空页，则把前页合并到当前页
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    //加n个可用块
    nr_free += n;
    //从头到尾进行一次遍历，找到合适的插入位置,把合并和的页插入到找到的位置前面
    le  = list_next(&free_list);
    while(le!=&free_list){
      p = le2page(le,page_link);
      if(base+base->property<=p){
        break;
      }
      le = list_next(le);
    }
    list_add_before(le, &(base->page_link));    //cc应该使用add_before把整合的页插入找到的位置
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
```
**改进:**在alloc_page过程中，如果当前要求的内存大小小于分配页的内存大小的时候，分配该页之后剩下的内存空间可以考虑和后面可能空闲的区块进行合并，找到剩余页内存空间后面是否紧跟着空闲区块，如果存在，则直接和后面的空闲区块合并，节省之后可能存在的合并操作，提高效率。或者在查询页表项的时候可以采用查询优化算法优化查询表项的过程。
## 练习2
问题1：描述页目录项(Pag Director Entry)和页表(Page Table Entry)中每个组成部分的含
义和以及对ucore而言的潜在用处。
  - pte和pde都是32位长，分别包含页帧位（高20位 ，用来索引页表或页目录的内存位置）和多个标志位，由于两者很多的标志位功能都差不多，因此在Ucore中并没有做区分，两者的标志位设置都是公用的，以下是pte和pde的标志位：

```C++
/* page table/directory entry flags */
#define PTE_P           0x001                   // Present  存在位，判断该页是否分配了物理内存
#define PTE_W           0x002                   // Writeable 可写位，标志该页是够可以修改
#define PTE_U           0x004                   // User  用户可访问权限设置位
#define PTE_PWT         0x008          // Write-Through  写直达，CPU数据可以直写回内存
#define PTE_PCD         0x010                   
/* Cache-Disable  高速缓存禁止位（辅存地址位）：对于那些映射到设备寄存器而不是常规内存的页面有
用，假设操作系统正在循环等待某个I/O设备对其指令进行响应，保证硬件不断的从设备中读取数据而不是
访问一个旧的高速缓存中的副本是非常重要的。即用于页面调入。*/

#define PTE_A           0x020      // Accessed   已访问位，判断改页是否近期被访问过，有利于回收机制实现
#define PTE_D           0x040      // Dirty 脏位，判断是否被修改，可以不必写回未修改页
#define PTE_PS          0x080                   // Page Size  表示一个页的大小为4MB
#define PTE_MBZ         0x180                   // Bits must be zero  
#define PTE_AVAIL       0xE00                   
// Available for software use  用户进程自定义位，使用户程序具有一定的操作空间
                                                // The PTE_AVAIL bits aren't used by the kernel or interpreted by the
                                                // hardware, so user processes are allowed to set them arbitrarily.

#define PTE_USER        (PTE_U | PTE_W | PTE_P)   //用户页表的默认设置
```
问题2：如果ucore执行过程中访问内存,出现了页访问异常,请问硬件要做哪些事情?
- 首先会保存当前的CPU现场状态，然后会调用14号中断（处理page fault的中断）处理访存异常，返回后会恢复调用中断前的cpu状态，然后会重新执行该访存指令。

在trap.h中定义了处理page fault的中断序号如下：
```c++
#define T_PGFLT                 14  // page fault
```
页式内存管理机制的具体示意图如下：
![页式内存管理机制](./figures/页表机制.png)
练习2中需要对get_pte函数进行完善，实现获取页表项的功能，根据注释内容完成编程，具体实现代码如下：
```c++
/get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /* LAB2 EXERCISE 2: YOUR CODE
     *
     * If you need to visit a physical address, please use KADDR()
     * please read pmm.h for useful macros
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry   
    //通过参数中的pgdir加上页表目录偏移量获取页表目录项地址
    if (!(*pdep&PTE_P)) {              // (2) check if entry is not present判断是否存在物理映射
    struct Page*page;
    if(!create)  return NULL;                // (3) check if creating is needed, then alloc page for page table
                                                            //不存在物理映射且不需要分配，直接返回NULL
    page = alloc_page();  //否则，调用alloc函数分配一个空闲的物理页帧
    if(page==NULL)   return NULL; //没有找到能够分配的页
                                                          // CAUTION: this page is used for page table, not for common data page
    set_page_ref(page,1);     // (4) set page reference  设置新分配的页访问位为1
    uintptr_t pa =page2pa(page); // (5) get linear address of page  获得线性地址（也就是物理地址）
    memset(KADDR(pa),0,PGSIZE);             // (6) clear page content using memset  清除页表项内容
    // (7) set page directory entry's permission  设置和物理地址，可写，用户可访问，可用位
    *pdep =pa|PTE_W|PTE_P|PTE_U;                      
    }
     // (8) return page table entry  
     //la 需要映射的线性地址（物理地址）
     //*pdep  二级页表的线性地址
     // PDE_ADDR  截取地址的前20位,获取页目录表的地址
     // PTX(la)获取线性地址在二级页表中的偏移量
     //KADDR 将页目录表地址转为内核虚拟地址
     //将页目录项内容中存储的页表虚拟地址加上页表项偏移获取目的页表项，返回其地址
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];         
#endif
}
```
## 练习3
问题1：数据结构Page的全局变量(其实是一个数组)的每一项与页表中的页目录项和页表项有
无对应关系?如果有,其对应关系是啥?
- 有对应关系，pages的每一项对应一个物理页，而页目录项和页表项本身都是一个物理页，其本身也是pages中的一项，对应关系映射关系其实就是PNN对应的关系，通过PNN（） 得到页目录和页表地址的高20位索引所对应的page。

问题2：如果希望虚拟地址与物理地址相等,则需要如何修改lab2,完成此事? 鼓励通过编程来
具体完成这个问题
- 在实验手册中说明了虚拟地址和物理地址之间转换关系是在链接过程中出现偏移量的，将kernel.ld中的链接地址修改一下：

```c++
SECTIONS {
    /* Load the kernel at this address: "." means the current address */
    . = 0xC0100000;        //这里将虚拟地址和物理地址设置了0xc0000000的偏移
    //此时pysical addr + 0xc0000000 = virtual addr  所以需要将这个改为0x00100000

    .text : {
        *(.text .stub .text.* .gnu.linkonce.t.*)
    }
................
}
```
- 然后在memlayout.h中定义了kernelbase作为偏移量，我们通过kADDR获得的将物理地址转为虚拟地址都是通过对物理地址+0xc0000000实现的，所以同样需要将kernelbase修改为0x0。但是这样还是不能够正常执行，在网上参考已有的资料之后，发现需要修改entry.S 中的unmap va 0~4M代码，把它注释掉，make qemu之后正常执行，结果如下：     

```c++
jack-lio@jack-lio:~/文档/ucore_os_implementation/labcodes/lab2$ make qemu
WARNING: Image format was not specified for 'bin/ucore.img' and probing guessed raw.
Automatically detecting the format is dangerous for raw images, write operations
on block 0 will be restricted.
Specify the 'raw' format explicitly to remove the restrictions.
VNC server running on 127.0.0.1:5900
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0x0010002f (phys)   //这里的地址不再加上0xc0000000
  etext  0x00105fbe (phys)
  edata  0x0011b000 (phys)
  end    0x0011bf28 (phys)
Kernel executable memory footprint: 112KB
-> ebp:0x00117f38   eip:0x00100aa2   args: 0x00010094 0x00010094 0x00117f68 0x001000c6
    kern/debug/kdebug.c:310: print_stackframe+21
-> ebp:0x00117f48   eip:0x00100d9f   args: 0x00000000 0x00000000 0x00000000 0x00117fb8
    kern/debug/kmonitor.c:129: mon_backtrace+10
-> ebp:0x00117f68   eip:0x001000c6   args: 0x00000000 0x00117f90 0xffff0000 0x00117f94
    kern/init/init.c:51: grade_backtrace2+33
-> ebp:0x00117f88   eip:0x001000f0   args: 0x00000000 0xffff0000 0x00117fb4 0x0000002a
    kern/init/init.c:56: grade_backtrace1+38
-> ebp:0x00117fa8   eip:0x0010010f   args: 0x00000000 0x0010002f 0xffff0000 0x0000001d
    kern/init/init.c:61: grade_backtrace0+23
-> ebp:0x00117fc8   eip:0x00100135   args: 0x00105fdc 0x00105fc0 0x00000f28 0x00000000
    kern/init/init.c:66: grade_backtrace+34
-> ebp:0x00117ff8   eip:0x00100084   args: 0x001061c4 0x001061cc 0x00100d27 0x001061eb
    kern/init/init.c:31: kern_init+84
memory management: default_pmm_manager
e820map:
  memory: 0009fc00, [00000000, 0009fbff], type = 1.
  memory: 00000400, [0009fc00, 0009ffff], type = 2.
  memory: 00010000, [000f0000, 000fffff], type = 2.
  memory: 07ee0000, [00100000, 07fdffff], type = 1.
  memory: 00020000, [07fe0000, 07ffffff], type = 2.
  memory: 00040000, [fffc0000, ffffffff], type = 2.
check_alloc_page() succeeded!
kernel panic at kern/mm/pmm.c:478:
    assertion failed: get_page(boot_pgdir, 0x0, NULL) == NULL
stack trackback:
-> ebp:0x00117f18   eip:0x00100aa2   args: 0x00106088 0x00117f5c 0x000001de 0x0000001e
    kern/debug/kdebug.c:310: print_stackframe+21
-> ebp:0x00117f48   eip:0x0010045a   args: 0x001067d0 0x000001de 0x001067bb 0x00106878
    kern/debug/panic.c:27: __panic+103
-> ebp:0x00117f88   eip:0x0010373d   args: 0x00000000 0xffff0000 0x00117fb4 0x0000002a
    kern/mm/pmm.c:478: check_pgdir+181
-> ebp:0x00117fc8   eip:0x001032f3   args: 0x00105fdc 0x00105fc0 0x00000f28 0x00000000
    kern/mm/pmm.c:301: pmm_init+41
-> ebp:0x00117ff8   eip:0x00100089   args: 0x001061c4 0x001061cc 0x00100d27 0x001061eb
    kern/init/init.c:33: kern_init+89
Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K> qemu-system-i386: terminating on signal 2

```
- 虽然能够通过分配页的检查函数，但是通不过check_pgdir() succeeded!和check_boot_pgdir()
succeeded，make  grade之后也没有得分，可能是因为检查函数的默认物理地址和虚拟地址的非一致性。


练习3中需要完成对于页表项的释放工作，需要根据函数参数中的虚地址释放对应的页，根据注释完成代码如下所示：
```c++
//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /* LAB2 EXERCISE 3: YOUR CODE
     *
     * Please check if ptep is valid, and tlb must be manually updated if mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   struct Page *page pte2page(*ptep): get the according page from the value of a ptep
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 , then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
//检查中断位，看页表项是够分配了对应的物理内存，二级页表项存在与否
    if (*ptep&PTE_P) {                      //(1) check if this page table entry is present ？  
      //找到相应的页
        struct Page *page =pte2page(*ptep); //(2) find corresponding page to pte
        //引用减1，减到0则释放
        if(page_ref_dec(page)==0){                          //(3) decrease page reference
            free_page(page);  //(4) and free this page when page reference reachs 0
        }
        //清空二级页表项
        *ptep = 0;                          //(5) clear second page table entry
        //刷新tlb
        tlb_invalidate(pgdir,la);                          //(6) flush tlb
    }
#endif
}
```
## 拓展练习
暂时没有做拓展练习的相关工作。
