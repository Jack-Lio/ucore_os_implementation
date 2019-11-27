
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 90 11 40       	mov    $0x40119000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping        将boot_pgdir清零
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 90 11 00       	mov    %eax,0x119000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 80 11 00       	mov    $0x118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here  kern_init出现错误退出进入此无限循环说明系统崩溃
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
  /*kerne_init中的外部全局变量,可知edata[]和 end[]这些变量是ld根据kernel.ld链接
脚本生成的全局变量,表示相应段的起始地址或结束地址等*/
    extern char edata[], end[];    //在kernel.ld中定义，作为定义段的起始地址
    memset(edata, 0, end - edata);
  10003c:	ba 28 bf 11 00       	mov    $0x11bf28,%edx
  100041:	b8 36 8a 11 00       	mov    $0x118a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 8a 11 00 	movl   $0x118a36,(%esp)
  10005d:	e8 79 58 00 00       	call   1058db <memset>

    cons_init();                // init the console
  100062:	e8 a3 15 00 00       	call   10160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 e0 60 10 00 	movl   $0x1060e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 fc 60 10 00 	movl   $0x1060fc,(%esp)
  10007c:	e8 21 02 00 00       	call   1002a2 <cprintf>

    print_kerninfo();
  100081:	e8 c2 08 00 00       	call   100948 <print_kerninfo>

    grade_backtrace();
  100086:	e8 8e 00 00 00       	call   100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 76 32 00 00       	call   103306 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 da 16 00 00       	call   10176f <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 3a 18 00 00       	call   1018d4 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 0e 0d 00 00       	call   100dad <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 05 18 00 00       	call   1018a9 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a4:	e8 6b 01 00 00       	call   100214 <lab1_switch_test>

    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	55                   	push   %ebp
  1000ac:	89 e5                	mov    %esp,%ebp
  1000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b8:	00 
  1000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c0:	00 
  1000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c8:	e8 ce 0c 00 00       	call   100d9b <mon_backtrace>
}
  1000cd:	90                   	nop
  1000ce:	c9                   	leave  
  1000cf:	c3                   	ret    

001000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000d0:	55                   	push   %ebp
  1000d1:	89 e5                	mov    %esp,%ebp
  1000d3:	53                   	push   %ebx
  1000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000da:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ef:	89 04 24             	mov    %eax,(%esp)
  1000f2:	e8 b4 ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000f7:	90                   	nop
  1000f8:	83 c4 14             	add    $0x14,%esp
  1000fb:	5b                   	pop    %ebx
  1000fc:	5d                   	pop    %ebp
  1000fd:	c3                   	ret    

001000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100104:	8b 45 10             	mov    0x10(%ebp),%eax
  100107:	89 44 24 04          	mov    %eax,0x4(%esp)
  10010b:	8b 45 08             	mov    0x8(%ebp),%eax
  10010e:	89 04 24             	mov    %eax,(%esp)
  100111:	e8 ba ff ff ff       	call   1000d0 <grade_backtrace1>
}
  100116:	90                   	nop
  100117:	c9                   	leave  
  100118:	c3                   	ret    

00100119 <grade_backtrace>:

void
grade_backtrace(void) {
  100119:	55                   	push   %ebp
  10011a:	89 e5                	mov    %esp,%ebp
  10011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011f:	b8 36 00 10 00       	mov    $0x100036,%eax
  100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10012b:	ff 
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100137:	e8 c2 ff ff ff       	call   1000fe <grade_backtrace0>
}
  10013c:	90                   	nop
  10013d:	c9                   	leave  
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 01 61 10 00 	movl   $0x106101,(%esp)
  10016e:	e8 2f 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 0f 61 10 00 	movl   $0x10610f,(%esp)
  10018d:	e8 10 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 1d 61 10 00 	movl   $0x10611d,(%esp)
  1001ac:	e8 f1 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 2b 61 10 00 	movl   $0x10612b,(%esp)
  1001cb:	e8 d2 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 39 61 10 00 	movl   $0x106139,(%esp)
  1001ea:	e8 b3 00 00 00       	call   1002a2 <cprintf>
    round ++;
  1001ef:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 b0 11 00       	mov    %eax,0x11b000
}
  1001fa:	90                   	nop
  1001fb:	c9                   	leave  
  1001fc:	c3                   	ret    

001001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fd:	55                   	push   %ebp
  1001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  100200:	83 ec 08             	sub    $0x8,%esp
  100203:	cd 78                	int    $0x78
  100205:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        :
        : "i"(T_SWITCH_TOU)
    );
}
  100207:	90                   	nop
  100208:	5d                   	pop    %ebp
  100209:	c3                   	ret    

0010020a <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  10020a:	55                   	push   %ebp
  10020b:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  10020d:	cd 79                	int    $0x79
  10020f:	89 ec                	mov    %ebp,%esp
    "int %0 \n"
    "movl %%ebp, %%esp \n"
    :
    : "i"(T_SWITCH_TOK)
    );
}
  100211:	90                   	nop
  100212:	5d                   	pop    %ebp
  100213:	c3                   	ret    

00100214 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100214:	55                   	push   %ebp
  100215:	89 e5                	mov    %esp,%ebp
  100217:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10021a:	e8 20 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10021f:	c7 04 24 48 61 10 00 	movl   $0x106148,(%esp)
  100226:	e8 77 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_user();
  10022b:	e8 cd ff ff ff       	call   1001fd <lab1_switch_to_user>
    lab1_print_cur_status();
  100230:	e8 0a ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100235:	c7 04 24 68 61 10 00 	movl   $0x106168,(%esp)
  10023c:	e8 61 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_kernel();
  100241:	e8 c4 ff ff ff       	call   10020a <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100246:	e8 f4 fe ff ff       	call   10013f <lab1_print_cur_status>
}
  10024b:	90                   	nop
  10024c:	c9                   	leave  
  10024d:	c3                   	ret    

0010024e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10024e:	55                   	push   %ebp
  10024f:	89 e5                	mov    %esp,%ebp
  100251:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100254:	8b 45 08             	mov    0x8(%ebp),%eax
  100257:	89 04 24             	mov    %eax,(%esp)
  10025a:	e8 d8 13 00 00       	call   101637 <cons_putc>
    (*cnt) ++;
  10025f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100262:	8b 00                	mov    (%eax),%eax
  100264:	8d 50 01             	lea    0x1(%eax),%edx
  100267:	8b 45 0c             	mov    0xc(%ebp),%eax
  10026a:	89 10                	mov    %edx,(%eax)
}
  10026c:	90                   	nop
  10026d:	c9                   	leave  
  10026e:	c3                   	ret    

0010026f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10026f:	55                   	push   %ebp
  100270:	89 e5                	mov    %esp,%ebp
  100272:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10027f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100283:	8b 45 08             	mov    0x8(%ebp),%eax
  100286:	89 44 24 08          	mov    %eax,0x8(%esp)
  10028a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100291:	c7 04 24 4e 02 10 00 	movl   $0x10024e,(%esp)
  100298:	e8 91 59 00 00       	call   105c2e <vprintfmt>
    return cnt;
  10029d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002a0:	c9                   	leave  
  1002a1:	c3                   	ret    

001002a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  1002a2:	55                   	push   %ebp
  1002a3:	89 e5                	mov    %esp,%ebp
  1002a5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b8:	89 04 24             	mov    %eax,(%esp)
  1002bb:	e8 af ff ff ff       	call   10026f <vcprintf>
  1002c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002c6:	c9                   	leave  
  1002c7:	c3                   	ret    

001002c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002c8:	55                   	push   %ebp
  1002c9:	89 e5                	mov    %esp,%ebp
  1002cb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d1:	89 04 24             	mov    %eax,(%esp)
  1002d4:	e8 5e 13 00 00       	call   101637 <cons_putc>
}
  1002d9:	90                   	nop
  1002da:	c9                   	leave  
  1002db:	c3                   	ret    

001002dc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002dc:	55                   	push   %ebp
  1002dd:	89 e5                	mov    %esp,%ebp
  1002df:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002e9:	eb 13                	jmp    1002fe <cputs+0x22>
        cputch(c, &cnt);
  1002eb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002ef:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002f6:	89 04 24             	mov    %eax,(%esp)
  1002f9:	e8 50 ff ff ff       	call   10024e <cputch>
    while ((c = *str ++) != '\0') {
  1002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100301:	8d 50 01             	lea    0x1(%eax),%edx
  100304:	89 55 08             	mov    %edx,0x8(%ebp)
  100307:	0f b6 00             	movzbl (%eax),%eax
  10030a:	88 45 f7             	mov    %al,-0x9(%ebp)
  10030d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100311:	75 d8                	jne    1002eb <cputs+0xf>
    }
    cputch('\n', &cnt);
  100313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100316:	89 44 24 04          	mov    %eax,0x4(%esp)
  10031a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100321:	e8 28 ff ff ff       	call   10024e <cputch>
    return cnt;
  100326:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100329:	c9                   	leave  
  10032a:	c3                   	ret    

0010032b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10032b:	55                   	push   %ebp
  10032c:	89 e5                	mov    %esp,%ebp
  10032e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100331:	e8 3e 13 00 00       	call   101674 <cons_getc>
  100336:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10033d:	74 f2                	je     100331 <getchar+0x6>
        /* do nothing */;
    return c;
  10033f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100342:	c9                   	leave  
  100343:	c3                   	ret    

00100344 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100344:	55                   	push   %ebp
  100345:	89 e5                	mov    %esp,%ebp
  100347:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10034a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10034e:	74 13                	je     100363 <readline+0x1f>
        cprintf("%s", prompt);
  100350:	8b 45 08             	mov    0x8(%ebp),%eax
  100353:	89 44 24 04          	mov    %eax,0x4(%esp)
  100357:	c7 04 24 87 61 10 00 	movl   $0x106187,(%esp)
  10035e:	e8 3f ff ff ff       	call   1002a2 <cprintf>
    }
    int i = 0, c;
  100363:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10036a:	e8 bc ff ff ff       	call   10032b <getchar>
  10036f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100372:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100376:	79 07                	jns    10037f <readline+0x3b>
            return NULL;
  100378:	b8 00 00 00 00       	mov    $0x0,%eax
  10037d:	eb 78                	jmp    1003f7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10037f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100383:	7e 28                	jle    1003ad <readline+0x69>
  100385:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10038c:	7f 1f                	jg     1003ad <readline+0x69>
            cputchar(c);
  10038e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100391:	89 04 24             	mov    %eax,(%esp)
  100394:	e8 2f ff ff ff       	call   1002c8 <cputchar>
            buf[i ++] = c;
  100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10039c:	8d 50 01             	lea    0x1(%eax),%edx
  10039f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003a5:	88 90 20 b0 11 00    	mov    %dl,0x11b020(%eax)
  1003ab:	eb 45                	jmp    1003f2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1003ad:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003b1:	75 16                	jne    1003c9 <readline+0x85>
  1003b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003b7:	7e 10                	jle    1003c9 <readline+0x85>
            cputchar(c);
  1003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003bc:	89 04 24             	mov    %eax,(%esp)
  1003bf:	e8 04 ff ff ff       	call   1002c8 <cputchar>
            i --;
  1003c4:	ff 4d f4             	decl   -0xc(%ebp)
  1003c7:	eb 29                	jmp    1003f2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003c9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003cd:	74 06                	je     1003d5 <readline+0x91>
  1003cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003d3:	75 95                	jne    10036a <readline+0x26>
            cputchar(c);
  1003d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003d8:	89 04 24             	mov    %eax,(%esp)
  1003db:	e8 e8 fe ff ff       	call   1002c8 <cputchar>
            buf[i] = '\0';
  1003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003e3:	05 20 b0 11 00       	add    $0x11b020,%eax
  1003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003eb:	b8 20 b0 11 00       	mov    $0x11b020,%eax
  1003f0:	eb 05                	jmp    1003f7 <readline+0xb3>
        c = getchar();
  1003f2:	e9 73 ff ff ff       	jmp    10036a <readline+0x26>
        }
    }
}
  1003f7:	c9                   	leave  
  1003f8:	c3                   	ret    

001003f9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003f9:	55                   	push   %ebp
  1003fa:	89 e5                	mov    %esp,%ebp
  1003fc:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003ff:	a1 20 b4 11 00       	mov    0x11b420,%eax
  100404:	85 c0                	test   %eax,%eax
  100406:	75 5b                	jne    100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100408:	c7 05 20 b4 11 00 01 	movl   $0x1,0x11b420
  10040f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100412:	8d 45 14             	lea    0x14(%ebp),%eax
  100415:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100418:	8b 45 0c             	mov    0xc(%ebp),%eax
  10041b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10041f:	8b 45 08             	mov    0x8(%ebp),%eax
  100422:	89 44 24 04          	mov    %eax,0x4(%esp)
  100426:	c7 04 24 8a 61 10 00 	movl   $0x10618a,(%esp)
  10042d:	e8 70 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100435:	89 44 24 04          	mov    %eax,0x4(%esp)
  100439:	8b 45 10             	mov    0x10(%ebp),%eax
  10043c:	89 04 24             	mov    %eax,(%esp)
  10043f:	e8 2b fe ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  100444:	c7 04 24 a6 61 10 00 	movl   $0x1061a6,(%esp)
  10044b:	e8 52 fe ff ff       	call   1002a2 <cprintf>
    
    cprintf("stack trackback:\n");
  100450:	c7 04 24 a8 61 10 00 	movl   $0x1061a8,(%esp)
  100457:	e8 46 fe ff ff       	call   1002a2 <cprintf>
    print_stackframe();
  10045c:	e8 32 06 00 00       	call   100a93 <print_stackframe>
  100461:	eb 01                	jmp    100464 <__panic+0x6b>
        goto panic_dead;
  100463:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100464:	e8 47 14 00 00       	call   1018b0 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100470:	e8 59 08 00 00       	call   100cce <kmonitor>
  100475:	eb f2                	jmp    100469 <__panic+0x70>

00100477 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100477:	55                   	push   %ebp
  100478:	89 e5                	mov    %esp,%ebp
  10047a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10047d:	8d 45 14             	lea    0x14(%ebp),%eax
  100480:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100483:	8b 45 0c             	mov    0xc(%ebp),%eax
  100486:	89 44 24 08          	mov    %eax,0x8(%esp)
  10048a:	8b 45 08             	mov    0x8(%ebp),%eax
  10048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100491:	c7 04 24 ba 61 10 00 	movl   $0x1061ba,(%esp)
  100498:	e8 05 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  10049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a7:	89 04 24             	mov    %eax,(%esp)
  1004aa:	e8 c0 fd ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  1004af:	c7 04 24 a6 61 10 00 	movl   $0x1061a6,(%esp)
  1004b6:	e8 e7 fd ff ff       	call   1002a2 <cprintf>
    va_end(ap);
}
  1004bb:	90                   	nop
  1004bc:	c9                   	leave  
  1004bd:	c3                   	ret    

001004be <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004be:	55                   	push   %ebp
  1004bf:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004c1:	a1 20 b4 11 00       	mov    0x11b420,%eax
}
  1004c6:	5d                   	pop    %ebp
  1004c7:	c3                   	ret    

001004c8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004c8:	55                   	push   %ebp
  1004c9:	89 e5                	mov    %esp,%ebp
  1004cb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d1:	8b 00                	mov    (%eax),%eax
  1004d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004d6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d9:	8b 00                	mov    (%eax),%eax
  1004db:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004e5:	e9 ca 00 00 00       	jmp    1005b4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004f0:	01 d0                	add    %edx,%eax
  1004f2:	89 c2                	mov    %eax,%edx
  1004f4:	c1 ea 1f             	shr    $0x1f,%edx
  1004f7:	01 d0                	add    %edx,%eax
  1004f9:	d1 f8                	sar    %eax
  1004fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100501:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100504:	eb 03                	jmp    100509 <stab_binsearch+0x41>
            m --;
  100506:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10050c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10050f:	7c 1f                	jl     100530 <stab_binsearch+0x68>
  100511:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100514:	89 d0                	mov    %edx,%eax
  100516:	01 c0                	add    %eax,%eax
  100518:	01 d0                	add    %edx,%eax
  10051a:	c1 e0 02             	shl    $0x2,%eax
  10051d:	89 c2                	mov    %eax,%edx
  10051f:	8b 45 08             	mov    0x8(%ebp),%eax
  100522:	01 d0                	add    %edx,%eax
  100524:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100528:	0f b6 c0             	movzbl %al,%eax
  10052b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10052e:	75 d6                	jne    100506 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100533:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100536:	7d 09                	jge    100541 <stab_binsearch+0x79>
            l = true_m + 1;
  100538:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10053b:	40                   	inc    %eax
  10053c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10053f:	eb 73                	jmp    1005b4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100541:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100548:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10054b:	89 d0                	mov    %edx,%eax
  10054d:	01 c0                	add    %eax,%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	c1 e0 02             	shl    $0x2,%eax
  100554:	89 c2                	mov    %eax,%edx
  100556:	8b 45 08             	mov    0x8(%ebp),%eax
  100559:	01 d0                	add    %edx,%eax
  10055b:	8b 40 08             	mov    0x8(%eax),%eax
  10055e:	39 45 18             	cmp    %eax,0x18(%ebp)
  100561:	76 11                	jbe    100574 <stab_binsearch+0xac>
            *region_left = m;
  100563:	8b 45 0c             	mov    0xc(%ebp),%eax
  100566:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100569:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10056e:	40                   	inc    %eax
  10056f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100572:	eb 40                	jmp    1005b4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100574:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100577:	89 d0                	mov    %edx,%eax
  100579:	01 c0                	add    %eax,%eax
  10057b:	01 d0                	add    %edx,%eax
  10057d:	c1 e0 02             	shl    $0x2,%eax
  100580:	89 c2                	mov    %eax,%edx
  100582:	8b 45 08             	mov    0x8(%ebp),%eax
  100585:	01 d0                	add    %edx,%eax
  100587:	8b 40 08             	mov    0x8(%eax),%eax
  10058a:	39 45 18             	cmp    %eax,0x18(%ebp)
  10058d:	73 14                	jae    1005a3 <stab_binsearch+0xdb>
            *region_right = m - 1;
  10058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100592:	8d 50 ff             	lea    -0x1(%eax),%edx
  100595:	8b 45 10             	mov    0x10(%ebp),%eax
  100598:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10059a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10059d:	48                   	dec    %eax
  10059e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005a1:	eb 11                	jmp    1005b4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005a9:	89 10                	mov    %edx,(%eax)
            l = m;
  1005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005b1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1005b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005ba:	0f 8e 2a ff ff ff    	jle    1004ea <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1005c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005c4:	75 0f                	jne    1005d5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005c9:	8b 00                	mov    (%eax),%eax
  1005cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1005d1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005d3:	eb 3e                	jmp    100613 <stab_binsearch+0x14b>
        l = *region_right;
  1005d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1005d8:	8b 00                	mov    (%eax),%eax
  1005da:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005dd:	eb 03                	jmp    1005e2 <stab_binsearch+0x11a>
  1005df:	ff 4d fc             	decl   -0x4(%ebp)
  1005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e5:	8b 00                	mov    (%eax),%eax
  1005e7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005ea:	7e 1f                	jle    10060b <stab_binsearch+0x143>
  1005ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005ef:	89 d0                	mov    %edx,%eax
  1005f1:	01 c0                	add    %eax,%eax
  1005f3:	01 d0                	add    %edx,%eax
  1005f5:	c1 e0 02             	shl    $0x2,%eax
  1005f8:	89 c2                	mov    %eax,%edx
  1005fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1005fd:	01 d0                	add    %edx,%eax
  1005ff:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100603:	0f b6 c0             	movzbl %al,%eax
  100606:	39 45 14             	cmp    %eax,0x14(%ebp)
  100609:	75 d4                	jne    1005df <stab_binsearch+0x117>
        *region_left = l;
  10060b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100611:	89 10                	mov    %edx,(%eax)
}
  100613:	90                   	nop
  100614:	c9                   	leave  
  100615:	c3                   	ret    

00100616 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100616:	55                   	push   %ebp
  100617:	89 e5                	mov    %esp,%ebp
  100619:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10061c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061f:	c7 00 d8 61 10 00    	movl   $0x1061d8,(%eax)
    info->eip_line = 0;
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	c7 40 08 d8 61 10 00 	movl   $0x1061d8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100639:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100643:	8b 45 0c             	mov    0xc(%ebp),%eax
  100646:	8b 55 08             	mov    0x8(%ebp),%edx
  100649:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10064c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10064f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100656:	c7 45 f4 e8 73 10 00 	movl   $0x1073e8,-0xc(%ebp)
    stab_end = __STAB_END__;
  10065d:	c7 45 f0 b8 27 11 00 	movl   $0x1127b8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100664:	c7 45 ec b9 27 11 00 	movl   $0x1127b9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10066b:	c7 45 e8 e6 52 11 00 	movl   $0x1152e6,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100678:	76 0b                	jbe    100685 <debuginfo_eip+0x6f>
  10067a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10067d:	48                   	dec    %eax
  10067e:	0f b6 00             	movzbl (%eax),%eax
  100681:	84 c0                	test   %al,%al
  100683:	74 0a                	je     10068f <debuginfo_eip+0x79>
        return -1;
  100685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10068a:	e9 b7 02 00 00       	jmp    100946 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10068f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10069c:	29 c2                	sub    %eax,%edx
  10069e:	89 d0                	mov    %edx,%eax
  1006a0:	c1 f8 02             	sar    $0x2,%eax
  1006a3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006a9:	48                   	dec    %eax
  1006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1006b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006b4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006bb:	00 
  1006bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006cd:	89 04 24             	mov    %eax,(%esp)
  1006d0:	e8 f3 fd ff ff       	call   1004c8 <stab_binsearch>
    if (lfile == 0)
  1006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d8:	85 c0                	test   %eax,%eax
  1006da:	75 0a                	jne    1006e6 <debuginfo_eip+0xd0>
        return -1;
  1006dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006e1:	e9 60 02 00 00       	jmp    100946 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006f9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100700:	00 
  100701:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100704:	89 44 24 08          	mov    %eax,0x8(%esp)
  100708:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10070b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100712:	89 04 24             	mov    %eax,(%esp)
  100715:	e8 ae fd ff ff       	call   1004c8 <stab_binsearch>

    if (lfun <= rfun) {
  10071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100720:	39 c2                	cmp    %eax,%edx
  100722:	7f 7c                	jg     1007a0 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100724:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100727:	89 c2                	mov    %eax,%edx
  100729:	89 d0                	mov    %edx,%eax
  10072b:	01 c0                	add    %eax,%eax
  10072d:	01 d0                	add    %edx,%eax
  10072f:	c1 e0 02             	shl    $0x2,%eax
  100732:	89 c2                	mov    %eax,%edx
  100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100737:	01 d0                	add    %edx,%eax
  100739:	8b 00                	mov    (%eax),%eax
  10073b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10073e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100741:	29 d1                	sub    %edx,%ecx
  100743:	89 ca                	mov    %ecx,%edx
  100745:	39 d0                	cmp    %edx,%eax
  100747:	73 22                	jae    10076b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100749:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10074c:	89 c2                	mov    %eax,%edx
  10074e:	89 d0                	mov    %edx,%eax
  100750:	01 c0                	add    %eax,%eax
  100752:	01 d0                	add    %edx,%eax
  100754:	c1 e0 02             	shl    $0x2,%eax
  100757:	89 c2                	mov    %eax,%edx
  100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075c:	01 d0                	add    %edx,%eax
  10075e:	8b 10                	mov    (%eax),%edx
  100760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100763:	01 c2                	add    %eax,%edx
  100765:	8b 45 0c             	mov    0xc(%ebp),%eax
  100768:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10076b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10076e:	89 c2                	mov    %eax,%edx
  100770:	89 d0                	mov    %edx,%eax
  100772:	01 c0                	add    %eax,%eax
  100774:	01 d0                	add    %edx,%eax
  100776:	c1 e0 02             	shl    $0x2,%eax
  100779:	89 c2                	mov    %eax,%edx
  10077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10077e:	01 d0                	add    %edx,%eax
  100780:	8b 50 08             	mov    0x8(%eax),%edx
  100783:	8b 45 0c             	mov    0xc(%ebp),%eax
  100786:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100789:	8b 45 0c             	mov    0xc(%ebp),%eax
  10078c:	8b 40 10             	mov    0x10(%eax),%eax
  10078f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100795:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100798:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10079b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10079e:	eb 15                	jmp    1007b5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a3:	8b 55 08             	mov    0x8(%ebp),%edx
  1007a6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b8:	8b 40 08             	mov    0x8(%eax),%eax
  1007bb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007c2:	00 
  1007c3:	89 04 24             	mov    %eax,(%esp)
  1007c6:	e8 8c 4f 00 00       	call   105757 <strfind>
  1007cb:	89 c2                	mov    %eax,%edx
  1007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d0:	8b 40 08             	mov    0x8(%eax),%eax
  1007d3:	29 c2                	sub    %eax,%edx
  1007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007db:	8b 45 08             	mov    0x8(%ebp),%eax
  1007de:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007e2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007e9:	00 
  1007ea:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007f1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fb:	89 04 24             	mov    %eax,(%esp)
  1007fe:	e8 c5 fc ff ff       	call   1004c8 <stab_binsearch>
    if (lline <= rline) {
  100803:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100806:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100809:	39 c2                	cmp    %eax,%edx
  10080b:	7f 23                	jg     100830 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  10080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100810:	89 c2                	mov    %eax,%edx
  100812:	89 d0                	mov    %edx,%eax
  100814:	01 c0                	add    %eax,%eax
  100816:	01 d0                	add    %edx,%eax
  100818:	c1 e0 02             	shl    $0x2,%eax
  10081b:	89 c2                	mov    %eax,%edx
  10081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100820:	01 d0                	add    %edx,%eax
  100822:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100826:	89 c2                	mov    %eax,%edx
  100828:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10082e:	eb 11                	jmp    100841 <debuginfo_eip+0x22b>
        return -1;
  100830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100835:	e9 0c 01 00 00       	jmp    100946 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10083a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10083d:	48                   	dec    %eax
  10083e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100847:	39 c2                	cmp    %eax,%edx
  100849:	7c 56                	jl     1008a1 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  10084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	89 d0                	mov    %edx,%eax
  100852:	01 c0                	add    %eax,%eax
  100854:	01 d0                	add    %edx,%eax
  100856:	c1 e0 02             	shl    $0x2,%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100864:	3c 84                	cmp    $0x84,%al
  100866:	74 39                	je     1008a1 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10086b:	89 c2                	mov    %eax,%edx
  10086d:	89 d0                	mov    %edx,%eax
  10086f:	01 c0                	add    %eax,%eax
  100871:	01 d0                	add    %edx,%eax
  100873:	c1 e0 02             	shl    $0x2,%eax
  100876:	89 c2                	mov    %eax,%edx
  100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10087b:	01 d0                	add    %edx,%eax
  10087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100881:	3c 64                	cmp    $0x64,%al
  100883:	75 b5                	jne    10083a <debuginfo_eip+0x224>
  100885:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100888:	89 c2                	mov    %eax,%edx
  10088a:	89 d0                	mov    %edx,%eax
  10088c:	01 c0                	add    %eax,%eax
  10088e:	01 d0                	add    %edx,%eax
  100890:	c1 e0 02             	shl    $0x2,%eax
  100893:	89 c2                	mov    %eax,%edx
  100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100898:	01 d0                	add    %edx,%eax
  10089a:	8b 40 08             	mov    0x8(%eax),%eax
  10089d:	85 c0                	test   %eax,%eax
  10089f:	74 99                	je     10083a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008a7:	39 c2                	cmp    %eax,%edx
  1008a9:	7c 46                	jl     1008f1 <debuginfo_eip+0x2db>
  1008ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008ae:	89 c2                	mov    %eax,%edx
  1008b0:	89 d0                	mov    %edx,%eax
  1008b2:	01 c0                	add    %eax,%eax
  1008b4:	01 d0                	add    %edx,%eax
  1008b6:	c1 e0 02             	shl    $0x2,%eax
  1008b9:	89 c2                	mov    %eax,%edx
  1008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008be:	01 d0                	add    %edx,%eax
  1008c0:	8b 00                	mov    (%eax),%eax
  1008c2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008c8:	29 d1                	sub    %edx,%ecx
  1008ca:	89 ca                	mov    %ecx,%edx
  1008cc:	39 d0                	cmp    %edx,%eax
  1008ce:	73 21                	jae    1008f1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d3:	89 c2                	mov    %eax,%edx
  1008d5:	89 d0                	mov    %edx,%eax
  1008d7:	01 c0                	add    %eax,%eax
  1008d9:	01 d0                	add    %edx,%eax
  1008db:	c1 e0 02             	shl    $0x2,%eax
  1008de:	89 c2                	mov    %eax,%edx
  1008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e3:	01 d0                	add    %edx,%eax
  1008e5:	8b 10                	mov    (%eax),%edx
  1008e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008ea:	01 c2                	add    %eax,%edx
  1008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008ef:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008f7:	39 c2                	cmp    %eax,%edx
  1008f9:	7d 46                	jge    100941 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008fe:	40                   	inc    %eax
  1008ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100902:	eb 16                	jmp    10091a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100904:	8b 45 0c             	mov    0xc(%ebp),%eax
  100907:	8b 40 14             	mov    0x14(%eax),%eax
  10090a:	8d 50 01             	lea    0x1(%eax),%edx
  10090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100910:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100913:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100916:	40                   	inc    %eax
  100917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10091a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10091d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100920:	39 c2                	cmp    %eax,%edx
  100922:	7d 1d                	jge    100941 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100924:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100927:	89 c2                	mov    %eax,%edx
  100929:	89 d0                	mov    %edx,%eax
  10092b:	01 c0                	add    %eax,%eax
  10092d:	01 d0                	add    %edx,%eax
  10092f:	c1 e0 02             	shl    $0x2,%eax
  100932:	89 c2                	mov    %eax,%edx
  100934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100937:	01 d0                	add    %edx,%eax
  100939:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10093d:	3c a0                	cmp    $0xa0,%al
  10093f:	74 c3                	je     100904 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  100941:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100946:	c9                   	leave  
  100947:	c3                   	ret    

00100948 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100948:	55                   	push   %ebp
  100949:	89 e5                	mov    %esp,%ebp
  10094b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10094e:	c7 04 24 e2 61 10 00 	movl   $0x1061e2,(%esp)
  100955:	e8 48 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100961:	00 
  100962:	c7 04 24 fb 61 10 00 	movl   $0x1061fb,(%esp)
  100969:	e8 34 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096e:	c7 44 24 04 d5 60 10 	movl   $0x1060d5,0x4(%esp)
  100975:	00 
  100976:	c7 04 24 13 62 10 00 	movl   $0x106213,(%esp)
  10097d:	e8 20 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100982:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  100989:	00 
  10098a:	c7 04 24 2b 62 10 00 	movl   $0x10622b,(%esp)
  100991:	e8 0c f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100996:	c7 44 24 04 28 bf 11 	movl   $0x11bf28,0x4(%esp)
  10099d:	00 
  10099e:	c7 04 24 43 62 10 00 	movl   $0x106243,(%esp)
  1009a5:	e8 f8 f8 ff ff       	call   1002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009aa:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
  1009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009ba:	29 c2                	sub    %eax,%edx
  1009bc:	89 d0                	mov    %edx,%eax
  1009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	0f 48 c2             	cmovs  %edx,%eax
  1009c9:	c1 f8 0a             	sar    $0xa,%eax
  1009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d0:	c7 04 24 5c 62 10 00 	movl   $0x10625c,(%esp)
  1009d7:	e8 c6 f8 ff ff       	call   1002a2 <cprintf>
}
  1009dc:	90                   	nop
  1009dd:	c9                   	leave  
  1009de:	c3                   	ret    

001009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009df:	55                   	push   %ebp
  1009e0:	89 e5                	mov    %esp,%ebp
  1009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f2:	89 04 24             	mov    %eax,(%esp)
  1009f5:	e8 1c fc ff ff       	call   100616 <debuginfo_eip>
  1009fa:	85 c0                	test   %eax,%eax
  1009fc:	74 15                	je     100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a05:	c7 04 24 86 62 10 00 	movl   $0x106286,(%esp)
  100a0c:	e8 91 f8 ff ff       	call   1002a2 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a11:	eb 6c                	jmp    100a7f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a1a:	eb 1b                	jmp    100a37 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a22:	01 d0                	add    %edx,%eax
  100a24:	0f b6 00             	movzbl (%eax),%eax
  100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a30:	01 ca                	add    %ecx,%edx
  100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a34:	ff 45 f4             	incl   -0xc(%ebp)
  100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a3a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a3d:	7c dd                	jl     100a1c <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a3f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a48:	01 d0                	add    %edx,%eax
  100a4a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a50:	8b 55 08             	mov    0x8(%ebp),%edx
  100a53:	89 d1                	mov    %edx,%ecx
  100a55:	29 c1                	sub    %eax,%ecx
  100a57:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a5d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a61:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a67:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a73:	c7 04 24 a2 62 10 00 	movl   $0x1062a2,(%esp)
  100a7a:	e8 23 f8 ff ff       	call   1002a2 <cprintf>
}
  100a7f:	90                   	nop
  100a80:	c9                   	leave  
  100a81:	c3                   	ret    

00100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a82:	55                   	push   %ebp
  100a83:	89 e5                	mov    %esp,%ebp
  100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a88:	8b 45 04             	mov    0x4(%ebp),%eax
  100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a91:	c9                   	leave  
  100a92:	c3                   	ret    

00100a93 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */

void
print_stackframe(void) {
  100a93:	55                   	push   %ebp
  100a94:	89 e5                	mov    %esp,%ebp
  100a96:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a99:	89 e8                	mov    %ebp,%eax
  100a9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
  100aa4:	e8 d9 ff ff ff       	call   100a82 <read_eip>
  100aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
  100aac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100ab3:	e9 9a 00 00 00       	jmp    100b52 <print_stackframe+0xbf>
      {
        if (ebp==0)  break;
  100ab8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100abc:	0f 84 9c 00 00 00    	je     100b5e <print_stackframe+0xcb>
        cprintf("-> ebp:0x%08x   eip:0x%08x   " ,ebp,eip);
  100ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad0:	c7 04 24 b4 62 10 00 	movl   $0x1062b4,(%esp)
  100ad7:	e8 c6 f7 ff ff       	call   1002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	83 c0 08             	add    $0x8,%eax
  100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
  100ae5:	c7 04 24 d2 62 10 00 	movl   $0x1062d2,(%esp)
  100aec:	e8 b1 f7 ff ff       	call   1002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
  100af1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100af8:	eb 24                	jmp    100b1e <print_stackframe+0x8b>
        {
          cprintf("0x%08x ",arguments[j]);
  100afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100afd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b07:	01 d0                	add    %edx,%eax
  100b09:	8b 00                	mov    (%eax),%eax
  100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b0f:	c7 04 24 d9 62 10 00 	movl   $0x1062d9,(%esp)
  100b16:	e8 87 f7 ff ff       	call   1002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
  100b1b:	ff 45 e8             	incl   -0x18(%ebp)
  100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b22:	7e d6                	jle    100afa <print_stackframe+0x67>
        }
        cprintf("\n");
  100b24:	c7 04 24 e1 62 10 00 	movl   $0x1062e1,(%esp)
  100b2b:	e8 72 f7 ff ff       	call   1002a2 <cprintf>
        print_debuginfo(eip-1);
  100b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b33:	48                   	dec    %eax
  100b34:	89 04 24             	mov    %eax,(%esp)
  100b37:	e8 a3 fe ff ff       	call   1009df <print_debuginfo>
        eip =( (uint32_t*) ebp)[1];
  100b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b3f:	83 c0 04             	add    $0x4,%eax
  100b42:	8b 00                	mov    (%eax),%eax
  100b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp= ((uint32_t* ) ebp)[0];
  100b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b4a:	8b 00                	mov    (%eax),%eax
  100b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
  100b4f:	ff 45 ec             	incl   -0x14(%ebp)
  100b52:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b56:	0f 8e 5c ff ff ff    	jle    100ab8 <print_stackframe+0x25>
      }

}
  100b5c:	eb 01                	jmp    100b5f <print_stackframe+0xcc>
        if (ebp==0)  break;
  100b5e:	90                   	nop
}
  100b5f:	90                   	nop
  100b60:	c9                   	leave  
  100b61:	c3                   	ret    

00100b62 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b62:	55                   	push   %ebp
  100b63:	89 e5                	mov    %esp,%ebp
  100b65:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b6f:	eb 0c                	jmp    100b7d <parse+0x1b>
            *buf ++ = '\0';
  100b71:	8b 45 08             	mov    0x8(%ebp),%eax
  100b74:	8d 50 01             	lea    0x1(%eax),%edx
  100b77:	89 55 08             	mov    %edx,0x8(%ebp)
  100b7a:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b80:	0f b6 00             	movzbl (%eax),%eax
  100b83:	84 c0                	test   %al,%al
  100b85:	74 1d                	je     100ba4 <parse+0x42>
  100b87:	8b 45 08             	mov    0x8(%ebp),%eax
  100b8a:	0f b6 00             	movzbl (%eax),%eax
  100b8d:	0f be c0             	movsbl %al,%eax
  100b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b94:	c7 04 24 64 63 10 00 	movl   $0x106364,(%esp)
  100b9b:	e8 85 4b 00 00       	call   105725 <strchr>
  100ba0:	85 c0                	test   %eax,%eax
  100ba2:	75 cd                	jne    100b71 <parse+0xf>
        }
        if (*buf == '\0') {
  100ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba7:	0f b6 00             	movzbl (%eax),%eax
  100baa:	84 c0                	test   %al,%al
  100bac:	74 65                	je     100c13 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bae:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bb2:	75 14                	jne    100bc8 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bb4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100bbb:	00 
  100bbc:	c7 04 24 69 63 10 00 	movl   $0x106369,(%esp)
  100bc3:	e8 da f6 ff ff       	call   1002a2 <cprintf>
        }
        argv[argc ++] = buf;
  100bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bcb:	8d 50 01             	lea    0x1(%eax),%edx
  100bce:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bdb:	01 c2                	add    %eax,%edx
  100bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  100be0:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100be2:	eb 03                	jmp    100be7 <parse+0x85>
            buf ++;
  100be4:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100be7:	8b 45 08             	mov    0x8(%ebp),%eax
  100bea:	0f b6 00             	movzbl (%eax),%eax
  100bed:	84 c0                	test   %al,%al
  100bef:	74 8c                	je     100b7d <parse+0x1b>
  100bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf4:	0f b6 00             	movzbl (%eax),%eax
  100bf7:	0f be c0             	movsbl %al,%eax
  100bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bfe:	c7 04 24 64 63 10 00 	movl   $0x106364,(%esp)
  100c05:	e8 1b 4b 00 00       	call   105725 <strchr>
  100c0a:	85 c0                	test   %eax,%eax
  100c0c:	74 d6                	je     100be4 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c0e:	e9 6a ff ff ff       	jmp    100b7d <parse+0x1b>
            break;
  100c13:	90                   	nop
        }
    }
    return argc;
  100c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c17:	c9                   	leave  
  100c18:	c3                   	ret    

00100c19 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c19:	55                   	push   %ebp
  100c1a:	89 e5                	mov    %esp,%ebp
  100c1c:	53                   	push   %ebx
  100c1d:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c20:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c27:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2a:	89 04 24             	mov    %eax,(%esp)
  100c2d:	e8 30 ff ff ff       	call   100b62 <parse>
  100c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c39:	75 0a                	jne    100c45 <runcmd+0x2c>
        return 0;
  100c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  100c40:	e9 83 00 00 00       	jmp    100cc8 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c4c:	eb 5a                	jmp    100ca8 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c4e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c54:	89 d0                	mov    %edx,%eax
  100c56:	01 c0                	add    %eax,%eax
  100c58:	01 d0                	add    %edx,%eax
  100c5a:	c1 e0 02             	shl    $0x2,%eax
  100c5d:	05 00 80 11 00       	add    $0x118000,%eax
  100c62:	8b 00                	mov    (%eax),%eax
  100c64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c68:	89 04 24             	mov    %eax,(%esp)
  100c6b:	e8 18 4a 00 00       	call   105688 <strcmp>
  100c70:	85 c0                	test   %eax,%eax
  100c72:	75 31                	jne    100ca5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c77:	89 d0                	mov    %edx,%eax
  100c79:	01 c0                	add    %eax,%eax
  100c7b:	01 d0                	add    %edx,%eax
  100c7d:	c1 e0 02             	shl    $0x2,%eax
  100c80:	05 08 80 11 00       	add    $0x118008,%eax
  100c85:	8b 10                	mov    (%eax),%edx
  100c87:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c8a:	83 c0 04             	add    $0x4,%eax
  100c8d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c90:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9e:	89 1c 24             	mov    %ebx,(%esp)
  100ca1:	ff d2                	call   *%edx
  100ca3:	eb 23                	jmp    100cc8 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100ca5:	ff 45 f4             	incl   -0xc(%ebp)
  100ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cab:	83 f8 02             	cmp    $0x2,%eax
  100cae:	76 9e                	jbe    100c4e <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cb0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cb7:	c7 04 24 87 63 10 00 	movl   $0x106387,(%esp)
  100cbe:	e8 df f5 ff ff       	call   1002a2 <cprintf>
    return 0;
  100cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc8:	83 c4 64             	add    $0x64,%esp
  100ccb:	5b                   	pop    %ebx
  100ccc:	5d                   	pop    %ebp
  100ccd:	c3                   	ret    

00100cce <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cce:	55                   	push   %ebp
  100ccf:	89 e5                	mov    %esp,%ebp
  100cd1:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cd4:	c7 04 24 a0 63 10 00 	movl   $0x1063a0,(%esp)
  100cdb:	e8 c2 f5 ff ff       	call   1002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ce0:	c7 04 24 c8 63 10 00 	movl   $0x1063c8,(%esp)
  100ce7:	e8 b6 f5 ff ff       	call   1002a2 <cprintf>

    if (tf != NULL) {
  100cec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cf0:	74 0b                	je     100cfd <kmonitor+0x2f>
        print_trapframe(tf);
  100cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf5:	89 04 24             	mov    %eax,(%esp)
  100cf8:	e8 8f 0d 00 00       	call   101a8c <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cfd:	c7 04 24 ed 63 10 00 	movl   $0x1063ed,(%esp)
  100d04:	e8 3b f6 ff ff       	call   100344 <readline>
  100d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d10:	74 eb                	je     100cfd <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100d12:	8b 45 08             	mov    0x8(%ebp),%eax
  100d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d1c:	89 04 24             	mov    %eax,(%esp)
  100d1f:	e8 f5 fe ff ff       	call   100c19 <runcmd>
  100d24:	85 c0                	test   %eax,%eax
  100d26:	78 02                	js     100d2a <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100d28:	eb d3                	jmp    100cfd <kmonitor+0x2f>
                break;
  100d2a:	90                   	nop
            }
        }
    }
}
  100d2b:	90                   	nop
  100d2c:	c9                   	leave  
  100d2d:	c3                   	ret    

00100d2e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d2e:	55                   	push   %ebp
  100d2f:	89 e5                	mov    %esp,%ebp
  100d31:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d3b:	eb 3d                	jmp    100d7a <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d40:	89 d0                	mov    %edx,%eax
  100d42:	01 c0                	add    %eax,%eax
  100d44:	01 d0                	add    %edx,%eax
  100d46:	c1 e0 02             	shl    $0x2,%eax
  100d49:	05 04 80 11 00       	add    $0x118004,%eax
  100d4e:	8b 08                	mov    (%eax),%ecx
  100d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d53:	89 d0                	mov    %edx,%eax
  100d55:	01 c0                	add    %eax,%eax
  100d57:	01 d0                	add    %edx,%eax
  100d59:	c1 e0 02             	shl    $0x2,%eax
  100d5c:	05 00 80 11 00       	add    $0x118000,%eax
  100d61:	8b 00                	mov    (%eax),%eax
  100d63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d6b:	c7 04 24 f1 63 10 00 	movl   $0x1063f1,(%esp)
  100d72:	e8 2b f5 ff ff       	call   1002a2 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d77:	ff 45 f4             	incl   -0xc(%ebp)
  100d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d7d:	83 f8 02             	cmp    $0x2,%eax
  100d80:	76 bb                	jbe    100d3d <mon_help+0xf>
    }
    return 0;
  100d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d87:	c9                   	leave  
  100d88:	c3                   	ret    

00100d89 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d89:	55                   	push   %ebp
  100d8a:	89 e5                	mov    %esp,%ebp
  100d8c:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d8f:	e8 b4 fb ff ff       	call   100948 <print_kerninfo>
    return 0;
  100d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d99:	c9                   	leave  
  100d9a:	c3                   	ret    

00100d9b <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d9b:	55                   	push   %ebp
  100d9c:	89 e5                	mov    %esp,%ebp
  100d9e:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100da1:	e8 ed fc ff ff       	call   100a93 <print_stackframe>
    return 0;
  100da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dab:	c9                   	leave  
  100dac:	c3                   	ret    

00100dad <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dad:	55                   	push   %ebp
  100dae:	89 e5                	mov    %esp,%ebp
  100db0:	83 ec 28             	sub    $0x28,%esp
  100db3:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100db9:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dbd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dc1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dc5:	ee                   	out    %al,(%dx)
  100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd8:	ee                   	out    %al,(%dx)
  100dd9:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100ddf:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100de3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100de7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100deb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dec:	c7 05 0c bf 11 00 00 	movl   $0x0,0x11bf0c
  100df3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df6:	c7 04 24 fa 63 10 00 	movl   $0x1063fa,(%esp)
  100dfd:	e8 a0 f4 ff ff       	call   1002a2 <cprintf>
    pic_enable(IRQ_TIMER);
  100e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e09:	e8 2e 09 00 00       	call   10173c <pic_enable>
}
  100e0e:	90                   	nop
  100e0f:	c9                   	leave  
  100e10:	c3                   	ret    

00100e11 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {     //TS自旋锁机制
  100e11:	55                   	push   %ebp
  100e12:	89 e5                	mov    %esp,%ebp
  100e14:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {   //保存标志寄存器的值
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e17:	9c                   	pushf  
  100e18:	58                   	pop    %eax
  100e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
  100e1f:	25 00 02 00 00       	and    $0x200,%eax
  100e24:	85 c0                	test   %eax,%eax
  100e26:	74 0c                	je     100e34 <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
  100e28:	e8 83 0a 00 00       	call   1018b0 <intr_disable>
        return 1;
  100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  100e32:	eb 05                	jmp    100e39 <__intr_save+0x28>
    }
    return 0;       //否则表明中断标志位为0
  100e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e39:	c9                   	leave  
  100e3a:	c3                   	ret    

00100e3b <__intr_restore>:

static inline void
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
  100e3b:	55                   	push   %ebp
  100e3c:	89 e5                	mov    %esp,%ebp
  100e3e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e45:	74 05                	je     100e4c <__intr_restore+0x11>
        intr_enable();
  100e47:	e8 5d 0a 00 00       	call   1018a9 <intr_enable>
    }
}
  100e4c:	90                   	nop
  100e4d:	c9                   	leave  
  100e4e:	c3                   	ret    

00100e4f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e4f:	55                   	push   %ebp
  100e50:	89 e5                	mov    %esp,%ebp
  100e52:	83 ec 10             	sub    $0x10,%esp
  100e55:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e5b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e5f:	89 c2                	mov    %eax,%edx
  100e61:	ec                   	in     (%dx),%al
  100e62:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6f:	89 c2                	mov    %eax,%edx
  100e71:	ec                   	in     (%dx),%al
  100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e75:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e7b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e7f:	89 c2                	mov    %eax,%edx
  100e81:	ec                   	in     (%dx),%al
  100e82:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e85:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e8b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e8f:	89 c2                	mov    %eax,%edx
  100e91:	ec                   	in     (%dx),%al
  100e92:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e95:	90                   	nop
  100e96:	c9                   	leave  
  100e97:	c3                   	ret    

00100e98 <cga_init>:
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e98:	55                   	push   %ebp
  100e99:	89 e5                	mov    %esp,%ebp
  100e9b:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e9e:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea8:	0f b7 00             	movzwl (%eax),%eax
  100eab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eba:	0f b7 00             	movzwl (%eax),%eax
  100ebd:	0f b7 c0             	movzwl %ax,%eax
  100ec0:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ec5:	74 12                	je     100ed9 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ece:	66 c7 05 46 b4 11 00 	movw   $0x3b4,0x11b446
  100ed5:	b4 03 
  100ed7:	eb 13                	jmp    100eec <cga_init+0x54>
    } else {
        *cp = was;
  100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee3:	66 c7 05 46 b4 11 00 	movw   $0x3d4,0x11b446
  100eea:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);
  100eec:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100ef3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ef7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100efb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f03:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100f04:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f0b:	40                   	inc    %eax
  100f0c:	0f b7 c0             	movzwl %ax,%eax
  100f0f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f13:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f17:	89 c2                	mov    %eax,%edx
  100f19:	ec                   	in     (%dx),%al
  100f1a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f1d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f21:	0f b6 c0             	movzbl %al,%eax
  100f24:	c1 e0 08             	shl    $0x8,%eax
  100f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f2a:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f41:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f42:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f49:	40                   	inc    %eax
  100f4a:	0f b7 c0             	movzwl %ax,%eax
  100f4d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f51:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f55:	89 c2                	mov    %eax,%edx
  100f57:	ec                   	in     (%dx),%al
  100f58:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f5b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f5f:	0f b6 c0             	movzbl %al,%eax
  100f62:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f68:	a3 40 b4 11 00       	mov    %eax,0x11b440
    crt_pos = pos;
  100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f70:	0f b7 c0             	movzwl %ax,%eax
  100f73:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
}
  100f79:	90                   	nop
  100f7a:	c9                   	leave  
  100f7b:	c3                   	ret    

00100f7c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f7c:	55                   	push   %ebp
  100f7d:	89 e5                	mov    %esp,%ebp
  100f7f:	83 ec 48             	sub    $0x48,%esp
  100f82:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f88:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f94:	ee                   	out    %al,(%dx)
  100f95:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f9b:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f9f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fa3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fa7:	ee                   	out    %al,(%dx)
  100fa8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fae:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100fb2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fb6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fba:	ee                   	out    %al,(%dx)
  100fbb:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fc1:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fc5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fc9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fcd:	ee                   	out    %al,(%dx)
  100fce:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fd4:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100fd8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fdc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe0:	ee                   	out    %al,(%dx)
  100fe1:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fe7:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100feb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ff3:	ee                   	out    %al,(%dx)
  100ff4:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100ffa:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100ffe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101002:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101006:	ee                   	out    %al,(%dx)
  101007:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101011:	89 c2                	mov    %eax,%edx
  101013:	ec                   	in     (%dx),%al
  101014:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101017:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10101b:	3c ff                	cmp    $0xff,%al
  10101d:	0f 95 c0             	setne  %al
  101020:	0f b6 c0             	movzbl %al,%eax
  101023:	a3 48 b4 11 00       	mov    %eax,0x11b448
  101028:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10102e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101032:	89 c2                	mov    %eax,%edx
  101034:	ec                   	in     (%dx),%al
  101035:	88 45 f1             	mov    %al,-0xf(%ebp)
  101038:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10103e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101042:	89 c2                	mov    %eax,%edx
  101044:	ec                   	in     (%dx),%al
  101045:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101048:	a1 48 b4 11 00       	mov    0x11b448,%eax
  10104d:	85 c0                	test   %eax,%eax
  10104f:	74 0c                	je     10105d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101051:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101058:	e8 df 06 00 00       	call   10173c <pic_enable>
    }
}
  10105d:	90                   	nop
  10105e:	c9                   	leave  
  10105f:	c3                   	ret    

00101060 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101060:	55                   	push   %ebp
  101061:	89 e5                	mov    %esp,%ebp
  101063:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101066:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10106d:	eb 08                	jmp    101077 <lpt_putc_sub+0x17>
        delay();
  10106f:	e8 db fd ff ff       	call   100e4f <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101074:	ff 45 fc             	incl   -0x4(%ebp)
  101077:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10107d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101081:	89 c2                	mov    %eax,%edx
  101083:	ec                   	in     (%dx),%al
  101084:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101087:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10108b:	84 c0                	test   %al,%al
  10108d:	78 09                	js     101098 <lpt_putc_sub+0x38>
  10108f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101096:	7e d7                	jle    10106f <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101098:	8b 45 08             	mov    0x8(%ebp),%eax
  10109b:	0f b6 c0             	movzbl %al,%eax
  10109e:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010a4:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010a7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010ab:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010af:	ee                   	out    %al,(%dx)
  1010b0:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010b6:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010ba:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010be:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010c2:	ee                   	out    %al,(%dx)
  1010c3:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010c9:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  1010cd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010d1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010d5:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010d6:	90                   	nop
  1010d7:	c9                   	leave  
  1010d8:	c3                   	ret    

001010d9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010d9:	55                   	push   %ebp
  1010da:	89 e5                	mov    %esp,%ebp
  1010dc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010df:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010e3:	74 0d                	je     1010f2 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e8:	89 04 24             	mov    %eax,(%esp)
  1010eb:	e8 70 ff ff ff       	call   101060 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010f0:	eb 24                	jmp    101116 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010f2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f9:	e8 62 ff ff ff       	call   101060 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101105:	e8 56 ff ff ff       	call   101060 <lpt_putc_sub>
        lpt_putc_sub('\b');
  10110a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101111:	e8 4a ff ff ff       	call   101060 <lpt_putc_sub>
}
  101116:	90                   	nop
  101117:	c9                   	leave  
  101118:	c3                   	ret    

00101119 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101119:	55                   	push   %ebp
  10111a:	89 e5                	mov    %esp,%ebp
  10111c:	53                   	push   %ebx
  10111d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101120:	8b 45 08             	mov    0x8(%ebp),%eax
  101123:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101128:	85 c0                	test   %eax,%eax
  10112a:	75 07                	jne    101133 <cga_putc+0x1a>
        c |= 0x0700;
  10112c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101133:	8b 45 08             	mov    0x8(%ebp),%eax
  101136:	0f b6 c0             	movzbl %al,%eax
  101139:	83 f8 0a             	cmp    $0xa,%eax
  10113c:	74 55                	je     101193 <cga_putc+0x7a>
  10113e:	83 f8 0d             	cmp    $0xd,%eax
  101141:	74 63                	je     1011a6 <cga_putc+0x8d>
  101143:	83 f8 08             	cmp    $0x8,%eax
  101146:	0f 85 94 00 00 00    	jne    1011e0 <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  10114c:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101153:	85 c0                	test   %eax,%eax
  101155:	0f 84 af 00 00 00    	je     10120a <cga_putc+0xf1>
            crt_pos --;
  10115b:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101162:	48                   	dec    %eax
  101163:	0f b7 c0             	movzwl %ax,%eax
  101166:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10116c:	8b 45 08             	mov    0x8(%ebp),%eax
  10116f:	98                   	cwtl   
  101170:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101175:	98                   	cwtl   
  101176:	83 c8 20             	or     $0x20,%eax
  101179:	98                   	cwtl   
  10117a:	8b 15 40 b4 11 00    	mov    0x11b440,%edx
  101180:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  101187:	01 c9                	add    %ecx,%ecx
  101189:	01 ca                	add    %ecx,%edx
  10118b:	0f b7 c0             	movzwl %ax,%eax
  10118e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101191:	eb 77                	jmp    10120a <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101193:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10119a:	83 c0 50             	add    $0x50,%eax
  10119d:	0f b7 c0             	movzwl %ax,%eax
  1011a0:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011a6:	0f b7 1d 44 b4 11 00 	movzwl 0x11b444,%ebx
  1011ad:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  1011b4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011b9:	89 c8                	mov    %ecx,%eax
  1011bb:	f7 e2                	mul    %edx
  1011bd:	c1 ea 06             	shr    $0x6,%edx
  1011c0:	89 d0                	mov    %edx,%eax
  1011c2:	c1 e0 02             	shl    $0x2,%eax
  1011c5:	01 d0                	add    %edx,%eax
  1011c7:	c1 e0 04             	shl    $0x4,%eax
  1011ca:	29 c1                	sub    %eax,%ecx
  1011cc:	89 c8                	mov    %ecx,%eax
  1011ce:	0f b7 c0             	movzwl %ax,%eax
  1011d1:	29 c3                	sub    %eax,%ebx
  1011d3:	89 d8                	mov    %ebx,%eax
  1011d5:	0f b7 c0             	movzwl %ax,%eax
  1011d8:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
        break;
  1011de:	eb 2b                	jmp    10120b <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011e0:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  1011e6:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011ed:	8d 50 01             	lea    0x1(%eax),%edx
  1011f0:	0f b7 d2             	movzwl %dx,%edx
  1011f3:	66 89 15 44 b4 11 00 	mov    %dx,0x11b444
  1011fa:	01 c0                	add    %eax,%eax
  1011fc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  101202:	0f b7 c0             	movzwl %ax,%eax
  101205:	66 89 02             	mov    %ax,(%edx)
        break;
  101208:	eb 01                	jmp    10120b <cga_putc+0xf2>
        break;
  10120a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10120b:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101212:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101217:	76 5d                	jbe    101276 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101219:	a1 40 b4 11 00       	mov    0x11b440,%eax
  10121e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101224:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101229:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101230:	00 
  101231:	89 54 24 04          	mov    %edx,0x4(%esp)
  101235:	89 04 24             	mov    %eax,(%esp)
  101238:	e8 de 46 00 00       	call   10591b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10123d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101244:	eb 14                	jmp    10125a <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101246:	a1 40 b4 11 00       	mov    0x11b440,%eax
  10124b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10124e:	01 d2                	add    %edx,%edx
  101250:	01 d0                	add    %edx,%eax
  101252:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101257:	ff 45 f4             	incl   -0xc(%ebp)
  10125a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101261:	7e e3                	jle    101246 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  101263:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10126a:	83 e8 50             	sub    $0x50,%eax
  10126d:	0f b7 c0             	movzwl %ax,%eax
  101270:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101276:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  10127d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101281:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101285:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101289:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10128e:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101295:	c1 e8 08             	shr    $0x8,%eax
  101298:	0f b7 c0             	movzwl %ax,%eax
  10129b:	0f b6 c0             	movzbl %al,%eax
  10129e:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  1012a5:	42                   	inc    %edx
  1012a6:	0f b7 d2             	movzwl %dx,%edx
  1012a9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012ad:	88 45 e9             	mov    %al,-0x17(%ebp)
  1012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012b9:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012c0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012c4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012d0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012d1:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1012d8:	0f b6 c0             	movzbl %al,%eax
  1012db:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  1012e2:	42                   	inc    %edx
  1012e3:	0f b7 d2             	movzwl %dx,%edx
  1012e6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012ea:	88 45 f1             	mov    %al,-0xf(%ebp)
  1012ed:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012f1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012f5:	ee                   	out    %al,(%dx)
}
  1012f6:	90                   	nop
  1012f7:	83 c4 34             	add    $0x34,%esp
  1012fa:	5b                   	pop    %ebx
  1012fb:	5d                   	pop    %ebp
  1012fc:	c3                   	ret    

001012fd <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012fd:	55                   	push   %ebp
  1012fe:	89 e5                	mov    %esp,%ebp
  101300:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101303:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10130a:	eb 08                	jmp    101314 <serial_putc_sub+0x17>
        delay();
  10130c:	e8 3e fb ff ff       	call   100e4f <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101311:	ff 45 fc             	incl   -0x4(%ebp)
  101314:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10131a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10131e:	89 c2                	mov    %eax,%edx
  101320:	ec                   	in     (%dx),%al
  101321:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101324:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101328:	0f b6 c0             	movzbl %al,%eax
  10132b:	83 e0 20             	and    $0x20,%eax
  10132e:	85 c0                	test   %eax,%eax
  101330:	75 09                	jne    10133b <serial_putc_sub+0x3e>
  101332:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101339:	7e d1                	jle    10130c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10133b:	8b 45 08             	mov    0x8(%ebp),%eax
  10133e:	0f b6 c0             	movzbl %al,%eax
  101341:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101347:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10134a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10134e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101352:	ee                   	out    %al,(%dx)
}
  101353:	90                   	nop
  101354:	c9                   	leave  
  101355:	c3                   	ret    

00101356 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101356:	55                   	push   %ebp
  101357:	89 e5                	mov    %esp,%ebp
  101359:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10135c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101360:	74 0d                	je     10136f <serial_putc+0x19>
        serial_putc_sub(c);
  101362:	8b 45 08             	mov    0x8(%ebp),%eax
  101365:	89 04 24             	mov    %eax,(%esp)
  101368:	e8 90 ff ff ff       	call   1012fd <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10136d:	eb 24                	jmp    101393 <serial_putc+0x3d>
        serial_putc_sub('\b');
  10136f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101376:	e8 82 ff ff ff       	call   1012fd <serial_putc_sub>
        serial_putc_sub(' ');
  10137b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101382:	e8 76 ff ff ff       	call   1012fd <serial_putc_sub>
        serial_putc_sub('\b');
  101387:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10138e:	e8 6a ff ff ff       	call   1012fd <serial_putc_sub>
}
  101393:	90                   	nop
  101394:	c9                   	leave  
  101395:	c3                   	ret    

00101396 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101396:	55                   	push   %ebp
  101397:	89 e5                	mov    %esp,%ebp
  101399:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10139c:	eb 33                	jmp    1013d1 <cons_intr+0x3b>
        if (c != 0) {
  10139e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013a2:	74 2d                	je     1013d1 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013a4:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013a9:	8d 50 01             	lea    0x1(%eax),%edx
  1013ac:	89 15 64 b6 11 00    	mov    %edx,0x11b664
  1013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013b5:	88 90 60 b4 11 00    	mov    %dl,0x11b460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013bb:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013c0:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013c5:	75 0a                	jne    1013d1 <cons_intr+0x3b>
                cons.wpos = 0;
  1013c7:	c7 05 64 b6 11 00 00 	movl   $0x0,0x11b664
  1013ce:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1013d4:	ff d0                	call   *%eax
  1013d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013d9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013dd:	75 bf                	jne    10139e <cons_intr+0x8>
            }
        }
    }
}
  1013df:	90                   	nop
  1013e0:	c9                   	leave  
  1013e1:	c3                   	ret    

001013e2 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013e2:	55                   	push   %ebp
  1013e3:	89 e5                	mov    %esp,%ebp
  1013e5:	83 ec 10             	sub    $0x10,%esp
  1013e8:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ee:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013f2:	89 c2                	mov    %eax,%edx
  1013f4:	ec                   	in     (%dx),%al
  1013f5:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013f8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013fc:	0f b6 c0             	movzbl %al,%eax
  1013ff:	83 e0 01             	and    $0x1,%eax
  101402:	85 c0                	test   %eax,%eax
  101404:	75 07                	jne    10140d <serial_proc_data+0x2b>
        return -1;
  101406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10140b:	eb 2a                	jmp    101437 <serial_proc_data+0x55>
  10140d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101413:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101417:	89 c2                	mov    %eax,%edx
  101419:	ec                   	in     (%dx),%al
  10141a:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10141d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101421:	0f b6 c0             	movzbl %al,%eax
  101424:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101427:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10142b:	75 07                	jne    101434 <serial_proc_data+0x52>
        c = '\b';
  10142d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101434:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101437:	c9                   	leave  
  101438:	c3                   	ret    

00101439 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101439:	55                   	push   %ebp
  10143a:	89 e5                	mov    %esp,%ebp
  10143c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10143f:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101444:	85 c0                	test   %eax,%eax
  101446:	74 0c                	je     101454 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101448:	c7 04 24 e2 13 10 00 	movl   $0x1013e2,(%esp)
  10144f:	e8 42 ff ff ff       	call   101396 <cons_intr>
    }
}
  101454:	90                   	nop
  101455:	c9                   	leave  
  101456:	c3                   	ret    

00101457 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101457:	55                   	push   %ebp
  101458:	89 e5                	mov    %esp,%ebp
  10145a:	83 ec 38             	sub    $0x38,%esp
  10145d:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101466:	89 c2                	mov    %eax,%edx
  101468:	ec                   	in     (%dx),%al
  101469:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10146c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101470:	0f b6 c0             	movzbl %al,%eax
  101473:	83 e0 01             	and    $0x1,%eax
  101476:	85 c0                	test   %eax,%eax
  101478:	75 0a                	jne    101484 <kbd_proc_data+0x2d>
        return -1;
  10147a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10147f:	e9 55 01 00 00       	jmp    1015d9 <kbd_proc_data+0x182>
  101484:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10148a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10148d:	89 c2                	mov    %eax,%edx
  10148f:	ec                   	in     (%dx),%al
  101490:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101493:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101497:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10149a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10149e:	75 17                	jne    1014b7 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014a0:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014a5:	83 c8 40             	or     $0x40,%eax
  1014a8:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014ad:	b8 00 00 00 00       	mov    $0x0,%eax
  1014b2:	e9 22 01 00 00       	jmp    1015d9 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  1014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bb:	84 c0                	test   %al,%al
  1014bd:	79 45                	jns    101504 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014bf:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014c4:	83 e0 40             	and    $0x40,%eax
  1014c7:	85 c0                	test   %eax,%eax
  1014c9:	75 08                	jne    1014d3 <kbd_proc_data+0x7c>
  1014cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014cf:	24 7f                	and    $0x7f,%al
  1014d1:	eb 04                	jmp    1014d7 <kbd_proc_data+0x80>
  1014d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014da:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014de:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  1014e5:	0c 40                	or     $0x40,%al
  1014e7:	0f b6 c0             	movzbl %al,%eax
  1014ea:	f7 d0                	not    %eax
  1014ec:	89 c2                	mov    %eax,%edx
  1014ee:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014f3:	21 d0                	and    %edx,%eax
  1014f5:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ff:	e9 d5 00 00 00       	jmp    1015d9 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  101504:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101509:	83 e0 40             	and    $0x40,%eax
  10150c:	85 c0                	test   %eax,%eax
  10150e:	74 11                	je     101521 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101510:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101514:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101519:	83 e0 bf             	and    $0xffffffbf,%eax
  10151c:	a3 68 b6 11 00       	mov    %eax,0x11b668
    }

    shift |= shiftcode[data];
  101521:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101525:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  10152c:	0f b6 d0             	movzbl %al,%edx
  10152f:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101534:	09 d0                	or     %edx,%eax
  101536:	a3 68 b6 11 00       	mov    %eax,0x11b668
    shift ^= togglecode[data];
  10153b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10153f:	0f b6 80 40 81 11 00 	movzbl 0x118140(%eax),%eax
  101546:	0f b6 d0             	movzbl %al,%edx
  101549:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10154e:	31 d0                	xor    %edx,%eax
  101550:	a3 68 b6 11 00       	mov    %eax,0x11b668

    c = charcode[shift & (CTL | SHIFT)][data];
  101555:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10155a:	83 e0 03             	and    $0x3,%eax
  10155d:	8b 14 85 40 85 11 00 	mov    0x118540(,%eax,4),%edx
  101564:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101568:	01 d0                	add    %edx,%eax
  10156a:	0f b6 00             	movzbl (%eax),%eax
  10156d:	0f b6 c0             	movzbl %al,%eax
  101570:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101573:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101578:	83 e0 08             	and    $0x8,%eax
  10157b:	85 c0                	test   %eax,%eax
  10157d:	74 22                	je     1015a1 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10157f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101583:	7e 0c                	jle    101591 <kbd_proc_data+0x13a>
  101585:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101589:	7f 06                	jg     101591 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  10158b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10158f:	eb 10                	jmp    1015a1 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101591:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101595:	7e 0a                	jle    1015a1 <kbd_proc_data+0x14a>
  101597:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10159b:	7f 04                	jg     1015a1 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10159d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015a1:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1015a6:	f7 d0                	not    %eax
  1015a8:	83 e0 06             	and    $0x6,%eax
  1015ab:	85 c0                	test   %eax,%eax
  1015ad:	75 27                	jne    1015d6 <kbd_proc_data+0x17f>
  1015af:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015b6:	75 1e                	jne    1015d6 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  1015b8:	c7 04 24 15 64 10 00 	movl   $0x106415,(%esp)
  1015bf:	e8 de ec ff ff       	call   1002a2 <cprintf>
  1015c4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015ca:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ce:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015d2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015d5:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015d9:	c9                   	leave  
  1015da:	c3                   	ret    

001015db <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015db:	55                   	push   %ebp
  1015dc:	89 e5                	mov    %esp,%ebp
  1015de:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015e1:	c7 04 24 57 14 10 00 	movl   $0x101457,(%esp)
  1015e8:	e8 a9 fd ff ff       	call   101396 <cons_intr>
}
  1015ed:	90                   	nop
  1015ee:	c9                   	leave  
  1015ef:	c3                   	ret    

001015f0 <kbd_init>:

static void
kbd_init(void) {
  1015f0:	55                   	push   %ebp
  1015f1:	89 e5                	mov    %esp,%ebp
  1015f3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015f6:	e8 e0 ff ff ff       	call   1015db <kbd_intr>
    pic_enable(IRQ_KBD);
  1015fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101602:	e8 35 01 00 00       	call   10173c <pic_enable>
}
  101607:	90                   	nop
  101608:	c9                   	leave  
  101609:	c3                   	ret    

0010160a <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10160a:	55                   	push   %ebp
  10160b:	89 e5                	mov    %esp,%ebp
  10160d:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101610:	e8 83 f8 ff ff       	call   100e98 <cga_init>
    serial_init();
  101615:	e8 62 f9 ff ff       	call   100f7c <serial_init>
    kbd_init();
  10161a:	e8 d1 ff ff ff       	call   1015f0 <kbd_init>
    if (!serial_exists) {
  10161f:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101624:	85 c0                	test   %eax,%eax
  101626:	75 0c                	jne    101634 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101628:	c7 04 24 21 64 10 00 	movl   $0x106421,(%esp)
  10162f:	e8 6e ec ff ff       	call   1002a2 <cprintf>
    }
}
  101634:	90                   	nop
  101635:	c9                   	leave  
  101636:	c3                   	ret    

00101637 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101637:	55                   	push   %ebp
  101638:	89 e5                	mov    %esp,%ebp
  10163a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10163d:	e8 cf f7 ff ff       	call   100e11 <__intr_save>
  101642:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101645:	8b 45 08             	mov    0x8(%ebp),%eax
  101648:	89 04 24             	mov    %eax,(%esp)
  10164b:	e8 89 fa ff ff       	call   1010d9 <lpt_putc>
        cga_putc(c);
  101650:	8b 45 08             	mov    0x8(%ebp),%eax
  101653:	89 04 24             	mov    %eax,(%esp)
  101656:	e8 be fa ff ff       	call   101119 <cga_putc>
        serial_putc(c);
  10165b:	8b 45 08             	mov    0x8(%ebp),%eax
  10165e:	89 04 24             	mov    %eax,(%esp)
  101661:	e8 f0 fc ff ff       	call   101356 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101669:	89 04 24             	mov    %eax,(%esp)
  10166c:	e8 ca f7 ff ff       	call   100e3b <__intr_restore>
}
  101671:	90                   	nop
  101672:	c9                   	leave  
  101673:	c3                   	ret    

00101674 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101674:	55                   	push   %ebp
  101675:	89 e5                	mov    %esp,%ebp
  101677:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10167a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101681:	e8 8b f7 ff ff       	call   100e11 <__intr_save>
  101686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101689:	e8 ab fd ff ff       	call   101439 <serial_intr>
        kbd_intr();
  10168e:	e8 48 ff ff ff       	call   1015db <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101693:	8b 15 60 b6 11 00    	mov    0x11b660,%edx
  101699:	a1 64 b6 11 00       	mov    0x11b664,%eax
  10169e:	39 c2                	cmp    %eax,%edx
  1016a0:	74 31                	je     1016d3 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016a2:	a1 60 b6 11 00       	mov    0x11b660,%eax
  1016a7:	8d 50 01             	lea    0x1(%eax),%edx
  1016aa:	89 15 60 b6 11 00    	mov    %edx,0x11b660
  1016b0:	0f b6 80 60 b4 11 00 	movzbl 0x11b460(%eax),%eax
  1016b7:	0f b6 c0             	movzbl %al,%eax
  1016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016bd:	a1 60 b6 11 00       	mov    0x11b660,%eax
  1016c2:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016c7:	75 0a                	jne    1016d3 <cons_getc+0x5f>
                cons.rpos = 0;
  1016c9:	c7 05 60 b6 11 00 00 	movl   $0x0,0x11b660
  1016d0:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016d6:	89 04 24             	mov    %eax,(%esp)
  1016d9:	e8 5d f7 ff ff       	call   100e3b <__intr_restore>
    return c;
  1016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016e1:	c9                   	leave  
  1016e2:	c3                   	ret    

001016e3 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016e3:	55                   	push   %ebp
  1016e4:	89 e5                	mov    %esp,%ebp
  1016e6:	83 ec 14             	sub    $0x14,%esp
  1016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ec:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016f3:	66 a3 50 85 11 00    	mov    %ax,0x118550
    if (did_init) {
  1016f9:	a1 6c b6 11 00       	mov    0x11b66c,%eax
  1016fe:	85 c0                	test   %eax,%eax
  101700:	74 37                	je     101739 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101702:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101705:	0f b6 c0             	movzbl %al,%eax
  101708:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10170e:	88 45 f9             	mov    %al,-0x7(%ebp)
  101711:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101715:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101719:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10171a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10171e:	c1 e8 08             	shr    $0x8,%eax
  101721:	0f b7 c0             	movzwl %ax,%eax
  101724:	0f b6 c0             	movzbl %al,%eax
  101727:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10172d:	88 45 fd             	mov    %al,-0x3(%ebp)
  101730:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101734:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101738:	ee                   	out    %al,(%dx)
    }
}
  101739:	90                   	nop
  10173a:	c9                   	leave  
  10173b:	c3                   	ret    

0010173c <pic_enable>:

void
pic_enable(unsigned int irq) {
  10173c:	55                   	push   %ebp
  10173d:	89 e5                	mov    %esp,%ebp
  10173f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101742:	8b 45 08             	mov    0x8(%ebp),%eax
  101745:	ba 01 00 00 00       	mov    $0x1,%edx
  10174a:	88 c1                	mov    %al,%cl
  10174c:	d3 e2                	shl    %cl,%edx
  10174e:	89 d0                	mov    %edx,%eax
  101750:	98                   	cwtl   
  101751:	f7 d0                	not    %eax
  101753:	0f bf d0             	movswl %ax,%edx
  101756:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10175d:	98                   	cwtl   
  10175e:	21 d0                	and    %edx,%eax
  101760:	98                   	cwtl   
  101761:	0f b7 c0             	movzwl %ax,%eax
  101764:	89 04 24             	mov    %eax,(%esp)
  101767:	e8 77 ff ff ff       	call   1016e3 <pic_setmask>
}
  10176c:	90                   	nop
  10176d:	c9                   	leave  
  10176e:	c3                   	ret    

0010176f <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10176f:	55                   	push   %ebp
  101770:	89 e5                	mov    %esp,%ebp
  101772:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101775:	c7 05 6c b6 11 00 01 	movl   $0x1,0x11b66c
  10177c:	00 00 00 
  10177f:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101785:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  101789:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  10178d:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101791:	ee                   	out    %al,(%dx)
  101792:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101798:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  10179c:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017a0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017a4:	ee                   	out    %al,(%dx)
  1017a5:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017ab:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  1017af:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017b3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017b7:	ee                   	out    %al,(%dx)
  1017b8:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017be:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  1017c2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017c6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017ca:	ee                   	out    %al,(%dx)
  1017cb:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017d1:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  1017d5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017d9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017dd:	ee                   	out    %al,(%dx)
  1017de:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017e4:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  1017e8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017ec:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017f0:	ee                   	out    %al,(%dx)
  1017f1:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017f7:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  1017fb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017ff:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101803:	ee                   	out    %al,(%dx)
  101804:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  10180a:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  10180e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101812:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101816:	ee                   	out    %al,(%dx)
  101817:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  10181d:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  101821:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101825:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101829:	ee                   	out    %al,(%dx)
  10182a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101830:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  101834:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101838:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10183c:	ee                   	out    %al,(%dx)
  10183d:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101843:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  101847:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10184b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10184f:	ee                   	out    %al,(%dx)
  101850:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101856:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  10185a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10185e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101862:	ee                   	out    %al,(%dx)
  101863:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101869:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  10186d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101871:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101875:	ee                   	out    %al,(%dx)
  101876:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10187c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  101880:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101884:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101888:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101889:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  101890:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101895:	74 0f                	je     1018a6 <pic_init+0x137>
        pic_setmask(irq_mask);
  101897:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10189e:	89 04 24             	mov    %eax,(%esp)
  1018a1:	e8 3d fe ff ff       	call   1016e3 <pic_setmask>
    }
}
  1018a6:	90                   	nop
  1018a7:	c9                   	leave  
  1018a8:	c3                   	ret    

001018a9 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt 打开中断 */
void
intr_enable(void) {
  1018a9:	55                   	push   %ebp
  1018aa:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  1018ac:	fb                   	sti    
    sti();
}
  1018ad:	90                   	nop
  1018ae:	5d                   	pop    %ebp
  1018af:	c3                   	ret    

001018b0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1018b0:	55                   	push   %ebp
  1018b1:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  1018b3:	fa                   	cli    
    cli();
}
  1018b4:	90                   	nop
  1018b5:	5d                   	pop    %ebp
  1018b6:	c3                   	ret    

001018b7 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1018b7:	55                   	push   %ebp
  1018b8:	89 e5                	mov    %esp,%ebp
  1018ba:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018bd:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018c4:	00 
  1018c5:	c7 04 24 40 64 10 00 	movl   $0x106440,(%esp)
  1018cc:	e8 d1 e9 ff ff       	call   1002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018d1:	90                   	nop
  1018d2:	c9                   	leave  
  1018d3:	c3                   	ret    

001018d4 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018d4:	55                   	push   %ebp
  1018d5:	89 e5                	mov    %esp,%ebp
  1018d7:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uint32_t __vectors[];
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  1018da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018e1:	e9 c4 00 00 00       	jmp    1019aa <idt_init+0xd6>
    {
      SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  1018e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e9:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  1018f0:	0f b7 d0             	movzwl %ax,%edx
  1018f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f6:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  1018fd:	00 
  1018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101901:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  101908:	00 08 00 
  10190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190e:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  101915:	00 
  101916:	80 e2 e0             	and    $0xe0,%dl
  101919:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101920:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101923:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10192a:	00 
  10192b:	80 e2 1f             	and    $0x1f,%dl
  10192e:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101938:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10193f:	00 
  101940:	80 e2 f0             	and    $0xf0,%dl
  101943:	80 ca 0e             	or     $0xe,%dl
  101946:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101950:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101957:	00 
  101958:	80 e2 ef             	and    $0xef,%dl
  10195b:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101962:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101965:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10196c:	00 
  10196d:	80 e2 9f             	and    $0x9f,%dl
  101970:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197a:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101981:	00 
  101982:	80 ca 80             	or     $0x80,%dl
  101985:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198f:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101996:	c1 e8 10             	shr    $0x10,%eax
  101999:	0f b7 d0             	movzwl %ax,%edx
  10199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199f:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  1019a6:	00 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  1019a7:	ff 45 fc             	incl   -0x4(%ebp)
  1019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019b2:	0f 86 2e ff ff ff    	jbe    1018e6 <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019b8:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  1019bd:	0f b7 c0             	movzwl %ax,%eax
  1019c0:	66 a3 48 ba 11 00    	mov    %ax,0x11ba48
  1019c6:	66 c7 05 4a ba 11 00 	movw   $0x8,0x11ba4a
  1019cd:	08 00 
  1019cf:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  1019d6:	24 e0                	and    $0xe0,%al
  1019d8:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  1019dd:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  1019e4:	24 1f                	and    $0x1f,%al
  1019e6:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  1019eb:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  1019f2:	24 f0                	and    $0xf0,%al
  1019f4:	0c 0e                	or     $0xe,%al
  1019f6:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  1019fb:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a02:	24 ef                	and    $0xef,%al
  101a04:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a09:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a10:	0c 60                	or     $0x60,%al
  101a12:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a17:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a1e:	0c 80                	or     $0x80,%al
  101a20:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a25:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  101a2a:	c1 e8 10             	shr    $0x10,%eax
  101a2d:	0f b7 c0             	movzwl %ax,%eax
  101a30:	66 a3 4e ba 11 00    	mov    %ax,0x11ba4e
  101a36:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a40:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101a43:	90                   	nop
  101a44:	c9                   	leave  
  101a45:	c3                   	ret    

00101a46 <trapname>:

static const char *
trapname(int trapno) {
  101a46:	55                   	push   %ebp
  101a47:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a49:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4c:	83 f8 13             	cmp    $0x13,%eax
  101a4f:	77 0c                	ja     101a5d <trapname+0x17>
        return excnames[trapno];
  101a51:	8b 45 08             	mov    0x8(%ebp),%eax
  101a54:	8b 04 85 a0 67 10 00 	mov    0x1067a0(,%eax,4),%eax
  101a5b:	eb 18                	jmp    101a75 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a5d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a61:	7e 0d                	jle    101a70 <trapname+0x2a>
  101a63:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a67:	7f 07                	jg     101a70 <trapname+0x2a>
        return "Hardware Interrupt";
  101a69:	b8 4a 64 10 00       	mov    $0x10644a,%eax
  101a6e:	eb 05                	jmp    101a75 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a70:	b8 5d 64 10 00       	mov    $0x10645d,%eax
}
  101a75:	5d                   	pop    %ebp
  101a76:	c3                   	ret    

00101a77 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a77:	55                   	push   %ebp
  101a78:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a81:	83 f8 08             	cmp    $0x8,%eax
  101a84:	0f 94 c0             	sete   %al
  101a87:	0f b6 c0             	movzbl %al,%eax
}
  101a8a:	5d                   	pop    %ebp
  101a8b:	c3                   	ret    

00101a8c <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a8c:	55                   	push   %ebp
  101a8d:	89 e5                	mov    %esp,%ebp
  101a8f:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a92:	8b 45 08             	mov    0x8(%ebp),%eax
  101a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a99:	c7 04 24 9e 64 10 00 	movl   $0x10649e,(%esp)
  101aa0:	e8 fd e7 ff ff       	call   1002a2 <cprintf>
    print_regs(&tf->tf_regs);
  101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa8:	89 04 24             	mov    %eax,(%esp)
  101aab:	e8 8f 01 00 00       	call   101c3f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abb:	c7 04 24 af 64 10 00 	movl   $0x1064af,(%esp)
  101ac2:	e8 db e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aca:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad2:	c7 04 24 c2 64 10 00 	movl   $0x1064c2,(%esp)
  101ad9:	e8 c4 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ade:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae1:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae9:	c7 04 24 d5 64 10 00 	movl   $0x1064d5,(%esp)
  101af0:	e8 ad e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101af5:	8b 45 08             	mov    0x8(%ebp),%eax
  101af8:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b00:	c7 04 24 e8 64 10 00 	movl   $0x1064e8,(%esp)
  101b07:	e8 96 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0f:	8b 40 30             	mov    0x30(%eax),%eax
  101b12:	89 04 24             	mov    %eax,(%esp)
  101b15:	e8 2c ff ff ff       	call   101a46 <trapname>
  101b1a:	89 c2                	mov    %eax,%edx
  101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1f:	8b 40 30             	mov    0x30(%eax),%eax
  101b22:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b26:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2a:	c7 04 24 fb 64 10 00 	movl   $0x1064fb,(%esp)
  101b31:	e8 6c e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b36:	8b 45 08             	mov    0x8(%ebp),%eax
  101b39:	8b 40 34             	mov    0x34(%eax),%eax
  101b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b40:	c7 04 24 0d 65 10 00 	movl   $0x10650d,(%esp)
  101b47:	e8 56 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4f:	8b 40 38             	mov    0x38(%eax),%eax
  101b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b56:	c7 04 24 1c 65 10 00 	movl   $0x10651c,(%esp)
  101b5d:	e8 40 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b62:	8b 45 08             	mov    0x8(%ebp),%eax
  101b65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6d:	c7 04 24 2b 65 10 00 	movl   $0x10652b,(%esp)
  101b74:	e8 29 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b79:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7c:	8b 40 40             	mov    0x40(%eax),%eax
  101b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b83:	c7 04 24 3e 65 10 00 	movl   $0x10653e,(%esp)
  101b8a:	e8 13 e7 ff ff       	call   1002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b96:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b9d:	eb 3d                	jmp    101bdc <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba2:	8b 50 40             	mov    0x40(%eax),%edx
  101ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ba8:	21 d0                	and    %edx,%eax
  101baa:	85 c0                	test   %eax,%eax
  101bac:	74 28                	je     101bd6 <print_trapframe+0x14a>
  101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bb1:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101bb8:	85 c0                	test   %eax,%eax
  101bba:	74 1a                	je     101bd6 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bbf:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 4d 65 10 00 	movl   $0x10654d,(%esp)
  101bd1:	e8 cc e6 ff ff       	call   1002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bd6:	ff 45 f4             	incl   -0xc(%ebp)
  101bd9:	d1 65 f0             	shll   -0x10(%ebp)
  101bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bdf:	83 f8 17             	cmp    $0x17,%eax
  101be2:	76 bb                	jbe    101b9f <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101be4:	8b 45 08             	mov    0x8(%ebp),%eax
  101be7:	8b 40 40             	mov    0x40(%eax),%eax
  101bea:	c1 e8 0c             	shr    $0xc,%eax
  101bed:	83 e0 03             	and    $0x3,%eax
  101bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf4:	c7 04 24 51 65 10 00 	movl   $0x106551,(%esp)
  101bfb:	e8 a2 e6 ff ff       	call   1002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c00:	8b 45 08             	mov    0x8(%ebp),%eax
  101c03:	89 04 24             	mov    %eax,(%esp)
  101c06:	e8 6c fe ff ff       	call   101a77 <trap_in_kernel>
  101c0b:	85 c0                	test   %eax,%eax
  101c0d:	75 2d                	jne    101c3c <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c12:	8b 40 44             	mov    0x44(%eax),%eax
  101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c19:	c7 04 24 5a 65 10 00 	movl   $0x10655a,(%esp)
  101c20:	e8 7d e6 ff ff       	call   1002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 69 65 10 00 	movl   $0x106569,(%esp)
  101c37:	e8 66 e6 ff ff       	call   1002a2 <cprintf>
    }
}
  101c3c:	90                   	nop
  101c3d:	c9                   	leave  
  101c3e:	c3                   	ret    

00101c3f <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c3f:	55                   	push   %ebp
  101c40:	89 e5                	mov    %esp,%ebp
  101c42:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c45:	8b 45 08             	mov    0x8(%ebp),%eax
  101c48:	8b 00                	mov    (%eax),%eax
  101c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4e:	c7 04 24 7c 65 10 00 	movl   $0x10657c,(%esp)
  101c55:	e8 48 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5d:	8b 40 04             	mov    0x4(%eax),%eax
  101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c64:	c7 04 24 8b 65 10 00 	movl   $0x10658b,(%esp)
  101c6b:	e8 32 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c70:	8b 45 08             	mov    0x8(%ebp),%eax
  101c73:	8b 40 08             	mov    0x8(%eax),%eax
  101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7a:	c7 04 24 9a 65 10 00 	movl   $0x10659a,(%esp)
  101c81:	e8 1c e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c86:	8b 45 08             	mov    0x8(%ebp),%eax
  101c89:	8b 40 0c             	mov    0xc(%eax),%eax
  101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c90:	c7 04 24 a9 65 10 00 	movl   $0x1065a9,(%esp)
  101c97:	e8 06 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9f:	8b 40 10             	mov    0x10(%eax),%eax
  101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca6:	c7 04 24 b8 65 10 00 	movl   $0x1065b8,(%esp)
  101cad:	e8 f0 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb5:	8b 40 14             	mov    0x14(%eax),%eax
  101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbc:	c7 04 24 c7 65 10 00 	movl   $0x1065c7,(%esp)
  101cc3:	e8 da e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccb:	8b 40 18             	mov    0x18(%eax),%eax
  101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd2:	c7 04 24 d6 65 10 00 	movl   $0x1065d6,(%esp)
  101cd9:	e8 c4 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cde:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce1:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce8:	c7 04 24 e5 65 10 00 	movl   $0x1065e5,(%esp)
  101cef:	e8 ae e5 ff ff       	call   1002a2 <cprintf>
}
  101cf4:	90                   	nop
  101cf5:	c9                   	leave  
  101cf6:	c3                   	ret    

00101cf7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cf7:	55                   	push   %ebp
  101cf8:	89 e5                	mov    %esp,%ebp
  101cfa:	57                   	push   %edi
  101cfb:	56                   	push   %esi
  101cfc:	53                   	push   %ebx
  101cfd:	83 ec 7c             	sub    $0x7c,%esp
    char c;

    switch (tf->tf_trapno) {
  101d00:	8b 45 08             	mov    0x8(%ebp),%eax
  101d03:	8b 40 30             	mov    0x30(%eax),%eax
  101d06:	83 f8 2f             	cmp    $0x2f,%eax
  101d09:	77 21                	ja     101d2c <trap_dispatch+0x35>
  101d0b:	83 f8 2e             	cmp    $0x2e,%eax
  101d0e:	0f 83 38 02 00 00    	jae    101f4c <trap_dispatch+0x255>
  101d14:	83 f8 21             	cmp    $0x21,%eax
  101d17:	0f 84 95 00 00 00    	je     101db2 <trap_dispatch+0xbb>
  101d1d:	83 f8 24             	cmp    $0x24,%eax
  101d20:	74 67                	je     101d89 <trap_dispatch+0x92>
  101d22:	83 f8 20             	cmp    $0x20,%eax
  101d25:	74 1c                	je     101d43 <trap_dispatch+0x4c>
  101d27:	e9 eb 01 00 00       	jmp    101f17 <trap_dispatch+0x220>
  101d2c:	83 f8 78             	cmp    $0x78,%eax
  101d2f:	0f 84 a6 00 00 00    	je     101ddb <trap_dispatch+0xe4>
  101d35:	83 f8 79             	cmp    $0x79,%eax
  101d38:	0f 84 63 01 00 00    	je     101ea1 <trap_dispatch+0x1aa>
  101d3e:	e9 d4 01 00 00       	jmp    101f17 <trap_dispatch+0x220>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101d43:	a1 0c bf 11 00       	mov    0x11bf0c,%eax
  101d48:	40                   	inc    %eax
  101d49:	a3 0c bf 11 00       	mov    %eax,0x11bf0c
        if(ticks % TICK_NUM == 0 )
  101d4e:	8b 0d 0c bf 11 00    	mov    0x11bf0c,%ecx
  101d54:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d59:	89 c8                	mov    %ecx,%eax
  101d5b:	f7 e2                	mul    %edx
  101d5d:	c1 ea 05             	shr    $0x5,%edx
  101d60:	89 d0                	mov    %edx,%eax
  101d62:	c1 e0 02             	shl    $0x2,%eax
  101d65:	01 d0                	add    %edx,%eax
  101d67:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d6e:	01 d0                	add    %edx,%eax
  101d70:	c1 e0 02             	shl    $0x2,%eax
  101d73:	29 c1                	sub    %eax,%ecx
  101d75:	89 ca                	mov    %ecx,%edx
  101d77:	85 d2                	test   %edx,%edx
  101d79:	0f 85 d0 01 00 00    	jne    101f4f <trap_dispatch+0x258>
        {
          print_ticks();
  101d7f:	e8 33 fb ff ff       	call   1018b7 <print_ticks>
        }
        break;
  101d84:	e9 c6 01 00 00       	jmp    101f4f <trap_dispatch+0x258>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d89:	e8 e6 f8 ff ff       	call   101674 <cons_getc>
  101d8e:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d91:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101d95:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101d99:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da1:	c7 04 24 f4 65 10 00 	movl   $0x1065f4,(%esp)
  101da8:	e8 f5 e4 ff ff       	call   1002a2 <cprintf>
        break;
  101dad:	e9 a4 01 00 00       	jmp    101f56 <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101db2:	e8 bd f8 ff ff       	call   101674 <cons_getc>
  101db7:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101dba:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101dbe:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dca:	c7 04 24 06 66 10 00 	movl   $0x106606,(%esp)
  101dd1:	e8 cc e4 ff ff       	call   1002a2 <cprintf>
        break;
  101dd6:	e9 7b 01 00 00       	jmp    101f56 <trap_dispatch+0x25f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
      if (tf->tf_cs!=USER_CS)
  101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dde:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101de2:	83 f8 1b             	cmp    $0x1b,%eax
  101de5:	0f 84 67 01 00 00    	je     101f52 <trap_dispatch+0x25b>
      {
        struct trapframe temp1 = *tf;//保留寄存器值
  101deb:	8b 55 08             	mov    0x8(%ebp),%edx
  101dee:	8d 45 97             	lea    -0x69(%ebp),%eax
  101df1:	bb 4c 00 00 00       	mov    $0x4c,%ebx
  101df6:	89 c1                	mov    %eax,%ecx
  101df8:	83 e1 01             	and    $0x1,%ecx
  101dfb:	85 c9                	test   %ecx,%ecx
  101dfd:	74 0c                	je     101e0b <trap_dispatch+0x114>
  101dff:	0f b6 0a             	movzbl (%edx),%ecx
  101e02:	88 08                	mov    %cl,(%eax)
  101e04:	8d 40 01             	lea    0x1(%eax),%eax
  101e07:	8d 52 01             	lea    0x1(%edx),%edx
  101e0a:	4b                   	dec    %ebx
  101e0b:	89 c1                	mov    %eax,%ecx
  101e0d:	83 e1 02             	and    $0x2,%ecx
  101e10:	85 c9                	test   %ecx,%ecx
  101e12:	74 0f                	je     101e23 <trap_dispatch+0x12c>
  101e14:	0f b7 0a             	movzwl (%edx),%ecx
  101e17:	66 89 08             	mov    %cx,(%eax)
  101e1a:	8d 40 02             	lea    0x2(%eax),%eax
  101e1d:	8d 52 02             	lea    0x2(%edx),%edx
  101e20:	83 eb 02             	sub    $0x2,%ebx
  101e23:	89 df                	mov    %ebx,%edi
  101e25:	83 e7 fc             	and    $0xfffffffc,%edi
  101e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  101e2d:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
  101e30:	89 34 08             	mov    %esi,(%eax,%ecx,1)
  101e33:	83 c1 04             	add    $0x4,%ecx
  101e36:	39 f9                	cmp    %edi,%ecx
  101e38:	72 f3                	jb     101e2d <trap_dispatch+0x136>
  101e3a:	01 c8                	add    %ecx,%eax
  101e3c:	01 ca                	add    %ecx,%edx
  101e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  101e43:	89 de                	mov    %ebx,%esi
  101e45:	83 e6 02             	and    $0x2,%esi
  101e48:	85 f6                	test   %esi,%esi
  101e4a:	74 0b                	je     101e57 <trap_dispatch+0x160>
  101e4c:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
  101e50:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
  101e54:	83 c1 02             	add    $0x2,%ecx
  101e57:	83 e3 01             	and    $0x1,%ebx
  101e5a:	85 db                	test   %ebx,%ebx
  101e5c:	74 07                	je     101e65 <trap_dispatch+0x16e>
  101e5e:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
  101e62:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        temp1.tf_cs = USER_CS;
  101e65:	66 c7 45 d3 1b 00    	movw   $0x1b,-0x2d(%ebp)
        temp1.tf_es = USER_DS;
  101e6b:	66 c7 45 bf 23 00    	movw   $0x23,-0x41(%ebp)
        temp1.tf_ds=USER_DS;
  101e71:	66 c7 45 c3 23 00    	movw   $0x23,-0x3d(%ebp)
        temp1.tf_ss = USER_DS;
  101e77:	66 c7 45 df 23 00    	movw   $0x23,-0x21(%ebp)
        temp1.tf_esp=(uint32_t)tf+sizeof(struct trapframe) -8;
  101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e80:	83 c0 44             	add    $0x44,%eax
  101e83:	89 45 db             	mov    %eax,-0x25(%ebp)

        temp1.tf_eflags |=FL_IOPL_MASK;
  101e86:	8b 45 d7             	mov    -0x29(%ebp),%eax
  101e89:	0d 00 30 00 00       	or     $0x3000,%eax
  101e8e:	89 45 d7             	mov    %eax,-0x29(%ebp)

        *((uint32_t *)tf -1) = (uint32_t) &temp1;
  101e91:	8b 45 08             	mov    0x8(%ebp),%eax
  101e94:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e97:	8d 45 97             	lea    -0x69(%ebp),%eax
  101e9a:	89 02                	mov    %eax,(%edx)
      }
      break;
  101e9c:	e9 b1 00 00 00       	jmp    101f52 <trap_dispatch+0x25b>
    case T_SWITCH_TOK:
    if (tf->tf_cs != KERNEL_CS) {
  101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ea8:	83 f8 08             	cmp    $0x8,%eax
  101eab:	0f 84 a4 00 00 00    	je     101f55 <trap_dispatch+0x25e>
        tf->tf_cs = KERNEL_CS;
  101eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb4:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  101eba:	8b 45 08             	mov    0x8(%ebp),%eax
  101ebd:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec6:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101eca:	8b 45 08             	mov    0x8(%ebp),%eax
  101ecd:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed4:	8b 40 40             	mov    0x40(%eax),%eax
  101ed7:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101edc:	89 c2                	mov    %eax,%edx
  101ede:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee1:	89 50 40             	mov    %edx,0x40(%eax)
        struct trapframe*  temp2 = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee7:	8b 40 44             	mov    0x44(%eax),%eax
  101eea:	83 e8 44             	sub    $0x44,%eax
  101eed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        memmove(temp2, tf, sizeof(struct trapframe) - 8);
  101ef0:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101ef7:	00 
  101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  101efb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101f02:	89 04 24             	mov    %eax,(%esp)
  101f05:	e8 11 3a 00 00       	call   10591b <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)temp2;
  101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f0d:	8d 50 fc             	lea    -0x4(%eax),%edx
  101f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101f13:	89 02                	mov    %eax,(%edx)
    }
        break;
  101f15:	eb 3e                	jmp    101f55 <trap_dispatch+0x25e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f17:	8b 45 08             	mov    0x8(%ebp),%eax
  101f1a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f1e:	83 e0 03             	and    $0x3,%eax
  101f21:	85 c0                	test   %eax,%eax
  101f23:	75 31                	jne    101f56 <trap_dispatch+0x25f>
            print_trapframe(tf);
  101f25:	8b 45 08             	mov    0x8(%ebp),%eax
  101f28:	89 04 24             	mov    %eax,(%esp)
  101f2b:	e8 5c fb ff ff       	call   101a8c <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f30:	c7 44 24 08 15 66 10 	movl   $0x106615,0x8(%esp)
  101f37:	00 
  101f38:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  101f3f:	00 
  101f40:	c7 04 24 31 66 10 00 	movl   $0x106631,(%esp)
  101f47:	e8 ad e4 ff ff       	call   1003f9 <__panic>
        break;
  101f4c:	90                   	nop
  101f4d:	eb 07                	jmp    101f56 <trap_dispatch+0x25f>
        break;
  101f4f:	90                   	nop
  101f50:	eb 04                	jmp    101f56 <trap_dispatch+0x25f>
      break;
  101f52:	90                   	nop
  101f53:	eb 01                	jmp    101f56 <trap_dispatch+0x25f>
        break;
  101f55:	90                   	nop
        }
    }
}
  101f56:	90                   	nop
  101f57:	83 c4 7c             	add    $0x7c,%esp
  101f5a:	5b                   	pop    %ebx
  101f5b:	5e                   	pop    %esi
  101f5c:	5f                   	pop    %edi
  101f5d:	5d                   	pop    %ebp
  101f5e:	c3                   	ret    

00101f5f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f5f:	55                   	push   %ebp
  101f60:	89 e5                	mov    %esp,%ebp
  101f62:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f65:	8b 45 08             	mov    0x8(%ebp),%eax
  101f68:	89 04 24             	mov    %eax,(%esp)
  101f6b:	e8 87 fd ff ff       	call   101cf7 <trap_dispatch>
}
  101f70:	90                   	nop
  101f71:	c9                   	leave  
  101f72:	c3                   	ret    

00101f73 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f73:	6a 00                	push   $0x0
  pushl $0
  101f75:	6a 00                	push   $0x0
  jmp __alltraps
  101f77:	e9 69 0a 00 00       	jmp    1029e5 <__alltraps>

00101f7c <vector1>:
.globl vector1
vector1:
  pushl $0
  101f7c:	6a 00                	push   $0x0
  pushl $1
  101f7e:	6a 01                	push   $0x1
  jmp __alltraps
  101f80:	e9 60 0a 00 00       	jmp    1029e5 <__alltraps>

00101f85 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f85:	6a 00                	push   $0x0
  pushl $2
  101f87:	6a 02                	push   $0x2
  jmp __alltraps
  101f89:	e9 57 0a 00 00       	jmp    1029e5 <__alltraps>

00101f8e <vector3>:
.globl vector3
vector3:
  pushl $0
  101f8e:	6a 00                	push   $0x0
  pushl $3
  101f90:	6a 03                	push   $0x3
  jmp __alltraps
  101f92:	e9 4e 0a 00 00       	jmp    1029e5 <__alltraps>

00101f97 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f97:	6a 00                	push   $0x0
  pushl $4
  101f99:	6a 04                	push   $0x4
  jmp __alltraps
  101f9b:	e9 45 0a 00 00       	jmp    1029e5 <__alltraps>

00101fa0 <vector5>:
.globl vector5
vector5:
  pushl $0
  101fa0:	6a 00                	push   $0x0
  pushl $5
  101fa2:	6a 05                	push   $0x5
  jmp __alltraps
  101fa4:	e9 3c 0a 00 00       	jmp    1029e5 <__alltraps>

00101fa9 <vector6>:
.globl vector6
vector6:
  pushl $0
  101fa9:	6a 00                	push   $0x0
  pushl $6
  101fab:	6a 06                	push   $0x6
  jmp __alltraps
  101fad:	e9 33 0a 00 00       	jmp    1029e5 <__alltraps>

00101fb2 <vector7>:
.globl vector7
vector7:
  pushl $0
  101fb2:	6a 00                	push   $0x0
  pushl $7
  101fb4:	6a 07                	push   $0x7
  jmp __alltraps
  101fb6:	e9 2a 0a 00 00       	jmp    1029e5 <__alltraps>

00101fbb <vector8>:
.globl vector8
vector8:
  pushl $8
  101fbb:	6a 08                	push   $0x8
  jmp __alltraps
  101fbd:	e9 23 0a 00 00       	jmp    1029e5 <__alltraps>

00101fc2 <vector9>:
.globl vector9
vector9:
  pushl $0
  101fc2:	6a 00                	push   $0x0
  pushl $9
  101fc4:	6a 09                	push   $0x9
  jmp __alltraps
  101fc6:	e9 1a 0a 00 00       	jmp    1029e5 <__alltraps>

00101fcb <vector10>:
.globl vector10
vector10:
  pushl $10
  101fcb:	6a 0a                	push   $0xa
  jmp __alltraps
  101fcd:	e9 13 0a 00 00       	jmp    1029e5 <__alltraps>

00101fd2 <vector11>:
.globl vector11
vector11:
  pushl $11
  101fd2:	6a 0b                	push   $0xb
  jmp __alltraps
  101fd4:	e9 0c 0a 00 00       	jmp    1029e5 <__alltraps>

00101fd9 <vector12>:
.globl vector12
vector12:
  pushl $12
  101fd9:	6a 0c                	push   $0xc
  jmp __alltraps
  101fdb:	e9 05 0a 00 00       	jmp    1029e5 <__alltraps>

00101fe0 <vector13>:
.globl vector13
vector13:
  pushl $13
  101fe0:	6a 0d                	push   $0xd
  jmp __alltraps
  101fe2:	e9 fe 09 00 00       	jmp    1029e5 <__alltraps>

00101fe7 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fe7:	6a 0e                	push   $0xe
  jmp __alltraps
  101fe9:	e9 f7 09 00 00       	jmp    1029e5 <__alltraps>

00101fee <vector15>:
.globl vector15
vector15:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $15
  101ff0:	6a 0f                	push   $0xf
  jmp __alltraps
  101ff2:	e9 ee 09 00 00       	jmp    1029e5 <__alltraps>

00101ff7 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ff7:	6a 00                	push   $0x0
  pushl $16
  101ff9:	6a 10                	push   $0x10
  jmp __alltraps
  101ffb:	e9 e5 09 00 00       	jmp    1029e5 <__alltraps>

00102000 <vector17>:
.globl vector17
vector17:
  pushl $17
  102000:	6a 11                	push   $0x11
  jmp __alltraps
  102002:	e9 de 09 00 00       	jmp    1029e5 <__alltraps>

00102007 <vector18>:
.globl vector18
vector18:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $18
  102009:	6a 12                	push   $0x12
  jmp __alltraps
  10200b:	e9 d5 09 00 00       	jmp    1029e5 <__alltraps>

00102010 <vector19>:
.globl vector19
vector19:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $19
  102012:	6a 13                	push   $0x13
  jmp __alltraps
  102014:	e9 cc 09 00 00       	jmp    1029e5 <__alltraps>

00102019 <vector20>:
.globl vector20
vector20:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $20
  10201b:	6a 14                	push   $0x14
  jmp __alltraps
  10201d:	e9 c3 09 00 00       	jmp    1029e5 <__alltraps>

00102022 <vector21>:
.globl vector21
vector21:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $21
  102024:	6a 15                	push   $0x15
  jmp __alltraps
  102026:	e9 ba 09 00 00       	jmp    1029e5 <__alltraps>

0010202b <vector22>:
.globl vector22
vector22:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $22
  10202d:	6a 16                	push   $0x16
  jmp __alltraps
  10202f:	e9 b1 09 00 00       	jmp    1029e5 <__alltraps>

00102034 <vector23>:
.globl vector23
vector23:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $23
  102036:	6a 17                	push   $0x17
  jmp __alltraps
  102038:	e9 a8 09 00 00       	jmp    1029e5 <__alltraps>

0010203d <vector24>:
.globl vector24
vector24:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $24
  10203f:	6a 18                	push   $0x18
  jmp __alltraps
  102041:	e9 9f 09 00 00       	jmp    1029e5 <__alltraps>

00102046 <vector25>:
.globl vector25
vector25:
  pushl $0
  102046:	6a 00                	push   $0x0
  pushl $25
  102048:	6a 19                	push   $0x19
  jmp __alltraps
  10204a:	e9 96 09 00 00       	jmp    1029e5 <__alltraps>

0010204f <vector26>:
.globl vector26
vector26:
  pushl $0
  10204f:	6a 00                	push   $0x0
  pushl $26
  102051:	6a 1a                	push   $0x1a
  jmp __alltraps
  102053:	e9 8d 09 00 00       	jmp    1029e5 <__alltraps>

00102058 <vector27>:
.globl vector27
vector27:
  pushl $0
  102058:	6a 00                	push   $0x0
  pushl $27
  10205a:	6a 1b                	push   $0x1b
  jmp __alltraps
  10205c:	e9 84 09 00 00       	jmp    1029e5 <__alltraps>

00102061 <vector28>:
.globl vector28
vector28:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $28
  102063:	6a 1c                	push   $0x1c
  jmp __alltraps
  102065:	e9 7b 09 00 00       	jmp    1029e5 <__alltraps>

0010206a <vector29>:
.globl vector29
vector29:
  pushl $0
  10206a:	6a 00                	push   $0x0
  pushl $29
  10206c:	6a 1d                	push   $0x1d
  jmp __alltraps
  10206e:	e9 72 09 00 00       	jmp    1029e5 <__alltraps>

00102073 <vector30>:
.globl vector30
vector30:
  pushl $0
  102073:	6a 00                	push   $0x0
  pushl $30
  102075:	6a 1e                	push   $0x1e
  jmp __alltraps
  102077:	e9 69 09 00 00       	jmp    1029e5 <__alltraps>

0010207c <vector31>:
.globl vector31
vector31:
  pushl $0
  10207c:	6a 00                	push   $0x0
  pushl $31
  10207e:	6a 1f                	push   $0x1f
  jmp __alltraps
  102080:	e9 60 09 00 00       	jmp    1029e5 <__alltraps>

00102085 <vector32>:
.globl vector32
vector32:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $32
  102087:	6a 20                	push   $0x20
  jmp __alltraps
  102089:	e9 57 09 00 00       	jmp    1029e5 <__alltraps>

0010208e <vector33>:
.globl vector33
vector33:
  pushl $0
  10208e:	6a 00                	push   $0x0
  pushl $33
  102090:	6a 21                	push   $0x21
  jmp __alltraps
  102092:	e9 4e 09 00 00       	jmp    1029e5 <__alltraps>

00102097 <vector34>:
.globl vector34
vector34:
  pushl $0
  102097:	6a 00                	push   $0x0
  pushl $34
  102099:	6a 22                	push   $0x22
  jmp __alltraps
  10209b:	e9 45 09 00 00       	jmp    1029e5 <__alltraps>

001020a0 <vector35>:
.globl vector35
vector35:
  pushl $0
  1020a0:	6a 00                	push   $0x0
  pushl $35
  1020a2:	6a 23                	push   $0x23
  jmp __alltraps
  1020a4:	e9 3c 09 00 00       	jmp    1029e5 <__alltraps>

001020a9 <vector36>:
.globl vector36
vector36:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $36
  1020ab:	6a 24                	push   $0x24
  jmp __alltraps
  1020ad:	e9 33 09 00 00       	jmp    1029e5 <__alltraps>

001020b2 <vector37>:
.globl vector37
vector37:
  pushl $0
  1020b2:	6a 00                	push   $0x0
  pushl $37
  1020b4:	6a 25                	push   $0x25
  jmp __alltraps
  1020b6:	e9 2a 09 00 00       	jmp    1029e5 <__alltraps>

001020bb <vector38>:
.globl vector38
vector38:
  pushl $0
  1020bb:	6a 00                	push   $0x0
  pushl $38
  1020bd:	6a 26                	push   $0x26
  jmp __alltraps
  1020bf:	e9 21 09 00 00       	jmp    1029e5 <__alltraps>

001020c4 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020c4:	6a 00                	push   $0x0
  pushl $39
  1020c6:	6a 27                	push   $0x27
  jmp __alltraps
  1020c8:	e9 18 09 00 00       	jmp    1029e5 <__alltraps>

001020cd <vector40>:
.globl vector40
vector40:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $40
  1020cf:	6a 28                	push   $0x28
  jmp __alltraps
  1020d1:	e9 0f 09 00 00       	jmp    1029e5 <__alltraps>

001020d6 <vector41>:
.globl vector41
vector41:
  pushl $0
  1020d6:	6a 00                	push   $0x0
  pushl $41
  1020d8:	6a 29                	push   $0x29
  jmp __alltraps
  1020da:	e9 06 09 00 00       	jmp    1029e5 <__alltraps>

001020df <vector42>:
.globl vector42
vector42:
  pushl $0
  1020df:	6a 00                	push   $0x0
  pushl $42
  1020e1:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020e3:	e9 fd 08 00 00       	jmp    1029e5 <__alltraps>

001020e8 <vector43>:
.globl vector43
vector43:
  pushl $0
  1020e8:	6a 00                	push   $0x0
  pushl $43
  1020ea:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020ec:	e9 f4 08 00 00       	jmp    1029e5 <__alltraps>

001020f1 <vector44>:
.globl vector44
vector44:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $44
  1020f3:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020f5:	e9 eb 08 00 00       	jmp    1029e5 <__alltraps>

001020fa <vector45>:
.globl vector45
vector45:
  pushl $0
  1020fa:	6a 00                	push   $0x0
  pushl $45
  1020fc:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020fe:	e9 e2 08 00 00       	jmp    1029e5 <__alltraps>

00102103 <vector46>:
.globl vector46
vector46:
  pushl $0
  102103:	6a 00                	push   $0x0
  pushl $46
  102105:	6a 2e                	push   $0x2e
  jmp __alltraps
  102107:	e9 d9 08 00 00       	jmp    1029e5 <__alltraps>

0010210c <vector47>:
.globl vector47
vector47:
  pushl $0
  10210c:	6a 00                	push   $0x0
  pushl $47
  10210e:	6a 2f                	push   $0x2f
  jmp __alltraps
  102110:	e9 d0 08 00 00       	jmp    1029e5 <__alltraps>

00102115 <vector48>:
.globl vector48
vector48:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $48
  102117:	6a 30                	push   $0x30
  jmp __alltraps
  102119:	e9 c7 08 00 00       	jmp    1029e5 <__alltraps>

0010211e <vector49>:
.globl vector49
vector49:
  pushl $0
  10211e:	6a 00                	push   $0x0
  pushl $49
  102120:	6a 31                	push   $0x31
  jmp __alltraps
  102122:	e9 be 08 00 00       	jmp    1029e5 <__alltraps>

00102127 <vector50>:
.globl vector50
vector50:
  pushl $0
  102127:	6a 00                	push   $0x0
  pushl $50
  102129:	6a 32                	push   $0x32
  jmp __alltraps
  10212b:	e9 b5 08 00 00       	jmp    1029e5 <__alltraps>

00102130 <vector51>:
.globl vector51
vector51:
  pushl $0
  102130:	6a 00                	push   $0x0
  pushl $51
  102132:	6a 33                	push   $0x33
  jmp __alltraps
  102134:	e9 ac 08 00 00       	jmp    1029e5 <__alltraps>

00102139 <vector52>:
.globl vector52
vector52:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $52
  10213b:	6a 34                	push   $0x34
  jmp __alltraps
  10213d:	e9 a3 08 00 00       	jmp    1029e5 <__alltraps>

00102142 <vector53>:
.globl vector53
vector53:
  pushl $0
  102142:	6a 00                	push   $0x0
  pushl $53
  102144:	6a 35                	push   $0x35
  jmp __alltraps
  102146:	e9 9a 08 00 00       	jmp    1029e5 <__alltraps>

0010214b <vector54>:
.globl vector54
vector54:
  pushl $0
  10214b:	6a 00                	push   $0x0
  pushl $54
  10214d:	6a 36                	push   $0x36
  jmp __alltraps
  10214f:	e9 91 08 00 00       	jmp    1029e5 <__alltraps>

00102154 <vector55>:
.globl vector55
vector55:
  pushl $0
  102154:	6a 00                	push   $0x0
  pushl $55
  102156:	6a 37                	push   $0x37
  jmp __alltraps
  102158:	e9 88 08 00 00       	jmp    1029e5 <__alltraps>

0010215d <vector56>:
.globl vector56
vector56:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $56
  10215f:	6a 38                	push   $0x38
  jmp __alltraps
  102161:	e9 7f 08 00 00       	jmp    1029e5 <__alltraps>

00102166 <vector57>:
.globl vector57
vector57:
  pushl $0
  102166:	6a 00                	push   $0x0
  pushl $57
  102168:	6a 39                	push   $0x39
  jmp __alltraps
  10216a:	e9 76 08 00 00       	jmp    1029e5 <__alltraps>

0010216f <vector58>:
.globl vector58
vector58:
  pushl $0
  10216f:	6a 00                	push   $0x0
  pushl $58
  102171:	6a 3a                	push   $0x3a
  jmp __alltraps
  102173:	e9 6d 08 00 00       	jmp    1029e5 <__alltraps>

00102178 <vector59>:
.globl vector59
vector59:
  pushl $0
  102178:	6a 00                	push   $0x0
  pushl $59
  10217a:	6a 3b                	push   $0x3b
  jmp __alltraps
  10217c:	e9 64 08 00 00       	jmp    1029e5 <__alltraps>

00102181 <vector60>:
.globl vector60
vector60:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $60
  102183:	6a 3c                	push   $0x3c
  jmp __alltraps
  102185:	e9 5b 08 00 00       	jmp    1029e5 <__alltraps>

0010218a <vector61>:
.globl vector61
vector61:
  pushl $0
  10218a:	6a 00                	push   $0x0
  pushl $61
  10218c:	6a 3d                	push   $0x3d
  jmp __alltraps
  10218e:	e9 52 08 00 00       	jmp    1029e5 <__alltraps>

00102193 <vector62>:
.globl vector62
vector62:
  pushl $0
  102193:	6a 00                	push   $0x0
  pushl $62
  102195:	6a 3e                	push   $0x3e
  jmp __alltraps
  102197:	e9 49 08 00 00       	jmp    1029e5 <__alltraps>

0010219c <vector63>:
.globl vector63
vector63:
  pushl $0
  10219c:	6a 00                	push   $0x0
  pushl $63
  10219e:	6a 3f                	push   $0x3f
  jmp __alltraps
  1021a0:	e9 40 08 00 00       	jmp    1029e5 <__alltraps>

001021a5 <vector64>:
.globl vector64
vector64:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $64
  1021a7:	6a 40                	push   $0x40
  jmp __alltraps
  1021a9:	e9 37 08 00 00       	jmp    1029e5 <__alltraps>

001021ae <vector65>:
.globl vector65
vector65:
  pushl $0
  1021ae:	6a 00                	push   $0x0
  pushl $65
  1021b0:	6a 41                	push   $0x41
  jmp __alltraps
  1021b2:	e9 2e 08 00 00       	jmp    1029e5 <__alltraps>

001021b7 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021b7:	6a 00                	push   $0x0
  pushl $66
  1021b9:	6a 42                	push   $0x42
  jmp __alltraps
  1021bb:	e9 25 08 00 00       	jmp    1029e5 <__alltraps>

001021c0 <vector67>:
.globl vector67
vector67:
  pushl $0
  1021c0:	6a 00                	push   $0x0
  pushl $67
  1021c2:	6a 43                	push   $0x43
  jmp __alltraps
  1021c4:	e9 1c 08 00 00       	jmp    1029e5 <__alltraps>

001021c9 <vector68>:
.globl vector68
vector68:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $68
  1021cb:	6a 44                	push   $0x44
  jmp __alltraps
  1021cd:	e9 13 08 00 00       	jmp    1029e5 <__alltraps>

001021d2 <vector69>:
.globl vector69
vector69:
  pushl $0
  1021d2:	6a 00                	push   $0x0
  pushl $69
  1021d4:	6a 45                	push   $0x45
  jmp __alltraps
  1021d6:	e9 0a 08 00 00       	jmp    1029e5 <__alltraps>

001021db <vector70>:
.globl vector70
vector70:
  pushl $0
  1021db:	6a 00                	push   $0x0
  pushl $70
  1021dd:	6a 46                	push   $0x46
  jmp __alltraps
  1021df:	e9 01 08 00 00       	jmp    1029e5 <__alltraps>

001021e4 <vector71>:
.globl vector71
vector71:
  pushl $0
  1021e4:	6a 00                	push   $0x0
  pushl $71
  1021e6:	6a 47                	push   $0x47
  jmp __alltraps
  1021e8:	e9 f8 07 00 00       	jmp    1029e5 <__alltraps>

001021ed <vector72>:
.globl vector72
vector72:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $72
  1021ef:	6a 48                	push   $0x48
  jmp __alltraps
  1021f1:	e9 ef 07 00 00       	jmp    1029e5 <__alltraps>

001021f6 <vector73>:
.globl vector73
vector73:
  pushl $0
  1021f6:	6a 00                	push   $0x0
  pushl $73
  1021f8:	6a 49                	push   $0x49
  jmp __alltraps
  1021fa:	e9 e6 07 00 00       	jmp    1029e5 <__alltraps>

001021ff <vector74>:
.globl vector74
vector74:
  pushl $0
  1021ff:	6a 00                	push   $0x0
  pushl $74
  102201:	6a 4a                	push   $0x4a
  jmp __alltraps
  102203:	e9 dd 07 00 00       	jmp    1029e5 <__alltraps>

00102208 <vector75>:
.globl vector75
vector75:
  pushl $0
  102208:	6a 00                	push   $0x0
  pushl $75
  10220a:	6a 4b                	push   $0x4b
  jmp __alltraps
  10220c:	e9 d4 07 00 00       	jmp    1029e5 <__alltraps>

00102211 <vector76>:
.globl vector76
vector76:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $76
  102213:	6a 4c                	push   $0x4c
  jmp __alltraps
  102215:	e9 cb 07 00 00       	jmp    1029e5 <__alltraps>

0010221a <vector77>:
.globl vector77
vector77:
  pushl $0
  10221a:	6a 00                	push   $0x0
  pushl $77
  10221c:	6a 4d                	push   $0x4d
  jmp __alltraps
  10221e:	e9 c2 07 00 00       	jmp    1029e5 <__alltraps>

00102223 <vector78>:
.globl vector78
vector78:
  pushl $0
  102223:	6a 00                	push   $0x0
  pushl $78
  102225:	6a 4e                	push   $0x4e
  jmp __alltraps
  102227:	e9 b9 07 00 00       	jmp    1029e5 <__alltraps>

0010222c <vector79>:
.globl vector79
vector79:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $79
  10222e:	6a 4f                	push   $0x4f
  jmp __alltraps
  102230:	e9 b0 07 00 00       	jmp    1029e5 <__alltraps>

00102235 <vector80>:
.globl vector80
vector80:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $80
  102237:	6a 50                	push   $0x50
  jmp __alltraps
  102239:	e9 a7 07 00 00       	jmp    1029e5 <__alltraps>

0010223e <vector81>:
.globl vector81
vector81:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $81
  102240:	6a 51                	push   $0x51
  jmp __alltraps
  102242:	e9 9e 07 00 00       	jmp    1029e5 <__alltraps>

00102247 <vector82>:
.globl vector82
vector82:
  pushl $0
  102247:	6a 00                	push   $0x0
  pushl $82
  102249:	6a 52                	push   $0x52
  jmp __alltraps
  10224b:	e9 95 07 00 00       	jmp    1029e5 <__alltraps>

00102250 <vector83>:
.globl vector83
vector83:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $83
  102252:	6a 53                	push   $0x53
  jmp __alltraps
  102254:	e9 8c 07 00 00       	jmp    1029e5 <__alltraps>

00102259 <vector84>:
.globl vector84
vector84:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $84
  10225b:	6a 54                	push   $0x54
  jmp __alltraps
  10225d:	e9 83 07 00 00       	jmp    1029e5 <__alltraps>

00102262 <vector85>:
.globl vector85
vector85:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $85
  102264:	6a 55                	push   $0x55
  jmp __alltraps
  102266:	e9 7a 07 00 00       	jmp    1029e5 <__alltraps>

0010226b <vector86>:
.globl vector86
vector86:
  pushl $0
  10226b:	6a 00                	push   $0x0
  pushl $86
  10226d:	6a 56                	push   $0x56
  jmp __alltraps
  10226f:	e9 71 07 00 00       	jmp    1029e5 <__alltraps>

00102274 <vector87>:
.globl vector87
vector87:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $87
  102276:	6a 57                	push   $0x57
  jmp __alltraps
  102278:	e9 68 07 00 00       	jmp    1029e5 <__alltraps>

0010227d <vector88>:
.globl vector88
vector88:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $88
  10227f:	6a 58                	push   $0x58
  jmp __alltraps
  102281:	e9 5f 07 00 00       	jmp    1029e5 <__alltraps>

00102286 <vector89>:
.globl vector89
vector89:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $89
  102288:	6a 59                	push   $0x59
  jmp __alltraps
  10228a:	e9 56 07 00 00       	jmp    1029e5 <__alltraps>

0010228f <vector90>:
.globl vector90
vector90:
  pushl $0
  10228f:	6a 00                	push   $0x0
  pushl $90
  102291:	6a 5a                	push   $0x5a
  jmp __alltraps
  102293:	e9 4d 07 00 00       	jmp    1029e5 <__alltraps>

00102298 <vector91>:
.globl vector91
vector91:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $91
  10229a:	6a 5b                	push   $0x5b
  jmp __alltraps
  10229c:	e9 44 07 00 00       	jmp    1029e5 <__alltraps>

001022a1 <vector92>:
.globl vector92
vector92:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $92
  1022a3:	6a 5c                	push   $0x5c
  jmp __alltraps
  1022a5:	e9 3b 07 00 00       	jmp    1029e5 <__alltraps>

001022aa <vector93>:
.globl vector93
vector93:
  pushl $0
  1022aa:	6a 00                	push   $0x0
  pushl $93
  1022ac:	6a 5d                	push   $0x5d
  jmp __alltraps
  1022ae:	e9 32 07 00 00       	jmp    1029e5 <__alltraps>

001022b3 <vector94>:
.globl vector94
vector94:
  pushl $0
  1022b3:	6a 00                	push   $0x0
  pushl $94
  1022b5:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022b7:	e9 29 07 00 00       	jmp    1029e5 <__alltraps>

001022bc <vector95>:
.globl vector95
vector95:
  pushl $0
  1022bc:	6a 00                	push   $0x0
  pushl $95
  1022be:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022c0:	e9 20 07 00 00       	jmp    1029e5 <__alltraps>

001022c5 <vector96>:
.globl vector96
vector96:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $96
  1022c7:	6a 60                	push   $0x60
  jmp __alltraps
  1022c9:	e9 17 07 00 00       	jmp    1029e5 <__alltraps>

001022ce <vector97>:
.globl vector97
vector97:
  pushl $0
  1022ce:	6a 00                	push   $0x0
  pushl $97
  1022d0:	6a 61                	push   $0x61
  jmp __alltraps
  1022d2:	e9 0e 07 00 00       	jmp    1029e5 <__alltraps>

001022d7 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022d7:	6a 00                	push   $0x0
  pushl $98
  1022d9:	6a 62                	push   $0x62
  jmp __alltraps
  1022db:	e9 05 07 00 00       	jmp    1029e5 <__alltraps>

001022e0 <vector99>:
.globl vector99
vector99:
  pushl $0
  1022e0:	6a 00                	push   $0x0
  pushl $99
  1022e2:	6a 63                	push   $0x63
  jmp __alltraps
  1022e4:	e9 fc 06 00 00       	jmp    1029e5 <__alltraps>

001022e9 <vector100>:
.globl vector100
vector100:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $100
  1022eb:	6a 64                	push   $0x64
  jmp __alltraps
  1022ed:	e9 f3 06 00 00       	jmp    1029e5 <__alltraps>

001022f2 <vector101>:
.globl vector101
vector101:
  pushl $0
  1022f2:	6a 00                	push   $0x0
  pushl $101
  1022f4:	6a 65                	push   $0x65
  jmp __alltraps
  1022f6:	e9 ea 06 00 00       	jmp    1029e5 <__alltraps>

001022fb <vector102>:
.globl vector102
vector102:
  pushl $0
  1022fb:	6a 00                	push   $0x0
  pushl $102
  1022fd:	6a 66                	push   $0x66
  jmp __alltraps
  1022ff:	e9 e1 06 00 00       	jmp    1029e5 <__alltraps>

00102304 <vector103>:
.globl vector103
vector103:
  pushl $0
  102304:	6a 00                	push   $0x0
  pushl $103
  102306:	6a 67                	push   $0x67
  jmp __alltraps
  102308:	e9 d8 06 00 00       	jmp    1029e5 <__alltraps>

0010230d <vector104>:
.globl vector104
vector104:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $104
  10230f:	6a 68                	push   $0x68
  jmp __alltraps
  102311:	e9 cf 06 00 00       	jmp    1029e5 <__alltraps>

00102316 <vector105>:
.globl vector105
vector105:
  pushl $0
  102316:	6a 00                	push   $0x0
  pushl $105
  102318:	6a 69                	push   $0x69
  jmp __alltraps
  10231a:	e9 c6 06 00 00       	jmp    1029e5 <__alltraps>

0010231f <vector106>:
.globl vector106
vector106:
  pushl $0
  10231f:	6a 00                	push   $0x0
  pushl $106
  102321:	6a 6a                	push   $0x6a
  jmp __alltraps
  102323:	e9 bd 06 00 00       	jmp    1029e5 <__alltraps>

00102328 <vector107>:
.globl vector107
vector107:
  pushl $0
  102328:	6a 00                	push   $0x0
  pushl $107
  10232a:	6a 6b                	push   $0x6b
  jmp __alltraps
  10232c:	e9 b4 06 00 00       	jmp    1029e5 <__alltraps>

00102331 <vector108>:
.globl vector108
vector108:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $108
  102333:	6a 6c                	push   $0x6c
  jmp __alltraps
  102335:	e9 ab 06 00 00       	jmp    1029e5 <__alltraps>

0010233a <vector109>:
.globl vector109
vector109:
  pushl $0
  10233a:	6a 00                	push   $0x0
  pushl $109
  10233c:	6a 6d                	push   $0x6d
  jmp __alltraps
  10233e:	e9 a2 06 00 00       	jmp    1029e5 <__alltraps>

00102343 <vector110>:
.globl vector110
vector110:
  pushl $0
  102343:	6a 00                	push   $0x0
  pushl $110
  102345:	6a 6e                	push   $0x6e
  jmp __alltraps
  102347:	e9 99 06 00 00       	jmp    1029e5 <__alltraps>

0010234c <vector111>:
.globl vector111
vector111:
  pushl $0
  10234c:	6a 00                	push   $0x0
  pushl $111
  10234e:	6a 6f                	push   $0x6f
  jmp __alltraps
  102350:	e9 90 06 00 00       	jmp    1029e5 <__alltraps>

00102355 <vector112>:
.globl vector112
vector112:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $112
  102357:	6a 70                	push   $0x70
  jmp __alltraps
  102359:	e9 87 06 00 00       	jmp    1029e5 <__alltraps>

0010235e <vector113>:
.globl vector113
vector113:
  pushl $0
  10235e:	6a 00                	push   $0x0
  pushl $113
  102360:	6a 71                	push   $0x71
  jmp __alltraps
  102362:	e9 7e 06 00 00       	jmp    1029e5 <__alltraps>

00102367 <vector114>:
.globl vector114
vector114:
  pushl $0
  102367:	6a 00                	push   $0x0
  pushl $114
  102369:	6a 72                	push   $0x72
  jmp __alltraps
  10236b:	e9 75 06 00 00       	jmp    1029e5 <__alltraps>

00102370 <vector115>:
.globl vector115
vector115:
  pushl $0
  102370:	6a 00                	push   $0x0
  pushl $115
  102372:	6a 73                	push   $0x73
  jmp __alltraps
  102374:	e9 6c 06 00 00       	jmp    1029e5 <__alltraps>

00102379 <vector116>:
.globl vector116
vector116:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $116
  10237b:	6a 74                	push   $0x74
  jmp __alltraps
  10237d:	e9 63 06 00 00       	jmp    1029e5 <__alltraps>

00102382 <vector117>:
.globl vector117
vector117:
  pushl $0
  102382:	6a 00                	push   $0x0
  pushl $117
  102384:	6a 75                	push   $0x75
  jmp __alltraps
  102386:	e9 5a 06 00 00       	jmp    1029e5 <__alltraps>

0010238b <vector118>:
.globl vector118
vector118:
  pushl $0
  10238b:	6a 00                	push   $0x0
  pushl $118
  10238d:	6a 76                	push   $0x76
  jmp __alltraps
  10238f:	e9 51 06 00 00       	jmp    1029e5 <__alltraps>

00102394 <vector119>:
.globl vector119
vector119:
  pushl $0
  102394:	6a 00                	push   $0x0
  pushl $119
  102396:	6a 77                	push   $0x77
  jmp __alltraps
  102398:	e9 48 06 00 00       	jmp    1029e5 <__alltraps>

0010239d <vector120>:
.globl vector120
vector120:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $120
  10239f:	6a 78                	push   $0x78
  jmp __alltraps
  1023a1:	e9 3f 06 00 00       	jmp    1029e5 <__alltraps>

001023a6 <vector121>:
.globl vector121
vector121:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $121
  1023a8:	6a 79                	push   $0x79
  jmp __alltraps
  1023aa:	e9 36 06 00 00       	jmp    1029e5 <__alltraps>

001023af <vector122>:
.globl vector122
vector122:
  pushl $0
  1023af:	6a 00                	push   $0x0
  pushl $122
  1023b1:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023b3:	e9 2d 06 00 00       	jmp    1029e5 <__alltraps>

001023b8 <vector123>:
.globl vector123
vector123:
  pushl $0
  1023b8:	6a 00                	push   $0x0
  pushl $123
  1023ba:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023bc:	e9 24 06 00 00       	jmp    1029e5 <__alltraps>

001023c1 <vector124>:
.globl vector124
vector124:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $124
  1023c3:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023c5:	e9 1b 06 00 00       	jmp    1029e5 <__alltraps>

001023ca <vector125>:
.globl vector125
vector125:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $125
  1023cc:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023ce:	e9 12 06 00 00       	jmp    1029e5 <__alltraps>

001023d3 <vector126>:
.globl vector126
vector126:
  pushl $0
  1023d3:	6a 00                	push   $0x0
  pushl $126
  1023d5:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023d7:	e9 09 06 00 00       	jmp    1029e5 <__alltraps>

001023dc <vector127>:
.globl vector127
vector127:
  pushl $0
  1023dc:	6a 00                	push   $0x0
  pushl $127
  1023de:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023e0:	e9 00 06 00 00       	jmp    1029e5 <__alltraps>

001023e5 <vector128>:
.globl vector128
vector128:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $128
  1023e7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023ec:	e9 f4 05 00 00       	jmp    1029e5 <__alltraps>

001023f1 <vector129>:
.globl vector129
vector129:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $129
  1023f3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023f8:	e9 e8 05 00 00       	jmp    1029e5 <__alltraps>

001023fd <vector130>:
.globl vector130
vector130:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $130
  1023ff:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102404:	e9 dc 05 00 00       	jmp    1029e5 <__alltraps>

00102409 <vector131>:
.globl vector131
vector131:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $131
  10240b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102410:	e9 d0 05 00 00       	jmp    1029e5 <__alltraps>

00102415 <vector132>:
.globl vector132
vector132:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $132
  102417:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10241c:	e9 c4 05 00 00       	jmp    1029e5 <__alltraps>

00102421 <vector133>:
.globl vector133
vector133:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $133
  102423:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102428:	e9 b8 05 00 00       	jmp    1029e5 <__alltraps>

0010242d <vector134>:
.globl vector134
vector134:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $134
  10242f:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102434:	e9 ac 05 00 00       	jmp    1029e5 <__alltraps>

00102439 <vector135>:
.globl vector135
vector135:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $135
  10243b:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102440:	e9 a0 05 00 00       	jmp    1029e5 <__alltraps>

00102445 <vector136>:
.globl vector136
vector136:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $136
  102447:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10244c:	e9 94 05 00 00       	jmp    1029e5 <__alltraps>

00102451 <vector137>:
.globl vector137
vector137:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $137
  102453:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102458:	e9 88 05 00 00       	jmp    1029e5 <__alltraps>

0010245d <vector138>:
.globl vector138
vector138:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $138
  10245f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102464:	e9 7c 05 00 00       	jmp    1029e5 <__alltraps>

00102469 <vector139>:
.globl vector139
vector139:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $139
  10246b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102470:	e9 70 05 00 00       	jmp    1029e5 <__alltraps>

00102475 <vector140>:
.globl vector140
vector140:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $140
  102477:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10247c:	e9 64 05 00 00       	jmp    1029e5 <__alltraps>

00102481 <vector141>:
.globl vector141
vector141:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $141
  102483:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102488:	e9 58 05 00 00       	jmp    1029e5 <__alltraps>

0010248d <vector142>:
.globl vector142
vector142:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $142
  10248f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102494:	e9 4c 05 00 00       	jmp    1029e5 <__alltraps>

00102499 <vector143>:
.globl vector143
vector143:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $143
  10249b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1024a0:	e9 40 05 00 00       	jmp    1029e5 <__alltraps>

001024a5 <vector144>:
.globl vector144
vector144:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $144
  1024a7:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1024ac:	e9 34 05 00 00       	jmp    1029e5 <__alltraps>

001024b1 <vector145>:
.globl vector145
vector145:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $145
  1024b3:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024b8:	e9 28 05 00 00       	jmp    1029e5 <__alltraps>

001024bd <vector146>:
.globl vector146
vector146:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $146
  1024bf:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024c4:	e9 1c 05 00 00       	jmp    1029e5 <__alltraps>

001024c9 <vector147>:
.globl vector147
vector147:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $147
  1024cb:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024d0:	e9 10 05 00 00       	jmp    1029e5 <__alltraps>

001024d5 <vector148>:
.globl vector148
vector148:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $148
  1024d7:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024dc:	e9 04 05 00 00       	jmp    1029e5 <__alltraps>

001024e1 <vector149>:
.globl vector149
vector149:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $149
  1024e3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024e8:	e9 f8 04 00 00       	jmp    1029e5 <__alltraps>

001024ed <vector150>:
.globl vector150
vector150:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $150
  1024ef:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024f4:	e9 ec 04 00 00       	jmp    1029e5 <__alltraps>

001024f9 <vector151>:
.globl vector151
vector151:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $151
  1024fb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102500:	e9 e0 04 00 00       	jmp    1029e5 <__alltraps>

00102505 <vector152>:
.globl vector152
vector152:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $152
  102507:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10250c:	e9 d4 04 00 00       	jmp    1029e5 <__alltraps>

00102511 <vector153>:
.globl vector153
vector153:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $153
  102513:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102518:	e9 c8 04 00 00       	jmp    1029e5 <__alltraps>

0010251d <vector154>:
.globl vector154
vector154:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $154
  10251f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102524:	e9 bc 04 00 00       	jmp    1029e5 <__alltraps>

00102529 <vector155>:
.globl vector155
vector155:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $155
  10252b:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102530:	e9 b0 04 00 00       	jmp    1029e5 <__alltraps>

00102535 <vector156>:
.globl vector156
vector156:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $156
  102537:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10253c:	e9 a4 04 00 00       	jmp    1029e5 <__alltraps>

00102541 <vector157>:
.globl vector157
vector157:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $157
  102543:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102548:	e9 98 04 00 00       	jmp    1029e5 <__alltraps>

0010254d <vector158>:
.globl vector158
vector158:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $158
  10254f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102554:	e9 8c 04 00 00       	jmp    1029e5 <__alltraps>

00102559 <vector159>:
.globl vector159
vector159:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $159
  10255b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102560:	e9 80 04 00 00       	jmp    1029e5 <__alltraps>

00102565 <vector160>:
.globl vector160
vector160:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $160
  102567:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10256c:	e9 74 04 00 00       	jmp    1029e5 <__alltraps>

00102571 <vector161>:
.globl vector161
vector161:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $161
  102573:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102578:	e9 68 04 00 00       	jmp    1029e5 <__alltraps>

0010257d <vector162>:
.globl vector162
vector162:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $162
  10257f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102584:	e9 5c 04 00 00       	jmp    1029e5 <__alltraps>

00102589 <vector163>:
.globl vector163
vector163:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $163
  10258b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102590:	e9 50 04 00 00       	jmp    1029e5 <__alltraps>

00102595 <vector164>:
.globl vector164
vector164:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $164
  102597:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10259c:	e9 44 04 00 00       	jmp    1029e5 <__alltraps>

001025a1 <vector165>:
.globl vector165
vector165:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $165
  1025a3:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1025a8:	e9 38 04 00 00       	jmp    1029e5 <__alltraps>

001025ad <vector166>:
.globl vector166
vector166:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $166
  1025af:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025b4:	e9 2c 04 00 00       	jmp    1029e5 <__alltraps>

001025b9 <vector167>:
.globl vector167
vector167:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $167
  1025bb:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025c0:	e9 20 04 00 00       	jmp    1029e5 <__alltraps>

001025c5 <vector168>:
.globl vector168
vector168:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $168
  1025c7:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025cc:	e9 14 04 00 00       	jmp    1029e5 <__alltraps>

001025d1 <vector169>:
.globl vector169
vector169:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $169
  1025d3:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025d8:	e9 08 04 00 00       	jmp    1029e5 <__alltraps>

001025dd <vector170>:
.globl vector170
vector170:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $170
  1025df:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025e4:	e9 fc 03 00 00       	jmp    1029e5 <__alltraps>

001025e9 <vector171>:
.globl vector171
vector171:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $171
  1025eb:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025f0:	e9 f0 03 00 00       	jmp    1029e5 <__alltraps>

001025f5 <vector172>:
.globl vector172
vector172:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $172
  1025f7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025fc:	e9 e4 03 00 00       	jmp    1029e5 <__alltraps>

00102601 <vector173>:
.globl vector173
vector173:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $173
  102603:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102608:	e9 d8 03 00 00       	jmp    1029e5 <__alltraps>

0010260d <vector174>:
.globl vector174
vector174:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $174
  10260f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102614:	e9 cc 03 00 00       	jmp    1029e5 <__alltraps>

00102619 <vector175>:
.globl vector175
vector175:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $175
  10261b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102620:	e9 c0 03 00 00       	jmp    1029e5 <__alltraps>

00102625 <vector176>:
.globl vector176
vector176:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $176
  102627:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10262c:	e9 b4 03 00 00       	jmp    1029e5 <__alltraps>

00102631 <vector177>:
.globl vector177
vector177:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $177
  102633:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102638:	e9 a8 03 00 00       	jmp    1029e5 <__alltraps>

0010263d <vector178>:
.globl vector178
vector178:
  pushl $0
  10263d:	6a 00                	push   $0x0
  pushl $178
  10263f:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102644:	e9 9c 03 00 00       	jmp    1029e5 <__alltraps>

00102649 <vector179>:
.globl vector179
vector179:
  pushl $0
  102649:	6a 00                	push   $0x0
  pushl $179
  10264b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102650:	e9 90 03 00 00       	jmp    1029e5 <__alltraps>

00102655 <vector180>:
.globl vector180
vector180:
  pushl $0
  102655:	6a 00                	push   $0x0
  pushl $180
  102657:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10265c:	e9 84 03 00 00       	jmp    1029e5 <__alltraps>

00102661 <vector181>:
.globl vector181
vector181:
  pushl $0
  102661:	6a 00                	push   $0x0
  pushl $181
  102663:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102668:	e9 78 03 00 00       	jmp    1029e5 <__alltraps>

0010266d <vector182>:
.globl vector182
vector182:
  pushl $0
  10266d:	6a 00                	push   $0x0
  pushl $182
  10266f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102674:	e9 6c 03 00 00       	jmp    1029e5 <__alltraps>

00102679 <vector183>:
.globl vector183
vector183:
  pushl $0
  102679:	6a 00                	push   $0x0
  pushl $183
  10267b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102680:	e9 60 03 00 00       	jmp    1029e5 <__alltraps>

00102685 <vector184>:
.globl vector184
vector184:
  pushl $0
  102685:	6a 00                	push   $0x0
  pushl $184
  102687:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10268c:	e9 54 03 00 00       	jmp    1029e5 <__alltraps>

00102691 <vector185>:
.globl vector185
vector185:
  pushl $0
  102691:	6a 00                	push   $0x0
  pushl $185
  102693:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102698:	e9 48 03 00 00       	jmp    1029e5 <__alltraps>

0010269d <vector186>:
.globl vector186
vector186:
  pushl $0
  10269d:	6a 00                	push   $0x0
  pushl $186
  10269f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1026a4:	e9 3c 03 00 00       	jmp    1029e5 <__alltraps>

001026a9 <vector187>:
.globl vector187
vector187:
  pushl $0
  1026a9:	6a 00                	push   $0x0
  pushl $187
  1026ab:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1026b0:	e9 30 03 00 00       	jmp    1029e5 <__alltraps>

001026b5 <vector188>:
.globl vector188
vector188:
  pushl $0
  1026b5:	6a 00                	push   $0x0
  pushl $188
  1026b7:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026bc:	e9 24 03 00 00       	jmp    1029e5 <__alltraps>

001026c1 <vector189>:
.globl vector189
vector189:
  pushl $0
  1026c1:	6a 00                	push   $0x0
  pushl $189
  1026c3:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026c8:	e9 18 03 00 00       	jmp    1029e5 <__alltraps>

001026cd <vector190>:
.globl vector190
vector190:
  pushl $0
  1026cd:	6a 00                	push   $0x0
  pushl $190
  1026cf:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026d4:	e9 0c 03 00 00       	jmp    1029e5 <__alltraps>

001026d9 <vector191>:
.globl vector191
vector191:
  pushl $0
  1026d9:	6a 00                	push   $0x0
  pushl $191
  1026db:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026e0:	e9 00 03 00 00       	jmp    1029e5 <__alltraps>

001026e5 <vector192>:
.globl vector192
vector192:
  pushl $0
  1026e5:	6a 00                	push   $0x0
  pushl $192
  1026e7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026ec:	e9 f4 02 00 00       	jmp    1029e5 <__alltraps>

001026f1 <vector193>:
.globl vector193
vector193:
  pushl $0
  1026f1:	6a 00                	push   $0x0
  pushl $193
  1026f3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026f8:	e9 e8 02 00 00       	jmp    1029e5 <__alltraps>

001026fd <vector194>:
.globl vector194
vector194:
  pushl $0
  1026fd:	6a 00                	push   $0x0
  pushl $194
  1026ff:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102704:	e9 dc 02 00 00       	jmp    1029e5 <__alltraps>

00102709 <vector195>:
.globl vector195
vector195:
  pushl $0
  102709:	6a 00                	push   $0x0
  pushl $195
  10270b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102710:	e9 d0 02 00 00       	jmp    1029e5 <__alltraps>

00102715 <vector196>:
.globl vector196
vector196:
  pushl $0
  102715:	6a 00                	push   $0x0
  pushl $196
  102717:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10271c:	e9 c4 02 00 00       	jmp    1029e5 <__alltraps>

00102721 <vector197>:
.globl vector197
vector197:
  pushl $0
  102721:	6a 00                	push   $0x0
  pushl $197
  102723:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102728:	e9 b8 02 00 00       	jmp    1029e5 <__alltraps>

0010272d <vector198>:
.globl vector198
vector198:
  pushl $0
  10272d:	6a 00                	push   $0x0
  pushl $198
  10272f:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102734:	e9 ac 02 00 00       	jmp    1029e5 <__alltraps>

00102739 <vector199>:
.globl vector199
vector199:
  pushl $0
  102739:	6a 00                	push   $0x0
  pushl $199
  10273b:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102740:	e9 a0 02 00 00       	jmp    1029e5 <__alltraps>

00102745 <vector200>:
.globl vector200
vector200:
  pushl $0
  102745:	6a 00                	push   $0x0
  pushl $200
  102747:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10274c:	e9 94 02 00 00       	jmp    1029e5 <__alltraps>

00102751 <vector201>:
.globl vector201
vector201:
  pushl $0
  102751:	6a 00                	push   $0x0
  pushl $201
  102753:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102758:	e9 88 02 00 00       	jmp    1029e5 <__alltraps>

0010275d <vector202>:
.globl vector202
vector202:
  pushl $0
  10275d:	6a 00                	push   $0x0
  pushl $202
  10275f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102764:	e9 7c 02 00 00       	jmp    1029e5 <__alltraps>

00102769 <vector203>:
.globl vector203
vector203:
  pushl $0
  102769:	6a 00                	push   $0x0
  pushl $203
  10276b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102770:	e9 70 02 00 00       	jmp    1029e5 <__alltraps>

00102775 <vector204>:
.globl vector204
vector204:
  pushl $0
  102775:	6a 00                	push   $0x0
  pushl $204
  102777:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10277c:	e9 64 02 00 00       	jmp    1029e5 <__alltraps>

00102781 <vector205>:
.globl vector205
vector205:
  pushl $0
  102781:	6a 00                	push   $0x0
  pushl $205
  102783:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102788:	e9 58 02 00 00       	jmp    1029e5 <__alltraps>

0010278d <vector206>:
.globl vector206
vector206:
  pushl $0
  10278d:	6a 00                	push   $0x0
  pushl $206
  10278f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102794:	e9 4c 02 00 00       	jmp    1029e5 <__alltraps>

00102799 <vector207>:
.globl vector207
vector207:
  pushl $0
  102799:	6a 00                	push   $0x0
  pushl $207
  10279b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1027a0:	e9 40 02 00 00       	jmp    1029e5 <__alltraps>

001027a5 <vector208>:
.globl vector208
vector208:
  pushl $0
  1027a5:	6a 00                	push   $0x0
  pushl $208
  1027a7:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1027ac:	e9 34 02 00 00       	jmp    1029e5 <__alltraps>

001027b1 <vector209>:
.globl vector209
vector209:
  pushl $0
  1027b1:	6a 00                	push   $0x0
  pushl $209
  1027b3:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027b8:	e9 28 02 00 00       	jmp    1029e5 <__alltraps>

001027bd <vector210>:
.globl vector210
vector210:
  pushl $0
  1027bd:	6a 00                	push   $0x0
  pushl $210
  1027bf:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027c4:	e9 1c 02 00 00       	jmp    1029e5 <__alltraps>

001027c9 <vector211>:
.globl vector211
vector211:
  pushl $0
  1027c9:	6a 00                	push   $0x0
  pushl $211
  1027cb:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027d0:	e9 10 02 00 00       	jmp    1029e5 <__alltraps>

001027d5 <vector212>:
.globl vector212
vector212:
  pushl $0
  1027d5:	6a 00                	push   $0x0
  pushl $212
  1027d7:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027dc:	e9 04 02 00 00       	jmp    1029e5 <__alltraps>

001027e1 <vector213>:
.globl vector213
vector213:
  pushl $0
  1027e1:	6a 00                	push   $0x0
  pushl $213
  1027e3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027e8:	e9 f8 01 00 00       	jmp    1029e5 <__alltraps>

001027ed <vector214>:
.globl vector214
vector214:
  pushl $0
  1027ed:	6a 00                	push   $0x0
  pushl $214
  1027ef:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027f4:	e9 ec 01 00 00       	jmp    1029e5 <__alltraps>

001027f9 <vector215>:
.globl vector215
vector215:
  pushl $0
  1027f9:	6a 00                	push   $0x0
  pushl $215
  1027fb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102800:	e9 e0 01 00 00       	jmp    1029e5 <__alltraps>

00102805 <vector216>:
.globl vector216
vector216:
  pushl $0
  102805:	6a 00                	push   $0x0
  pushl $216
  102807:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10280c:	e9 d4 01 00 00       	jmp    1029e5 <__alltraps>

00102811 <vector217>:
.globl vector217
vector217:
  pushl $0
  102811:	6a 00                	push   $0x0
  pushl $217
  102813:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102818:	e9 c8 01 00 00       	jmp    1029e5 <__alltraps>

0010281d <vector218>:
.globl vector218
vector218:
  pushl $0
  10281d:	6a 00                	push   $0x0
  pushl $218
  10281f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102824:	e9 bc 01 00 00       	jmp    1029e5 <__alltraps>

00102829 <vector219>:
.globl vector219
vector219:
  pushl $0
  102829:	6a 00                	push   $0x0
  pushl $219
  10282b:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102830:	e9 b0 01 00 00       	jmp    1029e5 <__alltraps>

00102835 <vector220>:
.globl vector220
vector220:
  pushl $0
  102835:	6a 00                	push   $0x0
  pushl $220
  102837:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10283c:	e9 a4 01 00 00       	jmp    1029e5 <__alltraps>

00102841 <vector221>:
.globl vector221
vector221:
  pushl $0
  102841:	6a 00                	push   $0x0
  pushl $221
  102843:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102848:	e9 98 01 00 00       	jmp    1029e5 <__alltraps>

0010284d <vector222>:
.globl vector222
vector222:
  pushl $0
  10284d:	6a 00                	push   $0x0
  pushl $222
  10284f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102854:	e9 8c 01 00 00       	jmp    1029e5 <__alltraps>

00102859 <vector223>:
.globl vector223
vector223:
  pushl $0
  102859:	6a 00                	push   $0x0
  pushl $223
  10285b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102860:	e9 80 01 00 00       	jmp    1029e5 <__alltraps>

00102865 <vector224>:
.globl vector224
vector224:
  pushl $0
  102865:	6a 00                	push   $0x0
  pushl $224
  102867:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10286c:	e9 74 01 00 00       	jmp    1029e5 <__alltraps>

00102871 <vector225>:
.globl vector225
vector225:
  pushl $0
  102871:	6a 00                	push   $0x0
  pushl $225
  102873:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102878:	e9 68 01 00 00       	jmp    1029e5 <__alltraps>

0010287d <vector226>:
.globl vector226
vector226:
  pushl $0
  10287d:	6a 00                	push   $0x0
  pushl $226
  10287f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102884:	e9 5c 01 00 00       	jmp    1029e5 <__alltraps>

00102889 <vector227>:
.globl vector227
vector227:
  pushl $0
  102889:	6a 00                	push   $0x0
  pushl $227
  10288b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102890:	e9 50 01 00 00       	jmp    1029e5 <__alltraps>

00102895 <vector228>:
.globl vector228
vector228:
  pushl $0
  102895:	6a 00                	push   $0x0
  pushl $228
  102897:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10289c:	e9 44 01 00 00       	jmp    1029e5 <__alltraps>

001028a1 <vector229>:
.globl vector229
vector229:
  pushl $0
  1028a1:	6a 00                	push   $0x0
  pushl $229
  1028a3:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1028a8:	e9 38 01 00 00       	jmp    1029e5 <__alltraps>

001028ad <vector230>:
.globl vector230
vector230:
  pushl $0
  1028ad:	6a 00                	push   $0x0
  pushl $230
  1028af:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028b4:	e9 2c 01 00 00       	jmp    1029e5 <__alltraps>

001028b9 <vector231>:
.globl vector231
vector231:
  pushl $0
  1028b9:	6a 00                	push   $0x0
  pushl $231
  1028bb:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028c0:	e9 20 01 00 00       	jmp    1029e5 <__alltraps>

001028c5 <vector232>:
.globl vector232
vector232:
  pushl $0
  1028c5:	6a 00                	push   $0x0
  pushl $232
  1028c7:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028cc:	e9 14 01 00 00       	jmp    1029e5 <__alltraps>

001028d1 <vector233>:
.globl vector233
vector233:
  pushl $0
  1028d1:	6a 00                	push   $0x0
  pushl $233
  1028d3:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028d8:	e9 08 01 00 00       	jmp    1029e5 <__alltraps>

001028dd <vector234>:
.globl vector234
vector234:
  pushl $0
  1028dd:	6a 00                	push   $0x0
  pushl $234
  1028df:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028e4:	e9 fc 00 00 00       	jmp    1029e5 <__alltraps>

001028e9 <vector235>:
.globl vector235
vector235:
  pushl $0
  1028e9:	6a 00                	push   $0x0
  pushl $235
  1028eb:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028f0:	e9 f0 00 00 00       	jmp    1029e5 <__alltraps>

001028f5 <vector236>:
.globl vector236
vector236:
  pushl $0
  1028f5:	6a 00                	push   $0x0
  pushl $236
  1028f7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028fc:	e9 e4 00 00 00       	jmp    1029e5 <__alltraps>

00102901 <vector237>:
.globl vector237
vector237:
  pushl $0
  102901:	6a 00                	push   $0x0
  pushl $237
  102903:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102908:	e9 d8 00 00 00       	jmp    1029e5 <__alltraps>

0010290d <vector238>:
.globl vector238
vector238:
  pushl $0
  10290d:	6a 00                	push   $0x0
  pushl $238
  10290f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102914:	e9 cc 00 00 00       	jmp    1029e5 <__alltraps>

00102919 <vector239>:
.globl vector239
vector239:
  pushl $0
  102919:	6a 00                	push   $0x0
  pushl $239
  10291b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102920:	e9 c0 00 00 00       	jmp    1029e5 <__alltraps>

00102925 <vector240>:
.globl vector240
vector240:
  pushl $0
  102925:	6a 00                	push   $0x0
  pushl $240
  102927:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10292c:	e9 b4 00 00 00       	jmp    1029e5 <__alltraps>

00102931 <vector241>:
.globl vector241
vector241:
  pushl $0
  102931:	6a 00                	push   $0x0
  pushl $241
  102933:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102938:	e9 a8 00 00 00       	jmp    1029e5 <__alltraps>

0010293d <vector242>:
.globl vector242
vector242:
  pushl $0
  10293d:	6a 00                	push   $0x0
  pushl $242
  10293f:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102944:	e9 9c 00 00 00       	jmp    1029e5 <__alltraps>

00102949 <vector243>:
.globl vector243
vector243:
  pushl $0
  102949:	6a 00                	push   $0x0
  pushl $243
  10294b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102950:	e9 90 00 00 00       	jmp    1029e5 <__alltraps>

00102955 <vector244>:
.globl vector244
vector244:
  pushl $0
  102955:	6a 00                	push   $0x0
  pushl $244
  102957:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10295c:	e9 84 00 00 00       	jmp    1029e5 <__alltraps>

00102961 <vector245>:
.globl vector245
vector245:
  pushl $0
  102961:	6a 00                	push   $0x0
  pushl $245
  102963:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102968:	e9 78 00 00 00       	jmp    1029e5 <__alltraps>

0010296d <vector246>:
.globl vector246
vector246:
  pushl $0
  10296d:	6a 00                	push   $0x0
  pushl $246
  10296f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102974:	e9 6c 00 00 00       	jmp    1029e5 <__alltraps>

00102979 <vector247>:
.globl vector247
vector247:
  pushl $0
  102979:	6a 00                	push   $0x0
  pushl $247
  10297b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102980:	e9 60 00 00 00       	jmp    1029e5 <__alltraps>

00102985 <vector248>:
.globl vector248
vector248:
  pushl $0
  102985:	6a 00                	push   $0x0
  pushl $248
  102987:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10298c:	e9 54 00 00 00       	jmp    1029e5 <__alltraps>

00102991 <vector249>:
.globl vector249
vector249:
  pushl $0
  102991:	6a 00                	push   $0x0
  pushl $249
  102993:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102998:	e9 48 00 00 00       	jmp    1029e5 <__alltraps>

0010299d <vector250>:
.globl vector250
vector250:
  pushl $0
  10299d:	6a 00                	push   $0x0
  pushl $250
  10299f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1029a4:	e9 3c 00 00 00       	jmp    1029e5 <__alltraps>

001029a9 <vector251>:
.globl vector251
vector251:
  pushl $0
  1029a9:	6a 00                	push   $0x0
  pushl $251
  1029ab:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1029b0:	e9 30 00 00 00       	jmp    1029e5 <__alltraps>

001029b5 <vector252>:
.globl vector252
vector252:
  pushl $0
  1029b5:	6a 00                	push   $0x0
  pushl $252
  1029b7:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029bc:	e9 24 00 00 00       	jmp    1029e5 <__alltraps>

001029c1 <vector253>:
.globl vector253
vector253:
  pushl $0
  1029c1:	6a 00                	push   $0x0
  pushl $253
  1029c3:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029c8:	e9 18 00 00 00       	jmp    1029e5 <__alltraps>

001029cd <vector254>:
.globl vector254
vector254:
  pushl $0
  1029cd:	6a 00                	push   $0x0
  pushl $254
  1029cf:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029d4:	e9 0c 00 00 00       	jmp    1029e5 <__alltraps>

001029d9 <vector255>:
.globl vector255
vector255:
  pushl $0
  1029d9:	6a 00                	push   $0x0
  pushl $255
  1029db:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029e0:	e9 00 00 00 00       	jmp    1029e5 <__alltraps>

001029e5 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1029e5:	1e                   	push   %ds
    pushl %es
  1029e6:	06                   	push   %es
    pushl %fs
  1029e7:	0f a0                	push   %fs
    pushl %gs
  1029e9:	0f a8                	push   %gs
    pushal
  1029eb:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1029ec:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1029f1:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1029f3:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1029f5:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1029f6:	e8 64 f5 ff ff       	call   101f5f <trap>

    # pop the pushed stack pointer
    popl %esp
  1029fb:	5c                   	pop    %esp

001029fc <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1029fc:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1029fd:	0f a9                	pop    %gs
    popl %fs
  1029ff:	0f a1                	pop    %fs
    popl %es
  102a01:	07                   	pop    %es
    popl %ds
  102a02:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102a03:	83 c4 08             	add    $0x8,%esp
    iret
  102a06:	cf                   	iret   

00102a07 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102a07:	55                   	push   %ebp
  102a08:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  102a0d:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
  102a13:	29 d0                	sub    %edx,%eax
  102a15:	c1 f8 02             	sar    $0x2,%eax
  102a18:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102a1e:	5d                   	pop    %ebp
  102a1f:	c3                   	ret    

00102a20 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102a20:	55                   	push   %ebp
  102a21:	89 e5                	mov    %esp,%ebp
  102a23:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102a26:	8b 45 08             	mov    0x8(%ebp),%eax
  102a29:	89 04 24             	mov    %eax,(%esp)
  102a2c:	e8 d6 ff ff ff       	call   102a07 <page2ppn>
  102a31:	c1 e0 0c             	shl    $0xc,%eax
}
  102a34:	c9                   	leave  
  102a35:	c3                   	ret    

00102a36 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102a36:	55                   	push   %ebp
  102a37:	89 e5                	mov    %esp,%ebp
  102a39:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  102a3f:	c1 e8 0c             	shr    $0xc,%eax
  102a42:	89 c2                	mov    %eax,%edx
  102a44:	a1 80 be 11 00       	mov    0x11be80,%eax
  102a49:	39 c2                	cmp    %eax,%edx
  102a4b:	72 1c                	jb     102a69 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102a4d:	c7 44 24 08 f0 67 10 	movl   $0x1067f0,0x8(%esp)
  102a54:	00 
  102a55:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  102a5c:	00 
  102a5d:	c7 04 24 0f 68 10 00 	movl   $0x10680f,(%esp)
  102a64:	e8 90 d9 ff ff       	call   1003f9 <__panic>
    }
    return &pages[PPN(pa)];
  102a69:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
  102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  102a72:	c1 e8 0c             	shr    $0xc,%eax
  102a75:	89 c2                	mov    %eax,%edx
  102a77:	89 d0                	mov    %edx,%eax
  102a79:	c1 e0 02             	shl    $0x2,%eax
  102a7c:	01 d0                	add    %edx,%eax
  102a7e:	c1 e0 02             	shl    $0x2,%eax
  102a81:	01 c8                	add    %ecx,%eax
}
  102a83:	c9                   	leave  
  102a84:	c3                   	ret    

00102a85 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102a85:	55                   	push   %ebp
  102a86:	89 e5                	mov    %esp,%ebp
  102a88:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8e:	89 04 24             	mov    %eax,(%esp)
  102a91:	e8 8a ff ff ff       	call   102a20 <page2pa>
  102a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102a9c:	c1 e8 0c             	shr    $0xc,%eax
  102a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102aa2:	a1 80 be 11 00       	mov    0x11be80,%eax
  102aa7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102aaa:	72 23                	jb     102acf <page2kva+0x4a>
  102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ab3:	c7 44 24 08 20 68 10 	movl   $0x106820,0x8(%esp)
  102aba:	00 
  102abb:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  102ac2:	00 
  102ac3:	c7 04 24 0f 68 10 00 	movl   $0x10680f,(%esp)
  102aca:	e8 2a d9 ff ff       	call   1003f9 <__panic>
  102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ad2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102ad7:	c9                   	leave  
  102ad8:	c3                   	ret    

00102ad9 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102ad9:	55                   	push   %ebp
  102ada:	89 e5                	mov    %esp,%ebp
  102adc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102adf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae2:	83 e0 01             	and    $0x1,%eax
  102ae5:	85 c0                	test   %eax,%eax
  102ae7:	75 1c                	jne    102b05 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102ae9:	c7 44 24 08 44 68 10 	movl   $0x106844,0x8(%esp)
  102af0:	00 
  102af1:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  102af8:	00 
  102af9:	c7 04 24 0f 68 10 00 	movl   $0x10680f,(%esp)
  102b00:	e8 f4 d8 ff ff       	call   1003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102b05:	8b 45 08             	mov    0x8(%ebp),%eax
  102b08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b0d:	89 04 24             	mov    %eax,(%esp)
  102b10:	e8 21 ff ff ff       	call   102a36 <pa2page>
}
  102b15:	c9                   	leave  
  102b16:	c3                   	ret    

00102b17 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102b17:	55                   	push   %ebp
  102b18:	89 e5                	mov    %esp,%ebp
  102b1a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102b20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b25:	89 04 24             	mov    %eax,(%esp)
  102b28:	e8 09 ff ff ff       	call   102a36 <pa2page>
}
  102b2d:	c9                   	leave  
  102b2e:	c3                   	ret    

00102b2f <page_ref>:

static inline int
page_ref(struct Page *page) {
  102b2f:	55                   	push   %ebp
  102b30:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102b32:	8b 45 08             	mov    0x8(%ebp),%eax
  102b35:	8b 00                	mov    (%eax),%eax
}
  102b37:	5d                   	pop    %ebp
  102b38:	c3                   	ret    

00102b39 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102b39:	55                   	push   %ebp
  102b3a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b42:	89 10                	mov    %edx,(%eax)
}
  102b44:	90                   	nop
  102b45:	5d                   	pop    %ebp
  102b46:	c3                   	ret    

00102b47 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102b47:	55                   	push   %ebp
  102b48:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b4d:	8b 00                	mov    (%eax),%eax
  102b4f:	8d 50 01             	lea    0x1(%eax),%edx
  102b52:	8b 45 08             	mov    0x8(%ebp),%eax
  102b55:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b57:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5a:	8b 00                	mov    (%eax),%eax
}
  102b5c:	5d                   	pop    %ebp
  102b5d:	c3                   	ret    

00102b5e <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102b5e:	55                   	push   %ebp
  102b5f:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102b61:	8b 45 08             	mov    0x8(%ebp),%eax
  102b64:	8b 00                	mov    (%eax),%eax
  102b66:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b69:	8b 45 08             	mov    0x8(%ebp),%eax
  102b6c:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b71:	8b 00                	mov    (%eax),%eax
}
  102b73:	5d                   	pop    %ebp
  102b74:	c3                   	ret    

00102b75 <__intr_save>:
__intr_save(void) {     //TS自旋锁机制
  102b75:	55                   	push   %ebp
  102b76:	89 e5                	mov    %esp,%ebp
  102b78:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102b7b:	9c                   	pushf  
  102b7c:	58                   	pop    %eax
  102b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
  102b83:	25 00 02 00 00       	and    $0x200,%eax
  102b88:	85 c0                	test   %eax,%eax
  102b8a:	74 0c                	je     102b98 <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
  102b8c:	e8 1f ed ff ff       	call   1018b0 <intr_disable>
        return 1;
  102b91:	b8 01 00 00 00       	mov    $0x1,%eax
  102b96:	eb 05                	jmp    102b9d <__intr_save+0x28>
    return 0;       //否则表明中断标志位为0
  102b98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102b9d:	c9                   	leave  
  102b9e:	c3                   	ret    

00102b9f <__intr_restore>:
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
  102b9f:	55                   	push   %ebp
  102ba0:	89 e5                	mov    %esp,%ebp
  102ba2:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102ba5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102ba9:	74 05                	je     102bb0 <__intr_restore+0x11>
        intr_enable();
  102bab:	e8 f9 ec ff ff       	call   1018a9 <intr_enable>
}
  102bb0:	90                   	nop
  102bb1:	c9                   	leave  
  102bb2:	c3                   	ret    

00102bb3 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102bb3:	55                   	push   %ebp
  102bb4:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb9:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102bbc:	b8 23 00 00 00       	mov    $0x23,%eax
  102bc1:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102bc3:	b8 23 00 00 00       	mov    $0x23,%eax
  102bc8:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102bca:	b8 10 00 00 00       	mov    $0x10,%eax
  102bcf:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102bd1:	b8 10 00 00 00       	mov    $0x10,%eax
  102bd6:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102bd8:	b8 10 00 00 00       	mov    $0x10,%eax
  102bdd:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102bdf:	ea e6 2b 10 00 08 00 	ljmp   $0x8,$0x102be6
}
  102be6:	90                   	nop
  102be7:	5d                   	pop    %ebp
  102be8:	c3                   	ret    

00102be9 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102be9:	55                   	push   %ebp
  102bea:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102bec:	8b 45 08             	mov    0x8(%ebp),%eax
  102bef:	a3 a4 be 11 00       	mov    %eax,0x11bea4
}
  102bf4:	90                   	nop
  102bf5:	5d                   	pop    %ebp
  102bf6:	c3                   	ret    

00102bf7 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102bf7:	55                   	push   %ebp
  102bf8:	89 e5                	mov    %esp,%ebp
  102bfa:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102bfd:	b8 00 80 11 00       	mov    $0x118000,%eax
  102c02:	89 04 24             	mov    %eax,(%esp)
  102c05:	e8 df ff ff ff       	call   102be9 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102c0a:	66 c7 05 a8 be 11 00 	movw   $0x10,0x11bea8
  102c11:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102c13:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  102c1a:	68 00 
  102c1c:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102c21:	0f b7 c0             	movzwl %ax,%eax
  102c24:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  102c2a:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102c2f:	c1 e8 10             	shr    $0x10,%eax
  102c32:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  102c37:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c3e:	24 f0                	and    $0xf0,%al
  102c40:	0c 09                	or     $0x9,%al
  102c42:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c47:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c4e:	24 ef                	and    $0xef,%al
  102c50:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c55:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c5c:	24 9f                	and    $0x9f,%al
  102c5e:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c63:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c6a:	0c 80                	or     $0x80,%al
  102c6c:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c71:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102c78:	24 f0                	and    $0xf0,%al
  102c7a:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102c7f:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102c86:	24 ef                	and    $0xef,%al
  102c88:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102c8d:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102c94:	24 df                	and    $0xdf,%al
  102c96:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102c9b:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102ca2:	0c 40                	or     $0x40,%al
  102ca4:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102ca9:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102cb0:	24 7f                	and    $0x7f,%al
  102cb2:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102cb7:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102cbc:	c1 e8 18             	shr    $0x18,%eax
  102cbf:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102cc4:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
  102ccb:	e8 e3 fe ff ff       	call   102bb3 <lgdt>
  102cd0:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102cd6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102cda:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102cdd:	90                   	nop
  102cde:	c9                   	leave  
  102cdf:	c3                   	ret    

00102ce0 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102ce0:	55                   	push   %ebp
  102ce1:	89 e5                	mov    %esp,%ebp
  102ce3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102ce6:	c7 05 10 bf 11 00 d0 	movl   $0x1071d0,0x11bf10
  102ced:	71 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102cf0:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102cf5:	8b 00                	mov    (%eax),%eax
  102cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102cfb:	c7 04 24 70 68 10 00 	movl   $0x106870,(%esp)
  102d02:	e8 9b d5 ff ff       	call   1002a2 <cprintf>
    pmm_manager->init();
  102d07:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d0c:	8b 40 04             	mov    0x4(%eax),%eax
  102d0f:	ff d0                	call   *%eax
}
  102d11:	90                   	nop
  102d12:	c9                   	leave  
  102d13:	c3                   	ret    

00102d14 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
  102d14:	55                   	push   %ebp
  102d15:	89 e5                	mov    %esp,%ebp
  102d17:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102d1a:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d1f:	8b 40 08             	mov    0x8(%eax),%eax
  102d22:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d25:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d29:	8b 55 08             	mov    0x8(%ebp),%edx
  102d2c:	89 14 24             	mov    %edx,(%esp)
  102d2f:	ff d0                	call   *%eax
}
  102d31:	90                   	nop
  102d32:	c9                   	leave  
  102d33:	c3                   	ret    

00102d34 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
//分配连续的n个pagesize大小的内存空间，问题是为什么对页表的相关函数调用都需要先关闭中断呢？？？？
struct Page *
alloc_pages(size_t n) {
  102d34:	55                   	push   %ebp
  102d35:	89 e5                	mov    %esp,%ebp
  102d37:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag); //在sync中定义的函数，先关闭中断，再调用pmm_manager 的alloc_pages()函数进行页分配
  102d41:	e8 2f fe ff ff       	call   102b75 <__intr_save>
  102d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102d49:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d4e:	8b 40 0c             	mov    0xc(%eax),%eax
  102d51:	8b 55 08             	mov    0x8(%ebp),%edx
  102d54:	89 14 24             	mov    %edx,(%esp)
  102d57:	ff d0                	call   *%eax
  102d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);//开启中断
  102d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d5f:	89 04 24             	mov    %eax,(%esp)
  102d62:	e8 38 fe ff ff       	call   102b9f <__intr_restore>
    return page;
  102d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102d6a:	c9                   	leave  
  102d6b:	c3                   	ret    

00102d6c <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//释放n个pagesize大小的内存
void
free_pages(struct Page *base, size_t n) {
  102d6c:	55                   	push   %ebp
  102d6d:	89 e5                	mov    %esp,%ebp
  102d6f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102d72:	e8 fe fd ff ff       	call   102b75 <__intr_save>
  102d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102d7a:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d7f:	8b 40 10             	mov    0x10(%eax),%eax
  102d82:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d85:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d89:	8b 55 08             	mov    0x8(%ebp),%edx
  102d8c:	89 14 24             	mov    %edx,(%esp)
  102d8f:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d94:	89 04 24             	mov    %eax,(%esp)
  102d97:	e8 03 fe ff ff       	call   102b9f <__intr_restore>
}
  102d9c:	90                   	nop
  102d9d:	c9                   	leave  
  102d9e:	c3                   	ret    

00102d9f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
//获取当前的空闲页数量
size_t
nr_free_pages(void) {
  102d9f:	55                   	push   %ebp
  102da0:	89 e5                	mov    %esp,%ebp
  102da2:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102da5:	e8 cb fd ff ff       	call   102b75 <__intr_save>
  102daa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102dad:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102db2:	8b 40 14             	mov    0x14(%eax),%eax
  102db5:	ff d0                	call   *%eax
  102db7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dbd:	89 04 24             	mov    %eax,(%esp)
  102dc0:	e8 da fd ff ff       	call   102b9f <__intr_restore>
    return ret;
  102dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102dc8:	c9                   	leave  
  102dc9:	c3                   	ret    

00102dca <page_init>:

/* pmm_init - initialize the physical memory management */
// 初始化pmm
static void
page_init(void) {
  102dca:	55                   	push   %ebp
  102dcb:	89 e5                	mov    %esp,%ebp
  102dcd:	57                   	push   %edi
  102dce:	56                   	push   %esi
  102dcf:	53                   	push   %ebx
  102dd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    //申明一个e820map变量，从0x8000开始
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102dd6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102ddd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102de4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102deb:	c7 04 24 87 68 10 00 	movl   $0x106887,(%esp)
  102df2:	e8 ab d4 ff ff       	call   1002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102df7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102dfe:	e9 22 01 00 00       	jmp    102f25 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e03:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e06:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e09:	89 d0                	mov    %edx,%eax
  102e0b:	c1 e0 02             	shl    $0x2,%eax
  102e0e:	01 d0                	add    %edx,%eax
  102e10:	c1 e0 02             	shl    $0x2,%eax
  102e13:	01 c8                	add    %ecx,%eax
  102e15:	8b 50 08             	mov    0x8(%eax),%edx
  102e18:	8b 40 04             	mov    0x4(%eax),%eax
  102e1b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102e1e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102e21:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e24:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e27:	89 d0                	mov    %edx,%eax
  102e29:	c1 e0 02             	shl    $0x2,%eax
  102e2c:	01 d0                	add    %edx,%eax
  102e2e:	c1 e0 02             	shl    $0x2,%eax
  102e31:	01 c8                	add    %ecx,%eax
  102e33:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e36:	8b 58 10             	mov    0x10(%eax),%ebx
  102e39:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e3c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e3f:	01 c8                	add    %ecx,%eax
  102e41:	11 da                	adc    %ebx,%edx
  102e43:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e46:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102e49:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e4f:	89 d0                	mov    %edx,%eax
  102e51:	c1 e0 02             	shl    $0x2,%eax
  102e54:	01 d0                	add    %edx,%eax
  102e56:	c1 e0 02             	shl    $0x2,%eax
  102e59:	01 c8                	add    %ecx,%eax
  102e5b:	83 c0 14             	add    $0x14,%eax
  102e5e:	8b 00                	mov    (%eax),%eax
  102e60:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102e63:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e66:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102e69:	83 c0 ff             	add    $0xffffffff,%eax
  102e6c:	83 d2 ff             	adc    $0xffffffff,%edx
  102e6f:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102e75:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102e7b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e81:	89 d0                	mov    %edx,%eax
  102e83:	c1 e0 02             	shl    $0x2,%eax
  102e86:	01 d0                	add    %edx,%eax
  102e88:	c1 e0 02             	shl    $0x2,%eax
  102e8b:	01 c8                	add    %ecx,%eax
  102e8d:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e90:	8b 58 10             	mov    0x10(%eax),%ebx
  102e93:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e96:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102e9a:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102ea0:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102ea6:	89 44 24 14          	mov    %eax,0x14(%esp)
  102eaa:	89 54 24 18          	mov    %edx,0x18(%esp)
  102eae:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102eb1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102eb8:	89 54 24 10          	mov    %edx,0x10(%esp)
  102ebc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102ec0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102ec4:	c7 04 24 94 68 10 00 	movl   $0x106894,(%esp)
  102ecb:	e8 d2 d3 ff ff       	call   1002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {      //用户区内存的第一段，获取交接处的地址
  102ed0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ed3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ed6:	89 d0                	mov    %edx,%eax
  102ed8:	c1 e0 02             	shl    $0x2,%eax
  102edb:	01 d0                	add    %edx,%eax
  102edd:	c1 e0 02             	shl    $0x2,%eax
  102ee0:	01 c8                	add    %ecx,%eax
  102ee2:	83 c0 14             	add    $0x14,%eax
  102ee5:	8b 00                	mov    (%eax),%eax
  102ee7:	83 f8 01             	cmp    $0x1,%eax
  102eea:	75 36                	jne    102f22 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102eef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ef2:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102ef5:	77 2b                	ja     102f22 <page_init+0x158>
  102ef7:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102efa:	72 05                	jb     102f01 <page_init+0x137>
  102efc:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102eff:	73 21                	jae    102f22 <page_init+0x158>
  102f01:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102f05:	77 1b                	ja     102f22 <page_init+0x158>
  102f07:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102f0b:	72 09                	jb     102f16 <page_init+0x14c>
  102f0d:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102f14:	77 0c                	ja     102f22 <page_init+0x158>
                maxpa = end;
  102f16:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f19:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102f1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102f22:	ff 45 dc             	incl   -0x24(%ebp)
  102f25:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102f28:	8b 00                	mov    (%eax),%eax
  102f2a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102f2d:	0f 8c d0 fe ff ff    	jl     102e03 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {   //获得最大的内存地址，从而获取需要管理的内存页个数
  102f33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f37:	72 1d                	jb     102f56 <page_init+0x18c>
  102f39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f3d:	77 09                	ja     102f48 <page_init+0x17e>
  102f3f:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102f46:	76 0e                	jbe    102f56 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102f48:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102f4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;   //获取需要管理的页数
  102f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f5c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102f60:	c1 ea 0c             	shr    $0xc,%edx
  102f63:	89 c1                	mov    %eax,%ecx
  102f65:	89 d3                	mov    %edx,%ebx
  102f67:	89 c8                	mov    %ecx,%eax
  102f69:	a3 80 be 11 00       	mov    %eax,0x11be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //向上取整获取管理内存空间的开始地址
  102f6e:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102f75:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
  102f7a:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f7d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102f80:	01 d0                	add    %edx,%eax
  102f82:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102f85:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102f88:	ba 00 00 00 00       	mov    $0x0,%edx
  102f8d:	f7 75 c0             	divl   -0x40(%ebp)
  102f90:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102f93:	29 d0                	sub    %edx,%eax
  102f95:	a3 18 bf 11 00       	mov    %eax,0x11bf18
    //为所有的页设置保留位为1，即为内核保留的页空间
    for (i = 0; i < npage; i ++) {
  102f9a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102fa1:	eb 2e                	jmp    102fd1 <page_init+0x207>
        SetPageReserved(pages + i);
  102fa3:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
  102fa9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fac:	89 d0                	mov    %edx,%eax
  102fae:	c1 e0 02             	shl    $0x2,%eax
  102fb1:	01 d0                	add    %edx,%eax
  102fb3:	c1 e0 02             	shl    $0x2,%eax
  102fb6:	01 c8                	add    %ecx,%eax
  102fb8:	83 c0 04             	add    $0x4,%eax
  102fbb:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102fc2:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fc5:	8b 45 90             	mov    -0x70(%ebp),%eax
  102fc8:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102fcb:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102fce:	ff 45 dc             	incl   -0x24(%ebp)
  102fd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fd4:	a1 80 be 11 00       	mov    0x11be80,%eax
  102fd9:	39 c2                	cmp    %eax,%edx
  102fdb:	72 c6                	jb     102fa3 <page_init+0x1d9>
    }
//获取空闲内存空间起始地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102fdd:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  102fe3:	89 d0                	mov    %edx,%eax
  102fe5:	c1 e0 02             	shl    $0x2,%eax
  102fe8:	01 d0                	add    %edx,%eax
  102fea:	c1 e0 02             	shl    $0x2,%eax
  102fed:	89 c2                	mov    %eax,%edx
  102fef:	a1 18 bf 11 00       	mov    0x11bf18,%eax
  102ff4:	01 d0                	add    %edx,%eax
  102ff6:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102ff9:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  103000:	77 23                	ja     103025 <page_init+0x25b>
  103002:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103005:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103009:	c7 44 24 08 c4 68 10 	movl   $0x1068c4,0x8(%esp)
  103010:	00 
  103011:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  103018:	00 
  103019:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103020:	e8 d4 d3 ff ff       	call   1003f9 <__panic>
  103025:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103028:	05 00 00 00 40       	add    $0x40000000,%eax
  10302d:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103030:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103037:	e9 69 01 00 00       	jmp    1031a5 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10303c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10303f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103042:	89 d0                	mov    %edx,%eax
  103044:	c1 e0 02             	shl    $0x2,%eax
  103047:	01 d0                	add    %edx,%eax
  103049:	c1 e0 02             	shl    $0x2,%eax
  10304c:	01 c8                	add    %ecx,%eax
  10304e:	8b 50 08             	mov    0x8(%eax),%edx
  103051:	8b 40 04             	mov    0x4(%eax),%eax
  103054:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103057:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10305a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10305d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103060:	89 d0                	mov    %edx,%eax
  103062:	c1 e0 02             	shl    $0x2,%eax
  103065:	01 d0                	add    %edx,%eax
  103067:	c1 e0 02             	shl    $0x2,%eax
  10306a:	01 c8                	add    %ecx,%eax
  10306c:	8b 48 0c             	mov    0xc(%eax),%ecx
  10306f:	8b 58 10             	mov    0x10(%eax),%ebx
  103072:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103075:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103078:	01 c8                	add    %ecx,%eax
  10307a:	11 da                	adc    %ebx,%edx
  10307c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10307f:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  103082:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103085:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103088:	89 d0                	mov    %edx,%eax
  10308a:	c1 e0 02             	shl    $0x2,%eax
  10308d:	01 d0                	add    %edx,%eax
  10308f:	c1 e0 02             	shl    $0x2,%eax
  103092:	01 c8                	add    %ecx,%eax
  103094:	83 c0 14             	add    $0x14,%eax
  103097:	8b 00                	mov    (%eax),%eax
  103099:	83 f8 01             	cmp    $0x1,%eax
  10309c:	0f 85 00 01 00 00    	jne    1031a2 <page_init+0x3d8>
            if (begin < freemem) {
  1030a2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1030a5:	ba 00 00 00 00       	mov    $0x0,%edx
  1030aa:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1030ad:	77 17                	ja     1030c6 <page_init+0x2fc>
  1030af:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1030b2:	72 05                	jb     1030b9 <page_init+0x2ef>
  1030b4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1030b7:	73 0d                	jae    1030c6 <page_init+0x2fc>
                begin = freemem;
  1030b9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1030bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1030c6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030ca:	72 1d                	jb     1030e9 <page_init+0x31f>
  1030cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030d0:	77 09                	ja     1030db <page_init+0x311>
  1030d2:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1030d9:	76 0e                	jbe    1030e9 <page_init+0x31f>
                end = KMEMSIZE;
  1030db:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1030e2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1030e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1030ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1030ef:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030f2:	0f 87 aa 00 00 00    	ja     1031a2 <page_init+0x3d8>
  1030f8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030fb:	72 09                	jb     103106 <page_init+0x33c>
  1030fd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103100:	0f 83 9c 00 00 00    	jae    1031a2 <page_init+0x3d8>
              //获得空闲空间的开始地址和结束地址
  103106:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  10310d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103110:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103113:	01 d0                	add    %edx,%eax
  103115:	48                   	dec    %eax
  103116:	89 45 ac             	mov    %eax,-0x54(%ebp)
  103119:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10311c:	ba 00 00 00 00       	mov    $0x0,%edx
  103121:	f7 75 b0             	divl   -0x50(%ebp)
  103124:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103127:	29 d0                	sub    %edx,%eax
  103129:	ba 00 00 00 00       	mov    $0x0,%edx
  10312e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103131:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                begin = ROUNDUP(begin, PGSIZE);
  103134:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103137:	89 45 a8             	mov    %eax,-0x58(%ebp)
  10313a:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10313d:	ba 00 00 00 00       	mov    $0x0,%edx
  103142:	89 c3                	mov    %eax,%ebx
  103144:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  10314a:	89 de                	mov    %ebx,%esi
  10314c:	89 d0                	mov    %edx,%eax
  10314e:	83 e0 00             	and    $0x0,%eax
  103151:	89 c7                	mov    %eax,%edi
  103153:	89 75 c8             	mov    %esi,-0x38(%ebp)
  103156:	89 7d cc             	mov    %edi,-0x34(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103159:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10315c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10315f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103162:	77 3e                	ja     1031a2 <page_init+0x3d8>
  103164:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103167:	72 05                	jb     10316e <page_init+0x3a4>
  103169:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10316c:	73 34                	jae    1031a2 <page_init+0x3d8>
                if (begin < end) {
  10316e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103171:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103174:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103177:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10317a:	89 c1                	mov    %eax,%ecx
  10317c:	89 d3                	mov    %edx,%ebx
  10317e:	89 c8                	mov    %ecx,%eax
  103180:	89 da                	mov    %ebx,%edx
  103182:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103186:	c1 ea 0c             	shr    $0xc,%edx
  103189:	89 c3                	mov    %eax,%ebx
  10318b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10318e:	89 04 24             	mov    %eax,(%esp)
  103191:	e8 a0 f8 ff ff       	call   102a36 <pa2page>
  103196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10319a:	89 04 24             	mov    %eax,(%esp)
  10319d:	e8 72 fb ff ff       	call   102d14 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  1031a2:	ff 45 dc             	incl   -0x24(%ebp)
  1031a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1031a8:	8b 00                	mov    (%eax),%eax
  1031aa:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1031ad:	0f 8c 89 fe ff ff    	jl     10303c <page_init+0x272>
                  //将page结构中的flags位和引用位ref清零，并加入空闲链表管理
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
  1031b3:	90                   	nop
  1031b4:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1031ba:	5b                   	pop    %ebx
  1031bb:	5e                   	pop    %esi
  1031bc:	5f                   	pop    %edi
  1031bd:	5d                   	pop    %ebp
  1031be:	c3                   	ret    

001031bf <boot_map_segment>:
//boot_map_segment - setup&enable the paging mechanism
// parameters
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
  1031bf:	55                   	push   %ebp
  1031c0:	89 e5                	mov    %esp,%ebp
  1031c2:	83 ec 38             	sub    $0x38,%esp
static void
  1031c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031c8:	33 45 14             	xor    0x14(%ebp),%eax
  1031cb:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031d0:	85 c0                	test   %eax,%eax
  1031d2:	74 24                	je     1031f8 <boot_map_segment+0x39>
  1031d4:	c7 44 24 0c f6 68 10 	movl   $0x1068f6,0xc(%esp)
  1031db:	00 
  1031dc:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1031e3:	00 
  1031e4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  1031eb:	00 
  1031ec:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1031f3:	e8 01 d2 ff ff       	call   1003f9 <__panic>
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1031f8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1031ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  103202:	25 ff 0f 00 00       	and    $0xfff,%eax
  103207:	89 c2                	mov    %eax,%edx
  103209:	8b 45 10             	mov    0x10(%ebp),%eax
  10320c:	01 c2                	add    %eax,%edx
  10320e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103211:	01 d0                	add    %edx,%eax
  103213:	48                   	dec    %eax
  103214:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103217:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10321a:	ba 00 00 00 00       	mov    $0x0,%edx
  10321f:	f7 75 f0             	divl   -0x10(%ebp)
  103222:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103225:	29 d0                	sub    %edx,%eax
  103227:	c1 e8 0c             	shr    $0xc,%eax
  10322a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(PGOFF(la) == PGOFF(pa));
  10322d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103230:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103233:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103236:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10323b:	89 45 0c             	mov    %eax,0xc(%ebp)
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10323e:	8b 45 14             	mov    0x14(%ebp),%eax
  103241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10324c:	89 45 14             	mov    %eax,0x14(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10324f:	eb 68                	jmp    1032b9 <boot_map_segment+0xfa>
    pa = ROUNDDOWN(pa, PGSIZE);
  103251:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103258:	00 
  103259:	8b 45 0c             	mov    0xc(%ebp),%eax
  10325c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103260:	8b 45 08             	mov    0x8(%ebp),%eax
  103263:	89 04 24             	mov    %eax,(%esp)
  103266:	e8 81 01 00 00       	call   1033ec <get_pte>
  10326b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10326e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103272:	75 24                	jne    103298 <boot_map_segment+0xd9>
  103274:	c7 44 24 0c 22 69 10 	movl   $0x106922,0xc(%esp)
  10327b:	00 
  10327c:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103283:	00 
  103284:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  10328b:	00 
  10328c:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103293:	e8 61 d1 ff ff       	call   1003f9 <__panic>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103298:	8b 45 14             	mov    0x14(%ebp),%eax
  10329b:	0b 45 18             	or     0x18(%ebp),%eax
  10329e:	83 c8 01             	or     $0x1,%eax
  1032a1:	89 c2                	mov    %eax,%edx
  1032a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032a6:	89 10                	mov    %edx,(%eax)
    la = ROUNDDOWN(la, PGSIZE);
  1032a8:	ff 4d f4             	decl   -0xc(%ebp)
  1032ab:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1032b2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1032b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032bd:	75 92                	jne    103251 <boot_map_segment+0x92>
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
  1032bf:	90                   	nop
  1032c0:	c9                   	leave  
  1032c1:	c3                   	ret    

001032c2 <boot_alloc_page>:
    }
}

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
  1032c2:	55                   	push   %ebp
  1032c3:	89 e5                	mov    %esp,%ebp
  1032c5:	83 ec 28             	sub    $0x28,%esp
static void *
  1032c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032cf:	e8 60 fa ff ff       	call   102d34 <alloc_pages>
  1032d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
boot_alloc_page(void) {
  1032d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032db:	75 1c                	jne    1032f9 <boot_alloc_page+0x37>
    struct Page *p = alloc_page();
  1032dd:	c7 44 24 08 2f 69 10 	movl   $0x10692f,0x8(%esp)
  1032e4:	00 
  1032e5:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  1032ec:	00 
  1032ed:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1032f4:	e8 00 d1 ff ff       	call   1003f9 <__panic>
    if (p == NULL) {
        panic("boot_alloc_page failed.\n");
  1032f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032fc:	89 04 24             	mov    %eax,(%esp)
  1032ff:	e8 81 f7 ff ff       	call   102a85 <page2kva>
    }
  103304:	c9                   	leave  
  103305:	c3                   	ret    

00103306 <pmm_init>:
    return page2kva(p);
}

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
  103306:	55                   	push   %ebp
  103307:	89 e5                	mov    %esp,%ebp
  103309:	83 ec 38             	sub    $0x38,%esp
void
pmm_init(void) {
  10330c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103311:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103314:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10331b:	77 23                	ja     103340 <pmm_init+0x3a>
  10331d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103320:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103324:	c7 44 24 08 c4 68 10 	movl   $0x1068c4,0x8(%esp)
  10332b:	00 
  10332c:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  103333:	00 
  103334:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10333b:	e8 b9 d0 ff ff       	call   1003f9 <__panic>
  103340:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103343:	05 00 00 00 40       	add    $0x40000000,%eax
  103348:	a3 14 bf 11 00       	mov    %eax,0x11bf14
    boot_cr3 = PADDR(boot_pgdir);

    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
  10334d:	e8 8e f9 ff ff       	call   102ce0 <init_pmm_manager>
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
  103352:	e8 73 fa ff ff       	call   102dca <page_init>
    // then use pmm->init_memmap to create free page list
    page_init();

  103357:	e8 e8 03 00 00       	call   103744 <check_alloc_page>
    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10335c:	e8 02 04 00 00       	call   103763 <check_pgdir>

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
  103361:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103366:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103369:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103370:	77 23                	ja     103395 <pmm_init+0x8f>
  103372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103379:	c7 44 24 08 c4 68 10 	movl   $0x1068c4,0x8(%esp)
  103380:	00 
  103381:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  103388:	00 
  103389:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103390:	e8 64 d0 ff ff       	call   1003f9 <__panic>
  103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103398:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  10339e:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1033a3:	05 ac 0f 00 00       	add    $0xfac,%eax
  1033a8:	83 ca 03             	or     $0x3,%edx
  1033ab:	89 10                	mov    %edx,(%eax)
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;

    // map all physical memory to linear memory with base linear addr KERNBASE
  1033ad:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1033b2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1033b9:	00 
  1033ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1033c1:	00 
  1033c2:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1033c9:	38 
  1033ca:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1033d1:	c0 
  1033d2:	89 04 24             	mov    %eax,(%esp)
  1033d5:	e8 e5 fd ff ff       	call   1031bf <boot_map_segment>
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    //将4MB之外的线性地址映射到物理地址
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
  1033da:	e8 18 f8 ff ff       	call   102bf7 <gdt_init>
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();

  1033df:	e8 1b 0a 00 00       	call   103dff <check_boot_pgdir>
    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
  1033e4:	e8 94 0e 00 00       	call   10427d <print_pgdir>
    check_boot_pgdir();

  1033e9:	90                   	nop
  1033ea:	c9                   	leave  
  1033eb:	c3                   	ret    

001033ec <get_pte>:
//get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
  1033ec:	55                   	push   %ebp
  1033ed:	89 e5                	mov    %esp,%ebp
  1033ef:	83 ec 38             	sub    $0x38,%esp
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
  1033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033f5:	c1 e8 16             	shr    $0x16,%eax
  1033f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1033ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103402:	01 d0                	add    %edx,%eax
  103404:	89 45 f4             	mov    %eax,-0xc(%ebp)
     */
  103407:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10340a:	8b 00                	mov    (%eax),%eax
  10340c:	83 e0 01             	and    $0x1,%eax
  10340f:	85 c0                	test   %eax,%eax
  103411:	0f 85 b9 00 00 00    	jne    1034d0 <get_pte+0xe4>
#if 1
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry   通过参数中的pgdir加上页表目录偏移量（数组方式）获取页表目录地址
  103417:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10341b:	75 0a                	jne    103427 <get_pte+0x3b>
  10341d:	b8 00 00 00 00       	mov    $0x0,%eax
  103422:	e9 06 01 00 00       	jmp    10352d <get_pte+0x141>
    if (!(*pdep&PTE_P)) {              // (2) check if entry is not present
  103427:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10342e:	e8 01 f9 ff ff       	call   102d34 <alloc_pages>
  103433:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct Page*page;
  103436:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10343a:	75 0a                	jne    103446 <get_pte+0x5a>
  10343c:	b8 00 00 00 00       	mov    $0x0,%eax
  103441:	e9 e7 00 00 00       	jmp    10352d <get_pte+0x141>
    if(!create)  return NULL;                // (3) check if creating is needed, then alloc page for page table 不需要分配，直接返回NULL
    page = alloc_page();
  103446:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10344d:	00 
  10344e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103451:	89 04 24             	mov    %eax,(%esp)
  103454:	e8 e0 f6 ff ff       	call   102b39 <set_page_ref>
    if(page==NULL)   return NULL; //没有找到能够分配的页
  103459:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10345c:	89 04 24             	mov    %eax,(%esp)
  10345f:	e8 bc f5 ff ff       	call   102a20 <page2pa>
  103464:	89 45 ec             	mov    %eax,-0x14(%ebp)
                                                          // CAUTION: this page is used for page table, not for common data page
  103467:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10346a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10346d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103470:	c1 e8 0c             	shr    $0xc,%eax
  103473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103476:	a1 80 be 11 00       	mov    0x11be80,%eax
  10347b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10347e:	72 23                	jb     1034a3 <get_pte+0xb7>
  103480:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103487:	c7 44 24 08 20 68 10 	movl   $0x106820,0x8(%esp)
  10348e:	00 
  10348f:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
  103496:	00 
  103497:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10349e:	e8 56 cf ff ff       	call   1003f9 <__panic>
  1034a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034a6:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1034ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1034b2:	00 
  1034b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1034ba:	00 
  1034bb:	89 04 24             	mov    %eax,(%esp)
  1034be:	e8 18 24 00 00       	call   1058db <memset>
    set_page_ref(page,1);     // (4) set page reference
  1034c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034c6:	83 c8 07             	or     $0x7,%eax
  1034c9:	89 c2                	mov    %eax,%edx
  1034cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034ce:	89 10                	mov    %edx,(%eax)
    uintptr_t pa =page2pa(page); // (5) get linear address of page
    memset(KADDR(pa),0,PGSIZE);             // (6) clear page content using memset
  1034d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034d3:	8b 00                	mov    (%eax),%eax
  1034d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1034da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1034dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034e0:	c1 e8 0c             	shr    $0xc,%eax
  1034e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1034e6:	a1 80 be 11 00       	mov    0x11be80,%eax
  1034eb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1034ee:	72 23                	jb     103513 <get_pte+0x127>
  1034f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1034f7:	c7 44 24 08 20 68 10 	movl   $0x106820,0x8(%esp)
  1034fe:	00 
  1034ff:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
  103506:	00 
  103507:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10350e:	e8 e6 ce ff ff       	call   1003f9 <__panic>
  103513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103516:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10351b:	89 c2                	mov    %eax,%edx
  10351d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103520:	c1 e8 0c             	shr    $0xc,%eax
  103523:	25 ff 03 00 00       	and    $0x3ff,%eax
  103528:	c1 e0 02             	shl    $0x2,%eax
  10352b:	01 d0                	add    %edx,%eax
    *pdep =pa|PTE_W|PTE_P|PTE_U;                      // (7) set page directory entry's permission  设置和物理地址，可写，用户可访问，可用位
    }
  10352d:	c9                   	leave  
  10352e:	c3                   	ret    

0010352f <get_page>:
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry  拼接页表项、页表目录、表内偏移，得到物理地址之后转为虚拟地址返回
#endif
}

  10352f:	55                   	push   %ebp
  103530:	89 e5                	mov    %esp,%ebp
  103532:	83 ec 28             	sub    $0x28,%esp
//get_page - get related Page struct for linear address la using PDT pgdir
  103535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10353c:	00 
  10353d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103540:	89 44 24 04          	mov    %eax,0x4(%esp)
  103544:	8b 45 08             	mov    0x8(%ebp),%eax
  103547:	89 04 24             	mov    %eax,(%esp)
  10354a:	e8 9d fe ff ff       	call   1033ec <get_pte>
  10354f:	89 45 f4             	mov    %eax,-0xc(%ebp)
struct Page *
  103552:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103556:	74 08                	je     103560 <get_page+0x31>
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103558:	8b 45 10             	mov    0x10(%ebp),%eax
  10355b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10355e:	89 10                	mov    %edx,(%eax)
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep_store != NULL) {
  103560:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103564:	74 1b                	je     103581 <get_page+0x52>
  103566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103569:	8b 00                	mov    (%eax),%eax
  10356b:	83 e0 01             	and    $0x1,%eax
  10356e:	85 c0                	test   %eax,%eax
  103570:	74 0f                	je     103581 <get_page+0x52>
        *ptep_store = ptep;
  103572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103575:	8b 00                	mov    (%eax),%eax
  103577:	89 04 24             	mov    %eax,(%esp)
  10357a:	e8 5a f5 ff ff       	call   102ad9 <pte2page>
  10357f:	eb 05                	jmp    103586 <get_page+0x57>
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103581:	b8 00 00 00 00       	mov    $0x0,%eax
        return pte2page(*ptep);
  103586:	c9                   	leave  
  103587:	c3                   	ret    

00103588 <page_remove_pte>:
    }
    return NULL;
}

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
  103588:	55                   	push   %ebp
  103589:	89 e5                	mov    %esp,%ebp
  10358b:	83 ec 28             	sub    $0x28,%esp
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 , then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
  10358e:	8b 45 10             	mov    0x10(%ebp),%eax
  103591:	8b 00                	mov    (%eax),%eax
  103593:	83 e0 01             	and    $0x1,%eax
  103596:	85 c0                	test   %eax,%eax
  103598:	74 4d                	je     1035e7 <page_remove_pte+0x5f>
     */
  10359a:	8b 45 10             	mov    0x10(%ebp),%eax
  10359d:	8b 00                	mov    (%eax),%eax
  10359f:	89 04 24             	mov    %eax,(%esp)
  1035a2:	e8 32 f5 ff ff       	call   102ad9 <pte2page>
  1035a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if 1
  1035aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035ad:	89 04 24             	mov    %eax,(%esp)
  1035b0:	e8 a9 f5 ff ff       	call   102b5e <page_ref_dec>
  1035b5:	85 c0                	test   %eax,%eax
  1035b7:	75 13                	jne    1035cc <page_remove_pte+0x44>
    if (*ptep&PTE_P) {                      //(1) check if this page table entry is present   ?
  1035b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1035c0:	00 
  1035c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035c4:	89 04 24             	mov    %eax,(%esp)
  1035c7:	e8 a0 f7 ff ff       	call   102d6c <free_pages>
        struct Page *page =pte2page(*ptep); //(2) find corresponding page to pte
        if(page_ref_dec(page)==0){                          //(3) decrease page reference
  1035cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1035cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            free_page(page);  //(4) and free this page when page reference reachs 0
  1035d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1035df:	89 04 24             	mov    %eax,(%esp)
  1035e2:	e8 01 01 00 00       	call   1036e8 <tlb_invalidate>
        }
        *ptep = 0;                          //(5) clear second page table entry
        tlb_invalidate(pgdir,la);                          //(6) flush tlb
  1035e7:	90                   	nop
  1035e8:	c9                   	leave  
  1035e9:	c3                   	ret    

001035ea <page_remove>:
    }
#endif
}

  1035ea:	55                   	push   %ebp
  1035eb:	89 e5                	mov    %esp,%ebp
  1035ed:	83 ec 28             	sub    $0x28,%esp
//page_remove - free an Page which is related linear address la and has an validated pte
  1035f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035f7:	00 
  1035f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103602:	89 04 24             	mov    %eax,(%esp)
  103605:	e8 e2 fd ff ff       	call   1033ec <get_pte>
  10360a:	89 45 f4             	mov    %eax,-0xc(%ebp)
void
  10360d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103611:	74 19                	je     10362c <page_remove+0x42>
page_remove(pde_t *pgdir, uintptr_t la) {
  103613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103616:	89 44 24 08          	mov    %eax,0x8(%esp)
  10361a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10361d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103621:	8b 45 08             	mov    0x8(%ebp),%eax
  103624:	89 04 24             	mov    %eax,(%esp)
  103627:	e8 5c ff ff ff       	call   103588 <page_remove_pte>
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL) {
  10362c:	90                   	nop
  10362d:	c9                   	leave  
  10362e:	c3                   	ret    

0010362f <page_insert>:
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
  10362f:	55                   	push   %ebp
  103630:	89 e5                	mov    %esp,%ebp
  103632:	83 ec 28             	sub    $0x28,%esp
//note: PT is changed, so the TLB need to be invalidate
  103635:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10363c:	00 
  10363d:	8b 45 10             	mov    0x10(%ebp),%eax
  103640:	89 44 24 04          	mov    %eax,0x4(%esp)
  103644:	8b 45 08             	mov    0x8(%ebp),%eax
  103647:	89 04 24             	mov    %eax,(%esp)
  10364a:	e8 9d fd ff ff       	call   1033ec <get_pte>
  10364f:	89 45 f4             	mov    %eax,-0xc(%ebp)
int
  103652:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103656:	75 0a                	jne    103662 <page_insert+0x33>
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103658:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10365d:	e9 84 00 00 00       	jmp    1036e6 <page_insert+0xb7>
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
  103662:	8b 45 0c             	mov    0xc(%ebp),%eax
  103665:	89 04 24             	mov    %eax,(%esp)
  103668:	e8 da f4 ff ff       	call   102b47 <page_ref_inc>
        return -E_NO_MEM;
  10366d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103670:	8b 00                	mov    (%eax),%eax
  103672:	83 e0 01             	and    $0x1,%eax
  103675:	85 c0                	test   %eax,%eax
  103677:	74 3e                	je     1036b7 <page_insert+0x88>
    }
  103679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10367c:	8b 00                	mov    (%eax),%eax
  10367e:	89 04 24             	mov    %eax,(%esp)
  103681:	e8 53 f4 ff ff       	call   102ad9 <pte2page>
  103686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    page_ref_inc(page);
  103689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10368c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10368f:	75 0d                	jne    10369e <page_insert+0x6f>
    if (*ptep & PTE_P) {
  103691:	8b 45 0c             	mov    0xc(%ebp),%eax
  103694:	89 04 24             	mov    %eax,(%esp)
  103697:	e8 c2 f4 ff ff       	call   102b5e <page_ref_dec>
  10369c:	eb 19                	jmp    1036b7 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
  10369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1036a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1036a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1036af:	89 04 24             	mov    %eax,(%esp)
  1036b2:	e8 d1 fe ff ff       	call   103588 <page_remove_pte>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1036b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036ba:	89 04 24             	mov    %eax,(%esp)
  1036bd:	e8 5e f3 ff ff       	call   102a20 <page2pa>
  1036c2:	0b 45 14             	or     0x14(%ebp),%eax
  1036c5:	83 c8 01             	or     $0x1,%eax
  1036c8:	89 c2                	mov    %eax,%edx
  1036ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036cd:	89 10                	mov    %edx,(%eax)
        }
  1036cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1036d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1036d9:	89 04 24             	mov    %eax,(%esp)
  1036dc:	e8 07 00 00 00       	call   1036e8 <tlb_invalidate>
    }
  1036e1:	b8 00 00 00 00       	mov    $0x0,%eax
    *ptep = page2pa(page) | PTE_P | perm;
  1036e6:	c9                   	leave  
  1036e7:	c3                   	ret    

001036e8 <tlb_invalidate>:
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
  1036e8:	55                   	push   %ebp
  1036e9:	89 e5                	mov    %esp,%ebp
  1036eb:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1036ee:	0f 20 d8             	mov    %cr3,%eax
  1036f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1036f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
// edited are the ones currently in use by the processor.
  1036f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1036fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1036fd:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103704:	77 23                	ja     103729 <tlb_invalidate+0x41>
  103706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103709:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10370d:	c7 44 24 08 c4 68 10 	movl   $0x1068c4,0x8(%esp)
  103714:	00 
  103715:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
  10371c:	00 
  10371d:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103724:	e8 d0 cc ff ff       	call   1003f9 <__panic>
  103729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10372c:	05 00 00 00 40       	add    $0x40000000,%eax
  103731:	39 d0                	cmp    %edx,%eax
  103733:	75 0c                	jne    103741 <tlb_invalidate+0x59>
void
  103735:	8b 45 0c             	mov    0xc(%ebp),%eax
  103738:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10373b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10373e:	0f 01 38             	invlpg (%eax)
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
  103741:	90                   	nop
  103742:	c9                   	leave  
  103743:	c3                   	ret    

00103744 <check_alloc_page>:
        invlpg((void *)la);
    }
}
  103744:	55                   	push   %ebp
  103745:	89 e5                	mov    %esp,%ebp
  103747:	83 ec 18             	sub    $0x18,%esp

  10374a:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  10374f:	8b 40 18             	mov    0x18(%eax),%eax
  103752:	ff d0                	call   *%eax
static void
  103754:	c7 04 24 48 69 10 00 	movl   $0x106948,(%esp)
  10375b:	e8 42 cb ff ff       	call   1002a2 <cprintf>
check_alloc_page(void) {
  103760:	90                   	nop
  103761:	c9                   	leave  
  103762:	c3                   	ret    

00103763 <check_pgdir>:
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
  103763:	55                   	push   %ebp
  103764:	89 e5                	mov    %esp,%ebp
  103766:	83 ec 38             	sub    $0x38,%esp

  103769:	a1 80 be 11 00       	mov    0x11be80,%eax
  10376e:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103773:	76 24                	jbe    103799 <check_pgdir+0x36>
  103775:	c7 44 24 0c 67 69 10 	movl   $0x106967,0xc(%esp)
  10377c:	00 
  10377d:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103784:	00 
  103785:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  10378c:	00 
  10378d:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103794:	e8 60 cc ff ff       	call   1003f9 <__panic>
static void
  103799:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10379e:	85 c0                	test   %eax,%eax
  1037a0:	74 0e                	je     1037b0 <check_pgdir+0x4d>
  1037a2:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037a7:	25 ff 0f 00 00       	and    $0xfff,%eax
  1037ac:	85 c0                	test   %eax,%eax
  1037ae:	74 24                	je     1037d4 <check_pgdir+0x71>
  1037b0:	c7 44 24 0c 84 69 10 	movl   $0x106984,0xc(%esp)
  1037b7:	00 
  1037b8:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1037bf:	00 
  1037c0:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  1037c7:	00 
  1037c8:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1037cf:	e8 25 cc ff ff       	call   1003f9 <__panic>
check_pgdir(void) {
  1037d4:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037e0:	00 
  1037e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1037e8:	00 
  1037e9:	89 04 24             	mov    %eax,(%esp)
  1037ec:	e8 3e fd ff ff       	call   10352f <get_page>
  1037f1:	85 c0                	test   %eax,%eax
  1037f3:	74 24                	je     103819 <check_pgdir+0xb6>
  1037f5:	c7 44 24 0c bc 69 10 	movl   $0x1069bc,0xc(%esp)
  1037fc:	00 
  1037fd:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103804:	00 
  103805:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  10380c:	00 
  10380d:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103814:	e8 e0 cb ff ff       	call   1003f9 <__panic>
    assert(npage <= KMEMSIZE / PGSIZE);
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103819:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103820:	e8 0f f5 ff ff       	call   102d34 <alloc_pages>
  103825:	89 45 f4             	mov    %eax,-0xc(%ebp)

  103828:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10382d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103834:	00 
  103835:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10383c:	00 
  10383d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103840:	89 54 24 04          	mov    %edx,0x4(%esp)
  103844:	89 04 24             	mov    %eax,(%esp)
  103847:	e8 e3 fd ff ff       	call   10362f <page_insert>
  10384c:	85 c0                	test   %eax,%eax
  10384e:	74 24                	je     103874 <check_pgdir+0x111>
  103850:	c7 44 24 0c e4 69 10 	movl   $0x1069e4,0xc(%esp)
  103857:	00 
  103858:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  10385f:	00 
  103860:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  103867:	00 
  103868:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10386f:	e8 85 cb ff ff       	call   1003f9 <__panic>
    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103874:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103879:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103880:	00 
  103881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103888:	00 
  103889:	89 04 24             	mov    %eax,(%esp)
  10388c:	e8 5b fb ff ff       	call   1033ec <get_pte>
  103891:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103894:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103898:	75 24                	jne    1038be <check_pgdir+0x15b>
  10389a:	c7 44 24 0c 10 6a 10 	movl   $0x106a10,0xc(%esp)
  1038a1:	00 
  1038a2:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1038a9:	00 
  1038aa:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1038b1:	00 
  1038b2:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1038b9:	e8 3b cb ff ff       	call   1003f9 <__panic>

  1038be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038c1:	8b 00                	mov    (%eax),%eax
  1038c3:	89 04 24             	mov    %eax,(%esp)
  1038c6:	e8 0e f2 ff ff       	call   102ad9 <pte2page>
  1038cb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1038ce:	74 24                	je     1038f4 <check_pgdir+0x191>
  1038d0:	c7 44 24 0c 3d 6a 10 	movl   $0x106a3d,0xc(%esp)
  1038d7:	00 
  1038d8:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1038df:	00 
  1038e0:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  1038e7:	00 
  1038e8:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1038ef:	e8 05 cb ff ff       	call   1003f9 <__panic>
    pte_t *ptep;
  1038f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038f7:	89 04 24             	mov    %eax,(%esp)
  1038fa:	e8 30 f2 ff ff       	call   102b2f <page_ref>
  1038ff:	83 f8 01             	cmp    $0x1,%eax
  103902:	74 24                	je     103928 <check_pgdir+0x1c5>
  103904:	c7 44 24 0c 53 6a 10 	movl   $0x106a53,0xc(%esp)
  10390b:	00 
  10390c:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103913:	00 
  103914:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  10391b:	00 
  10391c:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103923:	e8 d1 ca ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
  103928:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10392d:	8b 00                	mov    (%eax),%eax
  10392f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103937:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10393a:	c1 e8 0c             	shr    $0xc,%eax
  10393d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103940:	a1 80 be 11 00       	mov    0x11be80,%eax
  103945:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103948:	72 23                	jb     10396d <check_pgdir+0x20a>
  10394a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10394d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103951:	c7 44 24 08 20 68 10 	movl   $0x106820,0x8(%esp)
  103958:	00 
  103959:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103960:	00 
  103961:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103968:	e8 8c ca ff ff       	call   1003f9 <__panic>
  10396d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103970:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103975:	83 c0 04             	add    $0x4,%eax
  103978:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(page_ref(p1) == 1);
  10397b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103980:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103987:	00 
  103988:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10398f:	00 
  103990:	89 04 24             	mov    %eax,(%esp)
  103993:	e8 54 fa ff ff       	call   1033ec <get_pte>
  103998:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  10399b:	74 24                	je     1039c1 <check_pgdir+0x25e>
  10399d:	c7 44 24 0c 68 6a 10 	movl   $0x106a68,0xc(%esp)
  1039a4:	00 
  1039a5:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1039ac:	00 
  1039ad:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  1039b4:	00 
  1039b5:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1039bc:	e8 38 ca ff ff       	call   1003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1039c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039c8:	e8 67 f3 ff ff       	call   102d34 <alloc_pages>
  1039cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1039d0:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1039d5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  1039dc:	00 
  1039dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1039e4:	00 
  1039e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1039e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1039ec:	89 04 24             	mov    %eax,(%esp)
  1039ef:	e8 3b fc ff ff       	call   10362f <page_insert>
  1039f4:	85 c0                	test   %eax,%eax
  1039f6:	74 24                	je     103a1c <check_pgdir+0x2b9>
  1039f8:	c7 44 24 0c 90 6a 10 	movl   $0x106a90,0xc(%esp)
  1039ff:	00 
  103a00:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103a07:	00 
  103a08:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103a0f:	00 
  103a10:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103a17:	e8 dd c9 ff ff       	call   1003f9 <__panic>

  103a1c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103a21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a28:	00 
  103a29:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a30:	00 
  103a31:	89 04 24             	mov    %eax,(%esp)
  103a34:	e8 b3 f9 ff ff       	call   1033ec <get_pte>
  103a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a40:	75 24                	jne    103a66 <check_pgdir+0x303>
  103a42:	c7 44 24 0c c8 6a 10 	movl   $0x106ac8,0xc(%esp)
  103a49:	00 
  103a4a:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103a51:	00 
  103a52:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103a59:	00 
  103a5a:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103a61:	e8 93 c9 ff ff       	call   1003f9 <__panic>
    p2 = alloc_page();
  103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a69:	8b 00                	mov    (%eax),%eax
  103a6b:	83 e0 04             	and    $0x4,%eax
  103a6e:	85 c0                	test   %eax,%eax
  103a70:	75 24                	jne    103a96 <check_pgdir+0x333>
  103a72:	c7 44 24 0c f8 6a 10 	movl   $0x106af8,0xc(%esp)
  103a79:	00 
  103a7a:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103a81:	00 
  103a82:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103a89:	00 
  103a8a:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103a91:	e8 63 c9 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a99:	8b 00                	mov    (%eax),%eax
  103a9b:	83 e0 02             	and    $0x2,%eax
  103a9e:	85 c0                	test   %eax,%eax
  103aa0:	75 24                	jne    103ac6 <check_pgdir+0x363>
  103aa2:	c7 44 24 0c 06 6b 10 	movl   $0x106b06,0xc(%esp)
  103aa9:	00 
  103aaa:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103ab1:	00 
  103ab2:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103ab9:	00 
  103aba:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103ac1:	e8 33 c9 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103ac6:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103acb:	8b 00                	mov    (%eax),%eax
  103acd:	83 e0 04             	and    $0x4,%eax
  103ad0:	85 c0                	test   %eax,%eax
  103ad2:	75 24                	jne    103af8 <check_pgdir+0x395>
  103ad4:	c7 44 24 0c 14 6b 10 	movl   $0x106b14,0xc(%esp)
  103adb:	00 
  103adc:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103ae3:	00 
  103ae4:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103aeb:	00 
  103aec:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103af3:	e8 01 c9 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_U);
  103af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103afb:	89 04 24             	mov    %eax,(%esp)
  103afe:	e8 2c f0 ff ff       	call   102b2f <page_ref>
  103b03:	83 f8 01             	cmp    $0x1,%eax
  103b06:	74 24                	je     103b2c <check_pgdir+0x3c9>
  103b08:	c7 44 24 0c 2a 6b 10 	movl   $0x106b2a,0xc(%esp)
  103b0f:	00 
  103b10:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103b17:	00 
  103b18:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103b1f:	00 
  103b20:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103b27:	e8 cd c8 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
  103b2c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103b31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103b38:	00 
  103b39:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103b40:	00 
  103b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b44:	89 54 24 04          	mov    %edx,0x4(%esp)
  103b48:	89 04 24             	mov    %eax,(%esp)
  103b4b:	e8 df fa ff ff       	call   10362f <page_insert>
  103b50:	85 c0                	test   %eax,%eax
  103b52:	74 24                	je     103b78 <check_pgdir+0x415>
  103b54:	c7 44 24 0c 3c 6b 10 	movl   $0x106b3c,0xc(%esp)
  103b5b:	00 
  103b5c:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103b63:	00 
  103b64:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103b6b:	00 
  103b6c:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103b73:	e8 81 c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 1);
  103b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b7b:	89 04 24             	mov    %eax,(%esp)
  103b7e:	e8 ac ef ff ff       	call   102b2f <page_ref>
  103b83:	83 f8 02             	cmp    $0x2,%eax
  103b86:	74 24                	je     103bac <check_pgdir+0x449>
  103b88:	c7 44 24 0c 68 6b 10 	movl   $0x106b68,0xc(%esp)
  103b8f:	00 
  103b90:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103b97:	00 
  103b98:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  103b9f:	00 
  103ba0:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103ba7:	e8 4d c8 ff ff       	call   1003f9 <__panic>

  103bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103baf:	89 04 24             	mov    %eax,(%esp)
  103bb2:	e8 78 ef ff ff       	call   102b2f <page_ref>
  103bb7:	85 c0                	test   %eax,%eax
  103bb9:	74 24                	je     103bdf <check_pgdir+0x47c>
  103bbb:	c7 44 24 0c 7a 6b 10 	movl   $0x106b7a,0xc(%esp)
  103bc2:	00 
  103bc3:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103bca:	00 
  103bcb:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  103bd2:	00 
  103bd3:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103bda:	e8 1a c8 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103bdf:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103be4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103beb:	00 
  103bec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103bf3:	00 
  103bf4:	89 04 24             	mov    %eax,(%esp)
  103bf7:	e8 f0 f7 ff ff       	call   1033ec <get_pte>
  103bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103bff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103c03:	75 24                	jne    103c29 <check_pgdir+0x4c6>
  103c05:	c7 44 24 0c c8 6a 10 	movl   $0x106ac8,0xc(%esp)
  103c0c:	00 
  103c0d:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103c14:	00 
  103c15:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103c1c:	00 
  103c1d:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103c24:	e8 d0 c7 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 2);
  103c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c2c:	8b 00                	mov    (%eax),%eax
  103c2e:	89 04 24             	mov    %eax,(%esp)
  103c31:	e8 a3 ee ff ff       	call   102ad9 <pte2page>
  103c36:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103c39:	74 24                	je     103c5f <check_pgdir+0x4fc>
  103c3b:	c7 44 24 0c 3d 6a 10 	movl   $0x106a3d,0xc(%esp)
  103c42:	00 
  103c43:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103c4a:	00 
  103c4b:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103c52:	00 
  103c53:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103c5a:	e8 9a c7 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c62:	8b 00                	mov    (%eax),%eax
  103c64:	83 e0 04             	and    $0x4,%eax
  103c67:	85 c0                	test   %eax,%eax
  103c69:	74 24                	je     103c8f <check_pgdir+0x52c>
  103c6b:	c7 44 24 0c 8c 6b 10 	movl   $0x106b8c,0xc(%esp)
  103c72:	00 
  103c73:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103c7a:	00 
  103c7b:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103c82:	00 
  103c83:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103c8a:	e8 6a c7 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
  103c8f:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103c9b:	00 
  103c9c:	89 04 24             	mov    %eax,(%esp)
  103c9f:	e8 46 f9 ff ff       	call   1035ea <page_remove>
    assert((*ptep & PTE_U) == 0);
  103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ca7:	89 04 24             	mov    %eax,(%esp)
  103caa:	e8 80 ee ff ff       	call   102b2f <page_ref>
  103caf:	83 f8 01             	cmp    $0x1,%eax
  103cb2:	74 24                	je     103cd8 <check_pgdir+0x575>
  103cb4:	c7 44 24 0c 53 6a 10 	movl   $0x106a53,0xc(%esp)
  103cbb:	00 
  103cbc:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103cc3:	00 
  103cc4:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103ccb:	00 
  103ccc:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103cd3:	e8 21 c7 ff ff       	call   1003f9 <__panic>

  103cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cdb:	89 04 24             	mov    %eax,(%esp)
  103cde:	e8 4c ee ff ff       	call   102b2f <page_ref>
  103ce3:	85 c0                	test   %eax,%eax
  103ce5:	74 24                	je     103d0b <check_pgdir+0x5a8>
  103ce7:	c7 44 24 0c 7a 6b 10 	movl   $0x106b7a,0xc(%esp)
  103cee:	00 
  103cef:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103cf6:	00 
  103cf7:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  103cfe:	00 
  103cff:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103d06:	e8 ee c6 ff ff       	call   1003f9 <__panic>
    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
  103d0b:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103d10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103d17:	00 
  103d18:	89 04 24             	mov    %eax,(%esp)
  103d1b:	e8 ca f8 ff ff       	call   1035ea <page_remove>
    assert(page_ref(p2) == 0);
  103d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d23:	89 04 24             	mov    %eax,(%esp)
  103d26:	e8 04 ee ff ff       	call   102b2f <page_ref>
  103d2b:	85 c0                	test   %eax,%eax
  103d2d:	74 24                	je     103d53 <check_pgdir+0x5f0>
  103d2f:	c7 44 24 0c a1 6b 10 	movl   $0x106ba1,0xc(%esp)
  103d36:	00 
  103d37:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103d3e:	00 
  103d3f:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  103d46:	00 
  103d47:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103d4e:	e8 a6 c6 ff ff       	call   1003f9 <__panic>

  103d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d56:	89 04 24             	mov    %eax,(%esp)
  103d59:	e8 d1 ed ff ff       	call   102b2f <page_ref>
  103d5e:	85 c0                	test   %eax,%eax
  103d60:	74 24                	je     103d86 <check_pgdir+0x623>
  103d62:	c7 44 24 0c 7a 6b 10 	movl   $0x106b7a,0xc(%esp)
  103d69:	00 
  103d6a:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103d71:	00 
  103d72:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103d79:	00 
  103d7a:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103d81:	e8 73 c6 ff ff       	call   1003f9 <__panic>
    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
  103d86:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103d8b:	8b 00                	mov    (%eax),%eax
  103d8d:	89 04 24             	mov    %eax,(%esp)
  103d90:	e8 82 ed ff ff       	call   102b17 <pde2page>
  103d95:	89 04 24             	mov    %eax,(%esp)
  103d98:	e8 92 ed ff ff       	call   102b2f <page_ref>
  103d9d:	83 f8 01             	cmp    $0x1,%eax
  103da0:	74 24                	je     103dc6 <check_pgdir+0x663>
  103da2:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  103da9:	00 
  103daa:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103db1:	00 
  103db2:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103db9:	00 
  103dba:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103dc1:	e8 33 c6 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103dc6:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103dcb:	8b 00                	mov    (%eax),%eax
  103dcd:	89 04 24             	mov    %eax,(%esp)
  103dd0:	e8 42 ed ff ff       	call   102b17 <pde2page>
  103dd5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103ddc:	00 
  103ddd:	89 04 24             	mov    %eax,(%esp)
  103de0:	e8 87 ef ff ff       	call   102d6c <free_pages>

  103de5:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103dea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
    free_page(pde2page(boot_pgdir[0]));
  103df0:	c7 04 24 db 6b 10 00 	movl   $0x106bdb,(%esp)
  103df7:	e8 a6 c4 ff ff       	call   1002a2 <cprintf>
    boot_pgdir[0] = 0;
  103dfc:	90                   	nop
  103dfd:	c9                   	leave  
  103dfe:	c3                   	ret    

00103dff <check_boot_pgdir>:

    cprintf("check_pgdir() succeeded!\n");
}
  103dff:	55                   	push   %ebp
  103e00:	89 e5                	mov    %esp,%ebp
  103e02:	83 ec 38             	sub    $0x38,%esp

static void
check_boot_pgdir(void) {
  103e05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103e0c:	e9 ca 00 00 00       	jmp    103edb <check_boot_pgdir+0xdc>
    pte_t *ptep;
  103e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e1a:	c1 e8 0c             	shr    $0xc,%eax
  103e1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103e20:	a1 80 be 11 00       	mov    0x11be80,%eax
  103e25:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103e28:	72 23                	jb     103e4d <check_boot_pgdir+0x4e>
  103e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103e31:	c7 44 24 08 20 68 10 	movl   $0x106820,0x8(%esp)
  103e38:	00 
  103e39:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103e40:	00 
  103e41:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103e48:	e8 ac c5 ff ff       	call   1003f9 <__panic>
  103e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e50:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103e55:	89 c2                	mov    %eax,%edx
  103e57:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103e63:	00 
  103e64:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e68:	89 04 24             	mov    %eax,(%esp)
  103e6b:	e8 7c f5 ff ff       	call   1033ec <get_pte>
  103e70:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103e73:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103e77:	75 24                	jne    103e9d <check_boot_pgdir+0x9e>
  103e79:	c7 44 24 0c f8 6b 10 	movl   $0x106bf8,0xc(%esp)
  103e80:	00 
  103e81:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103e88:	00 
  103e89:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103e90:	00 
  103e91:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103e98:	e8 5c c5 ff ff       	call   1003f9 <__panic>
    int i;
  103e9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ea0:	8b 00                	mov    (%eax),%eax
  103ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ea7:	89 c2                	mov    %eax,%edx
  103ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103eac:	39 c2                	cmp    %eax,%edx
  103eae:	74 24                	je     103ed4 <check_boot_pgdir+0xd5>
  103eb0:	c7 44 24 0c 35 6c 10 	movl   $0x106c35,0xc(%esp)
  103eb7:	00 
  103eb8:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103ebf:	00 
  103ec0:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103ec7:	00 
  103ec8:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103ecf:	e8 25 c5 ff ff       	call   1003f9 <__panic>
check_boot_pgdir(void) {
  103ed4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103edb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103ede:	a1 80 be 11 00       	mov    0x11be80,%eax
  103ee3:	39 c2                	cmp    %eax,%edx
  103ee5:	0f 82 26 ff ff ff    	jb     103e11 <check_boot_pgdir+0x12>
    for (i = 0; i < npage; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
  103eeb:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103ef0:	05 ac 0f 00 00       	add    $0xfac,%eax
  103ef5:	8b 00                	mov    (%eax),%eax
  103ef7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103efc:	89 c2                	mov    %eax,%edx
  103efe:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103f03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f06:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103f0d:	77 23                	ja     103f32 <check_boot_pgdir+0x133>
  103f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f16:	c7 44 24 08 c4 68 10 	movl   $0x1068c4,0x8(%esp)
  103f1d:	00 
  103f1e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103f25:	00 
  103f26:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103f2d:	e8 c7 c4 ff ff       	call   1003f9 <__panic>
  103f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f35:	05 00 00 00 40       	add    $0x40000000,%eax
  103f3a:	39 d0                	cmp    %edx,%eax
  103f3c:	74 24                	je     103f62 <check_boot_pgdir+0x163>
  103f3e:	c7 44 24 0c 4c 6c 10 	movl   $0x106c4c,0xc(%esp)
  103f45:	00 
  103f46:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103f4d:	00 
  103f4e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103f55:	00 
  103f56:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103f5d:	e8 97 c4 ff ff       	call   1003f9 <__panic>
    }

  103f62:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103f67:	8b 00                	mov    (%eax),%eax
  103f69:	85 c0                	test   %eax,%eax
  103f6b:	74 24                	je     103f91 <check_boot_pgdir+0x192>
  103f6d:	c7 44 24 0c 80 6c 10 	movl   $0x106c80,0xc(%esp)
  103f74:	00 
  103f75:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103f7c:	00 
  103f7d:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103f84:	00 
  103f85:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103f8c:	e8 68 c4 ff ff       	call   1003f9 <__panic>
    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));

    assert(boot_pgdir[0] == 0);
  103f91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103f98:	e8 97 ed ff ff       	call   102d34 <alloc_pages>
  103f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)

  103fa0:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103fa5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103fac:	00 
  103fad:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103fb4:	00 
  103fb5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103fb8:	89 54 24 04          	mov    %edx,0x4(%esp)
  103fbc:	89 04 24             	mov    %eax,(%esp)
  103fbf:	e8 6b f6 ff ff       	call   10362f <page_insert>
  103fc4:	85 c0                	test   %eax,%eax
  103fc6:	74 24                	je     103fec <check_boot_pgdir+0x1ed>
  103fc8:	c7 44 24 0c 94 6c 10 	movl   $0x106c94,0xc(%esp)
  103fcf:	00 
  103fd0:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  103fd7:	00 
  103fd8:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  103fdf:	00 
  103fe0:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  103fe7:	e8 0d c4 ff ff       	call   1003f9 <__panic>
    struct Page *p;
  103fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fef:	89 04 24             	mov    %eax,(%esp)
  103ff2:	e8 38 eb ff ff       	call   102b2f <page_ref>
  103ff7:	83 f8 01             	cmp    $0x1,%eax
  103ffa:	74 24                	je     104020 <check_boot_pgdir+0x221>
  103ffc:	c7 44 24 0c c2 6c 10 	movl   $0x106cc2,0xc(%esp)
  104003:	00 
  104004:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  10400b:	00 
  10400c:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104013:	00 
  104014:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10401b:	e8 d9 c3 ff ff       	call   1003f9 <__panic>
    p = alloc_page();
  104020:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104025:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10402c:	00 
  10402d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  104034:	00 
  104035:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104038:	89 54 24 04          	mov    %edx,0x4(%esp)
  10403c:	89 04 24             	mov    %eax,(%esp)
  10403f:	e8 eb f5 ff ff       	call   10362f <page_insert>
  104044:	85 c0                	test   %eax,%eax
  104046:	74 24                	je     10406c <check_boot_pgdir+0x26d>
  104048:	c7 44 24 0c d4 6c 10 	movl   $0x106cd4,0xc(%esp)
  10404f:	00 
  104050:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  104057:	00 
  104058:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  10405f:	00 
  104060:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  104067:	e8 8d c3 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10406c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10406f:	89 04 24             	mov    %eax,(%esp)
  104072:	e8 b8 ea ff ff       	call   102b2f <page_ref>
  104077:	83 f8 02             	cmp    $0x2,%eax
  10407a:	74 24                	je     1040a0 <check_boot_pgdir+0x2a1>
  10407c:	c7 44 24 0c 0b 6d 10 	movl   $0x106d0b,0xc(%esp)
  104083:	00 
  104084:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  10408b:	00 
  10408c:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104093:	00 
  104094:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  10409b:	e8 59 c3 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1040a0:	c7 45 e8 1c 6d 10 00 	movl   $0x106d1c,-0x18(%ebp)
    assert(page_ref(p) == 2);
  1040a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1040aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1040ae:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040b5:	e8 57 15 00 00       	call   105611 <strcpy>

  1040ba:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1040c1:	00 
  1040c2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040c9:	e8 ba 15 00 00       	call   105688 <strcmp>
  1040ce:	85 c0                	test   %eax,%eax
  1040d0:	74 24                	je     1040f6 <check_boot_pgdir+0x2f7>
  1040d2:	c7 44 24 0c 34 6d 10 	movl   $0x106d34,0xc(%esp)
  1040d9:	00 
  1040da:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  1040e1:	00 
  1040e2:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  1040e9:	00 
  1040ea:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  1040f1:	e8 03 c3 ff ff       	call   1003f9 <__panic>
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
  1040f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1040f9:	89 04 24             	mov    %eax,(%esp)
  1040fc:	e8 84 e9 ff ff       	call   102a85 <page2kva>
  104101:	05 00 01 00 00       	add    $0x100,%eax
  104106:	c6 00 00             	movb   $0x0,(%eax)
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104109:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104110:	e8 a6 14 00 00       	call   1055bb <strlen>
  104115:	85 c0                	test   %eax,%eax
  104117:	74 24                	je     10413d <check_boot_pgdir+0x33e>
  104119:	c7 44 24 0c 6c 6d 10 	movl   $0x106d6c,0xc(%esp)
  104120:	00 
  104121:	c7 44 24 08 0d 69 10 	movl   $0x10690d,0x8(%esp)
  104128:	00 
  104129:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  104130:	00 
  104131:	c7 04 24 e8 68 10 00 	movl   $0x1068e8,(%esp)
  104138:	e8 bc c2 ff ff       	call   1003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10413d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104144:	00 
  104145:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104148:	89 04 24             	mov    %eax,(%esp)
  10414b:	e8 1c ec ff ff       	call   102d6c <free_pages>
    assert(strlen((const char *)0x100) == 0);
  104150:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104155:	8b 00                	mov    (%eax),%eax
  104157:	89 04 24             	mov    %eax,(%esp)
  10415a:	e8 b8 e9 ff ff       	call   102b17 <pde2page>
  10415f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104166:	00 
  104167:	89 04 24             	mov    %eax,(%esp)
  10416a:	e8 fd eb ff ff       	call   102d6c <free_pages>

  10416f:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104174:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    free_page(p);
    free_page(pde2page(boot_pgdir[0]));
  10417a:	c7 04 24 90 6d 10 00 	movl   $0x106d90,(%esp)
  104181:	e8 1c c1 ff ff       	call   1002a2 <cprintf>
    boot_pgdir[0] = 0;
  104186:	90                   	nop
  104187:	c9                   	leave  
  104188:	c3                   	ret    

00104189 <perm2str>:

    cprintf("check_boot_pgdir() succeeded!\n");
}

  104189:	55                   	push   %ebp
  10418a:	89 e5                	mov    %esp,%ebp
//perm2str - use string 'u,r,w,-' to present the permission
static const char *
  10418c:	8b 45 08             	mov    0x8(%ebp),%eax
  10418f:	83 e0 04             	and    $0x4,%eax
  104192:	85 c0                	test   %eax,%eax
  104194:	74 04                	je     10419a <perm2str+0x11>
  104196:	b0 75                	mov    $0x75,%al
  104198:	eb 02                	jmp    10419c <perm2str+0x13>
  10419a:	b0 2d                	mov    $0x2d,%al
  10419c:	a2 08 bf 11 00       	mov    %al,0x11bf08
perm2str(int perm) {
  1041a1:	c6 05 09 bf 11 00 72 	movb   $0x72,0x11bf09
    static char str[4];
  1041a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1041ab:	83 e0 02             	and    $0x2,%eax
  1041ae:	85 c0                	test   %eax,%eax
  1041b0:	74 04                	je     1041b6 <perm2str+0x2d>
  1041b2:	b0 77                	mov    $0x77,%al
  1041b4:	eb 02                	jmp    1041b8 <perm2str+0x2f>
  1041b6:	b0 2d                	mov    $0x2d,%al
  1041b8:	a2 0a bf 11 00       	mov    %al,0x11bf0a
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1041bd:	c6 05 0b bf 11 00 00 	movb   $0x0,0x11bf0b
    str[1] = 'r';
  1041c4:	b8 08 bf 11 00       	mov    $0x11bf08,%eax
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1041c9:	5d                   	pop    %ebp
  1041ca:	c3                   	ret    

001041cb <get_pgtable_items>:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
  1041cb:	55                   	push   %ebp
  1041cc:	89 e5                	mov    %esp,%ebp
  1041ce:	83 ec 10             	sub    $0x10,%esp
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
  1041d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1041d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041d7:	72 0d                	jb     1041e6 <get_pgtable_items+0x1b>
static int
  1041d9:	b8 00 00 00 00       	mov    $0x0,%eax
  1041de:	e9 98 00 00 00       	jmp    10427b <get_pgtable_items+0xb0>
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
  1041e3:	ff 45 10             	incl   0x10(%ebp)
    if (start >= right) {
  1041e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1041e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041ec:	73 18                	jae    104206 <get_pgtable_items+0x3b>
  1041ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1041f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1041f8:	8b 45 14             	mov    0x14(%ebp),%eax
  1041fb:	01 d0                	add    %edx,%eax
  1041fd:	8b 00                	mov    (%eax),%eax
  1041ff:	83 e0 01             	and    $0x1,%eax
  104202:	85 c0                	test   %eax,%eax
  104204:	74 dd                	je     1041e3 <get_pgtable_items+0x18>
    }
    while (start < right && !(table[start] & PTE_P)) {
  104206:	8b 45 10             	mov    0x10(%ebp),%eax
  104209:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10420c:	73 68                	jae    104276 <get_pgtable_items+0xab>
        start ++;
  10420e:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104212:	74 08                	je     10421c <get_pgtable_items+0x51>
    }
  104214:	8b 45 18             	mov    0x18(%ebp),%eax
  104217:	8b 55 10             	mov    0x10(%ebp),%edx
  10421a:	89 10                	mov    %edx,(%eax)
    if (start < right) {
        if (left_store != NULL) {
  10421c:	8b 45 10             	mov    0x10(%ebp),%eax
  10421f:	8d 50 01             	lea    0x1(%eax),%edx
  104222:	89 55 10             	mov    %edx,0x10(%ebp)
  104225:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10422c:	8b 45 14             	mov    0x14(%ebp),%eax
  10422f:	01 d0                	add    %edx,%eax
  104231:	8b 00                	mov    (%eax),%eax
  104233:	83 e0 07             	and    $0x7,%eax
  104236:	89 45 fc             	mov    %eax,-0x4(%ebp)
            *left_store = start;
  104239:	eb 03                	jmp    10423e <get_pgtable_items+0x73>
        }
  10423b:	ff 45 10             	incl   0x10(%ebp)
            *left_store = start;
  10423e:	8b 45 10             	mov    0x10(%ebp),%eax
  104241:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104244:	73 1d                	jae    104263 <get_pgtable_items+0x98>
  104246:	8b 45 10             	mov    0x10(%ebp),%eax
  104249:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104250:	8b 45 14             	mov    0x14(%ebp),%eax
  104253:	01 d0                	add    %edx,%eax
  104255:	8b 00                	mov    (%eax),%eax
  104257:	83 e0 07             	and    $0x7,%eax
  10425a:	89 c2                	mov    %eax,%edx
  10425c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10425f:	39 c2                	cmp    %eax,%edx
  104261:	74 d8                	je     10423b <get_pgtable_items+0x70>
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  104263:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104267:	74 08                	je     104271 <get_pgtable_items+0xa6>
            start ++;
  104269:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10426c:	8b 55 10             	mov    0x10(%ebp),%edx
  10426f:	89 10                	mov    %edx,(%eax)
        }
        if (right_store != NULL) {
  104271:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104274:	eb 05                	jmp    10427b <get_pgtable_items+0xb0>
            *right_store = start;
        }
  104276:	b8 00 00 00 00       	mov    $0x0,%eax
        return perm;
  10427b:	c9                   	leave  
  10427c:	c3                   	ret    

0010427d <print_pgdir>:
    }
    return 0;
}

  10427d:	55                   	push   %ebp
  10427e:	89 e5                	mov    %esp,%ebp
  104280:	57                   	push   %edi
  104281:	56                   	push   %esi
  104282:	53                   	push   %ebx
  104283:	83 ec 4c             	sub    $0x4c,%esp
//print_pgdir - print the PDT&PT
  104286:	c7 04 24 b0 6d 10 00 	movl   $0x106db0,(%esp)
  10428d:	e8 10 c0 ff ff       	call   1002a2 <cprintf>
void
  104292:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
print_pgdir(void) {
  104299:	e9 fa 00 00 00       	jmp    104398 <print_pgdir+0x11b>
    cprintf("-------------------- BEGIN --------------------\n");
  10429e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042a1:	89 04 24             	mov    %eax,(%esp)
  1042a4:	e8 e0 fe ff ff       	call   104189 <perm2str>
    size_t left, right = 0, perm;
  1042a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1042ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042af:	29 d1                	sub    %edx,%ecx
  1042b1:	89 ca                	mov    %ecx,%edx
    cprintf("-------------------- BEGIN --------------------\n");
  1042b3:	89 d6                	mov    %edx,%esi
  1042b5:	c1 e6 16             	shl    $0x16,%esi
  1042b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042bb:	89 d3                	mov    %edx,%ebx
  1042bd:	c1 e3 16             	shl    $0x16,%ebx
  1042c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042c3:	89 d1                	mov    %edx,%ecx
  1042c5:	c1 e1 16             	shl    $0x16,%ecx
  1042c8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1042cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042ce:	29 d7                	sub    %edx,%edi
  1042d0:	89 fa                	mov    %edi,%edx
  1042d2:	89 44 24 14          	mov    %eax,0x14(%esp)
  1042d6:	89 74 24 10          	mov    %esi,0x10(%esp)
  1042da:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1042de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1042e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1042e6:	c7 04 24 e1 6d 10 00 	movl   $0x106de1,(%esp)
  1042ed:	e8 b0 bf ff ff       	call   1002a2 <cprintf>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1042f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1042f5:	c1 e0 0a             	shl    $0xa,%eax
  1042f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1042fb:	eb 54                	jmp    104351 <print_pgdir+0xd4>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1042fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104300:	89 04 24             	mov    %eax,(%esp)
  104303:	e8 81 fe ff ff       	call   104189 <perm2str>
        size_t l, r = left * NPTEENTRY;
  104308:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10430b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10430e:	29 d1                	sub    %edx,%ecx
  104310:	89 ca                	mov    %ecx,%edx
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104312:	89 d6                	mov    %edx,%esi
  104314:	c1 e6 0c             	shl    $0xc,%esi
  104317:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10431a:	89 d3                	mov    %edx,%ebx
  10431c:	c1 e3 0c             	shl    $0xc,%ebx
  10431f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104322:	89 d1                	mov    %edx,%ecx
  104324:	c1 e1 0c             	shl    $0xc,%ecx
  104327:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10432a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10432d:	29 d7                	sub    %edx,%edi
  10432f:	89 fa                	mov    %edi,%edx
  104331:	89 44 24 14          	mov    %eax,0x14(%esp)
  104335:	89 74 24 10          	mov    %esi,0x10(%esp)
  104339:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10433d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104341:	89 54 24 04          	mov    %edx,0x4(%esp)
  104345:	c7 04 24 00 6e 10 00 	movl   $0x106e00,(%esp)
  10434c:	e8 51 bf ff ff       	call   1002a2 <cprintf>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104351:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  104356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104359:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10435c:	89 d3                	mov    %edx,%ebx
  10435e:	c1 e3 0a             	shl    $0xa,%ebx
  104361:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104364:	89 d1                	mov    %edx,%ecx
  104366:	c1 e1 0a             	shl    $0xa,%ecx
  104369:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  10436c:	89 54 24 14          	mov    %edx,0x14(%esp)
  104370:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104373:	89 54 24 10          	mov    %edx,0x10(%esp)
  104377:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10437b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10437f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104383:	89 0c 24             	mov    %ecx,(%esp)
  104386:	e8 40 fe ff ff       	call   1041cb <get_pgtable_items>
  10438b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10438e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104392:	0f 85 65 ff ff ff    	jne    1042fd <print_pgdir+0x80>
print_pgdir(void) {
  104398:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10439d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043a0:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1043a3:	89 54 24 14          	mov    %edx,0x14(%esp)
  1043a7:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1043aa:	89 54 24 10          	mov    %edx,0x10(%esp)
  1043ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1043b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043b6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1043bd:	00 
  1043be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1043c5:	e8 01 fe ff ff       	call   1041cb <get_pgtable_items>
  1043ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1043cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1043d1:	0f 85 c7 fe ff ff    	jne    10429e <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1043d7:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1043de:	e8 bf be ff ff       	call   1002a2 <cprintf>
        }
  1043e3:	90                   	nop
  1043e4:	83 c4 4c             	add    $0x4c,%esp
  1043e7:	5b                   	pop    %ebx
  1043e8:	5e                   	pop    %esi
  1043e9:	5f                   	pop    %edi
  1043ea:	5d                   	pop    %ebp
  1043eb:	c3                   	ret    

001043ec <page2ppn>:
page2ppn(struct Page *page) {
  1043ec:	55                   	push   %ebp
  1043ed:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1043ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1043f2:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
  1043f8:	29 d0                	sub    %edx,%eax
  1043fa:	c1 f8 02             	sar    $0x2,%eax
  1043fd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104403:	5d                   	pop    %ebp
  104404:	c3                   	ret    

00104405 <page2pa>:
page2pa(struct Page *page) {
  104405:	55                   	push   %ebp
  104406:	89 e5                	mov    %esp,%ebp
  104408:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  10440b:	8b 45 08             	mov    0x8(%ebp),%eax
  10440e:	89 04 24             	mov    %eax,(%esp)
  104411:	e8 d6 ff ff ff       	call   1043ec <page2ppn>
  104416:	c1 e0 0c             	shl    $0xc,%eax
}
  104419:	c9                   	leave  
  10441a:	c3                   	ret    

0010441b <page_ref>:
page_ref(struct Page *page) {
  10441b:	55                   	push   %ebp
  10441c:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10441e:	8b 45 08             	mov    0x8(%ebp),%eax
  104421:	8b 00                	mov    (%eax),%eax
}
  104423:	5d                   	pop    %ebp
  104424:	c3                   	ret    

00104425 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  104425:	55                   	push   %ebp
  104426:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104428:	8b 45 08             	mov    0x8(%ebp),%eax
  10442b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10442e:	89 10                	mov    %edx,(%eax)
}
  104430:	90                   	nop
  104431:	5d                   	pop    %ebp
  104432:	c3                   	ret    

00104433 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104433:	55                   	push   %ebp
  104434:	89 e5                	mov    %esp,%ebp
  104436:	83 ec 10             	sub    $0x10,%esp
  104439:	c7 45 fc 1c bf 11 00 	movl   $0x11bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104440:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104443:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104446:	89 50 04             	mov    %edx,0x4(%eax)
  104449:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10444c:	8b 50 04             	mov    0x4(%eax),%edx
  10444f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104452:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  104454:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  10445b:	00 00 00 
}
  10445e:	90                   	nop
  10445f:	c9                   	leave  
  104460:	c3                   	ret    

00104461 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104461:	55                   	push   %ebp
  104462:	89 e5                	mov    %esp,%ebp
  104464:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);    //断言，如果判断为false，直接中断程序的执行
  104467:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10446b:	75 24                	jne    104491 <default_init_memmap+0x30>
  10446d:	c7 44 24 0c 58 6e 10 	movl   $0x106e58,0xc(%esp)
  104474:	00 
  104475:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  10447c:	00 
  10447d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  104484:	00 
  104485:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  10448c:	e8 68 bf ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  104491:	8b 45 08             	mov    0x8(%ebp),%eax
  104494:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104497:	eb 7d                	jmp    104516 <default_init_memmap+0xb5>
        assert(PageReserved(p));        //判断该页保留位是否为1，如果为内核占用页则清空该标志位
  104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10449c:	83 c0 04             	add    $0x4,%eax
  10449f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1044a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1044a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1044af:	0f a3 10             	bt     %edx,(%eax)
  1044b2:	19 c0                	sbb    %eax,%eax
  1044b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1044b7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1044bb:	0f 95 c0             	setne  %al
  1044be:	0f b6 c0             	movzbl %al,%eax
  1044c1:	85 c0                	test   %eax,%eax
  1044c3:	75 24                	jne    1044e9 <default_init_memmap+0x88>
  1044c5:	c7 44 24 0c 89 6e 10 	movl   $0x106e89,0xc(%esp)
  1044cc:	00 
  1044cd:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1044d4:	00 
  1044d5:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1044dc:	00 
  1044dd:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1044e4:	e8 10 bf ff ff       	call   1003f9 <__panic>
        p->flags = p->property = 0;     //标志为清0，空闲块数量置0
  1044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f6:	8b 50 08             	mov    0x8(%eax),%edx
  1044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044fc:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);                   //设置引用量为0
  1044ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104506:	00 
  104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10450a:	89 04 24             	mov    %eax,(%esp)
  10450d:	e8 13 ff ff ff       	call   104425 <set_page_ref>
    for (; p != base + n; p ++) {
  104512:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104516:	8b 55 0c             	mov    0xc(%ebp),%edx
  104519:	89 d0                	mov    %edx,%eax
  10451b:	c1 e0 02             	shl    $0x2,%eax
  10451e:	01 d0                	add    %edx,%eax
  104520:	c1 e0 02             	shl    $0x2,%eax
  104523:	89 c2                	mov    %eax,%edx
  104525:	8b 45 08             	mov    0x8(%ebp),%eax
  104528:	01 d0                	add    %edx,%eax
  10452a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10452d:	0f 85 66 ff ff ff    	jne    104499 <default_init_memmap+0x38>
    }
    base->property = n;
  104533:	8b 45 08             	mov    0x8(%ebp),%eax
  104536:	8b 55 0c             	mov    0xc(%ebp),%edx
  104539:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  10453c:	8b 45 08             	mov    0x8(%ebp),%eax
  10453f:	83 c0 04             	add    $0x4,%eax
  104542:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104549:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10454c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10454f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104552:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  104555:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  10455b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10455e:	01 d0                	add    %edx,%eax
  104560:	a3 24 bf 11 00       	mov    %eax,0x11bf24
    //应该使用list_add_before,否则使用list_add默认为add_after,
    //这样新增加的页总是在后面，不适合FFMA算法，应该要按照地址排序
    list_add_before(&free_list, &(base->page_link));    //cc
  104565:	8b 45 08             	mov    0x8(%ebp),%eax
  104568:	83 c0 0c             	add    $0xc,%eax
  10456b:	c7 45 e4 1c bf 11 00 	movl   $0x11bf1c,-0x1c(%ebp)
  104572:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  104575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104578:	8b 00                	mov    (%eax),%eax
  10457a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10457d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  104580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  104583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104586:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10458c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10458f:	89 10                	mov    %edx,(%eax)
  104591:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104594:	8b 10                	mov    (%eax),%edx
  104596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104599:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10459c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10459f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1045a2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1045a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1045ab:	89 10                	mov    %edx,(%eax)
}
  1045ad:	90                   	nop
  1045ae:	c9                   	leave  
  1045af:	c3                   	ret    

001045b0 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1045b0:	55                   	push   %ebp
  1045b1:	89 e5                	mov    %esp,%ebp
  1045b3:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1045b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1045ba:	75 24                	jne    1045e0 <default_alloc_pages+0x30>
  1045bc:	c7 44 24 0c 58 6e 10 	movl   $0x106e58,0xc(%esp)
  1045c3:	00 
  1045c4:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1045cb:	00 
  1045cc:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  1045d3:	00 
  1045d4:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1045db:	e8 19 be ff ff       	call   1003f9 <__panic>
    if (n > nr_free) {      //要求的超过空闲空间大小，返回NULL
  1045e0:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  1045e5:	39 45 08             	cmp    %eax,0x8(%ebp)
  1045e8:	76 0a                	jbe    1045f4 <default_alloc_pages+0x44>
        return NULL;
  1045ea:	b8 00 00 00 00       	mov    $0x0,%eax
  1045ef:	e9 3d 01 00 00       	jmp    104731 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  1045f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;          //查找符合条件的page
  1045fb:	c7 45 f0 1c bf 11 00 	movl   $0x11bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104602:	eb 1c                	jmp    104620 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  104604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104607:	83 e8 0c             	sub    $0xc,%eax
  10460a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {               //找到符合条件的块，赋值给page变量带出
  10460d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104610:	8b 40 08             	mov    0x8(%eax),%eax
  104613:	39 45 08             	cmp    %eax,0x8(%ebp)
  104616:	77 08                	ja     104620 <default_alloc_pages+0x70>
            page = p;
  104618:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10461b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  10461e:	eb 18                	jmp    104638 <default_alloc_pages+0x88>
  104620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104623:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  104626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104629:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10462c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10462f:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  104636:	75 cc                	jne    104604 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {           //找到了符合条件的页，进行设置
  104638:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10463c:	0f 84 ec 00 00 00    	je     10472e <default_alloc_pages+0x17e>
        if (page->property > n) {
  104642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104645:	8b 40 08             	mov    0x8(%eax),%eax
  104648:	39 45 08             	cmp    %eax,0x8(%ebp)
  10464b:	0f 83 8c 00 00 00    	jae    1046dd <default_alloc_pages+0x12d>
            struct Page *p = page + n;        //将多余的页空间，重新放入空闲页表目录
  104651:	8b 55 08             	mov    0x8(%ebp),%edx
  104654:	89 d0                	mov    %edx,%eax
  104656:	c1 e0 02             	shl    $0x2,%eax
  104659:	01 d0                	add    %edx,%eax
  10465b:	c1 e0 02             	shl    $0x2,%eax
  10465e:	89 c2                	mov    %eax,%edx
  104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104663:	01 d0                	add    %edx,%eax
  104665:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  104668:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10466b:	8b 40 08             	mov    0x8(%eax),%eax
  10466e:	2b 45 08             	sub    0x8(%ebp),%eax
  104671:	89 c2                	mov    %eax,%edx
  104673:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104676:	89 50 08             	mov    %edx,0x8(%eax)
            //应该要对剩余的部分空闲页设置属性位，在init中属性位全为0，这里需要设为1,表明空闲块
            SetPageProperty(p);                 //++
  104679:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10467c:	83 c0 04             	add    $0x4,%eax
  10467f:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  104686:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104689:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10468c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10468f:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));  //cc注意一定要添加在后面,按地址排序
  104692:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104695:	83 c0 0c             	add    $0xc,%eax
  104698:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10469b:	83 c2 0c             	add    $0xc,%edx
  10469e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1046a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
  1046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1046a7:	8b 40 04             	mov    0x4(%eax),%eax
  1046aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1046ad:	89 55 d8             	mov    %edx,-0x28(%ebp)
  1046b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1046b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1046b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
  1046b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1046bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1046bf:	89 10                	mov    %edx,(%eax)
  1046c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1046c4:	8b 10                	mov    (%eax),%edx
  1046c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046c9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1046cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1046d2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1046d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1046db:	89 10                	mov    %edx,(%eax)
    }
      list_del(&(page->page_link));     // 先要处理完剩余空间再删除该页，从空闲页表目录页删除该页
  1046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046e0:	83 c0 0c             	add    $0xc,%eax
  1046e3:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
  1046e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1046e9:	8b 40 04             	mov    0x4(%eax),%eax
  1046ec:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1046ef:	8b 12                	mov    (%edx),%edx
  1046f1:	89 55 b8             	mov    %edx,-0x48(%ebp)
  1046f4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1046f7:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1046fa:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1046fd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104700:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104703:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104706:	89 10                	mov    %edx,(%eax)
      nr_free -= n;       //总空闲块数减去分配页块数
  104708:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  10470d:	2b 45 08             	sub    0x8(%ebp),%eax
  104710:	a3 24 bf 11 00       	mov    %eax,0x11bf24
      ClearPageProperty(page);//将属性位置0，标记该页已被分配
  104715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104718:	83 c0 04             	add    $0x4,%eax
  10471b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  104722:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104725:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104728:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10472b:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  10472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104731:	c9                   	leave  
  104732:	c3                   	ret    

00104733 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104733:	55                   	push   %ebp
  104734:	89 e5                	mov    %esp,%ebp
  104736:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  10473c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104740:	75 24                	jne    104766 <default_free_pages+0x33>
  104742:	c7 44 24 0c 58 6e 10 	movl   $0x106e58,0xc(%esp)
  104749:	00 
  10474a:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104751:	00 
  104752:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  104759:	00 
  10475a:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104761:	e8 93 bc ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  104766:	8b 45 08             	mov    0x8(%ebp),%eax
  104769:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
  10476c:	e9 9d 00 00 00       	jmp    10480e <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));     //否则为用户态的占用区
  104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104774:	83 c0 04             	add    $0x4,%eax
  104777:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10477e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104781:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104784:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104787:	0f a3 10             	bt     %edx,(%eax)
  10478a:	19 c0                	sbb    %eax,%eax
  10478c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10478f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104793:	0f 95 c0             	setne  %al
  104796:	0f b6 c0             	movzbl %al,%eax
  104799:	85 c0                	test   %eax,%eax
  10479b:	75 2c                	jne    1047c9 <default_free_pages+0x96>
  10479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047a0:	83 c0 04             	add    $0x4,%eax
  1047a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1047aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1047ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1047b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1047b3:	0f a3 10             	bt     %edx,(%eax)
  1047b6:	19 c0                	sbb    %eax,%eax
  1047b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  1047bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1047bf:	0f 95 c0             	setne  %al
  1047c2:	0f b6 c0             	movzbl %al,%eax
  1047c5:	85 c0                	test   %eax,%eax
  1047c7:	74 24                	je     1047ed <default_free_pages+0xba>
  1047c9:	c7 44 24 0c 9c 6e 10 	movl   $0x106e9c,0xc(%esp)
  1047d0:	00 
  1047d1:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1047d8:	00 
  1047d9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  1047e0:	00 
  1047e1:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1047e8:	e8 0c bc ff ff       	call   1003f9 <__panic>
        p->flags = 0;         //标志位清零
  1047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047f0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  1047f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1047fe:	00 
  1047ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104802:	89 04 24             	mov    %eax,(%esp)
  104805:	e8 1b fc ff ff       	call   104425 <set_page_ref>
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
  10480a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10480e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104811:	89 d0                	mov    %edx,%eax
  104813:	c1 e0 02             	shl    $0x2,%eax
  104816:	01 d0                	add    %edx,%eax
  104818:	c1 e0 02             	shl    $0x2,%eax
  10481b:	89 c2                	mov    %eax,%edx
  10481d:	8b 45 08             	mov    0x8(%ebp),%eax
  104820:	01 d0                	add    %edx,%eax
  104822:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104825:	0f 85 46 ff ff ff    	jne    104771 <default_free_pages+0x3e>
    }
    base->property = n;
  10482b:	8b 45 08             	mov    0x8(%ebp),%eax
  10482e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104831:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104834:	8b 45 08             	mov    0x8(%ebp),%eax
  104837:	83 c0 04             	add    $0x4,%eax
  10483a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104841:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104844:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104847:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10484a:	0f ab 10             	bts    %edx,(%eax)
  10484d:	c7 45 d4 1c bf 11 00 	movl   $0x11bf1c,-0x2c(%ebp)
    return listelm->next;
  104854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104857:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);    //获取头页地址
  10485a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {            //合并空页
  10485d:	e9 08 01 00 00       	jmp    10496a <default_free_pages+0x237>
        p = le2page(le, page_link);
  104862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104865:	83 e8 0c             	sub    $0xc,%eax
  104868:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10486b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10486e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104871:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104874:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  104877:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {     //如果该页为当前释放页的紧邻后页，则直接释放后面一页的属性位，将之和当前页合并
  10487a:	8b 45 08             	mov    0x8(%ebp),%eax
  10487d:	8b 50 08             	mov    0x8(%eax),%edx
  104880:	89 d0                	mov    %edx,%eax
  104882:	c1 e0 02             	shl    $0x2,%eax
  104885:	01 d0                	add    %edx,%eax
  104887:	c1 e0 02             	shl    $0x2,%eax
  10488a:	89 c2                	mov    %eax,%edx
  10488c:	8b 45 08             	mov    0x8(%ebp),%eax
  10488f:	01 d0                	add    %edx,%eax
  104891:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104894:	75 5a                	jne    1048f0 <default_free_pages+0x1bd>
            base->property += p->property;
  104896:	8b 45 08             	mov    0x8(%ebp),%eax
  104899:	8b 50 08             	mov    0x8(%eax),%edx
  10489c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10489f:	8b 40 08             	mov    0x8(%eax),%eax
  1048a2:	01 c2                	add    %eax,%edx
  1048a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1048a7:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);     //清楚属性位
  1048aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048ad:	83 c0 04             	add    $0x4,%eax
  1048b0:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1048b7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1048ba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1048bd:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1048c0:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));    //在空闲页表中删除该页
  1048c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048c6:	83 c0 0c             	add    $0xc,%eax
  1048c9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1048cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1048cf:	8b 40 04             	mov    0x4(%eax),%eax
  1048d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1048d5:	8b 12                	mov    (%edx),%edx
  1048d7:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1048da:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  1048dd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1048e0:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1048e3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1048e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1048e9:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1048ec:	89 10                	mov    %edx,(%eax)
  1048ee:	eb 7a                	jmp    10496a <default_free_pages+0x237>
        }
        else if (p + p->property == base) {   //如果找到紧邻前一页是空页，则把前页合并到当前页
  1048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048f3:	8b 50 08             	mov    0x8(%eax),%edx
  1048f6:	89 d0                	mov    %edx,%eax
  1048f8:	c1 e0 02             	shl    $0x2,%eax
  1048fb:	01 d0                	add    %edx,%eax
  1048fd:	c1 e0 02             	shl    $0x2,%eax
  104900:	89 c2                	mov    %eax,%edx
  104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104905:	01 d0                	add    %edx,%eax
  104907:	39 45 08             	cmp    %eax,0x8(%ebp)
  10490a:	75 5e                	jne    10496a <default_free_pages+0x237>
            p->property += base->property;
  10490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10490f:	8b 50 08             	mov    0x8(%eax),%edx
  104912:	8b 45 08             	mov    0x8(%ebp),%eax
  104915:	8b 40 08             	mov    0x8(%eax),%eax
  104918:	01 c2                	add    %eax,%edx
  10491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10491d:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104920:	8b 45 08             	mov    0x8(%ebp),%eax
  104923:	83 c0 04             	add    $0x4,%eax
  104926:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  10492d:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104930:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104933:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104936:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  104939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10493c:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  10493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104942:	83 c0 0c             	add    $0xc,%eax
  104945:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  104948:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10494b:	8b 40 04             	mov    0x4(%eax),%eax
  10494e:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104951:	8b 12                	mov    (%edx),%edx
  104953:	89 55 ac             	mov    %edx,-0x54(%ebp)
  104956:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  104959:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10495c:	8b 55 a8             	mov    -0x58(%ebp),%edx
  10495f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104962:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104965:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104968:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {            //合并空页
  10496a:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  104971:	0f 85 eb fe ff ff    	jne    104862 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  104977:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  10497d:	8b 45 0c             	mov    0xc(%ebp),%eax
  104980:	01 d0                	add    %edx,%eax
  104982:	a3 24 bf 11 00       	mov    %eax,0x11bf24
  104987:	c7 45 9c 1c bf 11 00 	movl   $0x11bf1c,-0x64(%ebp)
    return listelm->next;
  10498e:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104991:	8b 40 04             	mov    0x4(%eax),%eax
    //从头到尾进行一次遍历，找到合适的插入位置,把合并和的页插入到找到的位置前面
    le  = list_next(&free_list);
  104994:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
  104997:	eb 34                	jmp    1049cd <default_free_pages+0x29a>
      p = le2page(le,page_link);
  104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10499c:	83 e8 0c             	sub    $0xc,%eax
  10499f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(base+base->property<=p){
  1049a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1049a5:	8b 50 08             	mov    0x8(%eax),%edx
  1049a8:	89 d0                	mov    %edx,%eax
  1049aa:	c1 e0 02             	shl    $0x2,%eax
  1049ad:	01 d0                	add    %edx,%eax
  1049af:	c1 e0 02             	shl    $0x2,%eax
  1049b2:	89 c2                	mov    %eax,%edx
  1049b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1049b7:	01 d0                	add    %edx,%eax
  1049b9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1049bc:	73 1a                	jae    1049d8 <default_free_pages+0x2a5>
  1049be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049c1:	89 45 98             	mov    %eax,-0x68(%ebp)
  1049c4:	8b 45 98             	mov    -0x68(%ebp),%eax
  1049c7:	8b 40 04             	mov    0x4(%eax),%eax
        break;
      }
      le = list_next(le);
  1049ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
  1049cd:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  1049d4:	75 c3                	jne    104999 <default_free_pages+0x266>
  1049d6:	eb 01                	jmp    1049d9 <default_free_pages+0x2a6>
        break;
  1049d8:	90                   	nop
    }
    list_add_before(le, &(base->page_link));    //cc应该使用add_before把整合的页插入找到的位置
  1049d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1049dc:	8d 50 0c             	lea    0xc(%eax),%edx
  1049df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049e2:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1049e5:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1049e8:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1049eb:	8b 00                	mov    (%eax),%eax
  1049ed:	8b 55 90             	mov    -0x70(%ebp),%edx
  1049f0:	89 55 8c             	mov    %edx,-0x74(%ebp)
  1049f3:	89 45 88             	mov    %eax,-0x78(%ebp)
  1049f6:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1049f9:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  1049fc:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1049ff:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104a02:	89 10                	mov    %edx,(%eax)
  104a04:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104a07:	8b 10                	mov    (%eax),%edx
  104a09:	8b 45 88             	mov    -0x78(%ebp),%eax
  104a0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104a0f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a12:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104a15:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104a18:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a1b:	8b 55 88             	mov    -0x78(%ebp),%edx
  104a1e:	89 10                	mov    %edx,(%eax)
}
  104a20:	90                   	nop
  104a21:	c9                   	leave  
  104a22:	c3                   	ret    

00104a23 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104a23:	55                   	push   %ebp
  104a24:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104a26:	a1 24 bf 11 00       	mov    0x11bf24,%eax
}
  104a2b:	5d                   	pop    %ebp
  104a2c:	c3                   	ret    

00104a2d <basic_check>:

static void
basic_check(void) {
  104a2d:	55                   	push   %ebp
  104a2e:	89 e5                	mov    %esp,%ebp
  104a30:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104a46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a4d:	e8 e2 e2 ff ff       	call   102d34 <alloc_pages>
  104a52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104a59:	75 24                	jne    104a7f <basic_check+0x52>
  104a5b:	c7 44 24 0c c1 6e 10 	movl   $0x106ec1,0xc(%esp)
  104a62:	00 
  104a63:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104a6a:	00 
  104a6b:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a72:	00 
  104a73:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104a7a:	e8 7a b9 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104a7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a86:	e8 a9 e2 ff ff       	call   102d34 <alloc_pages>
  104a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a92:	75 24                	jne    104ab8 <basic_check+0x8b>
  104a94:	c7 44 24 0c dd 6e 10 	movl   $0x106edd,0xc(%esp)
  104a9b:	00 
  104a9c:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104aa3:	00 
  104aa4:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  104aab:	00 
  104aac:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104ab3:	e8 41 b9 ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104ab8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104abf:	e8 70 e2 ff ff       	call   102d34 <alloc_pages>
  104ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104ac7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104acb:	75 24                	jne    104af1 <basic_check+0xc4>
  104acd:	c7 44 24 0c f9 6e 10 	movl   $0x106ef9,0xc(%esp)
  104ad4:	00 
  104ad5:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104adc:	00 
  104add:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104ae4:	00 
  104ae5:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104aec:	e8 08 b9 ff ff       	call   1003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104af4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104af7:	74 10                	je     104b09 <basic_check+0xdc>
  104af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104afc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104aff:	74 08                	je     104b09 <basic_check+0xdc>
  104b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b07:	75 24                	jne    104b2d <basic_check+0x100>
  104b09:	c7 44 24 0c 18 6f 10 	movl   $0x106f18,0xc(%esp)
  104b10:	00 
  104b11:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104b18:	00 
  104b19:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104b20:	00 
  104b21:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104b28:	e8 cc b8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104b2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b30:	89 04 24             	mov    %eax,(%esp)
  104b33:	e8 e3 f8 ff ff       	call   10441b <page_ref>
  104b38:	85 c0                	test   %eax,%eax
  104b3a:	75 1e                	jne    104b5a <basic_check+0x12d>
  104b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b3f:	89 04 24             	mov    %eax,(%esp)
  104b42:	e8 d4 f8 ff ff       	call   10441b <page_ref>
  104b47:	85 c0                	test   %eax,%eax
  104b49:	75 0f                	jne    104b5a <basic_check+0x12d>
  104b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b4e:	89 04 24             	mov    %eax,(%esp)
  104b51:	e8 c5 f8 ff ff       	call   10441b <page_ref>
  104b56:	85 c0                	test   %eax,%eax
  104b58:	74 24                	je     104b7e <basic_check+0x151>
  104b5a:	c7 44 24 0c 3c 6f 10 	movl   $0x106f3c,0xc(%esp)
  104b61:	00 
  104b62:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104b69:	00 
  104b6a:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  104b71:	00 
  104b72:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104b79:	e8 7b b8 ff ff       	call   1003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104b7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b81:	89 04 24             	mov    %eax,(%esp)
  104b84:	e8 7c f8 ff ff       	call   104405 <page2pa>
  104b89:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104b8f:	c1 e2 0c             	shl    $0xc,%edx
  104b92:	39 d0                	cmp    %edx,%eax
  104b94:	72 24                	jb     104bba <basic_check+0x18d>
  104b96:	c7 44 24 0c 78 6f 10 	movl   $0x106f78,0xc(%esp)
  104b9d:	00 
  104b9e:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104ba5:	00 
  104ba6:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  104bad:	00 
  104bae:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104bb5:	e8 3f b8 ff ff       	call   1003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bbd:	89 04 24             	mov    %eax,(%esp)
  104bc0:	e8 40 f8 ff ff       	call   104405 <page2pa>
  104bc5:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104bcb:	c1 e2 0c             	shl    $0xc,%edx
  104bce:	39 d0                	cmp    %edx,%eax
  104bd0:	72 24                	jb     104bf6 <basic_check+0x1c9>
  104bd2:	c7 44 24 0c 95 6f 10 	movl   $0x106f95,0xc(%esp)
  104bd9:	00 
  104bda:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104be1:	00 
  104be2:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  104be9:	00 
  104bea:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104bf1:	e8 03 b8 ff ff       	call   1003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bf9:	89 04 24             	mov    %eax,(%esp)
  104bfc:	e8 04 f8 ff ff       	call   104405 <page2pa>
  104c01:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104c07:	c1 e2 0c             	shl    $0xc,%edx
  104c0a:	39 d0                	cmp    %edx,%eax
  104c0c:	72 24                	jb     104c32 <basic_check+0x205>
  104c0e:	c7 44 24 0c b2 6f 10 	movl   $0x106fb2,0xc(%esp)
  104c15:	00 
  104c16:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104c1d:	00 
  104c1e:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  104c25:	00 
  104c26:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104c2d:	e8 c7 b7 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  104c32:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  104c37:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  104c3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104c40:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104c43:	c7 45 dc 1c bf 11 00 	movl   $0x11bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104c4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104c50:	89 50 04             	mov    %edx,0x4(%eax)
  104c53:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c56:	8b 50 04             	mov    0x4(%eax),%edx
  104c59:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c5c:	89 10                	mov    %edx,(%eax)
  104c5e:	c7 45 e0 1c bf 11 00 	movl   $0x11bf1c,-0x20(%ebp)
    return list->next == list;
  104c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104c68:	8b 40 04             	mov    0x4(%eax),%eax
  104c6b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104c6e:	0f 94 c0             	sete   %al
  104c71:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104c74:	85 c0                	test   %eax,%eax
  104c76:	75 24                	jne    104c9c <basic_check+0x26f>
  104c78:	c7 44 24 0c cf 6f 10 	movl   $0x106fcf,0xc(%esp)
  104c7f:	00 
  104c80:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104c87:	00 
  104c88:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104c8f:	00 
  104c90:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104c97:	e8 5d b7 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  104c9c:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104ca1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104ca4:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  104cab:	00 00 00 

    assert(alloc_page() == NULL);
  104cae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cb5:	e8 7a e0 ff ff       	call   102d34 <alloc_pages>
  104cba:	85 c0                	test   %eax,%eax
  104cbc:	74 24                	je     104ce2 <basic_check+0x2b5>
  104cbe:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  104cc5:	00 
  104cc6:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104ccd:	00 
  104cce:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104cd5:	00 
  104cd6:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104cdd:	e8 17 b7 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104ce2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ce9:	00 
  104cea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ced:	89 04 24             	mov    %eax,(%esp)
  104cf0:	e8 77 e0 ff ff       	call   102d6c <free_pages>
    free_page(p1);
  104cf5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cfc:	00 
  104cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d00:	89 04 24             	mov    %eax,(%esp)
  104d03:	e8 64 e0 ff ff       	call   102d6c <free_pages>
    free_page(p2);
  104d08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d0f:	00 
  104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d13:	89 04 24             	mov    %eax,(%esp)
  104d16:	e8 51 e0 ff ff       	call   102d6c <free_pages>
    assert(nr_free == 3);
  104d1b:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104d20:	83 f8 03             	cmp    $0x3,%eax
  104d23:	74 24                	je     104d49 <basic_check+0x31c>
  104d25:	c7 44 24 0c fb 6f 10 	movl   $0x106ffb,0xc(%esp)
  104d2c:	00 
  104d2d:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104d34:	00 
  104d35:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  104d3c:	00 
  104d3d:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104d44:	e8 b0 b6 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104d49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d50:	e8 df df ff ff       	call   102d34 <alloc_pages>
  104d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104d5c:	75 24                	jne    104d82 <basic_check+0x355>
  104d5e:	c7 44 24 0c c1 6e 10 	movl   $0x106ec1,0xc(%esp)
  104d65:	00 
  104d66:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104d6d:	00 
  104d6e:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104d75:	00 
  104d76:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104d7d:	e8 77 b6 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d89:	e8 a6 df ff ff       	call   102d34 <alloc_pages>
  104d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104d95:	75 24                	jne    104dbb <basic_check+0x38e>
  104d97:	c7 44 24 0c dd 6e 10 	movl   $0x106edd,0xc(%esp)
  104d9e:	00 
  104d9f:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104da6:	00 
  104da7:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  104dae:	00 
  104daf:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104db6:	e8 3e b6 ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104dbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dc2:	e8 6d df ff ff       	call   102d34 <alloc_pages>
  104dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104dca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104dce:	75 24                	jne    104df4 <basic_check+0x3c7>
  104dd0:	c7 44 24 0c f9 6e 10 	movl   $0x106ef9,0xc(%esp)
  104dd7:	00 
  104dd8:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104ddf:	00 
  104de0:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104de7:	00 
  104de8:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104def:	e8 05 b6 ff ff       	call   1003f9 <__panic>

    assert(alloc_page() == NULL);
  104df4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dfb:	e8 34 df ff ff       	call   102d34 <alloc_pages>
  104e00:	85 c0                	test   %eax,%eax
  104e02:	74 24                	je     104e28 <basic_check+0x3fb>
  104e04:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  104e0b:	00 
  104e0c:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104e13:	00 
  104e14:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104e1b:	00 
  104e1c:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104e23:	e8 d1 b5 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104e28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e2f:	00 
  104e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e33:	89 04 24             	mov    %eax,(%esp)
  104e36:	e8 31 df ff ff       	call   102d6c <free_pages>
  104e3b:	c7 45 d8 1c bf 11 00 	movl   $0x11bf1c,-0x28(%ebp)
  104e42:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104e45:	8b 40 04             	mov    0x4(%eax),%eax
  104e48:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104e4b:	0f 94 c0             	sete   %al
  104e4e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104e51:	85 c0                	test   %eax,%eax
  104e53:	74 24                	je     104e79 <basic_check+0x44c>
  104e55:	c7 44 24 0c 08 70 10 	movl   $0x107008,0xc(%esp)
  104e5c:	00 
  104e5d:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104e64:	00 
  104e65:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  104e6c:	00 
  104e6d:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104e74:	e8 80 b5 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104e79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e80:	e8 af de ff ff       	call   102d34 <alloc_pages>
  104e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104e8e:	74 24                	je     104eb4 <basic_check+0x487>
  104e90:	c7 44 24 0c 20 70 10 	movl   $0x107020,0xc(%esp)
  104e97:	00 
  104e98:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104e9f:	00 
  104ea0:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  104ea7:	00 
  104ea8:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104eaf:	e8 45 b5 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  104eb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ebb:	e8 74 de ff ff       	call   102d34 <alloc_pages>
  104ec0:	85 c0                	test   %eax,%eax
  104ec2:	74 24                	je     104ee8 <basic_check+0x4bb>
  104ec4:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  104ecb:	00 
  104ecc:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104ed3:	00 
  104ed4:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  104edb:	00 
  104edc:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104ee3:	e8 11 b5 ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  104ee8:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104eed:	85 c0                	test   %eax,%eax
  104eef:	74 24                	je     104f15 <basic_check+0x4e8>
  104ef1:	c7 44 24 0c 39 70 10 	movl   $0x107039,0xc(%esp)
  104ef8:	00 
  104ef9:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104f00:	00 
  104f01:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104f08:	00 
  104f09:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104f10:	e8 e4 b4 ff ff       	call   1003f9 <__panic>
    free_list = free_list_store;
  104f15:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104f18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104f1b:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  104f20:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    nr_free = nr_free_store;
  104f26:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f29:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_page(p);
  104f2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f35:	00 
  104f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f39:	89 04 24             	mov    %eax,(%esp)
  104f3c:	e8 2b de ff ff       	call   102d6c <free_pages>
    free_page(p1);
  104f41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f48:	00 
  104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f4c:	89 04 24             	mov    %eax,(%esp)
  104f4f:	e8 18 de ff ff       	call   102d6c <free_pages>
    free_page(p2);
  104f54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f5b:	00 
  104f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f5f:	89 04 24             	mov    %eax,(%esp)
  104f62:	e8 05 de ff ff       	call   102d6c <free_pages>
}
  104f67:	90                   	nop
  104f68:	c9                   	leave  
  104f69:	c3                   	ret    

00104f6a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104f6a:	55                   	push   %ebp
  104f6b:	89 e5                	mov    %esp,%ebp
  104f6d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104f73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104f7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104f81:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104f88:	eb 6a                	jmp    104ff4 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f8d:	83 e8 0c             	sub    $0xc,%eax
  104f90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104f93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104f96:	83 c0 04             	add    $0x4,%eax
  104f99:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104fa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104fa3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104fa6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104fa9:	0f a3 10             	bt     %edx,(%eax)
  104fac:	19 c0                	sbb    %eax,%eax
  104fae:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104fb1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104fb5:	0f 95 c0             	setne  %al
  104fb8:	0f b6 c0             	movzbl %al,%eax
  104fbb:	85 c0                	test   %eax,%eax
  104fbd:	75 24                	jne    104fe3 <default_check+0x79>
  104fbf:	c7 44 24 0c 46 70 10 	movl   $0x107046,0xc(%esp)
  104fc6:	00 
  104fc7:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  104fce:	00 
  104fcf:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  104fd6:	00 
  104fd7:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  104fde:	e8 16 b4 ff ff       	call   1003f9 <__panic>
        count ++, total += p->property;
  104fe3:	ff 45 f4             	incl   -0xc(%ebp)
  104fe6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104fe9:	8b 50 08             	mov    0x8(%eax),%edx
  104fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104fef:	01 d0                	add    %edx,%eax
  104ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ff7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104ffa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104ffd:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105000:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105003:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  10500a:	0f 85 7a ff ff ff    	jne    104f8a <default_check+0x20>
    }
    assert(total == nr_free_pages());
  105010:	e8 8a dd ff ff       	call   102d9f <nr_free_pages>
  105015:	89 c2                	mov    %eax,%edx
  105017:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10501a:	39 c2                	cmp    %eax,%edx
  10501c:	74 24                	je     105042 <default_check+0xd8>
  10501e:	c7 44 24 0c 56 70 10 	movl   $0x107056,0xc(%esp)
  105025:	00 
  105026:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  10502d:	00 
  10502e:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  105035:	00 
  105036:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  10503d:	e8 b7 b3 ff ff       	call   1003f9 <__panic>

    basic_check();
  105042:	e8 e6 f9 ff ff       	call   104a2d <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  105047:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10504e:	e8 e1 dc ff ff       	call   102d34 <alloc_pages>
  105053:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  105056:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10505a:	75 24                	jne    105080 <default_check+0x116>
  10505c:	c7 44 24 0c 6f 70 10 	movl   $0x10706f,0xc(%esp)
  105063:	00 
  105064:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  10506b:	00 
  10506c:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  105073:	00 
  105074:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  10507b:	e8 79 b3 ff ff       	call   1003f9 <__panic>
    assert(!PageProperty(p0));
  105080:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105083:	83 c0 04             	add    $0x4,%eax
  105086:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10508d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105090:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105093:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105096:	0f a3 10             	bt     %edx,(%eax)
  105099:	19 c0                	sbb    %eax,%eax
  10509b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  10509e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1050a2:	0f 95 c0             	setne  %al
  1050a5:	0f b6 c0             	movzbl %al,%eax
  1050a8:	85 c0                	test   %eax,%eax
  1050aa:	74 24                	je     1050d0 <default_check+0x166>
  1050ac:	c7 44 24 0c 7a 70 10 	movl   $0x10707a,0xc(%esp)
  1050b3:	00 
  1050b4:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1050bb:	00 
  1050bc:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1050c3:	00 
  1050c4:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1050cb:	e8 29 b3 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  1050d0:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  1050d5:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  1050db:	89 45 80             	mov    %eax,-0x80(%ebp)
  1050de:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1050e1:	c7 45 b0 1c bf 11 00 	movl   $0x11bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1050e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1050eb:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1050ee:	89 50 04             	mov    %edx,0x4(%eax)
  1050f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1050f4:	8b 50 04             	mov    0x4(%eax),%edx
  1050f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1050fa:	89 10                	mov    %edx,(%eax)
  1050fc:	c7 45 b4 1c bf 11 00 	movl   $0x11bf1c,-0x4c(%ebp)
    return list->next == list;
  105103:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  105106:	8b 40 04             	mov    0x4(%eax),%eax
  105109:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  10510c:	0f 94 c0             	sete   %al
  10510f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105112:	85 c0                	test   %eax,%eax
  105114:	75 24                	jne    10513a <default_check+0x1d0>
  105116:	c7 44 24 0c cf 6f 10 	movl   $0x106fcf,0xc(%esp)
  10511d:	00 
  10511e:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105125:	00 
  105126:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  10512d:	00 
  10512e:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105135:	e8 bf b2 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  10513a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105141:	e8 ee db ff ff       	call   102d34 <alloc_pages>
  105146:	85 c0                	test   %eax,%eax
  105148:	74 24                	je     10516e <default_check+0x204>
  10514a:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  105151:	00 
  105152:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105159:	00 
  10515a:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  105161:	00 
  105162:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105169:	e8 8b b2 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  10516e:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  105173:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  105176:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  10517d:	00 00 00 

    free_pages(p0 + 2, 3);
  105180:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105183:	83 c0 28             	add    $0x28,%eax
  105186:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10518d:	00 
  10518e:	89 04 24             	mov    %eax,(%esp)
  105191:	e8 d6 db ff ff       	call   102d6c <free_pages>
    assert(alloc_pages(4) == NULL);
  105196:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10519d:	e8 92 db ff ff       	call   102d34 <alloc_pages>
  1051a2:	85 c0                	test   %eax,%eax
  1051a4:	74 24                	je     1051ca <default_check+0x260>
  1051a6:	c7 44 24 0c 8c 70 10 	movl   $0x10708c,0xc(%esp)
  1051ad:	00 
  1051ae:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1051b5:	00 
  1051b6:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1051bd:	00 
  1051be:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1051c5:	e8 2f b2 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1051ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051cd:	83 c0 28             	add    $0x28,%eax
  1051d0:	83 c0 04             	add    $0x4,%eax
  1051d3:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1051da:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1051dd:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1051e0:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1051e3:	0f a3 10             	bt     %edx,(%eax)
  1051e6:	19 c0                	sbb    %eax,%eax
  1051e8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1051eb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1051ef:	0f 95 c0             	setne  %al
  1051f2:	0f b6 c0             	movzbl %al,%eax
  1051f5:	85 c0                	test   %eax,%eax
  1051f7:	74 0e                	je     105207 <default_check+0x29d>
  1051f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051fc:	83 c0 28             	add    $0x28,%eax
  1051ff:	8b 40 08             	mov    0x8(%eax),%eax
  105202:	83 f8 03             	cmp    $0x3,%eax
  105205:	74 24                	je     10522b <default_check+0x2c1>
  105207:	c7 44 24 0c a4 70 10 	movl   $0x1070a4,0xc(%esp)
  10520e:	00 
  10520f:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105216:	00 
  105217:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  10521e:	00 
  10521f:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105226:	e8 ce b1 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10522b:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105232:	e8 fd da ff ff       	call   102d34 <alloc_pages>
  105237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10523a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10523e:	75 24                	jne    105264 <default_check+0x2fa>
  105240:	c7 44 24 0c d0 70 10 	movl   $0x1070d0,0xc(%esp)
  105247:	00 
  105248:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  10524f:	00 
  105250:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  105257:	00 
  105258:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  10525f:	e8 95 b1 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105264:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10526b:	e8 c4 da ff ff       	call   102d34 <alloc_pages>
  105270:	85 c0                	test   %eax,%eax
  105272:	74 24                	je     105298 <default_check+0x32e>
  105274:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  10527b:	00 
  10527c:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105283:	00 
  105284:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  10528b:	00 
  10528c:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105293:	e8 61 b1 ff ff       	call   1003f9 <__panic>
    assert(p0 + 2 == p1);
  105298:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10529b:	83 c0 28             	add    $0x28,%eax
  10529e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1052a1:	74 24                	je     1052c7 <default_check+0x35d>
  1052a3:	c7 44 24 0c ee 70 10 	movl   $0x1070ee,0xc(%esp)
  1052aa:	00 
  1052ab:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1052b2:	00 
  1052b3:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1052ba:	00 
  1052bb:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1052c2:	e8 32 b1 ff ff       	call   1003f9 <__panic>

    p2 = p0 + 1;
  1052c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052ca:	83 c0 14             	add    $0x14,%eax
  1052cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1052d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052d7:	00 
  1052d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052db:	89 04 24             	mov    %eax,(%esp)
  1052de:	e8 89 da ff ff       	call   102d6c <free_pages>
    free_pages(p1, 3);
  1052e3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1052ea:	00 
  1052eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1052ee:	89 04 24             	mov    %eax,(%esp)
  1052f1:	e8 76 da ff ff       	call   102d6c <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1052f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052f9:	83 c0 04             	add    $0x4,%eax
  1052fc:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105303:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105306:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105309:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10530c:	0f a3 10             	bt     %edx,(%eax)
  10530f:	19 c0                	sbb    %eax,%eax
  105311:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105314:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105318:	0f 95 c0             	setne  %al
  10531b:	0f b6 c0             	movzbl %al,%eax
  10531e:	85 c0                	test   %eax,%eax
  105320:	74 0b                	je     10532d <default_check+0x3c3>
  105322:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105325:	8b 40 08             	mov    0x8(%eax),%eax
  105328:	83 f8 01             	cmp    $0x1,%eax
  10532b:	74 24                	je     105351 <default_check+0x3e7>
  10532d:	c7 44 24 0c fc 70 10 	movl   $0x1070fc,0xc(%esp)
  105334:	00 
  105335:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  10533c:	00 
  10533d:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  105344:	00 
  105345:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  10534c:	e8 a8 b0 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105354:	83 c0 04             	add    $0x4,%eax
  105357:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10535e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105361:	8b 45 90             	mov    -0x70(%ebp),%eax
  105364:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105367:	0f a3 10             	bt     %edx,(%eax)
  10536a:	19 c0                	sbb    %eax,%eax
  10536c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10536f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105373:	0f 95 c0             	setne  %al
  105376:	0f b6 c0             	movzbl %al,%eax
  105379:	85 c0                	test   %eax,%eax
  10537b:	74 0b                	je     105388 <default_check+0x41e>
  10537d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105380:	8b 40 08             	mov    0x8(%eax),%eax
  105383:	83 f8 03             	cmp    $0x3,%eax
  105386:	74 24                	je     1053ac <default_check+0x442>
  105388:	c7 44 24 0c 24 71 10 	movl   $0x107124,0xc(%esp)
  10538f:	00 
  105390:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105397:	00 
  105398:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  10539f:	00 
  1053a0:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1053a7:	e8 4d b0 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1053ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1053b3:	e8 7c d9 ff ff       	call   102d34 <alloc_pages>
  1053b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1053bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053be:	83 e8 14             	sub    $0x14,%eax
  1053c1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1053c4:	74 24                	je     1053ea <default_check+0x480>
  1053c6:	c7 44 24 0c 4a 71 10 	movl   $0x10714a,0xc(%esp)
  1053cd:	00 
  1053ce:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1053d5:	00 
  1053d6:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  1053dd:	00 
  1053de:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1053e5:	e8 0f b0 ff ff       	call   1003f9 <__panic>
    free_page(p0);
  1053ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1053f1:	00 
  1053f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053f5:	89 04 24             	mov    %eax,(%esp)
  1053f8:	e8 6f d9 ff ff       	call   102d6c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1053fd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105404:	e8 2b d9 ff ff       	call   102d34 <alloc_pages>
  105409:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10540c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10540f:	83 c0 14             	add    $0x14,%eax
  105412:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105415:	74 24                	je     10543b <default_check+0x4d1>
  105417:	c7 44 24 0c 68 71 10 	movl   $0x107168,0xc(%esp)
  10541e:	00 
  10541f:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105426:	00 
  105427:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  10542e:	00 
  10542f:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105436:	e8 be af ff ff       	call   1003f9 <__panic>

    free_pages(p0, 2);
  10543b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105442:	00 
  105443:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105446:	89 04 24             	mov    %eax,(%esp)
  105449:	e8 1e d9 ff ff       	call   102d6c <free_pages>
    free_page(p2);
  10544e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105455:	00 
  105456:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105459:	89 04 24             	mov    %eax,(%esp)
  10545c:	e8 0b d9 ff ff       	call   102d6c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105461:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105468:	e8 c7 d8 ff ff       	call   102d34 <alloc_pages>
  10546d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105470:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105474:	75 24                	jne    10549a <default_check+0x530>
  105476:	c7 44 24 0c 88 71 10 	movl   $0x107188,0xc(%esp)
  10547d:	00 
  10547e:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105485:	00 
  105486:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  10548d:	00 
  10548e:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105495:	e8 5f af ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  10549a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1054a1:	e8 8e d8 ff ff       	call   102d34 <alloc_pages>
  1054a6:	85 c0                	test   %eax,%eax
  1054a8:	74 24                	je     1054ce <default_check+0x564>
  1054aa:	c7 44 24 0c e6 6f 10 	movl   $0x106fe6,0xc(%esp)
  1054b1:	00 
  1054b2:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1054b9:	00 
  1054ba:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1054c1:	00 
  1054c2:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1054c9:	e8 2b af ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  1054ce:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  1054d3:	85 c0                	test   %eax,%eax
  1054d5:	74 24                	je     1054fb <default_check+0x591>
  1054d7:	c7 44 24 0c 39 70 10 	movl   $0x107039,0xc(%esp)
  1054de:	00 
  1054df:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1054e6:	00 
  1054e7:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1054ee:	00 
  1054ef:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1054f6:	e8 fe ae ff ff       	call   1003f9 <__panic>
    nr_free = nr_free_store;
  1054fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1054fe:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_list = free_list_store;
  105503:	8b 45 80             	mov    -0x80(%ebp),%eax
  105506:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105509:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  10550e:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    free_pages(p0, 5);
  105514:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10551b:	00 
  10551c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10551f:	89 04 24             	mov    %eax,(%esp)
  105522:	e8 45 d8 ff ff       	call   102d6c <free_pages>

    le = &free_list;
  105527:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10552e:	eb 1c                	jmp    10554c <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
  105530:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105533:	83 e8 0c             	sub    $0xc,%eax
  105536:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105539:	ff 4d f4             	decl   -0xc(%ebp)
  10553c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10553f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105542:	8b 40 08             	mov    0x8(%eax),%eax
  105545:	29 c2                	sub    %eax,%edx
  105547:	89 d0                	mov    %edx,%eax
  105549:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10554c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10554f:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105552:	8b 45 88             	mov    -0x78(%ebp),%eax
  105555:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105558:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10555b:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  105562:	75 cc                	jne    105530 <default_check+0x5c6>
    }
    assert(count == 0);
  105564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105568:	74 24                	je     10558e <default_check+0x624>
  10556a:	c7 44 24 0c a6 71 10 	movl   $0x1071a6,0xc(%esp)
  105571:	00 
  105572:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  105579:	00 
  10557a:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  105581:	00 
  105582:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  105589:	e8 6b ae ff ff       	call   1003f9 <__panic>
    assert(total == 0);
  10558e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105592:	74 24                	je     1055b8 <default_check+0x64e>
  105594:	c7 44 24 0c b1 71 10 	movl   $0x1071b1,0xc(%esp)
  10559b:	00 
  10559c:	c7 44 24 08 5e 6e 10 	movl   $0x106e5e,0x8(%esp)
  1055a3:	00 
  1055a4:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  1055ab:	00 
  1055ac:	c7 04 24 73 6e 10 00 	movl   $0x106e73,(%esp)
  1055b3:	e8 41 ae ff ff       	call   1003f9 <__panic>
}
  1055b8:	90                   	nop
  1055b9:	c9                   	leave  
  1055ba:	c3                   	ret    

001055bb <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1055bb:	55                   	push   %ebp
  1055bc:	89 e5                	mov    %esp,%ebp
  1055be:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1055c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1055c8:	eb 03                	jmp    1055cd <strlen+0x12>
        cnt ++;
  1055ca:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1055cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d0:	8d 50 01             	lea    0x1(%eax),%edx
  1055d3:	89 55 08             	mov    %edx,0x8(%ebp)
  1055d6:	0f b6 00             	movzbl (%eax),%eax
  1055d9:	84 c0                	test   %al,%al
  1055db:	75 ed                	jne    1055ca <strlen+0xf>
    }
    return cnt;
  1055dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1055e0:	c9                   	leave  
  1055e1:	c3                   	ret    

001055e2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1055e2:	55                   	push   %ebp
  1055e3:	89 e5                	mov    %esp,%ebp
  1055e5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1055e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1055ef:	eb 03                	jmp    1055f4 <strnlen+0x12>
        cnt ++;
  1055f1:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1055f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1055f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1055fa:	73 10                	jae    10560c <strnlen+0x2a>
  1055fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ff:	8d 50 01             	lea    0x1(%eax),%edx
  105602:	89 55 08             	mov    %edx,0x8(%ebp)
  105605:	0f b6 00             	movzbl (%eax),%eax
  105608:	84 c0                	test   %al,%al
  10560a:	75 e5                	jne    1055f1 <strnlen+0xf>
    }
    return cnt;
  10560c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10560f:	c9                   	leave  
  105610:	c3                   	ret    

00105611 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105611:	55                   	push   %ebp
  105612:	89 e5                	mov    %esp,%ebp
  105614:	57                   	push   %edi
  105615:	56                   	push   %esi
  105616:	83 ec 20             	sub    $0x20,%esp
  105619:	8b 45 08             	mov    0x8(%ebp),%eax
  10561c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10561f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105622:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105625:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10562b:	89 d1                	mov    %edx,%ecx
  10562d:	89 c2                	mov    %eax,%edx
  10562f:	89 ce                	mov    %ecx,%esi
  105631:	89 d7                	mov    %edx,%edi
  105633:	ac                   	lods   %ds:(%esi),%al
  105634:	aa                   	stos   %al,%es:(%edi)
  105635:	84 c0                	test   %al,%al
  105637:	75 fa                	jne    105633 <strcpy+0x22>
  105639:	89 fa                	mov    %edi,%edx
  10563b:	89 f1                	mov    %esi,%ecx
  10563d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105640:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105643:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105646:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105649:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10564a:	83 c4 20             	add    $0x20,%esp
  10564d:	5e                   	pop    %esi
  10564e:	5f                   	pop    %edi
  10564f:	5d                   	pop    %ebp
  105650:	c3                   	ret    

00105651 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105651:	55                   	push   %ebp
  105652:	89 e5                	mov    %esp,%ebp
  105654:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105657:	8b 45 08             	mov    0x8(%ebp),%eax
  10565a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10565d:	eb 1e                	jmp    10567d <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10565f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105662:	0f b6 10             	movzbl (%eax),%edx
  105665:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105668:	88 10                	mov    %dl,(%eax)
  10566a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10566d:	0f b6 00             	movzbl (%eax),%eax
  105670:	84 c0                	test   %al,%al
  105672:	74 03                	je     105677 <strncpy+0x26>
            src ++;
  105674:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105677:	ff 45 fc             	incl   -0x4(%ebp)
  10567a:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10567d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105681:	75 dc                	jne    10565f <strncpy+0xe>
    }
    return dst;
  105683:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105686:	c9                   	leave  
  105687:	c3                   	ret    

00105688 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105688:	55                   	push   %ebp
  105689:	89 e5                	mov    %esp,%ebp
  10568b:	57                   	push   %edi
  10568c:	56                   	push   %esi
  10568d:	83 ec 20             	sub    $0x20,%esp
  105690:	8b 45 08             	mov    0x8(%ebp),%eax
  105693:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105696:	8b 45 0c             	mov    0xc(%ebp),%eax
  105699:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  10569c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10569f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056a2:	89 d1                	mov    %edx,%ecx
  1056a4:	89 c2                	mov    %eax,%edx
  1056a6:	89 ce                	mov    %ecx,%esi
  1056a8:	89 d7                	mov    %edx,%edi
  1056aa:	ac                   	lods   %ds:(%esi),%al
  1056ab:	ae                   	scas   %es:(%edi),%al
  1056ac:	75 08                	jne    1056b6 <strcmp+0x2e>
  1056ae:	84 c0                	test   %al,%al
  1056b0:	75 f8                	jne    1056aa <strcmp+0x22>
  1056b2:	31 c0                	xor    %eax,%eax
  1056b4:	eb 04                	jmp    1056ba <strcmp+0x32>
  1056b6:	19 c0                	sbb    %eax,%eax
  1056b8:	0c 01                	or     $0x1,%al
  1056ba:	89 fa                	mov    %edi,%edx
  1056bc:	89 f1                	mov    %esi,%ecx
  1056be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056c1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1056c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1056c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1056ca:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1056cb:	83 c4 20             	add    $0x20,%esp
  1056ce:	5e                   	pop    %esi
  1056cf:	5f                   	pop    %edi
  1056d0:	5d                   	pop    %ebp
  1056d1:	c3                   	ret    

001056d2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1056d2:	55                   	push   %ebp
  1056d3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1056d5:	eb 09                	jmp    1056e0 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1056d7:	ff 4d 10             	decl   0x10(%ebp)
  1056da:	ff 45 08             	incl   0x8(%ebp)
  1056dd:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1056e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056e4:	74 1a                	je     105700 <strncmp+0x2e>
  1056e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1056e9:	0f b6 00             	movzbl (%eax),%eax
  1056ec:	84 c0                	test   %al,%al
  1056ee:	74 10                	je     105700 <strncmp+0x2e>
  1056f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1056f3:	0f b6 10             	movzbl (%eax),%edx
  1056f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056f9:	0f b6 00             	movzbl (%eax),%eax
  1056fc:	38 c2                	cmp    %al,%dl
  1056fe:	74 d7                	je     1056d7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105700:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105704:	74 18                	je     10571e <strncmp+0x4c>
  105706:	8b 45 08             	mov    0x8(%ebp),%eax
  105709:	0f b6 00             	movzbl (%eax),%eax
  10570c:	0f b6 d0             	movzbl %al,%edx
  10570f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105712:	0f b6 00             	movzbl (%eax),%eax
  105715:	0f b6 c0             	movzbl %al,%eax
  105718:	29 c2                	sub    %eax,%edx
  10571a:	89 d0                	mov    %edx,%eax
  10571c:	eb 05                	jmp    105723 <strncmp+0x51>
  10571e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105723:	5d                   	pop    %ebp
  105724:	c3                   	ret    

00105725 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105725:	55                   	push   %ebp
  105726:	89 e5                	mov    %esp,%ebp
  105728:	83 ec 04             	sub    $0x4,%esp
  10572b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10572e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105731:	eb 13                	jmp    105746 <strchr+0x21>
        if (*s == c) {
  105733:	8b 45 08             	mov    0x8(%ebp),%eax
  105736:	0f b6 00             	movzbl (%eax),%eax
  105739:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10573c:	75 05                	jne    105743 <strchr+0x1e>
            return (char *)s;
  10573e:	8b 45 08             	mov    0x8(%ebp),%eax
  105741:	eb 12                	jmp    105755 <strchr+0x30>
        }
        s ++;
  105743:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105746:	8b 45 08             	mov    0x8(%ebp),%eax
  105749:	0f b6 00             	movzbl (%eax),%eax
  10574c:	84 c0                	test   %al,%al
  10574e:	75 e3                	jne    105733 <strchr+0xe>
    }
    return NULL;
  105750:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105755:	c9                   	leave  
  105756:	c3                   	ret    

00105757 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105757:	55                   	push   %ebp
  105758:	89 e5                	mov    %esp,%ebp
  10575a:	83 ec 04             	sub    $0x4,%esp
  10575d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105760:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105763:	eb 0e                	jmp    105773 <strfind+0x1c>
        if (*s == c) {
  105765:	8b 45 08             	mov    0x8(%ebp),%eax
  105768:	0f b6 00             	movzbl (%eax),%eax
  10576b:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10576e:	74 0f                	je     10577f <strfind+0x28>
            break;
        }
        s ++;
  105770:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105773:	8b 45 08             	mov    0x8(%ebp),%eax
  105776:	0f b6 00             	movzbl (%eax),%eax
  105779:	84 c0                	test   %al,%al
  10577b:	75 e8                	jne    105765 <strfind+0xe>
  10577d:	eb 01                	jmp    105780 <strfind+0x29>
            break;
  10577f:	90                   	nop
    }
    return (char *)s;
  105780:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105783:	c9                   	leave  
  105784:	c3                   	ret    

00105785 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105785:	55                   	push   %ebp
  105786:	89 e5                	mov    %esp,%ebp
  105788:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10578b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105792:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105799:	eb 03                	jmp    10579e <strtol+0x19>
        s ++;
  10579b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  10579e:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a1:	0f b6 00             	movzbl (%eax),%eax
  1057a4:	3c 20                	cmp    $0x20,%al
  1057a6:	74 f3                	je     10579b <strtol+0x16>
  1057a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ab:	0f b6 00             	movzbl (%eax),%eax
  1057ae:	3c 09                	cmp    $0x9,%al
  1057b0:	74 e9                	je     10579b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1057b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1057b5:	0f b6 00             	movzbl (%eax),%eax
  1057b8:	3c 2b                	cmp    $0x2b,%al
  1057ba:	75 05                	jne    1057c1 <strtol+0x3c>
        s ++;
  1057bc:	ff 45 08             	incl   0x8(%ebp)
  1057bf:	eb 14                	jmp    1057d5 <strtol+0x50>
    }
    else if (*s == '-') {
  1057c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1057c4:	0f b6 00             	movzbl (%eax),%eax
  1057c7:	3c 2d                	cmp    $0x2d,%al
  1057c9:	75 0a                	jne    1057d5 <strtol+0x50>
        s ++, neg = 1;
  1057cb:	ff 45 08             	incl   0x8(%ebp)
  1057ce:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1057d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1057d9:	74 06                	je     1057e1 <strtol+0x5c>
  1057db:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1057df:	75 22                	jne    105803 <strtol+0x7e>
  1057e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e4:	0f b6 00             	movzbl (%eax),%eax
  1057e7:	3c 30                	cmp    $0x30,%al
  1057e9:	75 18                	jne    105803 <strtol+0x7e>
  1057eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ee:	40                   	inc    %eax
  1057ef:	0f b6 00             	movzbl (%eax),%eax
  1057f2:	3c 78                	cmp    $0x78,%al
  1057f4:	75 0d                	jne    105803 <strtol+0x7e>
        s += 2, base = 16;
  1057f6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1057fa:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105801:	eb 29                	jmp    10582c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105803:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105807:	75 16                	jne    10581f <strtol+0x9a>
  105809:	8b 45 08             	mov    0x8(%ebp),%eax
  10580c:	0f b6 00             	movzbl (%eax),%eax
  10580f:	3c 30                	cmp    $0x30,%al
  105811:	75 0c                	jne    10581f <strtol+0x9a>
        s ++, base = 8;
  105813:	ff 45 08             	incl   0x8(%ebp)
  105816:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10581d:	eb 0d                	jmp    10582c <strtol+0xa7>
    }
    else if (base == 0) {
  10581f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105823:	75 07                	jne    10582c <strtol+0xa7>
        base = 10;
  105825:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10582c:	8b 45 08             	mov    0x8(%ebp),%eax
  10582f:	0f b6 00             	movzbl (%eax),%eax
  105832:	3c 2f                	cmp    $0x2f,%al
  105834:	7e 1b                	jle    105851 <strtol+0xcc>
  105836:	8b 45 08             	mov    0x8(%ebp),%eax
  105839:	0f b6 00             	movzbl (%eax),%eax
  10583c:	3c 39                	cmp    $0x39,%al
  10583e:	7f 11                	jg     105851 <strtol+0xcc>
            dig = *s - '0';
  105840:	8b 45 08             	mov    0x8(%ebp),%eax
  105843:	0f b6 00             	movzbl (%eax),%eax
  105846:	0f be c0             	movsbl %al,%eax
  105849:	83 e8 30             	sub    $0x30,%eax
  10584c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10584f:	eb 48                	jmp    105899 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105851:	8b 45 08             	mov    0x8(%ebp),%eax
  105854:	0f b6 00             	movzbl (%eax),%eax
  105857:	3c 60                	cmp    $0x60,%al
  105859:	7e 1b                	jle    105876 <strtol+0xf1>
  10585b:	8b 45 08             	mov    0x8(%ebp),%eax
  10585e:	0f b6 00             	movzbl (%eax),%eax
  105861:	3c 7a                	cmp    $0x7a,%al
  105863:	7f 11                	jg     105876 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105865:	8b 45 08             	mov    0x8(%ebp),%eax
  105868:	0f b6 00             	movzbl (%eax),%eax
  10586b:	0f be c0             	movsbl %al,%eax
  10586e:	83 e8 57             	sub    $0x57,%eax
  105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105874:	eb 23                	jmp    105899 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105876:	8b 45 08             	mov    0x8(%ebp),%eax
  105879:	0f b6 00             	movzbl (%eax),%eax
  10587c:	3c 40                	cmp    $0x40,%al
  10587e:	7e 3b                	jle    1058bb <strtol+0x136>
  105880:	8b 45 08             	mov    0x8(%ebp),%eax
  105883:	0f b6 00             	movzbl (%eax),%eax
  105886:	3c 5a                	cmp    $0x5a,%al
  105888:	7f 31                	jg     1058bb <strtol+0x136>
            dig = *s - 'A' + 10;
  10588a:	8b 45 08             	mov    0x8(%ebp),%eax
  10588d:	0f b6 00             	movzbl (%eax),%eax
  105890:	0f be c0             	movsbl %al,%eax
  105893:	83 e8 37             	sub    $0x37,%eax
  105896:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10589c:	3b 45 10             	cmp    0x10(%ebp),%eax
  10589f:	7d 19                	jge    1058ba <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1058a1:	ff 45 08             	incl   0x8(%ebp)
  1058a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058a7:	0f af 45 10          	imul   0x10(%ebp),%eax
  1058ab:	89 c2                	mov    %eax,%edx
  1058ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058b0:	01 d0                	add    %edx,%eax
  1058b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1058b5:	e9 72 ff ff ff       	jmp    10582c <strtol+0xa7>
            break;
  1058ba:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1058bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1058bf:	74 08                	je     1058c9 <strtol+0x144>
        *endptr = (char *) s;
  1058c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058c4:	8b 55 08             	mov    0x8(%ebp),%edx
  1058c7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1058c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1058cd:	74 07                	je     1058d6 <strtol+0x151>
  1058cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058d2:	f7 d8                	neg    %eax
  1058d4:	eb 03                	jmp    1058d9 <strtol+0x154>
  1058d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1058d9:	c9                   	leave  
  1058da:	c3                   	ret    

001058db <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1058db:	55                   	push   %ebp
  1058dc:	89 e5                	mov    %esp,%ebp
  1058de:	57                   	push   %edi
  1058df:	83 ec 24             	sub    $0x24,%esp
  1058e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058e5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1058e8:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1058ec:	8b 55 08             	mov    0x8(%ebp),%edx
  1058ef:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1058f2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1058f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1058f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1058fb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1058fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105902:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105905:	89 d7                	mov    %edx,%edi
  105907:	f3 aa                	rep stos %al,%es:(%edi)
  105909:	89 fa                	mov    %edi,%edx
  10590b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10590e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105911:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105914:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105915:	83 c4 24             	add    $0x24,%esp
  105918:	5f                   	pop    %edi
  105919:	5d                   	pop    %ebp
  10591a:	c3                   	ret    

0010591b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10591b:	55                   	push   %ebp
  10591c:	89 e5                	mov    %esp,%ebp
  10591e:	57                   	push   %edi
  10591f:	56                   	push   %esi
  105920:	53                   	push   %ebx
  105921:	83 ec 30             	sub    $0x30,%esp
  105924:	8b 45 08             	mov    0x8(%ebp),%eax
  105927:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10592a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10592d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105930:	8b 45 10             	mov    0x10(%ebp),%eax
  105933:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105936:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105939:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10593c:	73 42                	jae    105980 <memmove+0x65>
  10593e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105941:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105944:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105947:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10594a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10594d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105950:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105953:	c1 e8 02             	shr    $0x2,%eax
  105956:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105958:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10595b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10595e:	89 d7                	mov    %edx,%edi
  105960:	89 c6                	mov    %eax,%esi
  105962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105964:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105967:	83 e1 03             	and    $0x3,%ecx
  10596a:	74 02                	je     10596e <memmove+0x53>
  10596c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10596e:	89 f0                	mov    %esi,%eax
  105970:	89 fa                	mov    %edi,%edx
  105972:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105975:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105978:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10597b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  10597e:	eb 36                	jmp    1059b6 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105980:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105983:	8d 50 ff             	lea    -0x1(%eax),%edx
  105986:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105989:	01 c2                	add    %eax,%edx
  10598b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10598e:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105991:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105994:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105997:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10599a:	89 c1                	mov    %eax,%ecx
  10599c:	89 d8                	mov    %ebx,%eax
  10599e:	89 d6                	mov    %edx,%esi
  1059a0:	89 c7                	mov    %eax,%edi
  1059a2:	fd                   	std    
  1059a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1059a5:	fc                   	cld    
  1059a6:	89 f8                	mov    %edi,%eax
  1059a8:	89 f2                	mov    %esi,%edx
  1059aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1059ad:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1059b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1059b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1059b6:	83 c4 30             	add    $0x30,%esp
  1059b9:	5b                   	pop    %ebx
  1059ba:	5e                   	pop    %esi
  1059bb:	5f                   	pop    %edi
  1059bc:	5d                   	pop    %ebp
  1059bd:	c3                   	ret    

001059be <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1059be:	55                   	push   %ebp
  1059bf:	89 e5                	mov    %esp,%ebp
  1059c1:	57                   	push   %edi
  1059c2:	56                   	push   %esi
  1059c3:	83 ec 20             	sub    $0x20,%esp
  1059c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1059c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059d2:	8b 45 10             	mov    0x10(%ebp),%eax
  1059d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1059d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059db:	c1 e8 02             	shr    $0x2,%eax
  1059de:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1059e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059e6:	89 d7                	mov    %edx,%edi
  1059e8:	89 c6                	mov    %eax,%esi
  1059ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1059ec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1059ef:	83 e1 03             	and    $0x3,%ecx
  1059f2:	74 02                	je     1059f6 <memcpy+0x38>
  1059f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1059f6:	89 f0                	mov    %esi,%eax
  1059f8:	89 fa                	mov    %edi,%edx
  1059fa:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1059fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105a00:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105a06:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105a07:	83 c4 20             	add    $0x20,%esp
  105a0a:	5e                   	pop    %esi
  105a0b:	5f                   	pop    %edi
  105a0c:	5d                   	pop    %ebp
  105a0d:	c3                   	ret    

00105a0e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105a0e:	55                   	push   %ebp
  105a0f:	89 e5                	mov    %esp,%ebp
  105a11:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105a14:	8b 45 08             	mov    0x8(%ebp),%eax
  105a17:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105a20:	eb 2e                	jmp    105a50 <memcmp+0x42>
        if (*s1 != *s2) {
  105a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a25:	0f b6 10             	movzbl (%eax),%edx
  105a28:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a2b:	0f b6 00             	movzbl (%eax),%eax
  105a2e:	38 c2                	cmp    %al,%dl
  105a30:	74 18                	je     105a4a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a35:	0f b6 00             	movzbl (%eax),%eax
  105a38:	0f b6 d0             	movzbl %al,%edx
  105a3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a3e:	0f b6 00             	movzbl (%eax),%eax
  105a41:	0f b6 c0             	movzbl %al,%eax
  105a44:	29 c2                	sub    %eax,%edx
  105a46:	89 d0                	mov    %edx,%eax
  105a48:	eb 18                	jmp    105a62 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105a4a:	ff 45 fc             	incl   -0x4(%ebp)
  105a4d:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105a50:	8b 45 10             	mov    0x10(%ebp),%eax
  105a53:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a56:	89 55 10             	mov    %edx,0x10(%ebp)
  105a59:	85 c0                	test   %eax,%eax
  105a5b:	75 c5                	jne    105a22 <memcmp+0x14>
    }
    return 0;
  105a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a62:	c9                   	leave  
  105a63:	c3                   	ret    

00105a64 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105a64:	55                   	push   %ebp
  105a65:	89 e5                	mov    %esp,%ebp
  105a67:	83 ec 58             	sub    $0x58,%esp
  105a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  105a6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105a70:	8b 45 14             	mov    0x14(%ebp),%eax
  105a73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105a76:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105a79:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105a7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a7f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105a82:	8b 45 18             	mov    0x18(%ebp),%eax
  105a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105a91:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105a9e:	74 1c                	je     105abc <printnum+0x58>
  105aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  105aa8:	f7 75 e4             	divl   -0x1c(%ebp)
  105aab:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  105ab6:	f7 75 e4             	divl   -0x1c(%ebp)
  105ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105abf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ac2:	f7 75 e4             	divl   -0x1c(%ebp)
  105ac5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105ac8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105ad1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105ad4:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105ad7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ada:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105add:	8b 45 18             	mov    0x18(%ebp),%eax
  105ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  105ae5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105ae8:	72 56                	jb     105b40 <printnum+0xdc>
  105aea:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105aed:	77 05                	ja     105af4 <printnum+0x90>
  105aef:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105af2:	72 4c                	jb     105b40 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105af4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105af7:	8d 50 ff             	lea    -0x1(%eax),%edx
  105afa:	8b 45 20             	mov    0x20(%ebp),%eax
  105afd:	89 44 24 18          	mov    %eax,0x18(%esp)
  105b01:	89 54 24 14          	mov    %edx,0x14(%esp)
  105b05:	8b 45 18             	mov    0x18(%ebp),%eax
  105b08:	89 44 24 10          	mov    %eax,0x10(%esp)
  105b0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b0f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b12:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b16:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b21:	8b 45 08             	mov    0x8(%ebp),%eax
  105b24:	89 04 24             	mov    %eax,(%esp)
  105b27:	e8 38 ff ff ff       	call   105a64 <printnum>
  105b2c:	eb 1b                	jmp    105b49 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b35:	8b 45 20             	mov    0x20(%ebp),%eax
  105b38:	89 04 24             	mov    %eax,(%esp)
  105b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  105b3e:	ff d0                	call   *%eax
        while (-- width > 0)
  105b40:	ff 4d 1c             	decl   0x1c(%ebp)
  105b43:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105b47:	7f e5                	jg     105b2e <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105b49:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105b4c:	05 6c 72 10 00       	add    $0x10726c,%eax
  105b51:	0f b6 00             	movzbl (%eax),%eax
  105b54:	0f be c0             	movsbl %al,%eax
  105b57:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b5a:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b5e:	89 04 24             	mov    %eax,(%esp)
  105b61:	8b 45 08             	mov    0x8(%ebp),%eax
  105b64:	ff d0                	call   *%eax
}
  105b66:	90                   	nop
  105b67:	c9                   	leave  
  105b68:	c3                   	ret    

00105b69 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105b69:	55                   	push   %ebp
  105b6a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105b6c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105b70:	7e 14                	jle    105b86 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105b72:	8b 45 08             	mov    0x8(%ebp),%eax
  105b75:	8b 00                	mov    (%eax),%eax
  105b77:	8d 48 08             	lea    0x8(%eax),%ecx
  105b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  105b7d:	89 0a                	mov    %ecx,(%edx)
  105b7f:	8b 50 04             	mov    0x4(%eax),%edx
  105b82:	8b 00                	mov    (%eax),%eax
  105b84:	eb 30                	jmp    105bb6 <getuint+0x4d>
    }
    else if (lflag) {
  105b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105b8a:	74 16                	je     105ba2 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8f:	8b 00                	mov    (%eax),%eax
  105b91:	8d 48 04             	lea    0x4(%eax),%ecx
  105b94:	8b 55 08             	mov    0x8(%ebp),%edx
  105b97:	89 0a                	mov    %ecx,(%edx)
  105b99:	8b 00                	mov    (%eax),%eax
  105b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  105ba0:	eb 14                	jmp    105bb6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  105ba5:	8b 00                	mov    (%eax),%eax
  105ba7:	8d 48 04             	lea    0x4(%eax),%ecx
  105baa:	8b 55 08             	mov    0x8(%ebp),%edx
  105bad:	89 0a                	mov    %ecx,(%edx)
  105baf:	8b 00                	mov    (%eax),%eax
  105bb1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105bb6:	5d                   	pop    %ebp
  105bb7:	c3                   	ret    

00105bb8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105bb8:	55                   	push   %ebp
  105bb9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105bbb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105bbf:	7e 14                	jle    105bd5 <getint+0x1d>
        return va_arg(*ap, long long);
  105bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc4:	8b 00                	mov    (%eax),%eax
  105bc6:	8d 48 08             	lea    0x8(%eax),%ecx
  105bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  105bcc:	89 0a                	mov    %ecx,(%edx)
  105bce:	8b 50 04             	mov    0x4(%eax),%edx
  105bd1:	8b 00                	mov    (%eax),%eax
  105bd3:	eb 28                	jmp    105bfd <getint+0x45>
    }
    else if (lflag) {
  105bd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105bd9:	74 12                	je     105bed <getint+0x35>
        return va_arg(*ap, long);
  105bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  105bde:	8b 00                	mov    (%eax),%eax
  105be0:	8d 48 04             	lea    0x4(%eax),%ecx
  105be3:	8b 55 08             	mov    0x8(%ebp),%edx
  105be6:	89 0a                	mov    %ecx,(%edx)
  105be8:	8b 00                	mov    (%eax),%eax
  105bea:	99                   	cltd   
  105beb:	eb 10                	jmp    105bfd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105bed:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf0:	8b 00                	mov    (%eax),%eax
  105bf2:	8d 48 04             	lea    0x4(%eax),%ecx
  105bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  105bf8:	89 0a                	mov    %ecx,(%edx)
  105bfa:	8b 00                	mov    (%eax),%eax
  105bfc:	99                   	cltd   
    }
}
  105bfd:	5d                   	pop    %ebp
  105bfe:	c3                   	ret    

00105bff <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105bff:	55                   	push   %ebp
  105c00:	89 e5                	mov    %esp,%ebp
  105c02:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105c05:	8d 45 14             	lea    0x14(%ebp),%eax
  105c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105c12:	8b 45 10             	mov    0x10(%ebp),%eax
  105c15:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c20:	8b 45 08             	mov    0x8(%ebp),%eax
  105c23:	89 04 24             	mov    %eax,(%esp)
  105c26:	e8 03 00 00 00       	call   105c2e <vprintfmt>
    va_end(ap);
}
  105c2b:	90                   	nop
  105c2c:	c9                   	leave  
  105c2d:	c3                   	ret    

00105c2e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105c2e:	55                   	push   %ebp
  105c2f:	89 e5                	mov    %esp,%ebp
  105c31:	56                   	push   %esi
  105c32:	53                   	push   %ebx
  105c33:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c36:	eb 17                	jmp    105c4f <vprintfmt+0x21>
            if (ch == '\0') {
  105c38:	85 db                	test   %ebx,%ebx
  105c3a:	0f 84 bf 03 00 00    	je     105fff <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105c40:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c47:	89 1c 24             	mov    %ebx,(%esp)
  105c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c4d:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
  105c52:	8d 50 01             	lea    0x1(%eax),%edx
  105c55:	89 55 10             	mov    %edx,0x10(%ebp)
  105c58:	0f b6 00             	movzbl (%eax),%eax
  105c5b:	0f b6 d8             	movzbl %al,%ebx
  105c5e:	83 fb 25             	cmp    $0x25,%ebx
  105c61:	75 d5                	jne    105c38 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105c63:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105c67:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c71:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105c74:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105c7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105c7e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105c81:	8b 45 10             	mov    0x10(%ebp),%eax
  105c84:	8d 50 01             	lea    0x1(%eax),%edx
  105c87:	89 55 10             	mov    %edx,0x10(%ebp)
  105c8a:	0f b6 00             	movzbl (%eax),%eax
  105c8d:	0f b6 d8             	movzbl %al,%ebx
  105c90:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105c93:	83 f8 55             	cmp    $0x55,%eax
  105c96:	0f 87 37 03 00 00    	ja     105fd3 <vprintfmt+0x3a5>
  105c9c:	8b 04 85 90 72 10 00 	mov    0x107290(,%eax,4),%eax
  105ca3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105ca5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105ca9:	eb d6                	jmp    105c81 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105cab:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105caf:	eb d0                	jmp    105c81 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105cb1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105cb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105cbb:	89 d0                	mov    %edx,%eax
  105cbd:	c1 e0 02             	shl    $0x2,%eax
  105cc0:	01 d0                	add    %edx,%eax
  105cc2:	01 c0                	add    %eax,%eax
  105cc4:	01 d8                	add    %ebx,%eax
  105cc6:	83 e8 30             	sub    $0x30,%eax
  105cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  105ccf:	0f b6 00             	movzbl (%eax),%eax
  105cd2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105cd5:	83 fb 2f             	cmp    $0x2f,%ebx
  105cd8:	7e 38                	jle    105d12 <vprintfmt+0xe4>
  105cda:	83 fb 39             	cmp    $0x39,%ebx
  105cdd:	7f 33                	jg     105d12 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105cdf:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105ce2:	eb d4                	jmp    105cb8 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105ce4:	8b 45 14             	mov    0x14(%ebp),%eax
  105ce7:	8d 50 04             	lea    0x4(%eax),%edx
  105cea:	89 55 14             	mov    %edx,0x14(%ebp)
  105ced:	8b 00                	mov    (%eax),%eax
  105cef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105cf2:	eb 1f                	jmp    105d13 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105cf4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105cf8:	79 87                	jns    105c81 <vprintfmt+0x53>
                width = 0;
  105cfa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105d01:	e9 7b ff ff ff       	jmp    105c81 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105d06:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105d0d:	e9 6f ff ff ff       	jmp    105c81 <vprintfmt+0x53>
            goto process_precision;
  105d12:	90                   	nop

        process_precision:
            if (width < 0)
  105d13:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d17:	0f 89 64 ff ff ff    	jns    105c81 <vprintfmt+0x53>
                width = precision, precision = -1;
  105d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d20:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105d23:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105d2a:	e9 52 ff ff ff       	jmp    105c81 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105d2f:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105d32:	e9 4a ff ff ff       	jmp    105c81 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105d37:	8b 45 14             	mov    0x14(%ebp),%eax
  105d3a:	8d 50 04             	lea    0x4(%eax),%edx
  105d3d:	89 55 14             	mov    %edx,0x14(%ebp)
  105d40:	8b 00                	mov    (%eax),%eax
  105d42:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d45:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d49:	89 04 24             	mov    %eax,(%esp)
  105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4f:	ff d0                	call   *%eax
            break;
  105d51:	e9 a4 02 00 00       	jmp    105ffa <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105d56:	8b 45 14             	mov    0x14(%ebp),%eax
  105d59:	8d 50 04             	lea    0x4(%eax),%edx
  105d5c:	89 55 14             	mov    %edx,0x14(%ebp)
  105d5f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105d61:	85 db                	test   %ebx,%ebx
  105d63:	79 02                	jns    105d67 <vprintfmt+0x139>
                err = -err;
  105d65:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105d67:	83 fb 06             	cmp    $0x6,%ebx
  105d6a:	7f 0b                	jg     105d77 <vprintfmt+0x149>
  105d6c:	8b 34 9d 50 72 10 00 	mov    0x107250(,%ebx,4),%esi
  105d73:	85 f6                	test   %esi,%esi
  105d75:	75 23                	jne    105d9a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105d77:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105d7b:	c7 44 24 08 7d 72 10 	movl   $0x10727d,0x8(%esp)
  105d82:	00 
  105d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8d:	89 04 24             	mov    %eax,(%esp)
  105d90:	e8 6a fe ff ff       	call   105bff <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105d95:	e9 60 02 00 00       	jmp    105ffa <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105d9a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105d9e:	c7 44 24 08 86 72 10 	movl   $0x107286,0x8(%esp)
  105da5:	00 
  105da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dad:	8b 45 08             	mov    0x8(%ebp),%eax
  105db0:	89 04 24             	mov    %eax,(%esp)
  105db3:	e8 47 fe ff ff       	call   105bff <printfmt>
            break;
  105db8:	e9 3d 02 00 00       	jmp    105ffa <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105dbd:	8b 45 14             	mov    0x14(%ebp),%eax
  105dc0:	8d 50 04             	lea    0x4(%eax),%edx
  105dc3:	89 55 14             	mov    %edx,0x14(%ebp)
  105dc6:	8b 30                	mov    (%eax),%esi
  105dc8:	85 f6                	test   %esi,%esi
  105dca:	75 05                	jne    105dd1 <vprintfmt+0x1a3>
                p = "(null)";
  105dcc:	be 89 72 10 00       	mov    $0x107289,%esi
            }
            if (width > 0 && padc != '-') {
  105dd1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105dd5:	7e 76                	jle    105e4d <vprintfmt+0x21f>
  105dd7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105ddb:	74 70                	je     105e4d <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105de0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105de4:	89 34 24             	mov    %esi,(%esp)
  105de7:	e8 f6 f7 ff ff       	call   1055e2 <strnlen>
  105dec:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105def:	29 c2                	sub    %eax,%edx
  105df1:	89 d0                	mov    %edx,%eax
  105df3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105df6:	eb 16                	jmp    105e0e <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105df8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  105dff:	89 54 24 04          	mov    %edx,0x4(%esp)
  105e03:	89 04 24             	mov    %eax,(%esp)
  105e06:	8b 45 08             	mov    0x8(%ebp),%eax
  105e09:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105e0b:	ff 4d e8             	decl   -0x18(%ebp)
  105e0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e12:	7f e4                	jg     105df8 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e14:	eb 37                	jmp    105e4d <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105e16:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105e1a:	74 1f                	je     105e3b <vprintfmt+0x20d>
  105e1c:	83 fb 1f             	cmp    $0x1f,%ebx
  105e1f:	7e 05                	jle    105e26 <vprintfmt+0x1f8>
  105e21:	83 fb 7e             	cmp    $0x7e,%ebx
  105e24:	7e 15                	jle    105e3b <vprintfmt+0x20d>
                    putch('?', putdat);
  105e26:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e29:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e2d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105e34:	8b 45 08             	mov    0x8(%ebp),%eax
  105e37:	ff d0                	call   *%eax
  105e39:	eb 0f                	jmp    105e4a <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e42:	89 1c 24             	mov    %ebx,(%esp)
  105e45:	8b 45 08             	mov    0x8(%ebp),%eax
  105e48:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e4a:	ff 4d e8             	decl   -0x18(%ebp)
  105e4d:	89 f0                	mov    %esi,%eax
  105e4f:	8d 70 01             	lea    0x1(%eax),%esi
  105e52:	0f b6 00             	movzbl (%eax),%eax
  105e55:	0f be d8             	movsbl %al,%ebx
  105e58:	85 db                	test   %ebx,%ebx
  105e5a:	74 27                	je     105e83 <vprintfmt+0x255>
  105e5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e60:	78 b4                	js     105e16 <vprintfmt+0x1e8>
  105e62:	ff 4d e4             	decl   -0x1c(%ebp)
  105e65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e69:	79 ab                	jns    105e16 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105e6b:	eb 16                	jmp    105e83 <vprintfmt+0x255>
                putch(' ', putdat);
  105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e74:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e7e:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105e80:	ff 4d e8             	decl   -0x18(%ebp)
  105e83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e87:	7f e4                	jg     105e6d <vprintfmt+0x23f>
            }
            break;
  105e89:	e9 6c 01 00 00       	jmp    105ffa <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105e8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e95:	8d 45 14             	lea    0x14(%ebp),%eax
  105e98:	89 04 24             	mov    %eax,(%esp)
  105e9b:	e8 18 fd ff ff       	call   105bb8 <getint>
  105ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ea3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105eac:	85 d2                	test   %edx,%edx
  105eae:	79 26                	jns    105ed6 <vprintfmt+0x2a8>
                putch('-', putdat);
  105eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105eb7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec1:	ff d0                	call   *%eax
                num = -(long long)num;
  105ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ec6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ec9:	f7 d8                	neg    %eax
  105ecb:	83 d2 00             	adc    $0x0,%edx
  105ece:	f7 da                	neg    %edx
  105ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ed3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105ed6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105edd:	e9 a8 00 00 00       	jmp    105f8a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105ee2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ee9:	8d 45 14             	lea    0x14(%ebp),%eax
  105eec:	89 04 24             	mov    %eax,(%esp)
  105eef:	e8 75 fc ff ff       	call   105b69 <getuint>
  105ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ef7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105efa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105f01:	e9 84 00 00 00       	jmp    105f8a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f09:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f0d:	8d 45 14             	lea    0x14(%ebp),%eax
  105f10:	89 04 24             	mov    %eax,(%esp)
  105f13:	e8 51 fc ff ff       	call   105b69 <getuint>
  105f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f1b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105f1e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105f25:	eb 63                	jmp    105f8a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f2e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105f35:	8b 45 08             	mov    0x8(%ebp),%eax
  105f38:	ff d0                	call   *%eax
            putch('x', putdat);
  105f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f41:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105f48:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4b:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105f4d:	8b 45 14             	mov    0x14(%ebp),%eax
  105f50:	8d 50 04             	lea    0x4(%eax),%edx
  105f53:	89 55 14             	mov    %edx,0x14(%ebp)
  105f56:	8b 00                	mov    (%eax),%eax
  105f58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105f62:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105f69:	eb 1f                	jmp    105f8a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f72:	8d 45 14             	lea    0x14(%ebp),%eax
  105f75:	89 04 24             	mov    %eax,(%esp)
  105f78:	e8 ec fb ff ff       	call   105b69 <getuint>
  105f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f80:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105f83:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105f8a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f91:	89 54 24 18          	mov    %edx,0x18(%esp)
  105f95:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105f98:	89 54 24 14          	mov    %edx,0x14(%esp)
  105f9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  105fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fa6:	89 44 24 08          	mov    %eax,0x8(%esp)
  105faa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105fae:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  105fb8:	89 04 24             	mov    %eax,(%esp)
  105fbb:	e8 a4 fa ff ff       	call   105a64 <printnum>
            break;
  105fc0:	eb 38                	jmp    105ffa <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fc9:	89 1c 24             	mov    %ebx,(%esp)
  105fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  105fcf:	ff d0                	call   *%eax
            break;
  105fd1:	eb 27                	jmp    105ffa <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fda:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  105fe4:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105fe6:	ff 4d 10             	decl   0x10(%ebp)
  105fe9:	eb 03                	jmp    105fee <vprintfmt+0x3c0>
  105feb:	ff 4d 10             	decl   0x10(%ebp)
  105fee:	8b 45 10             	mov    0x10(%ebp),%eax
  105ff1:	48                   	dec    %eax
  105ff2:	0f b6 00             	movzbl (%eax),%eax
  105ff5:	3c 25                	cmp    $0x25,%al
  105ff7:	75 f2                	jne    105feb <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105ff9:	90                   	nop
    while (1) {
  105ffa:	e9 37 fc ff ff       	jmp    105c36 <vprintfmt+0x8>
                return;
  105fff:	90                   	nop
        }
    }
}
  106000:	83 c4 40             	add    $0x40,%esp
  106003:	5b                   	pop    %ebx
  106004:	5e                   	pop    %esi
  106005:	5d                   	pop    %ebp
  106006:	c3                   	ret    

00106007 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106007:	55                   	push   %ebp
  106008:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10600a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10600d:	8b 40 08             	mov    0x8(%eax),%eax
  106010:	8d 50 01             	lea    0x1(%eax),%edx
  106013:	8b 45 0c             	mov    0xc(%ebp),%eax
  106016:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106019:	8b 45 0c             	mov    0xc(%ebp),%eax
  10601c:	8b 10                	mov    (%eax),%edx
  10601e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106021:	8b 40 04             	mov    0x4(%eax),%eax
  106024:	39 c2                	cmp    %eax,%edx
  106026:	73 12                	jae    10603a <sprintputch+0x33>
        *b->buf ++ = ch;
  106028:	8b 45 0c             	mov    0xc(%ebp),%eax
  10602b:	8b 00                	mov    (%eax),%eax
  10602d:	8d 48 01             	lea    0x1(%eax),%ecx
  106030:	8b 55 0c             	mov    0xc(%ebp),%edx
  106033:	89 0a                	mov    %ecx,(%edx)
  106035:	8b 55 08             	mov    0x8(%ebp),%edx
  106038:	88 10                	mov    %dl,(%eax)
    }
}
  10603a:	90                   	nop
  10603b:	5d                   	pop    %ebp
  10603c:	c3                   	ret    

0010603d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10603d:	55                   	push   %ebp
  10603e:	89 e5                	mov    %esp,%ebp
  106040:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106043:	8d 45 14             	lea    0x14(%ebp),%eax
  106046:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106049:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10604c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106050:	8b 45 10             	mov    0x10(%ebp),%eax
  106053:	89 44 24 08          	mov    %eax,0x8(%esp)
  106057:	8b 45 0c             	mov    0xc(%ebp),%eax
  10605a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10605e:	8b 45 08             	mov    0x8(%ebp),%eax
  106061:	89 04 24             	mov    %eax,(%esp)
  106064:	e8 08 00 00 00       	call   106071 <vsnprintf>
  106069:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10606c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10606f:	c9                   	leave  
  106070:	c3                   	ret    

00106071 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106071:	55                   	push   %ebp
  106072:	89 e5                	mov    %esp,%ebp
  106074:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106077:	8b 45 08             	mov    0x8(%ebp),%eax
  10607a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10607d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106080:	8d 50 ff             	lea    -0x1(%eax),%edx
  106083:	8b 45 08             	mov    0x8(%ebp),%eax
  106086:	01 d0                	add    %edx,%eax
  106088:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10608b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106092:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106096:	74 0a                	je     1060a2 <vsnprintf+0x31>
  106098:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10609e:	39 c2                	cmp    %eax,%edx
  1060a0:	76 07                	jbe    1060a9 <vsnprintf+0x38>
        return -E_INVAL;
  1060a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1060a7:	eb 2a                	jmp    1060d3 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1060a9:	8b 45 14             	mov    0x14(%ebp),%eax
  1060ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1060b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1060b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1060b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1060ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060be:	c7 04 24 07 60 10 00 	movl   $0x106007,(%esp)
  1060c5:	e8 64 fb ff ff       	call   105c2e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1060ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060cd:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1060d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1060d3:	c9                   	leave  
  1060d4:	c3                   	ret    
