# 操作系统lab4
> [Jack-Lio'github](https://github.com/Jack-Lio)关于ucore实验lab4的相关记录     
> 2019年11月27日最新修改

-   [小小吐槽](#小小吐槽)
-   [实验内容概括](#实验内容概括)
-   [练习0 merge lab3](#练习0)
-   [练习1 分配并初始化一个进程控制块(需要编码)](#练习1)
-   [练习2 为新创建的内核线程分配资源(需要编码)](#练习2)
-   [练习3 阅读代码,理解 proc_run 函数和它调用的函数如何完成进程切换的。(无编码工作)](#练习3)
-   [拓展练习 实现支持任意大小的内存分配算法](#Challenge)

## 小小吐槽一下
这次在做实验的时候Ubuntu操作系统突然崩溃了，我作业写了一半，系统崩了，有点头秃啊，在网上找相关资料说是因为系统更新出问题导致内核故障，按照一些教程利用recovery内核启动计算机后，才重新恢复系统的内核，不过这次太吓人了，快交作业了系统崩了。。。
然后再这次实验中，感觉东西还是不是怎么复杂，看实验文档基本都能弄明白，然后再有就是感觉合并代码有点难受，在make grade 的时候总是会有一些莫名奇妙的错误，看了代码后发现时grade.sh里面的输出写的有问题，这个地方浪费了我很多时间，总以为是合并代码出了问题。

## 实验内容概括
执行结果如下：
```
VNC server running on 127.0.0.1:5900
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc0100036 (phys)
  etext  0xc0109f8c (phys)
  edata  0xc0128000 (phys)
  end    0xc012b160 (phys)
Kernel executable memory footprint: 173KB
-> ebp:0xc0124f38   eip:0xc0100abb   args: 0x00010094 0x00010094 0xc0124f68 0xc01000df
    kern/debug/kdebug.c:309: print_stackframe+21
-> ebp:0xc0124f48   eip:0xc0100db8   args: 0x00000000 0x00000000 0x00000000 0xc0124fb8
    kern/debug/kmonitor.c:129: mon_backtrace+10
-> ebp:0xc0124f68   eip:0xc01000df   args: 0x00000000 0xc0124f90 0xffff0000 0xc0124f94
    kern/init/init.c:58: grade_backtrace2+33
-> ebp:0xc0124f88   eip:0xc0100109   args: 0x00000000 0xffff0000 0xc0124fb4 0x0000002a
    kern/init/init.c:63: grade_backtrace1+38
-> ebp:0xc0124fa8   eip:0xc0100128   args: 0x00000000 0xc0100036 0xffff0000 0x0000001d
    kern/init/init.c:68: grade_backtrace0+23
-> ebp:0xc0124fc8   eip:0xc010014e   args: 0xc0109fbc 0xc0109fa0 0x00003160 0x00000000
    kern/init/init.c:73: grade_backtrace+34
-> ebp:0xc0124ff8   eip:0xc010008b   args: 0xc010a1a4 0xc010a1ac 0xc0100d40 0xc010a1cb
    kern/init/init.c:33: kern_init+84
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
kmalloc_init() succeeded!
check_vma_struct() succeeded!
page fault at 0x00000100: K/W [no page found].
check_pgfault() succeeded!
check_vmm() succeeded.
ide 0:      10000(sectors), 'QEMU HARDDISK'.
ide 1:     262144(sectors), 'QEMU HARDDISK'.
SWAP: manager = fifo swap manager
BEGIN check_swap: count 1, total 31954
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
this initproc, pid = 1, name = "init"
To U: "Hello world!!".
To U: "en.., Bye, Bye. :)"
kernel panic at kern/process/proc.c:358:
    process exit!!.

stack trackback:
-> ebp:0xc030df98   eip:0xc0100abb   args: 0xc010a068 0xc030dfdc 0x00000166 0xc030dfcc
    kern/debug/kdebug.c:309: print_stackframe+21
-> ebp:0xc030dfc8   eip:0xc0100473   args: 0xc010bef9 0x00000166 0xc010bf0d 0xc012b044
    kern/debug/panic.c:27: __panic+103
-> ebp:0xc030dfe8   eip:0xc0108ff3   args: 0x00000000 0xc010bf8c 0x00000000 0x00000010
    kern/process/proc.c:358: do_exit+33
Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K>

```

make grade 的结果如下所示：

```
Check VMM:               (3.1s)
  -check pmm:                                OK
  -check page table:                         OK
  -check vmm:                                OK
  -check swap page fault:                    OK
  -check ticks:                              OK
  -check initproc:                           OK
Total Score: 90/90

```

## 练习0
还是通过Meld Diff工具合并代码，主要合并工作还是在kernel这个文件夹中进行，通过项目文件树不难看出，新增了一个process的文件夹负责线程的相关工作，同时在内存管理单元的mm文件夹中新增了两个文件，即kmalloc.[ch]，定义和实现新的kmalloc和kfree函数，同时实现了基于slab分配的简单算法。此外还有一个schedule文件夹包含了关于进程线程调度的实现（FIFO策略）。在libs中增加了红黑树的数据结构实现，用于slab分配的简化算法使用。
## 练习1
根据实验文档中的说明，在内核启动之后会首先调用kernel_init函数，这个函数会调用proc_init函数创建一个idleproc线程，这是内核中的第0个内核线程。

```
// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void
proc_init(void) {
    int i;

    list_init(&proc_list);                                              //初始化线程控制块链表
    for (i = 0; i < HASH_LIST_SIZE; i ++) {              //初始化进程控制块hash表
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {        //分配第一个进程控制块内存
        panic("cannot alloc idleproc.\n");
    }

//初始化进程控制块数据
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;          //设置进程为运行状态
    idleproc->kstack = (uintptr_t)bootstack;  //设置进程的栈为内核维护的栈
    idleproc->need_resched = 1;                         //这个为设为1表示需要立即调用调度函数切换到其他进程执行
    set_proc_name(idleproc, "idle");                //设置进程名字
    nr_process ++;

    current = idleproc;                                               //设置当前进程为idleproc进程

    int pid = kernel_thread(init_main, "Hello world!!", 0);     //通过创建一个内核函数创建内核线程init_main，执行一些工作，输出hello world
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}
```
这个线程的创建过程是通过alloc_proc函数获得存储线程控制块的内存区域，并对这个控制块的信息进行基本的初始化，而练习1要做的就是初始化这个控制块。完成基本的初始化。首先通过文档和代码注释查看proc_struct线程控制块数据结构的含义如下：

```
struct proc_struct {
enum proc_state state; // Process state
int pid; // Process ID
int runs; // the running times of Proces
uintptr_t kstack; // Process kernel stack
volatile bool need_resched; // need to be rescheduled to release CPU?
struct proc_struct *parent; // the parent process
struct mm_struct *mm; // Process's memory management field
struct context context; // Switch here to run process
struct trapframe *tf; // Trap frame for current interrupt
uintptr_t cr3; // the base addr of Page Directroy Table(PDT)
uint32_t flags; // Process flag
char name[PROC_NAME_LEN + 1]; // Process name
list_entry_t list_link; // Process link list
list_entry_t hash_link; // Process hash list
};
```
其中需要重点关注的是cr3，tf,context,mm,pid，state，这些数据成员分别定义了进程的内存页目录表地址，中断信息帧，基金称的上下文切换，内存管理信息，进程号和进程状态。

于是根据帮助注释我们可以补充代码如下：
```
proc->state = PROC_UNINIT;               //设置进程为初始态
proc->pid = -1;                                           //不能是0，因为零号进程需要使用
proc->runs = 0;                                          //运行时间
proc->kstack = 0;                                     //栈设置
proc->need_resched = 0;
proc->parent = NULL;
proc->mm = NULL;
memset(&(proc->context),0,sizeof(struct context));
proc->tf = NULL;
proc->cr3 = boot_cr3;                           //进程创建之初视为内核进程
proc->flags = 0;
memset(proc->name,0,PROC_NAME_LEN);     //分配内存空间
```


- ***问题：***

- 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥?(提示通过看代码和编程调试可以判断出来)

- context的数据结构如下所示：
```
// Saved registers for kernel context switches.
// Don't need to save all the %fs etc. segment registers,
// because they are constant across kernel contexts.
// Save all the regular registers so we don't need to care
// which are caller save, but not the return register %eax.
// (Not saving %eax just simplifies the switching code.)
// The layout of context must match code in switch.S.
struct context {
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};
```
通过注释不难看出context用来保存进程执行的上下文，用子啊在进行上下文切换的时候保存当前进程的相关寄存器的值。可以参考proc_run函数中调用switch_to实现上下文切换是用到context数据。

- 中断帧tf，用于进程调度的时候来构建一个新的进程运行环境，实现从就进程运行环境切换到新进程运行环境的工作。由于调度的本质是在时钟中断的时候进行，所以在进行调度新进程的时候，为了让进程以为自己没有被停过，会通过tf保存中断时的执行状态，在返回执行时中断处理程序也是通过修改tf来利用中断返回伪造中断现场，从而将CPU的运行控制顺利且从进程角度无破绽的转交给新进程。

## 练习2
> 在这个过程中,需要给新内核线程分配资源,并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括:
- 调用alloc_proc,首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程(但内核线程不必做此事)
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

根据实验文档中的步骤和实验代码中的注释，可以利用相关的函数和参数以及宏定义，添加编写do_fork函数代码如下所示：

```

//copy_thread函数首先在内核堆栈的顶部设置中断帧大小的一块栈空间,并在此空间中拷贝在
//kernel_thread函数建立的临时中断帧的初始值,并进一步设置中断帧中的栈指针esp和标志寄
//存器eflags,特别是eflags设置了FL_IF标志,这表示此内核线程在执行过程中,能响应中
//断,打断当前的执行。

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    if((proc = alloc_proc())==NULL)
    {
      goto fork_out;
    }
    proc->parent = current;
    //    2. call setup_kstack to allocate a kernel stack for child process
    if(setup_kstack(proc )!=0)
    {
      goto  bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    if(copy_mm(clone_flags,proc)!=0)
    {
        goto  bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc,stack,tf);
    //    5. insert proc_struct into hash_list && proc_list
    //需要关闭中断
    bool intr_flag;
local_intr_save(intr_flag);
{
    proc->pid = get_pid();
    hash_proc(proc);
    list_add(&proc_list,&(proc->list_link));
    nr_process ++;
  }
local_intr_restore(intr_flag);
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:                            //清楚栈
    put_kstack(proc);
bad_fork_cleanup_proc:                               //清楚线程控制块内存
    kfree(proc);
    goto fork_out;
}

```

- ***问题：***

- 请说明ucore是否做到给每个新fork的线程一个唯一的id?请说明你的分析和理由。
查看ucore系统为进程分配id的函数如下：

```
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    //先将静态局部变量next_safe和last_pid都置位为max_pid,即最大的进程id
    if (++ last_pid >= MAX_PID) {             //循环分配ＩＤ  ，不通过下一个判断直接进入代码体       
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {                   //如果上次分配的id大于等于可分配id上界
    inside:
        next_safe = MAX_PID;                        //更新允许的ｉｄ上界
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {      //遍历进程列表找到一个未分配的id
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {         //last_pid增加1，如果在安全区间内，则直接分配，否则进行区间扩大
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {               //缩小last_pid和next_safe之间的区间
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

```
从上述代码容易分析得出，确实能够分配唯一的pid，可以看到在函数中，定义了两个局部变量，这两个变量last_pid和next_safe之间的区间代表着最小的未分配id区间，函数保证了在这两个变量之间的区间是没有被分配的空白区间，同时，这种设计能够充分利用pid释放之后形成的空白区间。首先通过遍历进程控制信息列表，找到所有被分配过了的区间，如果某个id位于这两个值之间，则缩小区间，如果某个id与last_pid相等，则增加last_pid，如果last_pid增长速度超过了next_safe则，重新更新next_safe的值，形成新的区间。

## 练习3
- ***问题：***

- 请在实验报告中简要说明你对proc_run函数的分析。并回答如下问题:
- 在本实验的执行过程中,创建且运行了几个内核线程?语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);在这里有何作用?请说明理由

proc_run 函数代码如下所示：

```
// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {        //判断进程是否为执行中的进程
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);                       //sync.h 关闭中断
        {
            current = proc;                                       //切换当前执行进程
            load_esp0(next->kstack + KSTACKSIZE);             //切换 task state segment,实现运行不同的内核栈
            lcr3(next->cr3);                                                            //切换也页目录表根地址
            switch_to(&(prev->context), &(next->context));    //上下文切换switch.S
        }
        local_intr_restore(intr_flag);                                  //恢复中断
    }
}
```
该函数的作用是实现运行一个进程，如果先在正在运行一个进程，则切换执行新的进程，将CPU的执行时间交给新的进程。

从上述的代码注释中不难看出，proc_run 主要实现了关中断、切换执行进程、切换cr3寄存器、切换进程栈、进行上下文切换保存执行进程的上下文，触发系统的中断调度，实现执行新进程保存旧进程上下问的功能。

从init_proc函数的具体代码可以看到，本次试验执行了两个进程，分别为idleproc和initproc，最初建立的是idleproc，之后idleproc通过kernelthread调用do_fork函数建立了新的线程initproc负责打印一行文字。

语句local_intr_save(intr_flag);....local_intr_restore(intr_flag)的作用是关闭和打开中断，保证在运行内部语句的时候不会被中断暂停和打断，保证操作的原子性，在关于对硬件的操作时都需要进行如此的设置，保证对寄存器的操作具有原子性和连贯性，保证调度和相关寄存器操作不会造成系统的崩溃。

## Challenge

未实现。。。
