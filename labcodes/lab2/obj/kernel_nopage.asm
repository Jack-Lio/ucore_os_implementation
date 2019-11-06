
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

    # unmap va 0 ~ 4M, it's temporary mapping
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

# should never get here
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
  10005d:	e8 9e 58 00 00       	call   105900 <memset>

    cons_init();                // init the console
  100062:	e8 a3 15 00 00       	call   10160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 61 10 00 	movl   $0x106100,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 61 10 00 	movl   $0x10611c,(%esp)
  10007c:	e8 21 02 00 00       	call   1002a2 <cprintf>

    print_kerninfo();
  100081:	e8 c2 08 00 00       	call   100948 <print_kerninfo>

    grade_backtrace();
  100086:	e8 8e 00 00 00       	call   100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 9b 32 00 00       	call   10332b <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 da 16 00 00       	call   10176f <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 5f 18 00 00       	call   1018f9 <idt_init>

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
  100167:	c7 04 24 21 61 10 00 	movl   $0x106121,(%esp)
  10016e:	e8 2f 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 2f 61 10 00 	movl   $0x10612f,(%esp)
  10018d:	e8 10 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 3d 61 10 00 	movl   $0x10613d,(%esp)
  1001ac:	e8 f1 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 4b 61 10 00 	movl   $0x10614b,(%esp)
  1001cb:	e8 d2 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 59 61 10 00 	movl   $0x106159,(%esp)
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
  10021f:	c7 04 24 68 61 10 00 	movl   $0x106168,(%esp)
  100226:	e8 77 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_user();
  10022b:	e8 cd ff ff ff       	call   1001fd <lab1_switch_to_user>
    lab1_print_cur_status();
  100230:	e8 0a ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100235:	c7 04 24 88 61 10 00 	movl   $0x106188,(%esp)
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
  100298:	e8 b6 59 00 00       	call   105c53 <vprintfmt>
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
  100357:	c7 04 24 a7 61 10 00 	movl   $0x1061a7,(%esp)
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
  100426:	c7 04 24 aa 61 10 00 	movl   $0x1061aa,(%esp)
  10042d:	e8 70 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100435:	89 44 24 04          	mov    %eax,0x4(%esp)
  100439:	8b 45 10             	mov    0x10(%ebp),%eax
  10043c:	89 04 24             	mov    %eax,(%esp)
  10043f:	e8 2b fe ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  100444:	c7 04 24 c6 61 10 00 	movl   $0x1061c6,(%esp)
  10044b:	e8 52 fe ff ff       	call   1002a2 <cprintf>
    
    cprintf("stack trackback:\n");
  100450:	c7 04 24 c8 61 10 00 	movl   $0x1061c8,(%esp)
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
  100491:	c7 04 24 da 61 10 00 	movl   $0x1061da,(%esp)
  100498:	e8 05 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  10049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a7:	89 04 24             	mov    %eax,(%esp)
  1004aa:	e8 c0 fd ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  1004af:	c7 04 24 c6 61 10 00 	movl   $0x1061c6,(%esp)
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
  10061f:	c7 00 f8 61 10 00    	movl   $0x1061f8,(%eax)
    info->eip_line = 0;
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	c7 40 08 f8 61 10 00 	movl   $0x1061f8,0x8(%eax)
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
  100656:	c7 45 f4 28 74 10 00 	movl   $0x107428,-0xc(%ebp)
    stab_end = __STAB_END__;
  10065d:	c7 45 f0 04 28 11 00 	movl   $0x112804,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100664:	c7 45 ec 05 28 11 00 	movl   $0x112805,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10066b:	c7 45 e8 32 53 11 00 	movl   $0x115332,-0x18(%ebp)

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
  1007c6:	e8 b1 4f 00 00       	call   10577c <strfind>
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
  10094e:	c7 04 24 02 62 10 00 	movl   $0x106202,(%esp)
  100955:	e8 48 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100961:	00 
  100962:	c7 04 24 1b 62 10 00 	movl   $0x10621b,(%esp)
  100969:	e8 34 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096e:	c7 44 24 04 fa 60 10 	movl   $0x1060fa,0x4(%esp)
  100975:	00 
  100976:	c7 04 24 33 62 10 00 	movl   $0x106233,(%esp)
  10097d:	e8 20 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100982:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  100989:	00 
  10098a:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  100991:	e8 0c f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100996:	c7 44 24 04 28 bf 11 	movl   $0x11bf28,0x4(%esp)
  10099d:	00 
  10099e:	c7 04 24 63 62 10 00 	movl   $0x106263,(%esp)
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
  1009d0:	c7 04 24 7c 62 10 00 	movl   $0x10627c,(%esp)
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
  100a05:	c7 04 24 a6 62 10 00 	movl   $0x1062a6,(%esp)
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
  100a73:	c7 04 24 c2 62 10 00 	movl   $0x1062c2,(%esp)
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
  100ad0:	c7 04 24 d4 62 10 00 	movl   $0x1062d4,(%esp)
  100ad7:	e8 c6 f7 ff ff       	call   1002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	83 c0 08             	add    $0x8,%eax
  100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
  100ae5:	c7 04 24 f2 62 10 00 	movl   $0x1062f2,(%esp)
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
  100b0f:	c7 04 24 f9 62 10 00 	movl   $0x1062f9,(%esp)
  100b16:	e8 87 f7 ff ff       	call   1002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
  100b1b:	ff 45 e8             	incl   -0x18(%ebp)
  100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b22:	7e d6                	jle    100afa <print_stackframe+0x67>
        }
        cprintf("\n");
  100b24:	c7 04 24 01 63 10 00 	movl   $0x106301,(%esp)
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
  100b94:	c7 04 24 84 63 10 00 	movl   $0x106384,(%esp)
  100b9b:	e8 aa 4b 00 00       	call   10574a <strchr>
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
  100bbc:	c7 04 24 89 63 10 00 	movl   $0x106389,(%esp)
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
  100bfe:	c7 04 24 84 63 10 00 	movl   $0x106384,(%esp)
  100c05:	e8 40 4b 00 00       	call   10574a <strchr>
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
  100c6b:	e8 3d 4a 00 00       	call   1056ad <strcmp>
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
  100cb7:	c7 04 24 a7 63 10 00 	movl   $0x1063a7,(%esp)
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
  100cd4:	c7 04 24 c0 63 10 00 	movl   $0x1063c0,(%esp)
  100cdb:	e8 c2 f5 ff ff       	call   1002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ce0:	c7 04 24 e8 63 10 00 	movl   $0x1063e8,(%esp)
  100ce7:	e8 b6 f5 ff ff       	call   1002a2 <cprintf>

    if (tf != NULL) {
  100cec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cf0:	74 0b                	je     100cfd <kmonitor+0x2f>
        print_trapframe(tf);
  100cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf5:	89 04 24             	mov    %eax,(%esp)
  100cf8:	e8 b4 0d 00 00       	call   101ab1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cfd:	c7 04 24 0d 64 10 00 	movl   $0x10640d,(%esp)
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
  100d6b:	c7 04 24 11 64 10 00 	movl   $0x106411,(%esp)
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
  100df6:	c7 04 24 1a 64 10 00 	movl   $0x10641a,(%esp)
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
  101238:	e8 03 47 00 00       	call   105940 <memmove>
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
  1015b8:	c7 04 24 35 64 10 00 	movl   $0x106435,(%esp)
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
  101628:	c7 04 24 41 64 10 00 	movl   $0x106441,(%esp)
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
  1018c5:	c7 04 24 60 64 10 00 	movl   $0x106460,(%esp)
  1018cc:	e8 d1 e9 ff ff       	call   1002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018d1:	c7 04 24 6a 64 10 00 	movl   $0x10646a,(%esp)
  1018d8:	e8 c5 e9 ff ff       	call   1002a2 <cprintf>
    panic("EOT: kernel seems ok.");
  1018dd:	c7 44 24 08 78 64 10 	movl   $0x106478,0x8(%esp)
  1018e4:	00 
  1018e5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018ec:	00 
  1018ed:	c7 04 24 8e 64 10 00 	movl   $0x10648e,(%esp)
  1018f4:	e8 00 eb ff ff       	call   1003f9 <__panic>

001018f9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018f9:	55                   	push   %ebp
  1018fa:	89 e5                	mov    %esp,%ebp
  1018fc:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uint32_t __vectors[];
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  1018ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101906:	e9 c4 00 00 00       	jmp    1019cf <idt_init+0xd6>
    {
      SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  10190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190e:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101915:	0f b7 d0             	movzwl %ax,%edx
  101918:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191b:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  101922:	00 
  101923:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101926:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  10192d:	00 08 00 
  101930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101933:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10193a:	00 
  10193b:	80 e2 e0             	and    $0xe0,%dl
  10193e:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101945:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101948:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10194f:	00 
  101950:	80 e2 1f             	and    $0x1f,%dl
  101953:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  10195a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10195d:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101964:	00 
  101965:	80 e2 f0             	and    $0xf0,%dl
  101968:	80 ca 0e             	or     $0xe,%dl
  10196b:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101972:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101975:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10197c:	00 
  10197d:	80 e2 ef             	and    $0xef,%dl
  101980:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101987:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198a:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101991:	00 
  101992:	80 e2 9f             	and    $0x9f,%dl
  101995:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199f:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  1019a6:	00 
  1019a7:	80 ca 80             	or     $0x80,%dl
  1019aa:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  1019b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b4:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  1019bb:	c1 e8 10             	shr    $0x10,%eax
  1019be:	0f b7 d0             	movzwl %ax,%edx
  1019c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c4:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  1019cb:	00 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  1019cc:	ff 45 fc             	incl   -0x4(%ebp)
  1019cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019d7:	0f 86 2e ff ff ff    	jbe    10190b <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019dd:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  1019e2:	0f b7 c0             	movzwl %ax,%eax
  1019e5:	66 a3 48 ba 11 00    	mov    %ax,0x11ba48
  1019eb:	66 c7 05 4a ba 11 00 	movw   $0x8,0x11ba4a
  1019f2:	08 00 
  1019f4:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  1019fb:	24 e0                	and    $0xe0,%al
  1019fd:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  101a02:	0f b6 05 4c ba 11 00 	movzbl 0x11ba4c,%eax
  101a09:	24 1f                	and    $0x1f,%al
  101a0b:	a2 4c ba 11 00       	mov    %al,0x11ba4c
  101a10:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a17:	24 f0                	and    $0xf0,%al
  101a19:	0c 0e                	or     $0xe,%al
  101a1b:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a20:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a27:	24 ef                	and    $0xef,%al
  101a29:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a2e:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a35:	0c 60                	or     $0x60,%al
  101a37:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a3c:	0f b6 05 4d ba 11 00 	movzbl 0x11ba4d,%eax
  101a43:	0c 80                	or     $0x80,%al
  101a45:	a2 4d ba 11 00       	mov    %al,0x11ba4d
  101a4a:	a1 c4 87 11 00       	mov    0x1187c4,%eax
  101a4f:	c1 e8 10             	shr    $0x10,%eax
  101a52:	0f b7 c0             	movzwl %ax,%eax
  101a55:	66 a3 4e ba 11 00    	mov    %ax,0x11ba4e
  101a5b:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a62:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a65:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  101a68:	90                   	nop
  101a69:	c9                   	leave  
  101a6a:	c3                   	ret    

00101a6b <trapname>:

static const char *
trapname(int trapno) {
  101a6b:	55                   	push   %ebp
  101a6c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a71:	83 f8 13             	cmp    $0x13,%eax
  101a74:	77 0c                	ja     101a82 <trapname+0x17>
        return excnames[trapno];
  101a76:	8b 45 08             	mov    0x8(%ebp),%eax
  101a79:	8b 04 85 e0 67 10 00 	mov    0x1067e0(,%eax,4),%eax
  101a80:	eb 18                	jmp    101a9a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a82:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a86:	7e 0d                	jle    101a95 <trapname+0x2a>
  101a88:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a8c:	7f 07                	jg     101a95 <trapname+0x2a>
        return "Hardware Interrupt";
  101a8e:	b8 9f 64 10 00       	mov    $0x10649f,%eax
  101a93:	eb 05                	jmp    101a9a <trapname+0x2f>
    }
    return "(unknown trap)";
  101a95:	b8 b2 64 10 00       	mov    $0x1064b2,%eax
}
  101a9a:	5d                   	pop    %ebp
  101a9b:	c3                   	ret    

00101a9c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a9c:	55                   	push   %ebp
  101a9d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aa6:	83 f8 08             	cmp    $0x8,%eax
  101aa9:	0f 94 c0             	sete   %al
  101aac:	0f b6 c0             	movzbl %al,%eax
}
  101aaf:	5d                   	pop    %ebp
  101ab0:	c3                   	ret    

00101ab1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101ab1:	55                   	push   %ebp
  101ab2:	89 e5                	mov    %esp,%ebp
  101ab4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aba:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abe:	c7 04 24 f3 64 10 00 	movl   $0x1064f3,(%esp)
  101ac5:	e8 d8 e7 ff ff       	call   1002a2 <cprintf>
    print_regs(&tf->tf_regs);
  101aca:	8b 45 08             	mov    0x8(%ebp),%eax
  101acd:	89 04 24             	mov    %eax,(%esp)
  101ad0:	e8 8f 01 00 00       	call   101c64 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae0:	c7 04 24 04 65 10 00 	movl   $0x106504,(%esp)
  101ae7:	e8 b6 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101aec:	8b 45 08             	mov    0x8(%ebp),%eax
  101aef:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af7:	c7 04 24 17 65 10 00 	movl   $0x106517,(%esp)
  101afe:	e8 9f e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b03:	8b 45 08             	mov    0x8(%ebp),%eax
  101b06:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0e:	c7 04 24 2a 65 10 00 	movl   $0x10652a,(%esp)
  101b15:	e8 88 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b25:	c7 04 24 3d 65 10 00 	movl   $0x10653d,(%esp)
  101b2c:	e8 71 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b31:	8b 45 08             	mov    0x8(%ebp),%eax
  101b34:	8b 40 30             	mov    0x30(%eax),%eax
  101b37:	89 04 24             	mov    %eax,(%esp)
  101b3a:	e8 2c ff ff ff       	call   101a6b <trapname>
  101b3f:	89 c2                	mov    %eax,%edx
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	8b 40 30             	mov    0x30(%eax),%eax
  101b47:	89 54 24 08          	mov    %edx,0x8(%esp)
  101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4f:	c7 04 24 50 65 10 00 	movl   $0x106550,(%esp)
  101b56:	e8 47 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5e:	8b 40 34             	mov    0x34(%eax),%eax
  101b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b65:	c7 04 24 62 65 10 00 	movl   $0x106562,(%esp)
  101b6c:	e8 31 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b71:	8b 45 08             	mov    0x8(%ebp),%eax
  101b74:	8b 40 38             	mov    0x38(%eax),%eax
  101b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7b:	c7 04 24 71 65 10 00 	movl   $0x106571,(%esp)
  101b82:	e8 1b e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b87:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b92:	c7 04 24 80 65 10 00 	movl   $0x106580,(%esp)
  101b99:	e8 04 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba1:	8b 40 40             	mov    0x40(%eax),%eax
  101ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba8:	c7 04 24 93 65 10 00 	movl   $0x106593,(%esp)
  101baf:	e8 ee e6 ff ff       	call   1002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101bbb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101bc2:	eb 3d                	jmp    101c01 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc7:	8b 50 40             	mov    0x40(%eax),%edx
  101bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bcd:	21 d0                	and    %edx,%eax
  101bcf:	85 c0                	test   %eax,%eax
  101bd1:	74 28                	je     101bfb <print_trapframe+0x14a>
  101bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd6:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101bdd:	85 c0                	test   %eax,%eax
  101bdf:	74 1a                	je     101bfb <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101be4:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bef:	c7 04 24 a2 65 10 00 	movl   $0x1065a2,(%esp)
  101bf6:	e8 a7 e6 ff ff       	call   1002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bfb:	ff 45 f4             	incl   -0xc(%ebp)
  101bfe:	d1 65 f0             	shll   -0x10(%ebp)
  101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c04:	83 f8 17             	cmp    $0x17,%eax
  101c07:	76 bb                	jbe    101bc4 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 40             	mov    0x40(%eax),%eax
  101c0f:	c1 e8 0c             	shr    $0xc,%eax
  101c12:	83 e0 03             	and    $0x3,%eax
  101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c19:	c7 04 24 a6 65 10 00 	movl   $0x1065a6,(%esp)
  101c20:	e8 7d e6 ff ff       	call   1002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	89 04 24             	mov    %eax,(%esp)
  101c2b:	e8 6c fe ff ff       	call   101a9c <trap_in_kernel>
  101c30:	85 c0                	test   %eax,%eax
  101c32:	75 2d                	jne    101c61 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c34:	8b 45 08             	mov    0x8(%ebp),%eax
  101c37:	8b 40 44             	mov    0x44(%eax),%eax
  101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3e:	c7 04 24 af 65 10 00 	movl   $0x1065af,(%esp)
  101c45:	e8 58 e6 ff ff       	call   1002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c55:	c7 04 24 be 65 10 00 	movl   $0x1065be,(%esp)
  101c5c:	e8 41 e6 ff ff       	call   1002a2 <cprintf>
    }
}
  101c61:	90                   	nop
  101c62:	c9                   	leave  
  101c63:	c3                   	ret    

00101c64 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c64:	55                   	push   %ebp
  101c65:	89 e5                	mov    %esp,%ebp
  101c67:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6d:	8b 00                	mov    (%eax),%eax
  101c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c73:	c7 04 24 d1 65 10 00 	movl   $0x1065d1,(%esp)
  101c7a:	e8 23 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c82:	8b 40 04             	mov    0x4(%eax),%eax
  101c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c89:	c7 04 24 e0 65 10 00 	movl   $0x1065e0,(%esp)
  101c90:	e8 0d e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c95:	8b 45 08             	mov    0x8(%ebp),%eax
  101c98:	8b 40 08             	mov    0x8(%eax),%eax
  101c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c9f:	c7 04 24 ef 65 10 00 	movl   $0x1065ef,(%esp)
  101ca6:	e8 f7 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101cab:	8b 45 08             	mov    0x8(%ebp),%eax
  101cae:	8b 40 0c             	mov    0xc(%eax),%eax
  101cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb5:	c7 04 24 fe 65 10 00 	movl   $0x1065fe,(%esp)
  101cbc:	e8 e1 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc4:	8b 40 10             	mov    0x10(%eax),%eax
  101cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccb:	c7 04 24 0d 66 10 00 	movl   $0x10660d,(%esp)
  101cd2:	e8 cb e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  101cda:	8b 40 14             	mov    0x14(%eax),%eax
  101cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce1:	c7 04 24 1c 66 10 00 	movl   $0x10661c,(%esp)
  101ce8:	e8 b5 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101ced:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf0:	8b 40 18             	mov    0x18(%eax),%eax
  101cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf7:	c7 04 24 2b 66 10 00 	movl   $0x10662b,(%esp)
  101cfe:	e8 9f e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d03:	8b 45 08             	mov    0x8(%ebp),%eax
  101d06:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0d:	c7 04 24 3a 66 10 00 	movl   $0x10663a,(%esp)
  101d14:	e8 89 e5 ff ff       	call   1002a2 <cprintf>
}
  101d19:	90                   	nop
  101d1a:	c9                   	leave  
  101d1b:	c3                   	ret    

00101d1c <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d1c:	55                   	push   %ebp
  101d1d:	89 e5                	mov    %esp,%ebp
  101d1f:	57                   	push   %edi
  101d20:	56                   	push   %esi
  101d21:	53                   	push   %ebx
  101d22:	83 ec 7c             	sub    $0x7c,%esp
    char c;

    switch (tf->tf_trapno) {
  101d25:	8b 45 08             	mov    0x8(%ebp),%eax
  101d28:	8b 40 30             	mov    0x30(%eax),%eax
  101d2b:	83 f8 2f             	cmp    $0x2f,%eax
  101d2e:	77 21                	ja     101d51 <trap_dispatch+0x35>
  101d30:	83 f8 2e             	cmp    $0x2e,%eax
  101d33:	0f 83 38 02 00 00    	jae    101f71 <trap_dispatch+0x255>
  101d39:	83 f8 21             	cmp    $0x21,%eax
  101d3c:	0f 84 95 00 00 00    	je     101dd7 <trap_dispatch+0xbb>
  101d42:	83 f8 24             	cmp    $0x24,%eax
  101d45:	74 67                	je     101dae <trap_dispatch+0x92>
  101d47:	83 f8 20             	cmp    $0x20,%eax
  101d4a:	74 1c                	je     101d68 <trap_dispatch+0x4c>
  101d4c:	e9 eb 01 00 00       	jmp    101f3c <trap_dispatch+0x220>
  101d51:	83 f8 78             	cmp    $0x78,%eax
  101d54:	0f 84 a6 00 00 00    	je     101e00 <trap_dispatch+0xe4>
  101d5a:	83 f8 79             	cmp    $0x79,%eax
  101d5d:	0f 84 63 01 00 00    	je     101ec6 <trap_dispatch+0x1aa>
  101d63:	e9 d4 01 00 00       	jmp    101f3c <trap_dispatch+0x220>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101d68:	a1 0c bf 11 00       	mov    0x11bf0c,%eax
  101d6d:	40                   	inc    %eax
  101d6e:	a3 0c bf 11 00       	mov    %eax,0x11bf0c
        if(ticks % TICK_NUM == 0 )
  101d73:	8b 0d 0c bf 11 00    	mov    0x11bf0c,%ecx
  101d79:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d7e:	89 c8                	mov    %ecx,%eax
  101d80:	f7 e2                	mul    %edx
  101d82:	c1 ea 05             	shr    $0x5,%edx
  101d85:	89 d0                	mov    %edx,%eax
  101d87:	c1 e0 02             	shl    $0x2,%eax
  101d8a:	01 d0                	add    %edx,%eax
  101d8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d93:	01 d0                	add    %edx,%eax
  101d95:	c1 e0 02             	shl    $0x2,%eax
  101d98:	29 c1                	sub    %eax,%ecx
  101d9a:	89 ca                	mov    %ecx,%edx
  101d9c:	85 d2                	test   %edx,%edx
  101d9e:	0f 85 d0 01 00 00    	jne    101f74 <trap_dispatch+0x258>
        {
          print_ticks();
  101da4:	e8 0e fb ff ff       	call   1018b7 <print_ticks>
        }
        break;
  101da9:	e9 c6 01 00 00       	jmp    101f74 <trap_dispatch+0x258>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101dae:	e8 c1 f8 ff ff       	call   101674 <cons_getc>
  101db3:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101db6:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101dba:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101dbe:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dc6:	c7 04 24 49 66 10 00 	movl   $0x106649,(%esp)
  101dcd:	e8 d0 e4 ff ff       	call   1002a2 <cprintf>
        break;
  101dd2:	e9 a4 01 00 00       	jmp    101f7b <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101dd7:	e8 98 f8 ff ff       	call   101674 <cons_getc>
  101ddc:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101ddf:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101de3:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101de7:	89 54 24 08          	mov    %edx,0x8(%esp)
  101deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101def:	c7 04 24 5b 66 10 00 	movl   $0x10665b,(%esp)
  101df6:	e8 a7 e4 ff ff       	call   1002a2 <cprintf>
        break;
  101dfb:	e9 7b 01 00 00       	jmp    101f7b <trap_dispatch+0x25f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
      if (tf->tf_cs!=USER_CS)
  101e00:	8b 45 08             	mov    0x8(%ebp),%eax
  101e03:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e07:	83 f8 1b             	cmp    $0x1b,%eax
  101e0a:	0f 84 67 01 00 00    	je     101f77 <trap_dispatch+0x25b>
      {
        struct trapframe temp1 = *tf;//保留寄存器值
  101e10:	8b 55 08             	mov    0x8(%ebp),%edx
  101e13:	8d 45 97             	lea    -0x69(%ebp),%eax
  101e16:	bb 4c 00 00 00       	mov    $0x4c,%ebx
  101e1b:	89 c1                	mov    %eax,%ecx
  101e1d:	83 e1 01             	and    $0x1,%ecx
  101e20:	85 c9                	test   %ecx,%ecx
  101e22:	74 0c                	je     101e30 <trap_dispatch+0x114>
  101e24:	0f b6 0a             	movzbl (%edx),%ecx
  101e27:	88 08                	mov    %cl,(%eax)
  101e29:	8d 40 01             	lea    0x1(%eax),%eax
  101e2c:	8d 52 01             	lea    0x1(%edx),%edx
  101e2f:	4b                   	dec    %ebx
  101e30:	89 c1                	mov    %eax,%ecx
  101e32:	83 e1 02             	and    $0x2,%ecx
  101e35:	85 c9                	test   %ecx,%ecx
  101e37:	74 0f                	je     101e48 <trap_dispatch+0x12c>
  101e39:	0f b7 0a             	movzwl (%edx),%ecx
  101e3c:	66 89 08             	mov    %cx,(%eax)
  101e3f:	8d 40 02             	lea    0x2(%eax),%eax
  101e42:	8d 52 02             	lea    0x2(%edx),%edx
  101e45:	83 eb 02             	sub    $0x2,%ebx
  101e48:	89 df                	mov    %ebx,%edi
  101e4a:	83 e7 fc             	and    $0xfffffffc,%edi
  101e4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  101e52:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
  101e55:	89 34 08             	mov    %esi,(%eax,%ecx,1)
  101e58:	83 c1 04             	add    $0x4,%ecx
  101e5b:	39 f9                	cmp    %edi,%ecx
  101e5d:	72 f3                	jb     101e52 <trap_dispatch+0x136>
  101e5f:	01 c8                	add    %ecx,%eax
  101e61:	01 ca                	add    %ecx,%edx
  101e63:	b9 00 00 00 00       	mov    $0x0,%ecx
  101e68:	89 de                	mov    %ebx,%esi
  101e6a:	83 e6 02             	and    $0x2,%esi
  101e6d:	85 f6                	test   %esi,%esi
  101e6f:	74 0b                	je     101e7c <trap_dispatch+0x160>
  101e71:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
  101e75:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
  101e79:	83 c1 02             	add    $0x2,%ecx
  101e7c:	83 e3 01             	and    $0x1,%ebx
  101e7f:	85 db                	test   %ebx,%ebx
  101e81:	74 07                	je     101e8a <trap_dispatch+0x16e>
  101e83:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
  101e87:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        temp1.tf_cs = USER_CS;
  101e8a:	66 c7 45 d3 1b 00    	movw   $0x1b,-0x2d(%ebp)
        temp1.tf_es = USER_DS;
  101e90:	66 c7 45 bf 23 00    	movw   $0x23,-0x41(%ebp)
        temp1.tf_ds=USER_DS;
  101e96:	66 c7 45 c3 23 00    	movw   $0x23,-0x3d(%ebp)
        temp1.tf_ss = USER_DS;
  101e9c:	66 c7 45 df 23 00    	movw   $0x23,-0x21(%ebp)
        temp1.tf_esp=(uint32_t)tf+sizeof(struct trapframe) -8;
  101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea5:	83 c0 44             	add    $0x44,%eax
  101ea8:	89 45 db             	mov    %eax,-0x25(%ebp)

        temp1.tf_eflags |=FL_IOPL_MASK;
  101eab:	8b 45 d7             	mov    -0x29(%ebp),%eax
  101eae:	0d 00 30 00 00       	or     $0x3000,%eax
  101eb3:	89 45 d7             	mov    %eax,-0x29(%ebp)

        *((uint32_t *)tf -1) = (uint32_t) &temp1;
  101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb9:	8d 50 fc             	lea    -0x4(%eax),%edx
  101ebc:	8d 45 97             	lea    -0x69(%ebp),%eax
  101ebf:	89 02                	mov    %eax,(%edx)
      }
      break;
  101ec1:	e9 b1 00 00 00       	jmp    101f77 <trap_dispatch+0x25b>
    case T_SWITCH_TOK:
    if (tf->tf_cs != KERNEL_CS) {
  101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ecd:	83 f8 08             	cmp    $0x8,%eax
  101ed0:	0f 84 a4 00 00 00    	je     101f7a <trap_dispatch+0x25e>
        tf->tf_cs = KERNEL_CS;
  101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed9:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  101edf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  101eeb:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101eef:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef2:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef9:	8b 40 40             	mov    0x40(%eax),%eax
  101efc:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101f01:	89 c2                	mov    %eax,%edx
  101f03:	8b 45 08             	mov    0x8(%ebp),%eax
  101f06:	89 50 40             	mov    %edx,0x40(%eax)
        struct trapframe*  temp2 = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101f09:	8b 45 08             	mov    0x8(%ebp),%eax
  101f0c:	8b 40 44             	mov    0x44(%eax),%eax
  101f0f:	83 e8 44             	sub    $0x44,%eax
  101f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        memmove(temp2, tf, sizeof(struct trapframe) - 8);
  101f15:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101f1c:	00 
  101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101f27:	89 04 24             	mov    %eax,(%esp)
  101f2a:	e8 11 3a 00 00       	call   105940 <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)temp2;
  101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f32:	8d 50 fc             	lea    -0x4(%eax),%edx
  101f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101f38:	89 02                	mov    %eax,(%edx)
    }
        break;
  101f3a:	eb 3e                	jmp    101f7a <trap_dispatch+0x25e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101f3f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f43:	83 e0 03             	and    $0x3,%eax
  101f46:	85 c0                	test   %eax,%eax
  101f48:	75 31                	jne    101f7b <trap_dispatch+0x25f>
            print_trapframe(tf);
  101f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f4d:	89 04 24             	mov    %eax,(%esp)
  101f50:	e8 5c fb ff ff       	call   101ab1 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f55:	c7 44 24 08 6a 66 10 	movl   $0x10666a,0x8(%esp)
  101f5c:	00 
  101f5d:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  101f64:	00 
  101f65:	c7 04 24 8e 64 10 00 	movl   $0x10648e,(%esp)
  101f6c:	e8 88 e4 ff ff       	call   1003f9 <__panic>
        break;
  101f71:	90                   	nop
  101f72:	eb 07                	jmp    101f7b <trap_dispatch+0x25f>
        break;
  101f74:	90                   	nop
  101f75:	eb 04                	jmp    101f7b <trap_dispatch+0x25f>
      break;
  101f77:	90                   	nop
  101f78:	eb 01                	jmp    101f7b <trap_dispatch+0x25f>
        break;
  101f7a:	90                   	nop
        }
    }
}
  101f7b:	90                   	nop
  101f7c:	83 c4 7c             	add    $0x7c,%esp
  101f7f:	5b                   	pop    %ebx
  101f80:	5e                   	pop    %esi
  101f81:	5f                   	pop    %edi
  101f82:	5d                   	pop    %ebp
  101f83:	c3                   	ret    

00101f84 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f84:	55                   	push   %ebp
  101f85:	89 e5                	mov    %esp,%ebp
  101f87:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f8d:	89 04 24             	mov    %eax,(%esp)
  101f90:	e8 87 fd ff ff       	call   101d1c <trap_dispatch>
}
  101f95:	90                   	nop
  101f96:	c9                   	leave  
  101f97:	c3                   	ret    

00101f98 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f98:	6a 00                	push   $0x0
  pushl $0
  101f9a:	6a 00                	push   $0x0
  jmp __alltraps
  101f9c:	e9 69 0a 00 00       	jmp    102a0a <__alltraps>

00101fa1 <vector1>:
.globl vector1
vector1:
  pushl $0
  101fa1:	6a 00                	push   $0x0
  pushl $1
  101fa3:	6a 01                	push   $0x1
  jmp __alltraps
  101fa5:	e9 60 0a 00 00       	jmp    102a0a <__alltraps>

00101faa <vector2>:
.globl vector2
vector2:
  pushl $0
  101faa:	6a 00                	push   $0x0
  pushl $2
  101fac:	6a 02                	push   $0x2
  jmp __alltraps
  101fae:	e9 57 0a 00 00       	jmp    102a0a <__alltraps>

00101fb3 <vector3>:
.globl vector3
vector3:
  pushl $0
  101fb3:	6a 00                	push   $0x0
  pushl $3
  101fb5:	6a 03                	push   $0x3
  jmp __alltraps
  101fb7:	e9 4e 0a 00 00       	jmp    102a0a <__alltraps>

00101fbc <vector4>:
.globl vector4
vector4:
  pushl $0
  101fbc:	6a 00                	push   $0x0
  pushl $4
  101fbe:	6a 04                	push   $0x4
  jmp __alltraps
  101fc0:	e9 45 0a 00 00       	jmp    102a0a <__alltraps>

00101fc5 <vector5>:
.globl vector5
vector5:
  pushl $0
  101fc5:	6a 00                	push   $0x0
  pushl $5
  101fc7:	6a 05                	push   $0x5
  jmp __alltraps
  101fc9:	e9 3c 0a 00 00       	jmp    102a0a <__alltraps>

00101fce <vector6>:
.globl vector6
vector6:
  pushl $0
  101fce:	6a 00                	push   $0x0
  pushl $6
  101fd0:	6a 06                	push   $0x6
  jmp __alltraps
  101fd2:	e9 33 0a 00 00       	jmp    102a0a <__alltraps>

00101fd7 <vector7>:
.globl vector7
vector7:
  pushl $0
  101fd7:	6a 00                	push   $0x0
  pushl $7
  101fd9:	6a 07                	push   $0x7
  jmp __alltraps
  101fdb:	e9 2a 0a 00 00       	jmp    102a0a <__alltraps>

00101fe0 <vector8>:
.globl vector8
vector8:
  pushl $8
  101fe0:	6a 08                	push   $0x8
  jmp __alltraps
  101fe2:	e9 23 0a 00 00       	jmp    102a0a <__alltraps>

00101fe7 <vector9>:
.globl vector9
vector9:
  pushl $0
  101fe7:	6a 00                	push   $0x0
  pushl $9
  101fe9:	6a 09                	push   $0x9
  jmp __alltraps
  101feb:	e9 1a 0a 00 00       	jmp    102a0a <__alltraps>

00101ff0 <vector10>:
.globl vector10
vector10:
  pushl $10
  101ff0:	6a 0a                	push   $0xa
  jmp __alltraps
  101ff2:	e9 13 0a 00 00       	jmp    102a0a <__alltraps>

00101ff7 <vector11>:
.globl vector11
vector11:
  pushl $11
  101ff7:	6a 0b                	push   $0xb
  jmp __alltraps
  101ff9:	e9 0c 0a 00 00       	jmp    102a0a <__alltraps>

00101ffe <vector12>:
.globl vector12
vector12:
  pushl $12
  101ffe:	6a 0c                	push   $0xc
  jmp __alltraps
  102000:	e9 05 0a 00 00       	jmp    102a0a <__alltraps>

00102005 <vector13>:
.globl vector13
vector13:
  pushl $13
  102005:	6a 0d                	push   $0xd
  jmp __alltraps
  102007:	e9 fe 09 00 00       	jmp    102a0a <__alltraps>

0010200c <vector14>:
.globl vector14
vector14:
  pushl $14
  10200c:	6a 0e                	push   $0xe
  jmp __alltraps
  10200e:	e9 f7 09 00 00       	jmp    102a0a <__alltraps>

00102013 <vector15>:
.globl vector15
vector15:
  pushl $0
  102013:	6a 00                	push   $0x0
  pushl $15
  102015:	6a 0f                	push   $0xf
  jmp __alltraps
  102017:	e9 ee 09 00 00       	jmp    102a0a <__alltraps>

0010201c <vector16>:
.globl vector16
vector16:
  pushl $0
  10201c:	6a 00                	push   $0x0
  pushl $16
  10201e:	6a 10                	push   $0x10
  jmp __alltraps
  102020:	e9 e5 09 00 00       	jmp    102a0a <__alltraps>

00102025 <vector17>:
.globl vector17
vector17:
  pushl $17
  102025:	6a 11                	push   $0x11
  jmp __alltraps
  102027:	e9 de 09 00 00       	jmp    102a0a <__alltraps>

0010202c <vector18>:
.globl vector18
vector18:
  pushl $0
  10202c:	6a 00                	push   $0x0
  pushl $18
  10202e:	6a 12                	push   $0x12
  jmp __alltraps
  102030:	e9 d5 09 00 00       	jmp    102a0a <__alltraps>

00102035 <vector19>:
.globl vector19
vector19:
  pushl $0
  102035:	6a 00                	push   $0x0
  pushl $19
  102037:	6a 13                	push   $0x13
  jmp __alltraps
  102039:	e9 cc 09 00 00       	jmp    102a0a <__alltraps>

0010203e <vector20>:
.globl vector20
vector20:
  pushl $0
  10203e:	6a 00                	push   $0x0
  pushl $20
  102040:	6a 14                	push   $0x14
  jmp __alltraps
  102042:	e9 c3 09 00 00       	jmp    102a0a <__alltraps>

00102047 <vector21>:
.globl vector21
vector21:
  pushl $0
  102047:	6a 00                	push   $0x0
  pushl $21
  102049:	6a 15                	push   $0x15
  jmp __alltraps
  10204b:	e9 ba 09 00 00       	jmp    102a0a <__alltraps>

00102050 <vector22>:
.globl vector22
vector22:
  pushl $0
  102050:	6a 00                	push   $0x0
  pushl $22
  102052:	6a 16                	push   $0x16
  jmp __alltraps
  102054:	e9 b1 09 00 00       	jmp    102a0a <__alltraps>

00102059 <vector23>:
.globl vector23
vector23:
  pushl $0
  102059:	6a 00                	push   $0x0
  pushl $23
  10205b:	6a 17                	push   $0x17
  jmp __alltraps
  10205d:	e9 a8 09 00 00       	jmp    102a0a <__alltraps>

00102062 <vector24>:
.globl vector24
vector24:
  pushl $0
  102062:	6a 00                	push   $0x0
  pushl $24
  102064:	6a 18                	push   $0x18
  jmp __alltraps
  102066:	e9 9f 09 00 00       	jmp    102a0a <__alltraps>

0010206b <vector25>:
.globl vector25
vector25:
  pushl $0
  10206b:	6a 00                	push   $0x0
  pushl $25
  10206d:	6a 19                	push   $0x19
  jmp __alltraps
  10206f:	e9 96 09 00 00       	jmp    102a0a <__alltraps>

00102074 <vector26>:
.globl vector26
vector26:
  pushl $0
  102074:	6a 00                	push   $0x0
  pushl $26
  102076:	6a 1a                	push   $0x1a
  jmp __alltraps
  102078:	e9 8d 09 00 00       	jmp    102a0a <__alltraps>

0010207d <vector27>:
.globl vector27
vector27:
  pushl $0
  10207d:	6a 00                	push   $0x0
  pushl $27
  10207f:	6a 1b                	push   $0x1b
  jmp __alltraps
  102081:	e9 84 09 00 00       	jmp    102a0a <__alltraps>

00102086 <vector28>:
.globl vector28
vector28:
  pushl $0
  102086:	6a 00                	push   $0x0
  pushl $28
  102088:	6a 1c                	push   $0x1c
  jmp __alltraps
  10208a:	e9 7b 09 00 00       	jmp    102a0a <__alltraps>

0010208f <vector29>:
.globl vector29
vector29:
  pushl $0
  10208f:	6a 00                	push   $0x0
  pushl $29
  102091:	6a 1d                	push   $0x1d
  jmp __alltraps
  102093:	e9 72 09 00 00       	jmp    102a0a <__alltraps>

00102098 <vector30>:
.globl vector30
vector30:
  pushl $0
  102098:	6a 00                	push   $0x0
  pushl $30
  10209a:	6a 1e                	push   $0x1e
  jmp __alltraps
  10209c:	e9 69 09 00 00       	jmp    102a0a <__alltraps>

001020a1 <vector31>:
.globl vector31
vector31:
  pushl $0
  1020a1:	6a 00                	push   $0x0
  pushl $31
  1020a3:	6a 1f                	push   $0x1f
  jmp __alltraps
  1020a5:	e9 60 09 00 00       	jmp    102a0a <__alltraps>

001020aa <vector32>:
.globl vector32
vector32:
  pushl $0
  1020aa:	6a 00                	push   $0x0
  pushl $32
  1020ac:	6a 20                	push   $0x20
  jmp __alltraps
  1020ae:	e9 57 09 00 00       	jmp    102a0a <__alltraps>

001020b3 <vector33>:
.globl vector33
vector33:
  pushl $0
  1020b3:	6a 00                	push   $0x0
  pushl $33
  1020b5:	6a 21                	push   $0x21
  jmp __alltraps
  1020b7:	e9 4e 09 00 00       	jmp    102a0a <__alltraps>

001020bc <vector34>:
.globl vector34
vector34:
  pushl $0
  1020bc:	6a 00                	push   $0x0
  pushl $34
  1020be:	6a 22                	push   $0x22
  jmp __alltraps
  1020c0:	e9 45 09 00 00       	jmp    102a0a <__alltraps>

001020c5 <vector35>:
.globl vector35
vector35:
  pushl $0
  1020c5:	6a 00                	push   $0x0
  pushl $35
  1020c7:	6a 23                	push   $0x23
  jmp __alltraps
  1020c9:	e9 3c 09 00 00       	jmp    102a0a <__alltraps>

001020ce <vector36>:
.globl vector36
vector36:
  pushl $0
  1020ce:	6a 00                	push   $0x0
  pushl $36
  1020d0:	6a 24                	push   $0x24
  jmp __alltraps
  1020d2:	e9 33 09 00 00       	jmp    102a0a <__alltraps>

001020d7 <vector37>:
.globl vector37
vector37:
  pushl $0
  1020d7:	6a 00                	push   $0x0
  pushl $37
  1020d9:	6a 25                	push   $0x25
  jmp __alltraps
  1020db:	e9 2a 09 00 00       	jmp    102a0a <__alltraps>

001020e0 <vector38>:
.globl vector38
vector38:
  pushl $0
  1020e0:	6a 00                	push   $0x0
  pushl $38
  1020e2:	6a 26                	push   $0x26
  jmp __alltraps
  1020e4:	e9 21 09 00 00       	jmp    102a0a <__alltraps>

001020e9 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020e9:	6a 00                	push   $0x0
  pushl $39
  1020eb:	6a 27                	push   $0x27
  jmp __alltraps
  1020ed:	e9 18 09 00 00       	jmp    102a0a <__alltraps>

001020f2 <vector40>:
.globl vector40
vector40:
  pushl $0
  1020f2:	6a 00                	push   $0x0
  pushl $40
  1020f4:	6a 28                	push   $0x28
  jmp __alltraps
  1020f6:	e9 0f 09 00 00       	jmp    102a0a <__alltraps>

001020fb <vector41>:
.globl vector41
vector41:
  pushl $0
  1020fb:	6a 00                	push   $0x0
  pushl $41
  1020fd:	6a 29                	push   $0x29
  jmp __alltraps
  1020ff:	e9 06 09 00 00       	jmp    102a0a <__alltraps>

00102104 <vector42>:
.globl vector42
vector42:
  pushl $0
  102104:	6a 00                	push   $0x0
  pushl $42
  102106:	6a 2a                	push   $0x2a
  jmp __alltraps
  102108:	e9 fd 08 00 00       	jmp    102a0a <__alltraps>

0010210d <vector43>:
.globl vector43
vector43:
  pushl $0
  10210d:	6a 00                	push   $0x0
  pushl $43
  10210f:	6a 2b                	push   $0x2b
  jmp __alltraps
  102111:	e9 f4 08 00 00       	jmp    102a0a <__alltraps>

00102116 <vector44>:
.globl vector44
vector44:
  pushl $0
  102116:	6a 00                	push   $0x0
  pushl $44
  102118:	6a 2c                	push   $0x2c
  jmp __alltraps
  10211a:	e9 eb 08 00 00       	jmp    102a0a <__alltraps>

0010211f <vector45>:
.globl vector45
vector45:
  pushl $0
  10211f:	6a 00                	push   $0x0
  pushl $45
  102121:	6a 2d                	push   $0x2d
  jmp __alltraps
  102123:	e9 e2 08 00 00       	jmp    102a0a <__alltraps>

00102128 <vector46>:
.globl vector46
vector46:
  pushl $0
  102128:	6a 00                	push   $0x0
  pushl $46
  10212a:	6a 2e                	push   $0x2e
  jmp __alltraps
  10212c:	e9 d9 08 00 00       	jmp    102a0a <__alltraps>

00102131 <vector47>:
.globl vector47
vector47:
  pushl $0
  102131:	6a 00                	push   $0x0
  pushl $47
  102133:	6a 2f                	push   $0x2f
  jmp __alltraps
  102135:	e9 d0 08 00 00       	jmp    102a0a <__alltraps>

0010213a <vector48>:
.globl vector48
vector48:
  pushl $0
  10213a:	6a 00                	push   $0x0
  pushl $48
  10213c:	6a 30                	push   $0x30
  jmp __alltraps
  10213e:	e9 c7 08 00 00       	jmp    102a0a <__alltraps>

00102143 <vector49>:
.globl vector49
vector49:
  pushl $0
  102143:	6a 00                	push   $0x0
  pushl $49
  102145:	6a 31                	push   $0x31
  jmp __alltraps
  102147:	e9 be 08 00 00       	jmp    102a0a <__alltraps>

0010214c <vector50>:
.globl vector50
vector50:
  pushl $0
  10214c:	6a 00                	push   $0x0
  pushl $50
  10214e:	6a 32                	push   $0x32
  jmp __alltraps
  102150:	e9 b5 08 00 00       	jmp    102a0a <__alltraps>

00102155 <vector51>:
.globl vector51
vector51:
  pushl $0
  102155:	6a 00                	push   $0x0
  pushl $51
  102157:	6a 33                	push   $0x33
  jmp __alltraps
  102159:	e9 ac 08 00 00       	jmp    102a0a <__alltraps>

0010215e <vector52>:
.globl vector52
vector52:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $52
  102160:	6a 34                	push   $0x34
  jmp __alltraps
  102162:	e9 a3 08 00 00       	jmp    102a0a <__alltraps>

00102167 <vector53>:
.globl vector53
vector53:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $53
  102169:	6a 35                	push   $0x35
  jmp __alltraps
  10216b:	e9 9a 08 00 00       	jmp    102a0a <__alltraps>

00102170 <vector54>:
.globl vector54
vector54:
  pushl $0
  102170:	6a 00                	push   $0x0
  pushl $54
  102172:	6a 36                	push   $0x36
  jmp __alltraps
  102174:	e9 91 08 00 00       	jmp    102a0a <__alltraps>

00102179 <vector55>:
.globl vector55
vector55:
  pushl $0
  102179:	6a 00                	push   $0x0
  pushl $55
  10217b:	6a 37                	push   $0x37
  jmp __alltraps
  10217d:	e9 88 08 00 00       	jmp    102a0a <__alltraps>

00102182 <vector56>:
.globl vector56
vector56:
  pushl $0
  102182:	6a 00                	push   $0x0
  pushl $56
  102184:	6a 38                	push   $0x38
  jmp __alltraps
  102186:	e9 7f 08 00 00       	jmp    102a0a <__alltraps>

0010218b <vector57>:
.globl vector57
vector57:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $57
  10218d:	6a 39                	push   $0x39
  jmp __alltraps
  10218f:	e9 76 08 00 00       	jmp    102a0a <__alltraps>

00102194 <vector58>:
.globl vector58
vector58:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $58
  102196:	6a 3a                	push   $0x3a
  jmp __alltraps
  102198:	e9 6d 08 00 00       	jmp    102a0a <__alltraps>

0010219d <vector59>:
.globl vector59
vector59:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $59
  10219f:	6a 3b                	push   $0x3b
  jmp __alltraps
  1021a1:	e9 64 08 00 00       	jmp    102a0a <__alltraps>

001021a6 <vector60>:
.globl vector60
vector60:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $60
  1021a8:	6a 3c                	push   $0x3c
  jmp __alltraps
  1021aa:	e9 5b 08 00 00       	jmp    102a0a <__alltraps>

001021af <vector61>:
.globl vector61
vector61:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $61
  1021b1:	6a 3d                	push   $0x3d
  jmp __alltraps
  1021b3:	e9 52 08 00 00       	jmp    102a0a <__alltraps>

001021b8 <vector62>:
.globl vector62
vector62:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $62
  1021ba:	6a 3e                	push   $0x3e
  jmp __alltraps
  1021bc:	e9 49 08 00 00       	jmp    102a0a <__alltraps>

001021c1 <vector63>:
.globl vector63
vector63:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $63
  1021c3:	6a 3f                	push   $0x3f
  jmp __alltraps
  1021c5:	e9 40 08 00 00       	jmp    102a0a <__alltraps>

001021ca <vector64>:
.globl vector64
vector64:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $64
  1021cc:	6a 40                	push   $0x40
  jmp __alltraps
  1021ce:	e9 37 08 00 00       	jmp    102a0a <__alltraps>

001021d3 <vector65>:
.globl vector65
vector65:
  pushl $0
  1021d3:	6a 00                	push   $0x0
  pushl $65
  1021d5:	6a 41                	push   $0x41
  jmp __alltraps
  1021d7:	e9 2e 08 00 00       	jmp    102a0a <__alltraps>

001021dc <vector66>:
.globl vector66
vector66:
  pushl $0
  1021dc:	6a 00                	push   $0x0
  pushl $66
  1021de:	6a 42                	push   $0x42
  jmp __alltraps
  1021e0:	e9 25 08 00 00       	jmp    102a0a <__alltraps>

001021e5 <vector67>:
.globl vector67
vector67:
  pushl $0
  1021e5:	6a 00                	push   $0x0
  pushl $67
  1021e7:	6a 43                	push   $0x43
  jmp __alltraps
  1021e9:	e9 1c 08 00 00       	jmp    102a0a <__alltraps>

001021ee <vector68>:
.globl vector68
vector68:
  pushl $0
  1021ee:	6a 00                	push   $0x0
  pushl $68
  1021f0:	6a 44                	push   $0x44
  jmp __alltraps
  1021f2:	e9 13 08 00 00       	jmp    102a0a <__alltraps>

001021f7 <vector69>:
.globl vector69
vector69:
  pushl $0
  1021f7:	6a 00                	push   $0x0
  pushl $69
  1021f9:	6a 45                	push   $0x45
  jmp __alltraps
  1021fb:	e9 0a 08 00 00       	jmp    102a0a <__alltraps>

00102200 <vector70>:
.globl vector70
vector70:
  pushl $0
  102200:	6a 00                	push   $0x0
  pushl $70
  102202:	6a 46                	push   $0x46
  jmp __alltraps
  102204:	e9 01 08 00 00       	jmp    102a0a <__alltraps>

00102209 <vector71>:
.globl vector71
vector71:
  pushl $0
  102209:	6a 00                	push   $0x0
  pushl $71
  10220b:	6a 47                	push   $0x47
  jmp __alltraps
  10220d:	e9 f8 07 00 00       	jmp    102a0a <__alltraps>

00102212 <vector72>:
.globl vector72
vector72:
  pushl $0
  102212:	6a 00                	push   $0x0
  pushl $72
  102214:	6a 48                	push   $0x48
  jmp __alltraps
  102216:	e9 ef 07 00 00       	jmp    102a0a <__alltraps>

0010221b <vector73>:
.globl vector73
vector73:
  pushl $0
  10221b:	6a 00                	push   $0x0
  pushl $73
  10221d:	6a 49                	push   $0x49
  jmp __alltraps
  10221f:	e9 e6 07 00 00       	jmp    102a0a <__alltraps>

00102224 <vector74>:
.globl vector74
vector74:
  pushl $0
  102224:	6a 00                	push   $0x0
  pushl $74
  102226:	6a 4a                	push   $0x4a
  jmp __alltraps
  102228:	e9 dd 07 00 00       	jmp    102a0a <__alltraps>

0010222d <vector75>:
.globl vector75
vector75:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $75
  10222f:	6a 4b                	push   $0x4b
  jmp __alltraps
  102231:	e9 d4 07 00 00       	jmp    102a0a <__alltraps>

00102236 <vector76>:
.globl vector76
vector76:
  pushl $0
  102236:	6a 00                	push   $0x0
  pushl $76
  102238:	6a 4c                	push   $0x4c
  jmp __alltraps
  10223a:	e9 cb 07 00 00       	jmp    102a0a <__alltraps>

0010223f <vector77>:
.globl vector77
vector77:
  pushl $0
  10223f:	6a 00                	push   $0x0
  pushl $77
  102241:	6a 4d                	push   $0x4d
  jmp __alltraps
  102243:	e9 c2 07 00 00       	jmp    102a0a <__alltraps>

00102248 <vector78>:
.globl vector78
vector78:
  pushl $0
  102248:	6a 00                	push   $0x0
  pushl $78
  10224a:	6a 4e                	push   $0x4e
  jmp __alltraps
  10224c:	e9 b9 07 00 00       	jmp    102a0a <__alltraps>

00102251 <vector79>:
.globl vector79
vector79:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $79
  102253:	6a 4f                	push   $0x4f
  jmp __alltraps
  102255:	e9 b0 07 00 00       	jmp    102a0a <__alltraps>

0010225a <vector80>:
.globl vector80
vector80:
  pushl $0
  10225a:	6a 00                	push   $0x0
  pushl $80
  10225c:	6a 50                	push   $0x50
  jmp __alltraps
  10225e:	e9 a7 07 00 00       	jmp    102a0a <__alltraps>

00102263 <vector81>:
.globl vector81
vector81:
  pushl $0
  102263:	6a 00                	push   $0x0
  pushl $81
  102265:	6a 51                	push   $0x51
  jmp __alltraps
  102267:	e9 9e 07 00 00       	jmp    102a0a <__alltraps>

0010226c <vector82>:
.globl vector82
vector82:
  pushl $0
  10226c:	6a 00                	push   $0x0
  pushl $82
  10226e:	6a 52                	push   $0x52
  jmp __alltraps
  102270:	e9 95 07 00 00       	jmp    102a0a <__alltraps>

00102275 <vector83>:
.globl vector83
vector83:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $83
  102277:	6a 53                	push   $0x53
  jmp __alltraps
  102279:	e9 8c 07 00 00       	jmp    102a0a <__alltraps>

0010227e <vector84>:
.globl vector84
vector84:
  pushl $0
  10227e:	6a 00                	push   $0x0
  pushl $84
  102280:	6a 54                	push   $0x54
  jmp __alltraps
  102282:	e9 83 07 00 00       	jmp    102a0a <__alltraps>

00102287 <vector85>:
.globl vector85
vector85:
  pushl $0
  102287:	6a 00                	push   $0x0
  pushl $85
  102289:	6a 55                	push   $0x55
  jmp __alltraps
  10228b:	e9 7a 07 00 00       	jmp    102a0a <__alltraps>

00102290 <vector86>:
.globl vector86
vector86:
  pushl $0
  102290:	6a 00                	push   $0x0
  pushl $86
  102292:	6a 56                	push   $0x56
  jmp __alltraps
  102294:	e9 71 07 00 00       	jmp    102a0a <__alltraps>

00102299 <vector87>:
.globl vector87
vector87:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $87
  10229b:	6a 57                	push   $0x57
  jmp __alltraps
  10229d:	e9 68 07 00 00       	jmp    102a0a <__alltraps>

001022a2 <vector88>:
.globl vector88
vector88:
  pushl $0
  1022a2:	6a 00                	push   $0x0
  pushl $88
  1022a4:	6a 58                	push   $0x58
  jmp __alltraps
  1022a6:	e9 5f 07 00 00       	jmp    102a0a <__alltraps>

001022ab <vector89>:
.globl vector89
vector89:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $89
  1022ad:	6a 59                	push   $0x59
  jmp __alltraps
  1022af:	e9 56 07 00 00       	jmp    102a0a <__alltraps>

001022b4 <vector90>:
.globl vector90
vector90:
  pushl $0
  1022b4:	6a 00                	push   $0x0
  pushl $90
  1022b6:	6a 5a                	push   $0x5a
  jmp __alltraps
  1022b8:	e9 4d 07 00 00       	jmp    102a0a <__alltraps>

001022bd <vector91>:
.globl vector91
vector91:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $91
  1022bf:	6a 5b                	push   $0x5b
  jmp __alltraps
  1022c1:	e9 44 07 00 00       	jmp    102a0a <__alltraps>

001022c6 <vector92>:
.globl vector92
vector92:
  pushl $0
  1022c6:	6a 00                	push   $0x0
  pushl $92
  1022c8:	6a 5c                	push   $0x5c
  jmp __alltraps
  1022ca:	e9 3b 07 00 00       	jmp    102a0a <__alltraps>

001022cf <vector93>:
.globl vector93
vector93:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $93
  1022d1:	6a 5d                	push   $0x5d
  jmp __alltraps
  1022d3:	e9 32 07 00 00       	jmp    102a0a <__alltraps>

001022d8 <vector94>:
.globl vector94
vector94:
  pushl $0
  1022d8:	6a 00                	push   $0x0
  pushl $94
  1022da:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022dc:	e9 29 07 00 00       	jmp    102a0a <__alltraps>

001022e1 <vector95>:
.globl vector95
vector95:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $95
  1022e3:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022e5:	e9 20 07 00 00       	jmp    102a0a <__alltraps>

001022ea <vector96>:
.globl vector96
vector96:
  pushl $0
  1022ea:	6a 00                	push   $0x0
  pushl $96
  1022ec:	6a 60                	push   $0x60
  jmp __alltraps
  1022ee:	e9 17 07 00 00       	jmp    102a0a <__alltraps>

001022f3 <vector97>:
.globl vector97
vector97:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $97
  1022f5:	6a 61                	push   $0x61
  jmp __alltraps
  1022f7:	e9 0e 07 00 00       	jmp    102a0a <__alltraps>

001022fc <vector98>:
.globl vector98
vector98:
  pushl $0
  1022fc:	6a 00                	push   $0x0
  pushl $98
  1022fe:	6a 62                	push   $0x62
  jmp __alltraps
  102300:	e9 05 07 00 00       	jmp    102a0a <__alltraps>

00102305 <vector99>:
.globl vector99
vector99:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $99
  102307:	6a 63                	push   $0x63
  jmp __alltraps
  102309:	e9 fc 06 00 00       	jmp    102a0a <__alltraps>

0010230e <vector100>:
.globl vector100
vector100:
  pushl $0
  10230e:	6a 00                	push   $0x0
  pushl $100
  102310:	6a 64                	push   $0x64
  jmp __alltraps
  102312:	e9 f3 06 00 00       	jmp    102a0a <__alltraps>

00102317 <vector101>:
.globl vector101
vector101:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $101
  102319:	6a 65                	push   $0x65
  jmp __alltraps
  10231b:	e9 ea 06 00 00       	jmp    102a0a <__alltraps>

00102320 <vector102>:
.globl vector102
vector102:
  pushl $0
  102320:	6a 00                	push   $0x0
  pushl $102
  102322:	6a 66                	push   $0x66
  jmp __alltraps
  102324:	e9 e1 06 00 00       	jmp    102a0a <__alltraps>

00102329 <vector103>:
.globl vector103
vector103:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $103
  10232b:	6a 67                	push   $0x67
  jmp __alltraps
  10232d:	e9 d8 06 00 00       	jmp    102a0a <__alltraps>

00102332 <vector104>:
.globl vector104
vector104:
  pushl $0
  102332:	6a 00                	push   $0x0
  pushl $104
  102334:	6a 68                	push   $0x68
  jmp __alltraps
  102336:	e9 cf 06 00 00       	jmp    102a0a <__alltraps>

0010233b <vector105>:
.globl vector105
vector105:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $105
  10233d:	6a 69                	push   $0x69
  jmp __alltraps
  10233f:	e9 c6 06 00 00       	jmp    102a0a <__alltraps>

00102344 <vector106>:
.globl vector106
vector106:
  pushl $0
  102344:	6a 00                	push   $0x0
  pushl $106
  102346:	6a 6a                	push   $0x6a
  jmp __alltraps
  102348:	e9 bd 06 00 00       	jmp    102a0a <__alltraps>

0010234d <vector107>:
.globl vector107
vector107:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $107
  10234f:	6a 6b                	push   $0x6b
  jmp __alltraps
  102351:	e9 b4 06 00 00       	jmp    102a0a <__alltraps>

00102356 <vector108>:
.globl vector108
vector108:
  pushl $0
  102356:	6a 00                	push   $0x0
  pushl $108
  102358:	6a 6c                	push   $0x6c
  jmp __alltraps
  10235a:	e9 ab 06 00 00       	jmp    102a0a <__alltraps>

0010235f <vector109>:
.globl vector109
vector109:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $109
  102361:	6a 6d                	push   $0x6d
  jmp __alltraps
  102363:	e9 a2 06 00 00       	jmp    102a0a <__alltraps>

00102368 <vector110>:
.globl vector110
vector110:
  pushl $0
  102368:	6a 00                	push   $0x0
  pushl $110
  10236a:	6a 6e                	push   $0x6e
  jmp __alltraps
  10236c:	e9 99 06 00 00       	jmp    102a0a <__alltraps>

00102371 <vector111>:
.globl vector111
vector111:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $111
  102373:	6a 6f                	push   $0x6f
  jmp __alltraps
  102375:	e9 90 06 00 00       	jmp    102a0a <__alltraps>

0010237a <vector112>:
.globl vector112
vector112:
  pushl $0
  10237a:	6a 00                	push   $0x0
  pushl $112
  10237c:	6a 70                	push   $0x70
  jmp __alltraps
  10237e:	e9 87 06 00 00       	jmp    102a0a <__alltraps>

00102383 <vector113>:
.globl vector113
vector113:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $113
  102385:	6a 71                	push   $0x71
  jmp __alltraps
  102387:	e9 7e 06 00 00       	jmp    102a0a <__alltraps>

0010238c <vector114>:
.globl vector114
vector114:
  pushl $0
  10238c:	6a 00                	push   $0x0
  pushl $114
  10238e:	6a 72                	push   $0x72
  jmp __alltraps
  102390:	e9 75 06 00 00       	jmp    102a0a <__alltraps>

00102395 <vector115>:
.globl vector115
vector115:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $115
  102397:	6a 73                	push   $0x73
  jmp __alltraps
  102399:	e9 6c 06 00 00       	jmp    102a0a <__alltraps>

0010239e <vector116>:
.globl vector116
vector116:
  pushl $0
  10239e:	6a 00                	push   $0x0
  pushl $116
  1023a0:	6a 74                	push   $0x74
  jmp __alltraps
  1023a2:	e9 63 06 00 00       	jmp    102a0a <__alltraps>

001023a7 <vector117>:
.globl vector117
vector117:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $117
  1023a9:	6a 75                	push   $0x75
  jmp __alltraps
  1023ab:	e9 5a 06 00 00       	jmp    102a0a <__alltraps>

001023b0 <vector118>:
.globl vector118
vector118:
  pushl $0
  1023b0:	6a 00                	push   $0x0
  pushl $118
  1023b2:	6a 76                	push   $0x76
  jmp __alltraps
  1023b4:	e9 51 06 00 00       	jmp    102a0a <__alltraps>

001023b9 <vector119>:
.globl vector119
vector119:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $119
  1023bb:	6a 77                	push   $0x77
  jmp __alltraps
  1023bd:	e9 48 06 00 00       	jmp    102a0a <__alltraps>

001023c2 <vector120>:
.globl vector120
vector120:
  pushl $0
  1023c2:	6a 00                	push   $0x0
  pushl $120
  1023c4:	6a 78                	push   $0x78
  jmp __alltraps
  1023c6:	e9 3f 06 00 00       	jmp    102a0a <__alltraps>

001023cb <vector121>:
.globl vector121
vector121:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $121
  1023cd:	6a 79                	push   $0x79
  jmp __alltraps
  1023cf:	e9 36 06 00 00       	jmp    102a0a <__alltraps>

001023d4 <vector122>:
.globl vector122
vector122:
  pushl $0
  1023d4:	6a 00                	push   $0x0
  pushl $122
  1023d6:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023d8:	e9 2d 06 00 00       	jmp    102a0a <__alltraps>

001023dd <vector123>:
.globl vector123
vector123:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $123
  1023df:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023e1:	e9 24 06 00 00       	jmp    102a0a <__alltraps>

001023e6 <vector124>:
.globl vector124
vector124:
  pushl $0
  1023e6:	6a 00                	push   $0x0
  pushl $124
  1023e8:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023ea:	e9 1b 06 00 00       	jmp    102a0a <__alltraps>

001023ef <vector125>:
.globl vector125
vector125:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $125
  1023f1:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023f3:	e9 12 06 00 00       	jmp    102a0a <__alltraps>

001023f8 <vector126>:
.globl vector126
vector126:
  pushl $0
  1023f8:	6a 00                	push   $0x0
  pushl $126
  1023fa:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023fc:	e9 09 06 00 00       	jmp    102a0a <__alltraps>

00102401 <vector127>:
.globl vector127
vector127:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $127
  102403:	6a 7f                	push   $0x7f
  jmp __alltraps
  102405:	e9 00 06 00 00       	jmp    102a0a <__alltraps>

0010240a <vector128>:
.globl vector128
vector128:
  pushl $0
  10240a:	6a 00                	push   $0x0
  pushl $128
  10240c:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102411:	e9 f4 05 00 00       	jmp    102a0a <__alltraps>

00102416 <vector129>:
.globl vector129
vector129:
  pushl $0
  102416:	6a 00                	push   $0x0
  pushl $129
  102418:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10241d:	e9 e8 05 00 00       	jmp    102a0a <__alltraps>

00102422 <vector130>:
.globl vector130
vector130:
  pushl $0
  102422:	6a 00                	push   $0x0
  pushl $130
  102424:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102429:	e9 dc 05 00 00       	jmp    102a0a <__alltraps>

0010242e <vector131>:
.globl vector131
vector131:
  pushl $0
  10242e:	6a 00                	push   $0x0
  pushl $131
  102430:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102435:	e9 d0 05 00 00       	jmp    102a0a <__alltraps>

0010243a <vector132>:
.globl vector132
vector132:
  pushl $0
  10243a:	6a 00                	push   $0x0
  pushl $132
  10243c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102441:	e9 c4 05 00 00       	jmp    102a0a <__alltraps>

00102446 <vector133>:
.globl vector133
vector133:
  pushl $0
  102446:	6a 00                	push   $0x0
  pushl $133
  102448:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10244d:	e9 b8 05 00 00       	jmp    102a0a <__alltraps>

00102452 <vector134>:
.globl vector134
vector134:
  pushl $0
  102452:	6a 00                	push   $0x0
  pushl $134
  102454:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102459:	e9 ac 05 00 00       	jmp    102a0a <__alltraps>

0010245e <vector135>:
.globl vector135
vector135:
  pushl $0
  10245e:	6a 00                	push   $0x0
  pushl $135
  102460:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102465:	e9 a0 05 00 00       	jmp    102a0a <__alltraps>

0010246a <vector136>:
.globl vector136
vector136:
  pushl $0
  10246a:	6a 00                	push   $0x0
  pushl $136
  10246c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102471:	e9 94 05 00 00       	jmp    102a0a <__alltraps>

00102476 <vector137>:
.globl vector137
vector137:
  pushl $0
  102476:	6a 00                	push   $0x0
  pushl $137
  102478:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10247d:	e9 88 05 00 00       	jmp    102a0a <__alltraps>

00102482 <vector138>:
.globl vector138
vector138:
  pushl $0
  102482:	6a 00                	push   $0x0
  pushl $138
  102484:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102489:	e9 7c 05 00 00       	jmp    102a0a <__alltraps>

0010248e <vector139>:
.globl vector139
vector139:
  pushl $0
  10248e:	6a 00                	push   $0x0
  pushl $139
  102490:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102495:	e9 70 05 00 00       	jmp    102a0a <__alltraps>

0010249a <vector140>:
.globl vector140
vector140:
  pushl $0
  10249a:	6a 00                	push   $0x0
  pushl $140
  10249c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1024a1:	e9 64 05 00 00       	jmp    102a0a <__alltraps>

001024a6 <vector141>:
.globl vector141
vector141:
  pushl $0
  1024a6:	6a 00                	push   $0x0
  pushl $141
  1024a8:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1024ad:	e9 58 05 00 00       	jmp    102a0a <__alltraps>

001024b2 <vector142>:
.globl vector142
vector142:
  pushl $0
  1024b2:	6a 00                	push   $0x0
  pushl $142
  1024b4:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1024b9:	e9 4c 05 00 00       	jmp    102a0a <__alltraps>

001024be <vector143>:
.globl vector143
vector143:
  pushl $0
  1024be:	6a 00                	push   $0x0
  pushl $143
  1024c0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1024c5:	e9 40 05 00 00       	jmp    102a0a <__alltraps>

001024ca <vector144>:
.globl vector144
vector144:
  pushl $0
  1024ca:	6a 00                	push   $0x0
  pushl $144
  1024cc:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1024d1:	e9 34 05 00 00       	jmp    102a0a <__alltraps>

001024d6 <vector145>:
.globl vector145
vector145:
  pushl $0
  1024d6:	6a 00                	push   $0x0
  pushl $145
  1024d8:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024dd:	e9 28 05 00 00       	jmp    102a0a <__alltraps>

001024e2 <vector146>:
.globl vector146
vector146:
  pushl $0
  1024e2:	6a 00                	push   $0x0
  pushl $146
  1024e4:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024e9:	e9 1c 05 00 00       	jmp    102a0a <__alltraps>

001024ee <vector147>:
.globl vector147
vector147:
  pushl $0
  1024ee:	6a 00                	push   $0x0
  pushl $147
  1024f0:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024f5:	e9 10 05 00 00       	jmp    102a0a <__alltraps>

001024fa <vector148>:
.globl vector148
vector148:
  pushl $0
  1024fa:	6a 00                	push   $0x0
  pushl $148
  1024fc:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102501:	e9 04 05 00 00       	jmp    102a0a <__alltraps>

00102506 <vector149>:
.globl vector149
vector149:
  pushl $0
  102506:	6a 00                	push   $0x0
  pushl $149
  102508:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10250d:	e9 f8 04 00 00       	jmp    102a0a <__alltraps>

00102512 <vector150>:
.globl vector150
vector150:
  pushl $0
  102512:	6a 00                	push   $0x0
  pushl $150
  102514:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102519:	e9 ec 04 00 00       	jmp    102a0a <__alltraps>

0010251e <vector151>:
.globl vector151
vector151:
  pushl $0
  10251e:	6a 00                	push   $0x0
  pushl $151
  102520:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102525:	e9 e0 04 00 00       	jmp    102a0a <__alltraps>

0010252a <vector152>:
.globl vector152
vector152:
  pushl $0
  10252a:	6a 00                	push   $0x0
  pushl $152
  10252c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102531:	e9 d4 04 00 00       	jmp    102a0a <__alltraps>

00102536 <vector153>:
.globl vector153
vector153:
  pushl $0
  102536:	6a 00                	push   $0x0
  pushl $153
  102538:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10253d:	e9 c8 04 00 00       	jmp    102a0a <__alltraps>

00102542 <vector154>:
.globl vector154
vector154:
  pushl $0
  102542:	6a 00                	push   $0x0
  pushl $154
  102544:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102549:	e9 bc 04 00 00       	jmp    102a0a <__alltraps>

0010254e <vector155>:
.globl vector155
vector155:
  pushl $0
  10254e:	6a 00                	push   $0x0
  pushl $155
  102550:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102555:	e9 b0 04 00 00       	jmp    102a0a <__alltraps>

0010255a <vector156>:
.globl vector156
vector156:
  pushl $0
  10255a:	6a 00                	push   $0x0
  pushl $156
  10255c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102561:	e9 a4 04 00 00       	jmp    102a0a <__alltraps>

00102566 <vector157>:
.globl vector157
vector157:
  pushl $0
  102566:	6a 00                	push   $0x0
  pushl $157
  102568:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10256d:	e9 98 04 00 00       	jmp    102a0a <__alltraps>

00102572 <vector158>:
.globl vector158
vector158:
  pushl $0
  102572:	6a 00                	push   $0x0
  pushl $158
  102574:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102579:	e9 8c 04 00 00       	jmp    102a0a <__alltraps>

0010257e <vector159>:
.globl vector159
vector159:
  pushl $0
  10257e:	6a 00                	push   $0x0
  pushl $159
  102580:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102585:	e9 80 04 00 00       	jmp    102a0a <__alltraps>

0010258a <vector160>:
.globl vector160
vector160:
  pushl $0
  10258a:	6a 00                	push   $0x0
  pushl $160
  10258c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102591:	e9 74 04 00 00       	jmp    102a0a <__alltraps>

00102596 <vector161>:
.globl vector161
vector161:
  pushl $0
  102596:	6a 00                	push   $0x0
  pushl $161
  102598:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10259d:	e9 68 04 00 00       	jmp    102a0a <__alltraps>

001025a2 <vector162>:
.globl vector162
vector162:
  pushl $0
  1025a2:	6a 00                	push   $0x0
  pushl $162
  1025a4:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1025a9:	e9 5c 04 00 00       	jmp    102a0a <__alltraps>

001025ae <vector163>:
.globl vector163
vector163:
  pushl $0
  1025ae:	6a 00                	push   $0x0
  pushl $163
  1025b0:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1025b5:	e9 50 04 00 00       	jmp    102a0a <__alltraps>

001025ba <vector164>:
.globl vector164
vector164:
  pushl $0
  1025ba:	6a 00                	push   $0x0
  pushl $164
  1025bc:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1025c1:	e9 44 04 00 00       	jmp    102a0a <__alltraps>

001025c6 <vector165>:
.globl vector165
vector165:
  pushl $0
  1025c6:	6a 00                	push   $0x0
  pushl $165
  1025c8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1025cd:	e9 38 04 00 00       	jmp    102a0a <__alltraps>

001025d2 <vector166>:
.globl vector166
vector166:
  pushl $0
  1025d2:	6a 00                	push   $0x0
  pushl $166
  1025d4:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025d9:	e9 2c 04 00 00       	jmp    102a0a <__alltraps>

001025de <vector167>:
.globl vector167
vector167:
  pushl $0
  1025de:	6a 00                	push   $0x0
  pushl $167
  1025e0:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025e5:	e9 20 04 00 00       	jmp    102a0a <__alltraps>

001025ea <vector168>:
.globl vector168
vector168:
  pushl $0
  1025ea:	6a 00                	push   $0x0
  pushl $168
  1025ec:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025f1:	e9 14 04 00 00       	jmp    102a0a <__alltraps>

001025f6 <vector169>:
.globl vector169
vector169:
  pushl $0
  1025f6:	6a 00                	push   $0x0
  pushl $169
  1025f8:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025fd:	e9 08 04 00 00       	jmp    102a0a <__alltraps>

00102602 <vector170>:
.globl vector170
vector170:
  pushl $0
  102602:	6a 00                	push   $0x0
  pushl $170
  102604:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102609:	e9 fc 03 00 00       	jmp    102a0a <__alltraps>

0010260e <vector171>:
.globl vector171
vector171:
  pushl $0
  10260e:	6a 00                	push   $0x0
  pushl $171
  102610:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102615:	e9 f0 03 00 00       	jmp    102a0a <__alltraps>

0010261a <vector172>:
.globl vector172
vector172:
  pushl $0
  10261a:	6a 00                	push   $0x0
  pushl $172
  10261c:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102621:	e9 e4 03 00 00       	jmp    102a0a <__alltraps>

00102626 <vector173>:
.globl vector173
vector173:
  pushl $0
  102626:	6a 00                	push   $0x0
  pushl $173
  102628:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10262d:	e9 d8 03 00 00       	jmp    102a0a <__alltraps>

00102632 <vector174>:
.globl vector174
vector174:
  pushl $0
  102632:	6a 00                	push   $0x0
  pushl $174
  102634:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102639:	e9 cc 03 00 00       	jmp    102a0a <__alltraps>

0010263e <vector175>:
.globl vector175
vector175:
  pushl $0
  10263e:	6a 00                	push   $0x0
  pushl $175
  102640:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102645:	e9 c0 03 00 00       	jmp    102a0a <__alltraps>

0010264a <vector176>:
.globl vector176
vector176:
  pushl $0
  10264a:	6a 00                	push   $0x0
  pushl $176
  10264c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102651:	e9 b4 03 00 00       	jmp    102a0a <__alltraps>

00102656 <vector177>:
.globl vector177
vector177:
  pushl $0
  102656:	6a 00                	push   $0x0
  pushl $177
  102658:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10265d:	e9 a8 03 00 00       	jmp    102a0a <__alltraps>

00102662 <vector178>:
.globl vector178
vector178:
  pushl $0
  102662:	6a 00                	push   $0x0
  pushl $178
  102664:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102669:	e9 9c 03 00 00       	jmp    102a0a <__alltraps>

0010266e <vector179>:
.globl vector179
vector179:
  pushl $0
  10266e:	6a 00                	push   $0x0
  pushl $179
  102670:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102675:	e9 90 03 00 00       	jmp    102a0a <__alltraps>

0010267a <vector180>:
.globl vector180
vector180:
  pushl $0
  10267a:	6a 00                	push   $0x0
  pushl $180
  10267c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102681:	e9 84 03 00 00       	jmp    102a0a <__alltraps>

00102686 <vector181>:
.globl vector181
vector181:
  pushl $0
  102686:	6a 00                	push   $0x0
  pushl $181
  102688:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10268d:	e9 78 03 00 00       	jmp    102a0a <__alltraps>

00102692 <vector182>:
.globl vector182
vector182:
  pushl $0
  102692:	6a 00                	push   $0x0
  pushl $182
  102694:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102699:	e9 6c 03 00 00       	jmp    102a0a <__alltraps>

0010269e <vector183>:
.globl vector183
vector183:
  pushl $0
  10269e:	6a 00                	push   $0x0
  pushl $183
  1026a0:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1026a5:	e9 60 03 00 00       	jmp    102a0a <__alltraps>

001026aa <vector184>:
.globl vector184
vector184:
  pushl $0
  1026aa:	6a 00                	push   $0x0
  pushl $184
  1026ac:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1026b1:	e9 54 03 00 00       	jmp    102a0a <__alltraps>

001026b6 <vector185>:
.globl vector185
vector185:
  pushl $0
  1026b6:	6a 00                	push   $0x0
  pushl $185
  1026b8:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1026bd:	e9 48 03 00 00       	jmp    102a0a <__alltraps>

001026c2 <vector186>:
.globl vector186
vector186:
  pushl $0
  1026c2:	6a 00                	push   $0x0
  pushl $186
  1026c4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1026c9:	e9 3c 03 00 00       	jmp    102a0a <__alltraps>

001026ce <vector187>:
.globl vector187
vector187:
  pushl $0
  1026ce:	6a 00                	push   $0x0
  pushl $187
  1026d0:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1026d5:	e9 30 03 00 00       	jmp    102a0a <__alltraps>

001026da <vector188>:
.globl vector188
vector188:
  pushl $0
  1026da:	6a 00                	push   $0x0
  pushl $188
  1026dc:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026e1:	e9 24 03 00 00       	jmp    102a0a <__alltraps>

001026e6 <vector189>:
.globl vector189
vector189:
  pushl $0
  1026e6:	6a 00                	push   $0x0
  pushl $189
  1026e8:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026ed:	e9 18 03 00 00       	jmp    102a0a <__alltraps>

001026f2 <vector190>:
.globl vector190
vector190:
  pushl $0
  1026f2:	6a 00                	push   $0x0
  pushl $190
  1026f4:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026f9:	e9 0c 03 00 00       	jmp    102a0a <__alltraps>

001026fe <vector191>:
.globl vector191
vector191:
  pushl $0
  1026fe:	6a 00                	push   $0x0
  pushl $191
  102700:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102705:	e9 00 03 00 00       	jmp    102a0a <__alltraps>

0010270a <vector192>:
.globl vector192
vector192:
  pushl $0
  10270a:	6a 00                	push   $0x0
  pushl $192
  10270c:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102711:	e9 f4 02 00 00       	jmp    102a0a <__alltraps>

00102716 <vector193>:
.globl vector193
vector193:
  pushl $0
  102716:	6a 00                	push   $0x0
  pushl $193
  102718:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10271d:	e9 e8 02 00 00       	jmp    102a0a <__alltraps>

00102722 <vector194>:
.globl vector194
vector194:
  pushl $0
  102722:	6a 00                	push   $0x0
  pushl $194
  102724:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102729:	e9 dc 02 00 00       	jmp    102a0a <__alltraps>

0010272e <vector195>:
.globl vector195
vector195:
  pushl $0
  10272e:	6a 00                	push   $0x0
  pushl $195
  102730:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102735:	e9 d0 02 00 00       	jmp    102a0a <__alltraps>

0010273a <vector196>:
.globl vector196
vector196:
  pushl $0
  10273a:	6a 00                	push   $0x0
  pushl $196
  10273c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102741:	e9 c4 02 00 00       	jmp    102a0a <__alltraps>

00102746 <vector197>:
.globl vector197
vector197:
  pushl $0
  102746:	6a 00                	push   $0x0
  pushl $197
  102748:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10274d:	e9 b8 02 00 00       	jmp    102a0a <__alltraps>

00102752 <vector198>:
.globl vector198
vector198:
  pushl $0
  102752:	6a 00                	push   $0x0
  pushl $198
  102754:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102759:	e9 ac 02 00 00       	jmp    102a0a <__alltraps>

0010275e <vector199>:
.globl vector199
vector199:
  pushl $0
  10275e:	6a 00                	push   $0x0
  pushl $199
  102760:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102765:	e9 a0 02 00 00       	jmp    102a0a <__alltraps>

0010276a <vector200>:
.globl vector200
vector200:
  pushl $0
  10276a:	6a 00                	push   $0x0
  pushl $200
  10276c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102771:	e9 94 02 00 00       	jmp    102a0a <__alltraps>

00102776 <vector201>:
.globl vector201
vector201:
  pushl $0
  102776:	6a 00                	push   $0x0
  pushl $201
  102778:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10277d:	e9 88 02 00 00       	jmp    102a0a <__alltraps>

00102782 <vector202>:
.globl vector202
vector202:
  pushl $0
  102782:	6a 00                	push   $0x0
  pushl $202
  102784:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102789:	e9 7c 02 00 00       	jmp    102a0a <__alltraps>

0010278e <vector203>:
.globl vector203
vector203:
  pushl $0
  10278e:	6a 00                	push   $0x0
  pushl $203
  102790:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102795:	e9 70 02 00 00       	jmp    102a0a <__alltraps>

0010279a <vector204>:
.globl vector204
vector204:
  pushl $0
  10279a:	6a 00                	push   $0x0
  pushl $204
  10279c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1027a1:	e9 64 02 00 00       	jmp    102a0a <__alltraps>

001027a6 <vector205>:
.globl vector205
vector205:
  pushl $0
  1027a6:	6a 00                	push   $0x0
  pushl $205
  1027a8:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1027ad:	e9 58 02 00 00       	jmp    102a0a <__alltraps>

001027b2 <vector206>:
.globl vector206
vector206:
  pushl $0
  1027b2:	6a 00                	push   $0x0
  pushl $206
  1027b4:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1027b9:	e9 4c 02 00 00       	jmp    102a0a <__alltraps>

001027be <vector207>:
.globl vector207
vector207:
  pushl $0
  1027be:	6a 00                	push   $0x0
  pushl $207
  1027c0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1027c5:	e9 40 02 00 00       	jmp    102a0a <__alltraps>

001027ca <vector208>:
.globl vector208
vector208:
  pushl $0
  1027ca:	6a 00                	push   $0x0
  pushl $208
  1027cc:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1027d1:	e9 34 02 00 00       	jmp    102a0a <__alltraps>

001027d6 <vector209>:
.globl vector209
vector209:
  pushl $0
  1027d6:	6a 00                	push   $0x0
  pushl $209
  1027d8:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027dd:	e9 28 02 00 00       	jmp    102a0a <__alltraps>

001027e2 <vector210>:
.globl vector210
vector210:
  pushl $0
  1027e2:	6a 00                	push   $0x0
  pushl $210
  1027e4:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027e9:	e9 1c 02 00 00       	jmp    102a0a <__alltraps>

001027ee <vector211>:
.globl vector211
vector211:
  pushl $0
  1027ee:	6a 00                	push   $0x0
  pushl $211
  1027f0:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027f5:	e9 10 02 00 00       	jmp    102a0a <__alltraps>

001027fa <vector212>:
.globl vector212
vector212:
  pushl $0
  1027fa:	6a 00                	push   $0x0
  pushl $212
  1027fc:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102801:	e9 04 02 00 00       	jmp    102a0a <__alltraps>

00102806 <vector213>:
.globl vector213
vector213:
  pushl $0
  102806:	6a 00                	push   $0x0
  pushl $213
  102808:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10280d:	e9 f8 01 00 00       	jmp    102a0a <__alltraps>

00102812 <vector214>:
.globl vector214
vector214:
  pushl $0
  102812:	6a 00                	push   $0x0
  pushl $214
  102814:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102819:	e9 ec 01 00 00       	jmp    102a0a <__alltraps>

0010281e <vector215>:
.globl vector215
vector215:
  pushl $0
  10281e:	6a 00                	push   $0x0
  pushl $215
  102820:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102825:	e9 e0 01 00 00       	jmp    102a0a <__alltraps>

0010282a <vector216>:
.globl vector216
vector216:
  pushl $0
  10282a:	6a 00                	push   $0x0
  pushl $216
  10282c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102831:	e9 d4 01 00 00       	jmp    102a0a <__alltraps>

00102836 <vector217>:
.globl vector217
vector217:
  pushl $0
  102836:	6a 00                	push   $0x0
  pushl $217
  102838:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10283d:	e9 c8 01 00 00       	jmp    102a0a <__alltraps>

00102842 <vector218>:
.globl vector218
vector218:
  pushl $0
  102842:	6a 00                	push   $0x0
  pushl $218
  102844:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102849:	e9 bc 01 00 00       	jmp    102a0a <__alltraps>

0010284e <vector219>:
.globl vector219
vector219:
  pushl $0
  10284e:	6a 00                	push   $0x0
  pushl $219
  102850:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102855:	e9 b0 01 00 00       	jmp    102a0a <__alltraps>

0010285a <vector220>:
.globl vector220
vector220:
  pushl $0
  10285a:	6a 00                	push   $0x0
  pushl $220
  10285c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102861:	e9 a4 01 00 00       	jmp    102a0a <__alltraps>

00102866 <vector221>:
.globl vector221
vector221:
  pushl $0
  102866:	6a 00                	push   $0x0
  pushl $221
  102868:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10286d:	e9 98 01 00 00       	jmp    102a0a <__alltraps>

00102872 <vector222>:
.globl vector222
vector222:
  pushl $0
  102872:	6a 00                	push   $0x0
  pushl $222
  102874:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102879:	e9 8c 01 00 00       	jmp    102a0a <__alltraps>

0010287e <vector223>:
.globl vector223
vector223:
  pushl $0
  10287e:	6a 00                	push   $0x0
  pushl $223
  102880:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102885:	e9 80 01 00 00       	jmp    102a0a <__alltraps>

0010288a <vector224>:
.globl vector224
vector224:
  pushl $0
  10288a:	6a 00                	push   $0x0
  pushl $224
  10288c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102891:	e9 74 01 00 00       	jmp    102a0a <__alltraps>

00102896 <vector225>:
.globl vector225
vector225:
  pushl $0
  102896:	6a 00                	push   $0x0
  pushl $225
  102898:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10289d:	e9 68 01 00 00       	jmp    102a0a <__alltraps>

001028a2 <vector226>:
.globl vector226
vector226:
  pushl $0
  1028a2:	6a 00                	push   $0x0
  pushl $226
  1028a4:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1028a9:	e9 5c 01 00 00       	jmp    102a0a <__alltraps>

001028ae <vector227>:
.globl vector227
vector227:
  pushl $0
  1028ae:	6a 00                	push   $0x0
  pushl $227
  1028b0:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1028b5:	e9 50 01 00 00       	jmp    102a0a <__alltraps>

001028ba <vector228>:
.globl vector228
vector228:
  pushl $0
  1028ba:	6a 00                	push   $0x0
  pushl $228
  1028bc:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1028c1:	e9 44 01 00 00       	jmp    102a0a <__alltraps>

001028c6 <vector229>:
.globl vector229
vector229:
  pushl $0
  1028c6:	6a 00                	push   $0x0
  pushl $229
  1028c8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1028cd:	e9 38 01 00 00       	jmp    102a0a <__alltraps>

001028d2 <vector230>:
.globl vector230
vector230:
  pushl $0
  1028d2:	6a 00                	push   $0x0
  pushl $230
  1028d4:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028d9:	e9 2c 01 00 00       	jmp    102a0a <__alltraps>

001028de <vector231>:
.globl vector231
vector231:
  pushl $0
  1028de:	6a 00                	push   $0x0
  pushl $231
  1028e0:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028e5:	e9 20 01 00 00       	jmp    102a0a <__alltraps>

001028ea <vector232>:
.globl vector232
vector232:
  pushl $0
  1028ea:	6a 00                	push   $0x0
  pushl $232
  1028ec:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028f1:	e9 14 01 00 00       	jmp    102a0a <__alltraps>

001028f6 <vector233>:
.globl vector233
vector233:
  pushl $0
  1028f6:	6a 00                	push   $0x0
  pushl $233
  1028f8:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028fd:	e9 08 01 00 00       	jmp    102a0a <__alltraps>

00102902 <vector234>:
.globl vector234
vector234:
  pushl $0
  102902:	6a 00                	push   $0x0
  pushl $234
  102904:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102909:	e9 fc 00 00 00       	jmp    102a0a <__alltraps>

0010290e <vector235>:
.globl vector235
vector235:
  pushl $0
  10290e:	6a 00                	push   $0x0
  pushl $235
  102910:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102915:	e9 f0 00 00 00       	jmp    102a0a <__alltraps>

0010291a <vector236>:
.globl vector236
vector236:
  pushl $0
  10291a:	6a 00                	push   $0x0
  pushl $236
  10291c:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102921:	e9 e4 00 00 00       	jmp    102a0a <__alltraps>

00102926 <vector237>:
.globl vector237
vector237:
  pushl $0
  102926:	6a 00                	push   $0x0
  pushl $237
  102928:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10292d:	e9 d8 00 00 00       	jmp    102a0a <__alltraps>

00102932 <vector238>:
.globl vector238
vector238:
  pushl $0
  102932:	6a 00                	push   $0x0
  pushl $238
  102934:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102939:	e9 cc 00 00 00       	jmp    102a0a <__alltraps>

0010293e <vector239>:
.globl vector239
vector239:
  pushl $0
  10293e:	6a 00                	push   $0x0
  pushl $239
  102940:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102945:	e9 c0 00 00 00       	jmp    102a0a <__alltraps>

0010294a <vector240>:
.globl vector240
vector240:
  pushl $0
  10294a:	6a 00                	push   $0x0
  pushl $240
  10294c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102951:	e9 b4 00 00 00       	jmp    102a0a <__alltraps>

00102956 <vector241>:
.globl vector241
vector241:
  pushl $0
  102956:	6a 00                	push   $0x0
  pushl $241
  102958:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10295d:	e9 a8 00 00 00       	jmp    102a0a <__alltraps>

00102962 <vector242>:
.globl vector242
vector242:
  pushl $0
  102962:	6a 00                	push   $0x0
  pushl $242
  102964:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102969:	e9 9c 00 00 00       	jmp    102a0a <__alltraps>

0010296e <vector243>:
.globl vector243
vector243:
  pushl $0
  10296e:	6a 00                	push   $0x0
  pushl $243
  102970:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102975:	e9 90 00 00 00       	jmp    102a0a <__alltraps>

0010297a <vector244>:
.globl vector244
vector244:
  pushl $0
  10297a:	6a 00                	push   $0x0
  pushl $244
  10297c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102981:	e9 84 00 00 00       	jmp    102a0a <__alltraps>

00102986 <vector245>:
.globl vector245
vector245:
  pushl $0
  102986:	6a 00                	push   $0x0
  pushl $245
  102988:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10298d:	e9 78 00 00 00       	jmp    102a0a <__alltraps>

00102992 <vector246>:
.globl vector246
vector246:
  pushl $0
  102992:	6a 00                	push   $0x0
  pushl $246
  102994:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102999:	e9 6c 00 00 00       	jmp    102a0a <__alltraps>

0010299e <vector247>:
.globl vector247
vector247:
  pushl $0
  10299e:	6a 00                	push   $0x0
  pushl $247
  1029a0:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1029a5:	e9 60 00 00 00       	jmp    102a0a <__alltraps>

001029aa <vector248>:
.globl vector248
vector248:
  pushl $0
  1029aa:	6a 00                	push   $0x0
  pushl $248
  1029ac:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1029b1:	e9 54 00 00 00       	jmp    102a0a <__alltraps>

001029b6 <vector249>:
.globl vector249
vector249:
  pushl $0
  1029b6:	6a 00                	push   $0x0
  pushl $249
  1029b8:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1029bd:	e9 48 00 00 00       	jmp    102a0a <__alltraps>

001029c2 <vector250>:
.globl vector250
vector250:
  pushl $0
  1029c2:	6a 00                	push   $0x0
  pushl $250
  1029c4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1029c9:	e9 3c 00 00 00       	jmp    102a0a <__alltraps>

001029ce <vector251>:
.globl vector251
vector251:
  pushl $0
  1029ce:	6a 00                	push   $0x0
  pushl $251
  1029d0:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1029d5:	e9 30 00 00 00       	jmp    102a0a <__alltraps>

001029da <vector252>:
.globl vector252
vector252:
  pushl $0
  1029da:	6a 00                	push   $0x0
  pushl $252
  1029dc:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029e1:	e9 24 00 00 00       	jmp    102a0a <__alltraps>

001029e6 <vector253>:
.globl vector253
vector253:
  pushl $0
  1029e6:	6a 00                	push   $0x0
  pushl $253
  1029e8:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029ed:	e9 18 00 00 00       	jmp    102a0a <__alltraps>

001029f2 <vector254>:
.globl vector254
vector254:
  pushl $0
  1029f2:	6a 00                	push   $0x0
  pushl $254
  1029f4:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029f9:	e9 0c 00 00 00       	jmp    102a0a <__alltraps>

001029fe <vector255>:
.globl vector255
vector255:
  pushl $0
  1029fe:	6a 00                	push   $0x0
  pushl $255
  102a00:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102a05:	e9 00 00 00 00       	jmp    102a0a <__alltraps>

00102a0a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102a0a:	1e                   	push   %ds
    pushl %es
  102a0b:	06                   	push   %es
    pushl %fs
  102a0c:	0f a0                	push   %fs
    pushl %gs
  102a0e:	0f a8                	push   %gs
    pushal
  102a10:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102a11:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102a16:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102a18:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102a1a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102a1b:	e8 64 f5 ff ff       	call   101f84 <trap>

    # pop the pushed stack pointer
    popl %esp
  102a20:	5c                   	pop    %esp

00102a21 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102a21:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102a22:	0f a9                	pop    %gs
    popl %fs
  102a24:	0f a1                	pop    %fs
    popl %es
  102a26:	07                   	pop    %es
    popl %ds
  102a27:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102a28:	83 c4 08             	add    $0x8,%esp
    iret
  102a2b:	cf                   	iret   

00102a2c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102a2c:	55                   	push   %ebp
  102a2d:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  102a32:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
  102a38:	29 d0                	sub    %edx,%eax
  102a3a:	c1 f8 02             	sar    $0x2,%eax
  102a3d:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102a43:	5d                   	pop    %ebp
  102a44:	c3                   	ret    

00102a45 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102a45:	55                   	push   %ebp
  102a46:	89 e5                	mov    %esp,%ebp
  102a48:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  102a4e:	89 04 24             	mov    %eax,(%esp)
  102a51:	e8 d6 ff ff ff       	call   102a2c <page2ppn>
  102a56:	c1 e0 0c             	shl    $0xc,%eax
}
  102a59:	c9                   	leave  
  102a5a:	c3                   	ret    

00102a5b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102a5b:	55                   	push   %ebp
  102a5c:	89 e5                	mov    %esp,%ebp
  102a5e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102a61:	8b 45 08             	mov    0x8(%ebp),%eax
  102a64:	c1 e8 0c             	shr    $0xc,%eax
  102a67:	89 c2                	mov    %eax,%edx
  102a69:	a1 80 be 11 00       	mov    0x11be80,%eax
  102a6e:	39 c2                	cmp    %eax,%edx
  102a70:	72 1c                	jb     102a8e <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102a72:	c7 44 24 08 30 68 10 	movl   $0x106830,0x8(%esp)
  102a79:	00 
  102a7a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  102a81:	00 
  102a82:	c7 04 24 4f 68 10 00 	movl   $0x10684f,(%esp)
  102a89:	e8 6b d9 ff ff       	call   1003f9 <__panic>
    }
    return &pages[PPN(pa)];
  102a8e:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
  102a94:	8b 45 08             	mov    0x8(%ebp),%eax
  102a97:	c1 e8 0c             	shr    $0xc,%eax
  102a9a:	89 c2                	mov    %eax,%edx
  102a9c:	89 d0                	mov    %edx,%eax
  102a9e:	c1 e0 02             	shl    $0x2,%eax
  102aa1:	01 d0                	add    %edx,%eax
  102aa3:	c1 e0 02             	shl    $0x2,%eax
  102aa6:	01 c8                	add    %ecx,%eax
}
  102aa8:	c9                   	leave  
  102aa9:	c3                   	ret    

00102aaa <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102aaa:	55                   	push   %ebp
  102aab:	89 e5                	mov    %esp,%ebp
  102aad:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ab3:	89 04 24             	mov    %eax,(%esp)
  102ab6:	e8 8a ff ff ff       	call   102a45 <page2pa>
  102abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ac1:	c1 e8 0c             	shr    $0xc,%eax
  102ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ac7:	a1 80 be 11 00       	mov    0x11be80,%eax
  102acc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102acf:	72 23                	jb     102af4 <page2kva+0x4a>
  102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ad4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ad8:	c7 44 24 08 60 68 10 	movl   $0x106860,0x8(%esp)
  102adf:	00 
  102ae0:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  102ae7:	00 
  102ae8:	c7 04 24 4f 68 10 00 	movl   $0x10684f,(%esp)
  102aef:	e8 05 d9 ff ff       	call   1003f9 <__panic>
  102af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102af7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102afc:	c9                   	leave  
  102afd:	c3                   	ret    

00102afe <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102afe:	55                   	push   %ebp
  102aff:	89 e5                	mov    %esp,%ebp
  102b01:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102b04:	8b 45 08             	mov    0x8(%ebp),%eax
  102b07:	83 e0 01             	and    $0x1,%eax
  102b0a:	85 c0                	test   %eax,%eax
  102b0c:	75 1c                	jne    102b2a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102b0e:	c7 44 24 08 84 68 10 	movl   $0x106884,0x8(%esp)
  102b15:	00 
  102b16:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  102b1d:	00 
  102b1e:	c7 04 24 4f 68 10 00 	movl   $0x10684f,(%esp)
  102b25:	e8 cf d8 ff ff       	call   1003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b32:	89 04 24             	mov    %eax,(%esp)
  102b35:	e8 21 ff ff ff       	call   102a5b <pa2page>
}
  102b3a:	c9                   	leave  
  102b3b:	c3                   	ret    

00102b3c <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102b3c:	55                   	push   %ebp
  102b3d:	89 e5                	mov    %esp,%ebp
  102b3f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102b42:	8b 45 08             	mov    0x8(%ebp),%eax
  102b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b4a:	89 04 24             	mov    %eax,(%esp)
  102b4d:	e8 09 ff ff ff       	call   102a5b <pa2page>
}
  102b52:	c9                   	leave  
  102b53:	c3                   	ret    

00102b54 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102b54:	55                   	push   %ebp
  102b55:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102b57:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5a:	8b 00                	mov    (%eax),%eax
}
  102b5c:	5d                   	pop    %ebp
  102b5d:	c3                   	ret    

00102b5e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102b5e:	55                   	push   %ebp
  102b5f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102b61:	8b 45 08             	mov    0x8(%ebp),%eax
  102b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b67:	89 10                	mov    %edx,(%eax)
}
  102b69:	90                   	nop
  102b6a:	5d                   	pop    %ebp
  102b6b:	c3                   	ret    

00102b6c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102b6c:	55                   	push   %ebp
  102b6d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b72:	8b 00                	mov    (%eax),%eax
  102b74:	8d 50 01             	lea    0x1(%eax),%edx
  102b77:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7a:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7f:	8b 00                	mov    (%eax),%eax
}
  102b81:	5d                   	pop    %ebp
  102b82:	c3                   	ret    

00102b83 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102b83:	55                   	push   %ebp
  102b84:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102b86:	8b 45 08             	mov    0x8(%ebp),%eax
  102b89:	8b 00                	mov    (%eax),%eax
  102b8b:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b91:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b93:	8b 45 08             	mov    0x8(%ebp),%eax
  102b96:	8b 00                	mov    (%eax),%eax
}
  102b98:	5d                   	pop    %ebp
  102b99:	c3                   	ret    

00102b9a <__intr_save>:
__intr_save(void) {     //TS自旋锁机制
  102b9a:	55                   	push   %ebp
  102b9b:	89 e5                	mov    %esp,%ebp
  102b9d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102ba0:	9c                   	pushf  
  102ba1:	58                   	pop    %eax
  102ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
  102ba8:	25 00 02 00 00       	and    $0x200,%eax
  102bad:	85 c0                	test   %eax,%eax
  102baf:	74 0c                	je     102bbd <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
  102bb1:	e8 fa ec ff ff       	call   1018b0 <intr_disable>
        return 1;
  102bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  102bbb:	eb 05                	jmp    102bc2 <__intr_save+0x28>
    return 0;       //否则表明中断标志位为0
  102bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102bc2:	c9                   	leave  
  102bc3:	c3                   	ret    

00102bc4 <__intr_restore>:
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
  102bc4:	55                   	push   %ebp
  102bc5:	89 e5                	mov    %esp,%ebp
  102bc7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102bca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102bce:	74 05                	je     102bd5 <__intr_restore+0x11>
        intr_enable();
  102bd0:	e8 d4 ec ff ff       	call   1018a9 <intr_enable>
}
  102bd5:	90                   	nop
  102bd6:	c9                   	leave  
  102bd7:	c3                   	ret    

00102bd8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102bd8:	55                   	push   %ebp
  102bd9:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bde:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102be1:	b8 23 00 00 00       	mov    $0x23,%eax
  102be6:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102be8:	b8 23 00 00 00       	mov    $0x23,%eax
  102bed:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102bef:	b8 10 00 00 00       	mov    $0x10,%eax
  102bf4:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102bf6:	b8 10 00 00 00       	mov    $0x10,%eax
  102bfb:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102bfd:	b8 10 00 00 00       	mov    $0x10,%eax
  102c02:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102c04:	ea 0b 2c 10 00 08 00 	ljmp   $0x8,$0x102c0b
}
  102c0b:	90                   	nop
  102c0c:	5d                   	pop    %ebp
  102c0d:	c3                   	ret    

00102c0e <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102c0e:	55                   	push   %ebp
  102c0f:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102c11:	8b 45 08             	mov    0x8(%ebp),%eax
  102c14:	a3 a4 be 11 00       	mov    %eax,0x11bea4
}
  102c19:	90                   	nop
  102c1a:	5d                   	pop    %ebp
  102c1b:	c3                   	ret    

00102c1c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102c1c:	55                   	push   %ebp
  102c1d:	89 e5                	mov    %esp,%ebp
  102c1f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102c22:	b8 00 80 11 00       	mov    $0x118000,%eax
  102c27:	89 04 24             	mov    %eax,(%esp)
  102c2a:	e8 df ff ff ff       	call   102c0e <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102c2f:	66 c7 05 a8 be 11 00 	movw   $0x10,0x11bea8
  102c36:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102c38:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  102c3f:	68 00 
  102c41:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102c46:	0f b7 c0             	movzwl %ax,%eax
  102c49:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  102c4f:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102c54:	c1 e8 10             	shr    $0x10,%eax
  102c57:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  102c5c:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c63:	24 f0                	and    $0xf0,%al
  102c65:	0c 09                	or     $0x9,%al
  102c67:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c6c:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c73:	24 ef                	and    $0xef,%al
  102c75:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c7a:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c81:	24 9f                	and    $0x9f,%al
  102c83:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c88:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102c8f:	0c 80                	or     $0x80,%al
  102c91:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102c96:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102c9d:	24 f0                	and    $0xf0,%al
  102c9f:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102ca4:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102cab:	24 ef                	and    $0xef,%al
  102cad:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102cb2:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102cb9:	24 df                	and    $0xdf,%al
  102cbb:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102cc0:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102cc7:	0c 40                	or     $0x40,%al
  102cc9:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102cce:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102cd5:	24 7f                	and    $0x7f,%al
  102cd7:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102cdc:	b8 a0 be 11 00       	mov    $0x11bea0,%eax
  102ce1:	c1 e8 18             	shr    $0x18,%eax
  102ce4:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102ce9:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
  102cf0:	e8 e3 fe ff ff       	call   102bd8 <lgdt>
  102cf5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102cfb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102cff:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102d02:	90                   	nop
  102d03:	c9                   	leave  
  102d04:	c3                   	ret    

00102d05 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102d05:	55                   	push   %ebp
  102d06:	89 e5                	mov    %esp,%ebp
  102d08:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102d0b:	c7 05 10 bf 11 00 10 	movl   $0x107210,0x11bf10
  102d12:	72 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102d15:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d1a:	8b 00                	mov    (%eax),%eax
  102d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d20:	c7 04 24 b0 68 10 00 	movl   $0x1068b0,(%esp)
  102d27:	e8 76 d5 ff ff       	call   1002a2 <cprintf>
    pmm_manager->init();
  102d2c:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d31:	8b 40 04             	mov    0x4(%eax),%eax
  102d34:	ff d0                	call   *%eax
}
  102d36:	90                   	nop
  102d37:	c9                   	leave  
  102d38:	c3                   	ret    

00102d39 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
  102d39:	55                   	push   %ebp
  102d3a:	89 e5                	mov    %esp,%ebp
  102d3c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102d3f:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d44:	8b 40 08             	mov    0x8(%eax),%eax
  102d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  102d51:	89 14 24             	mov    %edx,(%esp)
  102d54:	ff d0                	call   *%eax
}
  102d56:	90                   	nop
  102d57:	c9                   	leave  
  102d58:	c3                   	ret    

00102d59 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
//分配连续的n个pagesize大小的内存空间，问题是为什么对页表的相关函数调用都需要先关闭中断呢？？？？
struct Page *
alloc_pages(size_t n) {
  102d59:	55                   	push   %ebp
  102d5a:	89 e5                	mov    %esp,%ebp
  102d5c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag); //先关闭中断，再调用pmm_manager 的alloc_pages()函数进行页分配
  102d66:	e8 2f fe ff ff       	call   102b9a <__intr_save>
  102d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102d6e:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102d73:	8b 40 0c             	mov    0xc(%eax),%eax
  102d76:	8b 55 08             	mov    0x8(%ebp),%edx
  102d79:	89 14 24             	mov    %edx,(%esp)
  102d7c:	ff d0                	call   *%eax
  102d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);//开启中断
  102d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d84:	89 04 24             	mov    %eax,(%esp)
  102d87:	e8 38 fe ff ff       	call   102bc4 <__intr_restore>
    return page;
  102d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102d8f:	c9                   	leave  
  102d90:	c3                   	ret    

00102d91 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//释放n个pagesize大小的内存
void
free_pages(struct Page *base, size_t n) {
  102d91:	55                   	push   %ebp
  102d92:	89 e5                	mov    %esp,%ebp
  102d94:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102d97:	e8 fe fd ff ff       	call   102b9a <__intr_save>
  102d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102d9f:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102da4:	8b 40 10             	mov    0x10(%eax),%eax
  102da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102daa:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dae:	8b 55 08             	mov    0x8(%ebp),%edx
  102db1:	89 14 24             	mov    %edx,(%esp)
  102db4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102db9:	89 04 24             	mov    %eax,(%esp)
  102dbc:	e8 03 fe ff ff       	call   102bc4 <__intr_restore>
}
  102dc1:	90                   	nop
  102dc2:	c9                   	leave  
  102dc3:	c3                   	ret    

00102dc4 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
//获取当前的空闲页数量
size_t
nr_free_pages(void) {
  102dc4:	55                   	push   %ebp
  102dc5:	89 e5                	mov    %esp,%ebp
  102dc7:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102dca:	e8 cb fd ff ff       	call   102b9a <__intr_save>
  102dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102dd2:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  102dd7:	8b 40 14             	mov    0x14(%eax),%eax
  102dda:	ff d0                	call   *%eax
  102ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102de2:	89 04 24             	mov    %eax,(%esp)
  102de5:	e8 da fd ff ff       	call   102bc4 <__intr_restore>
    return ret;
  102dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102ded:	c9                   	leave  
  102dee:	c3                   	ret    

00102def <page_init>:

/* pmm_init - initialize the physical memory management */
// 初始化pmm
static void
page_init(void) {
  102def:	55                   	push   %ebp
  102df0:	89 e5                	mov    %esp,%ebp
  102df2:	57                   	push   %edi
  102df3:	56                   	push   %esi
  102df4:	53                   	push   %ebx
  102df5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    //申明一个e820map变量，从0x8000开始
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102dfb:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102e02:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102e09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102e10:	c7 04 24 c7 68 10 00 	movl   $0x1068c7,(%esp)
  102e17:	e8 86 d4 ff ff       	call   1002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102e1c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e23:	e9 22 01 00 00       	jmp    102f4a <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e28:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e2e:	89 d0                	mov    %edx,%eax
  102e30:	c1 e0 02             	shl    $0x2,%eax
  102e33:	01 d0                	add    %edx,%eax
  102e35:	c1 e0 02             	shl    $0x2,%eax
  102e38:	01 c8                	add    %ecx,%eax
  102e3a:	8b 50 08             	mov    0x8(%eax),%edx
  102e3d:	8b 40 04             	mov    0x4(%eax),%eax
  102e40:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102e43:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102e46:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e4c:	89 d0                	mov    %edx,%eax
  102e4e:	c1 e0 02             	shl    $0x2,%eax
  102e51:	01 d0                	add    %edx,%eax
  102e53:	c1 e0 02             	shl    $0x2,%eax
  102e56:	01 c8                	add    %ecx,%eax
  102e58:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e5b:	8b 58 10             	mov    0x10(%eax),%ebx
  102e5e:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e61:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e64:	01 c8                	add    %ecx,%eax
  102e66:	11 da                	adc    %ebx,%edx
  102e68:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e6b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102e6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e71:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e74:	89 d0                	mov    %edx,%eax
  102e76:	c1 e0 02             	shl    $0x2,%eax
  102e79:	01 d0                	add    %edx,%eax
  102e7b:	c1 e0 02             	shl    $0x2,%eax
  102e7e:	01 c8                	add    %ecx,%eax
  102e80:	83 c0 14             	add    $0x14,%eax
  102e83:	8b 00                	mov    (%eax),%eax
  102e85:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102e88:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e8b:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102e8e:	83 c0 ff             	add    $0xffffffff,%eax
  102e91:	83 d2 ff             	adc    $0xffffffff,%edx
  102e94:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102e9a:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102ea0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ea3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ea6:	89 d0                	mov    %edx,%eax
  102ea8:	c1 e0 02             	shl    $0x2,%eax
  102eab:	01 d0                	add    %edx,%eax
  102ead:	c1 e0 02             	shl    $0x2,%eax
  102eb0:	01 c8                	add    %ecx,%eax
  102eb2:	8b 48 0c             	mov    0xc(%eax),%ecx
  102eb5:	8b 58 10             	mov    0x10(%eax),%ebx
  102eb8:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102ebb:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102ebf:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102ec5:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102ecb:	89 44 24 14          	mov    %eax,0x14(%esp)
  102ecf:	89 54 24 18          	mov    %edx,0x18(%esp)
  102ed3:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ed6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102edd:	89 54 24 10          	mov    %edx,0x10(%esp)
  102ee1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102ee5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102ee9:	c7 04 24 d4 68 10 00 	movl   $0x1068d4,(%esp)
  102ef0:	e8 ad d3 ff ff       	call   1002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {      //用户区内存的第一段，获取交接处的地址
  102ef5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ef8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102efb:	89 d0                	mov    %edx,%eax
  102efd:	c1 e0 02             	shl    $0x2,%eax
  102f00:	01 d0                	add    %edx,%eax
  102f02:	c1 e0 02             	shl    $0x2,%eax
  102f05:	01 c8                	add    %ecx,%eax
  102f07:	83 c0 14             	add    $0x14,%eax
  102f0a:	8b 00                	mov    (%eax),%eax
  102f0c:	83 f8 01             	cmp    $0x1,%eax
  102f0f:	75 36                	jne    102f47 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f17:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102f1a:	77 2b                	ja     102f47 <page_init+0x158>
  102f1c:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102f1f:	72 05                	jb     102f26 <page_init+0x137>
  102f21:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102f24:	73 21                	jae    102f47 <page_init+0x158>
  102f26:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102f2a:	77 1b                	ja     102f47 <page_init+0x158>
  102f2c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102f30:	72 09                	jb     102f3b <page_init+0x14c>
  102f32:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102f39:	77 0c                	ja     102f47 <page_init+0x158>
                maxpa = end;
  102f3b:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f3e:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102f47:	ff 45 dc             	incl   -0x24(%ebp)
  102f4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102f4d:	8b 00                	mov    (%eax),%eax
  102f4f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102f52:	0f 8c d0 fe ff ff    	jl     102e28 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {   //获得内核区边界
  102f58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f5c:	72 1d                	jb     102f7b <page_init+0x18c>
  102f5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f62:	77 09                	ja     102f6d <page_init+0x17e>
  102f64:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102f6b:	76 0e                	jbe    102f7b <page_init+0x18c>
        maxpa = KMEMSIZE;
  102f6d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102f74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f81:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102f85:	c1 ea 0c             	shr    $0xc,%edx
  102f88:	89 c1                	mov    %eax,%ecx
  102f8a:	89 d3                	mov    %edx,%ebx
  102f8c:	89 c8                	mov    %ecx,%eax
  102f8e:	a3 80 be 11 00       	mov    %eax,0x11be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102f93:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102f9a:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
  102f9f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102fa2:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102fa5:	01 d0                	add    %edx,%eax
  102fa7:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102faa:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102fad:	ba 00 00 00 00       	mov    $0x0,%edx
  102fb2:	f7 75 c0             	divl   -0x40(%ebp)
  102fb5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102fb8:	29 d0                	sub    %edx,%eax
  102fba:	a3 18 bf 11 00       	mov    %eax,0x11bf18
    //为所有的页设置保留位为1，即为内核保留的页空间
    for (i = 0; i < npage; i ++) {
  102fbf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102fc6:	eb 2e                	jmp    102ff6 <page_init+0x207>
        SetPageReserved(pages + i);
  102fc8:	8b 0d 18 bf 11 00    	mov    0x11bf18,%ecx
  102fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fd1:	89 d0                	mov    %edx,%eax
  102fd3:	c1 e0 02             	shl    $0x2,%eax
  102fd6:	01 d0                	add    %edx,%eax
  102fd8:	c1 e0 02             	shl    $0x2,%eax
  102fdb:	01 c8                	add    %ecx,%eax
  102fdd:	83 c0 04             	add    $0x4,%eax
  102fe0:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102fe7:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fea:	8b 45 90             	mov    -0x70(%ebp),%eax
  102fed:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102ff0:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102ff3:	ff 45 dc             	incl   -0x24(%ebp)
  102ff6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ff9:	a1 80 be 11 00       	mov    0x11be80,%eax
  102ffe:	39 c2                	cmp    %eax,%edx
  103000:	72 c6                	jb     102fc8 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103002:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  103008:	89 d0                	mov    %edx,%eax
  10300a:	c1 e0 02             	shl    $0x2,%eax
  10300d:	01 d0                	add    %edx,%eax
  10300f:	c1 e0 02             	shl    $0x2,%eax
  103012:	89 c2                	mov    %eax,%edx
  103014:	a1 18 bf 11 00       	mov    0x11bf18,%eax
  103019:	01 d0                	add    %edx,%eax
  10301b:	89 45 b8             	mov    %eax,-0x48(%ebp)
  10301e:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  103025:	77 23                	ja     10304a <page_init+0x25b>
  103027:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10302a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10302e:	c7 44 24 08 04 69 10 	movl   $0x106904,0x8(%esp)
  103035:	00 
  103036:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  10303d:	00 
  10303e:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103045:	e8 af d3 ff ff       	call   1003f9 <__panic>
  10304a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10304d:	05 00 00 00 40       	add    $0x40000000,%eax
  103052:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103055:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10305c:	e9 69 01 00 00       	jmp    1031ca <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103061:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103064:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103067:	89 d0                	mov    %edx,%eax
  103069:	c1 e0 02             	shl    $0x2,%eax
  10306c:	01 d0                	add    %edx,%eax
  10306e:	c1 e0 02             	shl    $0x2,%eax
  103071:	01 c8                	add    %ecx,%eax
  103073:	8b 50 08             	mov    0x8(%eax),%edx
  103076:	8b 40 04             	mov    0x4(%eax),%eax
  103079:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10307c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10307f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103082:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103085:	89 d0                	mov    %edx,%eax
  103087:	c1 e0 02             	shl    $0x2,%eax
  10308a:	01 d0                	add    %edx,%eax
  10308c:	c1 e0 02             	shl    $0x2,%eax
  10308f:	01 c8                	add    %ecx,%eax
  103091:	8b 48 0c             	mov    0xc(%eax),%ecx
  103094:	8b 58 10             	mov    0x10(%eax),%ebx
  103097:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10309a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10309d:	01 c8                	add    %ecx,%eax
  10309f:	11 da                	adc    %ebx,%edx
  1030a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1030a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1030a7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030ad:	89 d0                	mov    %edx,%eax
  1030af:	c1 e0 02             	shl    $0x2,%eax
  1030b2:	01 d0                	add    %edx,%eax
  1030b4:	c1 e0 02             	shl    $0x2,%eax
  1030b7:	01 c8                	add    %ecx,%eax
  1030b9:	83 c0 14             	add    $0x14,%eax
  1030bc:	8b 00                	mov    (%eax),%eax
  1030be:	83 f8 01             	cmp    $0x1,%eax
  1030c1:	0f 85 00 01 00 00    	jne    1031c7 <page_init+0x3d8>
            if (begin < freemem) {
  1030c7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1030ca:	ba 00 00 00 00       	mov    $0x0,%edx
  1030cf:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1030d2:	77 17                	ja     1030eb <page_init+0x2fc>
  1030d4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1030d7:	72 05                	jb     1030de <page_init+0x2ef>
  1030d9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1030dc:	73 0d                	jae    1030eb <page_init+0x2fc>
                begin = freemem;
  1030de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1030e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030e4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1030eb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030ef:	72 1d                	jb     10310e <page_init+0x31f>
  1030f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030f5:	77 09                	ja     103100 <page_init+0x311>
  1030f7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1030fe:	76 0e                	jbe    10310e <page_init+0x31f>
                end = KMEMSIZE;
  103100:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  103107:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  10310e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103111:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103114:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103117:	0f 87 aa 00 00 00    	ja     1031c7 <page_init+0x3d8>
  10311d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103120:	72 09                	jb     10312b <page_init+0x33c>
  103122:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103125:	0f 83 9c 00 00 00    	jae    1031c7 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  10312b:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  103132:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103135:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103138:	01 d0                	add    %edx,%eax
  10313a:	48                   	dec    %eax
  10313b:	89 45 ac             	mov    %eax,-0x54(%ebp)
  10313e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103141:	ba 00 00 00 00       	mov    $0x0,%edx
  103146:	f7 75 b0             	divl   -0x50(%ebp)
  103149:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10314c:	29 d0                	sub    %edx,%eax
  10314e:	ba 00 00 00 00       	mov    $0x0,%edx
  103153:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103156:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103159:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10315c:	89 45 a8             	mov    %eax,-0x58(%ebp)
  10315f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103162:	ba 00 00 00 00       	mov    $0x0,%edx
  103167:	89 c3                	mov    %eax,%ebx
  103169:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  10316f:	89 de                	mov    %ebx,%esi
  103171:	89 d0                	mov    %edx,%eax
  103173:	83 e0 00             	and    $0x0,%eax
  103176:	89 c7                	mov    %eax,%edi
  103178:	89 75 c8             	mov    %esi,-0x38(%ebp)
  10317b:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  10317e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103181:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103184:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103187:	77 3e                	ja     1031c7 <page_init+0x3d8>
  103189:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10318c:	72 05                	jb     103193 <page_init+0x3a4>
  10318e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103191:	73 34                	jae    1031c7 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  103193:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103196:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103199:	2b 45 d0             	sub    -0x30(%ebp),%eax
  10319c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10319f:	89 c1                	mov    %eax,%ecx
  1031a1:	89 d3                	mov    %edx,%ebx
  1031a3:	89 c8                	mov    %ecx,%eax
  1031a5:	89 da                	mov    %ebx,%edx
  1031a7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1031ab:	c1 ea 0c             	shr    $0xc,%edx
  1031ae:	89 c3                	mov    %eax,%ebx
  1031b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031b3:	89 04 24             	mov    %eax,(%esp)
  1031b6:	e8 a0 f8 ff ff       	call   102a5b <pa2page>
  1031bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1031bf:	89 04 24             	mov    %eax,(%esp)
  1031c2:	e8 72 fb ff ff       	call   102d39 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  1031c7:	ff 45 dc             	incl   -0x24(%ebp)
  1031ca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1031cd:	8b 00                	mov    (%eax),%eax
  1031cf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1031d2:	0f 8c 89 fe ff ff    	jl     103061 <page_init+0x272>
                }
            }
        }
    }
}
  1031d8:	90                   	nop
  1031d9:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1031df:	5b                   	pop    %ebx
  1031e0:	5e                   	pop    %esi
  1031e1:	5f                   	pop    %edi
  1031e2:	5d                   	pop    %ebp
  1031e3:	c3                   	ret    

001031e4 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1031e4:	55                   	push   %ebp
  1031e5:	89 e5                	mov    %esp,%ebp
  1031e7:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1031ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031ed:	33 45 14             	xor    0x14(%ebp),%eax
  1031f0:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031f5:	85 c0                	test   %eax,%eax
  1031f7:	74 24                	je     10321d <boot_map_segment+0x39>
  1031f9:	c7 44 24 0c 36 69 10 	movl   $0x106936,0xc(%esp)
  103200:	00 
  103201:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103208:	00 
  103209:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  103210:	00 
  103211:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103218:	e8 dc d1 ff ff       	call   1003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10321d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103224:	8b 45 0c             	mov    0xc(%ebp),%eax
  103227:	25 ff 0f 00 00       	and    $0xfff,%eax
  10322c:	89 c2                	mov    %eax,%edx
  10322e:	8b 45 10             	mov    0x10(%ebp),%eax
  103231:	01 c2                	add    %eax,%edx
  103233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103236:	01 d0                	add    %edx,%eax
  103238:	48                   	dec    %eax
  103239:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10323c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10323f:	ba 00 00 00 00       	mov    $0x0,%edx
  103244:	f7 75 f0             	divl   -0x10(%ebp)
  103247:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10324a:	29 d0                	sub    %edx,%eax
  10324c:	c1 e8 0c             	shr    $0xc,%eax
  10324f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103252:	8b 45 0c             	mov    0xc(%ebp),%eax
  103255:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103258:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10325b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103260:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103263:	8b 45 14             	mov    0x14(%ebp),%eax
  103266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10326c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103271:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103274:	eb 68                	jmp    1032de <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103276:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10327d:	00 
  10327e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103281:	89 44 24 04          	mov    %eax,0x4(%esp)
  103285:	8b 45 08             	mov    0x8(%ebp),%eax
  103288:	89 04 24             	mov    %eax,(%esp)
  10328b:	e8 81 01 00 00       	call   103411 <get_pte>
  103290:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103293:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103297:	75 24                	jne    1032bd <boot_map_segment+0xd9>
  103299:	c7 44 24 0c 62 69 10 	movl   $0x106962,0xc(%esp)
  1032a0:	00 
  1032a1:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1032a8:	00 
  1032a9:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  1032b0:	00 
  1032b1:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1032b8:	e8 3c d1 ff ff       	call   1003f9 <__panic>
        *ptep = pa | PTE_P | perm;
  1032bd:	8b 45 14             	mov    0x14(%ebp),%eax
  1032c0:	0b 45 18             	or     0x18(%ebp),%eax
  1032c3:	83 c8 01             	or     $0x1,%eax
  1032c6:	89 c2                	mov    %eax,%edx
  1032c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032cb:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1032cd:	ff 4d f4             	decl   -0xc(%ebp)
  1032d0:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1032d7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1032de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032e2:	75 92                	jne    103276 <boot_map_segment+0x92>
    }
}
  1032e4:	90                   	nop
  1032e5:	c9                   	leave  
  1032e6:	c3                   	ret    

001032e7 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1032e7:	55                   	push   %ebp
  1032e8:	89 e5                	mov    %esp,%ebp
  1032ea:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1032ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032f4:	e8 60 fa ff ff       	call   102d59 <alloc_pages>
  1032f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1032fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103300:	75 1c                	jne    10331e <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  103302:	c7 44 24 08 6f 69 10 	movl   $0x10696f,0x8(%esp)
  103309:	00 
  10330a:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  103311:	00 
  103312:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103319:	e8 db d0 ff ff       	call   1003f9 <__panic>
    }
    return page2kva(p);
  10331e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103321:	89 04 24             	mov    %eax,(%esp)
  103324:	e8 81 f7 ff ff       	call   102aaa <page2kva>
}
  103329:	c9                   	leave  
  10332a:	c3                   	ret    

0010332b <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10332b:	55                   	push   %ebp
  10332c:	89 e5                	mov    %esp,%ebp
  10332e:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103331:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103336:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103339:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103340:	77 23                	ja     103365 <pmm_init+0x3a>
  103342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103349:	c7 44 24 08 04 69 10 	movl   $0x106904,0x8(%esp)
  103350:	00 
  103351:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  103358:	00 
  103359:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103360:	e8 94 d0 ff ff       	call   1003f9 <__panic>
  103365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103368:	05 00 00 00 40       	add    $0x40000000,%eax
  10336d:	a3 14 bf 11 00       	mov    %eax,0x11bf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103372:	e8 8e f9 ff ff       	call   102d05 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103377:	e8 73 fa ff ff       	call   102def <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  10337c:	e8 e8 03 00 00       	call   103769 <check_alloc_page>

    check_pgdir();
  103381:	e8 02 04 00 00       	call   103788 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103386:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10338b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10338e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103395:	77 23                	ja     1033ba <pmm_init+0x8f>
  103397:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10339a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10339e:	c7 44 24 08 04 69 10 	movl   $0x106904,0x8(%esp)
  1033a5:	00 
  1033a6:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  1033ad:	00 
  1033ae:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1033b5:	e8 3f d0 ff ff       	call   1003f9 <__panic>
  1033ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033bd:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1033c3:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1033c8:	05 ac 0f 00 00       	add    $0xfac,%eax
  1033cd:	83 ca 03             	or     $0x3,%edx
  1033d0:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1033d2:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1033d7:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1033de:	00 
  1033df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1033e6:	00 
  1033e7:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1033ee:	38 
  1033ef:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1033f6:	c0 
  1033f7:	89 04 24             	mov    %eax,(%esp)
  1033fa:	e8 e5 fd ff ff       	call   1031e4 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1033ff:	e8 18 f8 ff ff       	call   102c1c <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  103404:	e8 1b 0a 00 00       	call   103e24 <check_boot_pgdir>

    print_pgdir();
  103409:	e8 94 0e 00 00       	call   1042a2 <print_pgdir>

}
  10340e:	90                   	nop
  10340f:	c9                   	leave  
  103410:	c3                   	ret    

00103411 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103411:	55                   	push   %ebp
  103412:	89 e5                	mov    %esp,%ebp
  103414:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry   通过参数中的pgdir加上页表目录偏移量（数组方式）获取页表目录地址
  103417:	8b 45 0c             	mov    0xc(%ebp),%eax
  10341a:	c1 e8 16             	shr    $0x16,%eax
  10341d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103424:	8b 45 08             	mov    0x8(%ebp),%eax
  103427:	01 d0                	add    %edx,%eax
  103429:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep&PTE_P)) {              // (2) check if entry is not present
  10342c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10342f:	8b 00                	mov    (%eax),%eax
  103431:	83 e0 01             	and    $0x1,%eax
  103434:	85 c0                	test   %eax,%eax
  103436:	0f 85 b9 00 00 00    	jne    1034f5 <get_pte+0xe4>
    struct Page*page;
    if(!create)  return NULL;                // (3) check if creating is needed, then alloc page for page table 不需要分配，直接返回NULL
  10343c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103440:	75 0a                	jne    10344c <get_pte+0x3b>
  103442:	b8 00 00 00 00       	mov    $0x0,%eax
  103447:	e9 06 01 00 00       	jmp    103552 <get_pte+0x141>
    page = alloc_page();
  10344c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103453:	e8 01 f9 ff ff       	call   102d59 <alloc_pages>
  103458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(page==NULL)   return NULL; //没有找到能够分配的页
  10345b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10345f:	75 0a                	jne    10346b <get_pte+0x5a>
  103461:	b8 00 00 00 00       	mov    $0x0,%eax
  103466:	e9 e7 00 00 00       	jmp    103552 <get_pte+0x141>
                                                          // CAUTION: this page is used for page table, not for common data page
    set_page_ref(page,1);     // (4) set page reference
  10346b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103472:	00 
  103473:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103476:	89 04 24             	mov    %eax,(%esp)
  103479:	e8 e0 f6 ff ff       	call   102b5e <set_page_ref>
    uintptr_t pa =page2pa(page); // (5) get linear address of page
  10347e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103481:	89 04 24             	mov    %eax,(%esp)
  103484:	e8 bc f5 ff ff       	call   102a45 <page2pa>
  103489:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memset(KADDR(pa),0,PGSIZE);             // (6) clear page content using memset
  10348c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10348f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103492:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103495:	c1 e8 0c             	shr    $0xc,%eax
  103498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10349b:	a1 80 be 11 00       	mov    0x11be80,%eax
  1034a0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1034a3:	72 23                	jb     1034c8 <get_pte+0xb7>
  1034a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1034ac:	c7 44 24 08 60 68 10 	movl   $0x106860,0x8(%esp)
  1034b3:	00 
  1034b4:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
  1034bb:	00 
  1034bc:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1034c3:	e8 31 cf ff ff       	call   1003f9 <__panic>
  1034c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034cb:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1034d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1034d7:	00 
  1034d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1034df:	00 
  1034e0:	89 04 24             	mov    %eax,(%esp)
  1034e3:	e8 18 24 00 00       	call   105900 <memset>
    *pdep =pa|PTE_W|PTE_P|PTE_U;                      // (7) set page directory entry's permission  设置和物理地址，可写，用户可访问，可用位
  1034e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034eb:	83 c8 07             	or     $0x7,%eax
  1034ee:	89 c2                	mov    %eax,%edx
  1034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034f3:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry  拼接页表项、页表目录、表内偏移，得到物理地址之后转为虚拟地址返回
  1034f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034f8:	8b 00                	mov    (%eax),%eax
  1034fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1034ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103505:	c1 e8 0c             	shr    $0xc,%eax
  103508:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10350b:	a1 80 be 11 00       	mov    0x11be80,%eax
  103510:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103513:	72 23                	jb     103538 <get_pte+0x127>
  103515:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103518:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10351c:	c7 44 24 08 60 68 10 	movl   $0x106860,0x8(%esp)
  103523:	00 
  103524:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
  10352b:	00 
  10352c:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103533:	e8 c1 ce ff ff       	call   1003f9 <__panic>
  103538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10353b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103540:	89 c2                	mov    %eax,%edx
  103542:	8b 45 0c             	mov    0xc(%ebp),%eax
  103545:	c1 e8 0c             	shr    $0xc,%eax
  103548:	25 ff 03 00 00       	and    $0x3ff,%eax
  10354d:	c1 e0 02             	shl    $0x2,%eax
  103550:	01 d0                	add    %edx,%eax
#endif
}
  103552:	c9                   	leave  
  103553:	c3                   	ret    

00103554 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103554:	55                   	push   %ebp
  103555:	89 e5                	mov    %esp,%ebp
  103557:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10355a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103561:	00 
  103562:	8b 45 0c             	mov    0xc(%ebp),%eax
  103565:	89 44 24 04          	mov    %eax,0x4(%esp)
  103569:	8b 45 08             	mov    0x8(%ebp),%eax
  10356c:	89 04 24             	mov    %eax,(%esp)
  10356f:	e8 9d fe ff ff       	call   103411 <get_pte>
  103574:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103577:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10357b:	74 08                	je     103585 <get_page+0x31>
        *ptep_store = ptep;
  10357d:	8b 45 10             	mov    0x10(%ebp),%eax
  103580:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103583:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103589:	74 1b                	je     1035a6 <get_page+0x52>
  10358b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10358e:	8b 00                	mov    (%eax),%eax
  103590:	83 e0 01             	and    $0x1,%eax
  103593:	85 c0                	test   %eax,%eax
  103595:	74 0f                	je     1035a6 <get_page+0x52>
        return pte2page(*ptep);
  103597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10359a:	8b 00                	mov    (%eax),%eax
  10359c:	89 04 24             	mov    %eax,(%esp)
  10359f:	e8 5a f5 ff ff       	call   102afe <pte2page>
  1035a4:	eb 05                	jmp    1035ab <get_page+0x57>
    }
    return NULL;
  1035a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1035ab:	c9                   	leave  
  1035ac:	c3                   	ret    

001035ad <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1035ad:	55                   	push   %ebp
  1035ae:	89 e5                	mov    %esp,%ebp
  1035b0:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep&PTE_P) {                      //(1) check if this page table entry is present   ?
  1035b3:	8b 45 10             	mov    0x10(%ebp),%eax
  1035b6:	8b 00                	mov    (%eax),%eax
  1035b8:	83 e0 01             	and    $0x1,%eax
  1035bb:	85 c0                	test   %eax,%eax
  1035bd:	74 4d                	je     10360c <page_remove_pte+0x5f>
        struct Page *page =pte2page(*ptep); //(2) find corresponding page to pte
  1035bf:	8b 45 10             	mov    0x10(%ebp),%eax
  1035c2:	8b 00                	mov    (%eax),%eax
  1035c4:	89 04 24             	mov    %eax,(%esp)
  1035c7:	e8 32 f5 ff ff       	call   102afe <pte2page>
  1035cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0){                          //(3) decrease page reference
  1035cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035d2:	89 04 24             	mov    %eax,(%esp)
  1035d5:	e8 a9 f5 ff ff       	call   102b83 <page_ref_dec>
  1035da:	85 c0                	test   %eax,%eax
  1035dc:	75 13                	jne    1035f1 <page_remove_pte+0x44>
            free_page(page);  //(4) and free this page when page reference reachs 0
  1035de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1035e5:	00 
  1035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035e9:	89 04 24             	mov    %eax,(%esp)
  1035ec:	e8 a0 f7 ff ff       	call   102d91 <free_pages>
        }
        *ptep = 0;                          //(5) clear second page table entry
  1035f1:	8b 45 10             	mov    0x10(%ebp),%eax
  1035f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,la);                          //(6) flush tlb
  1035fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  103601:	8b 45 08             	mov    0x8(%ebp),%eax
  103604:	89 04 24             	mov    %eax,(%esp)
  103607:	e8 01 01 00 00       	call   10370d <tlb_invalidate>
    }
#endif
}
  10360c:	90                   	nop
  10360d:	c9                   	leave  
  10360e:	c3                   	ret    

0010360f <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10360f:	55                   	push   %ebp
  103610:	89 e5                	mov    %esp,%ebp
  103612:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103615:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10361c:	00 
  10361d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103620:	89 44 24 04          	mov    %eax,0x4(%esp)
  103624:	8b 45 08             	mov    0x8(%ebp),%eax
  103627:	89 04 24             	mov    %eax,(%esp)
  10362a:	e8 e2 fd ff ff       	call   103411 <get_pte>
  10362f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103632:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103636:	74 19                	je     103651 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10363b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10363f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103642:	89 44 24 04          	mov    %eax,0x4(%esp)
  103646:	8b 45 08             	mov    0x8(%ebp),%eax
  103649:	89 04 24             	mov    %eax,(%esp)
  10364c:	e8 5c ff ff ff       	call   1035ad <page_remove_pte>
    }
}
  103651:	90                   	nop
  103652:	c9                   	leave  
  103653:	c3                   	ret    

00103654 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103654:	55                   	push   %ebp
  103655:	89 e5                	mov    %esp,%ebp
  103657:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10365a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103661:	00 
  103662:	8b 45 10             	mov    0x10(%ebp),%eax
  103665:	89 44 24 04          	mov    %eax,0x4(%esp)
  103669:	8b 45 08             	mov    0x8(%ebp),%eax
  10366c:	89 04 24             	mov    %eax,(%esp)
  10366f:	e8 9d fd ff ff       	call   103411 <get_pte>
  103674:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103677:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10367b:	75 0a                	jne    103687 <page_insert+0x33>
        return -E_NO_MEM;
  10367d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103682:	e9 84 00 00 00       	jmp    10370b <page_insert+0xb7>
    }
    page_ref_inc(page);
  103687:	8b 45 0c             	mov    0xc(%ebp),%eax
  10368a:	89 04 24             	mov    %eax,(%esp)
  10368d:	e8 da f4 ff ff       	call   102b6c <page_ref_inc>
    if (*ptep & PTE_P) {
  103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103695:	8b 00                	mov    (%eax),%eax
  103697:	83 e0 01             	and    $0x1,%eax
  10369a:	85 c0                	test   %eax,%eax
  10369c:	74 3e                	je     1036dc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036a1:	8b 00                	mov    (%eax),%eax
  1036a3:	89 04 24             	mov    %eax,(%esp)
  1036a6:	e8 53 f4 ff ff       	call   102afe <pte2page>
  1036ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1036ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1036b4:	75 0d                	jne    1036c3 <page_insert+0x6f>
            page_ref_dec(page);
  1036b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036b9:	89 04 24             	mov    %eax,(%esp)
  1036bc:	e8 c2 f4 ff ff       	call   102b83 <page_ref_dec>
  1036c1:	eb 19                	jmp    1036dc <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1036c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1036ca:	8b 45 10             	mov    0x10(%ebp),%eax
  1036cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1036d4:	89 04 24             	mov    %eax,(%esp)
  1036d7:	e8 d1 fe ff ff       	call   1035ad <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1036dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036df:	89 04 24             	mov    %eax,(%esp)
  1036e2:	e8 5e f3 ff ff       	call   102a45 <page2pa>
  1036e7:	0b 45 14             	or     0x14(%ebp),%eax
  1036ea:	83 c8 01             	or     $0x1,%eax
  1036ed:	89 c2                	mov    %eax,%edx
  1036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036f2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1036f4:	8b 45 10             	mov    0x10(%ebp),%eax
  1036f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1036fe:	89 04 24             	mov    %eax,(%esp)
  103701:	e8 07 00 00 00       	call   10370d <tlb_invalidate>
    return 0;
  103706:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10370b:	c9                   	leave  
  10370c:	c3                   	ret    

0010370d <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10370d:	55                   	push   %ebp
  10370e:	89 e5                	mov    %esp,%ebp
  103710:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103713:	0f 20 d8             	mov    %cr3,%eax
  103716:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  103719:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  10371c:	8b 45 08             	mov    0x8(%ebp),%eax
  10371f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103722:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103729:	77 23                	ja     10374e <tlb_invalidate+0x41>
  10372b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10372e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103732:	c7 44 24 08 04 69 10 	movl   $0x106904,0x8(%esp)
  103739:	00 
  10373a:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
  103741:	00 
  103742:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103749:	e8 ab cc ff ff       	call   1003f9 <__panic>
  10374e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103751:	05 00 00 00 40       	add    $0x40000000,%eax
  103756:	39 d0                	cmp    %edx,%eax
  103758:	75 0c                	jne    103766 <tlb_invalidate+0x59>
        invlpg((void *)la);
  10375a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10375d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103763:	0f 01 38             	invlpg (%eax)
    }
}
  103766:	90                   	nop
  103767:	c9                   	leave  
  103768:	c3                   	ret    

00103769 <check_alloc_page>:

static void
check_alloc_page(void) {
  103769:	55                   	push   %ebp
  10376a:	89 e5                	mov    %esp,%ebp
  10376c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10376f:	a1 10 bf 11 00       	mov    0x11bf10,%eax
  103774:	8b 40 18             	mov    0x18(%eax),%eax
  103777:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103779:	c7 04 24 88 69 10 00 	movl   $0x106988,(%esp)
  103780:	e8 1d cb ff ff       	call   1002a2 <cprintf>
}
  103785:	90                   	nop
  103786:	c9                   	leave  
  103787:	c3                   	ret    

00103788 <check_pgdir>:

static void
check_pgdir(void) {
  103788:	55                   	push   %ebp
  103789:	89 e5                	mov    %esp,%ebp
  10378b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10378e:	a1 80 be 11 00       	mov    0x11be80,%eax
  103793:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103798:	76 24                	jbe    1037be <check_pgdir+0x36>
  10379a:	c7 44 24 0c a7 69 10 	movl   $0x1069a7,0xc(%esp)
  1037a1:	00 
  1037a2:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1037a9:	00 
  1037aa:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  1037b1:	00 
  1037b2:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1037b9:	e8 3b cc ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1037be:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037c3:	85 c0                	test   %eax,%eax
  1037c5:	74 0e                	je     1037d5 <check_pgdir+0x4d>
  1037c7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037cc:	25 ff 0f 00 00       	and    $0xfff,%eax
  1037d1:	85 c0                	test   %eax,%eax
  1037d3:	74 24                	je     1037f9 <check_pgdir+0x71>
  1037d5:	c7 44 24 0c c4 69 10 	movl   $0x1069c4,0xc(%esp)
  1037dc:	00 
  1037dd:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1037e4:	00 
  1037e5:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  1037ec:	00 
  1037ed:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1037f4:	e8 00 cc ff ff       	call   1003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1037f9:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1037fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103805:	00 
  103806:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10380d:	00 
  10380e:	89 04 24             	mov    %eax,(%esp)
  103811:	e8 3e fd ff ff       	call   103554 <get_page>
  103816:	85 c0                	test   %eax,%eax
  103818:	74 24                	je     10383e <check_pgdir+0xb6>
  10381a:	c7 44 24 0c fc 69 10 	movl   $0x1069fc,0xc(%esp)
  103821:	00 
  103822:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103829:	00 
  10382a:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103831:	00 
  103832:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103839:	e8 bb cb ff ff       	call   1003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10383e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103845:	e8 0f f5 ff ff       	call   102d59 <alloc_pages>
  10384a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10384d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103852:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103859:	00 
  10385a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103861:	00 
  103862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103865:	89 54 24 04          	mov    %edx,0x4(%esp)
  103869:	89 04 24             	mov    %eax,(%esp)
  10386c:	e8 e3 fd ff ff       	call   103654 <page_insert>
  103871:	85 c0                	test   %eax,%eax
  103873:	74 24                	je     103899 <check_pgdir+0x111>
  103875:	c7 44 24 0c 24 6a 10 	movl   $0x106a24,0xc(%esp)
  10387c:	00 
  10387d:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103884:	00 
  103885:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  10388c:	00 
  10388d:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103894:	e8 60 cb ff ff       	call   1003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103899:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10389e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038a5:	00 
  1038a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1038ad:	00 
  1038ae:	89 04 24             	mov    %eax,(%esp)
  1038b1:	e8 5b fb ff ff       	call   103411 <get_pte>
  1038b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1038b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1038bd:	75 24                	jne    1038e3 <check_pgdir+0x15b>
  1038bf:	c7 44 24 0c 50 6a 10 	movl   $0x106a50,0xc(%esp)
  1038c6:	00 
  1038c7:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1038ce:	00 
  1038cf:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1038d6:	00 
  1038d7:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1038de:	e8 16 cb ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  1038e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038e6:	8b 00                	mov    (%eax),%eax
  1038e8:	89 04 24             	mov    %eax,(%esp)
  1038eb:	e8 0e f2 ff ff       	call   102afe <pte2page>
  1038f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1038f3:	74 24                	je     103919 <check_pgdir+0x191>
  1038f5:	c7 44 24 0c 7d 6a 10 	movl   $0x106a7d,0xc(%esp)
  1038fc:	00 
  1038fd:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103904:	00 
  103905:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  10390c:	00 
  10390d:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103914:	e8 e0 ca ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 1);
  103919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10391c:	89 04 24             	mov    %eax,(%esp)
  10391f:	e8 30 f2 ff ff       	call   102b54 <page_ref>
  103924:	83 f8 01             	cmp    $0x1,%eax
  103927:	74 24                	je     10394d <check_pgdir+0x1c5>
  103929:	c7 44 24 0c 93 6a 10 	movl   $0x106a93,0xc(%esp)
  103930:	00 
  103931:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103938:	00 
  103939:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  103940:	00 
  103941:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103948:	e8 ac ca ff ff       	call   1003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10394d:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103952:	8b 00                	mov    (%eax),%eax
  103954:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103959:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10395c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10395f:	c1 e8 0c             	shr    $0xc,%eax
  103962:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103965:	a1 80 be 11 00       	mov    0x11be80,%eax
  10396a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10396d:	72 23                	jb     103992 <check_pgdir+0x20a>
  10396f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103976:	c7 44 24 08 60 68 10 	movl   $0x106860,0x8(%esp)
  10397d:	00 
  10397e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103985:	00 
  103986:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  10398d:	e8 67 ca ff ff       	call   1003f9 <__panic>
  103992:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103995:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10399a:	83 c0 04             	add    $0x4,%eax
  10399d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1039a0:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1039a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1039ac:	00 
  1039ad:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1039b4:	00 
  1039b5:	89 04 24             	mov    %eax,(%esp)
  1039b8:	e8 54 fa ff ff       	call   103411 <get_pte>
  1039bd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1039c0:	74 24                	je     1039e6 <check_pgdir+0x25e>
  1039c2:	c7 44 24 0c a8 6a 10 	movl   $0x106aa8,0xc(%esp)
  1039c9:	00 
  1039ca:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1039d1:	00 
  1039d2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  1039d9:	00 
  1039da:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1039e1:	e8 13 ca ff ff       	call   1003f9 <__panic>

    p2 = alloc_page();
  1039e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039ed:	e8 67 f3 ff ff       	call   102d59 <alloc_pages>
  1039f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1039f5:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1039fa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103a01:	00 
  103a02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103a09:	00 
  103a0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a11:	89 04 24             	mov    %eax,(%esp)
  103a14:	e8 3b fc ff ff       	call   103654 <page_insert>
  103a19:	85 c0                	test   %eax,%eax
  103a1b:	74 24                	je     103a41 <check_pgdir+0x2b9>
  103a1d:	c7 44 24 0c d0 6a 10 	movl   $0x106ad0,0xc(%esp)
  103a24:	00 
  103a25:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103a2c:	00 
  103a2d:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103a34:	00 
  103a35:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103a3c:	e8 b8 c9 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a41:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103a46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a4d:	00 
  103a4e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a55:	00 
  103a56:	89 04 24             	mov    %eax,(%esp)
  103a59:	e8 b3 f9 ff ff       	call   103411 <get_pte>
  103a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a65:	75 24                	jne    103a8b <check_pgdir+0x303>
  103a67:	c7 44 24 0c 08 6b 10 	movl   $0x106b08,0xc(%esp)
  103a6e:	00 
  103a6f:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103a76:	00 
  103a77:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103a7e:	00 
  103a7f:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103a86:	e8 6e c9 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_U);
  103a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a8e:	8b 00                	mov    (%eax),%eax
  103a90:	83 e0 04             	and    $0x4,%eax
  103a93:	85 c0                	test   %eax,%eax
  103a95:	75 24                	jne    103abb <check_pgdir+0x333>
  103a97:	c7 44 24 0c 38 6b 10 	movl   $0x106b38,0xc(%esp)
  103a9e:	00 
  103a9f:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103aa6:	00 
  103aa7:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103aae:	00 
  103aaf:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103ab6:	e8 3e c9 ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_W);
  103abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103abe:	8b 00                	mov    (%eax),%eax
  103ac0:	83 e0 02             	and    $0x2,%eax
  103ac3:	85 c0                	test   %eax,%eax
  103ac5:	75 24                	jne    103aeb <check_pgdir+0x363>
  103ac7:	c7 44 24 0c 46 6b 10 	movl   $0x106b46,0xc(%esp)
  103ace:	00 
  103acf:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103ad6:	00 
  103ad7:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103ade:	00 
  103adf:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103ae6:	e8 0e c9 ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103aeb:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103af0:	8b 00                	mov    (%eax),%eax
  103af2:	83 e0 04             	and    $0x4,%eax
  103af5:	85 c0                	test   %eax,%eax
  103af7:	75 24                	jne    103b1d <check_pgdir+0x395>
  103af9:	c7 44 24 0c 54 6b 10 	movl   $0x106b54,0xc(%esp)
  103b00:	00 
  103b01:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103b08:	00 
  103b09:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103b10:	00 
  103b11:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103b18:	e8 dc c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 1);
  103b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b20:	89 04 24             	mov    %eax,(%esp)
  103b23:	e8 2c f0 ff ff       	call   102b54 <page_ref>
  103b28:	83 f8 01             	cmp    $0x1,%eax
  103b2b:	74 24                	je     103b51 <check_pgdir+0x3c9>
  103b2d:	c7 44 24 0c 6a 6b 10 	movl   $0x106b6a,0xc(%esp)
  103b34:	00 
  103b35:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103b3c:	00 
  103b3d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103b44:	00 
  103b45:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103b4c:	e8 a8 c8 ff ff       	call   1003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103b51:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103b56:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103b5d:	00 
  103b5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103b65:	00 
  103b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b69:	89 54 24 04          	mov    %edx,0x4(%esp)
  103b6d:	89 04 24             	mov    %eax,(%esp)
  103b70:	e8 df fa ff ff       	call   103654 <page_insert>
  103b75:	85 c0                	test   %eax,%eax
  103b77:	74 24                	je     103b9d <check_pgdir+0x415>
  103b79:	c7 44 24 0c 7c 6b 10 	movl   $0x106b7c,0xc(%esp)
  103b80:	00 
  103b81:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103b88:	00 
  103b89:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103b90:	00 
  103b91:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103b98:	e8 5c c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 2);
  103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ba0:	89 04 24             	mov    %eax,(%esp)
  103ba3:	e8 ac ef ff ff       	call   102b54 <page_ref>
  103ba8:	83 f8 02             	cmp    $0x2,%eax
  103bab:	74 24                	je     103bd1 <check_pgdir+0x449>
  103bad:	c7 44 24 0c a8 6b 10 	movl   $0x106ba8,0xc(%esp)
  103bb4:	00 
  103bb5:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103bbc:	00 
  103bbd:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  103bc4:	00 
  103bc5:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103bcc:	e8 28 c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bd4:	89 04 24             	mov    %eax,(%esp)
  103bd7:	e8 78 ef ff ff       	call   102b54 <page_ref>
  103bdc:	85 c0                	test   %eax,%eax
  103bde:	74 24                	je     103c04 <check_pgdir+0x47c>
  103be0:	c7 44 24 0c ba 6b 10 	movl   $0x106bba,0xc(%esp)
  103be7:	00 
  103be8:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103bef:	00 
  103bf0:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  103bf7:	00 
  103bf8:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103bff:	e8 f5 c7 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103c04:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c10:	00 
  103c11:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103c18:	00 
  103c19:	89 04 24             	mov    %eax,(%esp)
  103c1c:	e8 f0 f7 ff ff       	call   103411 <get_pte>
  103c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103c28:	75 24                	jne    103c4e <check_pgdir+0x4c6>
  103c2a:	c7 44 24 0c 08 6b 10 	movl   $0x106b08,0xc(%esp)
  103c31:	00 
  103c32:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103c39:	00 
  103c3a:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103c41:	00 
  103c42:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103c49:	e8 ab c7 ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  103c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c51:	8b 00                	mov    (%eax),%eax
  103c53:	89 04 24             	mov    %eax,(%esp)
  103c56:	e8 a3 ee ff ff       	call   102afe <pte2page>
  103c5b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103c5e:	74 24                	je     103c84 <check_pgdir+0x4fc>
  103c60:	c7 44 24 0c 7d 6a 10 	movl   $0x106a7d,0xc(%esp)
  103c67:	00 
  103c68:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103c6f:	00 
  103c70:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103c77:	00 
  103c78:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103c7f:	e8 75 c7 ff ff       	call   1003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c87:	8b 00                	mov    (%eax),%eax
  103c89:	83 e0 04             	and    $0x4,%eax
  103c8c:	85 c0                	test   %eax,%eax
  103c8e:	74 24                	je     103cb4 <check_pgdir+0x52c>
  103c90:	c7 44 24 0c cc 6b 10 	movl   $0x106bcc,0xc(%esp)
  103c97:	00 
  103c98:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103c9f:	00 
  103ca0:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103ca7:	00 
  103ca8:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103caf:	e8 45 c7 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103cb4:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103cb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103cc0:	00 
  103cc1:	89 04 24             	mov    %eax,(%esp)
  103cc4:	e8 46 f9 ff ff       	call   10360f <page_remove>
    assert(page_ref(p1) == 1);
  103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ccc:	89 04 24             	mov    %eax,(%esp)
  103ccf:	e8 80 ee ff ff       	call   102b54 <page_ref>
  103cd4:	83 f8 01             	cmp    $0x1,%eax
  103cd7:	74 24                	je     103cfd <check_pgdir+0x575>
  103cd9:	c7 44 24 0c 93 6a 10 	movl   $0x106a93,0xc(%esp)
  103ce0:	00 
  103ce1:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103ce8:	00 
  103ce9:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103cf0:	00 
  103cf1:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103cf8:	e8 fc c6 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d00:	89 04 24             	mov    %eax,(%esp)
  103d03:	e8 4c ee ff ff       	call   102b54 <page_ref>
  103d08:	85 c0                	test   %eax,%eax
  103d0a:	74 24                	je     103d30 <check_pgdir+0x5a8>
  103d0c:	c7 44 24 0c ba 6b 10 	movl   $0x106bba,0xc(%esp)
  103d13:	00 
  103d14:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103d1b:	00 
  103d1c:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  103d23:	00 
  103d24:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103d2b:	e8 c9 c6 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103d30:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103d35:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103d3c:	00 
  103d3d:	89 04 24             	mov    %eax,(%esp)
  103d40:	e8 ca f8 ff ff       	call   10360f <page_remove>
    assert(page_ref(p1) == 0);
  103d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d48:	89 04 24             	mov    %eax,(%esp)
  103d4b:	e8 04 ee ff ff       	call   102b54 <page_ref>
  103d50:	85 c0                	test   %eax,%eax
  103d52:	74 24                	je     103d78 <check_pgdir+0x5f0>
  103d54:	c7 44 24 0c e1 6b 10 	movl   $0x106be1,0xc(%esp)
  103d5b:	00 
  103d5c:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103d63:	00 
  103d64:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  103d6b:	00 
  103d6c:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103d73:	e8 81 c6 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d7b:	89 04 24             	mov    %eax,(%esp)
  103d7e:	e8 d1 ed ff ff       	call   102b54 <page_ref>
  103d83:	85 c0                	test   %eax,%eax
  103d85:	74 24                	je     103dab <check_pgdir+0x623>
  103d87:	c7 44 24 0c ba 6b 10 	movl   $0x106bba,0xc(%esp)
  103d8e:	00 
  103d8f:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103d96:	00 
  103d97:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103d9e:	00 
  103d9f:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103da6:	e8 4e c6 ff ff       	call   1003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103dab:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103db0:	8b 00                	mov    (%eax),%eax
  103db2:	89 04 24             	mov    %eax,(%esp)
  103db5:	e8 82 ed ff ff       	call   102b3c <pde2page>
  103dba:	89 04 24             	mov    %eax,(%esp)
  103dbd:	e8 92 ed ff ff       	call   102b54 <page_ref>
  103dc2:	83 f8 01             	cmp    $0x1,%eax
  103dc5:	74 24                	je     103deb <check_pgdir+0x663>
  103dc7:	c7 44 24 0c f4 6b 10 	movl   $0x106bf4,0xc(%esp)
  103dce:	00 
  103dcf:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103dd6:	00 
  103dd7:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103dde:	00 
  103ddf:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103de6:	e8 0e c6 ff ff       	call   1003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103deb:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103df0:	8b 00                	mov    (%eax),%eax
  103df2:	89 04 24             	mov    %eax,(%esp)
  103df5:	e8 42 ed ff ff       	call   102b3c <pde2page>
  103dfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e01:	00 
  103e02:	89 04 24             	mov    %eax,(%esp)
  103e05:	e8 87 ef ff ff       	call   102d91 <free_pages>
    boot_pgdir[0] = 0;
  103e0a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103e15:	c7 04 24 1b 6c 10 00 	movl   $0x106c1b,(%esp)
  103e1c:	e8 81 c4 ff ff       	call   1002a2 <cprintf>
}
  103e21:	90                   	nop
  103e22:	c9                   	leave  
  103e23:	c3                   	ret    

00103e24 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103e24:	55                   	push   %ebp
  103e25:	89 e5                	mov    %esp,%ebp
  103e27:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103e2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103e31:	e9 ca 00 00 00       	jmp    103f00 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e3f:	c1 e8 0c             	shr    $0xc,%eax
  103e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103e45:	a1 80 be 11 00       	mov    0x11be80,%eax
  103e4a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103e4d:	72 23                	jb     103e72 <check_boot_pgdir+0x4e>
  103e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103e56:	c7 44 24 08 60 68 10 	movl   $0x106860,0x8(%esp)
  103e5d:	00 
  103e5e:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103e65:	00 
  103e66:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103e6d:	e8 87 c5 ff ff       	call   1003f9 <__panic>
  103e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e75:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103e7a:	89 c2                	mov    %eax,%edx
  103e7c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103e88:	00 
  103e89:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e8d:	89 04 24             	mov    %eax,(%esp)
  103e90:	e8 7c f5 ff ff       	call   103411 <get_pte>
  103e95:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103e98:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103e9c:	75 24                	jne    103ec2 <check_boot_pgdir+0x9e>
  103e9e:	c7 44 24 0c 38 6c 10 	movl   $0x106c38,0xc(%esp)
  103ea5:	00 
  103ea6:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103ead:	00 
  103eae:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103eb5:	00 
  103eb6:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103ebd:	e8 37 c5 ff ff       	call   1003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103ec2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ec5:	8b 00                	mov    (%eax),%eax
  103ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ecc:	89 c2                	mov    %eax,%edx
  103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ed1:	39 c2                	cmp    %eax,%edx
  103ed3:	74 24                	je     103ef9 <check_boot_pgdir+0xd5>
  103ed5:	c7 44 24 0c 75 6c 10 	movl   $0x106c75,0xc(%esp)
  103edc:	00 
  103edd:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103ee4:	00 
  103ee5:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103eec:	00 
  103eed:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103ef4:	e8 00 c5 ff ff       	call   1003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103ef9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103f03:	a1 80 be 11 00       	mov    0x11be80,%eax
  103f08:	39 c2                	cmp    %eax,%edx
  103f0a:	0f 82 26 ff ff ff    	jb     103e36 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103f10:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103f15:	05 ac 0f 00 00       	add    $0xfac,%eax
  103f1a:	8b 00                	mov    (%eax),%eax
  103f1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103f21:	89 c2                	mov    %eax,%edx
  103f23:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f2b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103f32:	77 23                	ja     103f57 <check_boot_pgdir+0x133>
  103f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f3b:	c7 44 24 08 04 69 10 	movl   $0x106904,0x8(%esp)
  103f42:	00 
  103f43:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103f4a:	00 
  103f4b:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103f52:	e8 a2 c4 ff ff       	call   1003f9 <__panic>
  103f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f5a:	05 00 00 00 40       	add    $0x40000000,%eax
  103f5f:	39 d0                	cmp    %edx,%eax
  103f61:	74 24                	je     103f87 <check_boot_pgdir+0x163>
  103f63:	c7 44 24 0c 8c 6c 10 	movl   $0x106c8c,0xc(%esp)
  103f6a:	00 
  103f6b:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103f72:	00 
  103f73:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103f7a:	00 
  103f7b:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103f82:	e8 72 c4 ff ff       	call   1003f9 <__panic>

    assert(boot_pgdir[0] == 0);
  103f87:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103f8c:	8b 00                	mov    (%eax),%eax
  103f8e:	85 c0                	test   %eax,%eax
  103f90:	74 24                	je     103fb6 <check_boot_pgdir+0x192>
  103f92:	c7 44 24 0c c0 6c 10 	movl   $0x106cc0,0xc(%esp)
  103f99:	00 
  103f9a:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103fa1:	00 
  103fa2:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103fa9:	00 
  103faa:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  103fb1:	e8 43 c4 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    p = alloc_page();
  103fb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103fbd:	e8 97 ed ff ff       	call   102d59 <alloc_pages>
  103fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103fc5:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103fca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103fd1:	00 
  103fd2:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103fd9:	00 
  103fda:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103fdd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103fe1:	89 04 24             	mov    %eax,(%esp)
  103fe4:	e8 6b f6 ff ff       	call   103654 <page_insert>
  103fe9:	85 c0                	test   %eax,%eax
  103feb:	74 24                	je     104011 <check_boot_pgdir+0x1ed>
  103fed:	c7 44 24 0c d4 6c 10 	movl   $0x106cd4,0xc(%esp)
  103ff4:	00 
  103ff5:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  103ffc:	00 
  103ffd:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  104004:	00 
  104005:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  10400c:	e8 e8 c3 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 1);
  104011:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104014:	89 04 24             	mov    %eax,(%esp)
  104017:	e8 38 eb ff ff       	call   102b54 <page_ref>
  10401c:	83 f8 01             	cmp    $0x1,%eax
  10401f:	74 24                	je     104045 <check_boot_pgdir+0x221>
  104021:	c7 44 24 0c 02 6d 10 	movl   $0x106d02,0xc(%esp)
  104028:	00 
  104029:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  104030:	00 
  104031:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104038:	00 
  104039:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  104040:	e8 b4 c3 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  104045:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10404a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104051:	00 
  104052:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  104059:	00 
  10405a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10405d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104061:	89 04 24             	mov    %eax,(%esp)
  104064:	e8 eb f5 ff ff       	call   103654 <page_insert>
  104069:	85 c0                	test   %eax,%eax
  10406b:	74 24                	je     104091 <check_boot_pgdir+0x26d>
  10406d:	c7 44 24 0c 14 6d 10 	movl   $0x106d14,0xc(%esp)
  104074:	00 
  104075:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  10407c:	00 
  10407d:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104084:	00 
  104085:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  10408c:	e8 68 c3 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 2);
  104091:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104094:	89 04 24             	mov    %eax,(%esp)
  104097:	e8 b8 ea ff ff       	call   102b54 <page_ref>
  10409c:	83 f8 02             	cmp    $0x2,%eax
  10409f:	74 24                	je     1040c5 <check_boot_pgdir+0x2a1>
  1040a1:	c7 44 24 0c 4b 6d 10 	movl   $0x106d4b,0xc(%esp)
  1040a8:	00 
  1040a9:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  1040b0:	00 
  1040b1:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  1040b8:	00 
  1040b9:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  1040c0:	e8 34 c3 ff ff       	call   1003f9 <__panic>

    const char *str = "ucore: Hello world!!";
  1040c5:	c7 45 e8 5c 6d 10 00 	movl   $0x106d5c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  1040cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1040cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1040d3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040da:	e8 57 15 00 00       	call   105636 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1040df:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1040e6:	00 
  1040e7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1040ee:	e8 ba 15 00 00       	call   1056ad <strcmp>
  1040f3:	85 c0                	test   %eax,%eax
  1040f5:	74 24                	je     10411b <check_boot_pgdir+0x2f7>
  1040f7:	c7 44 24 0c 74 6d 10 	movl   $0x106d74,0xc(%esp)
  1040fe:	00 
  1040ff:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  104106:	00 
  104107:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  10410e:	00 
  10410f:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  104116:	e8 de c2 ff ff       	call   1003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10411b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10411e:	89 04 24             	mov    %eax,(%esp)
  104121:	e8 84 e9 ff ff       	call   102aaa <page2kva>
  104126:	05 00 01 00 00       	add    $0x100,%eax
  10412b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10412e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104135:	e8 a6 14 00 00       	call   1055e0 <strlen>
  10413a:	85 c0                	test   %eax,%eax
  10413c:	74 24                	je     104162 <check_boot_pgdir+0x33e>
  10413e:	c7 44 24 0c ac 6d 10 	movl   $0x106dac,0xc(%esp)
  104145:	00 
  104146:	c7 44 24 08 4d 69 10 	movl   $0x10694d,0x8(%esp)
  10414d:	00 
  10414e:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  104155:	00 
  104156:	c7 04 24 28 69 10 00 	movl   $0x106928,(%esp)
  10415d:	e8 97 c2 ff ff       	call   1003f9 <__panic>

    free_page(p);
  104162:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104169:	00 
  10416a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10416d:	89 04 24             	mov    %eax,(%esp)
  104170:	e8 1c ec ff ff       	call   102d91 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  104175:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10417a:	8b 00                	mov    (%eax),%eax
  10417c:	89 04 24             	mov    %eax,(%esp)
  10417f:	e8 b8 e9 ff ff       	call   102b3c <pde2page>
  104184:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10418b:	00 
  10418c:	89 04 24             	mov    %eax,(%esp)
  10418f:	e8 fd eb ff ff       	call   102d91 <free_pages>
    boot_pgdir[0] = 0;
  104194:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104199:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10419f:	c7 04 24 d0 6d 10 00 	movl   $0x106dd0,(%esp)
  1041a6:	e8 f7 c0 ff ff       	call   1002a2 <cprintf>
}
  1041ab:	90                   	nop
  1041ac:	c9                   	leave  
  1041ad:	c3                   	ret    

001041ae <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1041ae:	55                   	push   %ebp
  1041af:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1041b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1041b4:	83 e0 04             	and    $0x4,%eax
  1041b7:	85 c0                	test   %eax,%eax
  1041b9:	74 04                	je     1041bf <perm2str+0x11>
  1041bb:	b0 75                	mov    $0x75,%al
  1041bd:	eb 02                	jmp    1041c1 <perm2str+0x13>
  1041bf:	b0 2d                	mov    $0x2d,%al
  1041c1:	a2 08 bf 11 00       	mov    %al,0x11bf08
    str[1] = 'r';
  1041c6:	c6 05 09 bf 11 00 72 	movb   $0x72,0x11bf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1041cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1041d0:	83 e0 02             	and    $0x2,%eax
  1041d3:	85 c0                	test   %eax,%eax
  1041d5:	74 04                	je     1041db <perm2str+0x2d>
  1041d7:	b0 77                	mov    $0x77,%al
  1041d9:	eb 02                	jmp    1041dd <perm2str+0x2f>
  1041db:	b0 2d                	mov    $0x2d,%al
  1041dd:	a2 0a bf 11 00       	mov    %al,0x11bf0a
    str[3] = '\0';
  1041e2:	c6 05 0b bf 11 00 00 	movb   $0x0,0x11bf0b
    return str;
  1041e9:	b8 08 bf 11 00       	mov    $0x11bf08,%eax
}
  1041ee:	5d                   	pop    %ebp
  1041ef:	c3                   	ret    

001041f0 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1041f0:	55                   	push   %ebp
  1041f1:	89 e5                	mov    %esp,%ebp
  1041f3:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1041f6:	8b 45 10             	mov    0x10(%ebp),%eax
  1041f9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1041fc:	72 0d                	jb     10420b <get_pgtable_items+0x1b>
        return 0;
  1041fe:	b8 00 00 00 00       	mov    $0x0,%eax
  104203:	e9 98 00 00 00       	jmp    1042a0 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104208:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10420b:	8b 45 10             	mov    0x10(%ebp),%eax
  10420e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104211:	73 18                	jae    10422b <get_pgtable_items+0x3b>
  104213:	8b 45 10             	mov    0x10(%ebp),%eax
  104216:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10421d:	8b 45 14             	mov    0x14(%ebp),%eax
  104220:	01 d0                	add    %edx,%eax
  104222:	8b 00                	mov    (%eax),%eax
  104224:	83 e0 01             	and    $0x1,%eax
  104227:	85 c0                	test   %eax,%eax
  104229:	74 dd                	je     104208 <get_pgtable_items+0x18>
    }
    if (start < right) {
  10422b:	8b 45 10             	mov    0x10(%ebp),%eax
  10422e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104231:	73 68                	jae    10429b <get_pgtable_items+0xab>
        if (left_store != NULL) {
  104233:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104237:	74 08                	je     104241 <get_pgtable_items+0x51>
            *left_store = start;
  104239:	8b 45 18             	mov    0x18(%ebp),%eax
  10423c:	8b 55 10             	mov    0x10(%ebp),%edx
  10423f:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104241:	8b 45 10             	mov    0x10(%ebp),%eax
  104244:	8d 50 01             	lea    0x1(%eax),%edx
  104247:	89 55 10             	mov    %edx,0x10(%ebp)
  10424a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104251:	8b 45 14             	mov    0x14(%ebp),%eax
  104254:	01 d0                	add    %edx,%eax
  104256:	8b 00                	mov    (%eax),%eax
  104258:	83 e0 07             	and    $0x7,%eax
  10425b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10425e:	eb 03                	jmp    104263 <get_pgtable_items+0x73>
            start ++;
  104260:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104263:	8b 45 10             	mov    0x10(%ebp),%eax
  104266:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104269:	73 1d                	jae    104288 <get_pgtable_items+0x98>
  10426b:	8b 45 10             	mov    0x10(%ebp),%eax
  10426e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104275:	8b 45 14             	mov    0x14(%ebp),%eax
  104278:	01 d0                	add    %edx,%eax
  10427a:	8b 00                	mov    (%eax),%eax
  10427c:	83 e0 07             	and    $0x7,%eax
  10427f:	89 c2                	mov    %eax,%edx
  104281:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104284:	39 c2                	cmp    %eax,%edx
  104286:	74 d8                	je     104260 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  104288:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10428c:	74 08                	je     104296 <get_pgtable_items+0xa6>
            *right_store = start;
  10428e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104291:	8b 55 10             	mov    0x10(%ebp),%edx
  104294:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104296:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104299:	eb 05                	jmp    1042a0 <get_pgtable_items+0xb0>
    }
    return 0;
  10429b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1042a0:	c9                   	leave  
  1042a1:	c3                   	ret    

001042a2 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1042a2:	55                   	push   %ebp
  1042a3:	89 e5                	mov    %esp,%ebp
  1042a5:	57                   	push   %edi
  1042a6:	56                   	push   %esi
  1042a7:	53                   	push   %ebx
  1042a8:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1042ab:	c7 04 24 f0 6d 10 00 	movl   $0x106df0,(%esp)
  1042b2:	e8 eb bf ff ff       	call   1002a2 <cprintf>
    size_t left, right = 0, perm;
  1042b7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1042be:	e9 fa 00 00 00       	jmp    1043bd <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1042c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042c6:	89 04 24             	mov    %eax,(%esp)
  1042c9:	e8 e0 fe ff ff       	call   1041ae <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1042ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1042d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042d4:	29 d1                	sub    %edx,%ecx
  1042d6:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1042d8:	89 d6                	mov    %edx,%esi
  1042da:	c1 e6 16             	shl    $0x16,%esi
  1042dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042e0:	89 d3                	mov    %edx,%ebx
  1042e2:	c1 e3 16             	shl    $0x16,%ebx
  1042e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042e8:	89 d1                	mov    %edx,%ecx
  1042ea:	c1 e1 16             	shl    $0x16,%ecx
  1042ed:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1042f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042f3:	29 d7                	sub    %edx,%edi
  1042f5:	89 fa                	mov    %edi,%edx
  1042f7:	89 44 24 14          	mov    %eax,0x14(%esp)
  1042fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  1042ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104303:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104307:	89 54 24 04          	mov    %edx,0x4(%esp)
  10430b:	c7 04 24 21 6e 10 00 	movl   $0x106e21,(%esp)
  104312:	e8 8b bf ff ff       	call   1002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
  104317:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10431a:	c1 e0 0a             	shl    $0xa,%eax
  10431d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104320:	eb 54                	jmp    104376 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104325:	89 04 24             	mov    %eax,(%esp)
  104328:	e8 81 fe ff ff       	call   1041ae <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10432d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104330:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104333:	29 d1                	sub    %edx,%ecx
  104335:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104337:	89 d6                	mov    %edx,%esi
  104339:	c1 e6 0c             	shl    $0xc,%esi
  10433c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10433f:	89 d3                	mov    %edx,%ebx
  104341:	c1 e3 0c             	shl    $0xc,%ebx
  104344:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104347:	89 d1                	mov    %edx,%ecx
  104349:	c1 e1 0c             	shl    $0xc,%ecx
  10434c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10434f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104352:	29 d7                	sub    %edx,%edi
  104354:	89 fa                	mov    %edi,%edx
  104356:	89 44 24 14          	mov    %eax,0x14(%esp)
  10435a:	89 74 24 10          	mov    %esi,0x10(%esp)
  10435e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104366:	89 54 24 04          	mov    %edx,0x4(%esp)
  10436a:	c7 04 24 40 6e 10 00 	movl   $0x106e40,(%esp)
  104371:	e8 2c bf ff ff       	call   1002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104376:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10437b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10437e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104381:	89 d3                	mov    %edx,%ebx
  104383:	c1 e3 0a             	shl    $0xa,%ebx
  104386:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104389:	89 d1                	mov    %edx,%ecx
  10438b:	c1 e1 0a             	shl    $0xa,%ecx
  10438e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104391:	89 54 24 14          	mov    %edx,0x14(%esp)
  104395:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104398:	89 54 24 10          	mov    %edx,0x10(%esp)
  10439c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1043a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1043a8:	89 0c 24             	mov    %ecx,(%esp)
  1043ab:	e8 40 fe ff ff       	call   1041f0 <get_pgtable_items>
  1043b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1043b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1043b7:	0f 85 65 ff ff ff    	jne    104322 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1043bd:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1043c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043c5:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1043c8:	89 54 24 14          	mov    %edx,0x14(%esp)
  1043cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1043cf:	89 54 24 10          	mov    %edx,0x10(%esp)
  1043d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1043d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1043db:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1043e2:	00 
  1043e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1043ea:	e8 01 fe ff ff       	call   1041f0 <get_pgtable_items>
  1043ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1043f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1043f6:	0f 85 c7 fe ff ff    	jne    1042c3 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1043fc:	c7 04 24 64 6e 10 00 	movl   $0x106e64,(%esp)
  104403:	e8 9a be ff ff       	call   1002a2 <cprintf>
}
  104408:	90                   	nop
  104409:	83 c4 4c             	add    $0x4c,%esp
  10440c:	5b                   	pop    %ebx
  10440d:	5e                   	pop    %esi
  10440e:	5f                   	pop    %edi
  10440f:	5d                   	pop    %ebp
  104410:	c3                   	ret    

00104411 <page2ppn>:
page2ppn(struct Page *page) {
  104411:	55                   	push   %ebp
  104412:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104414:	8b 45 08             	mov    0x8(%ebp),%eax
  104417:	8b 15 18 bf 11 00    	mov    0x11bf18,%edx
  10441d:	29 d0                	sub    %edx,%eax
  10441f:	c1 f8 02             	sar    $0x2,%eax
  104422:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104428:	5d                   	pop    %ebp
  104429:	c3                   	ret    

0010442a <page2pa>:
page2pa(struct Page *page) {
  10442a:	55                   	push   %ebp
  10442b:	89 e5                	mov    %esp,%ebp
  10442d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104430:	8b 45 08             	mov    0x8(%ebp),%eax
  104433:	89 04 24             	mov    %eax,(%esp)
  104436:	e8 d6 ff ff ff       	call   104411 <page2ppn>
  10443b:	c1 e0 0c             	shl    $0xc,%eax
}
  10443e:	c9                   	leave  
  10443f:	c3                   	ret    

00104440 <page_ref>:
page_ref(struct Page *page) {
  104440:	55                   	push   %ebp
  104441:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104443:	8b 45 08             	mov    0x8(%ebp),%eax
  104446:	8b 00                	mov    (%eax),%eax
}
  104448:	5d                   	pop    %ebp
  104449:	c3                   	ret    

0010444a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10444a:	55                   	push   %ebp
  10444b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10444d:	8b 45 08             	mov    0x8(%ebp),%eax
  104450:	8b 55 0c             	mov    0xc(%ebp),%edx
  104453:	89 10                	mov    %edx,(%eax)
}
  104455:	90                   	nop
  104456:	5d                   	pop    %ebp
  104457:	c3                   	ret    

00104458 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104458:	55                   	push   %ebp
  104459:	89 e5                	mov    %esp,%ebp
  10445b:	83 ec 10             	sub    $0x10,%esp
  10445e:	c7 45 fc 1c bf 11 00 	movl   $0x11bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104465:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104468:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10446b:	89 50 04             	mov    %edx,0x4(%eax)
  10446e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104471:	8b 50 04             	mov    0x4(%eax),%edx
  104474:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104477:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  104479:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  104480:	00 00 00 
}
  104483:	90                   	nop
  104484:	c9                   	leave  
  104485:	c3                   	ret    

00104486 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104486:	55                   	push   %ebp
  104487:	89 e5                	mov    %esp,%ebp
  104489:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);    //断言，如果判断为false，直接中断程序的执行
  10448c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104490:	75 24                	jne    1044b6 <default_init_memmap+0x30>
  104492:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  104499:	00 
  10449a:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1044a1:	00 
  1044a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1044a9:	00 
  1044aa:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1044b1:	e8 43 bf ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  1044b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1044b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1044bc:	eb 7d                	jmp    10453b <default_init_memmap+0xb5>
        assert(PageReserved(p));        //判断该页保留位是否为1，如果为内核占用页则清空该标志位
  1044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044c1:	83 c0 04             	add    $0x4,%eax
  1044c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1044cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1044ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1044d4:	0f a3 10             	bt     %edx,(%eax)
  1044d7:	19 c0                	sbb    %eax,%eax
  1044d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  1044dc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1044e0:	0f 95 c0             	setne  %al
  1044e3:	0f b6 c0             	movzbl %al,%eax
  1044e6:	85 c0                	test   %eax,%eax
  1044e8:	75 24                	jne    10450e <default_init_memmap+0x88>
  1044ea:	c7 44 24 0c c9 6e 10 	movl   $0x106ec9,0xc(%esp)
  1044f1:	00 
  1044f2:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1044f9:	00 
  1044fa:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  104501:	00 
  104502:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104509:	e8 eb be ff ff       	call   1003f9 <__panic>
        p->flags = p->property = 0;     //标志为清0，空闲块数量置0
  10450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104511:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10451b:	8b 50 08             	mov    0x8(%eax),%edx
  10451e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104521:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);                   //设置引用量为0
  104524:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10452b:	00 
  10452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10452f:	89 04 24             	mov    %eax,(%esp)
  104532:	e8 13 ff ff ff       	call   10444a <set_page_ref>
    for (; p != base + n; p ++) {
  104537:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10453b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10453e:	89 d0                	mov    %edx,%eax
  104540:	c1 e0 02             	shl    $0x2,%eax
  104543:	01 d0                	add    %edx,%eax
  104545:	c1 e0 02             	shl    $0x2,%eax
  104548:	89 c2                	mov    %eax,%edx
  10454a:	8b 45 08             	mov    0x8(%ebp),%eax
  10454d:	01 d0                	add    %edx,%eax
  10454f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104552:	0f 85 66 ff ff ff    	jne    1044be <default_init_memmap+0x38>
    }
    base->property = n;
  104558:	8b 45 08             	mov    0x8(%ebp),%eax
  10455b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10455e:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104561:	8b 45 08             	mov    0x8(%ebp),%eax
  104564:	83 c0 04             	add    $0x4,%eax
  104567:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  10456e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104571:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104574:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104577:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10457a:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  104580:	8b 45 0c             	mov    0xc(%ebp),%eax
  104583:	01 d0                	add    %edx,%eax
  104585:	a3 24 bf 11 00       	mov    %eax,0x11bf24
    //应该使用list_add_before,否则使用list_add默认为add_after,
    //这样新增加的页总是在后面，不适合FFMA算法，应该要按照地址排序
    list_add_before(&free_list, &(base->page_link));    //cc
  10458a:	8b 45 08             	mov    0x8(%ebp),%eax
  10458d:	83 c0 0c             	add    $0xc,%eax
  104590:	c7 45 e4 1c bf 11 00 	movl   $0x11bf1c,-0x1c(%ebp)
  104597:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10459a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10459d:	8b 00                	mov    (%eax),%eax
  10459f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1045a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1045a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1045ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1045ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1045b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1045b4:	89 10                	mov    %edx,(%eax)
  1045b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1045b9:	8b 10                	mov    (%eax),%edx
  1045bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1045be:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1045c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1045c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1045ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1045cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1045d0:	89 10                	mov    %edx,(%eax)
}
  1045d2:	90                   	nop
  1045d3:	c9                   	leave  
  1045d4:	c3                   	ret    

001045d5 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1045d5:	55                   	push   %ebp
  1045d6:	89 e5                	mov    %esp,%ebp
  1045d8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1045db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1045df:	75 24                	jne    104605 <default_alloc_pages+0x30>
  1045e1:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  1045e8:	00 
  1045e9:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1045f0:	00 
  1045f1:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  1045f8:	00 
  1045f9:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104600:	e8 f4 bd ff ff       	call   1003f9 <__panic>
    if (n > nr_free) {      //要求的超过空闲空间大小，返回NULL
  104605:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  10460a:	39 45 08             	cmp    %eax,0x8(%ebp)
  10460d:	76 0a                	jbe    104619 <default_alloc_pages+0x44>
        return NULL;
  10460f:	b8 00 00 00 00       	mov    $0x0,%eax
  104614:	e9 3d 01 00 00       	jmp    104756 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  104619:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;          //查找符合条件的page
  104620:	c7 45 f0 1c bf 11 00 	movl   $0x11bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104627:	eb 1c                	jmp    104645 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  104629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10462c:	83 e8 0c             	sub    $0xc,%eax
  10462f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {               //找到符合条件的块，赋值给page变量带出
  104632:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104635:	8b 40 08             	mov    0x8(%eax),%eax
  104638:	39 45 08             	cmp    %eax,0x8(%ebp)
  10463b:	77 08                	ja     104645 <default_alloc_pages+0x70>
            page = p;
  10463d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104643:	eb 18                	jmp    10465d <default_alloc_pages+0x88>
  104645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  10464b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10464e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104651:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104654:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  10465b:	75 cc                	jne    104629 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {           //找到了符合条件的页，进行设置
  10465d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104661:	0f 84 ec 00 00 00    	je     104753 <default_alloc_pages+0x17e>
        if (page->property > n) {
  104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10466a:	8b 40 08             	mov    0x8(%eax),%eax
  10466d:	39 45 08             	cmp    %eax,0x8(%ebp)
  104670:	0f 83 8c 00 00 00    	jae    104702 <default_alloc_pages+0x12d>
            struct Page *p = page + n;        //将多余的页空间，重新放入空闲页表目录
  104676:	8b 55 08             	mov    0x8(%ebp),%edx
  104679:	89 d0                	mov    %edx,%eax
  10467b:	c1 e0 02             	shl    $0x2,%eax
  10467e:	01 d0                	add    %edx,%eax
  104680:	c1 e0 02             	shl    $0x2,%eax
  104683:	89 c2                	mov    %eax,%edx
  104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104688:	01 d0                	add    %edx,%eax
  10468a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  10468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104690:	8b 40 08             	mov    0x8(%eax),%eax
  104693:	2b 45 08             	sub    0x8(%ebp),%eax
  104696:	89 c2                	mov    %eax,%edx
  104698:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10469b:	89 50 08             	mov    %edx,0x8(%eax)
            //应该要对剩余的部分空闲页设置属性位，在init中属性位全为0，这里需要设为1,表明空闲块
            SetPageProperty(p);                 //++
  10469e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046a1:	83 c0 04             	add    $0x4,%eax
  1046a4:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  1046ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1046ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1046b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1046b4:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));  //cc注意一定要添加在后面,按地址排序
  1046b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1046ba:	83 c0 0c             	add    $0xc,%eax
  1046bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1046c0:	83 c2 0c             	add    $0xc,%edx
  1046c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  1046c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
  1046c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1046cc:	8b 40 04             	mov    0x4(%eax),%eax
  1046cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1046d2:	89 55 d8             	mov    %edx,-0x28(%ebp)
  1046d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1046d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1046db:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
  1046de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1046e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1046e4:	89 10                	mov    %edx,(%eax)
  1046e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1046e9:	8b 10                	mov    (%eax),%edx
  1046eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1046f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1046f7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1046fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1046fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104700:	89 10                	mov    %edx,(%eax)
    }
      list_del(&(page->page_link));     // 先要处理完剩余空间再删除该页，从空闲页表目录页删除该页
  104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104705:	83 c0 0c             	add    $0xc,%eax
  104708:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
  10470b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10470e:	8b 40 04             	mov    0x4(%eax),%eax
  104711:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104714:	8b 12                	mov    (%edx),%edx
  104716:	89 55 b8             	mov    %edx,-0x48(%ebp)
  104719:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10471c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10471f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104722:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104725:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104728:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10472b:	89 10                	mov    %edx,(%eax)
      nr_free -= n;       //总空闲块数减去分配页块数
  10472d:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104732:	2b 45 08             	sub    0x8(%ebp),%eax
  104735:	a3 24 bf 11 00       	mov    %eax,0x11bf24
      ClearPageProperty(page);//将属性位置0，标记该页已被分配
  10473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10473d:	83 c0 04             	add    $0x4,%eax
  104740:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  104747:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10474a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10474d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104750:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104756:	c9                   	leave  
  104757:	c3                   	ret    

00104758 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104758:	55                   	push   %ebp
  104759:	89 e5                	mov    %esp,%ebp
  10475b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  104761:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104765:	75 24                	jne    10478b <default_free_pages+0x33>
  104767:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  10476e:	00 
  10476f:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104776:	00 
  104777:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  10477e:	00 
  10477f:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104786:	e8 6e bc ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  10478b:	8b 45 08             	mov    0x8(%ebp),%eax
  10478e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
  104791:	e9 9d 00 00 00       	jmp    104833 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));     //否则为用户态的占用区
  104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104799:	83 c0 04             	add    $0x4,%eax
  10479c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1047a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1047a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1047a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1047ac:	0f a3 10             	bt     %edx,(%eax)
  1047af:	19 c0                	sbb    %eax,%eax
  1047b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1047b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1047b8:	0f 95 c0             	setne  %al
  1047bb:	0f b6 c0             	movzbl %al,%eax
  1047be:	85 c0                	test   %eax,%eax
  1047c0:	75 2c                	jne    1047ee <default_free_pages+0x96>
  1047c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047c5:	83 c0 04             	add    $0x4,%eax
  1047c8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1047cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1047d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1047d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1047d8:	0f a3 10             	bt     %edx,(%eax)
  1047db:	19 c0                	sbb    %eax,%eax
  1047dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  1047e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1047e4:	0f 95 c0             	setne  %al
  1047e7:	0f b6 c0             	movzbl %al,%eax
  1047ea:	85 c0                	test   %eax,%eax
  1047ec:	74 24                	je     104812 <default_free_pages+0xba>
  1047ee:	c7 44 24 0c dc 6e 10 	movl   $0x106edc,0xc(%esp)
  1047f5:	00 
  1047f6:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1047fd:	00 
  1047fe:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
  104805:	00 
  104806:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10480d:	e8 e7 bb ff ff       	call   1003f9 <__panic>
        p->flags = 0;         //标志位清零
  104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104815:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  10481c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104823:	00 
  104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104827:	89 04 24             	mov    %eax,(%esp)
  10482a:	e8 1b fc ff ff       	call   10444a <set_page_ref>
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
  10482f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104833:	8b 55 0c             	mov    0xc(%ebp),%edx
  104836:	89 d0                	mov    %edx,%eax
  104838:	c1 e0 02             	shl    $0x2,%eax
  10483b:	01 d0                	add    %edx,%eax
  10483d:	c1 e0 02             	shl    $0x2,%eax
  104840:	89 c2                	mov    %eax,%edx
  104842:	8b 45 08             	mov    0x8(%ebp),%eax
  104845:	01 d0                	add    %edx,%eax
  104847:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10484a:	0f 85 46 ff ff ff    	jne    104796 <default_free_pages+0x3e>
    }
    base->property = n;
  104850:	8b 45 08             	mov    0x8(%ebp),%eax
  104853:	8b 55 0c             	mov    0xc(%ebp),%edx
  104856:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104859:	8b 45 08             	mov    0x8(%ebp),%eax
  10485c:	83 c0 04             	add    $0x4,%eax
  10485f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104866:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104869:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10486c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10486f:	0f ab 10             	bts    %edx,(%eax)
  104872:	c7 45 d4 1c bf 11 00 	movl   $0x11bf1c,-0x2c(%ebp)
    return listelm->next;
  104879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10487c:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);    //获取头页地址
  10487f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {            //合并空页
  104882:	e9 08 01 00 00       	jmp    10498f <default_free_pages+0x237>
        p = le2page(le, page_link);
  104887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10488a:	83 e8 0c             	sub    $0xc,%eax
  10488d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104893:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104896:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104899:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  10489c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {     //如果该页为当前释放页的紧邻后页，则直接释放后面一页的属性位，将之和当前页合并
  10489f:	8b 45 08             	mov    0x8(%ebp),%eax
  1048a2:	8b 50 08             	mov    0x8(%eax),%edx
  1048a5:	89 d0                	mov    %edx,%eax
  1048a7:	c1 e0 02             	shl    $0x2,%eax
  1048aa:	01 d0                	add    %edx,%eax
  1048ac:	c1 e0 02             	shl    $0x2,%eax
  1048af:	89 c2                	mov    %eax,%edx
  1048b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1048b4:	01 d0                	add    %edx,%eax
  1048b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1048b9:	75 5a                	jne    104915 <default_free_pages+0x1bd>
            base->property += p->property;
  1048bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1048be:	8b 50 08             	mov    0x8(%eax),%edx
  1048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048c4:	8b 40 08             	mov    0x8(%eax),%eax
  1048c7:	01 c2                	add    %eax,%edx
  1048c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1048cc:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);     //清楚属性位
  1048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048d2:	83 c0 04             	add    $0x4,%eax
  1048d5:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  1048dc:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1048df:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1048e2:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1048e5:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));    //在空闲页表中删除该页
  1048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048eb:	83 c0 0c             	add    $0xc,%eax
  1048ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  1048f1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1048f4:	8b 40 04             	mov    0x4(%eax),%eax
  1048f7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1048fa:	8b 12                	mov    (%edx),%edx
  1048fc:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1048ff:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  104902:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104905:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104908:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10490b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10490e:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104911:	89 10                	mov    %edx,(%eax)
  104913:	eb 7a                	jmp    10498f <default_free_pages+0x237>
        }
        else if (p + p->property == base) {   //如果找到紧邻前一页是空页，则把前页合并到当前页
  104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104918:	8b 50 08             	mov    0x8(%eax),%edx
  10491b:	89 d0                	mov    %edx,%eax
  10491d:	c1 e0 02             	shl    $0x2,%eax
  104920:	01 d0                	add    %edx,%eax
  104922:	c1 e0 02             	shl    $0x2,%eax
  104925:	89 c2                	mov    %eax,%edx
  104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10492a:	01 d0                	add    %edx,%eax
  10492c:	39 45 08             	cmp    %eax,0x8(%ebp)
  10492f:	75 5e                	jne    10498f <default_free_pages+0x237>
            p->property += base->property;
  104931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104934:	8b 50 08             	mov    0x8(%eax),%edx
  104937:	8b 45 08             	mov    0x8(%ebp),%eax
  10493a:	8b 40 08             	mov    0x8(%eax),%eax
  10493d:	01 c2                	add    %eax,%edx
  10493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104942:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104945:	8b 45 08             	mov    0x8(%ebp),%eax
  104948:	83 c0 04             	add    $0x4,%eax
  10494b:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  104952:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104955:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104958:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10495b:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10495e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104961:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104964:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104967:	83 c0 0c             	add    $0xc,%eax
  10496a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  10496d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104970:	8b 40 04             	mov    0x4(%eax),%eax
  104973:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104976:	8b 12                	mov    (%edx),%edx
  104978:	89 55 ac             	mov    %edx,-0x54(%ebp)
  10497b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  10497e:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104981:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104984:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104987:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10498a:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10498d:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {            //合并空页
  10498f:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  104996:	0f 85 eb fe ff ff    	jne    104887 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  10499c:	8b 15 24 bf 11 00    	mov    0x11bf24,%edx
  1049a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1049a5:	01 d0                	add    %edx,%eax
  1049a7:	a3 24 bf 11 00       	mov    %eax,0x11bf24
  1049ac:	c7 45 9c 1c bf 11 00 	movl   $0x11bf1c,-0x64(%ebp)
    return listelm->next;
  1049b3:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1049b6:	8b 40 04             	mov    0x4(%eax),%eax
    //从头到尾进行一次遍历，找到合适的插入位置,把合并和的页插入到找到的位置前面
    le  = list_next(&free_list);
  1049b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
  1049bc:	eb 34                	jmp    1049f2 <default_free_pages+0x29a>
      p = le2page(le,page_link);
  1049be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049c1:	83 e8 0c             	sub    $0xc,%eax
  1049c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(base+base->property<=p){
  1049c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1049ca:	8b 50 08             	mov    0x8(%eax),%edx
  1049cd:	89 d0                	mov    %edx,%eax
  1049cf:	c1 e0 02             	shl    $0x2,%eax
  1049d2:	01 d0                	add    %edx,%eax
  1049d4:	c1 e0 02             	shl    $0x2,%eax
  1049d7:	89 c2                	mov    %eax,%edx
  1049d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1049dc:	01 d0                	add    %edx,%eax
  1049de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1049e1:	73 1a                	jae    1049fd <default_free_pages+0x2a5>
  1049e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049e6:	89 45 98             	mov    %eax,-0x68(%ebp)
  1049e9:	8b 45 98             	mov    -0x68(%ebp),%eax
  1049ec:	8b 40 04             	mov    0x4(%eax),%eax
        break;
      }
      le = list_next(le);
  1049ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
  1049f2:	81 7d f0 1c bf 11 00 	cmpl   $0x11bf1c,-0x10(%ebp)
  1049f9:	75 c3                	jne    1049be <default_free_pages+0x266>
  1049fb:	eb 01                	jmp    1049fe <default_free_pages+0x2a6>
        break;
  1049fd:	90                   	nop
    }
    list_add_before(le, &(base->page_link));    //cc应该使用add_before把整合的页插入找到的位置
  1049fe:	8b 45 08             	mov    0x8(%ebp),%eax
  104a01:	8d 50 0c             	lea    0xc(%eax),%edx
  104a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a07:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104a0a:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104a0d:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104a10:	8b 00                	mov    (%eax),%eax
  104a12:	8b 55 90             	mov    -0x70(%ebp),%edx
  104a15:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104a18:	89 45 88             	mov    %eax,-0x78(%ebp)
  104a1b:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104a1e:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  104a21:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104a24:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104a27:	89 10                	mov    %edx,(%eax)
  104a29:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104a2c:	8b 10                	mov    (%eax),%edx
  104a2e:	8b 45 88             	mov    -0x78(%ebp),%eax
  104a31:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104a34:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a37:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104a3a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104a3d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104a40:	8b 55 88             	mov    -0x78(%ebp),%edx
  104a43:	89 10                	mov    %edx,(%eax)
}
  104a45:	90                   	nop
  104a46:	c9                   	leave  
  104a47:	c3                   	ret    

00104a48 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104a48:	55                   	push   %ebp
  104a49:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104a4b:	a1 24 bf 11 00       	mov    0x11bf24,%eax
}
  104a50:	5d                   	pop    %ebp
  104a51:	c3                   	ret    

00104a52 <basic_check>:

static void
basic_check(void) {
  104a52:	55                   	push   %ebp
  104a53:	89 e5                	mov    %esp,%ebp
  104a55:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104a58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a68:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104a6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a72:	e8 e2 e2 ff ff       	call   102d59 <alloc_pages>
  104a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104a7e:	75 24                	jne    104aa4 <basic_check+0x52>
  104a80:	c7 44 24 0c 01 6f 10 	movl   $0x106f01,0xc(%esp)
  104a87:	00 
  104a88:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104a8f:	00 
  104a90:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a97:	00 
  104a98:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104a9f:	e8 55 b9 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104aa4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104aab:	e8 a9 e2 ff ff       	call   102d59 <alloc_pages>
  104ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ab3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ab7:	75 24                	jne    104add <basic_check+0x8b>
  104ab9:	c7 44 24 0c 1d 6f 10 	movl   $0x106f1d,0xc(%esp)
  104ac0:	00 
  104ac1:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104ac8:	00 
  104ac9:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  104ad0:	00 
  104ad1:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104ad8:	e8 1c b9 ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104add:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ae4:	e8 70 e2 ff ff       	call   102d59 <alloc_pages>
  104ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104aec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104af0:	75 24                	jne    104b16 <basic_check+0xc4>
  104af2:	c7 44 24 0c 39 6f 10 	movl   $0x106f39,0xc(%esp)
  104af9:	00 
  104afa:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104b01:	00 
  104b02:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104b09:	00 
  104b0a:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104b11:	e8 e3 b8 ff ff       	call   1003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b19:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104b1c:	74 10                	je     104b2e <basic_check+0xdc>
  104b1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b24:	74 08                	je     104b2e <basic_check+0xdc>
  104b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b29:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b2c:	75 24                	jne    104b52 <basic_check+0x100>
  104b2e:	c7 44 24 0c 58 6f 10 	movl   $0x106f58,0xc(%esp)
  104b35:	00 
  104b36:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104b3d:	00 
  104b3e:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104b45:	00 
  104b46:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104b4d:	e8 a7 b8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104b55:	89 04 24             	mov    %eax,(%esp)
  104b58:	e8 e3 f8 ff ff       	call   104440 <page_ref>
  104b5d:	85 c0                	test   %eax,%eax
  104b5f:	75 1e                	jne    104b7f <basic_check+0x12d>
  104b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b64:	89 04 24             	mov    %eax,(%esp)
  104b67:	e8 d4 f8 ff ff       	call   104440 <page_ref>
  104b6c:	85 c0                	test   %eax,%eax
  104b6e:	75 0f                	jne    104b7f <basic_check+0x12d>
  104b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b73:	89 04 24             	mov    %eax,(%esp)
  104b76:	e8 c5 f8 ff ff       	call   104440 <page_ref>
  104b7b:	85 c0                	test   %eax,%eax
  104b7d:	74 24                	je     104ba3 <basic_check+0x151>
  104b7f:	c7 44 24 0c 7c 6f 10 	movl   $0x106f7c,0xc(%esp)
  104b86:	00 
  104b87:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104b8e:	00 
  104b8f:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  104b96:	00 
  104b97:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104b9e:	e8 56 b8 ff ff       	call   1003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ba6:	89 04 24             	mov    %eax,(%esp)
  104ba9:	e8 7c f8 ff ff       	call   10442a <page2pa>
  104bae:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104bb4:	c1 e2 0c             	shl    $0xc,%edx
  104bb7:	39 d0                	cmp    %edx,%eax
  104bb9:	72 24                	jb     104bdf <basic_check+0x18d>
  104bbb:	c7 44 24 0c b8 6f 10 	movl   $0x106fb8,0xc(%esp)
  104bc2:	00 
  104bc3:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104bca:	00 
  104bcb:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  104bd2:	00 
  104bd3:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104bda:	e8 1a b8 ff ff       	call   1003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104be2:	89 04 24             	mov    %eax,(%esp)
  104be5:	e8 40 f8 ff ff       	call   10442a <page2pa>
  104bea:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104bf0:	c1 e2 0c             	shl    $0xc,%edx
  104bf3:	39 d0                	cmp    %edx,%eax
  104bf5:	72 24                	jb     104c1b <basic_check+0x1c9>
  104bf7:	c7 44 24 0c d5 6f 10 	movl   $0x106fd5,0xc(%esp)
  104bfe:	00 
  104bff:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104c06:	00 
  104c07:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  104c0e:	00 
  104c0f:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104c16:	e8 de b7 ff ff       	call   1003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c1e:	89 04 24             	mov    %eax,(%esp)
  104c21:	e8 04 f8 ff ff       	call   10442a <page2pa>
  104c26:	8b 15 80 be 11 00    	mov    0x11be80,%edx
  104c2c:	c1 e2 0c             	shl    $0xc,%edx
  104c2f:	39 d0                	cmp    %edx,%eax
  104c31:	72 24                	jb     104c57 <basic_check+0x205>
  104c33:	c7 44 24 0c f2 6f 10 	movl   $0x106ff2,0xc(%esp)
  104c3a:	00 
  104c3b:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104c42:	00 
  104c43:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  104c4a:	00 
  104c4b:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104c52:	e8 a2 b7 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  104c57:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  104c5c:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  104c62:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104c65:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104c68:	c7 45 dc 1c bf 11 00 	movl   $0x11bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104c6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c72:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104c75:	89 50 04             	mov    %edx,0x4(%eax)
  104c78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c7b:	8b 50 04             	mov    0x4(%eax),%edx
  104c7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104c81:	89 10                	mov    %edx,(%eax)
  104c83:	c7 45 e0 1c bf 11 00 	movl   $0x11bf1c,-0x20(%ebp)
    return list->next == list;
  104c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104c8d:	8b 40 04             	mov    0x4(%eax),%eax
  104c90:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104c93:	0f 94 c0             	sete   %al
  104c96:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104c99:	85 c0                	test   %eax,%eax
  104c9b:	75 24                	jne    104cc1 <basic_check+0x26f>
  104c9d:	c7 44 24 0c 0f 70 10 	movl   $0x10700f,0xc(%esp)
  104ca4:	00 
  104ca5:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104cac:	00 
  104cad:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104cb4:	00 
  104cb5:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104cbc:	e8 38 b7 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  104cc1:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104cc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104cc9:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  104cd0:	00 00 00 

    assert(alloc_page() == NULL);
  104cd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cda:	e8 7a e0 ff ff       	call   102d59 <alloc_pages>
  104cdf:	85 c0                	test   %eax,%eax
  104ce1:	74 24                	je     104d07 <basic_check+0x2b5>
  104ce3:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  104cea:	00 
  104ceb:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104cf2:	00 
  104cf3:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
  104cfa:	00 
  104cfb:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104d02:	e8 f2 b6 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104d07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d0e:	00 
  104d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d12:	89 04 24             	mov    %eax,(%esp)
  104d15:	e8 77 e0 ff ff       	call   102d91 <free_pages>
    free_page(p1);
  104d1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d21:	00 
  104d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d25:	89 04 24             	mov    %eax,(%esp)
  104d28:	e8 64 e0 ff ff       	call   102d91 <free_pages>
    free_page(p2);
  104d2d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d34:	00 
  104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d38:	89 04 24             	mov    %eax,(%esp)
  104d3b:	e8 51 e0 ff ff       	call   102d91 <free_pages>
    assert(nr_free == 3);
  104d40:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104d45:	83 f8 03             	cmp    $0x3,%eax
  104d48:	74 24                	je     104d6e <basic_check+0x31c>
  104d4a:	c7 44 24 0c 3b 70 10 	movl   $0x10703b,0xc(%esp)
  104d51:	00 
  104d52:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104d59:	00 
  104d5a:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  104d61:	00 
  104d62:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104d69:	e8 8b b6 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104d6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d75:	e8 df df ff ff       	call   102d59 <alloc_pages>
  104d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104d81:	75 24                	jne    104da7 <basic_check+0x355>
  104d83:	c7 44 24 0c 01 6f 10 	movl   $0x106f01,0xc(%esp)
  104d8a:	00 
  104d8b:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104d92:	00 
  104d93:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104d9a:	00 
  104d9b:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104da2:	e8 52 b6 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104da7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dae:	e8 a6 df ff ff       	call   102d59 <alloc_pages>
  104db3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104db6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104dba:	75 24                	jne    104de0 <basic_check+0x38e>
  104dbc:	c7 44 24 0c 1d 6f 10 	movl   $0x106f1d,0xc(%esp)
  104dc3:	00 
  104dc4:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104dcb:	00 
  104dcc:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  104dd3:	00 
  104dd4:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104ddb:	e8 19 b6 ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104de0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104de7:	e8 6d df ff ff       	call   102d59 <alloc_pages>
  104dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104def:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104df3:	75 24                	jne    104e19 <basic_check+0x3c7>
  104df5:	c7 44 24 0c 39 6f 10 	movl   $0x106f39,0xc(%esp)
  104dfc:	00 
  104dfd:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104e04:	00 
  104e05:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  104e0c:	00 
  104e0d:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104e14:	e8 e0 b5 ff ff       	call   1003f9 <__panic>

    assert(alloc_page() == NULL);
  104e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e20:	e8 34 df ff ff       	call   102d59 <alloc_pages>
  104e25:	85 c0                	test   %eax,%eax
  104e27:	74 24                	je     104e4d <basic_check+0x3fb>
  104e29:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  104e30:	00 
  104e31:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104e38:	00 
  104e39:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  104e40:	00 
  104e41:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104e48:	e8 ac b5 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104e4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e54:	00 
  104e55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e58:	89 04 24             	mov    %eax,(%esp)
  104e5b:	e8 31 df ff ff       	call   102d91 <free_pages>
  104e60:	c7 45 d8 1c bf 11 00 	movl   $0x11bf1c,-0x28(%ebp)
  104e67:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104e6a:	8b 40 04             	mov    0x4(%eax),%eax
  104e6d:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104e70:	0f 94 c0             	sete   %al
  104e73:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104e76:	85 c0                	test   %eax,%eax
  104e78:	74 24                	je     104e9e <basic_check+0x44c>
  104e7a:	c7 44 24 0c 48 70 10 	movl   $0x107048,0xc(%esp)
  104e81:	00 
  104e82:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104e89:	00 
  104e8a:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  104e91:	00 
  104e92:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104e99:	e8 5b b5 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104e9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ea5:	e8 af de ff ff       	call   102d59 <alloc_pages>
  104eaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104eb0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104eb3:	74 24                	je     104ed9 <basic_check+0x487>
  104eb5:	c7 44 24 0c 60 70 10 	movl   $0x107060,0xc(%esp)
  104ebc:	00 
  104ebd:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104ec4:	00 
  104ec5:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  104ecc:	00 
  104ecd:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104ed4:	e8 20 b5 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  104ed9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ee0:	e8 74 de ff ff       	call   102d59 <alloc_pages>
  104ee5:	85 c0                	test   %eax,%eax
  104ee7:	74 24                	je     104f0d <basic_check+0x4bb>
  104ee9:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  104ef0:	00 
  104ef1:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104ef8:	00 
  104ef9:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  104f00:	00 
  104f01:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104f08:	e8 ec b4 ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  104f0d:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  104f12:	85 c0                	test   %eax,%eax
  104f14:	74 24                	je     104f3a <basic_check+0x4e8>
  104f16:	c7 44 24 0c 79 70 10 	movl   $0x107079,0xc(%esp)
  104f1d:	00 
  104f1e:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104f25:	00 
  104f26:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  104f2d:	00 
  104f2e:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  104f35:	e8 bf b4 ff ff       	call   1003f9 <__panic>
    free_list = free_list_store;
  104f3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104f3d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104f40:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  104f45:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    nr_free = nr_free_store;
  104f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f4e:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_page(p);
  104f53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f5a:	00 
  104f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f5e:	89 04 24             	mov    %eax,(%esp)
  104f61:	e8 2b de ff ff       	call   102d91 <free_pages>
    free_page(p1);
  104f66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f6d:	00 
  104f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f71:	89 04 24             	mov    %eax,(%esp)
  104f74:	e8 18 de ff ff       	call   102d91 <free_pages>
    free_page(p2);
  104f79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104f80:	00 
  104f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f84:	89 04 24             	mov    %eax,(%esp)
  104f87:	e8 05 de ff ff       	call   102d91 <free_pages>
}
  104f8c:	90                   	nop
  104f8d:	c9                   	leave  
  104f8e:	c3                   	ret    

00104f8f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104f8f:	55                   	push   %ebp
  104f90:	89 e5                	mov    %esp,%ebp
  104f92:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104f98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104f9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104fa6:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104fad:	eb 6a                	jmp    105019 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104faf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104fb2:	83 e8 0c             	sub    $0xc,%eax
  104fb5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104fb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104fbb:	83 c0 04             	add    $0x4,%eax
  104fbe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104fc5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104fc8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104fcb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104fce:	0f a3 10             	bt     %edx,(%eax)
  104fd1:	19 c0                	sbb    %eax,%eax
  104fd3:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104fd6:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104fda:	0f 95 c0             	setne  %al
  104fdd:	0f b6 c0             	movzbl %al,%eax
  104fe0:	85 c0                	test   %eax,%eax
  104fe2:	75 24                	jne    105008 <default_check+0x79>
  104fe4:	c7 44 24 0c 86 70 10 	movl   $0x107086,0xc(%esp)
  104feb:	00 
  104fec:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  104ff3:	00 
  104ff4:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  104ffb:	00 
  104ffc:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  105003:	e8 f1 b3 ff ff       	call   1003f9 <__panic>
        count ++, total += p->property;
  105008:	ff 45 f4             	incl   -0xc(%ebp)
  10500b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10500e:	8b 50 08             	mov    0x8(%eax),%edx
  105011:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105014:	01 d0                	add    %edx,%eax
  105016:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105019:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10501c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  10501f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105022:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105025:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105028:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  10502f:	0f 85 7a ff ff ff    	jne    104faf <default_check+0x20>
    }
    assert(total == nr_free_pages());
  105035:	e8 8a dd ff ff       	call   102dc4 <nr_free_pages>
  10503a:	89 c2                	mov    %eax,%edx
  10503c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10503f:	39 c2                	cmp    %eax,%edx
  105041:	74 24                	je     105067 <default_check+0xd8>
  105043:	c7 44 24 0c 96 70 10 	movl   $0x107096,0xc(%esp)
  10504a:	00 
  10504b:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  105052:	00 
  105053:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  10505a:	00 
  10505b:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  105062:	e8 92 b3 ff ff       	call   1003f9 <__panic>

    basic_check();
  105067:	e8 e6 f9 ff ff       	call   104a52 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10506c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105073:	e8 e1 dc ff ff       	call   102d59 <alloc_pages>
  105078:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  10507b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10507f:	75 24                	jne    1050a5 <default_check+0x116>
  105081:	c7 44 24 0c af 70 10 	movl   $0x1070af,0xc(%esp)
  105088:	00 
  105089:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  105090:	00 
  105091:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  105098:	00 
  105099:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1050a0:	e8 54 b3 ff ff       	call   1003f9 <__panic>
    assert(!PageProperty(p0));
  1050a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050a8:	83 c0 04             	add    $0x4,%eax
  1050ab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1050b2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1050b5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1050b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1050bb:	0f a3 10             	bt     %edx,(%eax)
  1050be:	19 c0                	sbb    %eax,%eax
  1050c0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1050c3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1050c7:	0f 95 c0             	setne  %al
  1050ca:	0f b6 c0             	movzbl %al,%eax
  1050cd:	85 c0                	test   %eax,%eax
  1050cf:	74 24                	je     1050f5 <default_check+0x166>
  1050d1:	c7 44 24 0c ba 70 10 	movl   $0x1070ba,0xc(%esp)
  1050d8:	00 
  1050d9:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1050e0:	00 
  1050e1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  1050e8:	00 
  1050e9:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1050f0:	e8 04 b3 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  1050f5:	a1 1c bf 11 00       	mov    0x11bf1c,%eax
  1050fa:	8b 15 20 bf 11 00    	mov    0x11bf20,%edx
  105100:	89 45 80             	mov    %eax,-0x80(%ebp)
  105103:	89 55 84             	mov    %edx,-0x7c(%ebp)
  105106:	c7 45 b0 1c bf 11 00 	movl   $0x11bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  10510d:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105110:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105113:	89 50 04             	mov    %edx,0x4(%eax)
  105116:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105119:	8b 50 04             	mov    0x4(%eax),%edx
  10511c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10511f:	89 10                	mov    %edx,(%eax)
  105121:	c7 45 b4 1c bf 11 00 	movl   $0x11bf1c,-0x4c(%ebp)
    return list->next == list;
  105128:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10512b:	8b 40 04             	mov    0x4(%eax),%eax
  10512e:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  105131:	0f 94 c0             	sete   %al
  105134:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105137:	85 c0                	test   %eax,%eax
  105139:	75 24                	jne    10515f <default_check+0x1d0>
  10513b:	c7 44 24 0c 0f 70 10 	movl   $0x10700f,0xc(%esp)
  105142:	00 
  105143:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10514a:	00 
  10514b:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  105152:	00 
  105153:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10515a:	e8 9a b2 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  10515f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105166:	e8 ee db ff ff       	call   102d59 <alloc_pages>
  10516b:	85 c0                	test   %eax,%eax
  10516d:	74 24                	je     105193 <default_check+0x204>
  10516f:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  105176:	00 
  105177:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10517e:	00 
  10517f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  105186:	00 
  105187:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10518e:	e8 66 b2 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  105193:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  105198:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  10519b:	c7 05 24 bf 11 00 00 	movl   $0x0,0x11bf24
  1051a2:	00 00 00 

    free_pages(p0 + 2, 3);
  1051a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051a8:	83 c0 28             	add    $0x28,%eax
  1051ab:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1051b2:	00 
  1051b3:	89 04 24             	mov    %eax,(%esp)
  1051b6:	e8 d6 db ff ff       	call   102d91 <free_pages>
    assert(alloc_pages(4) == NULL);
  1051bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1051c2:	e8 92 db ff ff       	call   102d59 <alloc_pages>
  1051c7:	85 c0                	test   %eax,%eax
  1051c9:	74 24                	je     1051ef <default_check+0x260>
  1051cb:	c7 44 24 0c cc 70 10 	movl   $0x1070cc,0xc(%esp)
  1051d2:	00 
  1051d3:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1051da:	00 
  1051db:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1051e2:	00 
  1051e3:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1051ea:	e8 0a b2 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1051ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051f2:	83 c0 28             	add    $0x28,%eax
  1051f5:	83 c0 04             	add    $0x4,%eax
  1051f8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1051ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105202:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105205:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105208:	0f a3 10             	bt     %edx,(%eax)
  10520b:	19 c0                	sbb    %eax,%eax
  10520d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  105210:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105214:	0f 95 c0             	setne  %al
  105217:	0f b6 c0             	movzbl %al,%eax
  10521a:	85 c0                	test   %eax,%eax
  10521c:	74 0e                	je     10522c <default_check+0x29d>
  10521e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105221:	83 c0 28             	add    $0x28,%eax
  105224:	8b 40 08             	mov    0x8(%eax),%eax
  105227:	83 f8 03             	cmp    $0x3,%eax
  10522a:	74 24                	je     105250 <default_check+0x2c1>
  10522c:	c7 44 24 0c e4 70 10 	movl   $0x1070e4,0xc(%esp)
  105233:	00 
  105234:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10523b:	00 
  10523c:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  105243:	00 
  105244:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10524b:	e8 a9 b1 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105250:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105257:	e8 fd da ff ff       	call   102d59 <alloc_pages>
  10525c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10525f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105263:	75 24                	jne    105289 <default_check+0x2fa>
  105265:	c7 44 24 0c 10 71 10 	movl   $0x107110,0xc(%esp)
  10526c:	00 
  10526d:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  105274:	00 
  105275:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10527c:	00 
  10527d:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  105284:	e8 70 b1 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105289:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105290:	e8 c4 da ff ff       	call   102d59 <alloc_pages>
  105295:	85 c0                	test   %eax,%eax
  105297:	74 24                	je     1052bd <default_check+0x32e>
  105299:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  1052a0:	00 
  1052a1:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1052a8:	00 
  1052a9:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  1052b0:	00 
  1052b1:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1052b8:	e8 3c b1 ff ff       	call   1003f9 <__panic>
    assert(p0 + 2 == p1);
  1052bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052c0:	83 c0 28             	add    $0x28,%eax
  1052c3:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1052c6:	74 24                	je     1052ec <default_check+0x35d>
  1052c8:	c7 44 24 0c 2e 71 10 	movl   $0x10712e,0xc(%esp)
  1052cf:	00 
  1052d0:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1052d7:	00 
  1052d8:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  1052df:	00 
  1052e0:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1052e7:	e8 0d b1 ff ff       	call   1003f9 <__panic>

    p2 = p0 + 1;
  1052ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052ef:	83 c0 14             	add    $0x14,%eax
  1052f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1052f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052fc:	00 
  1052fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105300:	89 04 24             	mov    %eax,(%esp)
  105303:	e8 89 da ff ff       	call   102d91 <free_pages>
    free_pages(p1, 3);
  105308:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10530f:	00 
  105310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105313:	89 04 24             	mov    %eax,(%esp)
  105316:	e8 76 da ff ff       	call   102d91 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10531b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10531e:	83 c0 04             	add    $0x4,%eax
  105321:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105328:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10532b:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10532e:	8b 55 a0             	mov    -0x60(%ebp),%edx
  105331:	0f a3 10             	bt     %edx,(%eax)
  105334:	19 c0                	sbb    %eax,%eax
  105336:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105339:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  10533d:	0f 95 c0             	setne  %al
  105340:	0f b6 c0             	movzbl %al,%eax
  105343:	85 c0                	test   %eax,%eax
  105345:	74 0b                	je     105352 <default_check+0x3c3>
  105347:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10534a:	8b 40 08             	mov    0x8(%eax),%eax
  10534d:	83 f8 01             	cmp    $0x1,%eax
  105350:	74 24                	je     105376 <default_check+0x3e7>
  105352:	c7 44 24 0c 3c 71 10 	movl   $0x10713c,0xc(%esp)
  105359:	00 
  10535a:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  105361:	00 
  105362:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  105369:	00 
  10536a:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  105371:	e8 83 b0 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105379:	83 c0 04             	add    $0x4,%eax
  10537c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105383:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105386:	8b 45 90             	mov    -0x70(%ebp),%eax
  105389:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10538c:	0f a3 10             	bt     %edx,(%eax)
  10538f:	19 c0                	sbb    %eax,%eax
  105391:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105394:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105398:	0f 95 c0             	setne  %al
  10539b:	0f b6 c0             	movzbl %al,%eax
  10539e:	85 c0                	test   %eax,%eax
  1053a0:	74 0b                	je     1053ad <default_check+0x41e>
  1053a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053a5:	8b 40 08             	mov    0x8(%eax),%eax
  1053a8:	83 f8 03             	cmp    $0x3,%eax
  1053ab:	74 24                	je     1053d1 <default_check+0x442>
  1053ad:	c7 44 24 0c 64 71 10 	movl   $0x107164,0xc(%esp)
  1053b4:	00 
  1053b5:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1053bc:	00 
  1053bd:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  1053c4:	00 
  1053c5:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1053cc:	e8 28 b0 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1053d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1053d8:	e8 7c d9 ff ff       	call   102d59 <alloc_pages>
  1053dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1053e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053e3:	83 e8 14             	sub    $0x14,%eax
  1053e6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1053e9:	74 24                	je     10540f <default_check+0x480>
  1053eb:	c7 44 24 0c 8a 71 10 	movl   $0x10718a,0xc(%esp)
  1053f2:	00 
  1053f3:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1053fa:	00 
  1053fb:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  105402:	00 
  105403:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10540a:	e8 ea af ff ff       	call   1003f9 <__panic>
    free_page(p0);
  10540f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105416:	00 
  105417:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10541a:	89 04 24             	mov    %eax,(%esp)
  10541d:	e8 6f d9 ff ff       	call   102d91 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105422:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105429:	e8 2b d9 ff ff       	call   102d59 <alloc_pages>
  10542e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105431:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105434:	83 c0 14             	add    $0x14,%eax
  105437:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10543a:	74 24                	je     105460 <default_check+0x4d1>
  10543c:	c7 44 24 0c a8 71 10 	movl   $0x1071a8,0xc(%esp)
  105443:	00 
  105444:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10544b:	00 
  10544c:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  105453:	00 
  105454:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10545b:	e8 99 af ff ff       	call   1003f9 <__panic>

    free_pages(p0, 2);
  105460:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105467:	00 
  105468:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10546b:	89 04 24             	mov    %eax,(%esp)
  10546e:	e8 1e d9 ff ff       	call   102d91 <free_pages>
    free_page(p2);
  105473:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10547a:	00 
  10547b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10547e:	89 04 24             	mov    %eax,(%esp)
  105481:	e8 0b d9 ff ff       	call   102d91 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105486:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10548d:	e8 c7 d8 ff ff       	call   102d59 <alloc_pages>
  105492:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105495:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105499:	75 24                	jne    1054bf <default_check+0x530>
  10549b:	c7 44 24 0c c8 71 10 	movl   $0x1071c8,0xc(%esp)
  1054a2:	00 
  1054a3:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1054aa:	00 
  1054ab:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  1054b2:	00 
  1054b3:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1054ba:	e8 3a af ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  1054bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1054c6:	e8 8e d8 ff ff       	call   102d59 <alloc_pages>
  1054cb:	85 c0                	test   %eax,%eax
  1054cd:	74 24                	je     1054f3 <default_check+0x564>
  1054cf:	c7 44 24 0c 26 70 10 	movl   $0x107026,0xc(%esp)
  1054d6:	00 
  1054d7:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1054de:	00 
  1054df:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  1054e6:	00 
  1054e7:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1054ee:	e8 06 af ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  1054f3:	a1 24 bf 11 00       	mov    0x11bf24,%eax
  1054f8:	85 c0                	test   %eax,%eax
  1054fa:	74 24                	je     105520 <default_check+0x591>
  1054fc:	c7 44 24 0c 79 70 10 	movl   $0x107079,0xc(%esp)
  105503:	00 
  105504:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10550b:	00 
  10550c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  105513:	00 
  105514:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  10551b:	e8 d9 ae ff ff       	call   1003f9 <__panic>
    nr_free = nr_free_store;
  105520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105523:	a3 24 bf 11 00       	mov    %eax,0x11bf24

    free_list = free_list_store;
  105528:	8b 45 80             	mov    -0x80(%ebp),%eax
  10552b:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10552e:	a3 1c bf 11 00       	mov    %eax,0x11bf1c
  105533:	89 15 20 bf 11 00    	mov    %edx,0x11bf20
    free_pages(p0, 5);
  105539:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105540:	00 
  105541:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105544:	89 04 24             	mov    %eax,(%esp)
  105547:	e8 45 d8 ff ff       	call   102d91 <free_pages>

    le = &free_list;
  10554c:	c7 45 ec 1c bf 11 00 	movl   $0x11bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105553:	eb 1c                	jmp    105571 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
  105555:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105558:	83 e8 0c             	sub    $0xc,%eax
  10555b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  10555e:	ff 4d f4             	decl   -0xc(%ebp)
  105561:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105567:	8b 40 08             	mov    0x8(%eax),%eax
  10556a:	29 c2                	sub    %eax,%edx
  10556c:	89 d0                	mov    %edx,%eax
  10556e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105571:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105574:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105577:	8b 45 88             	mov    -0x78(%ebp),%eax
  10557a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10557d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105580:	81 7d ec 1c bf 11 00 	cmpl   $0x11bf1c,-0x14(%ebp)
  105587:	75 cc                	jne    105555 <default_check+0x5c6>
    }
    assert(count == 0);
  105589:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10558d:	74 24                	je     1055b3 <default_check+0x624>
  10558f:	c7 44 24 0c e6 71 10 	movl   $0x1071e6,0xc(%esp)
  105596:	00 
  105597:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  10559e:	00 
  10559f:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  1055a6:	00 
  1055a7:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1055ae:	e8 46 ae ff ff       	call   1003f9 <__panic>
    assert(total == 0);
  1055b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1055b7:	74 24                	je     1055dd <default_check+0x64e>
  1055b9:	c7 44 24 0c f1 71 10 	movl   $0x1071f1,0xc(%esp)
  1055c0:	00 
  1055c1:	c7 44 24 08 9e 6e 10 	movl   $0x106e9e,0x8(%esp)
  1055c8:	00 
  1055c9:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  1055d0:	00 
  1055d1:	c7 04 24 b3 6e 10 00 	movl   $0x106eb3,(%esp)
  1055d8:	e8 1c ae ff ff       	call   1003f9 <__panic>
}
  1055dd:	90                   	nop
  1055de:	c9                   	leave  
  1055df:	c3                   	ret    

001055e0 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1055e0:	55                   	push   %ebp
  1055e1:	89 e5                	mov    %esp,%ebp
  1055e3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1055e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1055ed:	eb 03                	jmp    1055f2 <strlen+0x12>
        cnt ++;
  1055ef:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1055f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f5:	8d 50 01             	lea    0x1(%eax),%edx
  1055f8:	89 55 08             	mov    %edx,0x8(%ebp)
  1055fb:	0f b6 00             	movzbl (%eax),%eax
  1055fe:	84 c0                	test   %al,%al
  105600:	75 ed                	jne    1055ef <strlen+0xf>
    }
    return cnt;
  105602:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105605:	c9                   	leave  
  105606:	c3                   	ret    

00105607 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105607:	55                   	push   %ebp
  105608:	89 e5                	mov    %esp,%ebp
  10560a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10560d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105614:	eb 03                	jmp    105619 <strnlen+0x12>
        cnt ++;
  105616:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105619:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10561c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10561f:	73 10                	jae    105631 <strnlen+0x2a>
  105621:	8b 45 08             	mov    0x8(%ebp),%eax
  105624:	8d 50 01             	lea    0x1(%eax),%edx
  105627:	89 55 08             	mov    %edx,0x8(%ebp)
  10562a:	0f b6 00             	movzbl (%eax),%eax
  10562d:	84 c0                	test   %al,%al
  10562f:	75 e5                	jne    105616 <strnlen+0xf>
    }
    return cnt;
  105631:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105634:	c9                   	leave  
  105635:	c3                   	ret    

00105636 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105636:	55                   	push   %ebp
  105637:	89 e5                	mov    %esp,%ebp
  105639:	57                   	push   %edi
  10563a:	56                   	push   %esi
  10563b:	83 ec 20             	sub    $0x20,%esp
  10563e:	8b 45 08             	mov    0x8(%ebp),%eax
  105641:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105644:	8b 45 0c             	mov    0xc(%ebp),%eax
  105647:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10564a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105650:	89 d1                	mov    %edx,%ecx
  105652:	89 c2                	mov    %eax,%edx
  105654:	89 ce                	mov    %ecx,%esi
  105656:	89 d7                	mov    %edx,%edi
  105658:	ac                   	lods   %ds:(%esi),%al
  105659:	aa                   	stos   %al,%es:(%edi)
  10565a:	84 c0                	test   %al,%al
  10565c:	75 fa                	jne    105658 <strcpy+0x22>
  10565e:	89 fa                	mov    %edi,%edx
  105660:	89 f1                	mov    %esi,%ecx
  105662:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105665:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105668:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  10566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  10566e:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10566f:	83 c4 20             	add    $0x20,%esp
  105672:	5e                   	pop    %esi
  105673:	5f                   	pop    %edi
  105674:	5d                   	pop    %ebp
  105675:	c3                   	ret    

00105676 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105676:	55                   	push   %ebp
  105677:	89 e5                	mov    %esp,%ebp
  105679:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  10567c:	8b 45 08             	mov    0x8(%ebp),%eax
  10567f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105682:	eb 1e                	jmp    1056a2 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105684:	8b 45 0c             	mov    0xc(%ebp),%eax
  105687:	0f b6 10             	movzbl (%eax),%edx
  10568a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10568d:	88 10                	mov    %dl,(%eax)
  10568f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105692:	0f b6 00             	movzbl (%eax),%eax
  105695:	84 c0                	test   %al,%al
  105697:	74 03                	je     10569c <strncpy+0x26>
            src ++;
  105699:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10569c:	ff 45 fc             	incl   -0x4(%ebp)
  10569f:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  1056a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1056a6:	75 dc                	jne    105684 <strncpy+0xe>
    }
    return dst;
  1056a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1056ab:	c9                   	leave  
  1056ac:	c3                   	ret    

001056ad <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1056ad:	55                   	push   %ebp
  1056ae:	89 e5                	mov    %esp,%ebp
  1056b0:	57                   	push   %edi
  1056b1:	56                   	push   %esi
  1056b2:	83 ec 20             	sub    $0x20,%esp
  1056b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1056b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1056c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1056c7:	89 d1                	mov    %edx,%ecx
  1056c9:	89 c2                	mov    %eax,%edx
  1056cb:	89 ce                	mov    %ecx,%esi
  1056cd:	89 d7                	mov    %edx,%edi
  1056cf:	ac                   	lods   %ds:(%esi),%al
  1056d0:	ae                   	scas   %es:(%edi),%al
  1056d1:	75 08                	jne    1056db <strcmp+0x2e>
  1056d3:	84 c0                	test   %al,%al
  1056d5:	75 f8                	jne    1056cf <strcmp+0x22>
  1056d7:	31 c0                	xor    %eax,%eax
  1056d9:	eb 04                	jmp    1056df <strcmp+0x32>
  1056db:	19 c0                	sbb    %eax,%eax
  1056dd:	0c 01                	or     $0x1,%al
  1056df:	89 fa                	mov    %edi,%edx
  1056e1:	89 f1                	mov    %esi,%ecx
  1056e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1056e6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1056e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1056ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1056ef:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1056f0:	83 c4 20             	add    $0x20,%esp
  1056f3:	5e                   	pop    %esi
  1056f4:	5f                   	pop    %edi
  1056f5:	5d                   	pop    %ebp
  1056f6:	c3                   	ret    

001056f7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1056f7:	55                   	push   %ebp
  1056f8:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1056fa:	eb 09                	jmp    105705 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1056fc:	ff 4d 10             	decl   0x10(%ebp)
  1056ff:	ff 45 08             	incl   0x8(%ebp)
  105702:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105705:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105709:	74 1a                	je     105725 <strncmp+0x2e>
  10570b:	8b 45 08             	mov    0x8(%ebp),%eax
  10570e:	0f b6 00             	movzbl (%eax),%eax
  105711:	84 c0                	test   %al,%al
  105713:	74 10                	je     105725 <strncmp+0x2e>
  105715:	8b 45 08             	mov    0x8(%ebp),%eax
  105718:	0f b6 10             	movzbl (%eax),%edx
  10571b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10571e:	0f b6 00             	movzbl (%eax),%eax
  105721:	38 c2                	cmp    %al,%dl
  105723:	74 d7                	je     1056fc <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105725:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105729:	74 18                	je     105743 <strncmp+0x4c>
  10572b:	8b 45 08             	mov    0x8(%ebp),%eax
  10572e:	0f b6 00             	movzbl (%eax),%eax
  105731:	0f b6 d0             	movzbl %al,%edx
  105734:	8b 45 0c             	mov    0xc(%ebp),%eax
  105737:	0f b6 00             	movzbl (%eax),%eax
  10573a:	0f b6 c0             	movzbl %al,%eax
  10573d:	29 c2                	sub    %eax,%edx
  10573f:	89 d0                	mov    %edx,%eax
  105741:	eb 05                	jmp    105748 <strncmp+0x51>
  105743:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105748:	5d                   	pop    %ebp
  105749:	c3                   	ret    

0010574a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10574a:	55                   	push   %ebp
  10574b:	89 e5                	mov    %esp,%ebp
  10574d:	83 ec 04             	sub    $0x4,%esp
  105750:	8b 45 0c             	mov    0xc(%ebp),%eax
  105753:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105756:	eb 13                	jmp    10576b <strchr+0x21>
        if (*s == c) {
  105758:	8b 45 08             	mov    0x8(%ebp),%eax
  10575b:	0f b6 00             	movzbl (%eax),%eax
  10575e:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105761:	75 05                	jne    105768 <strchr+0x1e>
            return (char *)s;
  105763:	8b 45 08             	mov    0x8(%ebp),%eax
  105766:	eb 12                	jmp    10577a <strchr+0x30>
        }
        s ++;
  105768:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  10576b:	8b 45 08             	mov    0x8(%ebp),%eax
  10576e:	0f b6 00             	movzbl (%eax),%eax
  105771:	84 c0                	test   %al,%al
  105773:	75 e3                	jne    105758 <strchr+0xe>
    }
    return NULL;
  105775:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10577a:	c9                   	leave  
  10577b:	c3                   	ret    

0010577c <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10577c:	55                   	push   %ebp
  10577d:	89 e5                	mov    %esp,%ebp
  10577f:	83 ec 04             	sub    $0x4,%esp
  105782:	8b 45 0c             	mov    0xc(%ebp),%eax
  105785:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105788:	eb 0e                	jmp    105798 <strfind+0x1c>
        if (*s == c) {
  10578a:	8b 45 08             	mov    0x8(%ebp),%eax
  10578d:	0f b6 00             	movzbl (%eax),%eax
  105790:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105793:	74 0f                	je     1057a4 <strfind+0x28>
            break;
        }
        s ++;
  105795:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105798:	8b 45 08             	mov    0x8(%ebp),%eax
  10579b:	0f b6 00             	movzbl (%eax),%eax
  10579e:	84 c0                	test   %al,%al
  1057a0:	75 e8                	jne    10578a <strfind+0xe>
  1057a2:	eb 01                	jmp    1057a5 <strfind+0x29>
            break;
  1057a4:	90                   	nop
    }
    return (char *)s;
  1057a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1057a8:	c9                   	leave  
  1057a9:	c3                   	ret    

001057aa <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1057aa:	55                   	push   %ebp
  1057ab:	89 e5                	mov    %esp,%ebp
  1057ad:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1057b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1057b7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1057be:	eb 03                	jmp    1057c3 <strtol+0x19>
        s ++;
  1057c0:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1057c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1057c6:	0f b6 00             	movzbl (%eax),%eax
  1057c9:	3c 20                	cmp    $0x20,%al
  1057cb:	74 f3                	je     1057c0 <strtol+0x16>
  1057cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d0:	0f b6 00             	movzbl (%eax),%eax
  1057d3:	3c 09                	cmp    $0x9,%al
  1057d5:	74 e9                	je     1057c0 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1057d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1057da:	0f b6 00             	movzbl (%eax),%eax
  1057dd:	3c 2b                	cmp    $0x2b,%al
  1057df:	75 05                	jne    1057e6 <strtol+0x3c>
        s ++;
  1057e1:	ff 45 08             	incl   0x8(%ebp)
  1057e4:	eb 14                	jmp    1057fa <strtol+0x50>
    }
    else if (*s == '-') {
  1057e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e9:	0f b6 00             	movzbl (%eax),%eax
  1057ec:	3c 2d                	cmp    $0x2d,%al
  1057ee:	75 0a                	jne    1057fa <strtol+0x50>
        s ++, neg = 1;
  1057f0:	ff 45 08             	incl   0x8(%ebp)
  1057f3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1057fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1057fe:	74 06                	je     105806 <strtol+0x5c>
  105800:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105804:	75 22                	jne    105828 <strtol+0x7e>
  105806:	8b 45 08             	mov    0x8(%ebp),%eax
  105809:	0f b6 00             	movzbl (%eax),%eax
  10580c:	3c 30                	cmp    $0x30,%al
  10580e:	75 18                	jne    105828 <strtol+0x7e>
  105810:	8b 45 08             	mov    0x8(%ebp),%eax
  105813:	40                   	inc    %eax
  105814:	0f b6 00             	movzbl (%eax),%eax
  105817:	3c 78                	cmp    $0x78,%al
  105819:	75 0d                	jne    105828 <strtol+0x7e>
        s += 2, base = 16;
  10581b:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10581f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105826:	eb 29                	jmp    105851 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105828:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10582c:	75 16                	jne    105844 <strtol+0x9a>
  10582e:	8b 45 08             	mov    0x8(%ebp),%eax
  105831:	0f b6 00             	movzbl (%eax),%eax
  105834:	3c 30                	cmp    $0x30,%al
  105836:	75 0c                	jne    105844 <strtol+0x9a>
        s ++, base = 8;
  105838:	ff 45 08             	incl   0x8(%ebp)
  10583b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105842:	eb 0d                	jmp    105851 <strtol+0xa7>
    }
    else if (base == 0) {
  105844:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105848:	75 07                	jne    105851 <strtol+0xa7>
        base = 10;
  10584a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105851:	8b 45 08             	mov    0x8(%ebp),%eax
  105854:	0f b6 00             	movzbl (%eax),%eax
  105857:	3c 2f                	cmp    $0x2f,%al
  105859:	7e 1b                	jle    105876 <strtol+0xcc>
  10585b:	8b 45 08             	mov    0x8(%ebp),%eax
  10585e:	0f b6 00             	movzbl (%eax),%eax
  105861:	3c 39                	cmp    $0x39,%al
  105863:	7f 11                	jg     105876 <strtol+0xcc>
            dig = *s - '0';
  105865:	8b 45 08             	mov    0x8(%ebp),%eax
  105868:	0f b6 00             	movzbl (%eax),%eax
  10586b:	0f be c0             	movsbl %al,%eax
  10586e:	83 e8 30             	sub    $0x30,%eax
  105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105874:	eb 48                	jmp    1058be <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105876:	8b 45 08             	mov    0x8(%ebp),%eax
  105879:	0f b6 00             	movzbl (%eax),%eax
  10587c:	3c 60                	cmp    $0x60,%al
  10587e:	7e 1b                	jle    10589b <strtol+0xf1>
  105880:	8b 45 08             	mov    0x8(%ebp),%eax
  105883:	0f b6 00             	movzbl (%eax),%eax
  105886:	3c 7a                	cmp    $0x7a,%al
  105888:	7f 11                	jg     10589b <strtol+0xf1>
            dig = *s - 'a' + 10;
  10588a:	8b 45 08             	mov    0x8(%ebp),%eax
  10588d:	0f b6 00             	movzbl (%eax),%eax
  105890:	0f be c0             	movsbl %al,%eax
  105893:	83 e8 57             	sub    $0x57,%eax
  105896:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105899:	eb 23                	jmp    1058be <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10589b:	8b 45 08             	mov    0x8(%ebp),%eax
  10589e:	0f b6 00             	movzbl (%eax),%eax
  1058a1:	3c 40                	cmp    $0x40,%al
  1058a3:	7e 3b                	jle    1058e0 <strtol+0x136>
  1058a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a8:	0f b6 00             	movzbl (%eax),%eax
  1058ab:	3c 5a                	cmp    $0x5a,%al
  1058ad:	7f 31                	jg     1058e0 <strtol+0x136>
            dig = *s - 'A' + 10;
  1058af:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b2:	0f b6 00             	movzbl (%eax),%eax
  1058b5:	0f be c0             	movsbl %al,%eax
  1058b8:	83 e8 37             	sub    $0x37,%eax
  1058bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1058be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058c1:	3b 45 10             	cmp    0x10(%ebp),%eax
  1058c4:	7d 19                	jge    1058df <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1058c6:	ff 45 08             	incl   0x8(%ebp)
  1058c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058cc:	0f af 45 10          	imul   0x10(%ebp),%eax
  1058d0:	89 c2                	mov    %eax,%edx
  1058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1058d5:	01 d0                	add    %edx,%eax
  1058d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1058da:	e9 72 ff ff ff       	jmp    105851 <strtol+0xa7>
            break;
  1058df:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1058e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1058e4:	74 08                	je     1058ee <strtol+0x144>
        *endptr = (char *) s;
  1058e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058e9:	8b 55 08             	mov    0x8(%ebp),%edx
  1058ec:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1058ee:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1058f2:	74 07                	je     1058fb <strtol+0x151>
  1058f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1058f7:	f7 d8                	neg    %eax
  1058f9:	eb 03                	jmp    1058fe <strtol+0x154>
  1058fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1058fe:	c9                   	leave  
  1058ff:	c3                   	ret    

00105900 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105900:	55                   	push   %ebp
  105901:	89 e5                	mov    %esp,%ebp
  105903:	57                   	push   %edi
  105904:	83 ec 24             	sub    $0x24,%esp
  105907:	8b 45 0c             	mov    0xc(%ebp),%eax
  10590a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10590d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105911:	8b 55 08             	mov    0x8(%ebp),%edx
  105914:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105917:	88 45 f7             	mov    %al,-0x9(%ebp)
  10591a:	8b 45 10             	mov    0x10(%ebp),%eax
  10591d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105920:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105923:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105927:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10592a:	89 d7                	mov    %edx,%edi
  10592c:	f3 aa                	rep stos %al,%es:(%edi)
  10592e:	89 fa                	mov    %edi,%edx
  105930:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105933:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105936:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105939:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  10593a:	83 c4 24             	add    $0x24,%esp
  10593d:	5f                   	pop    %edi
  10593e:	5d                   	pop    %ebp
  10593f:	c3                   	ret    

00105940 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105940:	55                   	push   %ebp
  105941:	89 e5                	mov    %esp,%ebp
  105943:	57                   	push   %edi
  105944:	56                   	push   %esi
  105945:	53                   	push   %ebx
  105946:	83 ec 30             	sub    $0x30,%esp
  105949:	8b 45 08             	mov    0x8(%ebp),%eax
  10594c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10594f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105952:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105955:	8b 45 10             	mov    0x10(%ebp),%eax
  105958:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  10595b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10595e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105961:	73 42                	jae    1059a5 <memmove+0x65>
  105963:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105969:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10596c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10596f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105972:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105975:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105978:	c1 e8 02             	shr    $0x2,%eax
  10597b:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10597d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105980:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105983:	89 d7                	mov    %edx,%edi
  105985:	89 c6                	mov    %eax,%esi
  105987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105989:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10598c:	83 e1 03             	and    $0x3,%ecx
  10598f:	74 02                	je     105993 <memmove+0x53>
  105991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105993:	89 f0                	mov    %esi,%eax
  105995:	89 fa                	mov    %edi,%edx
  105997:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10599a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10599d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  1059a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  1059a3:	eb 36                	jmp    1059db <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1059a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059a8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1059ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1059ae:	01 c2                	add    %eax,%edx
  1059b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059b3:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1059b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059b9:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1059bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1059bf:	89 c1                	mov    %eax,%ecx
  1059c1:	89 d8                	mov    %ebx,%eax
  1059c3:	89 d6                	mov    %edx,%esi
  1059c5:	89 c7                	mov    %eax,%edi
  1059c7:	fd                   	std    
  1059c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1059ca:	fc                   	cld    
  1059cb:	89 f8                	mov    %edi,%eax
  1059cd:	89 f2                	mov    %esi,%edx
  1059cf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1059d2:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1059d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1059db:	83 c4 30             	add    $0x30,%esp
  1059de:	5b                   	pop    %ebx
  1059df:	5e                   	pop    %esi
  1059e0:	5f                   	pop    %edi
  1059e1:	5d                   	pop    %ebp
  1059e2:	c3                   	ret    

001059e3 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1059e3:	55                   	push   %ebp
  1059e4:	89 e5                	mov    %esp,%ebp
  1059e6:	57                   	push   %edi
  1059e7:	56                   	push   %esi
  1059e8:	83 ec 20             	sub    $0x20,%esp
  1059eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1059fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1059fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a00:	c1 e8 02             	shr    $0x2,%eax
  105a03:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105a05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a0b:	89 d7                	mov    %edx,%edi
  105a0d:	89 c6                	mov    %eax,%esi
  105a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105a11:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105a14:	83 e1 03             	and    $0x3,%ecx
  105a17:	74 02                	je     105a1b <memcpy+0x38>
  105a19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105a1b:	89 f0                	mov    %esi,%eax
  105a1d:	89 fa                	mov    %edi,%edx
  105a1f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105a22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105a25:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105a2b:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105a2c:	83 c4 20             	add    $0x20,%esp
  105a2f:	5e                   	pop    %esi
  105a30:	5f                   	pop    %edi
  105a31:	5d                   	pop    %ebp
  105a32:	c3                   	ret    

00105a33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105a33:	55                   	push   %ebp
  105a34:	89 e5                	mov    %esp,%ebp
  105a36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105a39:	8b 45 08             	mov    0x8(%ebp),%eax
  105a3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105a45:	eb 2e                	jmp    105a75 <memcmp+0x42>
        if (*s1 != *s2) {
  105a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a4a:	0f b6 10             	movzbl (%eax),%edx
  105a4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a50:	0f b6 00             	movzbl (%eax),%eax
  105a53:	38 c2                	cmp    %al,%dl
  105a55:	74 18                	je     105a6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a5a:	0f b6 00             	movzbl (%eax),%eax
  105a5d:	0f b6 d0             	movzbl %al,%edx
  105a60:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105a63:	0f b6 00             	movzbl (%eax),%eax
  105a66:	0f b6 c0             	movzbl %al,%eax
  105a69:	29 c2                	sub    %eax,%edx
  105a6b:	89 d0                	mov    %edx,%eax
  105a6d:	eb 18                	jmp    105a87 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105a6f:	ff 45 fc             	incl   -0x4(%ebp)
  105a72:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105a75:	8b 45 10             	mov    0x10(%ebp),%eax
  105a78:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a7b:	89 55 10             	mov    %edx,0x10(%ebp)
  105a7e:	85 c0                	test   %eax,%eax
  105a80:	75 c5                	jne    105a47 <memcmp+0x14>
    }
    return 0;
  105a82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a87:	c9                   	leave  
  105a88:	c3                   	ret    

00105a89 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105a89:	55                   	push   %ebp
  105a8a:	89 e5                	mov    %esp,%ebp
  105a8c:	83 ec 58             	sub    $0x58,%esp
  105a8f:	8b 45 10             	mov    0x10(%ebp),%eax
  105a92:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105a95:	8b 45 14             	mov    0x14(%ebp),%eax
  105a98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105a9b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105a9e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105aa1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105aa4:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105aa7:	8b 45 18             	mov    0x18(%ebp),%eax
  105aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105aad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ab0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105ab3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105ab6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105abf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105ac3:	74 1c                	je     105ae1 <printnum+0x58>
  105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  105acd:	f7 75 e4             	divl   -0x1c(%ebp)
  105ad0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  105adb:	f7 75 e4             	divl   -0x1c(%ebp)
  105ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ae7:	f7 75 e4             	divl   -0x1c(%ebp)
  105aea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105aed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105af6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105af9:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105afc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105aff:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105b02:	8b 45 18             	mov    0x18(%ebp),%eax
  105b05:	ba 00 00 00 00       	mov    $0x0,%edx
  105b0a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105b0d:	72 56                	jb     105b65 <printnum+0xdc>
  105b0f:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  105b12:	77 05                	ja     105b19 <printnum+0x90>
  105b14:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105b17:	72 4c                	jb     105b65 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105b19:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105b1c:	8d 50 ff             	lea    -0x1(%eax),%edx
  105b1f:	8b 45 20             	mov    0x20(%ebp),%eax
  105b22:	89 44 24 18          	mov    %eax,0x18(%esp)
  105b26:	89 54 24 14          	mov    %edx,0x14(%esp)
  105b2a:	8b 45 18             	mov    0x18(%ebp),%eax
  105b2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  105b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b34:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b46:	8b 45 08             	mov    0x8(%ebp),%eax
  105b49:	89 04 24             	mov    %eax,(%esp)
  105b4c:	e8 38 ff ff ff       	call   105a89 <printnum>
  105b51:	eb 1b                	jmp    105b6e <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b5a:	8b 45 20             	mov    0x20(%ebp),%eax
  105b5d:	89 04 24             	mov    %eax,(%esp)
  105b60:	8b 45 08             	mov    0x8(%ebp),%eax
  105b63:	ff d0                	call   *%eax
        while (-- width > 0)
  105b65:	ff 4d 1c             	decl   0x1c(%ebp)
  105b68:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105b6c:	7f e5                	jg     105b53 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105b6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105b71:	05 ac 72 10 00       	add    $0x1072ac,%eax
  105b76:	0f b6 00             	movzbl (%eax),%eax
  105b79:	0f be c0             	movsbl %al,%eax
  105b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b83:	89 04 24             	mov    %eax,(%esp)
  105b86:	8b 45 08             	mov    0x8(%ebp),%eax
  105b89:	ff d0                	call   *%eax
}
  105b8b:	90                   	nop
  105b8c:	c9                   	leave  
  105b8d:	c3                   	ret    

00105b8e <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105b8e:	55                   	push   %ebp
  105b8f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105b91:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105b95:	7e 14                	jle    105bab <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105b97:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9a:	8b 00                	mov    (%eax),%eax
  105b9c:	8d 48 08             	lea    0x8(%eax),%ecx
  105b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  105ba2:	89 0a                	mov    %ecx,(%edx)
  105ba4:	8b 50 04             	mov    0x4(%eax),%edx
  105ba7:	8b 00                	mov    (%eax),%eax
  105ba9:	eb 30                	jmp    105bdb <getuint+0x4d>
    }
    else if (lflag) {
  105bab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105baf:	74 16                	je     105bc7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  105bb4:	8b 00                	mov    (%eax),%eax
  105bb6:	8d 48 04             	lea    0x4(%eax),%ecx
  105bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  105bbc:	89 0a                	mov    %ecx,(%edx)
  105bbe:	8b 00                	mov    (%eax),%eax
  105bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  105bc5:	eb 14                	jmp    105bdb <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  105bca:	8b 00                	mov    (%eax),%eax
  105bcc:	8d 48 04             	lea    0x4(%eax),%ecx
  105bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  105bd2:	89 0a                	mov    %ecx,(%edx)
  105bd4:	8b 00                	mov    (%eax),%eax
  105bd6:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105bdb:	5d                   	pop    %ebp
  105bdc:	c3                   	ret    

00105bdd <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105bdd:	55                   	push   %ebp
  105bde:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105be0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105be4:	7e 14                	jle    105bfa <getint+0x1d>
        return va_arg(*ap, long long);
  105be6:	8b 45 08             	mov    0x8(%ebp),%eax
  105be9:	8b 00                	mov    (%eax),%eax
  105beb:	8d 48 08             	lea    0x8(%eax),%ecx
  105bee:	8b 55 08             	mov    0x8(%ebp),%edx
  105bf1:	89 0a                	mov    %ecx,(%edx)
  105bf3:	8b 50 04             	mov    0x4(%eax),%edx
  105bf6:	8b 00                	mov    (%eax),%eax
  105bf8:	eb 28                	jmp    105c22 <getint+0x45>
    }
    else if (lflag) {
  105bfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105bfe:	74 12                	je     105c12 <getint+0x35>
        return va_arg(*ap, long);
  105c00:	8b 45 08             	mov    0x8(%ebp),%eax
  105c03:	8b 00                	mov    (%eax),%eax
  105c05:	8d 48 04             	lea    0x4(%eax),%ecx
  105c08:	8b 55 08             	mov    0x8(%ebp),%edx
  105c0b:	89 0a                	mov    %ecx,(%edx)
  105c0d:	8b 00                	mov    (%eax),%eax
  105c0f:	99                   	cltd   
  105c10:	eb 10                	jmp    105c22 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105c12:	8b 45 08             	mov    0x8(%ebp),%eax
  105c15:	8b 00                	mov    (%eax),%eax
  105c17:	8d 48 04             	lea    0x4(%eax),%ecx
  105c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  105c1d:	89 0a                	mov    %ecx,(%edx)
  105c1f:	8b 00                	mov    (%eax),%eax
  105c21:	99                   	cltd   
    }
}
  105c22:	5d                   	pop    %ebp
  105c23:	c3                   	ret    

00105c24 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105c24:	55                   	push   %ebp
  105c25:	89 e5                	mov    %esp,%ebp
  105c27:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105c2a:	8d 45 14             	lea    0x14(%ebp),%eax
  105c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105c37:	8b 45 10             	mov    0x10(%ebp),%eax
  105c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c45:	8b 45 08             	mov    0x8(%ebp),%eax
  105c48:	89 04 24             	mov    %eax,(%esp)
  105c4b:	e8 03 00 00 00       	call   105c53 <vprintfmt>
    va_end(ap);
}
  105c50:	90                   	nop
  105c51:	c9                   	leave  
  105c52:	c3                   	ret    

00105c53 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105c53:	55                   	push   %ebp
  105c54:	89 e5                	mov    %esp,%ebp
  105c56:	56                   	push   %esi
  105c57:	53                   	push   %ebx
  105c58:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c5b:	eb 17                	jmp    105c74 <vprintfmt+0x21>
            if (ch == '\0') {
  105c5d:	85 db                	test   %ebx,%ebx
  105c5f:	0f 84 bf 03 00 00    	je     106024 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c6c:	89 1c 24             	mov    %ebx,(%esp)
  105c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c72:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105c74:	8b 45 10             	mov    0x10(%ebp),%eax
  105c77:	8d 50 01             	lea    0x1(%eax),%edx
  105c7a:	89 55 10             	mov    %edx,0x10(%ebp)
  105c7d:	0f b6 00             	movzbl (%eax),%eax
  105c80:	0f b6 d8             	movzbl %al,%ebx
  105c83:	83 fb 25             	cmp    $0x25,%ebx
  105c86:	75 d5                	jne    105c5d <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105c88:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105c8c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c96:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105c99:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105ca0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ca3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  105ca9:	8d 50 01             	lea    0x1(%eax),%edx
  105cac:	89 55 10             	mov    %edx,0x10(%ebp)
  105caf:	0f b6 00             	movzbl (%eax),%eax
  105cb2:	0f b6 d8             	movzbl %al,%ebx
  105cb5:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105cb8:	83 f8 55             	cmp    $0x55,%eax
  105cbb:	0f 87 37 03 00 00    	ja     105ff8 <vprintfmt+0x3a5>
  105cc1:	8b 04 85 d0 72 10 00 	mov    0x1072d0(,%eax,4),%eax
  105cc8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105cca:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105cce:	eb d6                	jmp    105ca6 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105cd0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105cd4:	eb d0                	jmp    105ca6 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105cd6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105cdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105ce0:	89 d0                	mov    %edx,%eax
  105ce2:	c1 e0 02             	shl    $0x2,%eax
  105ce5:	01 d0                	add    %edx,%eax
  105ce7:	01 c0                	add    %eax,%eax
  105ce9:	01 d8                	add    %ebx,%eax
  105ceb:	83 e8 30             	sub    $0x30,%eax
  105cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  105cf4:	0f b6 00             	movzbl (%eax),%eax
  105cf7:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105cfa:	83 fb 2f             	cmp    $0x2f,%ebx
  105cfd:	7e 38                	jle    105d37 <vprintfmt+0xe4>
  105cff:	83 fb 39             	cmp    $0x39,%ebx
  105d02:	7f 33                	jg     105d37 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105d04:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105d07:	eb d4                	jmp    105cdd <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105d09:	8b 45 14             	mov    0x14(%ebp),%eax
  105d0c:	8d 50 04             	lea    0x4(%eax),%edx
  105d0f:	89 55 14             	mov    %edx,0x14(%ebp)
  105d12:	8b 00                	mov    (%eax),%eax
  105d14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105d17:	eb 1f                	jmp    105d38 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105d19:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d1d:	79 87                	jns    105ca6 <vprintfmt+0x53>
                width = 0;
  105d1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105d26:	e9 7b ff ff ff       	jmp    105ca6 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105d2b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105d32:	e9 6f ff ff ff       	jmp    105ca6 <vprintfmt+0x53>
            goto process_precision;
  105d37:	90                   	nop

        process_precision:
            if (width < 0)
  105d38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105d3c:	0f 89 64 ff ff ff    	jns    105ca6 <vprintfmt+0x53>
                width = precision, precision = -1;
  105d42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d45:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105d48:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105d4f:	e9 52 ff ff ff       	jmp    105ca6 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105d54:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105d57:	e9 4a ff ff ff       	jmp    105ca6 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  105d5f:	8d 50 04             	lea    0x4(%eax),%edx
  105d62:	89 55 14             	mov    %edx,0x14(%ebp)
  105d65:	8b 00                	mov    (%eax),%eax
  105d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  105d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  105d6e:	89 04 24             	mov    %eax,(%esp)
  105d71:	8b 45 08             	mov    0x8(%ebp),%eax
  105d74:	ff d0                	call   *%eax
            break;
  105d76:	e9 a4 02 00 00       	jmp    10601f <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105d7b:	8b 45 14             	mov    0x14(%ebp),%eax
  105d7e:	8d 50 04             	lea    0x4(%eax),%edx
  105d81:	89 55 14             	mov    %edx,0x14(%ebp)
  105d84:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105d86:	85 db                	test   %ebx,%ebx
  105d88:	79 02                	jns    105d8c <vprintfmt+0x139>
                err = -err;
  105d8a:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105d8c:	83 fb 06             	cmp    $0x6,%ebx
  105d8f:	7f 0b                	jg     105d9c <vprintfmt+0x149>
  105d91:	8b 34 9d 90 72 10 00 	mov    0x107290(,%ebx,4),%esi
  105d98:	85 f6                	test   %esi,%esi
  105d9a:	75 23                	jne    105dbf <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105d9c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105da0:	c7 44 24 08 bd 72 10 	movl   $0x1072bd,0x8(%esp)
  105da7:	00 
  105da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  105daf:	8b 45 08             	mov    0x8(%ebp),%eax
  105db2:	89 04 24             	mov    %eax,(%esp)
  105db5:	e8 6a fe ff ff       	call   105c24 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105dba:	e9 60 02 00 00       	jmp    10601f <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105dbf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105dc3:	c7 44 24 08 c6 72 10 	movl   $0x1072c6,0x8(%esp)
  105dca:	00 
  105dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  105dd5:	89 04 24             	mov    %eax,(%esp)
  105dd8:	e8 47 fe ff ff       	call   105c24 <printfmt>
            break;
  105ddd:	e9 3d 02 00 00       	jmp    10601f <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105de2:	8b 45 14             	mov    0x14(%ebp),%eax
  105de5:	8d 50 04             	lea    0x4(%eax),%edx
  105de8:	89 55 14             	mov    %edx,0x14(%ebp)
  105deb:	8b 30                	mov    (%eax),%esi
  105ded:	85 f6                	test   %esi,%esi
  105def:	75 05                	jne    105df6 <vprintfmt+0x1a3>
                p = "(null)";
  105df1:	be c9 72 10 00       	mov    $0x1072c9,%esi
            }
            if (width > 0 && padc != '-') {
  105df6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105dfa:	7e 76                	jle    105e72 <vprintfmt+0x21f>
  105dfc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105e00:	74 70                	je     105e72 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e09:	89 34 24             	mov    %esi,(%esp)
  105e0c:	e8 f6 f7 ff ff       	call   105607 <strnlen>
  105e11:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105e14:	29 c2                	sub    %eax,%edx
  105e16:	89 d0                	mov    %edx,%eax
  105e18:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e1b:	eb 16                	jmp    105e33 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105e1d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105e21:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e24:	89 54 24 04          	mov    %edx,0x4(%esp)
  105e28:	89 04 24             	mov    %eax,(%esp)
  105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  105e2e:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105e30:	ff 4d e8             	decl   -0x18(%ebp)
  105e33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e37:	7f e4                	jg     105e1d <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e39:	eb 37                	jmp    105e72 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105e3b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105e3f:	74 1f                	je     105e60 <vprintfmt+0x20d>
  105e41:	83 fb 1f             	cmp    $0x1f,%ebx
  105e44:	7e 05                	jle    105e4b <vprintfmt+0x1f8>
  105e46:	83 fb 7e             	cmp    $0x7e,%ebx
  105e49:	7e 15                	jle    105e60 <vprintfmt+0x20d>
                    putch('?', putdat);
  105e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e52:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105e59:	8b 45 08             	mov    0x8(%ebp),%eax
  105e5c:	ff d0                	call   *%eax
  105e5e:	eb 0f                	jmp    105e6f <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e67:	89 1c 24             	mov    %ebx,(%esp)
  105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  105e6d:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105e6f:	ff 4d e8             	decl   -0x18(%ebp)
  105e72:	89 f0                	mov    %esi,%eax
  105e74:	8d 70 01             	lea    0x1(%eax),%esi
  105e77:	0f b6 00             	movzbl (%eax),%eax
  105e7a:	0f be d8             	movsbl %al,%ebx
  105e7d:	85 db                	test   %ebx,%ebx
  105e7f:	74 27                	je     105ea8 <vprintfmt+0x255>
  105e81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e85:	78 b4                	js     105e3b <vprintfmt+0x1e8>
  105e87:	ff 4d e4             	decl   -0x1c(%ebp)
  105e8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105e8e:	79 ab                	jns    105e3b <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105e90:	eb 16                	jmp    105ea8 <vprintfmt+0x255>
                putch(' ', putdat);
  105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e95:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e99:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ea3:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105ea5:	ff 4d e8             	decl   -0x18(%ebp)
  105ea8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105eac:	7f e4                	jg     105e92 <vprintfmt+0x23f>
            }
            break;
  105eae:	e9 6c 01 00 00       	jmp    10601f <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105eba:	8d 45 14             	lea    0x14(%ebp),%eax
  105ebd:	89 04 24             	mov    %eax,(%esp)
  105ec0:	e8 18 fd ff ff       	call   105bdd <getint>
  105ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ec8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ece:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ed1:	85 d2                	test   %edx,%edx
  105ed3:	79 26                	jns    105efb <vprintfmt+0x2a8>
                putch('-', putdat);
  105ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105edc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ee6:	ff d0                	call   *%eax
                num = -(long long)num;
  105ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105eeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105eee:	f7 d8                	neg    %eax
  105ef0:	83 d2 00             	adc    $0x0,%edx
  105ef3:	f7 da                	neg    %edx
  105ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ef8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105efb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105f02:	e9 a8 00 00 00       	jmp    105faf <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105f07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f0e:	8d 45 14             	lea    0x14(%ebp),%eax
  105f11:	89 04 24             	mov    %eax,(%esp)
  105f14:	e8 75 fc ff ff       	call   105b8e <getuint>
  105f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105f1f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105f26:	e9 84 00 00 00       	jmp    105faf <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f32:	8d 45 14             	lea    0x14(%ebp),%eax
  105f35:	89 04 24             	mov    %eax,(%esp)
  105f38:	e8 51 fc ff ff       	call   105b8e <getuint>
  105f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f40:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105f43:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105f4a:	eb 63                	jmp    105faf <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f53:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  105f5d:	ff d0                	call   *%eax
            putch('x', putdat);
  105f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f66:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  105f70:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105f72:	8b 45 14             	mov    0x14(%ebp),%eax
  105f75:	8d 50 04             	lea    0x4(%eax),%edx
  105f78:	89 55 14             	mov    %edx,0x14(%ebp)
  105f7b:	8b 00                	mov    (%eax),%eax
  105f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105f87:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105f8e:	eb 1f                	jmp    105faf <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f97:	8d 45 14             	lea    0x14(%ebp),%eax
  105f9a:	89 04 24             	mov    %eax,(%esp)
  105f9d:	e8 ec fb ff ff       	call   105b8e <getuint>
  105fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105fa5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105fa8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105faf:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105fb6:	89 54 24 18          	mov    %edx,0x18(%esp)
  105fba:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105fbd:	89 54 24 14          	mov    %edx,0x14(%esp)
  105fc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  105fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  105fcf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fda:	8b 45 08             	mov    0x8(%ebp),%eax
  105fdd:	89 04 24             	mov    %eax,(%esp)
  105fe0:	e8 a4 fa ff ff       	call   105a89 <printnum>
            break;
  105fe5:	eb 38                	jmp    10601f <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fea:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fee:	89 1c 24             	mov    %ebx,(%esp)
  105ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ff4:	ff d0                	call   *%eax
            break;
  105ff6:	eb 27                	jmp    10601f <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106006:	8b 45 08             	mov    0x8(%ebp),%eax
  106009:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10600b:	ff 4d 10             	decl   0x10(%ebp)
  10600e:	eb 03                	jmp    106013 <vprintfmt+0x3c0>
  106010:	ff 4d 10             	decl   0x10(%ebp)
  106013:	8b 45 10             	mov    0x10(%ebp),%eax
  106016:	48                   	dec    %eax
  106017:	0f b6 00             	movzbl (%eax),%eax
  10601a:	3c 25                	cmp    $0x25,%al
  10601c:	75 f2                	jne    106010 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  10601e:	90                   	nop
    while (1) {
  10601f:	e9 37 fc ff ff       	jmp    105c5b <vprintfmt+0x8>
                return;
  106024:	90                   	nop
        }
    }
}
  106025:	83 c4 40             	add    $0x40,%esp
  106028:	5b                   	pop    %ebx
  106029:	5e                   	pop    %esi
  10602a:	5d                   	pop    %ebp
  10602b:	c3                   	ret    

0010602c <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10602c:	55                   	push   %ebp
  10602d:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10602f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106032:	8b 40 08             	mov    0x8(%eax),%eax
  106035:	8d 50 01             	lea    0x1(%eax),%edx
  106038:	8b 45 0c             	mov    0xc(%ebp),%eax
  10603b:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  10603e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106041:	8b 10                	mov    (%eax),%edx
  106043:	8b 45 0c             	mov    0xc(%ebp),%eax
  106046:	8b 40 04             	mov    0x4(%eax),%eax
  106049:	39 c2                	cmp    %eax,%edx
  10604b:	73 12                	jae    10605f <sprintputch+0x33>
        *b->buf ++ = ch;
  10604d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106050:	8b 00                	mov    (%eax),%eax
  106052:	8d 48 01             	lea    0x1(%eax),%ecx
  106055:	8b 55 0c             	mov    0xc(%ebp),%edx
  106058:	89 0a                	mov    %ecx,(%edx)
  10605a:	8b 55 08             	mov    0x8(%ebp),%edx
  10605d:	88 10                	mov    %dl,(%eax)
    }
}
  10605f:	90                   	nop
  106060:	5d                   	pop    %ebp
  106061:	c3                   	ret    

00106062 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106062:	55                   	push   %ebp
  106063:	89 e5                	mov    %esp,%ebp
  106065:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106068:	8d 45 14             	lea    0x14(%ebp),%eax
  10606b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  10606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106071:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106075:	8b 45 10             	mov    0x10(%ebp),%eax
  106078:	89 44 24 08          	mov    %eax,0x8(%esp)
  10607c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10607f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106083:	8b 45 08             	mov    0x8(%ebp),%eax
  106086:	89 04 24             	mov    %eax,(%esp)
  106089:	e8 08 00 00 00       	call   106096 <vsnprintf>
  10608e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106091:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106094:	c9                   	leave  
  106095:	c3                   	ret    

00106096 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106096:	55                   	push   %ebp
  106097:	89 e5                	mov    %esp,%ebp
  106099:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10609c:	8b 45 08             	mov    0x8(%ebp),%eax
  10609f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1060a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060a5:	8d 50 ff             	lea    -0x1(%eax),%edx
  1060a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1060ab:	01 d0                	add    %edx,%eax
  1060ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1060b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1060b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1060bb:	74 0a                	je     1060c7 <vsnprintf+0x31>
  1060bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1060c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060c3:	39 c2                	cmp    %eax,%edx
  1060c5:	76 07                	jbe    1060ce <vsnprintf+0x38>
        return -E_INVAL;
  1060c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1060cc:	eb 2a                	jmp    1060f8 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1060ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1060d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1060d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1060d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1060dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1060df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060e3:	c7 04 24 2c 60 10 00 	movl   $0x10602c,(%esp)
  1060ea:	e8 64 fb ff ff       	call   105c53 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1060ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060f2:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1060f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1060f8:	c9                   	leave  
  1060f9:	c3                   	ret    
