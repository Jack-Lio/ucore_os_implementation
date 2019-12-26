# 操作系统lab5
> [Jack-Lio'github](https://github.com/Jack-Lio)关于ucore实验lab5的相关记录     
> 2019年12月24日最新修改

-   [小小吐槽](#小小吐槽)
-   [实验内容概括](#实验内容概括)
-   [练习0 merge lab4](#练习0)
-   [练习1 加载应用程序并执行(需要编码)](#练习1)
-   [练习2 父进程复制自己的内存空间给子进程(需要编码)](#练习2)
-   [练习3 阅读分析源代码，理解进程执行fork、exec、wait、exit的实现以及系统的调用(无编码工作)](#练习3)
-   [拓展练习 实现Copy On Write机制](#Challenge)

## 小小吐槽一下
这次的实验的make grade的时候又报错了，明明能够正常运行返回结果，打印的文本也很正常但是在执行一些user文件中的程序的时候总是报错。后面检查了很久，比对lab5_result中的代码后发现是应为中断响应处理程序中多了一行代码。
```
ticks ++;
if (ticks % TICK_NUM == 0) {
    assert(current != NULL);
    current->need_resched = 1;
    print_ticks();      //这行打印会造成两个函数在make grade的时候无法通过
}
```
我猜测应该是因为在grade检查结果的时候通过字符串匹配，而时钟中断的打印会造成检查结果出错，所以一直没有通过，这个问题困扰了我很久，也浪费了很久的时间。

## 实验内容概括
执行结果如下：
```
VNC server running on 127.0.0.1:5900
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc0100036 (phys)
  etext  0xc010b435 (phys)
  edata  0xc019e000 (phys)
  end    0xc01a1160 (phys)
Kernel executable memory footprint: 645KB
-> ebp:0xc0129f48   eip:0xc0100b6b   args: 0x00010094 0x00010094 0xc0129f78 0xc01000cc
    kern/debug/kdebug.c:351: print_stackframe+21
-> ebp:0xc0129f58   eip:0xc0100e7e   args: 0x00000000 0x00000000 0x00000000 0xc0129fc8
    kern/debug/kmonitor.c:129: mon_backtrace+10
-> ebp:0xc0129f78   eip:0xc01000cc   args: 0x00000000 0xc0129fa0 0xffff0000 0xc0129fa4
    kern/init/init.c:58: grade_backtrace2+19
-> ebp:0xc0129f98   eip:0xc01000ee   args: 0x00000000 0xffff0000 0xc0129fc4 0x0000002a
    kern/init/init.c:63: grade_backtrace1+27
-> ebp:0xc0129fb8   eip:0xc010010b   args: 0x00000000 0xc0100036 0xffff0000 0xc0100079
    kern/init/init.c:68: grade_backtrace0+19
-> ebp:0xc0129fd8   eip:0xc010012c   args: 0x00000000 0x00000000 0x00000000 0xc010b440
    kern/init/init.c:73: grade_backtrace+26
-> ebp:0xc0129ff8   eip:0xc0100086   args: 0xc010b644 0xc010b64c 0xc0100e07 0xc010b66b
    kern/init/init.c:33: kern_init+79
memory management: default_pmm_manager
e820map:
  memory: 0009fc00, [00000000, 0009fbff], type = 1.
  memory: 00000400, [0009fc00, 0009ffff], type = 2.
  memory: 00010000, [000f0000, 000fffff], type = 2.
  memory: 07ee0000, [00100000, 07fdffff], type = 1.
  memory: 00020000, [07fe0000, 07ffffff], type = 2.
  memory: 00040000, [fffc0000, ffffffff], type = 2.
check_alloc_page() succeeded!
check_pgdir() succeeded!
check_boot_pgdir() succeeded!
-------------------- BEGIN --------------------
PDE(0e0) c0000000-f8000000 38000000 urw
  |-- PTE(38000) c0000000-f8000000 38000000 -rw
PDE(001) fac00000-fb000000 00400000 -rw
  |-- PTE(000e0) faf00000-fafe0000 000e0000 urw
  |-- PTE(00001) fafeb000-fafec000 00001000 -rw
--------------------- END ---------------------
use SLOB allocator
check_slab() succeeded!
kmalloc_init() succeeded!
check_vma_struct() succeeded!
page fault at 0x00000100: K/W [no page found].
check_pgfault() succeeded!
check_vmm() succeeded.
ide 0:      10000(sectors), 'QEMU HARDDISK'.
ide 1:     262144(sectors), 'QEMU HARDDISK'.
SWAP: manager = fifo swap manager
BEGIN check_swap: count 1, total 31804
setup Page Table for vaddr 0X1000, so alloc a page
setup Page Table vaddr 0~4MB OVER!
set up init env for check_swap begin!
page fault at 0x00001000: K/W [no page found].
page fault at 0x00002000: K/W [no page found].
page fault at 0x00003000: K/W [no page found].
page fault at 0x00004000: K/W [no page found].
set up init env for check_swap over!
write Virt Page c in fifo_check_swap
write Virt Page a in fifo_check_swap
write Virt Page d in fifo_check_swap
write Virt Page b in fifo_check_swap
write Virt Page e in fifo_check_swap
page fault at 0x00005000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
write Virt Page b in fifo_check_swap
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
write Virt Page b in fifo_check_swap
page fault at 0x00002000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x3000 to disk swap entry 4
swap_in: load disk swap entry 3 with swap_page in vadr 0x2000
write Virt Page c in fifo_check_swap
page fault at 0x00003000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 4 with swap_page in vadr 0x3000
write Virt Page d in fifo_check_swap
page fault at 0x00004000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
write Virt Page e in fifo_check_swap
page fault at 0x00005000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/R [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
count is 0, total is 5
check_swap() succeeded!
++ setup timer interrupts
kernel_execve: pid = 2, name = "exit".
I am the parent. Forking the child...
I am parent, fork a child pid 3
I am the parent, waiting now..
I am the child.
waitpid 3 ok.
exit pass.
all user-mode processes have quit.
init check memory pass.
kernel panic at kern/process/proc.c:476:
    initproc exit.

stack trackback:
-> ebp:0xc03a3f98   eip:0xc0100b6b   args: 0x00000018 0xc03a10e8 0x00000001 0xc03a3fcc
    kern/debug/kdebug.c:351: print_stackframe+21
-> ebp:0xc03a3fb8   eip:0xc0100467   args: 0xc010d500 0x000001dc 0xc010d550 0x00000000
    kern/debug/panic.c:27: __panic+107
-> ebp:0xc03a3fe8   eip:0xc01096e9   args: 0x00000000 0x00000000 0x00000000 0x00000010
    kern/process/proc.c:476: do_exit+81
Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K>

```

make grade 的结果如下所示：

```
badsegment:              (3.8s)
  -check result:                             OK
  -check output:                             OK
divzero:                 (1.3s)
  -check result:                             OK
  -check output:                             OK
softint:                 (1.3s)
  -check result:                             OK
  -check output:                             OK
faultread:               (1.3s)
  -check result:                             OK
  -check output:                             OK
faultreadkernel:         (1.3s)
  -check result:                             OK
  -check output:                             OK
hello:                   (1.2s)
  -check result:                             OK
  -check output:                             OK
testbss:                 (1.3s)
  -check result:                             OK
  -check output:                             OK
pgdir:                   (1.3s)
  -check result:                             OK
  -check output:                             OK
yield:                   (1.2s)
  -check result:                             OK
  -check output:                             OK
badarg:                  (1.2s)
  -check result:                             OK
  -check output:                             OK
exit:                    (1.3s)
  -check result:                             OK
  -check output:                             OK
spin:                    (4.2s)
  -check result:                             OK
  -check output:                             OK
waitkill:                (13.2s)
  -check result:                             OK
  -check output:                             OK
forktest:                (1.3s)
  -check result:                             OK
  -check output:                             OK
forktree:                (1.3s)
  -check result:                             OK
  -check output:                             OK
Total Score: 150/150
```
## 练习0
利用meld diff进行的代码合并，因为make grade报错怀疑是合并的问题，做了很多次合并操作QAQ。
通过合并过程中发现这次的实验需要修改之前几次lab中完成的代码，主要包括中断处理中添加对于系统调用的中断描述符，在每100个时钟中断时候修改进程调度标示，使进程进入可调度状态，在proc_alloc中添加对与新增的进程控制属性的初始化代码，在do_fork函数中添加对于进程wait_state的检查以及使用新的set_links函数来将进程控制块添加到proc_list中。
## 练习1
- 设计实现过程：
按照题目的说明，阅读实验代码和注释之后可以知道，主要的代码已经完成，只需要添加对于trapframe中断帧的设置能够实现do_execve函数中的相应功能，而完成对于trapframe的设置代码主要在load_icode函数中。阅读该函数代码和查阅文档，可以发现其中所做的工作主要包括以下几个：

- 调用mm_create函数来申请进程的内存管理数据结构mm所需内存空间,并对mm进行初始化;
- 调用setup_pgdir来申请一个页目录表所需的一个页大小的内存空间,并把描述ucore内核虚空间映射的内核页表(boot_pgdir所指)的内容拷贝到此新目录表中,最后让mm->pgdir指向此页目录表,这就是进程新的页目录表了,且能够正确映射内核虚空间;
- 根据应用程序执行码的起始位置来解析此ELF格式的执行程序,并调用mm_map函数根据ELF格式的执行程序说明的各个段(代码段、数据段、BSS段等)的起始位置和大小建立对应的vma结构,并把vma插入到mm结构中,从而表明了用户进程的合法用户态虚地址空间;
- 调用根据执行程序各个段的大小分配物理内存空间,并根据执行程序各个段的起始位置确定虚拟地址,并在页表中建立好物理地址和虚拟地址的映射关系,然后把执行程序各个段的内容拷贝到相应的内核虚拟地址中,至此应用程序执行码和数据已经根据编译时设定地址放置到虚拟内存中了;


- 需要给用户进程设置用户栈,为此调用mm_mmap函数建立用户栈的vma结构,明确用户栈的位置在用户虚空间的顶端,大小为256个页,即1MB,并分配一定数量的物理内存且建立好栈的虚地址<-->物理地址映射关系;

- 至此,进程内的内存管理vma和mm数据结构已经建立完成,于是把mm->pgdir赋值到cr3寄存器中,即更新了用户进程的虚拟内存空间,此时的initproc已经被hello的代码和数据覆盖,成为了第一个用户进程,但此时这个用户进程的执行现场还没建立好;

- 先清空进程的中断帧,再重新设置进程的中断帧,使得在执行中断返回指令“iret”后,能够让CPU转到用户态特权级,并回到用户态内存空间,使用用户态的代码段、数据段和堆栈,且能够跳转到用户进程的第一条指令执行,并确保在用户态能够响应中断;

通过注释可以看到，练习1中需要我们补充的主要是对于trapframe的主要寄存器的设置，而这些在代码注释中都已经说明，照着写就行，代码如下所示：

```
//(6) setup trapframe for user environment
//用户进程虚拟内存管理和物理内存管理工作完毕，需要设置用户进程执行现场
struct trapframe *tf = current->tf;
//覆盖当前的执行现场信息块tf
memset(tf, 0, sizeof(struct trapframe));
/* LAB5:EXERCISE1 YOUR CODE
 * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
 * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
 *          tf_cs should be USER_CS segment (see memlayout.h)
 *          tf_ds=tf_es=tf_ss should be USER_DS segment
 *          tf_esp should be the top addr of user stack (USTACKTOP)
 *          tf_eip should be the entry point of this binary program (elf->e_entry)
 *          tf_eflags should be set to enable computer to produce Interrupt
 */
 tf->tf_cs = USER_CS;
 tf->tf_ds = tf->tf_es=tf->tf_ss = USER_DS;
 tf->tf_esp = USTACKTOP;
 tf->tf_eip = elf->e_entry;
 tf->tf_eflags = FL_IF;                     //使能中断位，表明线程在执行过程中，能够响应中断，打断当前的执行
ret = 0;
out:
return ret;
bad_cleanup_mmap:
exit_mmap(mm);
bad_elf_cleanup_pgdir:
put_pgdir(mm);
bad_pgdir_cleanup_mm:
mm_destroy(mm);
bad_mm:
goto out;
}
```
其中值得注意的是宏FL_IF，为中断使能位，可以表示进程在运行过程中能够被中断打断执行。

- 问题：请在实验报告中描述当创建一个用户态进程并加载了应用程序后,CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行(RUNNING态)到具体执行应用程序第一条指令的整个经过。

在proc_init函数创建了内核的第一个线程idleproc之后，又通过kernelthread函数创建了内核的第二个线程iinti_main，然后init_mian线程又创建了第三个内核线程user_main负责创建用户进程，而user_main线程通过接受两个参数调用系统调用，同时将链接是创键的两个参数（表明用户程序user里面的相关代码起止位置),执行系统调用，然后经过系统调用的处理执行do_execve函数，最终通过do_execve函数实现执行用户进程的功能,在do_execve函数中会通过覆盖当前执行进程的内存空间，构建新进程的运行环境，拷贝内核内存并建立映射，建立新进程的物理内存管理信息和虚拟内存管理信息，之后通过设置新进程的中断帧，构建新进程中断现场执行环境，最后通过中断返回，恢复新进程的执行环境，开始运行新的进程。


## 练习2
父进程复制子即的内存空间给子进程，通过查看文档和代码以及注释之后可以知道，主要修改pmm.c中的copy_range 函数即可，该函数将父进程的内存空间的复制给子进程。

通过阅读fork函数的代码能够了解父进程创建子进程的整个过程。首先父进程调用系统调用，系统调用会调用处理函数do_fork ，do_fork会构建父子关系，创建子进程的相关数据结构并进行初始化，将父进程的内存空间拷贝给子进程。父进程调用了copy_mm ,copy_mm调用了dup_mmap,dup_mmap调用了copy_range函数，而练习二中需要完善copy_range函数。

copy_range 函数如下所示：
```
/* copy_range - copy content of memory (start, end) of one process A to another process B
 * @to:    the addr of process B's Page Directory
 * @from:  the addr of process A's Page Directory
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);      //检验起止地址为归一化的地址
    assert(USER_ACCESS(start, end));                                        //检验是否为用户空间地址
    // copy content by page unit.
    //以页为单位拷贝内存数据
    do {
        //call get_pte to find process A's pte according to the addr start
        //获取页表项，如果页表项获取失败
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        //获取目的进程的其实地址并分配一个页给他
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        /* LAB5:EXERCISE2 YOUR CODE
         * replicate content of page to npage, build the map of phy addr of nage with the linear addr start
         *
         * Some Useful MACROs and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *    page2kva(struct Page *page): return the kernel vritual addr of memory which page managed (SEE pmm.h)
         *    page_insert: build the map of phy addr of an Page with the linear addr la
         *    memcpy: typical memory copy function
         *
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
         void *  src_kvaddr = page2kva(page);
         void * dst_kvaddr = page2kva(npage);

         memcpy(dst_kvaddr,src_kvaddr ,PGSIZE);

         ret = page_insert(to, npage, start, perm);
        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

可以看到copy_range函数以页为单位进行内存空间的复制。而我们需要补充的是通过获取源进程的页开始虚拟地址和目的进程的页开始虚拟地址，然后通过memcpy函数实现内存的复制，之后将新的物理页添加映射到目的进程的虚拟地址空间中去。

任务：请在实验报告中简要说明如何设计实现”Copy on Write 机制“,给出概要设计,鼓励给出详细设计。

copy_write机制可以通过在copy_mm中可以进行修改实现，在进行复制内存的时候考虑不直接先进行内存的拷贝，而是将两个进程的用户空间映射到同一物理内存上，并将该物理内存的方位设置只读，如果存在写请求则会出发page_fault，通过page_fault为需要进行写请求的进程复制一个新的物理内存供其使用。

## 练习3
任务：请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题:
请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的?
请给出ucore中一个用户态进程的执行状态生命周期图(包执行状态,执行状态之间的变
换关系,以及产生变换的事件或函数调用)。(字符方式画即可)

在本实验中,与进程相关的各个系统调用属性如下所示:
```
系统调用名 含义 具体完成服务的函数
SYS_exit process exit do_exit
SYS_fork create child process,
dup mm do_fork-->wakeup_proc
SYS_wait wait child process do_wait
SYS_exec after fork, process
execute a new program load a program and refresh the mm
SYS_yield process flag itself need
resecheduling proc->need_sched=1, then scheduler will
rescheule this process
SYS_kill kill process do_kill-->proc->flags |= PF_EXITING, --
>wakeup_proc-->do_wait-->do_exit
SYS_getpid get the process's pid
```
- 执行状态的变化:
  - fork  会创建新的子进程，子进程的运行状态设为RUNABLE
  - exec会覆盖当前执行的进程，但是不修改其执行状态
  - wait  取决于是否存在ZOMBIE的子进程，如果存在则不会发生状态的改变，如果不存在则会将当前进程置为SLEEPING态，等待执行了exit的子进程将其唤醒
  - exit 将当前的进程设置ZONBIE状态，并将父进程唤醒收了自己

- 用户太进程的执行状态生命周期图：
周期图在proc.c文件中存在，如下所示：
```
-----------------------------
process state changing:

  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
```

## Challenge
