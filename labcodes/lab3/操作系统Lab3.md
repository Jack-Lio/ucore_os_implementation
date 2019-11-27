# 操作系统lab3
> [Jack-Lio'github](https://github.com/Jack-Lio)关于ucore实验lab3的相关记录     
> 2019年11月12日最新修改

-   [小小吐槽](#小小吐槽)
-   [实验内容概括](#实验内容概括)
-   [练习0 merge lab2](#练习0)
-   [练习1 给未被映射的地址映射上物理页](#练习1)
-   [练习2 补充完成基于FIFO的页面替换算法](#练习2)
-   [拓展练习 实现识别dirty bit的 extended clock页替换算法](#challenge)

## 小小吐槽一下

## 实验内容概括
本次实验是在实验二的基础上,借助于页表机制和实验一中涉及的中断异常处理机制,完成Page Fault异常处理和FIFO页替换算法的实现,结合磁盘提供的缓存空间,从而能够支持虚存管理,提供一个比实际物理内存空间“更大”的虚拟内存空间给系统使用，并实现不同程序内存空间的隔离。这个实验与实际操作系统中的实现比较起来要简单,不过需要了解实验一和实验二的具体实现。实际操作系统系统中的虚拟内存管理设计与实现是相当复杂的,涉及到与进程管理系统、文件系统等的交叉访问。
## 练习0
通过meld  diff工具合并lab2中的代码之后make qemu 执行之后发现lab1 和lab2中的实现均正确执行，合并代码没有问题。同时可以看到，在lab3中新增的vmm.c文件中do_pgfault()函数存在问题，以及pmm.c文件中boot_alloc_page(void)函数还有trap.c中的trap_dispatch()函数也存在问题需要修改或完善。从这里不难知道lab3的核心内容在这三个文件的完善工作上。

## 练习1
do_pgfault 函数实现了对于内存访问异常的处理，主要实现的功能就是在CPU无法访问某一个物理内存单元的时候，通过调用异常中断服务例程，然后通过中断响应这个时机调用do_pgfault 进行处理，处理的方式就是判断异常的类型，按照类型进行按需调页或者换入换出，抑或直接进行报错处理。产生也访问异常的原因主要有三种：
- 目标页帧不存在(页表项全为0,即该线性地址与物理地址尚未建立映射或者已经撤销);
- 相应的物理页帧不在内存中(页表项非空,但Present标志位=0,比如在swap分区或磁盘
文件上),这在本次实验中会出现,我们将在下面介绍换页机制实现时进一步讲解如何处
理;
-  不满足访问权限(此时页表项P标志=1,但低权限的程序试图访问高权限的地址空间,或
者有程序试图写只读页面).

按照上述的情况分析以及do_pgfault函数的注释修改函数代码如下所示：
```c++
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;       //error.h中宏，表示无效参数，
    //用来在输出错误提示的时候，作为错误提示的角标输出想一个的错误内容
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);   //查找，看是否存在已经映射的虚地址块

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {            //不存在，或者访问地址超出虚拟内存范围，访存失败
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    //check the error_code    检查errorcode 看是什么错误原因(写权限和存在位检查)
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }

    uint32_t perm = PTE_U;      //页表项用户态字段
    if (vma->vm_flags & VM_WRITE) {       //如果虚拟内存空间是可写的
        perm |= PTE_W;          //perm判断位或上页表项可写位
    }
    addr = ROUNDDOWN(addr, PGSIZE);           //向下对齐地址获得包含该虚拟地址的块起始位置

    ret = -E_NO_MEM;            // Request failed due to memory shortage，内存不足的报错宏定义

    pte_t *ptep=NULL;

#if 1
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = get_pte(mm->pgdir,addr,1);          //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    if(ptep==NULL)    //无法获得或分配页表项，报错
    {
      cprintf("do_pgfault failed: get_pte  failed\n");
      goto failed;
    }
    if (*ptep == 0) {
                            //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
                            //物理地址不存在，分配一个物理页帧并映射逻辑地址
              if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)//分配页帧失败
              {
                cprintf("do_pgfault failed: pgdir_alloc_page  failed\n");
                goto failed;
              }
    }
    else {      //存在一个需要交换的页
        执行与练习二相关的换入换出操作
    }
 #endif
    ret = 0;
 failed:
     return ret;
 }
```
从代码逻辑可以看出，对访问异常的处理主要是先判断访问的虚拟地址是否在虚拟内存访问内，或者对应的虚拟内存块是否存在，然后对errorcode进行判断，由于errorcode携带了访问异常的原因，通过对errorcode的标志位的判断可以得到不同的报错信息，从实验指导可以知道，errorcode第0\1\2三位分别为访问页不存在，写权限异常，访问权限异常，当出现写权限异常时，但虚拟内存不能够写的时候报错，同时出现物理页不存在的时候报错，当不存在写异常同时物理页也存在的时候如果虚拟内存不允许读或者执行的时候说明访问权限不够，需要报错。如果需要访问一个物理页且权限和位置均正，但映射关系不存在时候，需要执行后面的相关操作，则创建一个页表并建立虚实映射关系。之后，调用iret中断，回到页访问异常的指令位置，并重新执行页访问指令。
- ***回答问题***
- 请描述页目录项(Pag Director Entry)和页表(Page Table Entry)中组成部分对ucore实现页替换算法的潜在用处。

>  页目录项和页表项维护了虚存与硬盘扇区之间的映射关系，在虚拟内存管理中，PTE描述一般意义的物理页的时候，维护了从虚拟地址到物理地址的映射关系，在描述一个被换出的物理页的时候，会充分利用前24位来表示该页在硬盘上的起始扇区偏移位置，基于此，ucore最多能够使用1<<24个page，否则在映射硬盘扇区时将超出范围。而页目录项用来维护不同用户空间的虚拟内存实现不同用户空间的内存隔离和访问权限控制。综上所属，页目录项用来实现虚拟内存的隔离和权限控制，页表项用来实现页面换入换出的记录工作。

- 如果ucore的缺页服务例程在执行过程中访问内存,出现了页访问异常,请问硬件要做哪些事情?

> CPU在当前的内核栈中保存当前被打断的程序现场，一次压入当前被打断程序的EFLAGS ,CS ,EIP，ERRORCODE，由于也访问异常的中断号为0xE,CPU把异常终端号对应的中断服务历程的地址加载到CS和EIP中，开始执行中断服务例程，这时UCORE开始处理异常中断，之后就是软件要做的事情了。


## 练习2

```c++
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;       //error.h中宏，表示无效参数，
    //用来在输出错误提示的时候，作为错误提示的角标输出想一个的错误内容
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);   //查找，看是否存在已经映射的虚地址块

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {            //不存在，或者访问地址超出虚拟内存范围，访存失败
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    //check the error_code    检查errorcode 看是什么错误原因(写权限和存在位检查)
    switch (error_code & 3) {
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }

    uint32_t perm = PTE_U;      //页表项用户态字段
    if (vma->vm_flags & VM_WRITE) {       //如果虚拟内存空间是可写的
        perm |= PTE_W;          //perm判断位或上页表项可写位
    }
    addr = ROUNDDOWN(addr, PGSIZE);           //向下对齐地址获得包含该虚拟地址的块起始位置

    ret = -E_NO_MEM;            // Request failed due to memory shortage，内存不足的报错宏定义

    pte_t *ptep=NULL;

#if 1
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = get_pte(mm->pgdir,addr,1);          //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    if(ptep==NULL)    //无法获得或分配页表项，报错
    {
      cprintf("do_pgfault failed: get_pte  failed\n");
      goto failed;
    }
    if (*ptep == 0) {
                            //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
                            //物理地址不存在，分配一个物理页帧并映射逻辑地址
              if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)//分配页帧失败
              {
                cprintf("do_pgfault failed: pgdir_alloc_page  failed\n");
                goto failed;
              }
    }
    else {      //存在一个需要交换的页
        if(swap_init_ok) {        //swap文件初始化完成
            struct Page *page=NULL;
            if((ret=swap_in(mm,addr,&page))!=0)   //(1）According to the mm AND addr, try to load the content of right disk page
            //换入目的页
            {                                                                           //    into the memory which page managed.
              cprintf("do_pgfault failed: swap_in  failed\n");
              goto failed;
            }
            //将换入的页插入页表中
            page_insert(mm->pgdir,page,addr,perm);        //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            //将该页变为可交换的，将pra_page_link加入sm_priv中
            swap_map_swappable(mm,addr,page,1);            //(3) make the page swappable.
            page->pra_vaddr = addr;                                             //使用pra_vaddr记录该物理页的虚拟地址起始地址，用于后面的swap_out()
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
   ret = 0;
failed:
    return ret;
}
```
- ***回答问题：***
- 如果要在ucore上实现"extended clock页替换算法"请给你的设计方案,现有的swap_manager框架是否足以支持在ucore中实现此算法?如果是,请给你的设计方案。如果不是,请给出你的新的扩展和基此扩展的设计方案。

>  

- 需要被换出的页的特征是什么?

> 只有被映射到用户空间且能够被用户程序直接访问的页面才能够被换出，extended clock算法需要跳过没有修改过的页，同事将修改过的页写回硬盘，如果经常这么做写硬盘的代价比较大。所以优先换出被没有被访问过的页，其次是访问过但没有修改的，最后是修改过了的页。

- 在ucore中如何判断具有这样特征的页?

> 通过页表项的属性位实现对页特征的判断，从而确定哪些页能够被换出。标记为在PTE的flags上，PTE_A 表示访问位，PTE_D 表示脏位，看是否被修改过。

-  何时进行换入和换出操作?

> 当ucore或者应用程序访问地址所在的页不在内存的时候，会产生page fault异常，引起调用do_pdfault 函数，此函数会判断范文一场的地址是否属于合法虚拟地址空间且保存在swap文件中，如果是则可以执行页换入算法。

>  换出的时候分为消极和积极两种策略，一种是通过时钟中断周期性的将空闲的页换出到硬盘上，实现积极的页换出算法，另一种是在分配空闲页的时候没有可用的物理页，则通过查找换出不常用的页实现分配，目前ucore使用这种策略。

## challenge
