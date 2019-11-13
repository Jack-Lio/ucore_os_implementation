
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 11 00       	mov    $0x119000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping        将boot_pgdir清零
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 11 c0       	mov    %eax,0xc0119000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 11 c0       	mov    $0xc0118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here  kern_init出现错误退出进入此无限循环说明系统崩溃
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
  /*kerne_init中的外部全局变量,可知edata[]和 end[]这些变量是ld根据kernel.ld链接
脚本生成的全局变量,表示相应段的起始地址或结束地址等*/
    extern char edata[], end[];    //在kernel.ld中定义，作为定义段的起始地址
    memset(edata, 0, end - edata);
c010003c:	ba 28 bf 11 c0       	mov    $0xc011bf28,%edx
c0100041:	b8 00 b0 11 c0       	mov    $0xc011b000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c010005d:	e8 9e 58 00 00       	call   c0105900 <memset>

    cons_init();                // init the console
c0100062:	e8 a3 15 00 00       	call   c010160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 61 10 c0 	movl   $0xc0106100,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 61 10 c0 	movl   $0xc010611c,(%esp)
c010007c:	e8 21 02 00 00       	call   c01002a2 <cprintf>

    print_kerninfo();
c0100081:	e8 c2 08 00 00       	call   c0100948 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8e 00 00 00       	call   c0100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 9b 32 00 00       	call   c010332b <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 da 16 00 00       	call   c010176f <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 5f 18 00 00       	call   c01018f9 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 0e 0d 00 00       	call   c0100dad <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 05 18 00 00       	call   c01018a9 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a4:	e8 6b 01 00 00       	call   c0100214 <lab1_switch_test>

    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	55                   	push   %ebp
c01000ac:	89 e5                	mov    %esp,%ebp
c01000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b8:	00 
c01000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c0:	00 
c01000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c8:	e8 ce 0c 00 00       	call   c0100d9b <mon_backtrace>
}
c01000cd:	90                   	nop
c01000ce:	c9                   	leave  
c01000cf:	c3                   	ret    

c01000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d0:	55                   	push   %ebp
c01000d1:	89 e5                	mov    %esp,%ebp
c01000d3:	53                   	push   %ebx
c01000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000da:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ef:	89 04 24             	mov    %eax,(%esp)
c01000f2:	e8 b4 ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000f7:	90                   	nop
c01000f8:	83 c4 14             	add    $0x14,%esp
c01000fb:	5b                   	pop    %ebx
c01000fc:	5d                   	pop    %ebp
c01000fd:	c3                   	ret    

c01000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fe:	55                   	push   %ebp
c01000ff:	89 e5                	mov    %esp,%ebp
c0100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100104:	8b 45 10             	mov    0x10(%ebp),%eax
c0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010b:	8b 45 08             	mov    0x8(%ebp),%eax
c010010e:	89 04 24             	mov    %eax,(%esp)
c0100111:	e8 ba ff ff ff       	call   c01000d0 <grade_backtrace1>
}
c0100116:	90                   	nop
c0100117:	c9                   	leave  
c0100118:	c3                   	ret    

c0100119 <grade_backtrace>:

void
grade_backtrace(void) {
c0100119:	55                   	push   %ebp
c010011a:	89 e5                	mov    %esp,%ebp
c010011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012b:	ff 
c010012c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100137:	e8 c2 ff ff ff       	call   c01000fe <grade_backtrace0>
}
c010013c:	90                   	nop
c010013d:	c9                   	leave  
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 21 61 10 c0 	movl   $0xc0106121,(%esp)
c010016e:	e8 2f 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 2f 61 10 c0 	movl   $0xc010612f,(%esp)
c010018d:	e8 10 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 3d 61 10 c0 	movl   $0xc010613d,(%esp)
c01001ac:	e8 f1 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 4b 61 10 c0 	movl   $0xc010614b,(%esp)
c01001cb:	e8 d2 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 59 61 10 c0 	movl   $0xc0106159,(%esp)
c01001ea:	e8 b3 00 00 00       	call   c01002a2 <cprintf>
    round ++;
c01001ef:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 b0 11 c0       	mov    %eax,0xc011b000
}
c01001fa:	90                   	nop
c01001fb:	c9                   	leave  
c01001fc:	c3                   	ret    

c01001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fd:	55                   	push   %ebp
c01001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
c0100200:	83 ec 08             	sub    $0x8,%esp
c0100203:	cd 78                	int    $0x78
c0100205:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        :
        : "i"(T_SWITCH_TOU)
    );
}
c0100207:	90                   	nop
c0100208:	5d                   	pop    %ebp
c0100209:	c3                   	ret    

c010020a <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020a:	55                   	push   %ebp
c010020b:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c010020d:	cd 79                	int    $0x79
c010020f:	89 ec                	mov    %ebp,%esp
    "int %0 \n"
    "movl %%ebp, %%esp \n"
    :
    : "i"(T_SWITCH_TOK)
    );
}
c0100211:	90                   	nop
c0100212:	5d                   	pop    %ebp
c0100213:	c3                   	ret    

c0100214 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
c0100217:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021a:	e8 20 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021f:	c7 04 24 68 61 10 c0 	movl   $0xc0106168,(%esp)
c0100226:	e8 77 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_user();
c010022b:	e8 cd ff ff ff       	call   c01001fd <lab1_switch_to_user>
    lab1_print_cur_status();
c0100230:	e8 0a ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100235:	c7 04 24 88 61 10 c0 	movl   $0xc0106188,(%esp)
c010023c:	e8 61 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_kernel();
c0100241:	e8 c4 ff ff ff       	call   c010020a <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100246:	e8 f4 fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c010024b:	90                   	nop
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100254:	8b 45 08             	mov    0x8(%ebp),%eax
c0100257:	89 04 24             	mov    %eax,(%esp)
c010025a:	e8 d8 13 00 00       	call   c0101637 <cons_putc>
    (*cnt) ++;
c010025f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100262:	8b 00                	mov    (%eax),%eax
c0100264:	8d 50 01             	lea    0x1(%eax),%edx
c0100267:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026a:	89 10                	mov    %edx,(%eax)
}
c010026c:	90                   	nop
c010026d:	c9                   	leave  
c010026e:	c3                   	ret    

c010026f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026f:	55                   	push   %ebp
c0100270:	89 e5                	mov    %esp,%ebp
c0100272:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010027c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100283:	8b 45 08             	mov    0x8(%ebp),%eax
c0100286:	89 44 24 08          	mov    %eax,0x8(%esp)
c010028a:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010028d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100291:	c7 04 24 4e 02 10 c0 	movl   $0xc010024e,(%esp)
c0100298:	e8 b6 59 00 00       	call   c0105c53 <vprintfmt>
    return cnt;
c010029d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a0:	c9                   	leave  
c01002a1:	c3                   	ret    

c01002a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a2:	55                   	push   %ebp
c01002a3:	89 e5                	mov    %esp,%ebp
c01002a5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a8:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b8:	89 04 24             	mov    %eax,(%esp)
c01002bb:	e8 af ff ff ff       	call   c010026f <vcprintf>
c01002c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c6:	c9                   	leave  
c01002c7:	c3                   	ret    

c01002c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c8:	55                   	push   %ebp
c01002c9:	89 e5                	mov    %esp,%ebp
c01002cb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d1:	89 04 24             	mov    %eax,(%esp)
c01002d4:	e8 5e 13 00 00       	call   c0101637 <cons_putc>
}
c01002d9:	90                   	nop
c01002da:	c9                   	leave  
c01002db:	c3                   	ret    

c01002dc <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002dc:	55                   	push   %ebp
c01002dd:	89 e5                	mov    %esp,%ebp
c01002df:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e9:	eb 13                	jmp    c01002fe <cputs+0x22>
        cputch(c, &cnt);
c01002eb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ef:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f6:	89 04 24             	mov    %eax,(%esp)
c01002f9:	e8 50 ff ff ff       	call   c010024e <cputch>
    while ((c = *str ++) != '\0') {
c01002fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100301:	8d 50 01             	lea    0x1(%eax),%edx
c0100304:	89 55 08             	mov    %edx,0x8(%ebp)
c0100307:	0f b6 00             	movzbl (%eax),%eax
c010030a:	88 45 f7             	mov    %al,-0x9(%ebp)
c010030d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100311:	75 d8                	jne    c01002eb <cputs+0xf>
    }
    cputch('\n', &cnt);
c0100313:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100316:	89 44 24 04          	mov    %eax,0x4(%esp)
c010031a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100321:	e8 28 ff ff ff       	call   c010024e <cputch>
    return cnt;
c0100326:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100329:	c9                   	leave  
c010032a:	c3                   	ret    

c010032b <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010032b:	55                   	push   %ebp
c010032c:	89 e5                	mov    %esp,%ebp
c010032e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100331:	e8 3e 13 00 00       	call   c0101674 <cons_getc>
c0100336:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010033d:	74 f2                	je     c0100331 <getchar+0x6>
        /* do nothing */;
    return c;
c010033f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100342:	c9                   	leave  
c0100343:	c3                   	ret    

c0100344 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100344:	55                   	push   %ebp
c0100345:	89 e5                	mov    %esp,%ebp
c0100347:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010034a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010034e:	74 13                	je     c0100363 <readline+0x1f>
        cprintf("%s", prompt);
c0100350:	8b 45 08             	mov    0x8(%ebp),%eax
c0100353:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100357:	c7 04 24 a7 61 10 c0 	movl   $0xc01061a7,(%esp)
c010035e:	e8 3f ff ff ff       	call   c01002a2 <cprintf>
    }
    int i = 0, c;
c0100363:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010036a:	e8 bc ff ff ff       	call   c010032b <getchar>
c010036f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100372:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100376:	79 07                	jns    c010037f <readline+0x3b>
            return NULL;
c0100378:	b8 00 00 00 00       	mov    $0x0,%eax
c010037d:	eb 78                	jmp    c01003f7 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100383:	7e 28                	jle    c01003ad <readline+0x69>
c0100385:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010038c:	7f 1f                	jg     c01003ad <readline+0x69>
            cputchar(c);
c010038e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100391:	89 04 24             	mov    %eax,(%esp)
c0100394:	e8 2f ff ff ff       	call   c01002c8 <cputchar>
            buf[i ++] = c;
c0100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039c:	8d 50 01             	lea    0x1(%eax),%edx
c010039f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a5:	88 90 20 b0 11 c0    	mov    %dl,-0x3fee4fe0(%eax)
c01003ab:	eb 45                	jmp    c01003f2 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003ad:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b1:	75 16                	jne    c01003c9 <readline+0x85>
c01003b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b7:	7e 10                	jle    c01003c9 <readline+0x85>
            cputchar(c);
c01003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bc:	89 04 24             	mov    %eax,(%esp)
c01003bf:	e8 04 ff ff ff       	call   c01002c8 <cputchar>
            i --;
c01003c4:	ff 4d f4             	decl   -0xc(%ebp)
c01003c7:	eb 29                	jmp    c01003f2 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003c9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003cd:	74 06                	je     c01003d5 <readline+0x91>
c01003cf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003d3:	75 95                	jne    c010036a <readline+0x26>
            cputchar(c);
c01003d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d8:	89 04 24             	mov    %eax,(%esp)
c01003db:	e8 e8 fe ff ff       	call   c01002c8 <cputchar>
            buf[i] = '\0';
c01003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e3:	05 20 b0 11 c0       	add    $0xc011b020,%eax
c01003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003eb:	b8 20 b0 11 c0       	mov    $0xc011b020,%eax
c01003f0:	eb 05                	jmp    c01003f7 <readline+0xb3>
        c = getchar();
c01003f2:	e9 73 ff ff ff       	jmp    c010036a <readline+0x26>
        }
    }
}
c01003f7:	c9                   	leave  
c01003f8:	c3                   	ret    

c01003f9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f9:	55                   	push   %ebp
c01003fa:	89 e5                	mov    %esp,%ebp
c01003fc:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003ff:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
c0100404:	85 c0                	test   %eax,%eax
c0100406:	75 5b                	jne    c0100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100408:	c7 05 20 b4 11 c0 01 	movl   $0x1,0xc011b420
c010040f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100412:	8d 45 14             	lea    0x14(%ebp),%eax
c0100415:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100418:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010041f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100422:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100426:	c7 04 24 aa 61 10 c0 	movl   $0xc01061aa,(%esp)
c010042d:	e8 70 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c0100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100435:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100439:	8b 45 10             	mov    0x10(%ebp),%eax
c010043c:	89 04 24             	mov    %eax,(%esp)
c010043f:	e8 2b fe ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c0100444:	c7 04 24 c6 61 10 c0 	movl   $0xc01061c6,(%esp)
c010044b:	e8 52 fe ff ff       	call   c01002a2 <cprintf>
    
    cprintf("stack trackback:\n");
c0100450:	c7 04 24 c8 61 10 c0 	movl   $0xc01061c8,(%esp)
c0100457:	e8 46 fe ff ff       	call   c01002a2 <cprintf>
    print_stackframe();
c010045c:	e8 32 06 00 00       	call   c0100a93 <print_stackframe>
c0100461:	eb 01                	jmp    c0100464 <__panic+0x6b>
        goto panic_dead;
c0100463:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100464:	e8 47 14 00 00       	call   c01018b0 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100470:	e8 59 08 00 00       	call   c0100cce <kmonitor>
c0100475:	eb f2                	jmp    c0100469 <__panic+0x70>

c0100477 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100477:	55                   	push   %ebp
c0100478:	89 e5                	mov    %esp,%ebp
c010047a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010047d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100480:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100483:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100486:	89 44 24 08          	mov    %eax,0x8(%esp)
c010048a:	8b 45 08             	mov    0x8(%ebp),%eax
c010048d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100491:	c7 04 24 da 61 10 c0 	movl   $0xc01061da,(%esp)
c0100498:	e8 05 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c010049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a7:	89 04 24             	mov    %eax,(%esp)
c01004aa:	e8 c0 fd ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c01004af:	c7 04 24 c6 61 10 c0 	movl   $0xc01061c6,(%esp)
c01004b6:	e8 e7 fd ff ff       	call   c01002a2 <cprintf>
    va_end(ap);
}
c01004bb:	90                   	nop
c01004bc:	c9                   	leave  
c01004bd:	c3                   	ret    

c01004be <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004be:	55                   	push   %ebp
c01004bf:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c1:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
}
c01004c6:	5d                   	pop    %ebp
c01004c7:	c3                   	ret    

c01004c8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c8:	55                   	push   %ebp
c01004c9:	89 e5                	mov    %esp,%ebp
c01004cb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d1:	8b 00                	mov    (%eax),%eax
c01004d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d9:	8b 00                	mov    (%eax),%eax
c01004db:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e5:	e9 ca 00 00 00       	jmp    c01005b4 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f0:	01 d0                	add    %edx,%eax
c01004f2:	89 c2                	mov    %eax,%edx
c01004f4:	c1 ea 1f             	shr    $0x1f,%edx
c01004f7:	01 d0                	add    %edx,%eax
c01004f9:	d1 f8                	sar    %eax
c01004fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100501:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100504:	eb 03                	jmp    c0100509 <stab_binsearch+0x41>
            m --;
c0100506:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100509:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050f:	7c 1f                	jl     c0100530 <stab_binsearch+0x68>
c0100511:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100514:	89 d0                	mov    %edx,%eax
c0100516:	01 c0                	add    %eax,%eax
c0100518:	01 d0                	add    %edx,%eax
c010051a:	c1 e0 02             	shl    $0x2,%eax
c010051d:	89 c2                	mov    %eax,%edx
c010051f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100522:	01 d0                	add    %edx,%eax
c0100524:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100528:	0f b6 c0             	movzbl %al,%eax
c010052b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010052e:	75 d6                	jne    c0100506 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100530:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100533:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100536:	7d 09                	jge    c0100541 <stab_binsearch+0x79>
            l = true_m + 1;
c0100538:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010053b:	40                   	inc    %eax
c010053c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053f:	eb 73                	jmp    c01005b4 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100541:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100548:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054b:	89 d0                	mov    %edx,%eax
c010054d:	01 c0                	add    %eax,%eax
c010054f:	01 d0                	add    %edx,%eax
c0100551:	c1 e0 02             	shl    $0x2,%eax
c0100554:	89 c2                	mov    %eax,%edx
c0100556:	8b 45 08             	mov    0x8(%ebp),%eax
c0100559:	01 d0                	add    %edx,%eax
c010055b:	8b 40 08             	mov    0x8(%eax),%eax
c010055e:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100561:	76 11                	jbe    c0100574 <stab_binsearch+0xac>
            *region_left = m;
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100569:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056e:	40                   	inc    %eax
c010056f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100572:	eb 40                	jmp    c01005b4 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100574:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100577:	89 d0                	mov    %edx,%eax
c0100579:	01 c0                	add    %eax,%eax
c010057b:	01 d0                	add    %edx,%eax
c010057d:	c1 e0 02             	shl    $0x2,%eax
c0100580:	89 c2                	mov    %eax,%edx
c0100582:	8b 45 08             	mov    0x8(%ebp),%eax
c0100585:	01 d0                	add    %edx,%eax
c0100587:	8b 40 08             	mov    0x8(%eax),%eax
c010058a:	39 45 18             	cmp    %eax,0x18(%ebp)
c010058d:	73 14                	jae    c01005a3 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100592:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100595:	8b 45 10             	mov    0x10(%ebp),%eax
c0100598:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010059a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059d:	48                   	dec    %eax
c010059e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a1:	eb 11                	jmp    c01005b4 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a9:	89 10                	mov    %edx,(%eax)
            l = m;
c01005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b1:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01005b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005ba:	0f 8e 2a ff ff ff    	jle    c01004ea <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01005c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c4:	75 0f                	jne    c01005d5 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c9:	8b 00                	mov    (%eax),%eax
c01005cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d1:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005d3:	eb 3e                	jmp    c0100613 <stab_binsearch+0x14b>
        l = *region_right;
c01005d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d8:	8b 00                	mov    (%eax),%eax
c01005da:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005dd:	eb 03                	jmp    c01005e2 <stab_binsearch+0x11a>
c01005df:	ff 4d fc             	decl   -0x4(%ebp)
c01005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e5:	8b 00                	mov    (%eax),%eax
c01005e7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01005ea:	7e 1f                	jle    c010060b <stab_binsearch+0x143>
c01005ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ef:	89 d0                	mov    %edx,%eax
c01005f1:	01 c0                	add    %eax,%eax
c01005f3:	01 d0                	add    %edx,%eax
c01005f5:	c1 e0 02             	shl    $0x2,%eax
c01005f8:	89 c2                	mov    %eax,%edx
c01005fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fd:	01 d0                	add    %edx,%eax
c01005ff:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100603:	0f b6 c0             	movzbl %al,%eax
c0100606:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100609:	75 d4                	jne    c01005df <stab_binsearch+0x117>
        *region_left = l;
c010060b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100611:	89 10                	mov    %edx,(%eax)
}
c0100613:	90                   	nop
c0100614:	c9                   	leave  
c0100615:	c3                   	ret    

c0100616 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100616:	55                   	push   %ebp
c0100617:	89 e5                	mov    %esp,%ebp
c0100619:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010061c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061f:	c7 00 f8 61 10 c0    	movl   $0xc01061f8,(%eax)
    info->eip_line = 0;
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 08 f8 61 10 c0 	movl   $0xc01061f8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100639:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100643:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100646:	8b 55 08             	mov    0x8(%ebp),%edx
c0100649:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010064c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100656:	c7 45 f4 28 74 10 c0 	movl   $0xc0107428,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065d:	c7 45 f0 04 28 11 c0 	movl   $0xc0112804,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100664:	c7 45 ec 05 28 11 c0 	movl   $0xc0112805,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066b:	c7 45 e8 32 53 11 c0 	movl   $0xc0115332,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100678:	76 0b                	jbe    c0100685 <debuginfo_eip+0x6f>
c010067a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067d:	48                   	dec    %eax
c010067e:	0f b6 00             	movzbl (%eax),%eax
c0100681:	84 c0                	test   %al,%al
c0100683:	74 0a                	je     c010068f <debuginfo_eip+0x79>
        return -1;
c0100685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010068a:	e9 b7 02 00 00       	jmp    c0100946 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100696:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100699:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069c:	29 c2                	sub    %eax,%edx
c010069e:	89 d0                	mov    %edx,%eax
c01006a0:	c1 f8 02             	sar    $0x2,%eax
c01006a3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a9:	48                   	dec    %eax
c01006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01006b0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006b4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006bb:	00 
c01006bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006bf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cd:	89 04 24             	mov    %eax,(%esp)
c01006d0:	e8 f3 fd ff ff       	call   c01004c8 <stab_binsearch>
    if (lfile == 0)
c01006d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d8:	85 c0                	test   %eax,%eax
c01006da:	75 0a                	jne    c01006e6 <debuginfo_eip+0xd0>
        return -1;
c01006dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e1:	e9 60 02 00 00       	jmp    c0100946 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f9:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100700:	00 
c0100701:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100704:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100708:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100712:	89 04 24             	mov    %eax,(%esp)
c0100715:	e8 ae fd ff ff       	call   c01004c8 <stab_binsearch>

    if (lfun <= rfun) {
c010071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010071d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100720:	39 c2                	cmp    %eax,%edx
c0100722:	7f 7c                	jg     c01007a0 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100724:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100727:	89 c2                	mov    %eax,%edx
c0100729:	89 d0                	mov    %edx,%eax
c010072b:	01 c0                	add    %eax,%eax
c010072d:	01 d0                	add    %edx,%eax
c010072f:	c1 e0 02             	shl    $0x2,%eax
c0100732:	89 c2                	mov    %eax,%edx
c0100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100737:	01 d0                	add    %edx,%eax
c0100739:	8b 00                	mov    (%eax),%eax
c010073b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010073e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100741:	29 d1                	sub    %edx,%ecx
c0100743:	89 ca                	mov    %ecx,%edx
c0100745:	39 d0                	cmp    %edx,%eax
c0100747:	73 22                	jae    c010076b <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100749:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	89 d0                	mov    %edx,%eax
c0100750:	01 c0                	add    %eax,%eax
c0100752:	01 d0                	add    %edx,%eax
c0100754:	c1 e0 02             	shl    $0x2,%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	8b 10                	mov    (%eax),%edx
c0100760:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100763:	01 c2                	add    %eax,%edx
c0100765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100768:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010076b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010076e:	89 c2                	mov    %eax,%edx
c0100770:	89 d0                	mov    %edx,%eax
c0100772:	01 c0                	add    %eax,%eax
c0100774:	01 d0                	add    %edx,%eax
c0100776:	c1 e0 02             	shl    $0x2,%eax
c0100779:	89 c2                	mov    %eax,%edx
c010077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077e:	01 d0                	add    %edx,%eax
c0100780:	8b 50 08             	mov    0x8(%eax),%edx
c0100783:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100786:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100789:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078c:	8b 40 10             	mov    0x10(%eax),%eax
c010078f:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100795:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100798:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010079b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010079e:	eb 15                	jmp    c01007b5 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007af:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b8:	8b 40 08             	mov    0x8(%eax),%eax
c01007bb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c2:	00 
c01007c3:	89 04 24             	mov    %eax,(%esp)
c01007c6:	e8 b1 4f 00 00       	call   c010577c <strfind>
c01007cb:	89 c2                	mov    %eax,%edx
c01007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d0:	8b 40 08             	mov    0x8(%eax),%eax
c01007d3:	29 c2                	sub    %eax,%edx
c01007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d8:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007db:	8b 45 08             	mov    0x8(%ebp),%eax
c01007de:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e2:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e9:	00 
c01007ea:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fb:	89 04 24             	mov    %eax,(%esp)
c01007fe:	e8 c5 fc ff ff       	call   c01004c8 <stab_binsearch>
    if (lline <= rline) {
c0100803:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100806:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100809:	39 c2                	cmp    %eax,%edx
c010080b:	7f 23                	jg     c0100830 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c010080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100810:	89 c2                	mov    %eax,%edx
c0100812:	89 d0                	mov    %edx,%eax
c0100814:	01 c0                	add    %eax,%eax
c0100816:	01 d0                	add    %edx,%eax
c0100818:	c1 e0 02             	shl    $0x2,%eax
c010081b:	89 c2                	mov    %eax,%edx
c010081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100820:	01 d0                	add    %edx,%eax
c0100822:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100826:	89 c2                	mov    %eax,%edx
c0100828:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010082e:	eb 11                	jmp    c0100841 <debuginfo_eip+0x22b>
        return -1;
c0100830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100835:	e9 0c 01 00 00       	jmp    c0100946 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010083a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083d:	48                   	dec    %eax
c010083e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100847:	39 c2                	cmp    %eax,%edx
c0100849:	7c 56                	jl     c01008a1 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084e:	89 c2                	mov    %eax,%edx
c0100850:	89 d0                	mov    %edx,%eax
c0100852:	01 c0                	add    %eax,%eax
c0100854:	01 d0                	add    %edx,%eax
c0100856:	c1 e0 02             	shl    $0x2,%eax
c0100859:	89 c2                	mov    %eax,%edx
c010085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100864:	3c 84                	cmp    $0x84,%al
c0100866:	74 39                	je     c01008a1 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100868:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	89 d0                	mov    %edx,%eax
c010086f:	01 c0                	add    %eax,%eax
c0100871:	01 d0                	add    %edx,%eax
c0100873:	c1 e0 02             	shl    $0x2,%eax
c0100876:	89 c2                	mov    %eax,%edx
c0100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087b:	01 d0                	add    %edx,%eax
c010087d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100881:	3c 64                	cmp    $0x64,%al
c0100883:	75 b5                	jne    c010083a <debuginfo_eip+0x224>
c0100885:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100888:	89 c2                	mov    %eax,%edx
c010088a:	89 d0                	mov    %edx,%eax
c010088c:	01 c0                	add    %eax,%eax
c010088e:	01 d0                	add    %edx,%eax
c0100890:	c1 e0 02             	shl    $0x2,%eax
c0100893:	89 c2                	mov    %eax,%edx
c0100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100898:	01 d0                	add    %edx,%eax
c010089a:	8b 40 08             	mov    0x8(%eax),%eax
c010089d:	85 c0                	test   %eax,%eax
c010089f:	74 99                	je     c010083a <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a7:	39 c2                	cmp    %eax,%edx
c01008a9:	7c 46                	jl     c01008f1 <debuginfo_eip+0x2db>
c01008ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ae:	89 c2                	mov    %eax,%edx
c01008b0:	89 d0                	mov    %edx,%eax
c01008b2:	01 c0                	add    %eax,%eax
c01008b4:	01 d0                	add    %edx,%eax
c01008b6:	c1 e0 02             	shl    $0x2,%eax
c01008b9:	89 c2                	mov    %eax,%edx
c01008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008be:	01 d0                	add    %edx,%eax
c01008c0:	8b 00                	mov    (%eax),%eax
c01008c2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008c8:	29 d1                	sub    %edx,%ecx
c01008ca:	89 ca                	mov    %ecx,%edx
c01008cc:	39 d0                	cmp    %edx,%eax
c01008ce:	73 21                	jae    c01008f1 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d3:	89 c2                	mov    %eax,%edx
c01008d5:	89 d0                	mov    %edx,%eax
c01008d7:	01 c0                	add    %eax,%eax
c01008d9:	01 d0                	add    %edx,%eax
c01008db:	c1 e0 02             	shl    $0x2,%eax
c01008de:	89 c2                	mov    %eax,%edx
c01008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e3:	01 d0                	add    %edx,%eax
c01008e5:	8b 10                	mov    (%eax),%edx
c01008e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008ea:	01 c2                	add    %eax,%edx
c01008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ef:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f7:	39 c2                	cmp    %eax,%edx
c01008f9:	7d 46                	jge    c0100941 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008fe:	40                   	inc    %eax
c01008ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100902:	eb 16                	jmp    c010091a <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100904:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100907:	8b 40 14             	mov    0x14(%eax),%eax
c010090a:	8d 50 01             	lea    0x1(%eax),%edx
c010090d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100910:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100913:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100916:	40                   	inc    %eax
c0100917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010091a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010091d:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100920:	39 c2                	cmp    %eax,%edx
c0100922:	7d 1d                	jge    c0100941 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100924:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100927:	89 c2                	mov    %eax,%edx
c0100929:	89 d0                	mov    %edx,%eax
c010092b:	01 c0                	add    %eax,%eax
c010092d:	01 d0                	add    %edx,%eax
c010092f:	c1 e0 02             	shl    $0x2,%eax
c0100932:	89 c2                	mov    %eax,%edx
c0100934:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100937:	01 d0                	add    %edx,%eax
c0100939:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010093d:	3c a0                	cmp    $0xa0,%al
c010093f:	74 c3                	je     c0100904 <debuginfo_eip+0x2ee>
        }
    }
    return 0;
c0100941:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100946:	c9                   	leave  
c0100947:	c3                   	ret    

c0100948 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100948:	55                   	push   %ebp
c0100949:	89 e5                	mov    %esp,%ebp
c010094b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010094e:	c7 04 24 02 62 10 c0 	movl   $0xc0106202,(%esp)
c0100955:	e8 48 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010095a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100961:	c0 
c0100962:	c7 04 24 1b 62 10 c0 	movl   $0xc010621b,(%esp)
c0100969:	e8 34 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096e:	c7 44 24 04 fa 60 10 	movl   $0xc01060fa,0x4(%esp)
c0100975:	c0 
c0100976:	c7 04 24 33 62 10 c0 	movl   $0xc0106233,(%esp)
c010097d:	e8 20 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100982:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c0100989:	c0 
c010098a:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c0100991:	e8 0c f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100996:	c7 44 24 04 28 bf 11 	movl   $0xc011bf28,0x4(%esp)
c010099d:	c0 
c010099e:	c7 04 24 63 62 10 c0 	movl   $0xc0106263,(%esp)
c01009a5:	e8 f8 f8 ff ff       	call   c01002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009aa:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
c01009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009ba:	29 c2                	sub    %eax,%edx
c01009bc:	89 d0                	mov    %edx,%eax
c01009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c4:	85 c0                	test   %eax,%eax
c01009c6:	0f 48 c2             	cmovs  %edx,%eax
c01009c9:	c1 f8 0a             	sar    $0xa,%eax
c01009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d0:	c7 04 24 7c 62 10 c0 	movl   $0xc010627c,(%esp)
c01009d7:	e8 c6 f8 ff ff       	call   c01002a2 <cprintf>
}
c01009dc:	90                   	nop
c01009dd:	c9                   	leave  
c01009de:	c3                   	ret    

c01009df <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009df:	55                   	push   %ebp
c01009e0:	89 e5                	mov    %esp,%ebp
c01009e2:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f2:	89 04 24             	mov    %eax,(%esp)
c01009f5:	e8 1c fc ff ff       	call   c0100616 <debuginfo_eip>
c01009fa:	85 c0                	test   %eax,%eax
c01009fc:	74 15                	je     c0100a13 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a05:	c7 04 24 a6 62 10 c0 	movl   $0xc01062a6,(%esp)
c0100a0c:	e8 91 f8 ff ff       	call   c01002a2 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a11:	eb 6c                	jmp    c0100a7f <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a1a:	eb 1b                	jmp    c0100a37 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a22:	01 d0                	add    %edx,%eax
c0100a24:	0f b6 00             	movzbl (%eax),%eax
c0100a27:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a30:	01 ca                	add    %ecx,%edx
c0100a32:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a34:	ff 45 f4             	incl   -0xc(%ebp)
c0100a37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a3a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a3d:	7c dd                	jl     c0100a1c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a3f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a48:	01 d0                	add    %edx,%eax
c0100a4a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a50:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a53:	89 d1                	mov    %edx,%ecx
c0100a55:	29 c1                	sub    %eax,%ecx
c0100a57:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a5d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a61:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a67:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a6b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a73:	c7 04 24 c2 62 10 c0 	movl   $0xc01062c2,(%esp)
c0100a7a:	e8 23 f8 ff ff       	call   c01002a2 <cprintf>
}
c0100a7f:	90                   	nop
c0100a80:	c9                   	leave  
c0100a81:	c3                   	ret    

c0100a82 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a82:	55                   	push   %ebp
c0100a83:	89 e5                	mov    %esp,%ebp
c0100a85:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a88:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a91:	c9                   	leave  
c0100a92:	c3                   	ret    

c0100a93 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */

void
print_stackframe(void) {
c0100a93:	55                   	push   %ebp
c0100a94:	89 e5                	mov    %esp,%ebp
c0100a96:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a99:	89 e8                	mov    %ebp,%eax
c0100a9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
c0100aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
c0100aa4:	e8 d9 ff ff ff       	call   c0100a82 <read_eip>
c0100aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
c0100aac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ab3:	e9 9a 00 00 00       	jmp    c0100b52 <print_stackframe+0xbf>
      {
        if (ebp==0)  break;
c0100ab8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100abc:	0f 84 9c 00 00 00    	je     c0100b5e <print_stackframe+0xcb>
        cprintf("-> ebp:0x%08x   eip:0x%08x   " ,ebp,eip);
c0100ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100acc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad0:	c7 04 24 d4 62 10 c0 	movl   $0xc01062d4,(%esp)
c0100ad7:	e8 c6 f7 ff ff       	call   c01002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
c0100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adf:	83 c0 08             	add    $0x8,%eax
c0100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
c0100ae5:	c7 04 24 f2 62 10 c0 	movl   $0xc01062f2,(%esp)
c0100aec:	e8 b1 f7 ff ff       	call   c01002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
c0100af1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100af8:	eb 24                	jmp    c0100b1e <print_stackframe+0x8b>
        {
          cprintf("0x%08x ",arguments[j]);
c0100afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100afd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b07:	01 d0                	add    %edx,%eax
c0100b09:	8b 00                	mov    (%eax),%eax
c0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b0f:	c7 04 24 f9 62 10 c0 	movl   $0xc01062f9,(%esp)
c0100b16:	e8 87 f7 ff ff       	call   c01002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
c0100b1b:	ff 45 e8             	incl   -0x18(%ebp)
c0100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b22:	7e d6                	jle    c0100afa <print_stackframe+0x67>
        }
        cprintf("\n");
c0100b24:	c7 04 24 01 63 10 c0 	movl   $0xc0106301,(%esp)
c0100b2b:	e8 72 f7 ff ff       	call   c01002a2 <cprintf>
        print_debuginfo(eip-1);
c0100b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b33:	48                   	dec    %eax
c0100b34:	89 04 24             	mov    %eax,(%esp)
c0100b37:	e8 a3 fe ff ff       	call   c01009df <print_debuginfo>
        eip =( (uint32_t*) ebp)[1];
c0100b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3f:	83 c0 04             	add    $0x4,%eax
c0100b42:	8b 00                	mov    (%eax),%eax
c0100b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp= ((uint32_t* ) ebp)[0];
c0100b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b4a:	8b 00                	mov    (%eax),%eax
c0100b4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
c0100b4f:	ff 45 ec             	incl   -0x14(%ebp)
c0100b52:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b56:	0f 8e 5c ff ff ff    	jle    c0100ab8 <print_stackframe+0x25>
      }

}
c0100b5c:	eb 01                	jmp    c0100b5f <print_stackframe+0xcc>
        if (ebp==0)  break;
c0100b5e:	90                   	nop
}
c0100b5f:	90                   	nop
c0100b60:	c9                   	leave  
c0100b61:	c3                   	ret    

c0100b62 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b62:	55                   	push   %ebp
c0100b63:	89 e5                	mov    %esp,%ebp
c0100b65:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b6f:	eb 0c                	jmp    c0100b7d <parse+0x1b>
            *buf ++ = '\0';
c0100b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b74:	8d 50 01             	lea    0x1(%eax),%edx
c0100b77:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b7a:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b80:	0f b6 00             	movzbl (%eax),%eax
c0100b83:	84 c0                	test   %al,%al
c0100b85:	74 1d                	je     c0100ba4 <parse+0x42>
c0100b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b8a:	0f b6 00             	movzbl (%eax),%eax
c0100b8d:	0f be c0             	movsbl %al,%eax
c0100b90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b94:	c7 04 24 84 63 10 c0 	movl   $0xc0106384,(%esp)
c0100b9b:	e8 aa 4b 00 00       	call   c010574a <strchr>
c0100ba0:	85 c0                	test   %eax,%eax
c0100ba2:	75 cd                	jne    c0100b71 <parse+0xf>
        }
        if (*buf == '\0') {
c0100ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba7:	0f b6 00             	movzbl (%eax),%eax
c0100baa:	84 c0                	test   %al,%al
c0100bac:	74 65                	je     c0100c13 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bae:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bb2:	75 14                	jne    c0100bc8 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bb4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bbb:	00 
c0100bbc:	c7 04 24 89 63 10 c0 	movl   $0xc0106389,(%esp)
c0100bc3:	e8 da f6 ff ff       	call   c01002a2 <cprintf>
        }
        argv[argc ++] = buf;
c0100bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bcb:	8d 50 01             	lea    0x1(%eax),%edx
c0100bce:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bd1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bdb:	01 c2                	add    %eax,%edx
c0100bdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be0:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100be2:	eb 03                	jmp    c0100be7 <parse+0x85>
            buf ++;
c0100be4:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bea:	0f b6 00             	movzbl (%eax),%eax
c0100bed:	84 c0                	test   %al,%al
c0100bef:	74 8c                	je     c0100b7d <parse+0x1b>
c0100bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf4:	0f b6 00             	movzbl (%eax),%eax
c0100bf7:	0f be c0             	movsbl %al,%eax
c0100bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bfe:	c7 04 24 84 63 10 c0 	movl   $0xc0106384,(%esp)
c0100c05:	e8 40 4b 00 00       	call   c010574a <strchr>
c0100c0a:	85 c0                	test   %eax,%eax
c0100c0c:	74 d6                	je     c0100be4 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c0e:	e9 6a ff ff ff       	jmp    c0100b7d <parse+0x1b>
            break;
c0100c13:	90                   	nop
        }
    }
    return argc;
c0100c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c17:	c9                   	leave  
c0100c18:	c3                   	ret    

c0100c19 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c19:	55                   	push   %ebp
c0100c1a:	89 e5                	mov    %esp,%ebp
c0100c1c:	53                   	push   %ebx
c0100c1d:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c20:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2a:	89 04 24             	mov    %eax,(%esp)
c0100c2d:	e8 30 ff ff ff       	call   c0100b62 <parse>
c0100c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c39:	75 0a                	jne    c0100c45 <runcmd+0x2c>
        return 0;
c0100c3b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c40:	e9 83 00 00 00       	jmp    c0100cc8 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c4c:	eb 5a                	jmp    c0100ca8 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c4e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c54:	89 d0                	mov    %edx,%eax
c0100c56:	01 c0                	add    %eax,%eax
c0100c58:	01 d0                	add    %edx,%eax
c0100c5a:	c1 e0 02             	shl    $0x2,%eax
c0100c5d:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100c62:	8b 00                	mov    (%eax),%eax
c0100c64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c68:	89 04 24             	mov    %eax,(%esp)
c0100c6b:	e8 3d 4a 00 00       	call   c01056ad <strcmp>
c0100c70:	85 c0                	test   %eax,%eax
c0100c72:	75 31                	jne    c0100ca5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 08 80 11 c0       	add    $0xc0118008,%eax
c0100c85:	8b 10                	mov    (%eax),%edx
c0100c87:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c8a:	83 c0 04             	add    $0x4,%eax
c0100c8d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c90:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9e:	89 1c 24             	mov    %ebx,(%esp)
c0100ca1:	ff d2                	call   *%edx
c0100ca3:	eb 23                	jmp    c0100cc8 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ca5:	ff 45 f4             	incl   -0xc(%ebp)
c0100ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cab:	83 f8 02             	cmp    $0x2,%eax
c0100cae:	76 9e                	jbe    c0100c4e <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cb0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cb7:	c7 04 24 a7 63 10 c0 	movl   $0xc01063a7,(%esp)
c0100cbe:	e8 df f5 ff ff       	call   c01002a2 <cprintf>
    return 0;
c0100cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc8:	83 c4 64             	add    $0x64,%esp
c0100ccb:	5b                   	pop    %ebx
c0100ccc:	5d                   	pop    %ebp
c0100ccd:	c3                   	ret    

c0100cce <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cce:	55                   	push   %ebp
c0100ccf:	89 e5                	mov    %esp,%ebp
c0100cd1:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cd4:	c7 04 24 c0 63 10 c0 	movl   $0xc01063c0,(%esp)
c0100cdb:	e8 c2 f5 ff ff       	call   c01002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ce0:	c7 04 24 e8 63 10 c0 	movl   $0xc01063e8,(%esp)
c0100ce7:	e8 b6 f5 ff ff       	call   c01002a2 <cprintf>

    if (tf != NULL) {
c0100cec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cf0:	74 0b                	je     c0100cfd <kmonitor+0x2f>
        print_trapframe(tf);
c0100cf2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf5:	89 04 24             	mov    %eax,(%esp)
c0100cf8:	e8 b4 0d 00 00       	call   c0101ab1 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cfd:	c7 04 24 0d 64 10 c0 	movl   $0xc010640d,(%esp)
c0100d04:	e8 3b f6 ff ff       	call   c0100344 <readline>
c0100d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d10:	74 eb                	je     c0100cfd <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d12:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d1c:	89 04 24             	mov    %eax,(%esp)
c0100d1f:	e8 f5 fe ff ff       	call   c0100c19 <runcmd>
c0100d24:	85 c0                	test   %eax,%eax
c0100d26:	78 02                	js     c0100d2a <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d28:	eb d3                	jmp    c0100cfd <kmonitor+0x2f>
                break;
c0100d2a:	90                   	nop
            }
        }
    }
}
c0100d2b:	90                   	nop
c0100d2c:	c9                   	leave  
c0100d2d:	c3                   	ret    

c0100d2e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d2e:	55                   	push   %ebp
c0100d2f:	89 e5                	mov    %esp,%ebp
c0100d31:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d3b:	eb 3d                	jmp    c0100d7a <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d40:	89 d0                	mov    %edx,%eax
c0100d42:	01 c0                	add    %eax,%eax
c0100d44:	01 d0                	add    %edx,%eax
c0100d46:	c1 e0 02             	shl    $0x2,%eax
c0100d49:	05 04 80 11 c0       	add    $0xc0118004,%eax
c0100d4e:	8b 08                	mov    (%eax),%ecx
c0100d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d53:	89 d0                	mov    %edx,%eax
c0100d55:	01 c0                	add    %eax,%eax
c0100d57:	01 d0                	add    %edx,%eax
c0100d59:	c1 e0 02             	shl    $0x2,%eax
c0100d5c:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100d61:	8b 00                	mov    (%eax),%eax
c0100d63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6b:	c7 04 24 11 64 10 c0 	movl   $0xc0106411,(%esp)
c0100d72:	e8 2b f5 ff ff       	call   c01002a2 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d77:	ff 45 f4             	incl   -0xc(%ebp)
c0100d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d7d:	83 f8 02             	cmp    $0x2,%eax
c0100d80:	76 bb                	jbe    c0100d3d <mon_help+0xf>
    }
    return 0;
c0100d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d87:	c9                   	leave  
c0100d88:	c3                   	ret    

c0100d89 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d89:	55                   	push   %ebp
c0100d8a:	89 e5                	mov    %esp,%ebp
c0100d8c:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d8f:	e8 b4 fb ff ff       	call   c0100948 <print_kerninfo>
    return 0;
c0100d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d99:	c9                   	leave  
c0100d9a:	c3                   	ret    

c0100d9b <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d9b:	55                   	push   %ebp
c0100d9c:	89 e5                	mov    %esp,%ebp
c0100d9e:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100da1:	e8 ed fc ff ff       	call   c0100a93 <print_stackframe>
    return 0;
c0100da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dab:	c9                   	leave  
c0100dac:	c3                   	ret    

c0100dad <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dad:	55                   	push   %ebp
c0100dae:	89 e5                	mov    %esp,%ebp
c0100db0:	83 ec 28             	sub    $0x28,%esp
c0100db3:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100db9:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dbd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dc1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dc5:	ee                   	out    %al,(%dx)
c0100dc6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dcc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dd0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd8:	ee                   	out    %al,(%dx)
c0100dd9:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100ddf:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
c0100de3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100de7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100deb:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dec:	c7 05 0c bf 11 c0 00 	movl   $0x0,0xc011bf0c
c0100df3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df6:	c7 04 24 1a 64 10 c0 	movl   $0xc010641a,(%esp)
c0100dfd:	e8 a0 f4 ff ff       	call   c01002a2 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e09:	e8 2e 09 00 00       	call   c010173c <pic_enable>
}
c0100e0e:	90                   	nop
c0100e0f:	c9                   	leave  
c0100e10:	c3                   	ret    

c0100e11 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {     //TS自旋锁机制
c0100e11:	55                   	push   %ebp
c0100e12:	89 e5                	mov    %esp,%ebp
c0100e14:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {   //保存标志寄存器的值
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e17:	9c                   	pushf  
c0100e18:	58                   	pop    %eax
c0100e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
c0100e1f:	25 00 02 00 00       	and    $0x200,%eax
c0100e24:	85 c0                	test   %eax,%eax
c0100e26:	74 0c                	je     c0100e34 <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
c0100e28:	e8 83 0a 00 00       	call   c01018b0 <intr_disable>
        return 1;
c0100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e32:	eb 05                	jmp    c0100e39 <__intr_save+0x28>
    }
    return 0;       //否则表明中断标志位为0
c0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e39:	c9                   	leave  
c0100e3a:	c3                   	ret    

c0100e3b <__intr_restore>:

static inline void
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
c0100e3b:	55                   	push   %ebp
c0100e3c:	89 e5                	mov    %esp,%ebp
c0100e3e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e45:	74 05                	je     c0100e4c <__intr_restore+0x11>
        intr_enable();
c0100e47:	e8 5d 0a 00 00       	call   c01018a9 <intr_enable>
    }
}
c0100e4c:	90                   	nop
c0100e4d:	c9                   	leave  
c0100e4e:	c3                   	ret    

c0100e4f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e4f:	55                   	push   %ebp
c0100e50:	89 e5                	mov    %esp,%ebp
c0100e52:	83 ec 10             	sub    $0x10,%esp
c0100e55:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e5b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	89 c2                	mov    %eax,%edx
c0100e71:	ec                   	in     (%dx),%al
c0100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e75:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e7b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e85:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e8b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e8f:	89 c2                	mov    %eax,%edx
c0100e91:	ec                   	in     (%dx),%al
c0100e92:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e95:	90                   	nop
c0100e96:	c9                   	leave  
c0100e97:	c3                   	ret    

c0100e98 <cga_init>:
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e98:	55                   	push   %ebp
c0100e99:	89 e5                	mov    %esp,%ebp
c0100e9b:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e9e:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea8:	0f b7 00             	movzwl (%eax),%eax
c0100eab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eba:	0f b7 00             	movzwl (%eax),%eax
c0100ebd:	0f b7 c0             	movzwl %ax,%eax
c0100ec0:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ec5:	74 12                	je     c0100ed9 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ece:	66 c7 05 46 b4 11 c0 	movw   $0x3b4,0xc011b446
c0100ed5:	b4 03 
c0100ed7:	eb 13                	jmp    c0100eec <cga_init+0x54>
    } else {
        *cp = was;
c0100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee3:	66 c7 05 46 b4 11 c0 	movw   $0x3d4,0xc011b446
c0100eea:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);
c0100eec:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100ef3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ef7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100efb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100eff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f03:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f04:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f0b:	40                   	inc    %eax
c0100f0c:	0f b7 c0             	movzwl %ax,%eax
c0100f0f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f13:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f17:	89 c2                	mov    %eax,%edx
c0100f19:	ec                   	in     (%dx),%al
c0100f1a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f1d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f21:	0f b6 c0             	movzbl %al,%eax
c0100f24:	c1 e0 08             	shl    $0x8,%eax
c0100f27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f2a:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f41:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f42:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f49:	40                   	inc    %eax
c0100f4a:	0f b7 c0             	movzwl %ax,%eax
c0100f4d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f51:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f55:	89 c2                	mov    %eax,%edx
c0100f57:	ec                   	in     (%dx),%al
c0100f58:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f5b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f5f:	0f b6 c0             	movzbl %al,%eax
c0100f62:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f68:	a3 40 b4 11 c0       	mov    %eax,0xc011b440
    crt_pos = pos;
c0100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f70:	0f b7 c0             	movzwl %ax,%eax
c0100f73:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
}
c0100f79:	90                   	nop
c0100f7a:	c9                   	leave  
c0100f7b:	c3                   	ret    

c0100f7c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f7c:	55                   	push   %ebp
c0100f7d:	89 e5                	mov    %esp,%ebp
c0100f7f:	83 ec 48             	sub    $0x48,%esp
c0100f82:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100f88:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100f94:	ee                   	out    %al,(%dx)
c0100f95:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100f9b:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
c0100f9f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fa3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fa7:	ee                   	out    %al,(%dx)
c0100fa8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fae:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
c0100fb2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fb6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fba:	ee                   	out    %al,(%dx)
c0100fbb:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fc1:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fc5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fc9:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fcd:	ee                   	out    %al,(%dx)
c0100fce:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100fd4:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
c0100fd8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fdc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe0:	ee                   	out    %al,(%dx)
c0100fe1:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0100fe7:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
c0100feb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fef:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100ff3:	ee                   	out    %al,(%dx)
c0100ff4:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100ffa:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
c0100ffe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101002:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101006:	ee                   	out    %al,(%dx)
c0101007:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101011:	89 c2                	mov    %eax,%edx
c0101013:	ec                   	in     (%dx),%al
c0101014:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101017:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010101b:	3c ff                	cmp    $0xff,%al
c010101d:	0f 95 c0             	setne  %al
c0101020:	0f b6 c0             	movzbl %al,%eax
c0101023:	a3 48 b4 11 c0       	mov    %eax,0xc011b448
c0101028:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101032:	89 c2                	mov    %eax,%edx
c0101034:	ec                   	in     (%dx),%al
c0101035:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101038:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010103e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101042:	89 c2                	mov    %eax,%edx
c0101044:	ec                   	in     (%dx),%al
c0101045:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101048:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c010104d:	85 c0                	test   %eax,%eax
c010104f:	74 0c                	je     c010105d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101051:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101058:	e8 df 06 00 00       	call   c010173c <pic_enable>
    }
}
c010105d:	90                   	nop
c010105e:	c9                   	leave  
c010105f:	c3                   	ret    

c0101060 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101060:	55                   	push   %ebp
c0101061:	89 e5                	mov    %esp,%ebp
c0101063:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101066:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010106d:	eb 08                	jmp    c0101077 <lpt_putc_sub+0x17>
        delay();
c010106f:	e8 db fd ff ff       	call   c0100e4f <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101074:	ff 45 fc             	incl   -0x4(%ebp)
c0101077:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010107d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101081:	89 c2                	mov    %eax,%edx
c0101083:	ec                   	in     (%dx),%al
c0101084:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101087:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010108b:	84 c0                	test   %al,%al
c010108d:	78 09                	js     c0101098 <lpt_putc_sub+0x38>
c010108f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101096:	7e d7                	jle    c010106f <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c0101098:	8b 45 08             	mov    0x8(%ebp),%eax
c010109b:	0f b6 c0             	movzbl %al,%eax
c010109e:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010a4:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010a7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010ab:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010af:	ee                   	out    %al,(%dx)
c01010b0:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010b6:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ba:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010be:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010c2:	ee                   	out    %al,(%dx)
c01010c3:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010c9:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
c01010cd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010d1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010d5:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010d6:	90                   	nop
c01010d7:	c9                   	leave  
c01010d8:	c3                   	ret    

c01010d9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010d9:	55                   	push   %ebp
c01010da:	89 e5                	mov    %esp,%ebp
c01010dc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010df:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010e3:	74 0d                	je     c01010f2 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010e8:	89 04 24             	mov    %eax,(%esp)
c01010eb:	e8 70 ff ff ff       	call   c0101060 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010f0:	eb 24                	jmp    c0101116 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c01010f2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f9:	e8 62 ff ff ff       	call   c0101060 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101105:	e8 56 ff ff ff       	call   c0101060 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010110a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101111:	e8 4a ff ff ff       	call   c0101060 <lpt_putc_sub>
}
c0101116:	90                   	nop
c0101117:	c9                   	leave  
c0101118:	c3                   	ret    

c0101119 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101119:	55                   	push   %ebp
c010111a:	89 e5                	mov    %esp,%ebp
c010111c:	53                   	push   %ebx
c010111d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101120:	8b 45 08             	mov    0x8(%ebp),%eax
c0101123:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101128:	85 c0                	test   %eax,%eax
c010112a:	75 07                	jne    c0101133 <cga_putc+0x1a>
        c |= 0x0700;
c010112c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101133:	8b 45 08             	mov    0x8(%ebp),%eax
c0101136:	0f b6 c0             	movzbl %al,%eax
c0101139:	83 f8 0a             	cmp    $0xa,%eax
c010113c:	74 55                	je     c0101193 <cga_putc+0x7a>
c010113e:	83 f8 0d             	cmp    $0xd,%eax
c0101141:	74 63                	je     c01011a6 <cga_putc+0x8d>
c0101143:	83 f8 08             	cmp    $0x8,%eax
c0101146:	0f 85 94 00 00 00    	jne    c01011e0 <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c010114c:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101153:	85 c0                	test   %eax,%eax
c0101155:	0f 84 af 00 00 00    	je     c010120a <cga_putc+0xf1>
            crt_pos --;
c010115b:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101162:	48                   	dec    %eax
c0101163:	0f b7 c0             	movzwl %ax,%eax
c0101166:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010116c:	8b 45 08             	mov    0x8(%ebp),%eax
c010116f:	98                   	cwtl   
c0101170:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101175:	98                   	cwtl   
c0101176:	83 c8 20             	or     $0x20,%eax
c0101179:	98                   	cwtl   
c010117a:	8b 15 40 b4 11 c0    	mov    0xc011b440,%edx
c0101180:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c0101187:	01 c9                	add    %ecx,%ecx
c0101189:	01 ca                	add    %ecx,%edx
c010118b:	0f b7 c0             	movzwl %ax,%eax
c010118e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101191:	eb 77                	jmp    c010120a <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101193:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010119a:	83 c0 50             	add    $0x50,%eax
c010119d:	0f b7 c0             	movzwl %ax,%eax
c01011a0:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011a6:	0f b7 1d 44 b4 11 c0 	movzwl 0xc011b444,%ebx
c01011ad:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c01011b4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011b9:	89 c8                	mov    %ecx,%eax
c01011bb:	f7 e2                	mul    %edx
c01011bd:	c1 ea 06             	shr    $0x6,%edx
c01011c0:	89 d0                	mov    %edx,%eax
c01011c2:	c1 e0 02             	shl    $0x2,%eax
c01011c5:	01 d0                	add    %edx,%eax
c01011c7:	c1 e0 04             	shl    $0x4,%eax
c01011ca:	29 c1                	sub    %eax,%ecx
c01011cc:	89 c8                	mov    %ecx,%eax
c01011ce:	0f b7 c0             	movzwl %ax,%eax
c01011d1:	29 c3                	sub    %eax,%ebx
c01011d3:	89 d8                	mov    %ebx,%eax
c01011d5:	0f b7 c0             	movzwl %ax,%eax
c01011d8:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
        break;
c01011de:	eb 2b                	jmp    c010120b <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011e0:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c01011e6:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011ed:	8d 50 01             	lea    0x1(%eax),%edx
c01011f0:	0f b7 d2             	movzwl %dx,%edx
c01011f3:	66 89 15 44 b4 11 c0 	mov    %dx,0xc011b444
c01011fa:	01 c0                	add    %eax,%eax
c01011fc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101202:	0f b7 c0             	movzwl %ax,%eax
c0101205:	66 89 02             	mov    %ax,(%edx)
        break;
c0101208:	eb 01                	jmp    c010120b <cga_putc+0xf2>
        break;
c010120a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010120b:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101212:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101217:	76 5d                	jbe    c0101276 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101219:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c010121e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101224:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101229:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101230:	00 
c0101231:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101235:	89 04 24             	mov    %eax,(%esp)
c0101238:	e8 03 47 00 00       	call   c0105940 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010123d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101244:	eb 14                	jmp    c010125a <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101246:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c010124b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010124e:	01 d2                	add    %edx,%edx
c0101250:	01 d0                	add    %edx,%eax
c0101252:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101257:	ff 45 f4             	incl   -0xc(%ebp)
c010125a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101261:	7e e3                	jle    c0101246 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
c0101263:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010126a:	83 e8 50             	sub    $0x50,%eax
c010126d:	0f b7 c0             	movzwl %ax,%eax
c0101270:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101276:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c010127d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101281:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101285:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101289:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010128e:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101295:	c1 e8 08             	shr    $0x8,%eax
c0101298:	0f b7 c0             	movzwl %ax,%eax
c010129b:	0f b6 c0             	movzbl %al,%eax
c010129e:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012a5:	42                   	inc    %edx
c01012a6:	0f b7 d2             	movzwl %dx,%edx
c01012a9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012ad:	88 45 e9             	mov    %al,-0x17(%ebp)
c01012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012b9:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012c0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012c4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012d0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012d1:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01012d8:	0f b6 c0             	movzbl %al,%eax
c01012db:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012e2:	42                   	inc    %edx
c01012e3:	0f b7 d2             	movzwl %dx,%edx
c01012e6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01012ea:	88 45 f1             	mov    %al,-0xf(%ebp)
c01012ed:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01012f1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012f5:	ee                   	out    %al,(%dx)
}
c01012f6:	90                   	nop
c01012f7:	83 c4 34             	add    $0x34,%esp
c01012fa:	5b                   	pop    %ebx
c01012fb:	5d                   	pop    %ebp
c01012fc:	c3                   	ret    

c01012fd <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012fd:	55                   	push   %ebp
c01012fe:	89 e5                	mov    %esp,%ebp
c0101300:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101303:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010130a:	eb 08                	jmp    c0101314 <serial_putc_sub+0x17>
        delay();
c010130c:	e8 3e fb ff ff       	call   c0100e4f <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101311:	ff 45 fc             	incl   -0x4(%ebp)
c0101314:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010131a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010131e:	89 c2                	mov    %eax,%edx
c0101320:	ec                   	in     (%dx),%al
c0101321:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101324:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101328:	0f b6 c0             	movzbl %al,%eax
c010132b:	83 e0 20             	and    $0x20,%eax
c010132e:	85 c0                	test   %eax,%eax
c0101330:	75 09                	jne    c010133b <serial_putc_sub+0x3e>
c0101332:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101339:	7e d1                	jle    c010130c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010133b:	8b 45 08             	mov    0x8(%ebp),%eax
c010133e:	0f b6 c0             	movzbl %al,%eax
c0101341:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101347:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010134a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010134e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101352:	ee                   	out    %al,(%dx)
}
c0101353:	90                   	nop
c0101354:	c9                   	leave  
c0101355:	c3                   	ret    

c0101356 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101356:	55                   	push   %ebp
c0101357:	89 e5                	mov    %esp,%ebp
c0101359:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010135c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101360:	74 0d                	je     c010136f <serial_putc+0x19>
        serial_putc_sub(c);
c0101362:	8b 45 08             	mov    0x8(%ebp),%eax
c0101365:	89 04 24             	mov    %eax,(%esp)
c0101368:	e8 90 ff ff ff       	call   c01012fd <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010136d:	eb 24                	jmp    c0101393 <serial_putc+0x3d>
        serial_putc_sub('\b');
c010136f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101376:	e8 82 ff ff ff       	call   c01012fd <serial_putc_sub>
        serial_putc_sub(' ');
c010137b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101382:	e8 76 ff ff ff       	call   c01012fd <serial_putc_sub>
        serial_putc_sub('\b');
c0101387:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010138e:	e8 6a ff ff ff       	call   c01012fd <serial_putc_sub>
}
c0101393:	90                   	nop
c0101394:	c9                   	leave  
c0101395:	c3                   	ret    

c0101396 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101396:	55                   	push   %ebp
c0101397:	89 e5                	mov    %esp,%ebp
c0101399:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010139c:	eb 33                	jmp    c01013d1 <cons_intr+0x3b>
        if (c != 0) {
c010139e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013a2:	74 2d                	je     c01013d1 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013a4:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013a9:	8d 50 01             	lea    0x1(%eax),%edx
c01013ac:	89 15 64 b6 11 c0    	mov    %edx,0xc011b664
c01013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013b5:	88 90 60 b4 11 c0    	mov    %dl,-0x3fee4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013bb:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013c0:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013c5:	75 0a                	jne    c01013d1 <cons_intr+0x3b>
                cons.wpos = 0;
c01013c7:	c7 05 64 b6 11 c0 00 	movl   $0x0,0xc011b664
c01013ce:	00 00 00 
    while ((c = (*proc)()) != -1) {
c01013d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d4:	ff d0                	call   *%eax
c01013d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013d9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013dd:	75 bf                	jne    c010139e <cons_intr+0x8>
            }
        }
    }
}
c01013df:	90                   	nop
c01013e0:	c9                   	leave  
c01013e1:	c3                   	ret    

c01013e2 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013e2:	55                   	push   %ebp
c01013e3:	89 e5                	mov    %esp,%ebp
c01013e5:	83 ec 10             	sub    $0x10,%esp
c01013e8:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ee:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013f2:	89 c2                	mov    %eax,%edx
c01013f4:	ec                   	in     (%dx),%al
c01013f5:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013f8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013fc:	0f b6 c0             	movzbl %al,%eax
c01013ff:	83 e0 01             	and    $0x1,%eax
c0101402:	85 c0                	test   %eax,%eax
c0101404:	75 07                	jne    c010140d <serial_proc_data+0x2b>
        return -1;
c0101406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010140b:	eb 2a                	jmp    c0101437 <serial_proc_data+0x55>
c010140d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101413:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101417:	89 c2                	mov    %eax,%edx
c0101419:	ec                   	in     (%dx),%al
c010141a:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010141d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101421:	0f b6 c0             	movzbl %al,%eax
c0101424:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101427:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010142b:	75 07                	jne    c0101434 <serial_proc_data+0x52>
        c = '\b';
c010142d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101434:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101437:	c9                   	leave  
c0101438:	c3                   	ret    

c0101439 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101439:	55                   	push   %ebp
c010143a:	89 e5                	mov    %esp,%ebp
c010143c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010143f:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101444:	85 c0                	test   %eax,%eax
c0101446:	74 0c                	je     c0101454 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101448:	c7 04 24 e2 13 10 c0 	movl   $0xc01013e2,(%esp)
c010144f:	e8 42 ff ff ff       	call   c0101396 <cons_intr>
    }
}
c0101454:	90                   	nop
c0101455:	c9                   	leave  
c0101456:	c3                   	ret    

c0101457 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101457:	55                   	push   %ebp
c0101458:	89 e5                	mov    %esp,%ebp
c010145a:	83 ec 38             	sub    $0x38,%esp
c010145d:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101463:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101466:	89 c2                	mov    %eax,%edx
c0101468:	ec                   	in     (%dx),%al
c0101469:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010146c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101470:	0f b6 c0             	movzbl %al,%eax
c0101473:	83 e0 01             	and    $0x1,%eax
c0101476:	85 c0                	test   %eax,%eax
c0101478:	75 0a                	jne    c0101484 <kbd_proc_data+0x2d>
        return -1;
c010147a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010147f:	e9 55 01 00 00       	jmp    c01015d9 <kbd_proc_data+0x182>
c0101484:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010148a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010148d:	89 c2                	mov    %eax,%edx
c010148f:	ec                   	in     (%dx),%al
c0101490:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101493:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101497:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010149a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010149e:	75 17                	jne    c01014b7 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014a0:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014a5:	83 c8 40             	or     $0x40,%eax
c01014a8:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014ad:	b8 00 00 00 00       	mov    $0x0,%eax
c01014b2:	e9 22 01 00 00       	jmp    c01015d9 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c01014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bb:	84 c0                	test   %al,%al
c01014bd:	79 45                	jns    c0101504 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014bf:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014c4:	83 e0 40             	and    $0x40,%eax
c01014c7:	85 c0                	test   %eax,%eax
c01014c9:	75 08                	jne    c01014d3 <kbd_proc_data+0x7c>
c01014cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014cf:	24 7f                	and    $0x7f,%al
c01014d1:	eb 04                	jmp    c01014d7 <kbd_proc_data+0x80>
c01014d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d7:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014da:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014de:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c01014e5:	0c 40                	or     $0x40,%al
c01014e7:	0f b6 c0             	movzbl %al,%eax
c01014ea:	f7 d0                	not    %eax
c01014ec:	89 c2                	mov    %eax,%edx
c01014ee:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014f3:	21 d0                	and    %edx,%eax
c01014f5:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014fa:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ff:	e9 d5 00 00 00       	jmp    c01015d9 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c0101504:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101509:	83 e0 40             	and    $0x40,%eax
c010150c:	85 c0                	test   %eax,%eax
c010150e:	74 11                	je     c0101521 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101510:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101514:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101519:	83 e0 bf             	and    $0xffffffbf,%eax
c010151c:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    }

    shift |= shiftcode[data];
c0101521:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101525:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c010152c:	0f b6 d0             	movzbl %al,%edx
c010152f:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101534:	09 d0                	or     %edx,%eax
c0101536:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    shift ^= togglecode[data];
c010153b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010153f:	0f b6 80 40 81 11 c0 	movzbl -0x3fee7ec0(%eax),%eax
c0101546:	0f b6 d0             	movzbl %al,%edx
c0101549:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010154e:	31 d0                	xor    %edx,%eax
c0101550:	a3 68 b6 11 c0       	mov    %eax,0xc011b668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101555:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010155a:	83 e0 03             	and    $0x3,%eax
c010155d:	8b 14 85 40 85 11 c0 	mov    -0x3fee7ac0(,%eax,4),%edx
c0101564:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101568:	01 d0                	add    %edx,%eax
c010156a:	0f b6 00             	movzbl (%eax),%eax
c010156d:	0f b6 c0             	movzbl %al,%eax
c0101570:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101573:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101578:	83 e0 08             	and    $0x8,%eax
c010157b:	85 c0                	test   %eax,%eax
c010157d:	74 22                	je     c01015a1 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c010157f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101583:	7e 0c                	jle    c0101591 <kbd_proc_data+0x13a>
c0101585:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101589:	7f 06                	jg     c0101591 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c010158b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010158f:	eb 10                	jmp    c01015a1 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101591:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101595:	7e 0a                	jle    c01015a1 <kbd_proc_data+0x14a>
c0101597:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010159b:	7f 04                	jg     c01015a1 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010159d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015a1:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01015a6:	f7 d0                	not    %eax
c01015a8:	83 e0 06             	and    $0x6,%eax
c01015ab:	85 c0                	test   %eax,%eax
c01015ad:	75 27                	jne    c01015d6 <kbd_proc_data+0x17f>
c01015af:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015b6:	75 1e                	jne    c01015d6 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c01015b8:	c7 04 24 35 64 10 c0 	movl   $0xc0106435,(%esp)
c01015bf:	e8 de ec ff ff       	call   c01002a2 <cprintf>
c01015c4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015ca:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ce:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015d2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01015d5:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015d9:	c9                   	leave  
c01015da:	c3                   	ret    

c01015db <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015db:	55                   	push   %ebp
c01015dc:	89 e5                	mov    %esp,%ebp
c01015de:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015e1:	c7 04 24 57 14 10 c0 	movl   $0xc0101457,(%esp)
c01015e8:	e8 a9 fd ff ff       	call   c0101396 <cons_intr>
}
c01015ed:	90                   	nop
c01015ee:	c9                   	leave  
c01015ef:	c3                   	ret    

c01015f0 <kbd_init>:

static void
kbd_init(void) {
c01015f0:	55                   	push   %ebp
c01015f1:	89 e5                	mov    %esp,%ebp
c01015f3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015f6:	e8 e0 ff ff ff       	call   c01015db <kbd_intr>
    pic_enable(IRQ_KBD);
c01015fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101602:	e8 35 01 00 00       	call   c010173c <pic_enable>
}
c0101607:	90                   	nop
c0101608:	c9                   	leave  
c0101609:	c3                   	ret    

c010160a <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010160a:	55                   	push   %ebp
c010160b:	89 e5                	mov    %esp,%ebp
c010160d:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101610:	e8 83 f8 ff ff       	call   c0100e98 <cga_init>
    serial_init();
c0101615:	e8 62 f9 ff ff       	call   c0100f7c <serial_init>
    kbd_init();
c010161a:	e8 d1 ff ff ff       	call   c01015f0 <kbd_init>
    if (!serial_exists) {
c010161f:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101624:	85 c0                	test   %eax,%eax
c0101626:	75 0c                	jne    c0101634 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101628:	c7 04 24 41 64 10 c0 	movl   $0xc0106441,(%esp)
c010162f:	e8 6e ec ff ff       	call   c01002a2 <cprintf>
    }
}
c0101634:	90                   	nop
c0101635:	c9                   	leave  
c0101636:	c3                   	ret    

c0101637 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101637:	55                   	push   %ebp
c0101638:	89 e5                	mov    %esp,%ebp
c010163a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010163d:	e8 cf f7 ff ff       	call   c0100e11 <__intr_save>
c0101642:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101645:	8b 45 08             	mov    0x8(%ebp),%eax
c0101648:	89 04 24             	mov    %eax,(%esp)
c010164b:	e8 89 fa ff ff       	call   c01010d9 <lpt_putc>
        cga_putc(c);
c0101650:	8b 45 08             	mov    0x8(%ebp),%eax
c0101653:	89 04 24             	mov    %eax,(%esp)
c0101656:	e8 be fa ff ff       	call   c0101119 <cga_putc>
        serial_putc(c);
c010165b:	8b 45 08             	mov    0x8(%ebp),%eax
c010165e:	89 04 24             	mov    %eax,(%esp)
c0101661:	e8 f0 fc ff ff       	call   c0101356 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101666:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101669:	89 04 24             	mov    %eax,(%esp)
c010166c:	e8 ca f7 ff ff       	call   c0100e3b <__intr_restore>
}
c0101671:	90                   	nop
c0101672:	c9                   	leave  
c0101673:	c3                   	ret    

c0101674 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101674:	55                   	push   %ebp
c0101675:	89 e5                	mov    %esp,%ebp
c0101677:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010167a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101681:	e8 8b f7 ff ff       	call   c0100e11 <__intr_save>
c0101686:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101689:	e8 ab fd ff ff       	call   c0101439 <serial_intr>
        kbd_intr();
c010168e:	e8 48 ff ff ff       	call   c01015db <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101693:	8b 15 60 b6 11 c0    	mov    0xc011b660,%edx
c0101699:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c010169e:	39 c2                	cmp    %eax,%edx
c01016a0:	74 31                	je     c01016d3 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016a2:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c01016a7:	8d 50 01             	lea    0x1(%eax),%edx
c01016aa:	89 15 60 b6 11 c0    	mov    %edx,0xc011b660
c01016b0:	0f b6 80 60 b4 11 c0 	movzbl -0x3fee4ba0(%eax),%eax
c01016b7:	0f b6 c0             	movzbl %al,%eax
c01016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016bd:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c01016c2:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016c7:	75 0a                	jne    c01016d3 <cons_getc+0x5f>
                cons.rpos = 0;
c01016c9:	c7 05 60 b6 11 c0 00 	movl   $0x0,0xc011b660
c01016d0:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016d6:	89 04 24             	mov    %eax,(%esp)
c01016d9:	e8 5d f7 ff ff       	call   c0100e3b <__intr_restore>
    return c;
c01016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016e1:	c9                   	leave  
c01016e2:	c3                   	ret    

c01016e3 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016e3:	55                   	push   %ebp
c01016e4:	89 e5                	mov    %esp,%ebp
c01016e6:	83 ec 14             	sub    $0x14,%esp
c01016e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01016ec:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016f3:	66 a3 50 85 11 c0    	mov    %ax,0xc0118550
    if (did_init) {
c01016f9:	a1 6c b6 11 c0       	mov    0xc011b66c,%eax
c01016fe:	85 c0                	test   %eax,%eax
c0101700:	74 37                	je     c0101739 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101702:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101705:	0f b6 c0             	movzbl %al,%eax
c0101708:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c010170e:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101711:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101715:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101719:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010171a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010171e:	c1 e8 08             	shr    $0x8,%eax
c0101721:	0f b7 c0             	movzwl %ax,%eax
c0101724:	0f b6 c0             	movzbl %al,%eax
c0101727:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010172d:	88 45 fd             	mov    %al,-0x3(%ebp)
c0101730:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101734:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101738:	ee                   	out    %al,(%dx)
    }
}
c0101739:	90                   	nop
c010173a:	c9                   	leave  
c010173b:	c3                   	ret    

c010173c <pic_enable>:

void
pic_enable(unsigned int irq) {
c010173c:	55                   	push   %ebp
c010173d:	89 e5                	mov    %esp,%ebp
c010173f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101742:	8b 45 08             	mov    0x8(%ebp),%eax
c0101745:	ba 01 00 00 00       	mov    $0x1,%edx
c010174a:	88 c1                	mov    %al,%cl
c010174c:	d3 e2                	shl    %cl,%edx
c010174e:	89 d0                	mov    %edx,%eax
c0101750:	98                   	cwtl   
c0101751:	f7 d0                	not    %eax
c0101753:	0f bf d0             	movswl %ax,%edx
c0101756:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010175d:	98                   	cwtl   
c010175e:	21 d0                	and    %edx,%eax
c0101760:	98                   	cwtl   
c0101761:	0f b7 c0             	movzwl %ax,%eax
c0101764:	89 04 24             	mov    %eax,(%esp)
c0101767:	e8 77 ff ff ff       	call   c01016e3 <pic_setmask>
}
c010176c:	90                   	nop
c010176d:	c9                   	leave  
c010176e:	c3                   	ret    

c010176f <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010176f:	55                   	push   %ebp
c0101770:	89 e5                	mov    %esp,%ebp
c0101772:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101775:	c7 05 6c b6 11 c0 01 	movl   $0x1,0xc011b66c
c010177c:	00 00 00 
c010177f:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101785:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
c0101789:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010178d:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101791:	ee                   	out    %al,(%dx)
c0101792:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101798:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
c010179c:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01017a0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01017a4:	ee                   	out    %al,(%dx)
c01017a5:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01017ab:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
c01017af:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017b3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017b7:	ee                   	out    %al,(%dx)
c01017b8:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01017be:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c01017c2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017c6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017ca:	ee                   	out    %al,(%dx)
c01017cb:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01017d1:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
c01017d5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017d9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017dd:	ee                   	out    %al,(%dx)
c01017de:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01017e4:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
c01017e8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017ec:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017f0:	ee                   	out    %al,(%dx)
c01017f1:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01017f7:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
c01017fb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017ff:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101803:	ee                   	out    %al,(%dx)
c0101804:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c010180a:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
c010180e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101812:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101816:	ee                   	out    %al,(%dx)
c0101817:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010181d:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
c0101821:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101825:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101829:	ee                   	out    %al,(%dx)
c010182a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101830:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
c0101834:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101838:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010183c:	ee                   	out    %al,(%dx)
c010183d:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101843:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
c0101847:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010184b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010184f:	ee                   	out    %al,(%dx)
c0101850:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101856:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
c010185a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010185e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101862:	ee                   	out    %al,(%dx)
c0101863:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101869:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
c010186d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101871:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101875:	ee                   	out    %al,(%dx)
c0101876:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010187c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
c0101880:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101884:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101888:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101889:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c0101890:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101895:	74 0f                	je     c01018a6 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101897:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010189e:	89 04 24             	mov    %eax,(%esp)
c01018a1:	e8 3d fe ff ff       	call   c01016e3 <pic_setmask>
    }
}
c01018a6:	90                   	nop
c01018a7:	c9                   	leave  
c01018a8:	c3                   	ret    

c01018a9 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt 打开中断 */
void
intr_enable(void) {
c01018a9:	55                   	push   %ebp
c01018aa:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01018ac:	fb                   	sti    
    sti();
}
c01018ad:	90                   	nop
c01018ae:	5d                   	pop    %ebp
c01018af:	c3                   	ret    

c01018b0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01018b0:	55                   	push   %ebp
c01018b1:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01018b3:	fa                   	cli    
    cli();
}
c01018b4:	90                   	nop
c01018b5:	5d                   	pop    %ebp
c01018b6:	c3                   	ret    

c01018b7 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01018b7:	55                   	push   %ebp
c01018b8:	89 e5                	mov    %esp,%ebp
c01018ba:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01018bd:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018c4:	00 
c01018c5:	c7 04 24 60 64 10 c0 	movl   $0xc0106460,(%esp)
c01018cc:	e8 d1 e9 ff ff       	call   c01002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018d1:	c7 04 24 6a 64 10 c0 	movl   $0xc010646a,(%esp)
c01018d8:	e8 c5 e9 ff ff       	call   c01002a2 <cprintf>
    panic("EOT: kernel seems ok.");
c01018dd:	c7 44 24 08 78 64 10 	movl   $0xc0106478,0x8(%esp)
c01018e4:	c0 
c01018e5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018ec:	00 
c01018ed:	c7 04 24 8e 64 10 c0 	movl   $0xc010648e,(%esp)
c01018f4:	e8 00 eb ff ff       	call   c01003f9 <__panic>

c01018f9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018f9:	55                   	push   %ebp
c01018fa:	89 e5                	mov    %esp,%ebp
c01018fc:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uint32_t __vectors[];
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
c01018ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101906:	e9 c4 00 00 00       	jmp    c01019cf <idt_init+0xd6>
    {
      SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c010190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190e:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101915:	0f b7 d0             	movzwl %ax,%edx
c0101918:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191b:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c0101922:	c0 
c0101923:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101926:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c010192d:	c0 08 00 
c0101930:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101933:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010193a:	c0 
c010193b:	80 e2 e0             	and    $0xe0,%dl
c010193e:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101945:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101948:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010194f:	c0 
c0101950:	80 e2 1f             	and    $0x1f,%dl
c0101953:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c010195a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010195d:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101964:	c0 
c0101965:	80 e2 f0             	and    $0xf0,%dl
c0101968:	80 ca 0e             	or     $0xe,%dl
c010196b:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101972:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101975:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010197c:	c0 
c010197d:	80 e2 ef             	and    $0xef,%dl
c0101980:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101987:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198a:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101991:	c0 
c0101992:	80 e2 9f             	and    $0x9f,%dl
c0101995:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010199f:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c01019a6:	c0 
c01019a7:	80 ca 80             	or     $0x80,%dl
c01019aa:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c01019b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b4:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c01019bb:	c1 e8 10             	shr    $0x10,%eax
c01019be:	0f b7 d0             	movzwl %ax,%edx
c01019c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019c4:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c01019cb:	c0 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
c01019cc:	ff 45 fc             	incl   -0x4(%ebp)
c01019cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d2:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019d7:	0f 86 2e ff ff ff    	jbe    c010190b <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01019dd:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c01019e2:	0f b7 c0             	movzwl %ax,%eax
c01019e5:	66 a3 48 ba 11 c0    	mov    %ax,0xc011ba48
c01019eb:	66 c7 05 4a ba 11 c0 	movw   $0x8,0xc011ba4a
c01019f2:	08 00 
c01019f4:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c01019fb:	24 e0                	and    $0xe0,%al
c01019fd:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c0101a02:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c0101a09:	24 1f                	and    $0x1f,%al
c0101a0b:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c0101a10:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a17:	24 f0                	and    $0xf0,%al
c0101a19:	0c 0e                	or     $0xe,%al
c0101a1b:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a20:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a27:	24 ef                	and    $0xef,%al
c0101a29:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a2e:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a35:	0c 60                	or     $0x60,%al
c0101a37:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a3c:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a43:	0c 80                	or     $0x80,%al
c0101a45:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a4a:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c0101a4f:	c1 e8 10             	shr    $0x10,%eax
c0101a52:	0f b7 c0             	movzwl %ax,%eax
c0101a55:	66 a3 4e ba 11 c0    	mov    %ax,0xc011ba4e
c0101a5b:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a62:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a65:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0101a68:	90                   	nop
c0101a69:	c9                   	leave  
c0101a6a:	c3                   	ret    

c0101a6b <trapname>:

static const char *
trapname(int trapno) {
c0101a6b:	55                   	push   %ebp
c0101a6c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a71:	83 f8 13             	cmp    $0x13,%eax
c0101a74:	77 0c                	ja     c0101a82 <trapname+0x17>
        return excnames[trapno];
c0101a76:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a79:	8b 04 85 e0 67 10 c0 	mov    -0x3fef9820(,%eax,4),%eax
c0101a80:	eb 18                	jmp    c0101a9a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a82:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a86:	7e 0d                	jle    c0101a95 <trapname+0x2a>
c0101a88:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a8c:	7f 07                	jg     c0101a95 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a8e:	b8 9f 64 10 c0       	mov    $0xc010649f,%eax
c0101a93:	eb 05                	jmp    c0101a9a <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a95:	b8 b2 64 10 c0       	mov    $0xc01064b2,%eax
}
c0101a9a:	5d                   	pop    %ebp
c0101a9b:	c3                   	ret    

c0101a9c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a9c:	55                   	push   %ebp
c0101a9d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101aa6:	83 f8 08             	cmp    $0x8,%eax
c0101aa9:	0f 94 c0             	sete   %al
c0101aac:	0f b6 c0             	movzbl %al,%eax
}
c0101aaf:	5d                   	pop    %ebp
c0101ab0:	c3                   	ret    

c0101ab1 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101ab1:	55                   	push   %ebp
c0101ab2:	89 e5                	mov    %esp,%ebp
c0101ab4:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101abe:	c7 04 24 f3 64 10 c0 	movl   $0xc01064f3,(%esp)
c0101ac5:	e8 d8 e7 ff ff       	call   c01002a2 <cprintf>
    print_regs(&tf->tf_regs);
c0101aca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101acd:	89 04 24             	mov    %eax,(%esp)
c0101ad0:	e8 8f 01 00 00       	call   c0101c64 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101adc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae0:	c7 04 24 04 65 10 c0 	movl   $0xc0106504,(%esp)
c0101ae7:	e8 b6 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101aec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aef:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101af3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af7:	c7 04 24 17 65 10 c0 	movl   $0xc0106517,(%esp)
c0101afe:	e8 9f e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b06:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0e:	c7 04 24 2a 65 10 c0 	movl   $0xc010652a,(%esp)
c0101b15:	e8 88 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b25:	c7 04 24 3d 65 10 c0 	movl   $0xc010653d,(%esp)
c0101b2c:	e8 71 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b34:	8b 40 30             	mov    0x30(%eax),%eax
c0101b37:	89 04 24             	mov    %eax,(%esp)
c0101b3a:	e8 2c ff ff ff       	call   c0101a6b <trapname>
c0101b3f:	89 c2                	mov    %eax,%edx
c0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b44:	8b 40 30             	mov    0x30(%eax),%eax
c0101b47:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4f:	c7 04 24 50 65 10 c0 	movl   $0xc0106550,(%esp)
c0101b56:	e8 47 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5e:	8b 40 34             	mov    0x34(%eax),%eax
c0101b61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b65:	c7 04 24 62 65 10 c0 	movl   $0xc0106562,(%esp)
c0101b6c:	e8 31 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b74:	8b 40 38             	mov    0x38(%eax),%eax
c0101b77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7b:	c7 04 24 71 65 10 c0 	movl   $0xc0106571,(%esp)
c0101b82:	e8 1b e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b92:	c7 04 24 80 65 10 c0 	movl   $0xc0106580,(%esp)
c0101b99:	e8 04 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba1:	8b 40 40             	mov    0x40(%eax),%eax
c0101ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba8:	c7 04 24 93 65 10 c0 	movl   $0xc0106593,(%esp)
c0101baf:	e8 ee e6 ff ff       	call   c01002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101bbb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101bc2:	eb 3d                	jmp    c0101c01 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc7:	8b 50 40             	mov    0x40(%eax),%edx
c0101bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bcd:	21 d0                	and    %edx,%eax
c0101bcf:	85 c0                	test   %eax,%eax
c0101bd1:	74 28                	je     c0101bfb <print_trapframe+0x14a>
c0101bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd6:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101bdd:	85 c0                	test   %eax,%eax
c0101bdf:	74 1a                	je     c0101bfb <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101be4:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101beb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bef:	c7 04 24 a2 65 10 c0 	movl   $0xc01065a2,(%esp)
c0101bf6:	e8 a7 e6 ff ff       	call   c01002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bfb:	ff 45 f4             	incl   -0xc(%ebp)
c0101bfe:	d1 65 f0             	shll   -0x10(%ebp)
c0101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c04:	83 f8 17             	cmp    $0x17,%eax
c0101c07:	76 bb                	jbe    c0101bc4 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0c:	8b 40 40             	mov    0x40(%eax),%eax
c0101c0f:	c1 e8 0c             	shr    $0xc,%eax
c0101c12:	83 e0 03             	and    $0x3,%eax
c0101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c19:	c7 04 24 a6 65 10 c0 	movl   $0xc01065a6,(%esp)
c0101c20:	e8 7d e6 ff ff       	call   c01002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c28:	89 04 24             	mov    %eax,(%esp)
c0101c2b:	e8 6c fe ff ff       	call   c0101a9c <trap_in_kernel>
c0101c30:	85 c0                	test   %eax,%eax
c0101c32:	75 2d                	jne    c0101c61 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c37:	8b 40 44             	mov    0x44(%eax),%eax
c0101c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3e:	c7 04 24 af 65 10 c0 	movl   $0xc01065af,(%esp)
c0101c45:	e8 58 e6 ff ff       	call   c01002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c55:	c7 04 24 be 65 10 c0 	movl   $0xc01065be,(%esp)
c0101c5c:	e8 41 e6 ff ff       	call   c01002a2 <cprintf>
    }
}
c0101c61:	90                   	nop
c0101c62:	c9                   	leave  
c0101c63:	c3                   	ret    

c0101c64 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c64:	55                   	push   %ebp
c0101c65:	89 e5                	mov    %esp,%ebp
c0101c67:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6d:	8b 00                	mov    (%eax),%eax
c0101c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c73:	c7 04 24 d1 65 10 c0 	movl   $0xc01065d1,(%esp)
c0101c7a:	e8 23 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c82:	8b 40 04             	mov    0x4(%eax),%eax
c0101c85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c89:	c7 04 24 e0 65 10 c0 	movl   $0xc01065e0,(%esp)
c0101c90:	e8 0d e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c98:	8b 40 08             	mov    0x8(%eax),%eax
c0101c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c9f:	c7 04 24 ef 65 10 c0 	movl   $0xc01065ef,(%esp)
c0101ca6:	e8 f7 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101cab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cae:	8b 40 0c             	mov    0xc(%eax),%eax
c0101cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb5:	c7 04 24 fe 65 10 c0 	movl   $0xc01065fe,(%esp)
c0101cbc:	e8 e1 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc4:	8b 40 10             	mov    0x10(%eax),%eax
c0101cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccb:	c7 04 24 0d 66 10 c0 	movl   $0xc010660d,(%esp)
c0101cd2:	e8 cb e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cda:	8b 40 14             	mov    0x14(%eax),%eax
c0101cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce1:	c7 04 24 1c 66 10 c0 	movl   $0xc010661c,(%esp)
c0101ce8:	e8 b5 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101ced:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf0:	8b 40 18             	mov    0x18(%eax),%eax
c0101cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf7:	c7 04 24 2b 66 10 c0 	movl   $0xc010662b,(%esp)
c0101cfe:	e8 9f e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d06:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0d:	c7 04 24 3a 66 10 c0 	movl   $0xc010663a,(%esp)
c0101d14:	e8 89 e5 ff ff       	call   c01002a2 <cprintf>
}
c0101d19:	90                   	nop
c0101d1a:	c9                   	leave  
c0101d1b:	c3                   	ret    

c0101d1c <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d1c:	55                   	push   %ebp
c0101d1d:	89 e5                	mov    %esp,%ebp
c0101d1f:	57                   	push   %edi
c0101d20:	56                   	push   %esi
c0101d21:	53                   	push   %ebx
c0101d22:	83 ec 7c             	sub    $0x7c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d28:	8b 40 30             	mov    0x30(%eax),%eax
c0101d2b:	83 f8 2f             	cmp    $0x2f,%eax
c0101d2e:	77 21                	ja     c0101d51 <trap_dispatch+0x35>
c0101d30:	83 f8 2e             	cmp    $0x2e,%eax
c0101d33:	0f 83 38 02 00 00    	jae    c0101f71 <trap_dispatch+0x255>
c0101d39:	83 f8 21             	cmp    $0x21,%eax
c0101d3c:	0f 84 95 00 00 00    	je     c0101dd7 <trap_dispatch+0xbb>
c0101d42:	83 f8 24             	cmp    $0x24,%eax
c0101d45:	74 67                	je     c0101dae <trap_dispatch+0x92>
c0101d47:	83 f8 20             	cmp    $0x20,%eax
c0101d4a:	74 1c                	je     c0101d68 <trap_dispatch+0x4c>
c0101d4c:	e9 eb 01 00 00       	jmp    c0101f3c <trap_dispatch+0x220>
c0101d51:	83 f8 78             	cmp    $0x78,%eax
c0101d54:	0f 84 a6 00 00 00    	je     c0101e00 <trap_dispatch+0xe4>
c0101d5a:	83 f8 79             	cmp    $0x79,%eax
c0101d5d:	0f 84 63 01 00 00    	je     c0101ec6 <trap_dispatch+0x1aa>
c0101d63:	e9 d4 01 00 00       	jmp    c0101f3c <trap_dispatch+0x220>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0101d68:	a1 0c bf 11 c0       	mov    0xc011bf0c,%eax
c0101d6d:	40                   	inc    %eax
c0101d6e:	a3 0c bf 11 c0       	mov    %eax,0xc011bf0c
        if(ticks % TICK_NUM == 0 )
c0101d73:	8b 0d 0c bf 11 c0    	mov    0xc011bf0c,%ecx
c0101d79:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d7e:	89 c8                	mov    %ecx,%eax
c0101d80:	f7 e2                	mul    %edx
c0101d82:	c1 ea 05             	shr    $0x5,%edx
c0101d85:	89 d0                	mov    %edx,%eax
c0101d87:	c1 e0 02             	shl    $0x2,%eax
c0101d8a:	01 d0                	add    %edx,%eax
c0101d8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d93:	01 d0                	add    %edx,%eax
c0101d95:	c1 e0 02             	shl    $0x2,%eax
c0101d98:	29 c1                	sub    %eax,%ecx
c0101d9a:	89 ca                	mov    %ecx,%edx
c0101d9c:	85 d2                	test   %edx,%edx
c0101d9e:	0f 85 d0 01 00 00    	jne    c0101f74 <trap_dispatch+0x258>
        {
          print_ticks();
c0101da4:	e8 0e fb ff ff       	call   c01018b7 <print_ticks>
        }
        break;
c0101da9:	e9 c6 01 00 00       	jmp    c0101f74 <trap_dispatch+0x258>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101dae:	e8 c1 f8 ff ff       	call   c0101674 <cons_getc>
c0101db3:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101db6:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0101dba:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0101dbe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dc6:	c7 04 24 49 66 10 c0 	movl   $0xc0106649,(%esp)
c0101dcd:	e8 d0 e4 ff ff       	call   c01002a2 <cprintf>
        break;
c0101dd2:	e9 a4 01 00 00       	jmp    c0101f7b <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101dd7:	e8 98 f8 ff ff       	call   c0101674 <cons_getc>
c0101ddc:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101ddf:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0101de3:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0101de7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101deb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101def:	c7 04 24 5b 66 10 c0 	movl   $0xc010665b,(%esp)
c0101df6:	e8 a7 e4 ff ff       	call   c01002a2 <cprintf>
        break;
c0101dfb:	e9 7b 01 00 00       	jmp    c0101f7b <trap_dispatch+0x25f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
      if (tf->tf_cs!=USER_CS)
c0101e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e03:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e07:	83 f8 1b             	cmp    $0x1b,%eax
c0101e0a:	0f 84 67 01 00 00    	je     c0101f77 <trap_dispatch+0x25b>
      {
        struct trapframe temp1 = *tf;//保留寄存器值
c0101e10:	8b 55 08             	mov    0x8(%ebp),%edx
c0101e13:	8d 45 97             	lea    -0x69(%ebp),%eax
c0101e16:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0101e1b:	89 c1                	mov    %eax,%ecx
c0101e1d:	83 e1 01             	and    $0x1,%ecx
c0101e20:	85 c9                	test   %ecx,%ecx
c0101e22:	74 0c                	je     c0101e30 <trap_dispatch+0x114>
c0101e24:	0f b6 0a             	movzbl (%edx),%ecx
c0101e27:	88 08                	mov    %cl,(%eax)
c0101e29:	8d 40 01             	lea    0x1(%eax),%eax
c0101e2c:	8d 52 01             	lea    0x1(%edx),%edx
c0101e2f:	4b                   	dec    %ebx
c0101e30:	89 c1                	mov    %eax,%ecx
c0101e32:	83 e1 02             	and    $0x2,%ecx
c0101e35:	85 c9                	test   %ecx,%ecx
c0101e37:	74 0f                	je     c0101e48 <trap_dispatch+0x12c>
c0101e39:	0f b7 0a             	movzwl (%edx),%ecx
c0101e3c:	66 89 08             	mov    %cx,(%eax)
c0101e3f:	8d 40 02             	lea    0x2(%eax),%eax
c0101e42:	8d 52 02             	lea    0x2(%edx),%edx
c0101e45:	83 eb 02             	sub    $0x2,%ebx
c0101e48:	89 df                	mov    %ebx,%edi
c0101e4a:	83 e7 fc             	and    $0xfffffffc,%edi
c0101e4d:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101e52:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0101e55:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0101e58:	83 c1 04             	add    $0x4,%ecx
c0101e5b:	39 f9                	cmp    %edi,%ecx
c0101e5d:	72 f3                	jb     c0101e52 <trap_dispatch+0x136>
c0101e5f:	01 c8                	add    %ecx,%eax
c0101e61:	01 ca                	add    %ecx,%edx
c0101e63:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101e68:	89 de                	mov    %ebx,%esi
c0101e6a:	83 e6 02             	and    $0x2,%esi
c0101e6d:	85 f6                	test   %esi,%esi
c0101e6f:	74 0b                	je     c0101e7c <trap_dispatch+0x160>
c0101e71:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0101e75:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0101e79:	83 c1 02             	add    $0x2,%ecx
c0101e7c:	83 e3 01             	and    $0x1,%ebx
c0101e7f:	85 db                	test   %ebx,%ebx
c0101e81:	74 07                	je     c0101e8a <trap_dispatch+0x16e>
c0101e83:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0101e87:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        temp1.tf_cs = USER_CS;
c0101e8a:	66 c7 45 d3 1b 00    	movw   $0x1b,-0x2d(%ebp)
        temp1.tf_es = USER_DS;
c0101e90:	66 c7 45 bf 23 00    	movw   $0x23,-0x41(%ebp)
        temp1.tf_ds=USER_DS;
c0101e96:	66 c7 45 c3 23 00    	movw   $0x23,-0x3d(%ebp)
        temp1.tf_ss = USER_DS;
c0101e9c:	66 c7 45 df 23 00    	movw   $0x23,-0x21(%ebp)
        temp1.tf_esp=(uint32_t)tf+sizeof(struct trapframe) -8;
c0101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea5:	83 c0 44             	add    $0x44,%eax
c0101ea8:	89 45 db             	mov    %eax,-0x25(%ebp)

        temp1.tf_eflags |=FL_IOPL_MASK;
c0101eab:	8b 45 d7             	mov    -0x29(%ebp),%eax
c0101eae:	0d 00 30 00 00       	or     $0x3000,%eax
c0101eb3:	89 45 d7             	mov    %eax,-0x29(%ebp)

        *((uint32_t *)tf -1) = (uint32_t) &temp1;
c0101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb9:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101ebc:	8d 45 97             	lea    -0x69(%ebp),%eax
c0101ebf:	89 02                	mov    %eax,(%edx)
      }
      break;
c0101ec1:	e9 b1 00 00 00       	jmp    c0101f77 <trap_dispatch+0x25b>
    case T_SWITCH_TOK:
    if (tf->tf_cs != KERNEL_CS) {
c0101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ecd:	83 f8 08             	cmp    $0x8,%eax
c0101ed0:	0f 84 a4 00 00 00    	je     c0101f7a <trap_dispatch+0x25e>
        tf->tf_cs = KERNEL_CS;
c0101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed9:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101edf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101ee8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eeb:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101eef:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef2:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef9:	8b 40 40             	mov    0x40(%eax),%eax
c0101efc:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101f01:	89 c2                	mov    %eax,%edx
c0101f03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f06:	89 50 40             	mov    %edx,0x40(%eax)
        struct trapframe*  temp2 = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101f09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f0c:	8b 40 44             	mov    0x44(%eax),%eax
c0101f0f:	83 e8 44             	sub    $0x44,%eax
c0101f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        memmove(temp2, tf, sizeof(struct trapframe) - 8);
c0101f15:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101f1c:	00 
c0101f1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101f27:	89 04 24             	mov    %eax,(%esp)
c0101f2a:	e8 11 3a 00 00       	call   c0105940 <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)temp2;
c0101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f32:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101f38:	89 02                	mov    %eax,(%edx)
    }
        break;
c0101f3a:	eb 3e                	jmp    c0101f7a <trap_dispatch+0x25e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f43:	83 e0 03             	and    $0x3,%eax
c0101f46:	85 c0                	test   %eax,%eax
c0101f48:	75 31                	jne    c0101f7b <trap_dispatch+0x25f>
            print_trapframe(tf);
c0101f4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f4d:	89 04 24             	mov    %eax,(%esp)
c0101f50:	e8 5c fb ff ff       	call   c0101ab1 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101f55:	c7 44 24 08 6a 66 10 	movl   $0xc010666a,0x8(%esp)
c0101f5c:	c0 
c0101f5d:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0101f64:	00 
c0101f65:	c7 04 24 8e 64 10 c0 	movl   $0xc010648e,(%esp)
c0101f6c:	e8 88 e4 ff ff       	call   c01003f9 <__panic>
        break;
c0101f71:	90                   	nop
c0101f72:	eb 07                	jmp    c0101f7b <trap_dispatch+0x25f>
        break;
c0101f74:	90                   	nop
c0101f75:	eb 04                	jmp    c0101f7b <trap_dispatch+0x25f>
      break;
c0101f77:	90                   	nop
c0101f78:	eb 01                	jmp    c0101f7b <trap_dispatch+0x25f>
        break;
c0101f7a:	90                   	nop
        }
    }
}
c0101f7b:	90                   	nop
c0101f7c:	83 c4 7c             	add    $0x7c,%esp
c0101f7f:	5b                   	pop    %ebx
c0101f80:	5e                   	pop    %esi
c0101f81:	5f                   	pop    %edi
c0101f82:	5d                   	pop    %ebp
c0101f83:	c3                   	ret    

c0101f84 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101f84:	55                   	push   %ebp
c0101f85:	89 e5                	mov    %esp,%ebp
c0101f87:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8d:	89 04 24             	mov    %eax,(%esp)
c0101f90:	e8 87 fd ff ff       	call   c0101d1c <trap_dispatch>
}
c0101f95:	90                   	nop
c0101f96:	c9                   	leave  
c0101f97:	c3                   	ret    

c0101f98 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f98:	6a 00                	push   $0x0
  pushl $0
c0101f9a:	6a 00                	push   $0x0
  jmp __alltraps
c0101f9c:	e9 69 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fa1 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101fa1:	6a 00                	push   $0x0
  pushl $1
c0101fa3:	6a 01                	push   $0x1
  jmp __alltraps
c0101fa5:	e9 60 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101faa <vector2>:
.globl vector2
vector2:
  pushl $0
c0101faa:	6a 00                	push   $0x0
  pushl $2
c0101fac:	6a 02                	push   $0x2
  jmp __alltraps
c0101fae:	e9 57 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fb3 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101fb3:	6a 00                	push   $0x0
  pushl $3
c0101fb5:	6a 03                	push   $0x3
  jmp __alltraps
c0101fb7:	e9 4e 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fbc <vector4>:
.globl vector4
vector4:
  pushl $0
c0101fbc:	6a 00                	push   $0x0
  pushl $4
c0101fbe:	6a 04                	push   $0x4
  jmp __alltraps
c0101fc0:	e9 45 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fc5 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101fc5:	6a 00                	push   $0x0
  pushl $5
c0101fc7:	6a 05                	push   $0x5
  jmp __alltraps
c0101fc9:	e9 3c 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fce <vector6>:
.globl vector6
vector6:
  pushl $0
c0101fce:	6a 00                	push   $0x0
  pushl $6
c0101fd0:	6a 06                	push   $0x6
  jmp __alltraps
c0101fd2:	e9 33 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fd7 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101fd7:	6a 00                	push   $0x0
  pushl $7
c0101fd9:	6a 07                	push   $0x7
  jmp __alltraps
c0101fdb:	e9 2a 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fe0 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101fe0:	6a 08                	push   $0x8
  jmp __alltraps
c0101fe2:	e9 23 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101fe7 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101fe7:	6a 00                	push   $0x0
  pushl $9
c0101fe9:	6a 09                	push   $0x9
  jmp __alltraps
c0101feb:	e9 1a 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101ff0 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101ff0:	6a 0a                	push   $0xa
  jmp __alltraps
c0101ff2:	e9 13 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101ff7 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101ff7:	6a 0b                	push   $0xb
  jmp __alltraps
c0101ff9:	e9 0c 0a 00 00       	jmp    c0102a0a <__alltraps>

c0101ffe <vector12>:
.globl vector12
vector12:
  pushl $12
c0101ffe:	6a 0c                	push   $0xc
  jmp __alltraps
c0102000:	e9 05 0a 00 00       	jmp    c0102a0a <__alltraps>

c0102005 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102005:	6a 0d                	push   $0xd
  jmp __alltraps
c0102007:	e9 fe 09 00 00       	jmp    c0102a0a <__alltraps>

c010200c <vector14>:
.globl vector14
vector14:
  pushl $14
c010200c:	6a 0e                	push   $0xe
  jmp __alltraps
c010200e:	e9 f7 09 00 00       	jmp    c0102a0a <__alltraps>

c0102013 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102013:	6a 00                	push   $0x0
  pushl $15
c0102015:	6a 0f                	push   $0xf
  jmp __alltraps
c0102017:	e9 ee 09 00 00       	jmp    c0102a0a <__alltraps>

c010201c <vector16>:
.globl vector16
vector16:
  pushl $0
c010201c:	6a 00                	push   $0x0
  pushl $16
c010201e:	6a 10                	push   $0x10
  jmp __alltraps
c0102020:	e9 e5 09 00 00       	jmp    c0102a0a <__alltraps>

c0102025 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102025:	6a 11                	push   $0x11
  jmp __alltraps
c0102027:	e9 de 09 00 00       	jmp    c0102a0a <__alltraps>

c010202c <vector18>:
.globl vector18
vector18:
  pushl $0
c010202c:	6a 00                	push   $0x0
  pushl $18
c010202e:	6a 12                	push   $0x12
  jmp __alltraps
c0102030:	e9 d5 09 00 00       	jmp    c0102a0a <__alltraps>

c0102035 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102035:	6a 00                	push   $0x0
  pushl $19
c0102037:	6a 13                	push   $0x13
  jmp __alltraps
c0102039:	e9 cc 09 00 00       	jmp    c0102a0a <__alltraps>

c010203e <vector20>:
.globl vector20
vector20:
  pushl $0
c010203e:	6a 00                	push   $0x0
  pushl $20
c0102040:	6a 14                	push   $0x14
  jmp __alltraps
c0102042:	e9 c3 09 00 00       	jmp    c0102a0a <__alltraps>

c0102047 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102047:	6a 00                	push   $0x0
  pushl $21
c0102049:	6a 15                	push   $0x15
  jmp __alltraps
c010204b:	e9 ba 09 00 00       	jmp    c0102a0a <__alltraps>

c0102050 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102050:	6a 00                	push   $0x0
  pushl $22
c0102052:	6a 16                	push   $0x16
  jmp __alltraps
c0102054:	e9 b1 09 00 00       	jmp    c0102a0a <__alltraps>

c0102059 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102059:	6a 00                	push   $0x0
  pushl $23
c010205b:	6a 17                	push   $0x17
  jmp __alltraps
c010205d:	e9 a8 09 00 00       	jmp    c0102a0a <__alltraps>

c0102062 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102062:	6a 00                	push   $0x0
  pushl $24
c0102064:	6a 18                	push   $0x18
  jmp __alltraps
c0102066:	e9 9f 09 00 00       	jmp    c0102a0a <__alltraps>

c010206b <vector25>:
.globl vector25
vector25:
  pushl $0
c010206b:	6a 00                	push   $0x0
  pushl $25
c010206d:	6a 19                	push   $0x19
  jmp __alltraps
c010206f:	e9 96 09 00 00       	jmp    c0102a0a <__alltraps>

c0102074 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102074:	6a 00                	push   $0x0
  pushl $26
c0102076:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102078:	e9 8d 09 00 00       	jmp    c0102a0a <__alltraps>

c010207d <vector27>:
.globl vector27
vector27:
  pushl $0
c010207d:	6a 00                	push   $0x0
  pushl $27
c010207f:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102081:	e9 84 09 00 00       	jmp    c0102a0a <__alltraps>

c0102086 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102086:	6a 00                	push   $0x0
  pushl $28
c0102088:	6a 1c                	push   $0x1c
  jmp __alltraps
c010208a:	e9 7b 09 00 00       	jmp    c0102a0a <__alltraps>

c010208f <vector29>:
.globl vector29
vector29:
  pushl $0
c010208f:	6a 00                	push   $0x0
  pushl $29
c0102091:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102093:	e9 72 09 00 00       	jmp    c0102a0a <__alltraps>

c0102098 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102098:	6a 00                	push   $0x0
  pushl $30
c010209a:	6a 1e                	push   $0x1e
  jmp __alltraps
c010209c:	e9 69 09 00 00       	jmp    c0102a0a <__alltraps>

c01020a1 <vector31>:
.globl vector31
vector31:
  pushl $0
c01020a1:	6a 00                	push   $0x0
  pushl $31
c01020a3:	6a 1f                	push   $0x1f
  jmp __alltraps
c01020a5:	e9 60 09 00 00       	jmp    c0102a0a <__alltraps>

c01020aa <vector32>:
.globl vector32
vector32:
  pushl $0
c01020aa:	6a 00                	push   $0x0
  pushl $32
c01020ac:	6a 20                	push   $0x20
  jmp __alltraps
c01020ae:	e9 57 09 00 00       	jmp    c0102a0a <__alltraps>

c01020b3 <vector33>:
.globl vector33
vector33:
  pushl $0
c01020b3:	6a 00                	push   $0x0
  pushl $33
c01020b5:	6a 21                	push   $0x21
  jmp __alltraps
c01020b7:	e9 4e 09 00 00       	jmp    c0102a0a <__alltraps>

c01020bc <vector34>:
.globl vector34
vector34:
  pushl $0
c01020bc:	6a 00                	push   $0x0
  pushl $34
c01020be:	6a 22                	push   $0x22
  jmp __alltraps
c01020c0:	e9 45 09 00 00       	jmp    c0102a0a <__alltraps>

c01020c5 <vector35>:
.globl vector35
vector35:
  pushl $0
c01020c5:	6a 00                	push   $0x0
  pushl $35
c01020c7:	6a 23                	push   $0x23
  jmp __alltraps
c01020c9:	e9 3c 09 00 00       	jmp    c0102a0a <__alltraps>

c01020ce <vector36>:
.globl vector36
vector36:
  pushl $0
c01020ce:	6a 00                	push   $0x0
  pushl $36
c01020d0:	6a 24                	push   $0x24
  jmp __alltraps
c01020d2:	e9 33 09 00 00       	jmp    c0102a0a <__alltraps>

c01020d7 <vector37>:
.globl vector37
vector37:
  pushl $0
c01020d7:	6a 00                	push   $0x0
  pushl $37
c01020d9:	6a 25                	push   $0x25
  jmp __alltraps
c01020db:	e9 2a 09 00 00       	jmp    c0102a0a <__alltraps>

c01020e0 <vector38>:
.globl vector38
vector38:
  pushl $0
c01020e0:	6a 00                	push   $0x0
  pushl $38
c01020e2:	6a 26                	push   $0x26
  jmp __alltraps
c01020e4:	e9 21 09 00 00       	jmp    c0102a0a <__alltraps>

c01020e9 <vector39>:
.globl vector39
vector39:
  pushl $0
c01020e9:	6a 00                	push   $0x0
  pushl $39
c01020eb:	6a 27                	push   $0x27
  jmp __alltraps
c01020ed:	e9 18 09 00 00       	jmp    c0102a0a <__alltraps>

c01020f2 <vector40>:
.globl vector40
vector40:
  pushl $0
c01020f2:	6a 00                	push   $0x0
  pushl $40
c01020f4:	6a 28                	push   $0x28
  jmp __alltraps
c01020f6:	e9 0f 09 00 00       	jmp    c0102a0a <__alltraps>

c01020fb <vector41>:
.globl vector41
vector41:
  pushl $0
c01020fb:	6a 00                	push   $0x0
  pushl $41
c01020fd:	6a 29                	push   $0x29
  jmp __alltraps
c01020ff:	e9 06 09 00 00       	jmp    c0102a0a <__alltraps>

c0102104 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102104:	6a 00                	push   $0x0
  pushl $42
c0102106:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102108:	e9 fd 08 00 00       	jmp    c0102a0a <__alltraps>

c010210d <vector43>:
.globl vector43
vector43:
  pushl $0
c010210d:	6a 00                	push   $0x0
  pushl $43
c010210f:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102111:	e9 f4 08 00 00       	jmp    c0102a0a <__alltraps>

c0102116 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102116:	6a 00                	push   $0x0
  pushl $44
c0102118:	6a 2c                	push   $0x2c
  jmp __alltraps
c010211a:	e9 eb 08 00 00       	jmp    c0102a0a <__alltraps>

c010211f <vector45>:
.globl vector45
vector45:
  pushl $0
c010211f:	6a 00                	push   $0x0
  pushl $45
c0102121:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102123:	e9 e2 08 00 00       	jmp    c0102a0a <__alltraps>

c0102128 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102128:	6a 00                	push   $0x0
  pushl $46
c010212a:	6a 2e                	push   $0x2e
  jmp __alltraps
c010212c:	e9 d9 08 00 00       	jmp    c0102a0a <__alltraps>

c0102131 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102131:	6a 00                	push   $0x0
  pushl $47
c0102133:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102135:	e9 d0 08 00 00       	jmp    c0102a0a <__alltraps>

c010213a <vector48>:
.globl vector48
vector48:
  pushl $0
c010213a:	6a 00                	push   $0x0
  pushl $48
c010213c:	6a 30                	push   $0x30
  jmp __alltraps
c010213e:	e9 c7 08 00 00       	jmp    c0102a0a <__alltraps>

c0102143 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102143:	6a 00                	push   $0x0
  pushl $49
c0102145:	6a 31                	push   $0x31
  jmp __alltraps
c0102147:	e9 be 08 00 00       	jmp    c0102a0a <__alltraps>

c010214c <vector50>:
.globl vector50
vector50:
  pushl $0
c010214c:	6a 00                	push   $0x0
  pushl $50
c010214e:	6a 32                	push   $0x32
  jmp __alltraps
c0102150:	e9 b5 08 00 00       	jmp    c0102a0a <__alltraps>

c0102155 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102155:	6a 00                	push   $0x0
  pushl $51
c0102157:	6a 33                	push   $0x33
  jmp __alltraps
c0102159:	e9 ac 08 00 00       	jmp    c0102a0a <__alltraps>

c010215e <vector52>:
.globl vector52
vector52:
  pushl $0
c010215e:	6a 00                	push   $0x0
  pushl $52
c0102160:	6a 34                	push   $0x34
  jmp __alltraps
c0102162:	e9 a3 08 00 00       	jmp    c0102a0a <__alltraps>

c0102167 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102167:	6a 00                	push   $0x0
  pushl $53
c0102169:	6a 35                	push   $0x35
  jmp __alltraps
c010216b:	e9 9a 08 00 00       	jmp    c0102a0a <__alltraps>

c0102170 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102170:	6a 00                	push   $0x0
  pushl $54
c0102172:	6a 36                	push   $0x36
  jmp __alltraps
c0102174:	e9 91 08 00 00       	jmp    c0102a0a <__alltraps>

c0102179 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102179:	6a 00                	push   $0x0
  pushl $55
c010217b:	6a 37                	push   $0x37
  jmp __alltraps
c010217d:	e9 88 08 00 00       	jmp    c0102a0a <__alltraps>

c0102182 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102182:	6a 00                	push   $0x0
  pushl $56
c0102184:	6a 38                	push   $0x38
  jmp __alltraps
c0102186:	e9 7f 08 00 00       	jmp    c0102a0a <__alltraps>

c010218b <vector57>:
.globl vector57
vector57:
  pushl $0
c010218b:	6a 00                	push   $0x0
  pushl $57
c010218d:	6a 39                	push   $0x39
  jmp __alltraps
c010218f:	e9 76 08 00 00       	jmp    c0102a0a <__alltraps>

c0102194 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102194:	6a 00                	push   $0x0
  pushl $58
c0102196:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102198:	e9 6d 08 00 00       	jmp    c0102a0a <__alltraps>

c010219d <vector59>:
.globl vector59
vector59:
  pushl $0
c010219d:	6a 00                	push   $0x0
  pushl $59
c010219f:	6a 3b                	push   $0x3b
  jmp __alltraps
c01021a1:	e9 64 08 00 00       	jmp    c0102a0a <__alltraps>

c01021a6 <vector60>:
.globl vector60
vector60:
  pushl $0
c01021a6:	6a 00                	push   $0x0
  pushl $60
c01021a8:	6a 3c                	push   $0x3c
  jmp __alltraps
c01021aa:	e9 5b 08 00 00       	jmp    c0102a0a <__alltraps>

c01021af <vector61>:
.globl vector61
vector61:
  pushl $0
c01021af:	6a 00                	push   $0x0
  pushl $61
c01021b1:	6a 3d                	push   $0x3d
  jmp __alltraps
c01021b3:	e9 52 08 00 00       	jmp    c0102a0a <__alltraps>

c01021b8 <vector62>:
.globl vector62
vector62:
  pushl $0
c01021b8:	6a 00                	push   $0x0
  pushl $62
c01021ba:	6a 3e                	push   $0x3e
  jmp __alltraps
c01021bc:	e9 49 08 00 00       	jmp    c0102a0a <__alltraps>

c01021c1 <vector63>:
.globl vector63
vector63:
  pushl $0
c01021c1:	6a 00                	push   $0x0
  pushl $63
c01021c3:	6a 3f                	push   $0x3f
  jmp __alltraps
c01021c5:	e9 40 08 00 00       	jmp    c0102a0a <__alltraps>

c01021ca <vector64>:
.globl vector64
vector64:
  pushl $0
c01021ca:	6a 00                	push   $0x0
  pushl $64
c01021cc:	6a 40                	push   $0x40
  jmp __alltraps
c01021ce:	e9 37 08 00 00       	jmp    c0102a0a <__alltraps>

c01021d3 <vector65>:
.globl vector65
vector65:
  pushl $0
c01021d3:	6a 00                	push   $0x0
  pushl $65
c01021d5:	6a 41                	push   $0x41
  jmp __alltraps
c01021d7:	e9 2e 08 00 00       	jmp    c0102a0a <__alltraps>

c01021dc <vector66>:
.globl vector66
vector66:
  pushl $0
c01021dc:	6a 00                	push   $0x0
  pushl $66
c01021de:	6a 42                	push   $0x42
  jmp __alltraps
c01021e0:	e9 25 08 00 00       	jmp    c0102a0a <__alltraps>

c01021e5 <vector67>:
.globl vector67
vector67:
  pushl $0
c01021e5:	6a 00                	push   $0x0
  pushl $67
c01021e7:	6a 43                	push   $0x43
  jmp __alltraps
c01021e9:	e9 1c 08 00 00       	jmp    c0102a0a <__alltraps>

c01021ee <vector68>:
.globl vector68
vector68:
  pushl $0
c01021ee:	6a 00                	push   $0x0
  pushl $68
c01021f0:	6a 44                	push   $0x44
  jmp __alltraps
c01021f2:	e9 13 08 00 00       	jmp    c0102a0a <__alltraps>

c01021f7 <vector69>:
.globl vector69
vector69:
  pushl $0
c01021f7:	6a 00                	push   $0x0
  pushl $69
c01021f9:	6a 45                	push   $0x45
  jmp __alltraps
c01021fb:	e9 0a 08 00 00       	jmp    c0102a0a <__alltraps>

c0102200 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102200:	6a 00                	push   $0x0
  pushl $70
c0102202:	6a 46                	push   $0x46
  jmp __alltraps
c0102204:	e9 01 08 00 00       	jmp    c0102a0a <__alltraps>

c0102209 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102209:	6a 00                	push   $0x0
  pushl $71
c010220b:	6a 47                	push   $0x47
  jmp __alltraps
c010220d:	e9 f8 07 00 00       	jmp    c0102a0a <__alltraps>

c0102212 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102212:	6a 00                	push   $0x0
  pushl $72
c0102214:	6a 48                	push   $0x48
  jmp __alltraps
c0102216:	e9 ef 07 00 00       	jmp    c0102a0a <__alltraps>

c010221b <vector73>:
.globl vector73
vector73:
  pushl $0
c010221b:	6a 00                	push   $0x0
  pushl $73
c010221d:	6a 49                	push   $0x49
  jmp __alltraps
c010221f:	e9 e6 07 00 00       	jmp    c0102a0a <__alltraps>

c0102224 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102224:	6a 00                	push   $0x0
  pushl $74
c0102226:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102228:	e9 dd 07 00 00       	jmp    c0102a0a <__alltraps>

c010222d <vector75>:
.globl vector75
vector75:
  pushl $0
c010222d:	6a 00                	push   $0x0
  pushl $75
c010222f:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102231:	e9 d4 07 00 00       	jmp    c0102a0a <__alltraps>

c0102236 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102236:	6a 00                	push   $0x0
  pushl $76
c0102238:	6a 4c                	push   $0x4c
  jmp __alltraps
c010223a:	e9 cb 07 00 00       	jmp    c0102a0a <__alltraps>

c010223f <vector77>:
.globl vector77
vector77:
  pushl $0
c010223f:	6a 00                	push   $0x0
  pushl $77
c0102241:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102243:	e9 c2 07 00 00       	jmp    c0102a0a <__alltraps>

c0102248 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102248:	6a 00                	push   $0x0
  pushl $78
c010224a:	6a 4e                	push   $0x4e
  jmp __alltraps
c010224c:	e9 b9 07 00 00       	jmp    c0102a0a <__alltraps>

c0102251 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102251:	6a 00                	push   $0x0
  pushl $79
c0102253:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102255:	e9 b0 07 00 00       	jmp    c0102a0a <__alltraps>

c010225a <vector80>:
.globl vector80
vector80:
  pushl $0
c010225a:	6a 00                	push   $0x0
  pushl $80
c010225c:	6a 50                	push   $0x50
  jmp __alltraps
c010225e:	e9 a7 07 00 00       	jmp    c0102a0a <__alltraps>

c0102263 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102263:	6a 00                	push   $0x0
  pushl $81
c0102265:	6a 51                	push   $0x51
  jmp __alltraps
c0102267:	e9 9e 07 00 00       	jmp    c0102a0a <__alltraps>

c010226c <vector82>:
.globl vector82
vector82:
  pushl $0
c010226c:	6a 00                	push   $0x0
  pushl $82
c010226e:	6a 52                	push   $0x52
  jmp __alltraps
c0102270:	e9 95 07 00 00       	jmp    c0102a0a <__alltraps>

c0102275 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102275:	6a 00                	push   $0x0
  pushl $83
c0102277:	6a 53                	push   $0x53
  jmp __alltraps
c0102279:	e9 8c 07 00 00       	jmp    c0102a0a <__alltraps>

c010227e <vector84>:
.globl vector84
vector84:
  pushl $0
c010227e:	6a 00                	push   $0x0
  pushl $84
c0102280:	6a 54                	push   $0x54
  jmp __alltraps
c0102282:	e9 83 07 00 00       	jmp    c0102a0a <__alltraps>

c0102287 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102287:	6a 00                	push   $0x0
  pushl $85
c0102289:	6a 55                	push   $0x55
  jmp __alltraps
c010228b:	e9 7a 07 00 00       	jmp    c0102a0a <__alltraps>

c0102290 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102290:	6a 00                	push   $0x0
  pushl $86
c0102292:	6a 56                	push   $0x56
  jmp __alltraps
c0102294:	e9 71 07 00 00       	jmp    c0102a0a <__alltraps>

c0102299 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $87
c010229b:	6a 57                	push   $0x57
  jmp __alltraps
c010229d:	e9 68 07 00 00       	jmp    c0102a0a <__alltraps>

c01022a2 <vector88>:
.globl vector88
vector88:
  pushl $0
c01022a2:	6a 00                	push   $0x0
  pushl $88
c01022a4:	6a 58                	push   $0x58
  jmp __alltraps
c01022a6:	e9 5f 07 00 00       	jmp    c0102a0a <__alltraps>

c01022ab <vector89>:
.globl vector89
vector89:
  pushl $0
c01022ab:	6a 00                	push   $0x0
  pushl $89
c01022ad:	6a 59                	push   $0x59
  jmp __alltraps
c01022af:	e9 56 07 00 00       	jmp    c0102a0a <__alltraps>

c01022b4 <vector90>:
.globl vector90
vector90:
  pushl $0
c01022b4:	6a 00                	push   $0x0
  pushl $90
c01022b6:	6a 5a                	push   $0x5a
  jmp __alltraps
c01022b8:	e9 4d 07 00 00       	jmp    c0102a0a <__alltraps>

c01022bd <vector91>:
.globl vector91
vector91:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $91
c01022bf:	6a 5b                	push   $0x5b
  jmp __alltraps
c01022c1:	e9 44 07 00 00       	jmp    c0102a0a <__alltraps>

c01022c6 <vector92>:
.globl vector92
vector92:
  pushl $0
c01022c6:	6a 00                	push   $0x0
  pushl $92
c01022c8:	6a 5c                	push   $0x5c
  jmp __alltraps
c01022ca:	e9 3b 07 00 00       	jmp    c0102a0a <__alltraps>

c01022cf <vector93>:
.globl vector93
vector93:
  pushl $0
c01022cf:	6a 00                	push   $0x0
  pushl $93
c01022d1:	6a 5d                	push   $0x5d
  jmp __alltraps
c01022d3:	e9 32 07 00 00       	jmp    c0102a0a <__alltraps>

c01022d8 <vector94>:
.globl vector94
vector94:
  pushl $0
c01022d8:	6a 00                	push   $0x0
  pushl $94
c01022da:	6a 5e                	push   $0x5e
  jmp __alltraps
c01022dc:	e9 29 07 00 00       	jmp    c0102a0a <__alltraps>

c01022e1 <vector95>:
.globl vector95
vector95:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $95
c01022e3:	6a 5f                	push   $0x5f
  jmp __alltraps
c01022e5:	e9 20 07 00 00       	jmp    c0102a0a <__alltraps>

c01022ea <vector96>:
.globl vector96
vector96:
  pushl $0
c01022ea:	6a 00                	push   $0x0
  pushl $96
c01022ec:	6a 60                	push   $0x60
  jmp __alltraps
c01022ee:	e9 17 07 00 00       	jmp    c0102a0a <__alltraps>

c01022f3 <vector97>:
.globl vector97
vector97:
  pushl $0
c01022f3:	6a 00                	push   $0x0
  pushl $97
c01022f5:	6a 61                	push   $0x61
  jmp __alltraps
c01022f7:	e9 0e 07 00 00       	jmp    c0102a0a <__alltraps>

c01022fc <vector98>:
.globl vector98
vector98:
  pushl $0
c01022fc:	6a 00                	push   $0x0
  pushl $98
c01022fe:	6a 62                	push   $0x62
  jmp __alltraps
c0102300:	e9 05 07 00 00       	jmp    c0102a0a <__alltraps>

c0102305 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $99
c0102307:	6a 63                	push   $0x63
  jmp __alltraps
c0102309:	e9 fc 06 00 00       	jmp    c0102a0a <__alltraps>

c010230e <vector100>:
.globl vector100
vector100:
  pushl $0
c010230e:	6a 00                	push   $0x0
  pushl $100
c0102310:	6a 64                	push   $0x64
  jmp __alltraps
c0102312:	e9 f3 06 00 00       	jmp    c0102a0a <__alltraps>

c0102317 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102317:	6a 00                	push   $0x0
  pushl $101
c0102319:	6a 65                	push   $0x65
  jmp __alltraps
c010231b:	e9 ea 06 00 00       	jmp    c0102a0a <__alltraps>

c0102320 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102320:	6a 00                	push   $0x0
  pushl $102
c0102322:	6a 66                	push   $0x66
  jmp __alltraps
c0102324:	e9 e1 06 00 00       	jmp    c0102a0a <__alltraps>

c0102329 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $103
c010232b:	6a 67                	push   $0x67
  jmp __alltraps
c010232d:	e9 d8 06 00 00       	jmp    c0102a0a <__alltraps>

c0102332 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102332:	6a 00                	push   $0x0
  pushl $104
c0102334:	6a 68                	push   $0x68
  jmp __alltraps
c0102336:	e9 cf 06 00 00       	jmp    c0102a0a <__alltraps>

c010233b <vector105>:
.globl vector105
vector105:
  pushl $0
c010233b:	6a 00                	push   $0x0
  pushl $105
c010233d:	6a 69                	push   $0x69
  jmp __alltraps
c010233f:	e9 c6 06 00 00       	jmp    c0102a0a <__alltraps>

c0102344 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102344:	6a 00                	push   $0x0
  pushl $106
c0102346:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102348:	e9 bd 06 00 00       	jmp    c0102a0a <__alltraps>

c010234d <vector107>:
.globl vector107
vector107:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $107
c010234f:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102351:	e9 b4 06 00 00       	jmp    c0102a0a <__alltraps>

c0102356 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102356:	6a 00                	push   $0x0
  pushl $108
c0102358:	6a 6c                	push   $0x6c
  jmp __alltraps
c010235a:	e9 ab 06 00 00       	jmp    c0102a0a <__alltraps>

c010235f <vector109>:
.globl vector109
vector109:
  pushl $0
c010235f:	6a 00                	push   $0x0
  pushl $109
c0102361:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102363:	e9 a2 06 00 00       	jmp    c0102a0a <__alltraps>

c0102368 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102368:	6a 00                	push   $0x0
  pushl $110
c010236a:	6a 6e                	push   $0x6e
  jmp __alltraps
c010236c:	e9 99 06 00 00       	jmp    c0102a0a <__alltraps>

c0102371 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $111
c0102373:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102375:	e9 90 06 00 00       	jmp    c0102a0a <__alltraps>

c010237a <vector112>:
.globl vector112
vector112:
  pushl $0
c010237a:	6a 00                	push   $0x0
  pushl $112
c010237c:	6a 70                	push   $0x70
  jmp __alltraps
c010237e:	e9 87 06 00 00       	jmp    c0102a0a <__alltraps>

c0102383 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102383:	6a 00                	push   $0x0
  pushl $113
c0102385:	6a 71                	push   $0x71
  jmp __alltraps
c0102387:	e9 7e 06 00 00       	jmp    c0102a0a <__alltraps>

c010238c <vector114>:
.globl vector114
vector114:
  pushl $0
c010238c:	6a 00                	push   $0x0
  pushl $114
c010238e:	6a 72                	push   $0x72
  jmp __alltraps
c0102390:	e9 75 06 00 00       	jmp    c0102a0a <__alltraps>

c0102395 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $115
c0102397:	6a 73                	push   $0x73
  jmp __alltraps
c0102399:	e9 6c 06 00 00       	jmp    c0102a0a <__alltraps>

c010239e <vector116>:
.globl vector116
vector116:
  pushl $0
c010239e:	6a 00                	push   $0x0
  pushl $116
c01023a0:	6a 74                	push   $0x74
  jmp __alltraps
c01023a2:	e9 63 06 00 00       	jmp    c0102a0a <__alltraps>

c01023a7 <vector117>:
.globl vector117
vector117:
  pushl $0
c01023a7:	6a 00                	push   $0x0
  pushl $117
c01023a9:	6a 75                	push   $0x75
  jmp __alltraps
c01023ab:	e9 5a 06 00 00       	jmp    c0102a0a <__alltraps>

c01023b0 <vector118>:
.globl vector118
vector118:
  pushl $0
c01023b0:	6a 00                	push   $0x0
  pushl $118
c01023b2:	6a 76                	push   $0x76
  jmp __alltraps
c01023b4:	e9 51 06 00 00       	jmp    c0102a0a <__alltraps>

c01023b9 <vector119>:
.globl vector119
vector119:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $119
c01023bb:	6a 77                	push   $0x77
  jmp __alltraps
c01023bd:	e9 48 06 00 00       	jmp    c0102a0a <__alltraps>

c01023c2 <vector120>:
.globl vector120
vector120:
  pushl $0
c01023c2:	6a 00                	push   $0x0
  pushl $120
c01023c4:	6a 78                	push   $0x78
  jmp __alltraps
c01023c6:	e9 3f 06 00 00       	jmp    c0102a0a <__alltraps>

c01023cb <vector121>:
.globl vector121
vector121:
  pushl $0
c01023cb:	6a 00                	push   $0x0
  pushl $121
c01023cd:	6a 79                	push   $0x79
  jmp __alltraps
c01023cf:	e9 36 06 00 00       	jmp    c0102a0a <__alltraps>

c01023d4 <vector122>:
.globl vector122
vector122:
  pushl $0
c01023d4:	6a 00                	push   $0x0
  pushl $122
c01023d6:	6a 7a                	push   $0x7a
  jmp __alltraps
c01023d8:	e9 2d 06 00 00       	jmp    c0102a0a <__alltraps>

c01023dd <vector123>:
.globl vector123
vector123:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $123
c01023df:	6a 7b                	push   $0x7b
  jmp __alltraps
c01023e1:	e9 24 06 00 00       	jmp    c0102a0a <__alltraps>

c01023e6 <vector124>:
.globl vector124
vector124:
  pushl $0
c01023e6:	6a 00                	push   $0x0
  pushl $124
c01023e8:	6a 7c                	push   $0x7c
  jmp __alltraps
c01023ea:	e9 1b 06 00 00       	jmp    c0102a0a <__alltraps>

c01023ef <vector125>:
.globl vector125
vector125:
  pushl $0
c01023ef:	6a 00                	push   $0x0
  pushl $125
c01023f1:	6a 7d                	push   $0x7d
  jmp __alltraps
c01023f3:	e9 12 06 00 00       	jmp    c0102a0a <__alltraps>

c01023f8 <vector126>:
.globl vector126
vector126:
  pushl $0
c01023f8:	6a 00                	push   $0x0
  pushl $126
c01023fa:	6a 7e                	push   $0x7e
  jmp __alltraps
c01023fc:	e9 09 06 00 00       	jmp    c0102a0a <__alltraps>

c0102401 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $127
c0102403:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102405:	e9 00 06 00 00       	jmp    c0102a0a <__alltraps>

c010240a <vector128>:
.globl vector128
vector128:
  pushl $0
c010240a:	6a 00                	push   $0x0
  pushl $128
c010240c:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102411:	e9 f4 05 00 00       	jmp    c0102a0a <__alltraps>

c0102416 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102416:	6a 00                	push   $0x0
  pushl $129
c0102418:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010241d:	e9 e8 05 00 00       	jmp    c0102a0a <__alltraps>

c0102422 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102422:	6a 00                	push   $0x0
  pushl $130
c0102424:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102429:	e9 dc 05 00 00       	jmp    c0102a0a <__alltraps>

c010242e <vector131>:
.globl vector131
vector131:
  pushl $0
c010242e:	6a 00                	push   $0x0
  pushl $131
c0102430:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102435:	e9 d0 05 00 00       	jmp    c0102a0a <__alltraps>

c010243a <vector132>:
.globl vector132
vector132:
  pushl $0
c010243a:	6a 00                	push   $0x0
  pushl $132
c010243c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102441:	e9 c4 05 00 00       	jmp    c0102a0a <__alltraps>

c0102446 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102446:	6a 00                	push   $0x0
  pushl $133
c0102448:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010244d:	e9 b8 05 00 00       	jmp    c0102a0a <__alltraps>

c0102452 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102452:	6a 00                	push   $0x0
  pushl $134
c0102454:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102459:	e9 ac 05 00 00       	jmp    c0102a0a <__alltraps>

c010245e <vector135>:
.globl vector135
vector135:
  pushl $0
c010245e:	6a 00                	push   $0x0
  pushl $135
c0102460:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102465:	e9 a0 05 00 00       	jmp    c0102a0a <__alltraps>

c010246a <vector136>:
.globl vector136
vector136:
  pushl $0
c010246a:	6a 00                	push   $0x0
  pushl $136
c010246c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102471:	e9 94 05 00 00       	jmp    c0102a0a <__alltraps>

c0102476 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102476:	6a 00                	push   $0x0
  pushl $137
c0102478:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010247d:	e9 88 05 00 00       	jmp    c0102a0a <__alltraps>

c0102482 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102482:	6a 00                	push   $0x0
  pushl $138
c0102484:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102489:	e9 7c 05 00 00       	jmp    c0102a0a <__alltraps>

c010248e <vector139>:
.globl vector139
vector139:
  pushl $0
c010248e:	6a 00                	push   $0x0
  pushl $139
c0102490:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102495:	e9 70 05 00 00       	jmp    c0102a0a <__alltraps>

c010249a <vector140>:
.globl vector140
vector140:
  pushl $0
c010249a:	6a 00                	push   $0x0
  pushl $140
c010249c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01024a1:	e9 64 05 00 00       	jmp    c0102a0a <__alltraps>

c01024a6 <vector141>:
.globl vector141
vector141:
  pushl $0
c01024a6:	6a 00                	push   $0x0
  pushl $141
c01024a8:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01024ad:	e9 58 05 00 00       	jmp    c0102a0a <__alltraps>

c01024b2 <vector142>:
.globl vector142
vector142:
  pushl $0
c01024b2:	6a 00                	push   $0x0
  pushl $142
c01024b4:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01024b9:	e9 4c 05 00 00       	jmp    c0102a0a <__alltraps>

c01024be <vector143>:
.globl vector143
vector143:
  pushl $0
c01024be:	6a 00                	push   $0x0
  pushl $143
c01024c0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01024c5:	e9 40 05 00 00       	jmp    c0102a0a <__alltraps>

c01024ca <vector144>:
.globl vector144
vector144:
  pushl $0
c01024ca:	6a 00                	push   $0x0
  pushl $144
c01024cc:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01024d1:	e9 34 05 00 00       	jmp    c0102a0a <__alltraps>

c01024d6 <vector145>:
.globl vector145
vector145:
  pushl $0
c01024d6:	6a 00                	push   $0x0
  pushl $145
c01024d8:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01024dd:	e9 28 05 00 00       	jmp    c0102a0a <__alltraps>

c01024e2 <vector146>:
.globl vector146
vector146:
  pushl $0
c01024e2:	6a 00                	push   $0x0
  pushl $146
c01024e4:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01024e9:	e9 1c 05 00 00       	jmp    c0102a0a <__alltraps>

c01024ee <vector147>:
.globl vector147
vector147:
  pushl $0
c01024ee:	6a 00                	push   $0x0
  pushl $147
c01024f0:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01024f5:	e9 10 05 00 00       	jmp    c0102a0a <__alltraps>

c01024fa <vector148>:
.globl vector148
vector148:
  pushl $0
c01024fa:	6a 00                	push   $0x0
  pushl $148
c01024fc:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102501:	e9 04 05 00 00       	jmp    c0102a0a <__alltraps>

c0102506 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102506:	6a 00                	push   $0x0
  pushl $149
c0102508:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010250d:	e9 f8 04 00 00       	jmp    c0102a0a <__alltraps>

c0102512 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102512:	6a 00                	push   $0x0
  pushl $150
c0102514:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102519:	e9 ec 04 00 00       	jmp    c0102a0a <__alltraps>

c010251e <vector151>:
.globl vector151
vector151:
  pushl $0
c010251e:	6a 00                	push   $0x0
  pushl $151
c0102520:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102525:	e9 e0 04 00 00       	jmp    c0102a0a <__alltraps>

c010252a <vector152>:
.globl vector152
vector152:
  pushl $0
c010252a:	6a 00                	push   $0x0
  pushl $152
c010252c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102531:	e9 d4 04 00 00       	jmp    c0102a0a <__alltraps>

c0102536 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102536:	6a 00                	push   $0x0
  pushl $153
c0102538:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010253d:	e9 c8 04 00 00       	jmp    c0102a0a <__alltraps>

c0102542 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102542:	6a 00                	push   $0x0
  pushl $154
c0102544:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102549:	e9 bc 04 00 00       	jmp    c0102a0a <__alltraps>

c010254e <vector155>:
.globl vector155
vector155:
  pushl $0
c010254e:	6a 00                	push   $0x0
  pushl $155
c0102550:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102555:	e9 b0 04 00 00       	jmp    c0102a0a <__alltraps>

c010255a <vector156>:
.globl vector156
vector156:
  pushl $0
c010255a:	6a 00                	push   $0x0
  pushl $156
c010255c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102561:	e9 a4 04 00 00       	jmp    c0102a0a <__alltraps>

c0102566 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102566:	6a 00                	push   $0x0
  pushl $157
c0102568:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010256d:	e9 98 04 00 00       	jmp    c0102a0a <__alltraps>

c0102572 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102572:	6a 00                	push   $0x0
  pushl $158
c0102574:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102579:	e9 8c 04 00 00       	jmp    c0102a0a <__alltraps>

c010257e <vector159>:
.globl vector159
vector159:
  pushl $0
c010257e:	6a 00                	push   $0x0
  pushl $159
c0102580:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102585:	e9 80 04 00 00       	jmp    c0102a0a <__alltraps>

c010258a <vector160>:
.globl vector160
vector160:
  pushl $0
c010258a:	6a 00                	push   $0x0
  pushl $160
c010258c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102591:	e9 74 04 00 00       	jmp    c0102a0a <__alltraps>

c0102596 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102596:	6a 00                	push   $0x0
  pushl $161
c0102598:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010259d:	e9 68 04 00 00       	jmp    c0102a0a <__alltraps>

c01025a2 <vector162>:
.globl vector162
vector162:
  pushl $0
c01025a2:	6a 00                	push   $0x0
  pushl $162
c01025a4:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01025a9:	e9 5c 04 00 00       	jmp    c0102a0a <__alltraps>

c01025ae <vector163>:
.globl vector163
vector163:
  pushl $0
c01025ae:	6a 00                	push   $0x0
  pushl $163
c01025b0:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01025b5:	e9 50 04 00 00       	jmp    c0102a0a <__alltraps>

c01025ba <vector164>:
.globl vector164
vector164:
  pushl $0
c01025ba:	6a 00                	push   $0x0
  pushl $164
c01025bc:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01025c1:	e9 44 04 00 00       	jmp    c0102a0a <__alltraps>

c01025c6 <vector165>:
.globl vector165
vector165:
  pushl $0
c01025c6:	6a 00                	push   $0x0
  pushl $165
c01025c8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01025cd:	e9 38 04 00 00       	jmp    c0102a0a <__alltraps>

c01025d2 <vector166>:
.globl vector166
vector166:
  pushl $0
c01025d2:	6a 00                	push   $0x0
  pushl $166
c01025d4:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01025d9:	e9 2c 04 00 00       	jmp    c0102a0a <__alltraps>

c01025de <vector167>:
.globl vector167
vector167:
  pushl $0
c01025de:	6a 00                	push   $0x0
  pushl $167
c01025e0:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01025e5:	e9 20 04 00 00       	jmp    c0102a0a <__alltraps>

c01025ea <vector168>:
.globl vector168
vector168:
  pushl $0
c01025ea:	6a 00                	push   $0x0
  pushl $168
c01025ec:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01025f1:	e9 14 04 00 00       	jmp    c0102a0a <__alltraps>

c01025f6 <vector169>:
.globl vector169
vector169:
  pushl $0
c01025f6:	6a 00                	push   $0x0
  pushl $169
c01025f8:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01025fd:	e9 08 04 00 00       	jmp    c0102a0a <__alltraps>

c0102602 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102602:	6a 00                	push   $0x0
  pushl $170
c0102604:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102609:	e9 fc 03 00 00       	jmp    c0102a0a <__alltraps>

c010260e <vector171>:
.globl vector171
vector171:
  pushl $0
c010260e:	6a 00                	push   $0x0
  pushl $171
c0102610:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102615:	e9 f0 03 00 00       	jmp    c0102a0a <__alltraps>

c010261a <vector172>:
.globl vector172
vector172:
  pushl $0
c010261a:	6a 00                	push   $0x0
  pushl $172
c010261c:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102621:	e9 e4 03 00 00       	jmp    c0102a0a <__alltraps>

c0102626 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102626:	6a 00                	push   $0x0
  pushl $173
c0102628:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010262d:	e9 d8 03 00 00       	jmp    c0102a0a <__alltraps>

c0102632 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102632:	6a 00                	push   $0x0
  pushl $174
c0102634:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102639:	e9 cc 03 00 00       	jmp    c0102a0a <__alltraps>

c010263e <vector175>:
.globl vector175
vector175:
  pushl $0
c010263e:	6a 00                	push   $0x0
  pushl $175
c0102640:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102645:	e9 c0 03 00 00       	jmp    c0102a0a <__alltraps>

c010264a <vector176>:
.globl vector176
vector176:
  pushl $0
c010264a:	6a 00                	push   $0x0
  pushl $176
c010264c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102651:	e9 b4 03 00 00       	jmp    c0102a0a <__alltraps>

c0102656 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102656:	6a 00                	push   $0x0
  pushl $177
c0102658:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010265d:	e9 a8 03 00 00       	jmp    c0102a0a <__alltraps>

c0102662 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102662:	6a 00                	push   $0x0
  pushl $178
c0102664:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102669:	e9 9c 03 00 00       	jmp    c0102a0a <__alltraps>

c010266e <vector179>:
.globl vector179
vector179:
  pushl $0
c010266e:	6a 00                	push   $0x0
  pushl $179
c0102670:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102675:	e9 90 03 00 00       	jmp    c0102a0a <__alltraps>

c010267a <vector180>:
.globl vector180
vector180:
  pushl $0
c010267a:	6a 00                	push   $0x0
  pushl $180
c010267c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102681:	e9 84 03 00 00       	jmp    c0102a0a <__alltraps>

c0102686 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102686:	6a 00                	push   $0x0
  pushl $181
c0102688:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010268d:	e9 78 03 00 00       	jmp    c0102a0a <__alltraps>

c0102692 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102692:	6a 00                	push   $0x0
  pushl $182
c0102694:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102699:	e9 6c 03 00 00       	jmp    c0102a0a <__alltraps>

c010269e <vector183>:
.globl vector183
vector183:
  pushl $0
c010269e:	6a 00                	push   $0x0
  pushl $183
c01026a0:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01026a5:	e9 60 03 00 00       	jmp    c0102a0a <__alltraps>

c01026aa <vector184>:
.globl vector184
vector184:
  pushl $0
c01026aa:	6a 00                	push   $0x0
  pushl $184
c01026ac:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01026b1:	e9 54 03 00 00       	jmp    c0102a0a <__alltraps>

c01026b6 <vector185>:
.globl vector185
vector185:
  pushl $0
c01026b6:	6a 00                	push   $0x0
  pushl $185
c01026b8:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01026bd:	e9 48 03 00 00       	jmp    c0102a0a <__alltraps>

c01026c2 <vector186>:
.globl vector186
vector186:
  pushl $0
c01026c2:	6a 00                	push   $0x0
  pushl $186
c01026c4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01026c9:	e9 3c 03 00 00       	jmp    c0102a0a <__alltraps>

c01026ce <vector187>:
.globl vector187
vector187:
  pushl $0
c01026ce:	6a 00                	push   $0x0
  pushl $187
c01026d0:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01026d5:	e9 30 03 00 00       	jmp    c0102a0a <__alltraps>

c01026da <vector188>:
.globl vector188
vector188:
  pushl $0
c01026da:	6a 00                	push   $0x0
  pushl $188
c01026dc:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01026e1:	e9 24 03 00 00       	jmp    c0102a0a <__alltraps>

c01026e6 <vector189>:
.globl vector189
vector189:
  pushl $0
c01026e6:	6a 00                	push   $0x0
  pushl $189
c01026e8:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01026ed:	e9 18 03 00 00       	jmp    c0102a0a <__alltraps>

c01026f2 <vector190>:
.globl vector190
vector190:
  pushl $0
c01026f2:	6a 00                	push   $0x0
  pushl $190
c01026f4:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01026f9:	e9 0c 03 00 00       	jmp    c0102a0a <__alltraps>

c01026fe <vector191>:
.globl vector191
vector191:
  pushl $0
c01026fe:	6a 00                	push   $0x0
  pushl $191
c0102700:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102705:	e9 00 03 00 00       	jmp    c0102a0a <__alltraps>

c010270a <vector192>:
.globl vector192
vector192:
  pushl $0
c010270a:	6a 00                	push   $0x0
  pushl $192
c010270c:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102711:	e9 f4 02 00 00       	jmp    c0102a0a <__alltraps>

c0102716 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102716:	6a 00                	push   $0x0
  pushl $193
c0102718:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010271d:	e9 e8 02 00 00       	jmp    c0102a0a <__alltraps>

c0102722 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102722:	6a 00                	push   $0x0
  pushl $194
c0102724:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102729:	e9 dc 02 00 00       	jmp    c0102a0a <__alltraps>

c010272e <vector195>:
.globl vector195
vector195:
  pushl $0
c010272e:	6a 00                	push   $0x0
  pushl $195
c0102730:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102735:	e9 d0 02 00 00       	jmp    c0102a0a <__alltraps>

c010273a <vector196>:
.globl vector196
vector196:
  pushl $0
c010273a:	6a 00                	push   $0x0
  pushl $196
c010273c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102741:	e9 c4 02 00 00       	jmp    c0102a0a <__alltraps>

c0102746 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102746:	6a 00                	push   $0x0
  pushl $197
c0102748:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010274d:	e9 b8 02 00 00       	jmp    c0102a0a <__alltraps>

c0102752 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102752:	6a 00                	push   $0x0
  pushl $198
c0102754:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102759:	e9 ac 02 00 00       	jmp    c0102a0a <__alltraps>

c010275e <vector199>:
.globl vector199
vector199:
  pushl $0
c010275e:	6a 00                	push   $0x0
  pushl $199
c0102760:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102765:	e9 a0 02 00 00       	jmp    c0102a0a <__alltraps>

c010276a <vector200>:
.globl vector200
vector200:
  pushl $0
c010276a:	6a 00                	push   $0x0
  pushl $200
c010276c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102771:	e9 94 02 00 00       	jmp    c0102a0a <__alltraps>

c0102776 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102776:	6a 00                	push   $0x0
  pushl $201
c0102778:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010277d:	e9 88 02 00 00       	jmp    c0102a0a <__alltraps>

c0102782 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102782:	6a 00                	push   $0x0
  pushl $202
c0102784:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102789:	e9 7c 02 00 00       	jmp    c0102a0a <__alltraps>

c010278e <vector203>:
.globl vector203
vector203:
  pushl $0
c010278e:	6a 00                	push   $0x0
  pushl $203
c0102790:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102795:	e9 70 02 00 00       	jmp    c0102a0a <__alltraps>

c010279a <vector204>:
.globl vector204
vector204:
  pushl $0
c010279a:	6a 00                	push   $0x0
  pushl $204
c010279c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01027a1:	e9 64 02 00 00       	jmp    c0102a0a <__alltraps>

c01027a6 <vector205>:
.globl vector205
vector205:
  pushl $0
c01027a6:	6a 00                	push   $0x0
  pushl $205
c01027a8:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01027ad:	e9 58 02 00 00       	jmp    c0102a0a <__alltraps>

c01027b2 <vector206>:
.globl vector206
vector206:
  pushl $0
c01027b2:	6a 00                	push   $0x0
  pushl $206
c01027b4:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01027b9:	e9 4c 02 00 00       	jmp    c0102a0a <__alltraps>

c01027be <vector207>:
.globl vector207
vector207:
  pushl $0
c01027be:	6a 00                	push   $0x0
  pushl $207
c01027c0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01027c5:	e9 40 02 00 00       	jmp    c0102a0a <__alltraps>

c01027ca <vector208>:
.globl vector208
vector208:
  pushl $0
c01027ca:	6a 00                	push   $0x0
  pushl $208
c01027cc:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01027d1:	e9 34 02 00 00       	jmp    c0102a0a <__alltraps>

c01027d6 <vector209>:
.globl vector209
vector209:
  pushl $0
c01027d6:	6a 00                	push   $0x0
  pushl $209
c01027d8:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01027dd:	e9 28 02 00 00       	jmp    c0102a0a <__alltraps>

c01027e2 <vector210>:
.globl vector210
vector210:
  pushl $0
c01027e2:	6a 00                	push   $0x0
  pushl $210
c01027e4:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01027e9:	e9 1c 02 00 00       	jmp    c0102a0a <__alltraps>

c01027ee <vector211>:
.globl vector211
vector211:
  pushl $0
c01027ee:	6a 00                	push   $0x0
  pushl $211
c01027f0:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01027f5:	e9 10 02 00 00       	jmp    c0102a0a <__alltraps>

c01027fa <vector212>:
.globl vector212
vector212:
  pushl $0
c01027fa:	6a 00                	push   $0x0
  pushl $212
c01027fc:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102801:	e9 04 02 00 00       	jmp    c0102a0a <__alltraps>

c0102806 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102806:	6a 00                	push   $0x0
  pushl $213
c0102808:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010280d:	e9 f8 01 00 00       	jmp    c0102a0a <__alltraps>

c0102812 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102812:	6a 00                	push   $0x0
  pushl $214
c0102814:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102819:	e9 ec 01 00 00       	jmp    c0102a0a <__alltraps>

c010281e <vector215>:
.globl vector215
vector215:
  pushl $0
c010281e:	6a 00                	push   $0x0
  pushl $215
c0102820:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102825:	e9 e0 01 00 00       	jmp    c0102a0a <__alltraps>

c010282a <vector216>:
.globl vector216
vector216:
  pushl $0
c010282a:	6a 00                	push   $0x0
  pushl $216
c010282c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102831:	e9 d4 01 00 00       	jmp    c0102a0a <__alltraps>

c0102836 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102836:	6a 00                	push   $0x0
  pushl $217
c0102838:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010283d:	e9 c8 01 00 00       	jmp    c0102a0a <__alltraps>

c0102842 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102842:	6a 00                	push   $0x0
  pushl $218
c0102844:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102849:	e9 bc 01 00 00       	jmp    c0102a0a <__alltraps>

c010284e <vector219>:
.globl vector219
vector219:
  pushl $0
c010284e:	6a 00                	push   $0x0
  pushl $219
c0102850:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102855:	e9 b0 01 00 00       	jmp    c0102a0a <__alltraps>

c010285a <vector220>:
.globl vector220
vector220:
  pushl $0
c010285a:	6a 00                	push   $0x0
  pushl $220
c010285c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102861:	e9 a4 01 00 00       	jmp    c0102a0a <__alltraps>

c0102866 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102866:	6a 00                	push   $0x0
  pushl $221
c0102868:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010286d:	e9 98 01 00 00       	jmp    c0102a0a <__alltraps>

c0102872 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102872:	6a 00                	push   $0x0
  pushl $222
c0102874:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102879:	e9 8c 01 00 00       	jmp    c0102a0a <__alltraps>

c010287e <vector223>:
.globl vector223
vector223:
  pushl $0
c010287e:	6a 00                	push   $0x0
  pushl $223
c0102880:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102885:	e9 80 01 00 00       	jmp    c0102a0a <__alltraps>

c010288a <vector224>:
.globl vector224
vector224:
  pushl $0
c010288a:	6a 00                	push   $0x0
  pushl $224
c010288c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102891:	e9 74 01 00 00       	jmp    c0102a0a <__alltraps>

c0102896 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102896:	6a 00                	push   $0x0
  pushl $225
c0102898:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010289d:	e9 68 01 00 00       	jmp    c0102a0a <__alltraps>

c01028a2 <vector226>:
.globl vector226
vector226:
  pushl $0
c01028a2:	6a 00                	push   $0x0
  pushl $226
c01028a4:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01028a9:	e9 5c 01 00 00       	jmp    c0102a0a <__alltraps>

c01028ae <vector227>:
.globl vector227
vector227:
  pushl $0
c01028ae:	6a 00                	push   $0x0
  pushl $227
c01028b0:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01028b5:	e9 50 01 00 00       	jmp    c0102a0a <__alltraps>

c01028ba <vector228>:
.globl vector228
vector228:
  pushl $0
c01028ba:	6a 00                	push   $0x0
  pushl $228
c01028bc:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01028c1:	e9 44 01 00 00       	jmp    c0102a0a <__alltraps>

c01028c6 <vector229>:
.globl vector229
vector229:
  pushl $0
c01028c6:	6a 00                	push   $0x0
  pushl $229
c01028c8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01028cd:	e9 38 01 00 00       	jmp    c0102a0a <__alltraps>

c01028d2 <vector230>:
.globl vector230
vector230:
  pushl $0
c01028d2:	6a 00                	push   $0x0
  pushl $230
c01028d4:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01028d9:	e9 2c 01 00 00       	jmp    c0102a0a <__alltraps>

c01028de <vector231>:
.globl vector231
vector231:
  pushl $0
c01028de:	6a 00                	push   $0x0
  pushl $231
c01028e0:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01028e5:	e9 20 01 00 00       	jmp    c0102a0a <__alltraps>

c01028ea <vector232>:
.globl vector232
vector232:
  pushl $0
c01028ea:	6a 00                	push   $0x0
  pushl $232
c01028ec:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01028f1:	e9 14 01 00 00       	jmp    c0102a0a <__alltraps>

c01028f6 <vector233>:
.globl vector233
vector233:
  pushl $0
c01028f6:	6a 00                	push   $0x0
  pushl $233
c01028f8:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01028fd:	e9 08 01 00 00       	jmp    c0102a0a <__alltraps>

c0102902 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102902:	6a 00                	push   $0x0
  pushl $234
c0102904:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102909:	e9 fc 00 00 00       	jmp    c0102a0a <__alltraps>

c010290e <vector235>:
.globl vector235
vector235:
  pushl $0
c010290e:	6a 00                	push   $0x0
  pushl $235
c0102910:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102915:	e9 f0 00 00 00       	jmp    c0102a0a <__alltraps>

c010291a <vector236>:
.globl vector236
vector236:
  pushl $0
c010291a:	6a 00                	push   $0x0
  pushl $236
c010291c:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102921:	e9 e4 00 00 00       	jmp    c0102a0a <__alltraps>

c0102926 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102926:	6a 00                	push   $0x0
  pushl $237
c0102928:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010292d:	e9 d8 00 00 00       	jmp    c0102a0a <__alltraps>

c0102932 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102932:	6a 00                	push   $0x0
  pushl $238
c0102934:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102939:	e9 cc 00 00 00       	jmp    c0102a0a <__alltraps>

c010293e <vector239>:
.globl vector239
vector239:
  pushl $0
c010293e:	6a 00                	push   $0x0
  pushl $239
c0102940:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102945:	e9 c0 00 00 00       	jmp    c0102a0a <__alltraps>

c010294a <vector240>:
.globl vector240
vector240:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $240
c010294c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102951:	e9 b4 00 00 00       	jmp    c0102a0a <__alltraps>

c0102956 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102956:	6a 00                	push   $0x0
  pushl $241
c0102958:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010295d:	e9 a8 00 00 00       	jmp    c0102a0a <__alltraps>

c0102962 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102962:	6a 00                	push   $0x0
  pushl $242
c0102964:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102969:	e9 9c 00 00 00       	jmp    c0102a0a <__alltraps>

c010296e <vector243>:
.globl vector243
vector243:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $243
c0102970:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102975:	e9 90 00 00 00       	jmp    c0102a0a <__alltraps>

c010297a <vector244>:
.globl vector244
vector244:
  pushl $0
c010297a:	6a 00                	push   $0x0
  pushl $244
c010297c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102981:	e9 84 00 00 00       	jmp    c0102a0a <__alltraps>

c0102986 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102986:	6a 00                	push   $0x0
  pushl $245
c0102988:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010298d:	e9 78 00 00 00       	jmp    c0102a0a <__alltraps>

c0102992 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $246
c0102994:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102999:	e9 6c 00 00 00       	jmp    c0102a0a <__alltraps>

c010299e <vector247>:
.globl vector247
vector247:
  pushl $0
c010299e:	6a 00                	push   $0x0
  pushl $247
c01029a0:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01029a5:	e9 60 00 00 00       	jmp    c0102a0a <__alltraps>

c01029aa <vector248>:
.globl vector248
vector248:
  pushl $0
c01029aa:	6a 00                	push   $0x0
  pushl $248
c01029ac:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01029b1:	e9 54 00 00 00       	jmp    c0102a0a <__alltraps>

c01029b6 <vector249>:
.globl vector249
vector249:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $249
c01029b8:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01029bd:	e9 48 00 00 00       	jmp    c0102a0a <__alltraps>

c01029c2 <vector250>:
.globl vector250
vector250:
  pushl $0
c01029c2:	6a 00                	push   $0x0
  pushl $250
c01029c4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01029c9:	e9 3c 00 00 00       	jmp    c0102a0a <__alltraps>

c01029ce <vector251>:
.globl vector251
vector251:
  pushl $0
c01029ce:	6a 00                	push   $0x0
  pushl $251
c01029d0:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01029d5:	e9 30 00 00 00       	jmp    c0102a0a <__alltraps>

c01029da <vector252>:
.globl vector252
vector252:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $252
c01029dc:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01029e1:	e9 24 00 00 00       	jmp    c0102a0a <__alltraps>

c01029e6 <vector253>:
.globl vector253
vector253:
  pushl $0
c01029e6:	6a 00                	push   $0x0
  pushl $253
c01029e8:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01029ed:	e9 18 00 00 00       	jmp    c0102a0a <__alltraps>

c01029f2 <vector254>:
.globl vector254
vector254:
  pushl $0
c01029f2:	6a 00                	push   $0x0
  pushl $254
c01029f4:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01029f9:	e9 0c 00 00 00       	jmp    c0102a0a <__alltraps>

c01029fe <vector255>:
.globl vector255
vector255:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $255
c0102a00:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102a05:	e9 00 00 00 00       	jmp    c0102a0a <__alltraps>

c0102a0a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a0a:	1e                   	push   %ds
    pushl %es
c0102a0b:	06                   	push   %es
    pushl %fs
c0102a0c:	0f a0                	push   %fs
    pushl %gs
c0102a0e:	0f a8                	push   %gs
    pushal
c0102a10:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a11:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a16:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a18:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a1a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a1b:	e8 64 f5 ff ff       	call   c0101f84 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a20:	5c                   	pop    %esp

c0102a21 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a21:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a22:	0f a9                	pop    %gs
    popl %fs
c0102a24:	0f a1                	pop    %fs
    popl %es
c0102a26:	07                   	pop    %es
    popl %ds
c0102a27:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a28:	83 c4 08             	add    $0x8,%esp
    iret
c0102a2b:	cf                   	iret   

c0102a2c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102a2c:	55                   	push   %ebp
c0102a2d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a32:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
c0102a38:	29 d0                	sub    %edx,%eax
c0102a3a:	c1 f8 02             	sar    $0x2,%eax
c0102a3d:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102a43:	5d                   	pop    %ebp
c0102a44:	c3                   	ret    

c0102a45 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102a45:	55                   	push   %ebp
c0102a46:	89 e5                	mov    %esp,%ebp
c0102a48:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a4e:	89 04 24             	mov    %eax,(%esp)
c0102a51:	e8 d6 ff ff ff       	call   c0102a2c <page2ppn>
c0102a56:	c1 e0 0c             	shl    $0xc,%eax
}
c0102a59:	c9                   	leave  
c0102a5a:	c3                   	ret    

c0102a5b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102a5b:	55                   	push   %ebp
c0102a5c:	89 e5                	mov    %esp,%ebp
c0102a5e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a64:	c1 e8 0c             	shr    $0xc,%eax
c0102a67:	89 c2                	mov    %eax,%edx
c0102a69:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102a6e:	39 c2                	cmp    %eax,%edx
c0102a70:	72 1c                	jb     c0102a8e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102a72:	c7 44 24 08 30 68 10 	movl   $0xc0106830,0x8(%esp)
c0102a79:	c0 
c0102a7a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0102a81:	00 
c0102a82:	c7 04 24 4f 68 10 c0 	movl   $0xc010684f,(%esp)
c0102a89:	e8 6b d9 ff ff       	call   c01003f9 <__panic>
    }
    return &pages[PPN(pa)];
c0102a8e:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
c0102a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a97:	c1 e8 0c             	shr    $0xc,%eax
c0102a9a:	89 c2                	mov    %eax,%edx
c0102a9c:	89 d0                	mov    %edx,%eax
c0102a9e:	c1 e0 02             	shl    $0x2,%eax
c0102aa1:	01 d0                	add    %edx,%eax
c0102aa3:	c1 e0 02             	shl    $0x2,%eax
c0102aa6:	01 c8                	add    %ecx,%eax
}
c0102aa8:	c9                   	leave  
c0102aa9:	c3                   	ret    

c0102aaa <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102aaa:	55                   	push   %ebp
c0102aab:	89 e5                	mov    %esp,%ebp
c0102aad:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab3:	89 04 24             	mov    %eax,(%esp)
c0102ab6:	e8 8a ff ff ff       	call   c0102a45 <page2pa>
c0102abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ac1:	c1 e8 0c             	shr    $0xc,%eax
c0102ac4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102ac7:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102acc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102acf:	72 23                	jb     c0102af4 <page2kva+0x4a>
c0102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ad8:	c7 44 24 08 60 68 10 	movl   $0xc0106860,0x8(%esp)
c0102adf:	c0 
c0102ae0:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0102ae7:	00 
c0102ae8:	c7 04 24 4f 68 10 c0 	movl   $0xc010684f,(%esp)
c0102aef:	e8 05 d9 ff ff       	call   c01003f9 <__panic>
c0102af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102af7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102afc:	c9                   	leave  
c0102afd:	c3                   	ret    

c0102afe <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102afe:	55                   	push   %ebp
c0102aff:	89 e5                	mov    %esp,%ebp
c0102b01:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102b04:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b07:	83 e0 01             	and    $0x1,%eax
c0102b0a:	85 c0                	test   %eax,%eax
c0102b0c:	75 1c                	jne    c0102b2a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102b0e:	c7 44 24 08 84 68 10 	movl   $0xc0106884,0x8(%esp)
c0102b15:	c0 
c0102b16:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c0102b1d:	00 
c0102b1e:	c7 04 24 4f 68 10 c0 	movl   $0xc010684f,(%esp)
c0102b25:	e8 cf d8 ff ff       	call   c01003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b32:	89 04 24             	mov    %eax,(%esp)
c0102b35:	e8 21 ff ff ff       	call   c0102a5b <pa2page>
}
c0102b3a:	c9                   	leave  
c0102b3b:	c3                   	ret    

c0102b3c <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102b3c:	55                   	push   %ebp
c0102b3d:	89 e5                	mov    %esp,%ebp
c0102b3f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b4a:	89 04 24             	mov    %eax,(%esp)
c0102b4d:	e8 09 ff ff ff       	call   c0102a5b <pa2page>
}
c0102b52:	c9                   	leave  
c0102b53:	c3                   	ret    

c0102b54 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102b54:	55                   	push   %ebp
c0102b55:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b5a:	8b 00                	mov    (%eax),%eax
}
c0102b5c:	5d                   	pop    %ebp
c0102b5d:	c3                   	ret    

c0102b5e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102b5e:	55                   	push   %ebp
c0102b5f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b64:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b67:	89 10                	mov    %edx,(%eax)
}
c0102b69:	90                   	nop
c0102b6a:	5d                   	pop    %ebp
c0102b6b:	c3                   	ret    

c0102b6c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102b6c:	55                   	push   %ebp
c0102b6d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b72:	8b 00                	mov    (%eax),%eax
c0102b74:	8d 50 01             	lea    0x1(%eax),%edx
c0102b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7f:	8b 00                	mov    (%eax),%eax
}
c0102b81:	5d                   	pop    %ebp
c0102b82:	c3                   	ret    

c0102b83 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102b83:	55                   	push   %ebp
c0102b84:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b89:	8b 00                	mov    (%eax),%eax
c0102b8b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b91:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b93:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b96:	8b 00                	mov    (%eax),%eax
}
c0102b98:	5d                   	pop    %ebp
c0102b99:	c3                   	ret    

c0102b9a <__intr_save>:
__intr_save(void) {     //TS自旋锁机制
c0102b9a:	55                   	push   %ebp
c0102b9b:	89 e5                	mov    %esp,%ebp
c0102b9d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102ba0:	9c                   	pushf  
c0102ba1:	58                   	pop    %eax
c0102ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
c0102ba8:	25 00 02 00 00       	and    $0x200,%eax
c0102bad:	85 c0                	test   %eax,%eax
c0102baf:	74 0c                	je     c0102bbd <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
c0102bb1:	e8 fa ec ff ff       	call   c01018b0 <intr_disable>
        return 1;
c0102bb6:	b8 01 00 00 00       	mov    $0x1,%eax
c0102bbb:	eb 05                	jmp    c0102bc2 <__intr_save+0x28>
    return 0;       //否则表明中断标志位为0
c0102bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102bc2:	c9                   	leave  
c0102bc3:	c3                   	ret    

c0102bc4 <__intr_restore>:
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
c0102bc4:	55                   	push   %ebp
c0102bc5:	89 e5                	mov    %esp,%ebp
c0102bc7:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102bca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102bce:	74 05                	je     c0102bd5 <__intr_restore+0x11>
        intr_enable();
c0102bd0:	e8 d4 ec ff ff       	call   c01018a9 <intr_enable>
}
c0102bd5:	90                   	nop
c0102bd6:	c9                   	leave  
c0102bd7:	c3                   	ret    

c0102bd8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102bd8:	55                   	push   %ebp
c0102bd9:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bde:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102be1:	b8 23 00 00 00       	mov    $0x23,%eax
c0102be6:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102be8:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bed:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102bef:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bf4:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102bf6:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bfb:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102bfd:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c02:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102c04:	ea 0b 2c 10 c0 08 00 	ljmp   $0x8,$0xc0102c0b
}
c0102c0b:	90                   	nop
c0102c0c:	5d                   	pop    %ebp
c0102c0d:	c3                   	ret    

c0102c0e <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102c0e:	55                   	push   %ebp
c0102c0f:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102c11:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c14:	a3 a4 be 11 c0       	mov    %eax,0xc011bea4
}
c0102c19:	90                   	nop
c0102c1a:	5d                   	pop    %ebp
c0102c1b:	c3                   	ret    

c0102c1c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102c1c:	55                   	push   %ebp
c0102c1d:	89 e5                	mov    %esp,%ebp
c0102c1f:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102c22:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0102c27:	89 04 24             	mov    %eax,(%esp)
c0102c2a:	e8 df ff ff ff       	call   c0102c0e <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102c2f:	66 c7 05 a8 be 11 c0 	movw   $0x10,0xc011bea8
c0102c36:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102c38:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0102c3f:	68 00 
c0102c41:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102c46:	0f b7 c0             	movzwl %ax,%eax
c0102c49:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0102c4f:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102c54:	c1 e8 10             	shr    $0x10,%eax
c0102c57:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0102c5c:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c63:	24 f0                	and    $0xf0,%al
c0102c65:	0c 09                	or     $0x9,%al
c0102c67:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c6c:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c73:	24 ef                	and    $0xef,%al
c0102c75:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c7a:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c81:	24 9f                	and    $0x9f,%al
c0102c83:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c88:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c8f:	0c 80                	or     $0x80,%al
c0102c91:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c96:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102c9d:	24 f0                	and    $0xf0,%al
c0102c9f:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102ca4:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102cab:	24 ef                	and    $0xef,%al
c0102cad:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102cb2:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102cb9:	24 df                	and    $0xdf,%al
c0102cbb:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102cc0:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102cc7:	0c 40                	or     $0x40,%al
c0102cc9:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102cce:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102cd5:	24 7f                	and    $0x7f,%al
c0102cd7:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102cdc:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102ce1:	c1 e8 18             	shr    $0x18,%eax
c0102ce4:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102ce9:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0102cf0:	e8 e3 fe ff ff       	call   c0102bd8 <lgdt>
c0102cf5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102cfb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102cff:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102d02:	90                   	nop
c0102d03:	c9                   	leave  
c0102d04:	c3                   	ret    

c0102d05 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102d05:	55                   	push   %ebp
c0102d06:	89 e5                	mov    %esp,%ebp
c0102d08:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102d0b:	c7 05 10 bf 11 c0 10 	movl   $0xc0107210,0xc011bf10
c0102d12:	72 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102d15:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d1a:	8b 00                	mov    (%eax),%eax
c0102d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102d20:	c7 04 24 b0 68 10 c0 	movl   $0xc01068b0,(%esp)
c0102d27:	e8 76 d5 ff ff       	call   c01002a2 <cprintf>
    pmm_manager->init();
c0102d2c:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d31:	8b 40 04             	mov    0x4(%eax),%eax
c0102d34:	ff d0                	call   *%eax
}
c0102d36:	90                   	nop
c0102d37:	c9                   	leave  
c0102d38:	c3                   	ret    

c0102d39 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c0102d39:	55                   	push   %ebp
c0102d3a:	89 e5                	mov    %esp,%ebp
c0102d3c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102d3f:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d44:	8b 40 08             	mov    0x8(%eax),%eax
c0102d47:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d4a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d4e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d51:	89 14 24             	mov    %edx,(%esp)
c0102d54:	ff d0                	call   *%eax
}
c0102d56:	90                   	nop
c0102d57:	c9                   	leave  
c0102d58:	c3                   	ret    

c0102d59 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
//分配连续的n个pagesize大小的内存空间，问题是为什么对页表的相关函数调用都需要先关闭中断呢？？？？
struct Page *
alloc_pages(size_t n) {
c0102d59:	55                   	push   %ebp
c0102d5a:	89 e5                	mov    %esp,%ebp
c0102d5c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag); //在sync中定义的函数，先关闭中断，再调用pmm_manager 的alloc_pages()函数进行页分配
c0102d66:	e8 2f fe ff ff       	call   c0102b9a <__intr_save>
c0102d6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102d6e:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d73:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d76:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d79:	89 14 24             	mov    %edx,(%esp)
c0102d7c:	ff d0                	call   *%eax
c0102d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);//开启中断
c0102d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d84:	89 04 24             	mov    %eax,(%esp)
c0102d87:	e8 38 fe ff ff       	call   c0102bc4 <__intr_restore>
    return page;
c0102d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102d8f:	c9                   	leave  
c0102d90:	c3                   	ret    

c0102d91 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//释放n个pagesize大小的内存
void
free_pages(struct Page *base, size_t n) {
c0102d91:	55                   	push   %ebp
c0102d92:	89 e5                	mov    %esp,%ebp
c0102d94:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d97:	e8 fe fd ff ff       	call   c0102b9a <__intr_save>
c0102d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102d9f:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102da4:	8b 40 10             	mov    0x10(%eax),%eax
c0102da7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102daa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102dae:	8b 55 08             	mov    0x8(%ebp),%edx
c0102db1:	89 14 24             	mov    %edx,(%esp)
c0102db4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102db9:	89 04 24             	mov    %eax,(%esp)
c0102dbc:	e8 03 fe ff ff       	call   c0102bc4 <__intr_restore>
}
c0102dc1:	90                   	nop
c0102dc2:	c9                   	leave  
c0102dc3:	c3                   	ret    

c0102dc4 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
//获取当前的空闲页数量
size_t
nr_free_pages(void) {
c0102dc4:	55                   	push   %ebp
c0102dc5:	89 e5                	mov    %esp,%ebp
c0102dc7:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102dca:	e8 cb fd ff ff       	call   c0102b9a <__intr_save>
c0102dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102dd2:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102dd7:	8b 40 14             	mov    0x14(%eax),%eax
c0102dda:	ff d0                	call   *%eax
c0102ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102de2:	89 04 24             	mov    %eax,(%esp)
c0102de5:	e8 da fd ff ff       	call   c0102bc4 <__intr_restore>
    return ret;
c0102dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102ded:	c9                   	leave  
c0102dee:	c3                   	ret    

c0102def <page_init>:

/* pmm_init - initialize the physical memory management */
// 初始化pmm
static void
page_init(void) {
c0102def:	55                   	push   %ebp
c0102df0:	89 e5                	mov    %esp,%ebp
c0102df2:	57                   	push   %edi
c0102df3:	56                   	push   %esi
c0102df4:	53                   	push   %ebx
c0102df5:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    //申明一个e820map变量，从0x8000开始
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102dfb:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102e02:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102e09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102e10:	c7 04 24 c7 68 10 c0 	movl   $0xc01068c7,(%esp)
c0102e17:	e8 86 d4 ff ff       	call   c01002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102e1c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e23:	e9 22 01 00 00       	jmp    c0102f4a <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e28:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e2e:	89 d0                	mov    %edx,%eax
c0102e30:	c1 e0 02             	shl    $0x2,%eax
c0102e33:	01 d0                	add    %edx,%eax
c0102e35:	c1 e0 02             	shl    $0x2,%eax
c0102e38:	01 c8                	add    %ecx,%eax
c0102e3a:	8b 50 08             	mov    0x8(%eax),%edx
c0102e3d:	8b 40 04             	mov    0x4(%eax),%eax
c0102e40:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102e43:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102e46:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e4c:	89 d0                	mov    %edx,%eax
c0102e4e:	c1 e0 02             	shl    $0x2,%eax
c0102e51:	01 d0                	add    %edx,%eax
c0102e53:	c1 e0 02             	shl    $0x2,%eax
c0102e56:	01 c8                	add    %ecx,%eax
c0102e58:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e5b:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e5e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e61:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e64:	01 c8                	add    %ecx,%eax
c0102e66:	11 da                	adc    %ebx,%edx
c0102e68:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e6b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102e6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e71:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e74:	89 d0                	mov    %edx,%eax
c0102e76:	c1 e0 02             	shl    $0x2,%eax
c0102e79:	01 d0                	add    %edx,%eax
c0102e7b:	c1 e0 02             	shl    $0x2,%eax
c0102e7e:	01 c8                	add    %ecx,%eax
c0102e80:	83 c0 14             	add    $0x14,%eax
c0102e83:	8b 00                	mov    (%eax),%eax
c0102e85:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102e88:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e8b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102e8e:	83 c0 ff             	add    $0xffffffff,%eax
c0102e91:	83 d2 ff             	adc    $0xffffffff,%edx
c0102e94:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102e9a:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102ea0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ea3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ea6:	89 d0                	mov    %edx,%eax
c0102ea8:	c1 e0 02             	shl    $0x2,%eax
c0102eab:	01 d0                	add    %edx,%eax
c0102ead:	c1 e0 02             	shl    $0x2,%eax
c0102eb0:	01 c8                	add    %ecx,%eax
c0102eb2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102eb5:	8b 58 10             	mov    0x10(%eax),%ebx
c0102eb8:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102ebb:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102ebf:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102ec5:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102ecb:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102ecf:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102ed3:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ed6:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102edd:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102ee1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102ee5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102ee9:	c7 04 24 d4 68 10 c0 	movl   $0xc01068d4,(%esp)
c0102ef0:	e8 ad d3 ff ff       	call   c01002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {      //用户区内存的第一段，获取交接处的地址
c0102ef5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ef8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102efb:	89 d0                	mov    %edx,%eax
c0102efd:	c1 e0 02             	shl    $0x2,%eax
c0102f00:	01 d0                	add    %edx,%eax
c0102f02:	c1 e0 02             	shl    $0x2,%eax
c0102f05:	01 c8                	add    %ecx,%eax
c0102f07:	83 c0 14             	add    $0x14,%eax
c0102f0a:	8b 00                	mov    (%eax),%eax
c0102f0c:	83 f8 01             	cmp    $0x1,%eax
c0102f0f:	75 36                	jne    c0102f47 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102f11:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f17:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102f1a:	77 2b                	ja     c0102f47 <page_init+0x158>
c0102f1c:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102f1f:	72 05                	jb     c0102f26 <page_init+0x137>
c0102f21:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102f24:	73 21                	jae    c0102f47 <page_init+0x158>
c0102f26:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102f2a:	77 1b                	ja     c0102f47 <page_init+0x158>
c0102f2c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102f30:	72 09                	jb     c0102f3b <page_init+0x14c>
c0102f32:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102f39:	77 0c                	ja     c0102f47 <page_init+0x158>
                maxpa = end;
c0102f3b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f3e:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102f44:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102f47:	ff 45 dc             	incl   -0x24(%ebp)
c0102f4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102f4d:	8b 00                	mov    (%eax),%eax
c0102f4f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102f52:	0f 8c d0 fe ff ff    	jl     c0102e28 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {   //获得最大的内存地址，从而获取需要管理的内存页个数
c0102f58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f5c:	72 1d                	jb     c0102f7b <page_init+0x18c>
c0102f5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f62:	77 09                	ja     c0102f6d <page_init+0x17e>
c0102f64:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102f6b:	76 0e                	jbe    c0102f7b <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102f6d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102f74:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;   //获取需要管理的页数
c0102f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f81:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f85:	c1 ea 0c             	shr    $0xc,%edx
c0102f88:	89 c1                	mov    %eax,%ecx
c0102f8a:	89 d3                	mov    %edx,%ebx
c0102f8c:	89 c8                	mov    %ecx,%eax
c0102f8e:	a3 80 be 11 c0       	mov    %eax,0xc011be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);    //向上取整获取管理内存空间的开始地址
c0102f93:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102f9a:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
c0102f9f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102fa2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102fa5:	01 d0                	add    %edx,%eax
c0102fa7:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102faa:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102fad:	ba 00 00 00 00       	mov    $0x0,%edx
c0102fb2:	f7 75 c0             	divl   -0x40(%ebp)
c0102fb5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102fb8:	29 d0                	sub    %edx,%eax
c0102fba:	a3 18 bf 11 c0       	mov    %eax,0xc011bf18
    //为所有的页设置保留位为1，即为内核保留的页空间
    for (i = 0; i < npage; i ++) {
c0102fbf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102fc6:	eb 2e                	jmp    c0102ff6 <page_init+0x207>
        SetPageReserved(pages + i);
c0102fc8:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
c0102fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fd1:	89 d0                	mov    %edx,%eax
c0102fd3:	c1 e0 02             	shl    $0x2,%eax
c0102fd6:	01 d0                	add    %edx,%eax
c0102fd8:	c1 e0 02             	shl    $0x2,%eax
c0102fdb:	01 c8                	add    %ecx,%eax
c0102fdd:	83 c0 04             	add    $0x4,%eax
c0102fe0:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102fe7:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fea:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102fed:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102ff0:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102ff3:	ff 45 dc             	incl   -0x24(%ebp)
c0102ff6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ff9:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102ffe:	39 c2                	cmp    %eax,%edx
c0103000:	72 c6                	jb     c0102fc8 <page_init+0x1d9>
    }
//获取空闲内存空间起始地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103002:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0103008:	89 d0                	mov    %edx,%eax
c010300a:	c1 e0 02             	shl    $0x2,%eax
c010300d:	01 d0                	add    %edx,%eax
c010300f:	c1 e0 02             	shl    $0x2,%eax
c0103012:	89 c2                	mov    %eax,%edx
c0103014:	a1 18 bf 11 c0       	mov    0xc011bf18,%eax
c0103019:	01 d0                	add    %edx,%eax
c010301b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010301e:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103025:	77 23                	ja     c010304a <page_init+0x25b>
c0103027:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010302a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010302e:	c7 44 24 08 04 69 10 	movl   $0xc0106904,0x8(%esp)
c0103035:	c0 
c0103036:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c010303d:	00 
c010303e:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103045:	e8 af d3 ff ff       	call   c01003f9 <__panic>
c010304a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010304d:	05 00 00 00 40       	add    $0x40000000,%eax
c0103052:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103055:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010305c:	e9 69 01 00 00       	jmp    c01031ca <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103061:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103064:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103067:	89 d0                	mov    %edx,%eax
c0103069:	c1 e0 02             	shl    $0x2,%eax
c010306c:	01 d0                	add    %edx,%eax
c010306e:	c1 e0 02             	shl    $0x2,%eax
c0103071:	01 c8                	add    %ecx,%eax
c0103073:	8b 50 08             	mov    0x8(%eax),%edx
c0103076:	8b 40 04             	mov    0x4(%eax),%eax
c0103079:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010307c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010307f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103082:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103085:	89 d0                	mov    %edx,%eax
c0103087:	c1 e0 02             	shl    $0x2,%eax
c010308a:	01 d0                	add    %edx,%eax
c010308c:	c1 e0 02             	shl    $0x2,%eax
c010308f:	01 c8                	add    %ecx,%eax
c0103091:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103094:	8b 58 10             	mov    0x10(%eax),%ebx
c0103097:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010309a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010309d:	01 c8                	add    %ecx,%eax
c010309f:	11 da                	adc    %ebx,%edx
c01030a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01030a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01030a7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030ad:	89 d0                	mov    %edx,%eax
c01030af:	c1 e0 02             	shl    $0x2,%eax
c01030b2:	01 d0                	add    %edx,%eax
c01030b4:	c1 e0 02             	shl    $0x2,%eax
c01030b7:	01 c8                	add    %ecx,%eax
c01030b9:	83 c0 14             	add    $0x14,%eax
c01030bc:	8b 00                	mov    (%eax),%eax
c01030be:	83 f8 01             	cmp    $0x1,%eax
c01030c1:	0f 85 00 01 00 00    	jne    c01031c7 <page_init+0x3d8>
            if (begin < freemem) {
c01030c7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01030ca:	ba 00 00 00 00       	mov    $0x0,%edx
c01030cf:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01030d2:	77 17                	ja     c01030eb <page_init+0x2fc>
c01030d4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01030d7:	72 05                	jb     c01030de <page_init+0x2ef>
c01030d9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01030dc:	73 0d                	jae    c01030eb <page_init+0x2fc>
                begin = freemem;
c01030de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01030e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030e4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01030eb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030ef:	72 1d                	jb     c010310e <page_init+0x31f>
c01030f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030f5:	77 09                	ja     c0103100 <page_init+0x311>
c01030f7:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01030fe:	76 0e                	jbe    c010310e <page_init+0x31f>
                end = KMEMSIZE;
c0103100:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103107:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010310e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103111:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103114:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103117:	0f 87 aa 00 00 00    	ja     c01031c7 <page_init+0x3d8>
c010311d:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103120:	72 09                	jb     c010312b <page_init+0x33c>
c0103122:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103125:	0f 83 9c 00 00 00    	jae    c01031c7 <page_init+0x3d8>
              //获得空闲空间的开始地址和结束地址
c010312b:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0103132:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103135:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103138:	01 d0                	add    %edx,%eax
c010313a:	48                   	dec    %eax
c010313b:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010313e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103141:	ba 00 00 00 00       	mov    $0x0,%edx
c0103146:	f7 75 b0             	divl   -0x50(%ebp)
c0103149:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010314c:	29 d0                	sub    %edx,%eax
c010314e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103153:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103156:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                begin = ROUNDUP(begin, PGSIZE);
c0103159:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010315c:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010315f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103162:	ba 00 00 00 00       	mov    $0x0,%edx
c0103167:	89 c3                	mov    %eax,%ebx
c0103169:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c010316f:	89 de                	mov    %ebx,%esi
c0103171:	89 d0                	mov    %edx,%eax
c0103173:	83 e0 00             	and    $0x0,%eax
c0103176:	89 c7                	mov    %eax,%edi
c0103178:	89 75 c8             	mov    %esi,-0x38(%ebp)
c010317b:	89 7d cc             	mov    %edi,-0x34(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010317e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103181:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103184:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103187:	77 3e                	ja     c01031c7 <page_init+0x3d8>
c0103189:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010318c:	72 05                	jb     c0103193 <page_init+0x3a4>
c010318e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103191:	73 34                	jae    c01031c7 <page_init+0x3d8>
                if (begin < end) {
c0103193:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103196:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103199:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010319c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010319f:	89 c1                	mov    %eax,%ecx
c01031a1:	89 d3                	mov    %edx,%ebx
c01031a3:	89 c8                	mov    %ecx,%eax
c01031a5:	89 da                	mov    %ebx,%edx
c01031a7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01031ab:	c1 ea 0c             	shr    $0xc,%edx
c01031ae:	89 c3                	mov    %eax,%ebx
c01031b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01031b3:	89 04 24             	mov    %eax,(%esp)
c01031b6:	e8 a0 f8 ff ff       	call   c0102a5b <pa2page>
c01031bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01031bf:	89 04 24             	mov    %eax,(%esp)
c01031c2:	e8 72 fb ff ff       	call   c0102d39 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01031c7:	ff 45 dc             	incl   -0x24(%ebp)
c01031ca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01031cd:	8b 00                	mov    (%eax),%eax
c01031cf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01031d2:	0f 8c 89 fe ff ff    	jl     c0103061 <page_init+0x272>
                  //将page结构中的flags位和引用位ref清零，并加入空闲链表管理
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
c01031d8:	90                   	nop
c01031d9:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01031df:	5b                   	pop    %ebx
c01031e0:	5e                   	pop    %esi
c01031e1:	5f                   	pop    %edi
c01031e2:	5d                   	pop    %ebp
c01031e3:	c3                   	ret    

c01031e4 <boot_map_segment>:
//boot_map_segment - setup&enable the paging mechanism
// parameters
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
c01031e4:	55                   	push   %ebp
c01031e5:	89 e5                	mov    %esp,%ebp
c01031e7:	83 ec 38             	sub    $0x38,%esp
static void
c01031ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031ed:	33 45 14             	xor    0x14(%ebp),%eax
c01031f0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031f5:	85 c0                	test   %eax,%eax
c01031f7:	74 24                	je     c010321d <boot_map_segment+0x39>
c01031f9:	c7 44 24 0c 36 69 10 	movl   $0xc0106936,0xc(%esp)
c0103200:	c0 
c0103201:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103208:	c0 
c0103209:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0103210:	00 
c0103211:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103218:	e8 dc d1 ff ff       	call   c01003f9 <__panic>
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010321d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103224:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103227:	25 ff 0f 00 00       	and    $0xfff,%eax
c010322c:	89 c2                	mov    %eax,%edx
c010322e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103231:	01 c2                	add    %eax,%edx
c0103233:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103236:	01 d0                	add    %edx,%eax
c0103238:	48                   	dec    %eax
c0103239:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010323c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010323f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103244:	f7 75 f0             	divl   -0x10(%ebp)
c0103247:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010324a:	29 d0                	sub    %edx,%eax
c010324c:	c1 e8 0c             	shr    $0xc,%eax
c010324f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(PGOFF(la) == PGOFF(pa));
c0103252:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103255:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103258:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010325b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103260:	89 45 0c             	mov    %eax,0xc(%ebp)
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103263:	8b 45 14             	mov    0x14(%ebp),%eax
c0103266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010326c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103271:	89 45 14             	mov    %eax,0x14(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103274:	eb 68                	jmp    c01032de <boot_map_segment+0xfa>
    pa = ROUNDDOWN(pa, PGSIZE);
c0103276:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010327d:	00 
c010327e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103281:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103285:	8b 45 08             	mov    0x8(%ebp),%eax
c0103288:	89 04 24             	mov    %eax,(%esp)
c010328b:	e8 81 01 00 00       	call   c0103411 <get_pte>
c0103290:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103293:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103297:	75 24                	jne    c01032bd <boot_map_segment+0xd9>
c0103299:	c7 44 24 0c 62 69 10 	movl   $0xc0106962,0xc(%esp)
c01032a0:	c0 
c01032a1:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01032a8:	c0 
c01032a9:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c01032b0:	00 
c01032b1:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01032b8:	e8 3c d1 ff ff       	call   c01003f9 <__panic>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01032bd:	8b 45 14             	mov    0x14(%ebp),%eax
c01032c0:	0b 45 18             	or     0x18(%ebp),%eax
c01032c3:	83 c8 01             	or     $0x1,%eax
c01032c6:	89 c2                	mov    %eax,%edx
c01032c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032cb:	89 10                	mov    %edx,(%eax)
    la = ROUNDDOWN(la, PGSIZE);
c01032cd:	ff 4d f4             	decl   -0xc(%ebp)
c01032d0:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01032d7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01032de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032e2:	75 92                	jne    c0103276 <boot_map_segment+0x92>
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
c01032e4:	90                   	nop
c01032e5:	c9                   	leave  
c01032e6:	c3                   	ret    

c01032e7 <boot_alloc_page>:
    }
}

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
c01032e7:	55                   	push   %ebp
c01032e8:	89 e5                	mov    %esp,%ebp
c01032ea:	83 ec 28             	sub    $0x28,%esp
static void *
c01032ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032f4:	e8 60 fa ff ff       	call   c0102d59 <alloc_pages>
c01032f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
boot_alloc_page(void) {
c01032fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103300:	75 1c                	jne    c010331e <boot_alloc_page+0x37>
    struct Page *p = alloc_page();
c0103302:	c7 44 24 08 6f 69 10 	movl   $0xc010696f,0x8(%esp)
c0103309:	c0 
c010330a:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103311:	00 
c0103312:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103319:	e8 db d0 ff ff       	call   c01003f9 <__panic>
    if (p == NULL) {
        panic("boot_alloc_page failed.\n");
c010331e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103321:	89 04 24             	mov    %eax,(%esp)
c0103324:	e8 81 f7 ff ff       	call   c0102aaa <page2kva>
    }
c0103329:	c9                   	leave  
c010332a:	c3                   	ret    

c010332b <pmm_init>:
    return page2kva(p);
}

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
c010332b:	55                   	push   %ebp
c010332c:	89 e5                	mov    %esp,%ebp
c010332e:	83 ec 38             	sub    $0x38,%esp
void
pmm_init(void) {
c0103331:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103336:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103339:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103340:	77 23                	ja     c0103365 <pmm_init+0x3a>
c0103342:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103345:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103349:	c7 44 24 08 04 69 10 	movl   $0xc0106904,0x8(%esp)
c0103350:	c0 
c0103351:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0103358:	00 
c0103359:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103360:	e8 94 d0 ff ff       	call   c01003f9 <__panic>
c0103365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103368:	05 00 00 00 40       	add    $0x40000000,%eax
c010336d:	a3 14 bf 11 c0       	mov    %eax,0xc011bf14
    boot_cr3 = PADDR(boot_pgdir);

    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
c0103372:	e8 8e f9 ff ff       	call   c0102d05 <init_pmm_manager>
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
c0103377:	e8 73 fa ff ff       	call   c0102def <page_init>
    // then use pmm->init_memmap to create free page list
    page_init();

c010337c:	e8 e8 03 00 00       	call   c0103769 <check_alloc_page>
    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103381:	e8 02 04 00 00       	call   c0103788 <check_pgdir>

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
c0103386:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010338b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010338e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103395:	77 23                	ja     c01033ba <pmm_init+0x8f>
c0103397:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010339a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010339e:	c7 44 24 08 04 69 10 	movl   $0xc0106904,0x8(%esp)
c01033a5:	c0 
c01033a6:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c01033ad:	00 
c01033ae:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01033b5:	e8 3f d0 ff ff       	call   c01003f9 <__panic>
c01033ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033bd:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01033c3:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01033c8:	05 ac 0f 00 00       	add    $0xfac,%eax
c01033cd:	83 ca 03             	or     $0x3,%edx
c01033d0:	89 10                	mov    %edx,(%eax)
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;

    // map all physical memory to linear memory with base linear addr KERNBASE
c01033d2:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01033d7:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01033de:	00 
c01033df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01033e6:	00 
c01033e7:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01033ee:	38 
c01033ef:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01033f6:	c0 
c01033f7:	89 04 24             	mov    %eax,(%esp)
c01033fa:	e8 e5 fd ff ff       	call   c01031e4 <boot_map_segment>
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    //将4MB之外的线性地址映射到物理地址
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
c01033ff:	e8 18 f8 ff ff       	call   c0102c1c <gdt_init>
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();

c0103404:	e8 1b 0a 00 00       	call   c0103e24 <check_boot_pgdir>
    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
c0103409:	e8 94 0e 00 00       	call   c01042a2 <print_pgdir>
    check_boot_pgdir();

c010340e:	90                   	nop
c010340f:	c9                   	leave  
c0103410:	c3                   	ret    

c0103411 <get_pte>:
//get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
c0103411:	55                   	push   %ebp
c0103412:	89 e5                	mov    %esp,%ebp
c0103414:	83 ec 38             	sub    $0x38,%esp
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
c0103417:	8b 45 0c             	mov    0xc(%ebp),%eax
c010341a:	c1 e8 16             	shr    $0x16,%eax
c010341d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103424:	8b 45 08             	mov    0x8(%ebp),%eax
c0103427:	01 d0                	add    %edx,%eax
c0103429:	89 45 f4             	mov    %eax,-0xc(%ebp)
     */
c010342c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342f:	8b 00                	mov    (%eax),%eax
c0103431:	83 e0 01             	and    $0x1,%eax
c0103434:	85 c0                	test   %eax,%eax
c0103436:	0f 85 b9 00 00 00    	jne    c01034f5 <get_pte+0xe4>
#if 1
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry   通过参数中的pgdir加上页表目录偏移量（数组方式）获取页表目录地址
c010343c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103440:	75 0a                	jne    c010344c <get_pte+0x3b>
c0103442:	b8 00 00 00 00       	mov    $0x0,%eax
c0103447:	e9 06 01 00 00       	jmp    c0103552 <get_pte+0x141>
    if (!(*pdep&PTE_P)) {              // (2) check if entry is not present
c010344c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103453:	e8 01 f9 ff ff       	call   c0102d59 <alloc_pages>
c0103458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct Page*page;
c010345b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010345f:	75 0a                	jne    c010346b <get_pte+0x5a>
c0103461:	b8 00 00 00 00       	mov    $0x0,%eax
c0103466:	e9 e7 00 00 00       	jmp    c0103552 <get_pte+0x141>
    if(!create)  return NULL;                // (3) check if creating is needed, then alloc page for page table 不需要分配，直接返回NULL
    page = alloc_page();
c010346b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103472:	00 
c0103473:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103476:	89 04 24             	mov    %eax,(%esp)
c0103479:	e8 e0 f6 ff ff       	call   c0102b5e <set_page_ref>
    if(page==NULL)   return NULL; //没有找到能够分配的页
c010347e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103481:	89 04 24             	mov    %eax,(%esp)
c0103484:	e8 bc f5 ff ff       	call   c0102a45 <page2pa>
c0103489:	89 45 ec             	mov    %eax,-0x14(%ebp)
                                                          // CAUTION: this page is used for page table, not for common data page
c010348c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010348f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103492:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103495:	c1 e8 0c             	shr    $0xc,%eax
c0103498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010349b:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c01034a0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01034a3:	72 23                	jb     c01034c8 <get_pte+0xb7>
c01034a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034ac:	c7 44 24 08 60 68 10 	movl   $0xc0106860,0x8(%esp)
c01034b3:	c0 
c01034b4:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c01034bb:	00 
c01034bc:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01034c3:	e8 31 cf ff ff       	call   c01003f9 <__panic>
c01034c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034cb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01034d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01034d7:	00 
c01034d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01034df:	00 
c01034e0:	89 04 24             	mov    %eax,(%esp)
c01034e3:	e8 18 24 00 00       	call   c0105900 <memset>
    set_page_ref(page,1);     // (4) set page reference
c01034e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034eb:	83 c8 07             	or     $0x7,%eax
c01034ee:	89 c2                	mov    %eax,%edx
c01034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034f3:	89 10                	mov    %edx,(%eax)
    uintptr_t pa =page2pa(page); // (5) get linear address of page
    memset(KADDR(pa),0,PGSIZE);             // (6) clear page content using memset
c01034f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034f8:	8b 00                	mov    (%eax),%eax
c01034fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01034ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103502:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103505:	c1 e8 0c             	shr    $0xc,%eax
c0103508:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010350b:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103510:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103513:	72 23                	jb     c0103538 <get_pte+0x127>
c0103515:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103518:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010351c:	c7 44 24 08 60 68 10 	movl   $0xc0106860,0x8(%esp)
c0103523:	c0 
c0103524:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
c010352b:	00 
c010352c:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103533:	e8 c1 ce ff ff       	call   c01003f9 <__panic>
c0103538:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010353b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103540:	89 c2                	mov    %eax,%edx
c0103542:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103545:	c1 e8 0c             	shr    $0xc,%eax
c0103548:	25 ff 03 00 00       	and    $0x3ff,%eax
c010354d:	c1 e0 02             	shl    $0x2,%eax
c0103550:	01 d0                	add    %edx,%eax
    *pdep =pa|PTE_W|PTE_P|PTE_U;                      // (7) set page directory entry's permission  设置和物理地址，可写，用户可访问，可用位
    }
c0103552:	c9                   	leave  
c0103553:	c3                   	ret    

c0103554 <get_page>:
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry  拼接页表项、页表目录、表内偏移，得到物理地址之后转为虚拟地址返回
#endif
}

c0103554:	55                   	push   %ebp
c0103555:	89 e5                	mov    %esp,%ebp
c0103557:	83 ec 28             	sub    $0x28,%esp
//get_page - get related Page struct for linear address la using PDT pgdir
c010355a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103561:	00 
c0103562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103565:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103569:	8b 45 08             	mov    0x8(%ebp),%eax
c010356c:	89 04 24             	mov    %eax,(%esp)
c010356f:	e8 9d fe ff ff       	call   c0103411 <get_pte>
c0103574:	89 45 f4             	mov    %eax,-0xc(%ebp)
struct Page *
c0103577:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010357b:	74 08                	je     c0103585 <get_page+0x31>
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010357d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103580:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103583:	89 10                	mov    %edx,(%eax)
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep_store != NULL) {
c0103585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103589:	74 1b                	je     c01035a6 <get_page+0x52>
c010358b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010358e:	8b 00                	mov    (%eax),%eax
c0103590:	83 e0 01             	and    $0x1,%eax
c0103593:	85 c0                	test   %eax,%eax
c0103595:	74 0f                	je     c01035a6 <get_page+0x52>
        *ptep_store = ptep;
c0103597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359a:	8b 00                	mov    (%eax),%eax
c010359c:	89 04 24             	mov    %eax,(%esp)
c010359f:	e8 5a f5 ff ff       	call   c0102afe <pte2page>
c01035a4:	eb 05                	jmp    c01035ab <get_page+0x57>
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01035a6:	b8 00 00 00 00       	mov    $0x0,%eax
        return pte2page(*ptep);
c01035ab:	c9                   	leave  
c01035ac:	c3                   	ret    

c01035ad <page_remove_pte>:
    }
    return NULL;
}

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
c01035ad:	55                   	push   %ebp
c01035ae:	89 e5                	mov    %esp,%ebp
c01035b0:	83 ec 28             	sub    $0x28,%esp
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 , then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry, but only if the page tables being
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
c01035b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01035b6:	8b 00                	mov    (%eax),%eax
c01035b8:	83 e0 01             	and    $0x1,%eax
c01035bb:	85 c0                	test   %eax,%eax
c01035bd:	74 4d                	je     c010360c <page_remove_pte+0x5f>
     */
c01035bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01035c2:	8b 00                	mov    (%eax),%eax
c01035c4:	89 04 24             	mov    %eax,(%esp)
c01035c7:	e8 32 f5 ff ff       	call   c0102afe <pte2page>
c01035cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
#if 1
c01035cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035d2:	89 04 24             	mov    %eax,(%esp)
c01035d5:	e8 a9 f5 ff ff       	call   c0102b83 <page_ref_dec>
c01035da:	85 c0                	test   %eax,%eax
c01035dc:	75 13                	jne    c01035f1 <page_remove_pte+0x44>
    if (*ptep&PTE_P) {                      //(1) check if this page table entry is present   ?
c01035de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01035e5:	00 
c01035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e9:	89 04 24             	mov    %eax,(%esp)
c01035ec:	e8 a0 f7 ff ff       	call   c0102d91 <free_pages>
        struct Page *page =pte2page(*ptep); //(2) find corresponding page to pte
        if(page_ref_dec(page)==0){                          //(3) decrease page reference
c01035f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01035f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            free_page(page);  //(4) and free this page when page reference reachs 0
c01035fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103601:	8b 45 08             	mov    0x8(%ebp),%eax
c0103604:	89 04 24             	mov    %eax,(%esp)
c0103607:	e8 01 01 00 00       	call   c010370d <tlb_invalidate>
        }
        *ptep = 0;                          //(5) clear second page table entry
        tlb_invalidate(pgdir,la);                          //(6) flush tlb
c010360c:	90                   	nop
c010360d:	c9                   	leave  
c010360e:	c3                   	ret    

c010360f <page_remove>:
    }
#endif
}

c010360f:	55                   	push   %ebp
c0103610:	89 e5                	mov    %esp,%ebp
c0103612:	83 ec 28             	sub    $0x28,%esp
//page_remove - free an Page which is related linear address la and has an validated pte
c0103615:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010361c:	00 
c010361d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103620:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103624:	8b 45 08             	mov    0x8(%ebp),%eax
c0103627:	89 04 24             	mov    %eax,(%esp)
c010362a:	e8 e2 fd ff ff       	call   c0103411 <get_pte>
c010362f:	89 45 f4             	mov    %eax,-0xc(%ebp)
void
c0103632:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103636:	74 19                	je     c0103651 <page_remove+0x42>
page_remove(pde_t *pgdir, uintptr_t la) {
c0103638:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010363f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103646:	8b 45 08             	mov    0x8(%ebp),%eax
c0103649:	89 04 24             	mov    %eax,(%esp)
c010364c:	e8 5c ff ff ff       	call   c01035ad <page_remove_pte>
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL) {
c0103651:	90                   	nop
c0103652:	c9                   	leave  
c0103653:	c3                   	ret    

c0103654 <page_insert>:
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
c0103654:	55                   	push   %ebp
c0103655:	89 e5                	mov    %esp,%ebp
c0103657:	83 ec 28             	sub    $0x28,%esp
//note: PT is changed, so the TLB need to be invalidate
c010365a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103661:	00 
c0103662:	8b 45 10             	mov    0x10(%ebp),%eax
c0103665:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103669:	8b 45 08             	mov    0x8(%ebp),%eax
c010366c:	89 04 24             	mov    %eax,(%esp)
c010366f:	e8 9d fd ff ff       	call   c0103411 <get_pte>
c0103674:	89 45 f4             	mov    %eax,-0xc(%ebp)
int
c0103677:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010367b:	75 0a                	jne    c0103687 <page_insert+0x33>
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010367d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103682:	e9 84 00 00 00       	jmp    c010370b <page_insert+0xb7>
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
c0103687:	8b 45 0c             	mov    0xc(%ebp),%eax
c010368a:	89 04 24             	mov    %eax,(%esp)
c010368d:	e8 da f4 ff ff       	call   c0102b6c <page_ref_inc>
        return -E_NO_MEM;
c0103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103695:	8b 00                	mov    (%eax),%eax
c0103697:	83 e0 01             	and    $0x1,%eax
c010369a:	85 c0                	test   %eax,%eax
c010369c:	74 3e                	je     c01036dc <page_insert+0x88>
    }
c010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a1:	8b 00                	mov    (%eax),%eax
c01036a3:	89 04 24             	mov    %eax,(%esp)
c01036a6:	e8 53 f4 ff ff       	call   c0102afe <pte2page>
c01036ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    page_ref_inc(page);
c01036ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036b1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036b4:	75 0d                	jne    c01036c3 <page_insert+0x6f>
    if (*ptep & PTE_P) {
c01036b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036b9:	89 04 24             	mov    %eax,(%esp)
c01036bc:	e8 c2 f4 ff ff       	call   c0102b83 <page_ref_dec>
c01036c1:	eb 19                	jmp    c01036dc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
c01036c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01036ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01036cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d4:	89 04 24             	mov    %eax,(%esp)
c01036d7:	e8 d1 fe ff ff       	call   c01035ad <page_remove_pte>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01036dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036df:	89 04 24             	mov    %eax,(%esp)
c01036e2:	e8 5e f3 ff ff       	call   c0102a45 <page2pa>
c01036e7:	0b 45 14             	or     0x14(%ebp),%eax
c01036ea:	83 c8 01             	or     $0x1,%eax
c01036ed:	89 c2                	mov    %eax,%edx
c01036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f2:	89 10                	mov    %edx,(%eax)
        }
c01036f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01036f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01036fe:	89 04 24             	mov    %eax,(%esp)
c0103701:	e8 07 00 00 00       	call   c010370d <tlb_invalidate>
    }
c0103706:	b8 00 00 00 00       	mov    $0x0,%eax
    *ptep = page2pa(page) | PTE_P | perm;
c010370b:	c9                   	leave  
c010370c:	c3                   	ret    

c010370d <tlb_invalidate>:
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
c010370d:	55                   	push   %ebp
c010370e:	89 e5                	mov    %esp,%ebp
c0103710:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103713:	0f 20 d8             	mov    %cr3,%eax
c0103716:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103719:	8b 55 f0             	mov    -0x10(%ebp),%edx
// edited are the ones currently in use by the processor.
c010371c:	8b 45 08             	mov    0x8(%ebp),%eax
c010371f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103722:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103729:	77 23                	ja     c010374e <tlb_invalidate+0x41>
c010372b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010372e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103732:	c7 44 24 08 04 69 10 	movl   $0xc0106904,0x8(%esp)
c0103739:	c0 
c010373a:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
c0103741:	00 
c0103742:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103749:	e8 ab cc ff ff       	call   c01003f9 <__panic>
c010374e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103751:	05 00 00 00 40       	add    $0x40000000,%eax
c0103756:	39 d0                	cmp    %edx,%eax
c0103758:	75 0c                	jne    c0103766 <tlb_invalidate+0x59>
void
c010375a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010375d:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103760:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103763:	0f 01 38             	invlpg (%eax)
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) {
c0103766:	90                   	nop
c0103767:	c9                   	leave  
c0103768:	c3                   	ret    

c0103769 <check_alloc_page>:
        invlpg((void *)la);
    }
}
c0103769:	55                   	push   %ebp
c010376a:	89 e5                	mov    %esp,%ebp
c010376c:	83 ec 18             	sub    $0x18,%esp

c010376f:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0103774:	8b 40 18             	mov    0x18(%eax),%eax
c0103777:	ff d0                	call   *%eax
static void
c0103779:	c7 04 24 88 69 10 c0 	movl   $0xc0106988,(%esp)
c0103780:	e8 1d cb ff ff       	call   c01002a2 <cprintf>
check_alloc_page(void) {
c0103785:	90                   	nop
c0103786:	c9                   	leave  
c0103787:	c3                   	ret    

c0103788 <check_pgdir>:
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
c0103788:	55                   	push   %ebp
c0103789:	89 e5                	mov    %esp,%ebp
c010378b:	83 ec 38             	sub    $0x38,%esp

c010378e:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103793:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103798:	76 24                	jbe    c01037be <check_pgdir+0x36>
c010379a:	c7 44 24 0c a7 69 10 	movl   $0xc01069a7,0xc(%esp)
c01037a1:	c0 
c01037a2:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01037a9:	c0 
c01037aa:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c01037b1:	00 
c01037b2:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01037b9:	e8 3b cc ff ff       	call   c01003f9 <__panic>
static void
c01037be:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037c3:	85 c0                	test   %eax,%eax
c01037c5:	74 0e                	je     c01037d5 <check_pgdir+0x4d>
c01037c7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037cc:	25 ff 0f 00 00       	and    $0xfff,%eax
c01037d1:	85 c0                	test   %eax,%eax
c01037d3:	74 24                	je     c01037f9 <check_pgdir+0x71>
c01037d5:	c7 44 24 0c c4 69 10 	movl   $0xc01069c4,0xc(%esp)
c01037dc:	c0 
c01037dd:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01037e4:	c0 
c01037e5:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01037ec:	00 
c01037ed:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01037f4:	e8 00 cc ff ff       	call   c01003f9 <__panic>
check_pgdir(void) {
c01037f9:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103805:	00 
c0103806:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010380d:	00 
c010380e:	89 04 24             	mov    %eax,(%esp)
c0103811:	e8 3e fd ff ff       	call   c0103554 <get_page>
c0103816:	85 c0                	test   %eax,%eax
c0103818:	74 24                	je     c010383e <check_pgdir+0xb6>
c010381a:	c7 44 24 0c fc 69 10 	movl   $0xc01069fc,0xc(%esp)
c0103821:	c0 
c0103822:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103829:	c0 
c010382a:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103831:	00 
c0103832:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103839:	e8 bb cb ff ff       	call   c01003f9 <__panic>
    assert(npage <= KMEMSIZE / PGSIZE);
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010383e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103845:	e8 0f f5 ff ff       	call   c0102d59 <alloc_pages>
c010384a:	89 45 f4             	mov    %eax,-0xc(%ebp)

c010384d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103852:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103859:	00 
c010385a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103861:	00 
c0103862:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103865:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103869:	89 04 24             	mov    %eax,(%esp)
c010386c:	e8 e3 fd ff ff       	call   c0103654 <page_insert>
c0103871:	85 c0                	test   %eax,%eax
c0103873:	74 24                	je     c0103899 <check_pgdir+0x111>
c0103875:	c7 44 24 0c 24 6a 10 	movl   $0xc0106a24,0xc(%esp)
c010387c:	c0 
c010387d:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103884:	c0 
c0103885:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c010388c:	00 
c010388d:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103894:	e8 60 cb ff ff       	call   c01003f9 <__panic>
    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103899:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010389e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038a5:	00 
c01038a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01038ad:	00 
c01038ae:	89 04 24             	mov    %eax,(%esp)
c01038b1:	e8 5b fb ff ff       	call   c0103411 <get_pte>
c01038b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038bd:	75 24                	jne    c01038e3 <check_pgdir+0x15b>
c01038bf:	c7 44 24 0c 50 6a 10 	movl   $0xc0106a50,0xc(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01038ce:	c0 
c01038cf:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c01038d6:	00 
c01038d7:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01038de:	e8 16 cb ff ff       	call   c01003f9 <__panic>

c01038e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038e6:	8b 00                	mov    (%eax),%eax
c01038e8:	89 04 24             	mov    %eax,(%esp)
c01038eb:	e8 0e f2 ff ff       	call   c0102afe <pte2page>
c01038f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01038f3:	74 24                	je     c0103919 <check_pgdir+0x191>
c01038f5:	c7 44 24 0c 7d 6a 10 	movl   $0xc0106a7d,0xc(%esp)
c01038fc:	c0 
c01038fd:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103904:	c0 
c0103905:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c010390c:	00 
c010390d:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103914:	e8 e0 ca ff ff       	call   c01003f9 <__panic>
    pte_t *ptep;
c0103919:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391c:	89 04 24             	mov    %eax,(%esp)
c010391f:	e8 30 f2 ff ff       	call   c0102b54 <page_ref>
c0103924:	83 f8 01             	cmp    $0x1,%eax
c0103927:	74 24                	je     c010394d <check_pgdir+0x1c5>
c0103929:	c7 44 24 0c 93 6a 10 	movl   $0xc0106a93,0xc(%esp)
c0103930:	c0 
c0103931:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103938:	c0 
c0103939:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0103940:	00 
c0103941:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103948:	e8 ac ca ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
c010394d:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103952:	8b 00                	mov    (%eax),%eax
c0103954:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103959:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010395c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010395f:	c1 e8 0c             	shr    $0xc,%eax
c0103962:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103965:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010396a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010396d:	72 23                	jb     c0103992 <check_pgdir+0x20a>
c010396f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103972:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103976:	c7 44 24 08 60 68 10 	movl   $0xc0106860,0x8(%esp)
c010397d:	c0 
c010397e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103985:	00 
c0103986:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c010398d:	e8 67 ca ff ff       	call   c01003f9 <__panic>
c0103992:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103995:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010399a:	83 c0 04             	add    $0x4,%eax
c010399d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(page_ref(p1) == 1);
c01039a0:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01039a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01039ac:	00 
c01039ad:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01039b4:	00 
c01039b5:	89 04 24             	mov    %eax,(%esp)
c01039b8:	e8 54 fa ff ff       	call   c0103411 <get_pte>
c01039bd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01039c0:	74 24                	je     c01039e6 <check_pgdir+0x25e>
c01039c2:	c7 44 24 0c a8 6a 10 	movl   $0xc0106aa8,0xc(%esp)
c01039c9:	c0 
c01039ca:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01039d1:	c0 
c01039d2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c01039d9:	00 
c01039da:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01039e1:	e8 13 ca ff ff       	call   c01003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01039e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039ed:	e8 67 f3 ff ff       	call   c0102d59 <alloc_pages>
c01039f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01039f5:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01039fa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103a01:	00 
c0103a02:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103a09:	00 
c0103a0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a11:	89 04 24             	mov    %eax,(%esp)
c0103a14:	e8 3b fc ff ff       	call   c0103654 <page_insert>
c0103a19:	85 c0                	test   %eax,%eax
c0103a1b:	74 24                	je     c0103a41 <check_pgdir+0x2b9>
c0103a1d:	c7 44 24 0c d0 6a 10 	movl   $0xc0106ad0,0xc(%esp)
c0103a24:	c0 
c0103a25:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103a2c:	c0 
c0103a2d:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103a34:	00 
c0103a35:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103a3c:	e8 b8 c9 ff ff       	call   c01003f9 <__panic>

c0103a41:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103a46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a4d:	00 
c0103a4e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a55:	00 
c0103a56:	89 04 24             	mov    %eax,(%esp)
c0103a59:	e8 b3 f9 ff ff       	call   c0103411 <get_pte>
c0103a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a65:	75 24                	jne    c0103a8b <check_pgdir+0x303>
c0103a67:	c7 44 24 0c 08 6b 10 	movl   $0xc0106b08,0xc(%esp)
c0103a6e:	c0 
c0103a6f:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103a76:	c0 
c0103a77:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103a7e:	00 
c0103a7f:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103a86:	e8 6e c9 ff ff       	call   c01003f9 <__panic>
    p2 = alloc_page();
c0103a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a8e:	8b 00                	mov    (%eax),%eax
c0103a90:	83 e0 04             	and    $0x4,%eax
c0103a93:	85 c0                	test   %eax,%eax
c0103a95:	75 24                	jne    c0103abb <check_pgdir+0x333>
c0103a97:	c7 44 24 0c 38 6b 10 	movl   $0xc0106b38,0xc(%esp)
c0103a9e:	c0 
c0103a9f:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103aa6:	c0 
c0103aa7:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103aae:	00 
c0103aaf:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103ab6:	e8 3e c9 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103abe:	8b 00                	mov    (%eax),%eax
c0103ac0:	83 e0 02             	and    $0x2,%eax
c0103ac3:	85 c0                	test   %eax,%eax
c0103ac5:	75 24                	jne    c0103aeb <check_pgdir+0x363>
c0103ac7:	c7 44 24 0c 46 6b 10 	movl   $0xc0106b46,0xc(%esp)
c0103ace:	c0 
c0103acf:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103ad6:	c0 
c0103ad7:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103ade:	00 
c0103adf:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103ae6:	e8 0e c9 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103aeb:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103af0:	8b 00                	mov    (%eax),%eax
c0103af2:	83 e0 04             	and    $0x4,%eax
c0103af5:	85 c0                	test   %eax,%eax
c0103af7:	75 24                	jne    c0103b1d <check_pgdir+0x395>
c0103af9:	c7 44 24 0c 54 6b 10 	movl   $0xc0106b54,0xc(%esp)
c0103b00:	c0 
c0103b01:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103b08:	c0 
c0103b09:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103b10:	00 
c0103b11:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103b18:	e8 dc c8 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_U);
c0103b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b20:	89 04 24             	mov    %eax,(%esp)
c0103b23:	e8 2c f0 ff ff       	call   c0102b54 <page_ref>
c0103b28:	83 f8 01             	cmp    $0x1,%eax
c0103b2b:	74 24                	je     c0103b51 <check_pgdir+0x3c9>
c0103b2d:	c7 44 24 0c 6a 6b 10 	movl   $0xc0106b6a,0xc(%esp)
c0103b34:	c0 
c0103b35:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103b3c:	c0 
c0103b3d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103b44:	00 
c0103b45:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103b4c:	e8 a8 c8 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
c0103b51:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103b56:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103b5d:	00 
c0103b5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103b65:	00 
c0103b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b6d:	89 04 24             	mov    %eax,(%esp)
c0103b70:	e8 df fa ff ff       	call   c0103654 <page_insert>
c0103b75:	85 c0                	test   %eax,%eax
c0103b77:	74 24                	je     c0103b9d <check_pgdir+0x415>
c0103b79:	c7 44 24 0c 7c 6b 10 	movl   $0xc0106b7c,0xc(%esp)
c0103b80:	c0 
c0103b81:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103b88:	c0 
c0103b89:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103b90:	00 
c0103b91:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103b98:	e8 5c c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 1);
c0103b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ba0:	89 04 24             	mov    %eax,(%esp)
c0103ba3:	e8 ac ef ff ff       	call   c0102b54 <page_ref>
c0103ba8:	83 f8 02             	cmp    $0x2,%eax
c0103bab:	74 24                	je     c0103bd1 <check_pgdir+0x449>
c0103bad:	c7 44 24 0c a8 6b 10 	movl   $0xc0106ba8,0xc(%esp)
c0103bb4:	c0 
c0103bb5:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103bbc:	c0 
c0103bbd:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0103bc4:	00 
c0103bc5:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103bcc:	e8 28 c8 ff ff       	call   c01003f9 <__panic>

c0103bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bd4:	89 04 24             	mov    %eax,(%esp)
c0103bd7:	e8 78 ef ff ff       	call   c0102b54 <page_ref>
c0103bdc:	85 c0                	test   %eax,%eax
c0103bde:	74 24                	je     c0103c04 <check_pgdir+0x47c>
c0103be0:	c7 44 24 0c ba 6b 10 	movl   $0xc0106bba,0xc(%esp)
c0103be7:	c0 
c0103be8:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103bef:	c0 
c0103bf0:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0103bf7:	00 
c0103bf8:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103bff:	e8 f5 c7 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103c04:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c10:	00 
c0103c11:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103c18:	00 
c0103c19:	89 04 24             	mov    %eax,(%esp)
c0103c1c:	e8 f0 f7 ff ff       	call   c0103411 <get_pte>
c0103c21:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c28:	75 24                	jne    c0103c4e <check_pgdir+0x4c6>
c0103c2a:	c7 44 24 0c 08 6b 10 	movl   $0xc0106b08,0xc(%esp)
c0103c31:	c0 
c0103c32:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103c39:	c0 
c0103c3a:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103c41:	00 
c0103c42:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103c49:	e8 ab c7 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 2);
c0103c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c51:	8b 00                	mov    (%eax),%eax
c0103c53:	89 04 24             	mov    %eax,(%esp)
c0103c56:	e8 a3 ee ff ff       	call   c0102afe <pte2page>
c0103c5b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103c5e:	74 24                	je     c0103c84 <check_pgdir+0x4fc>
c0103c60:	c7 44 24 0c 7d 6a 10 	movl   $0xc0106a7d,0xc(%esp)
c0103c67:	c0 
c0103c68:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103c6f:	c0 
c0103c70:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103c77:	00 
c0103c78:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103c7f:	e8 75 c7 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c87:	8b 00                	mov    (%eax),%eax
c0103c89:	83 e0 04             	and    $0x4,%eax
c0103c8c:	85 c0                	test   %eax,%eax
c0103c8e:	74 24                	je     c0103cb4 <check_pgdir+0x52c>
c0103c90:	c7 44 24 0c cc 6b 10 	movl   $0xc0106bcc,0xc(%esp)
c0103c97:	c0 
c0103c98:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103c9f:	c0 
c0103ca0:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0103ca7:	00 
c0103ca8:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103caf:	e8 45 c7 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
c0103cb4:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103cb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103cc0:	00 
c0103cc1:	89 04 24             	mov    %eax,(%esp)
c0103cc4:	e8 46 f9 ff ff       	call   c010360f <page_remove>
    assert((*ptep & PTE_U) == 0);
c0103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ccc:	89 04 24             	mov    %eax,(%esp)
c0103ccf:	e8 80 ee ff ff       	call   c0102b54 <page_ref>
c0103cd4:	83 f8 01             	cmp    $0x1,%eax
c0103cd7:	74 24                	je     c0103cfd <check_pgdir+0x575>
c0103cd9:	c7 44 24 0c 93 6a 10 	movl   $0xc0106a93,0xc(%esp)
c0103ce0:	c0 
c0103ce1:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103ce8:	c0 
c0103ce9:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103cf0:	00 
c0103cf1:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103cf8:	e8 fc c6 ff ff       	call   c01003f9 <__panic>

c0103cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d00:	89 04 24             	mov    %eax,(%esp)
c0103d03:	e8 4c ee ff ff       	call   c0102b54 <page_ref>
c0103d08:	85 c0                	test   %eax,%eax
c0103d0a:	74 24                	je     c0103d30 <check_pgdir+0x5a8>
c0103d0c:	c7 44 24 0c ba 6b 10 	movl   $0xc0106bba,0xc(%esp)
c0103d13:	c0 
c0103d14:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103d1b:	c0 
c0103d1c:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103d23:	00 
c0103d24:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103d2b:	e8 c9 c6 ff ff       	call   c01003f9 <__panic>
    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
c0103d30:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103d35:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103d3c:	00 
c0103d3d:	89 04 24             	mov    %eax,(%esp)
c0103d40:	e8 ca f8 ff ff       	call   c010360f <page_remove>
    assert(page_ref(p2) == 0);
c0103d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d48:	89 04 24             	mov    %eax,(%esp)
c0103d4b:	e8 04 ee ff ff       	call   c0102b54 <page_ref>
c0103d50:	85 c0                	test   %eax,%eax
c0103d52:	74 24                	je     c0103d78 <check_pgdir+0x5f0>
c0103d54:	c7 44 24 0c e1 6b 10 	movl   $0xc0106be1,0xc(%esp)
c0103d5b:	c0 
c0103d5c:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103d63:	c0 
c0103d64:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103d6b:	00 
c0103d6c:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103d73:	e8 81 c6 ff ff       	call   c01003f9 <__panic>

c0103d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d7b:	89 04 24             	mov    %eax,(%esp)
c0103d7e:	e8 d1 ed ff ff       	call   c0102b54 <page_ref>
c0103d83:	85 c0                	test   %eax,%eax
c0103d85:	74 24                	je     c0103dab <check_pgdir+0x623>
c0103d87:	c7 44 24 0c ba 6b 10 	movl   $0xc0106bba,0xc(%esp)
c0103d8e:	c0 
c0103d8f:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103d96:	c0 
c0103d97:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103d9e:	00 
c0103d9f:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103da6:	e8 4e c6 ff ff       	call   c01003f9 <__panic>
    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
c0103dab:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103db0:	8b 00                	mov    (%eax),%eax
c0103db2:	89 04 24             	mov    %eax,(%esp)
c0103db5:	e8 82 ed ff ff       	call   c0102b3c <pde2page>
c0103dba:	89 04 24             	mov    %eax,(%esp)
c0103dbd:	e8 92 ed ff ff       	call   c0102b54 <page_ref>
c0103dc2:	83 f8 01             	cmp    $0x1,%eax
c0103dc5:	74 24                	je     c0103deb <check_pgdir+0x663>
c0103dc7:	c7 44 24 0c f4 6b 10 	movl   $0xc0106bf4,0xc(%esp)
c0103dce:	c0 
c0103dcf:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103dd6:	c0 
c0103dd7:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103dde:	00 
c0103ddf:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103de6:	e8 0e c6 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103deb:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103df0:	8b 00                	mov    (%eax),%eax
c0103df2:	89 04 24             	mov    %eax,(%esp)
c0103df5:	e8 42 ed ff ff       	call   c0102b3c <pde2page>
c0103dfa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e01:	00 
c0103e02:	89 04 24             	mov    %eax,(%esp)
c0103e05:	e8 87 ef ff ff       	call   c0102d91 <free_pages>

c0103e0a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
    free_page(pde2page(boot_pgdir[0]));
c0103e15:	c7 04 24 1b 6c 10 c0 	movl   $0xc0106c1b,(%esp)
c0103e1c:	e8 81 c4 ff ff       	call   c01002a2 <cprintf>
    boot_pgdir[0] = 0;
c0103e21:	90                   	nop
c0103e22:	c9                   	leave  
c0103e23:	c3                   	ret    

c0103e24 <check_boot_pgdir>:

    cprintf("check_pgdir() succeeded!\n");
}
c0103e24:	55                   	push   %ebp
c0103e25:	89 e5                	mov    %esp,%ebp
c0103e27:	83 ec 38             	sub    $0x38,%esp

static void
check_boot_pgdir(void) {
c0103e2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103e31:	e9 ca 00 00 00       	jmp    c0103f00 <check_boot_pgdir+0xdc>
    pte_t *ptep;
c0103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e3f:	c1 e8 0c             	shr    $0xc,%eax
c0103e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103e45:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103e4a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103e4d:	72 23                	jb     c0103e72 <check_boot_pgdir+0x4e>
c0103e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e52:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e56:	c7 44 24 08 60 68 10 	movl   $0xc0106860,0x8(%esp)
c0103e5d:	c0 
c0103e5e:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103e65:	00 
c0103e66:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103e6d:	e8 87 c5 ff ff       	call   c01003f9 <__panic>
c0103e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e75:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103e7a:	89 c2                	mov    %eax,%edx
c0103e7c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e88:	00 
c0103e89:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e8d:	89 04 24             	mov    %eax,(%esp)
c0103e90:	e8 7c f5 ff ff       	call   c0103411 <get_pte>
c0103e95:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103e98:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103e9c:	75 24                	jne    c0103ec2 <check_boot_pgdir+0x9e>
c0103e9e:	c7 44 24 0c 38 6c 10 	movl   $0xc0106c38,0xc(%esp)
c0103ea5:	c0 
c0103ea6:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103ead:	c0 
c0103eae:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103eb5:	00 
c0103eb6:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103ebd:	e8 37 c5 ff ff       	call   c01003f9 <__panic>
    int i;
c0103ec2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ec5:	8b 00                	mov    (%eax),%eax
c0103ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ecc:	89 c2                	mov    %eax,%edx
c0103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ed1:	39 c2                	cmp    %eax,%edx
c0103ed3:	74 24                	je     c0103ef9 <check_boot_pgdir+0xd5>
c0103ed5:	c7 44 24 0c 75 6c 10 	movl   $0xc0106c75,0xc(%esp)
c0103edc:	c0 
c0103edd:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103ee4:	c0 
c0103ee5:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103eec:	00 
c0103eed:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103ef4:	e8 00 c5 ff ff       	call   c01003f9 <__panic>
check_boot_pgdir(void) {
c0103ef9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f03:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103f08:	39 c2                	cmp    %eax,%edx
c0103f0a:	0f 82 26 ff ff ff    	jb     c0103e36 <check_boot_pgdir+0x12>
    for (i = 0; i < npage; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
c0103f10:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103f15:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103f1a:	8b 00                	mov    (%eax),%eax
c0103f1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103f21:	89 c2                	mov    %eax,%edx
c0103f23:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f2b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103f32:	77 23                	ja     c0103f57 <check_boot_pgdir+0x133>
c0103f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f37:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f3b:	c7 44 24 08 04 69 10 	movl   $0xc0106904,0x8(%esp)
c0103f42:	c0 
c0103f43:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103f4a:	00 
c0103f4b:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103f52:	e8 a2 c4 ff ff       	call   c01003f9 <__panic>
c0103f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f5a:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f5f:	39 d0                	cmp    %edx,%eax
c0103f61:	74 24                	je     c0103f87 <check_boot_pgdir+0x163>
c0103f63:	c7 44 24 0c 8c 6c 10 	movl   $0xc0106c8c,0xc(%esp)
c0103f6a:	c0 
c0103f6b:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103f72:	c0 
c0103f73:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103f7a:	00 
c0103f7b:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103f82:	e8 72 c4 ff ff       	call   c01003f9 <__panic>
    }

c0103f87:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103f8c:	8b 00                	mov    (%eax),%eax
c0103f8e:	85 c0                	test   %eax,%eax
c0103f90:	74 24                	je     c0103fb6 <check_boot_pgdir+0x192>
c0103f92:	c7 44 24 0c c0 6c 10 	movl   $0xc0106cc0,0xc(%esp)
c0103f99:	c0 
c0103f9a:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103fa1:	c0 
c0103fa2:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103fa9:	00 
c0103faa:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0103fb1:	e8 43 c4 ff ff       	call   c01003f9 <__panic>
    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));

    assert(boot_pgdir[0] == 0);
c0103fb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fbd:	e8 97 ed ff ff       	call   c0102d59 <alloc_pages>
c0103fc2:	89 45 ec             	mov    %eax,-0x14(%ebp)

c0103fc5:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103fca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103fd1:	00 
c0103fd2:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103fd9:	00 
c0103fda:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103fdd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fe1:	89 04 24             	mov    %eax,(%esp)
c0103fe4:	e8 6b f6 ff ff       	call   c0103654 <page_insert>
c0103fe9:	85 c0                	test   %eax,%eax
c0103feb:	74 24                	je     c0104011 <check_boot_pgdir+0x1ed>
c0103fed:	c7 44 24 0c d4 6c 10 	movl   $0xc0106cd4,0xc(%esp)
c0103ff4:	c0 
c0103ff5:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0103ffc:	c0 
c0103ffd:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104004:	00 
c0104005:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c010400c:	e8 e8 c3 ff ff       	call   c01003f9 <__panic>
    struct Page *p;
c0104011:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104014:	89 04 24             	mov    %eax,(%esp)
c0104017:	e8 38 eb ff ff       	call   c0102b54 <page_ref>
c010401c:	83 f8 01             	cmp    $0x1,%eax
c010401f:	74 24                	je     c0104045 <check_boot_pgdir+0x221>
c0104021:	c7 44 24 0c 02 6d 10 	movl   $0xc0106d02,0xc(%esp)
c0104028:	c0 
c0104029:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0104030:	c0 
c0104031:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104038:	00 
c0104039:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0104040:	e8 b4 c3 ff ff       	call   c01003f9 <__panic>
    p = alloc_page();
c0104045:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010404a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104051:	00 
c0104052:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104059:	00 
c010405a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010405d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104061:	89 04 24             	mov    %eax,(%esp)
c0104064:	e8 eb f5 ff ff       	call   c0103654 <page_insert>
c0104069:	85 c0                	test   %eax,%eax
c010406b:	74 24                	je     c0104091 <check_boot_pgdir+0x26d>
c010406d:	c7 44 24 0c 14 6d 10 	movl   $0xc0106d14,0xc(%esp)
c0104074:	c0 
c0104075:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c010407c:	c0 
c010407d:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104084:	00 
c0104085:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c010408c:	e8 68 c3 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104091:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104094:	89 04 24             	mov    %eax,(%esp)
c0104097:	e8 b8 ea ff ff       	call   c0102b54 <page_ref>
c010409c:	83 f8 02             	cmp    $0x2,%eax
c010409f:	74 24                	je     c01040c5 <check_boot_pgdir+0x2a1>
c01040a1:	c7 44 24 0c 4b 6d 10 	movl   $0xc0106d4b,0xc(%esp)
c01040a8:	c0 
c01040a9:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c01040b0:	c0 
c01040b1:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c01040b8:	00 
c01040b9:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c01040c0:	e8 34 c3 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01040c5:	c7 45 e8 5c 6d 10 c0 	movl   $0xc0106d5c,-0x18(%ebp)
    assert(page_ref(p) == 2);
c01040cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040d3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040da:	e8 57 15 00 00       	call   c0105636 <strcpy>

c01040df:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01040e6:	00 
c01040e7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040ee:	e8 ba 15 00 00       	call   c01056ad <strcmp>
c01040f3:	85 c0                	test   %eax,%eax
c01040f5:	74 24                	je     c010411b <check_boot_pgdir+0x2f7>
c01040f7:	c7 44 24 0c 74 6d 10 	movl   $0xc0106d74,0xc(%esp)
c01040fe:	c0 
c01040ff:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c0104106:	c0 
c0104107:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010410e:	00 
c010410f:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c0104116:	e8 de c2 ff ff       	call   c01003f9 <__panic>
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
c010411b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010411e:	89 04 24             	mov    %eax,(%esp)
c0104121:	e8 84 e9 ff ff       	call   c0102aaa <page2kva>
c0104126:	05 00 01 00 00       	add    $0x100,%eax
c010412b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010412e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104135:	e8 a6 14 00 00       	call   c01055e0 <strlen>
c010413a:	85 c0                	test   %eax,%eax
c010413c:	74 24                	je     c0104162 <check_boot_pgdir+0x33e>
c010413e:	c7 44 24 0c ac 6d 10 	movl   $0xc0106dac,0xc(%esp)
c0104145:	c0 
c0104146:	c7 44 24 08 4d 69 10 	movl   $0xc010694d,0x8(%esp)
c010414d:	c0 
c010414e:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104155:	00 
c0104156:	c7 04 24 28 69 10 c0 	movl   $0xc0106928,(%esp)
c010415d:	e8 97 c2 ff ff       	call   c01003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0104162:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104169:	00 
c010416a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010416d:	89 04 24             	mov    %eax,(%esp)
c0104170:	e8 1c ec ff ff       	call   c0102d91 <free_pages>
    assert(strlen((const char *)0x100) == 0);
c0104175:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010417a:	8b 00                	mov    (%eax),%eax
c010417c:	89 04 24             	mov    %eax,(%esp)
c010417f:	e8 b8 e9 ff ff       	call   c0102b3c <pde2page>
c0104184:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010418b:	00 
c010418c:	89 04 24             	mov    %eax,(%esp)
c010418f:	e8 fd eb ff ff       	call   c0102d91 <free_pages>

c0104194:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104199:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    free_page(p);
    free_page(pde2page(boot_pgdir[0]));
c010419f:	c7 04 24 d0 6d 10 c0 	movl   $0xc0106dd0,(%esp)
c01041a6:	e8 f7 c0 ff ff       	call   c01002a2 <cprintf>
    boot_pgdir[0] = 0;
c01041ab:	90                   	nop
c01041ac:	c9                   	leave  
c01041ad:	c3                   	ret    

c01041ae <perm2str>:

    cprintf("check_boot_pgdir() succeeded!\n");
}

c01041ae:	55                   	push   %ebp
c01041af:	89 e5                	mov    %esp,%ebp
//perm2str - use string 'u,r,w,-' to present the permission
static const char *
c01041b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01041b4:	83 e0 04             	and    $0x4,%eax
c01041b7:	85 c0                	test   %eax,%eax
c01041b9:	74 04                	je     c01041bf <perm2str+0x11>
c01041bb:	b0 75                	mov    $0x75,%al
c01041bd:	eb 02                	jmp    c01041c1 <perm2str+0x13>
c01041bf:	b0 2d                	mov    $0x2d,%al
c01041c1:	a2 08 bf 11 c0       	mov    %al,0xc011bf08
perm2str(int perm) {
c01041c6:	c6 05 09 bf 11 c0 72 	movb   $0x72,0xc011bf09
    static char str[4];
c01041cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01041d0:	83 e0 02             	and    $0x2,%eax
c01041d3:	85 c0                	test   %eax,%eax
c01041d5:	74 04                	je     c01041db <perm2str+0x2d>
c01041d7:	b0 77                	mov    $0x77,%al
c01041d9:	eb 02                	jmp    c01041dd <perm2str+0x2f>
c01041db:	b0 2d                	mov    $0x2d,%al
c01041dd:	a2 0a bf 11 c0       	mov    %al,0xc011bf0a
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01041e2:	c6 05 0b bf 11 c0 00 	movb   $0x0,0xc011bf0b
    str[1] = 'r';
c01041e9:	b8 08 bf 11 c0       	mov    $0xc011bf08,%eax
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01041ee:	5d                   	pop    %ebp
c01041ef:	c3                   	ret    

c01041f0 <get_pgtable_items>:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
c01041f0:	55                   	push   %ebp
c01041f1:	89 e5                	mov    %esp,%ebp
c01041f3:	83 ec 10             	sub    $0x10,%esp
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
c01041f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01041f9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041fc:	72 0d                	jb     c010420b <get_pgtable_items+0x1b>
static int
c01041fe:	b8 00 00 00 00       	mov    $0x0,%eax
c0104203:	e9 98 00 00 00       	jmp    c01042a0 <get_pgtable_items+0xb0>
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
c0104208:	ff 45 10             	incl   0x10(%ebp)
    if (start >= right) {
c010420b:	8b 45 10             	mov    0x10(%ebp),%eax
c010420e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104211:	73 18                	jae    c010422b <get_pgtable_items+0x3b>
c0104213:	8b 45 10             	mov    0x10(%ebp),%eax
c0104216:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010421d:	8b 45 14             	mov    0x14(%ebp),%eax
c0104220:	01 d0                	add    %edx,%eax
c0104222:	8b 00                	mov    (%eax),%eax
c0104224:	83 e0 01             	and    $0x1,%eax
c0104227:	85 c0                	test   %eax,%eax
c0104229:	74 dd                	je     c0104208 <get_pgtable_items+0x18>
    }
    while (start < right && !(table[start] & PTE_P)) {
c010422b:	8b 45 10             	mov    0x10(%ebp),%eax
c010422e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104231:	73 68                	jae    c010429b <get_pgtable_items+0xab>
        start ++;
c0104233:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104237:	74 08                	je     c0104241 <get_pgtable_items+0x51>
    }
c0104239:	8b 45 18             	mov    0x18(%ebp),%eax
c010423c:	8b 55 10             	mov    0x10(%ebp),%edx
c010423f:	89 10                	mov    %edx,(%eax)
    if (start < right) {
        if (left_store != NULL) {
c0104241:	8b 45 10             	mov    0x10(%ebp),%eax
c0104244:	8d 50 01             	lea    0x1(%eax),%edx
c0104247:	89 55 10             	mov    %edx,0x10(%ebp)
c010424a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104251:	8b 45 14             	mov    0x14(%ebp),%eax
c0104254:	01 d0                	add    %edx,%eax
c0104256:	8b 00                	mov    (%eax),%eax
c0104258:	83 e0 07             	and    $0x7,%eax
c010425b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            *left_store = start;
c010425e:	eb 03                	jmp    c0104263 <get_pgtable_items+0x73>
        }
c0104260:	ff 45 10             	incl   0x10(%ebp)
            *left_store = start;
c0104263:	8b 45 10             	mov    0x10(%ebp),%eax
c0104266:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104269:	73 1d                	jae    c0104288 <get_pgtable_items+0x98>
c010426b:	8b 45 10             	mov    0x10(%ebp),%eax
c010426e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104275:	8b 45 14             	mov    0x14(%ebp),%eax
c0104278:	01 d0                	add    %edx,%eax
c010427a:	8b 00                	mov    (%eax),%eax
c010427c:	83 e0 07             	and    $0x7,%eax
c010427f:	89 c2                	mov    %eax,%edx
c0104281:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104284:	39 c2                	cmp    %eax,%edx
c0104286:	74 d8                	je     c0104260 <get_pgtable_items+0x70>
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104288:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010428c:	74 08                	je     c0104296 <get_pgtable_items+0xa6>
            start ++;
c010428e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104291:	8b 55 10             	mov    0x10(%ebp),%edx
c0104294:	89 10                	mov    %edx,(%eax)
        }
        if (right_store != NULL) {
c0104296:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104299:	eb 05                	jmp    c01042a0 <get_pgtable_items+0xb0>
            *right_store = start;
        }
c010429b:	b8 00 00 00 00       	mov    $0x0,%eax
        return perm;
c01042a0:	c9                   	leave  
c01042a1:	c3                   	ret    

c01042a2 <print_pgdir>:
    }
    return 0;
}

c01042a2:	55                   	push   %ebp
c01042a3:	89 e5                	mov    %esp,%ebp
c01042a5:	57                   	push   %edi
c01042a6:	56                   	push   %esi
c01042a7:	53                   	push   %ebx
c01042a8:	83 ec 4c             	sub    $0x4c,%esp
//print_pgdir - print the PDT&PT
c01042ab:	c7 04 24 f0 6d 10 c0 	movl   $0xc0106df0,(%esp)
c01042b2:	e8 eb bf ff ff       	call   c01002a2 <cprintf>
void
c01042b7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
print_pgdir(void) {
c01042be:	e9 fa 00 00 00       	jmp    c01043bd <print_pgdir+0x11b>
    cprintf("-------------------- BEGIN --------------------\n");
c01042c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042c6:	89 04 24             	mov    %eax,(%esp)
c01042c9:	e8 e0 fe ff ff       	call   c01041ae <perm2str>
    size_t left, right = 0, perm;
c01042ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01042d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042d4:	29 d1                	sub    %edx,%ecx
c01042d6:	89 ca                	mov    %ecx,%edx
    cprintf("-------------------- BEGIN --------------------\n");
c01042d8:	89 d6                	mov    %edx,%esi
c01042da:	c1 e6 16             	shl    $0x16,%esi
c01042dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042e0:	89 d3                	mov    %edx,%ebx
c01042e2:	c1 e3 16             	shl    $0x16,%ebx
c01042e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042e8:	89 d1                	mov    %edx,%ecx
c01042ea:	c1 e1 16             	shl    $0x16,%ecx
c01042ed:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01042f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042f3:	29 d7                	sub    %edx,%edi
c01042f5:	89 fa                	mov    %edi,%edx
c01042f7:	89 44 24 14          	mov    %eax,0x14(%esp)
c01042fb:	89 74 24 10          	mov    %esi,0x10(%esp)
c01042ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104303:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104307:	89 54 24 04          	mov    %edx,0x4(%esp)
c010430b:	c7 04 24 21 6e 10 c0 	movl   $0xc0106e21,(%esp)
c0104312:	e8 8b bf ff ff       	call   c01002a2 <cprintf>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104317:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010431a:	c1 e0 0a             	shl    $0xa,%eax
c010431d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104320:	eb 54                	jmp    c0104376 <print_pgdir+0xd4>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104322:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104325:	89 04 24             	mov    %eax,(%esp)
c0104328:	e8 81 fe ff ff       	call   c01041ae <perm2str>
        size_t l, r = left * NPTEENTRY;
c010432d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104330:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104333:	29 d1                	sub    %edx,%ecx
c0104335:	89 ca                	mov    %ecx,%edx
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104337:	89 d6                	mov    %edx,%esi
c0104339:	c1 e6 0c             	shl    $0xc,%esi
c010433c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010433f:	89 d3                	mov    %edx,%ebx
c0104341:	c1 e3 0c             	shl    $0xc,%ebx
c0104344:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104347:	89 d1                	mov    %edx,%ecx
c0104349:	c1 e1 0c             	shl    $0xc,%ecx
c010434c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010434f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104352:	29 d7                	sub    %edx,%edi
c0104354:	89 fa                	mov    %edi,%edx
c0104356:	89 44 24 14          	mov    %eax,0x14(%esp)
c010435a:	89 74 24 10          	mov    %esi,0x10(%esp)
c010435e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104366:	89 54 24 04          	mov    %edx,0x4(%esp)
c010436a:	c7 04 24 40 6e 10 c0 	movl   $0xc0106e40,(%esp)
c0104371:	e8 2c bf ff ff       	call   c01002a2 <cprintf>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104376:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010437b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010437e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104381:	89 d3                	mov    %edx,%ebx
c0104383:	c1 e3 0a             	shl    $0xa,%ebx
c0104386:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104389:	89 d1                	mov    %edx,%ecx
c010438b:	c1 e1 0a             	shl    $0xa,%ecx
c010438e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104391:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104395:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104398:	89 54 24 10          	mov    %edx,0x10(%esp)
c010439c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01043a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01043a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01043a8:	89 0c 24             	mov    %ecx,(%esp)
c01043ab:	e8 40 fe ff ff       	call   c01041f0 <get_pgtable_items>
c01043b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043b7:	0f 85 65 ff ff ff    	jne    c0104322 <print_pgdir+0x80>
print_pgdir(void) {
c01043bd:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01043c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043c5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01043c8:	89 54 24 14          	mov    %edx,0x14(%esp)
c01043cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01043cf:	89 54 24 10          	mov    %edx,0x10(%esp)
c01043d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01043d7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01043db:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01043e2:	00 
c01043e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01043ea:	e8 01 fe ff ff       	call   c01041f0 <get_pgtable_items>
c01043ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043f6:	0f 85 c7 fe ff ff    	jne    c01042c3 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01043fc:	c7 04 24 64 6e 10 c0 	movl   $0xc0106e64,(%esp)
c0104403:	e8 9a be ff ff       	call   c01002a2 <cprintf>
        }
c0104408:	90                   	nop
c0104409:	83 c4 4c             	add    $0x4c,%esp
c010440c:	5b                   	pop    %ebx
c010440d:	5e                   	pop    %esi
c010440e:	5f                   	pop    %edi
c010440f:	5d                   	pop    %ebp
c0104410:	c3                   	ret    

c0104411 <page2ppn>:
page2ppn(struct Page *page) {
c0104411:	55                   	push   %ebp
c0104412:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104414:	8b 45 08             	mov    0x8(%ebp),%eax
c0104417:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
c010441d:	29 d0                	sub    %edx,%eax
c010441f:	c1 f8 02             	sar    $0x2,%eax
c0104422:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104428:	5d                   	pop    %ebp
c0104429:	c3                   	ret    

c010442a <page2pa>:
page2pa(struct Page *page) {
c010442a:	55                   	push   %ebp
c010442b:	89 e5                	mov    %esp,%ebp
c010442d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104430:	8b 45 08             	mov    0x8(%ebp),%eax
c0104433:	89 04 24             	mov    %eax,(%esp)
c0104436:	e8 d6 ff ff ff       	call   c0104411 <page2ppn>
c010443b:	c1 e0 0c             	shl    $0xc,%eax
}
c010443e:	c9                   	leave  
c010443f:	c3                   	ret    

c0104440 <page_ref>:
page_ref(struct Page *page) {
c0104440:	55                   	push   %ebp
c0104441:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104443:	8b 45 08             	mov    0x8(%ebp),%eax
c0104446:	8b 00                	mov    (%eax),%eax
}
c0104448:	5d                   	pop    %ebp
c0104449:	c3                   	ret    

c010444a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010444a:	55                   	push   %ebp
c010444b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010444d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104450:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104453:	89 10                	mov    %edx,(%eax)
}
c0104455:	90                   	nop
c0104456:	5d                   	pop    %ebp
c0104457:	c3                   	ret    

c0104458 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104458:	55                   	push   %ebp
c0104459:	89 e5                	mov    %esp,%ebp
c010445b:	83 ec 10             	sub    $0x10,%esp
c010445e:	c7 45 fc 1c bf 11 c0 	movl   $0xc011bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104465:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104468:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010446b:	89 50 04             	mov    %edx,0x4(%eax)
c010446e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104471:	8b 50 04             	mov    0x4(%eax),%edx
c0104474:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104477:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104479:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c0104480:	00 00 00 
}
c0104483:	90                   	nop
c0104484:	c9                   	leave  
c0104485:	c3                   	ret    

c0104486 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104486:	55                   	push   %ebp
c0104487:	89 e5                	mov    %esp,%ebp
c0104489:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);    //断言，如果判断为false，直接中断程序的执行
c010448c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104490:	75 24                	jne    c01044b6 <default_init_memmap+0x30>
c0104492:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c0104499:	c0 
c010449a:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01044a1:	c0 
c01044a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01044a9:	00 
c01044aa:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01044b1:	e8 43 bf ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c01044b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01044b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01044bc:	eb 7d                	jmp    c010453b <default_init_memmap+0xb5>
        assert(PageReserved(p));        //判断该页保留位是否为1，如果为内核占用页则清空该标志位
c01044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044c1:	83 c0 04             	add    $0x4,%eax
c01044c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01044cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01044ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01044d4:	0f a3 10             	bt     %edx,(%eax)
c01044d7:	19 c0                	sbb    %eax,%eax
c01044d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01044dc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01044e0:	0f 95 c0             	setne  %al
c01044e3:	0f b6 c0             	movzbl %al,%eax
c01044e6:	85 c0                	test   %eax,%eax
c01044e8:	75 24                	jne    c010450e <default_init_memmap+0x88>
c01044ea:	c7 44 24 0c c9 6e 10 	movl   $0xc0106ec9,0xc(%esp)
c01044f1:	c0 
c01044f2:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01044f9:	c0 
c01044fa:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104501:	00 
c0104502:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104509:	e8 eb be ff ff       	call   c01003f9 <__panic>
        p->flags = p->property = 0;     //标志为清0，空闲块数量置0
c010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104511:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0104518:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010451b:	8b 50 08             	mov    0x8(%eax),%edx
c010451e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104521:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);                   //设置引用量为0
c0104524:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010452b:	00 
c010452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010452f:	89 04 24             	mov    %eax,(%esp)
c0104532:	e8 13 ff ff ff       	call   c010444a <set_page_ref>
    for (; p != base + n; p ++) {
c0104537:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010453b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010453e:	89 d0                	mov    %edx,%eax
c0104540:	c1 e0 02             	shl    $0x2,%eax
c0104543:	01 d0                	add    %edx,%eax
c0104545:	c1 e0 02             	shl    $0x2,%eax
c0104548:	89 c2                	mov    %eax,%edx
c010454a:	8b 45 08             	mov    0x8(%ebp),%eax
c010454d:	01 d0                	add    %edx,%eax
c010454f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104552:	0f 85 66 ff ff ff    	jne    c01044be <default_init_memmap+0x38>
    }
    base->property = n;
c0104558:	8b 45 08             	mov    0x8(%ebp),%eax
c010455b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010455e:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104561:	8b 45 08             	mov    0x8(%ebp),%eax
c0104564:	83 c0 04             	add    $0x4,%eax
c0104567:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010456e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104571:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104574:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104577:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010457a:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c0104580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104583:	01 d0                	add    %edx,%eax
c0104585:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
    //应该使用list_add_before,否则使用list_add默认为add_after,
    //这样新增加的页总是在后面，不适合FFMA算法，应该要按照地址排序
    list_add_before(&free_list, &(base->page_link));    //cc
c010458a:	8b 45 08             	mov    0x8(%ebp),%eax
c010458d:	83 c0 0c             	add    $0xc,%eax
c0104590:	c7 45 e4 1c bf 11 c0 	movl   $0xc011bf1c,-0x1c(%ebp)
c0104597:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010459a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010459d:	8b 00                	mov    (%eax),%eax
c010459f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01045a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01045a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01045ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01045b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01045b4:	89 10                	mov    %edx,(%eax)
c01045b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01045b9:	8b 10                	mov    (%eax),%edx
c01045bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01045be:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01045c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01045c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01045ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01045d0:	89 10                	mov    %edx,(%eax)
}
c01045d2:	90                   	nop
c01045d3:	c9                   	leave  
c01045d4:	c3                   	ret    

c01045d5 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01045d5:	55                   	push   %ebp
c01045d6:	89 e5                	mov    %esp,%ebp
c01045d8:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01045db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01045df:	75 24                	jne    c0104605 <default_alloc_pages+0x30>
c01045e1:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c01045e8:	c0 
c01045e9:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01045f0:	c0 
c01045f1:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c01045f8:	00 
c01045f9:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104600:	e8 f4 bd ff ff       	call   c01003f9 <__panic>
    if (n > nr_free) {      //要求的超过空闲空间大小，返回NULL
c0104605:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c010460a:	39 45 08             	cmp    %eax,0x8(%ebp)
c010460d:	76 0a                	jbe    c0104619 <default_alloc_pages+0x44>
        return NULL;
c010460f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104614:	e9 3d 01 00 00       	jmp    c0104756 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0104619:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;          //查找符合条件的page
c0104620:	c7 45 f0 1c bf 11 c0 	movl   $0xc011bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104627:	eb 1c                	jmp    c0104645 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0104629:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010462c:	83 e8 0c             	sub    $0xc,%eax
c010462f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {               //找到符合条件的块，赋值给page变量带出
c0104632:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104635:	8b 40 08             	mov    0x8(%eax),%eax
c0104638:	39 45 08             	cmp    %eax,0x8(%ebp)
c010463b:	77 08                	ja     c0104645 <default_alloc_pages+0x70>
            page = p;
c010463d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104640:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104643:	eb 18                	jmp    c010465d <default_alloc_pages+0x88>
c0104645:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010464b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010464e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104651:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104654:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c010465b:	75 cc                	jne    c0104629 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {           //找到了符合条件的页，进行设置
c010465d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104661:	0f 84 ec 00 00 00    	je     c0104753 <default_alloc_pages+0x17e>
        if (page->property > n) {
c0104667:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466a:	8b 40 08             	mov    0x8(%eax),%eax
c010466d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104670:	0f 83 8c 00 00 00    	jae    c0104702 <default_alloc_pages+0x12d>
            struct Page *p = page + n;        //将多余的页空间，重新放入空闲页表目录
c0104676:	8b 55 08             	mov    0x8(%ebp),%edx
c0104679:	89 d0                	mov    %edx,%eax
c010467b:	c1 e0 02             	shl    $0x2,%eax
c010467e:	01 d0                	add    %edx,%eax
c0104680:	c1 e0 02             	shl    $0x2,%eax
c0104683:	89 c2                	mov    %eax,%edx
c0104685:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104688:	01 d0                	add    %edx,%eax
c010468a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104690:	8b 40 08             	mov    0x8(%eax),%eax
c0104693:	2b 45 08             	sub    0x8(%ebp),%eax
c0104696:	89 c2                	mov    %eax,%edx
c0104698:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010469b:	89 50 08             	mov    %edx,0x8(%eax)
            //应该要对剩余的部分空闲页设置属性位，在init中属性位全为0，这里需要设为1,表明空闲块
            SetPageProperty(p);                 //++
c010469e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046a1:	83 c0 04             	add    $0x4,%eax
c01046a4:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01046ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01046ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01046b1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01046b4:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));  //cc注意一定要添加在后面,按地址排序
c01046b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01046ba:	83 c0 0c             	add    $0xc,%eax
c01046bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01046c0:	83 c2 0c             	add    $0xc,%edx
c01046c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01046c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c01046c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01046cc:	8b 40 04             	mov    0x4(%eax),%eax
c01046cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01046d2:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01046d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01046d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01046db:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01046de:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01046e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01046e4:	89 10                	mov    %edx,(%eax)
c01046e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01046e9:	8b 10                	mov    (%eax),%edx
c01046eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01046f7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01046fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104700:	89 10                	mov    %edx,(%eax)
    }
      list_del(&(page->page_link));     // 先要处理完剩余空间再删除该页，从空闲页表目录页删除该页
c0104702:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104705:	83 c0 0c             	add    $0xc,%eax
c0104708:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c010470b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010470e:	8b 40 04             	mov    0x4(%eax),%eax
c0104711:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104714:	8b 12                	mov    (%edx),%edx
c0104716:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0104719:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010471c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010471f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104722:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104725:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104728:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010472b:	89 10                	mov    %edx,(%eax)
      nr_free -= n;       //总空闲块数减去分配页块数
c010472d:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104732:	2b 45 08             	sub    0x8(%ebp),%eax
c0104735:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
      ClearPageProperty(page);//将属性位置0，标记该页已被分配
c010473a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010473d:	83 c0 04             	add    $0x4,%eax
c0104740:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104747:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010474a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010474d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104750:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104753:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104756:	c9                   	leave  
c0104757:	c3                   	ret    

c0104758 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104758:	55                   	push   %ebp
c0104759:	89 e5                	mov    %esp,%ebp
c010475b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104761:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104765:	75 24                	jne    c010478b <default_free_pages+0x33>
c0104767:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c010476e:	c0 
c010476f:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104776:	c0 
c0104777:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010477e:	00 
c010477f:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104786:	e8 6e bc ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c010478b:	8b 45 08             	mov    0x8(%ebp),%eax
c010478e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
c0104791:	e9 9d 00 00 00       	jmp    c0104833 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));     //否则为用户态的占用区
c0104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104799:	83 c0 04             	add    $0x4,%eax
c010479c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01047a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01047ac:	0f a3 10             	bt     %edx,(%eax)
c01047af:	19 c0                	sbb    %eax,%eax
c01047b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01047b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01047b8:	0f 95 c0             	setne  %al
c01047bb:	0f b6 c0             	movzbl %al,%eax
c01047be:	85 c0                	test   %eax,%eax
c01047c0:	75 2c                	jne    c01047ee <default_free_pages+0x96>
c01047c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c5:	83 c0 04             	add    $0x4,%eax
c01047c8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01047cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01047d8:	0f a3 10             	bt     %edx,(%eax)
c01047db:	19 c0                	sbb    %eax,%eax
c01047dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01047e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01047e4:	0f 95 c0             	setne  %al
c01047e7:	0f b6 c0             	movzbl %al,%eax
c01047ea:	85 c0                	test   %eax,%eax
c01047ec:	74 24                	je     c0104812 <default_free_pages+0xba>
c01047ee:	c7 44 24 0c dc 6e 10 	movl   $0xc0106edc,0xc(%esp)
c01047f5:	c0 
c01047f6:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01047fd:	c0 
c01047fe:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0104805:	00 
c0104806:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010480d:	e8 e7 bb ff ff       	call   c01003f9 <__panic>
        p->flags = 0;         //标志位清零
c0104812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104815:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010481c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104823:	00 
c0104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104827:	89 04 24             	mov    %eax,(%esp)
c010482a:	e8 1b fc ff ff       	call   c010444a <set_page_ref>
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
c010482f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104833:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104836:	89 d0                	mov    %edx,%eax
c0104838:	c1 e0 02             	shl    $0x2,%eax
c010483b:	01 d0                	add    %edx,%eax
c010483d:	c1 e0 02             	shl    $0x2,%eax
c0104840:	89 c2                	mov    %eax,%edx
c0104842:	8b 45 08             	mov    0x8(%ebp),%eax
c0104845:	01 d0                	add    %edx,%eax
c0104847:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010484a:	0f 85 46 ff ff ff    	jne    c0104796 <default_free_pages+0x3e>
    }
    base->property = n;
c0104850:	8b 45 08             	mov    0x8(%ebp),%eax
c0104853:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104856:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104859:	8b 45 08             	mov    0x8(%ebp),%eax
c010485c:	83 c0 04             	add    $0x4,%eax
c010485f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104866:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104869:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010486c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010486f:	0f ab 10             	bts    %edx,(%eax)
c0104872:	c7 45 d4 1c bf 11 c0 	movl   $0xc011bf1c,-0x2c(%ebp)
    return listelm->next;
c0104879:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010487c:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);    //获取头页地址
c010487f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {            //合并空页
c0104882:	e9 08 01 00 00       	jmp    c010498f <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104887:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488a:	83 e8 0c             	sub    $0xc,%eax
c010488d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104890:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104893:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104896:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104899:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010489c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {     //如果该页为当前释放页的紧邻后页，则直接释放后面一页的属性位，将之和当前页合并
c010489f:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a2:	8b 50 08             	mov    0x8(%eax),%edx
c01048a5:	89 d0                	mov    %edx,%eax
c01048a7:	c1 e0 02             	shl    $0x2,%eax
c01048aa:	01 d0                	add    %edx,%eax
c01048ac:	c1 e0 02             	shl    $0x2,%eax
c01048af:	89 c2                	mov    %eax,%edx
c01048b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048b4:	01 d0                	add    %edx,%eax
c01048b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01048b9:	75 5a                	jne    c0104915 <default_free_pages+0x1bd>
            base->property += p->property;
c01048bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01048be:	8b 50 08             	mov    0x8(%eax),%edx
c01048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c4:	8b 40 08             	mov    0x8(%eax),%eax
c01048c7:	01 c2                	add    %eax,%edx
c01048c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01048cc:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);     //清楚属性位
c01048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d2:	83 c0 04             	add    $0x4,%eax
c01048d5:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01048dc:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01048df:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01048e2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01048e5:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));    //在空闲页表中删除该页
c01048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048eb:	83 c0 0c             	add    $0xc,%eax
c01048ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01048f1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01048f4:	8b 40 04             	mov    0x4(%eax),%eax
c01048f7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01048fa:	8b 12                	mov    (%edx),%edx
c01048fc:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01048ff:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104902:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104905:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104908:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010490b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010490e:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104911:	89 10                	mov    %edx,(%eax)
c0104913:	eb 7a                	jmp    c010498f <default_free_pages+0x237>
        }
        else if (p + p->property == base) {   //如果找到紧邻前一页是空页，则把前页合并到当前页
c0104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104918:	8b 50 08             	mov    0x8(%eax),%edx
c010491b:	89 d0                	mov    %edx,%eax
c010491d:	c1 e0 02             	shl    $0x2,%eax
c0104920:	01 d0                	add    %edx,%eax
c0104922:	c1 e0 02             	shl    $0x2,%eax
c0104925:	89 c2                	mov    %eax,%edx
c0104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010492a:	01 d0                	add    %edx,%eax
c010492c:	39 45 08             	cmp    %eax,0x8(%ebp)
c010492f:	75 5e                	jne    c010498f <default_free_pages+0x237>
            p->property += base->property;
c0104931:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104934:	8b 50 08             	mov    0x8(%eax),%edx
c0104937:	8b 45 08             	mov    0x8(%ebp),%eax
c010493a:	8b 40 08             	mov    0x8(%eax),%eax
c010493d:	01 c2                	add    %eax,%edx
c010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104942:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104945:	8b 45 08             	mov    0x8(%ebp),%eax
c0104948:	83 c0 04             	add    $0x4,%eax
c010494b:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104952:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104955:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104958:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010495b:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010495e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104961:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104964:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104967:	83 c0 0c             	add    $0xc,%eax
c010496a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010496d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104970:	8b 40 04             	mov    0x4(%eax),%eax
c0104973:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104976:	8b 12                	mov    (%edx),%edx
c0104978:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010497b:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010497e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104981:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104984:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104987:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010498a:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010498d:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {            //合并空页
c010498f:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c0104996:	0f 85 eb fe ff ff    	jne    c0104887 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
c010499c:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c01049a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049a5:	01 d0                	add    %edx,%eax
c01049a7:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
c01049ac:	c7 45 9c 1c bf 11 c0 	movl   $0xc011bf1c,-0x64(%ebp)
    return listelm->next;
c01049b3:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01049b6:	8b 40 04             	mov    0x4(%eax),%eax
    //从头到尾进行一次遍历，找到合适的插入位置,把合并和的页插入到找到的位置前面
    le  = list_next(&free_list);
c01049b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
c01049bc:	eb 34                	jmp    c01049f2 <default_free_pages+0x29a>
      p = le2page(le,page_link);
c01049be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049c1:	83 e8 0c             	sub    $0xc,%eax
c01049c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(base+base->property<=p){
c01049c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01049ca:	8b 50 08             	mov    0x8(%eax),%edx
c01049cd:	89 d0                	mov    %edx,%eax
c01049cf:	c1 e0 02             	shl    $0x2,%eax
c01049d2:	01 d0                	add    %edx,%eax
c01049d4:	c1 e0 02             	shl    $0x2,%eax
c01049d7:	89 c2                	mov    %eax,%edx
c01049d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01049dc:	01 d0                	add    %edx,%eax
c01049de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01049e1:	73 1a                	jae    c01049fd <default_free_pages+0x2a5>
c01049e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049e6:	89 45 98             	mov    %eax,-0x68(%ebp)
c01049e9:	8b 45 98             	mov    -0x68(%ebp),%eax
c01049ec:	8b 40 04             	mov    0x4(%eax),%eax
        break;
      }
      le = list_next(le);
c01049ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
c01049f2:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c01049f9:	75 c3                	jne    c01049be <default_free_pages+0x266>
c01049fb:	eb 01                	jmp    c01049fe <default_free_pages+0x2a6>
        break;
c01049fd:	90                   	nop
    }
    list_add_before(le, &(base->page_link));    //cc应该使用add_before把整合的页插入找到的位置
c01049fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a01:	8d 50 0c             	lea    0xc(%eax),%edx
c0104a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a07:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104a0a:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104a0d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104a10:	8b 00                	mov    (%eax),%eax
c0104a12:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104a15:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104a18:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104a1b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104a1e:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0104a21:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104a24:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104a27:	89 10                	mov    %edx,(%eax)
c0104a29:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104a2c:	8b 10                	mov    (%eax),%edx
c0104a2e:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104a31:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104a34:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a37:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104a3a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104a3d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a40:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104a43:	89 10                	mov    %edx,(%eax)
}
c0104a45:	90                   	nop
c0104a46:	c9                   	leave  
c0104a47:	c3                   	ret    

c0104a48 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104a48:	55                   	push   %ebp
c0104a49:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104a4b:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
}
c0104a50:	5d                   	pop    %ebp
c0104a51:	c3                   	ret    

c0104a52 <basic_check>:

static void
basic_check(void) {
c0104a52:	55                   	push   %ebp
c0104a53:	89 e5                	mov    %esp,%ebp
c0104a55:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104a58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a68:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104a6b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a72:	e8 e2 e2 ff ff       	call   c0102d59 <alloc_pages>
c0104a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104a7e:	75 24                	jne    c0104aa4 <basic_check+0x52>
c0104a80:	c7 44 24 0c 01 6f 10 	movl   $0xc0106f01,0xc(%esp)
c0104a87:	c0 
c0104a88:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104a8f:	c0 
c0104a90:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104a97:	00 
c0104a98:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104a9f:	e8 55 b9 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104aa4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104aab:	e8 a9 e2 ff ff       	call   c0102d59 <alloc_pages>
c0104ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ab3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ab7:	75 24                	jne    c0104add <basic_check+0x8b>
c0104ab9:	c7 44 24 0c 1d 6f 10 	movl   $0xc0106f1d,0xc(%esp)
c0104ac0:	c0 
c0104ac1:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104ac8:	c0 
c0104ac9:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104ad0:	00 
c0104ad1:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104ad8:	e8 1c b9 ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104add:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ae4:	e8 70 e2 ff ff       	call   c0102d59 <alloc_pages>
c0104ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104aec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104af0:	75 24                	jne    c0104b16 <basic_check+0xc4>
c0104af2:	c7 44 24 0c 39 6f 10 	movl   $0xc0106f39,0xc(%esp)
c0104af9:	c0 
c0104afa:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104b01:	c0 
c0104b02:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104b09:	00 
c0104b0a:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104b11:	e8 e3 b8 ff ff       	call   c01003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b19:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b1c:	74 10                	je     c0104b2e <basic_check+0xdc>
c0104b1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b24:	74 08                	je     c0104b2e <basic_check+0xdc>
c0104b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b29:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b2c:	75 24                	jne    c0104b52 <basic_check+0x100>
c0104b2e:	c7 44 24 0c 58 6f 10 	movl   $0xc0106f58,0xc(%esp)
c0104b35:	c0 
c0104b36:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104b3d:	c0 
c0104b3e:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104b45:	00 
c0104b46:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104b4d:	e8 a7 b8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b55:	89 04 24             	mov    %eax,(%esp)
c0104b58:	e8 e3 f8 ff ff       	call   c0104440 <page_ref>
c0104b5d:	85 c0                	test   %eax,%eax
c0104b5f:	75 1e                	jne    c0104b7f <basic_check+0x12d>
c0104b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b64:	89 04 24             	mov    %eax,(%esp)
c0104b67:	e8 d4 f8 ff ff       	call   c0104440 <page_ref>
c0104b6c:	85 c0                	test   %eax,%eax
c0104b6e:	75 0f                	jne    c0104b7f <basic_check+0x12d>
c0104b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b73:	89 04 24             	mov    %eax,(%esp)
c0104b76:	e8 c5 f8 ff ff       	call   c0104440 <page_ref>
c0104b7b:	85 c0                	test   %eax,%eax
c0104b7d:	74 24                	je     c0104ba3 <basic_check+0x151>
c0104b7f:	c7 44 24 0c 7c 6f 10 	movl   $0xc0106f7c,0xc(%esp)
c0104b86:	c0 
c0104b87:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104b8e:	c0 
c0104b8f:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104b96:	00 
c0104b97:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104b9e:	e8 56 b8 ff ff       	call   c01003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ba6:	89 04 24             	mov    %eax,(%esp)
c0104ba9:	e8 7c f8 ff ff       	call   c010442a <page2pa>
c0104bae:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104bb4:	c1 e2 0c             	shl    $0xc,%edx
c0104bb7:	39 d0                	cmp    %edx,%eax
c0104bb9:	72 24                	jb     c0104bdf <basic_check+0x18d>
c0104bbb:	c7 44 24 0c b8 6f 10 	movl   $0xc0106fb8,0xc(%esp)
c0104bc2:	c0 
c0104bc3:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104bca:	c0 
c0104bcb:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0104bd2:	00 
c0104bd3:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104bda:	e8 1a b8 ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be2:	89 04 24             	mov    %eax,(%esp)
c0104be5:	e8 40 f8 ff ff       	call   c010442a <page2pa>
c0104bea:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104bf0:	c1 e2 0c             	shl    $0xc,%edx
c0104bf3:	39 d0                	cmp    %edx,%eax
c0104bf5:	72 24                	jb     c0104c1b <basic_check+0x1c9>
c0104bf7:	c7 44 24 0c d5 6f 10 	movl   $0xc0106fd5,0xc(%esp)
c0104bfe:	c0 
c0104bff:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104c06:	c0 
c0104c07:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0104c0e:	00 
c0104c0f:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104c16:	e8 de b7 ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c1e:	89 04 24             	mov    %eax,(%esp)
c0104c21:	e8 04 f8 ff ff       	call   c010442a <page2pa>
c0104c26:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104c2c:	c1 e2 0c             	shl    $0xc,%edx
c0104c2f:	39 d0                	cmp    %edx,%eax
c0104c31:	72 24                	jb     c0104c57 <basic_check+0x205>
c0104c33:	c7 44 24 0c f2 6f 10 	movl   $0xc0106ff2,0xc(%esp)
c0104c3a:	c0 
c0104c3b:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104c42:	c0 
c0104c43:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0104c4a:	00 
c0104c4b:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104c52:	e8 a2 b7 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0104c57:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c0104c5c:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c0104c62:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c65:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c68:	c7 45 dc 1c bf 11 c0 	movl   $0xc011bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104c6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c72:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c75:	89 50 04             	mov    %edx,0x4(%eax)
c0104c78:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c7b:	8b 50 04             	mov    0x4(%eax),%edx
c0104c7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c81:	89 10                	mov    %edx,(%eax)
c0104c83:	c7 45 e0 1c bf 11 c0 	movl   $0xc011bf1c,-0x20(%ebp)
    return list->next == list;
c0104c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c8d:	8b 40 04             	mov    0x4(%eax),%eax
c0104c90:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104c93:	0f 94 c0             	sete   %al
c0104c96:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104c99:	85 c0                	test   %eax,%eax
c0104c9b:	75 24                	jne    c0104cc1 <basic_check+0x26f>
c0104c9d:	c7 44 24 0c 0f 70 10 	movl   $0xc010700f,0xc(%esp)
c0104ca4:	c0 
c0104ca5:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104cac:	c0 
c0104cad:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104cb4:	00 
c0104cb5:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104cbc:	e8 38 b7 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104cc1:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104cc6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104cc9:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c0104cd0:	00 00 00 

    assert(alloc_page() == NULL);
c0104cd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cda:	e8 7a e0 ff ff       	call   c0102d59 <alloc_pages>
c0104cdf:	85 c0                	test   %eax,%eax
c0104ce1:	74 24                	je     c0104d07 <basic_check+0x2b5>
c0104ce3:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c0104cea:	c0 
c0104ceb:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104cf2:	c0 
c0104cf3:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104cfa:	00 
c0104cfb:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104d02:	e8 f2 b6 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104d07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d0e:	00 
c0104d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d12:	89 04 24             	mov    %eax,(%esp)
c0104d15:	e8 77 e0 ff ff       	call   c0102d91 <free_pages>
    free_page(p1);
c0104d1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d21:	00 
c0104d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d25:	89 04 24             	mov    %eax,(%esp)
c0104d28:	e8 64 e0 ff ff       	call   c0102d91 <free_pages>
    free_page(p2);
c0104d2d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d34:	00 
c0104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d38:	89 04 24             	mov    %eax,(%esp)
c0104d3b:	e8 51 e0 ff ff       	call   c0102d91 <free_pages>
    assert(nr_free == 3);
c0104d40:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104d45:	83 f8 03             	cmp    $0x3,%eax
c0104d48:	74 24                	je     c0104d6e <basic_check+0x31c>
c0104d4a:	c7 44 24 0c 3b 70 10 	movl   $0xc010703b,0xc(%esp)
c0104d51:	c0 
c0104d52:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104d59:	c0 
c0104d5a:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0104d61:	00 
c0104d62:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104d69:	e8 8b b6 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104d6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d75:	e8 df df ff ff       	call   c0102d59 <alloc_pages>
c0104d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d81:	75 24                	jne    c0104da7 <basic_check+0x355>
c0104d83:	c7 44 24 0c 01 6f 10 	movl   $0xc0106f01,0xc(%esp)
c0104d8a:	c0 
c0104d8b:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104d92:	c0 
c0104d93:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104d9a:	00 
c0104d9b:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104da2:	e8 52 b6 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104da7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dae:	e8 a6 df ff ff       	call   c0102d59 <alloc_pages>
c0104db3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104db6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104dba:	75 24                	jne    c0104de0 <basic_check+0x38e>
c0104dbc:	c7 44 24 0c 1d 6f 10 	movl   $0xc0106f1d,0xc(%esp)
c0104dc3:	c0 
c0104dc4:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104dcb:	c0 
c0104dcc:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0104dd3:	00 
c0104dd4:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104ddb:	e8 19 b6 ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104de0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104de7:	e8 6d df ff ff       	call   c0102d59 <alloc_pages>
c0104dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104def:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104df3:	75 24                	jne    c0104e19 <basic_check+0x3c7>
c0104df5:	c7 44 24 0c 39 6f 10 	movl   $0xc0106f39,0xc(%esp)
c0104dfc:	c0 
c0104dfd:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104e04:	c0 
c0104e05:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104e0c:	00 
c0104e0d:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104e14:	e8 e0 b5 ff ff       	call   c01003f9 <__panic>

    assert(alloc_page() == NULL);
c0104e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e20:	e8 34 df ff ff       	call   c0102d59 <alloc_pages>
c0104e25:	85 c0                	test   %eax,%eax
c0104e27:	74 24                	je     c0104e4d <basic_check+0x3fb>
c0104e29:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c0104e30:	c0 
c0104e31:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104e38:	c0 
c0104e39:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104e40:	00 
c0104e41:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104e48:	e8 ac b5 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104e4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e54:	00 
c0104e55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e58:	89 04 24             	mov    %eax,(%esp)
c0104e5b:	e8 31 df ff ff       	call   c0102d91 <free_pages>
c0104e60:	c7 45 d8 1c bf 11 c0 	movl   $0xc011bf1c,-0x28(%ebp)
c0104e67:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e6a:	8b 40 04             	mov    0x4(%eax),%eax
c0104e6d:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104e70:	0f 94 c0             	sete   %al
c0104e73:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104e76:	85 c0                	test   %eax,%eax
c0104e78:	74 24                	je     c0104e9e <basic_check+0x44c>
c0104e7a:	c7 44 24 0c 48 70 10 	movl   $0xc0107048,0xc(%esp)
c0104e81:	c0 
c0104e82:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104e89:	c0 
c0104e8a:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0104e91:	00 
c0104e92:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104e99:	e8 5b b5 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104e9e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ea5:	e8 af de ff ff       	call   c0102d59 <alloc_pages>
c0104eaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104eb0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104eb3:	74 24                	je     c0104ed9 <basic_check+0x487>
c0104eb5:	c7 44 24 0c 60 70 10 	movl   $0xc0107060,0xc(%esp)
c0104ebc:	c0 
c0104ebd:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104ec4:	c0 
c0104ec5:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0104ecc:	00 
c0104ecd:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104ed4:	e8 20 b5 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0104ed9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ee0:	e8 74 de ff ff       	call   c0102d59 <alloc_pages>
c0104ee5:	85 c0                	test   %eax,%eax
c0104ee7:	74 24                	je     c0104f0d <basic_check+0x4bb>
c0104ee9:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104ef8:	c0 
c0104ef9:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0104f00:	00 
c0104f01:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104f08:	e8 ec b4 ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c0104f0d:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104f12:	85 c0                	test   %eax,%eax
c0104f14:	74 24                	je     c0104f3a <basic_check+0x4e8>
c0104f16:	c7 44 24 0c 79 70 10 	movl   $0xc0107079,0xc(%esp)
c0104f1d:	c0 
c0104f1e:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104f25:	c0 
c0104f26:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104f2d:	00 
c0104f2e:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0104f35:	e8 bf b4 ff ff       	call   c01003f9 <__panic>
    free_list = free_list_store;
c0104f3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f3d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f40:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c0104f45:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    nr_free = nr_free_store;
c0104f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f4e:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_page(p);
c0104f53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f5a:	00 
c0104f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f5e:	89 04 24             	mov    %eax,(%esp)
c0104f61:	e8 2b de ff ff       	call   c0102d91 <free_pages>
    free_page(p1);
c0104f66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f6d:	00 
c0104f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f71:	89 04 24             	mov    %eax,(%esp)
c0104f74:	e8 18 de ff ff       	call   c0102d91 <free_pages>
    free_page(p2);
c0104f79:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f80:	00 
c0104f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f84:	89 04 24             	mov    %eax,(%esp)
c0104f87:	e8 05 de ff ff       	call   c0102d91 <free_pages>
}
c0104f8c:	90                   	nop
c0104f8d:	c9                   	leave  
c0104f8e:	c3                   	ret    

c0104f8f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104f8f:	55                   	push   %ebp
c0104f90:	89 e5                	mov    %esp,%ebp
c0104f92:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104f98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104f9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104fa6:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104fad:	eb 6a                	jmp    c0105019 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104faf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fb2:	83 e8 0c             	sub    $0xc,%eax
c0104fb5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104fb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104fbb:	83 c0 04             	add    $0x4,%eax
c0104fbe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104fc5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fc8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104fcb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104fce:	0f a3 10             	bt     %edx,(%eax)
c0104fd1:	19 c0                	sbb    %eax,%eax
c0104fd3:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104fd6:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104fda:	0f 95 c0             	setne  %al
c0104fdd:	0f b6 c0             	movzbl %al,%eax
c0104fe0:	85 c0                	test   %eax,%eax
c0104fe2:	75 24                	jne    c0105008 <default_check+0x79>
c0104fe4:	c7 44 24 0c 86 70 10 	movl   $0xc0107086,0xc(%esp)
c0104feb:	c0 
c0104fec:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0104ff3:	c0 
c0104ff4:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104ffb:	00 
c0104ffc:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0105003:	e8 f1 b3 ff ff       	call   c01003f9 <__panic>
        count ++, total += p->property;
c0105008:	ff 45 f4             	incl   -0xc(%ebp)
c010500b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010500e:	8b 50 08             	mov    0x8(%eax),%edx
c0105011:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105014:	01 d0                	add    %edx,%eax
c0105016:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105019:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010501c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c010501f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105022:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105025:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105028:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c010502f:	0f 85 7a ff ff ff    	jne    c0104faf <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0105035:	e8 8a dd ff ff       	call   c0102dc4 <nr_free_pages>
c010503a:	89 c2                	mov    %eax,%edx
c010503c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010503f:	39 c2                	cmp    %eax,%edx
c0105041:	74 24                	je     c0105067 <default_check+0xd8>
c0105043:	c7 44 24 0c 96 70 10 	movl   $0xc0107096,0xc(%esp)
c010504a:	c0 
c010504b:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0105052:	c0 
c0105053:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c010505a:	00 
c010505b:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0105062:	e8 92 b3 ff ff       	call   c01003f9 <__panic>

    basic_check();
c0105067:	e8 e6 f9 ff ff       	call   c0104a52 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010506c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105073:	e8 e1 dc ff ff       	call   c0102d59 <alloc_pages>
c0105078:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010507b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010507f:	75 24                	jne    c01050a5 <default_check+0x116>
c0105081:	c7 44 24 0c af 70 10 	movl   $0xc01070af,0xc(%esp)
c0105088:	c0 
c0105089:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0105090:	c0 
c0105091:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0105098:	00 
c0105099:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01050a0:	e8 54 b3 ff ff       	call   c01003f9 <__panic>
    assert(!PageProperty(p0));
c01050a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050a8:	83 c0 04             	add    $0x4,%eax
c01050ab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01050b2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01050b5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01050b8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01050bb:	0f a3 10             	bt     %edx,(%eax)
c01050be:	19 c0                	sbb    %eax,%eax
c01050c0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01050c3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01050c7:	0f 95 c0             	setne  %al
c01050ca:	0f b6 c0             	movzbl %al,%eax
c01050cd:	85 c0                	test   %eax,%eax
c01050cf:	74 24                	je     c01050f5 <default_check+0x166>
c01050d1:	c7 44 24 0c ba 70 10 	movl   $0xc01070ba,0xc(%esp)
c01050d8:	c0 
c01050d9:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01050e0:	c0 
c01050e1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01050e8:	00 
c01050e9:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01050f0:	e8 04 b3 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c01050f5:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c01050fa:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c0105100:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105103:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105106:	c7 45 b0 1c bf 11 c0 	movl   $0xc011bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c010510d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105110:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105113:	89 50 04             	mov    %edx,0x4(%eax)
c0105116:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105119:	8b 50 04             	mov    0x4(%eax),%edx
c010511c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010511f:	89 10                	mov    %edx,(%eax)
c0105121:	c7 45 b4 1c bf 11 c0 	movl   $0xc011bf1c,-0x4c(%ebp)
    return list->next == list;
c0105128:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010512b:	8b 40 04             	mov    0x4(%eax),%eax
c010512e:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0105131:	0f 94 c0             	sete   %al
c0105134:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105137:	85 c0                	test   %eax,%eax
c0105139:	75 24                	jne    c010515f <default_check+0x1d0>
c010513b:	c7 44 24 0c 0f 70 10 	movl   $0xc010700f,0xc(%esp)
c0105142:	c0 
c0105143:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010514a:	c0 
c010514b:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0105152:	00 
c0105153:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010515a:	e8 9a b2 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c010515f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105166:	e8 ee db ff ff       	call   c0102d59 <alloc_pages>
c010516b:	85 c0                	test   %eax,%eax
c010516d:	74 24                	je     c0105193 <default_check+0x204>
c010516f:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c0105176:	c0 
c0105177:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010517e:	c0 
c010517f:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0105186:	00 
c0105187:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010518e:	e8 66 b2 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0105193:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0105198:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010519b:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c01051a2:	00 00 00 

    free_pages(p0 + 2, 3);
c01051a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051a8:	83 c0 28             	add    $0x28,%eax
c01051ab:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01051b2:	00 
c01051b3:	89 04 24             	mov    %eax,(%esp)
c01051b6:	e8 d6 db ff ff       	call   c0102d91 <free_pages>
    assert(alloc_pages(4) == NULL);
c01051bb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01051c2:	e8 92 db ff ff       	call   c0102d59 <alloc_pages>
c01051c7:	85 c0                	test   %eax,%eax
c01051c9:	74 24                	je     c01051ef <default_check+0x260>
c01051cb:	c7 44 24 0c cc 70 10 	movl   $0xc01070cc,0xc(%esp)
c01051d2:	c0 
c01051d3:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01051da:	c0 
c01051db:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01051e2:	00 
c01051e3:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01051ea:	e8 0a b2 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01051ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051f2:	83 c0 28             	add    $0x28,%eax
c01051f5:	83 c0 04             	add    $0x4,%eax
c01051f8:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01051ff:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105202:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105205:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105208:	0f a3 10             	bt     %edx,(%eax)
c010520b:	19 c0                	sbb    %eax,%eax
c010520d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105210:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105214:	0f 95 c0             	setne  %al
c0105217:	0f b6 c0             	movzbl %al,%eax
c010521a:	85 c0                	test   %eax,%eax
c010521c:	74 0e                	je     c010522c <default_check+0x29d>
c010521e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105221:	83 c0 28             	add    $0x28,%eax
c0105224:	8b 40 08             	mov    0x8(%eax),%eax
c0105227:	83 f8 03             	cmp    $0x3,%eax
c010522a:	74 24                	je     c0105250 <default_check+0x2c1>
c010522c:	c7 44 24 0c e4 70 10 	movl   $0xc01070e4,0xc(%esp)
c0105233:	c0 
c0105234:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010523b:	c0 
c010523c:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0105243:	00 
c0105244:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010524b:	e8 a9 b1 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105250:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105257:	e8 fd da ff ff       	call   c0102d59 <alloc_pages>
c010525c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010525f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105263:	75 24                	jne    c0105289 <default_check+0x2fa>
c0105265:	c7 44 24 0c 10 71 10 	movl   $0xc0107110,0xc(%esp)
c010526c:	c0 
c010526d:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0105274:	c0 
c0105275:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010527c:	00 
c010527d:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0105284:	e8 70 b1 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105289:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105290:	e8 c4 da ff ff       	call   c0102d59 <alloc_pages>
c0105295:	85 c0                	test   %eax,%eax
c0105297:	74 24                	je     c01052bd <default_check+0x32e>
c0105299:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c01052a0:	c0 
c01052a1:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01052a8:	c0 
c01052a9:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01052b0:	00 
c01052b1:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01052b8:	e8 3c b1 ff ff       	call   c01003f9 <__panic>
    assert(p0 + 2 == p1);
c01052bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052c0:	83 c0 28             	add    $0x28,%eax
c01052c3:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01052c6:	74 24                	je     c01052ec <default_check+0x35d>
c01052c8:	c7 44 24 0c 2e 71 10 	movl   $0xc010712e,0xc(%esp)
c01052cf:	c0 
c01052d0:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01052d7:	c0 
c01052d8:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01052df:	00 
c01052e0:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01052e7:	e8 0d b1 ff ff       	call   c01003f9 <__panic>

    p2 = p0 + 1;
c01052ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052ef:	83 c0 14             	add    $0x14,%eax
c01052f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01052f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052fc:	00 
c01052fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105300:	89 04 24             	mov    %eax,(%esp)
c0105303:	e8 89 da ff ff       	call   c0102d91 <free_pages>
    free_pages(p1, 3);
c0105308:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010530f:	00 
c0105310:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105313:	89 04 24             	mov    %eax,(%esp)
c0105316:	e8 76 da ff ff       	call   c0102d91 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010531b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010531e:	83 c0 04             	add    $0x4,%eax
c0105321:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105328:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010532b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010532e:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105331:	0f a3 10             	bt     %edx,(%eax)
c0105334:	19 c0                	sbb    %eax,%eax
c0105336:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105339:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010533d:	0f 95 c0             	setne  %al
c0105340:	0f b6 c0             	movzbl %al,%eax
c0105343:	85 c0                	test   %eax,%eax
c0105345:	74 0b                	je     c0105352 <default_check+0x3c3>
c0105347:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010534a:	8b 40 08             	mov    0x8(%eax),%eax
c010534d:	83 f8 01             	cmp    $0x1,%eax
c0105350:	74 24                	je     c0105376 <default_check+0x3e7>
c0105352:	c7 44 24 0c 3c 71 10 	movl   $0xc010713c,0xc(%esp)
c0105359:	c0 
c010535a:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c0105361:	c0 
c0105362:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0105369:	00 
c010536a:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c0105371:	e8 83 b0 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105376:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105379:	83 c0 04             	add    $0x4,%eax
c010537c:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105383:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105386:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105389:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010538c:	0f a3 10             	bt     %edx,(%eax)
c010538f:	19 c0                	sbb    %eax,%eax
c0105391:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105394:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105398:	0f 95 c0             	setne  %al
c010539b:	0f b6 c0             	movzbl %al,%eax
c010539e:	85 c0                	test   %eax,%eax
c01053a0:	74 0b                	je     c01053ad <default_check+0x41e>
c01053a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053a5:	8b 40 08             	mov    0x8(%eax),%eax
c01053a8:	83 f8 03             	cmp    $0x3,%eax
c01053ab:	74 24                	je     c01053d1 <default_check+0x442>
c01053ad:	c7 44 24 0c 64 71 10 	movl   $0xc0107164,0xc(%esp)
c01053b4:	c0 
c01053b5:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01053bc:	c0 
c01053bd:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01053c4:	00 
c01053c5:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01053cc:	e8 28 b0 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01053d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01053d8:	e8 7c d9 ff ff       	call   c0102d59 <alloc_pages>
c01053dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053e3:	83 e8 14             	sub    $0x14,%eax
c01053e6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01053e9:	74 24                	je     c010540f <default_check+0x480>
c01053eb:	c7 44 24 0c 8a 71 10 	movl   $0xc010718a,0xc(%esp)
c01053f2:	c0 
c01053f3:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01053fa:	c0 
c01053fb:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0105402:	00 
c0105403:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010540a:	e8 ea af ff ff       	call   c01003f9 <__panic>
    free_page(p0);
c010540f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105416:	00 
c0105417:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010541a:	89 04 24             	mov    %eax,(%esp)
c010541d:	e8 6f d9 ff ff       	call   c0102d91 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105422:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105429:	e8 2b d9 ff ff       	call   c0102d59 <alloc_pages>
c010542e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105431:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105434:	83 c0 14             	add    $0x14,%eax
c0105437:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010543a:	74 24                	je     c0105460 <default_check+0x4d1>
c010543c:	c7 44 24 0c a8 71 10 	movl   $0xc01071a8,0xc(%esp)
c0105443:	c0 
c0105444:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010544b:	c0 
c010544c:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105453:	00 
c0105454:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010545b:	e8 99 af ff ff       	call   c01003f9 <__panic>

    free_pages(p0, 2);
c0105460:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105467:	00 
c0105468:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010546b:	89 04 24             	mov    %eax,(%esp)
c010546e:	e8 1e d9 ff ff       	call   c0102d91 <free_pages>
    free_page(p2);
c0105473:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010547a:	00 
c010547b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010547e:	89 04 24             	mov    %eax,(%esp)
c0105481:	e8 0b d9 ff ff       	call   c0102d91 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105486:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010548d:	e8 c7 d8 ff ff       	call   c0102d59 <alloc_pages>
c0105492:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105495:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105499:	75 24                	jne    c01054bf <default_check+0x530>
c010549b:	c7 44 24 0c c8 71 10 	movl   $0xc01071c8,0xc(%esp)
c01054a2:	c0 
c01054a3:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01054aa:	c0 
c01054ab:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01054b2:	00 
c01054b3:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01054ba:	e8 3a af ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c01054bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054c6:	e8 8e d8 ff ff       	call   c0102d59 <alloc_pages>
c01054cb:	85 c0                	test   %eax,%eax
c01054cd:	74 24                	je     c01054f3 <default_check+0x564>
c01054cf:	c7 44 24 0c 26 70 10 	movl   $0xc0107026,0xc(%esp)
c01054d6:	c0 
c01054d7:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01054de:	c0 
c01054df:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01054e6:	00 
c01054e7:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01054ee:	e8 06 af ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c01054f3:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c01054f8:	85 c0                	test   %eax,%eax
c01054fa:	74 24                	je     c0105520 <default_check+0x591>
c01054fc:	c7 44 24 0c 79 70 10 	movl   $0xc0107079,0xc(%esp)
c0105503:	c0 
c0105504:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010550b:	c0 
c010550c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0105513:	00 
c0105514:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c010551b:	e8 d9 ae ff ff       	call   c01003f9 <__panic>
    nr_free = nr_free_store;
c0105520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105523:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_list = free_list_store;
c0105528:	8b 45 80             	mov    -0x80(%ebp),%eax
c010552b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010552e:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c0105533:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    free_pages(p0, 5);
c0105539:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105540:	00 
c0105541:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105544:	89 04 24             	mov    %eax,(%esp)
c0105547:	e8 45 d8 ff ff       	call   c0102d91 <free_pages>

    le = &free_list;
c010554c:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105553:	eb 1c                	jmp    c0105571 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0105555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105558:	83 e8 0c             	sub    $0xc,%eax
c010555b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010555e:	ff 4d f4             	decl   -0xc(%ebp)
c0105561:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105564:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105567:	8b 40 08             	mov    0x8(%eax),%eax
c010556a:	29 c2                	sub    %eax,%edx
c010556c:	89 d0                	mov    %edx,%eax
c010556e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105571:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105574:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105577:	8b 45 88             	mov    -0x78(%ebp),%eax
c010557a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010557d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105580:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c0105587:	75 cc                	jne    c0105555 <default_check+0x5c6>
    }
    assert(count == 0);
c0105589:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010558d:	74 24                	je     c01055b3 <default_check+0x624>
c010558f:	c7 44 24 0c e6 71 10 	movl   $0xc01071e6,0xc(%esp)
c0105596:	c0 
c0105597:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c010559e:	c0 
c010559f:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c01055a6:	00 
c01055a7:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01055ae:	e8 46 ae ff ff       	call   c01003f9 <__panic>
    assert(total == 0);
c01055b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055b7:	74 24                	je     c01055dd <default_check+0x64e>
c01055b9:	c7 44 24 0c f1 71 10 	movl   $0xc01071f1,0xc(%esp)
c01055c0:	c0 
c01055c1:	c7 44 24 08 9e 6e 10 	movl   $0xc0106e9e,0x8(%esp)
c01055c8:	c0 
c01055c9:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c01055d0:	00 
c01055d1:	c7 04 24 b3 6e 10 c0 	movl   $0xc0106eb3,(%esp)
c01055d8:	e8 1c ae ff ff       	call   c01003f9 <__panic>
}
c01055dd:	90                   	nop
c01055de:	c9                   	leave  
c01055df:	c3                   	ret    

c01055e0 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01055e0:	55                   	push   %ebp
c01055e1:	89 e5                	mov    %esp,%ebp
c01055e3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01055e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01055ed:	eb 03                	jmp    c01055f2 <strlen+0x12>
        cnt ++;
c01055ef:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01055f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f5:	8d 50 01             	lea    0x1(%eax),%edx
c01055f8:	89 55 08             	mov    %edx,0x8(%ebp)
c01055fb:	0f b6 00             	movzbl (%eax),%eax
c01055fe:	84 c0                	test   %al,%al
c0105600:	75 ed                	jne    c01055ef <strlen+0xf>
    }
    return cnt;
c0105602:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105605:	c9                   	leave  
c0105606:	c3                   	ret    

c0105607 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105607:	55                   	push   %ebp
c0105608:	89 e5                	mov    %esp,%ebp
c010560a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010560d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105614:	eb 03                	jmp    c0105619 <strnlen+0x12>
        cnt ++;
c0105616:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105619:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010561c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010561f:	73 10                	jae    c0105631 <strnlen+0x2a>
c0105621:	8b 45 08             	mov    0x8(%ebp),%eax
c0105624:	8d 50 01             	lea    0x1(%eax),%edx
c0105627:	89 55 08             	mov    %edx,0x8(%ebp)
c010562a:	0f b6 00             	movzbl (%eax),%eax
c010562d:	84 c0                	test   %al,%al
c010562f:	75 e5                	jne    c0105616 <strnlen+0xf>
    }
    return cnt;
c0105631:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105634:	c9                   	leave  
c0105635:	c3                   	ret    

c0105636 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105636:	55                   	push   %ebp
c0105637:	89 e5                	mov    %esp,%ebp
c0105639:	57                   	push   %edi
c010563a:	56                   	push   %esi
c010563b:	83 ec 20             	sub    $0x20,%esp
c010563e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105641:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105644:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105647:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010564a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105650:	89 d1                	mov    %edx,%ecx
c0105652:	89 c2                	mov    %eax,%edx
c0105654:	89 ce                	mov    %ecx,%esi
c0105656:	89 d7                	mov    %edx,%edi
c0105658:	ac                   	lods   %ds:(%esi),%al
c0105659:	aa                   	stos   %al,%es:(%edi)
c010565a:	84 c0                	test   %al,%al
c010565c:	75 fa                	jne    c0105658 <strcpy+0x22>
c010565e:	89 fa                	mov    %edi,%edx
c0105660:	89 f1                	mov    %esi,%ecx
c0105662:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105665:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105668:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010566e:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010566f:	83 c4 20             	add    $0x20,%esp
c0105672:	5e                   	pop    %esi
c0105673:	5f                   	pop    %edi
c0105674:	5d                   	pop    %ebp
c0105675:	c3                   	ret    

c0105676 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105676:	55                   	push   %ebp
c0105677:	89 e5                	mov    %esp,%ebp
c0105679:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010567c:	8b 45 08             	mov    0x8(%ebp),%eax
c010567f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105682:	eb 1e                	jmp    c01056a2 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105684:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105687:	0f b6 10             	movzbl (%eax),%edx
c010568a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010568d:	88 10                	mov    %dl,(%eax)
c010568f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105692:	0f b6 00             	movzbl (%eax),%eax
c0105695:	84 c0                	test   %al,%al
c0105697:	74 03                	je     c010569c <strncpy+0x26>
            src ++;
c0105699:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010569c:	ff 45 fc             	incl   -0x4(%ebp)
c010569f:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01056a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01056a6:	75 dc                	jne    c0105684 <strncpy+0xe>
    }
    return dst;
c01056a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01056ab:	c9                   	leave  
c01056ac:	c3                   	ret    

c01056ad <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01056ad:	55                   	push   %ebp
c01056ae:	89 e5                	mov    %esp,%ebp
c01056b0:	57                   	push   %edi
c01056b1:	56                   	push   %esi
c01056b2:	83 ec 20             	sub    $0x20,%esp
c01056b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01056c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056c7:	89 d1                	mov    %edx,%ecx
c01056c9:	89 c2                	mov    %eax,%edx
c01056cb:	89 ce                	mov    %ecx,%esi
c01056cd:	89 d7                	mov    %edx,%edi
c01056cf:	ac                   	lods   %ds:(%esi),%al
c01056d0:	ae                   	scas   %es:(%edi),%al
c01056d1:	75 08                	jne    c01056db <strcmp+0x2e>
c01056d3:	84 c0                	test   %al,%al
c01056d5:	75 f8                	jne    c01056cf <strcmp+0x22>
c01056d7:	31 c0                	xor    %eax,%eax
c01056d9:	eb 04                	jmp    c01056df <strcmp+0x32>
c01056db:	19 c0                	sbb    %eax,%eax
c01056dd:	0c 01                	or     $0x1,%al
c01056df:	89 fa                	mov    %edi,%edx
c01056e1:	89 f1                	mov    %esi,%ecx
c01056e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056e6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01056e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01056ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01056ef:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01056f0:	83 c4 20             	add    $0x20,%esp
c01056f3:	5e                   	pop    %esi
c01056f4:	5f                   	pop    %edi
c01056f5:	5d                   	pop    %ebp
c01056f6:	c3                   	ret    

c01056f7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01056f7:	55                   	push   %ebp
c01056f8:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01056fa:	eb 09                	jmp    c0105705 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01056fc:	ff 4d 10             	decl   0x10(%ebp)
c01056ff:	ff 45 08             	incl   0x8(%ebp)
c0105702:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105705:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105709:	74 1a                	je     c0105725 <strncmp+0x2e>
c010570b:	8b 45 08             	mov    0x8(%ebp),%eax
c010570e:	0f b6 00             	movzbl (%eax),%eax
c0105711:	84 c0                	test   %al,%al
c0105713:	74 10                	je     c0105725 <strncmp+0x2e>
c0105715:	8b 45 08             	mov    0x8(%ebp),%eax
c0105718:	0f b6 10             	movzbl (%eax),%edx
c010571b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010571e:	0f b6 00             	movzbl (%eax),%eax
c0105721:	38 c2                	cmp    %al,%dl
c0105723:	74 d7                	je     c01056fc <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105725:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105729:	74 18                	je     c0105743 <strncmp+0x4c>
c010572b:	8b 45 08             	mov    0x8(%ebp),%eax
c010572e:	0f b6 00             	movzbl (%eax),%eax
c0105731:	0f b6 d0             	movzbl %al,%edx
c0105734:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105737:	0f b6 00             	movzbl (%eax),%eax
c010573a:	0f b6 c0             	movzbl %al,%eax
c010573d:	29 c2                	sub    %eax,%edx
c010573f:	89 d0                	mov    %edx,%eax
c0105741:	eb 05                	jmp    c0105748 <strncmp+0x51>
c0105743:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105748:	5d                   	pop    %ebp
c0105749:	c3                   	ret    

c010574a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010574a:	55                   	push   %ebp
c010574b:	89 e5                	mov    %esp,%ebp
c010574d:	83 ec 04             	sub    $0x4,%esp
c0105750:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105753:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105756:	eb 13                	jmp    c010576b <strchr+0x21>
        if (*s == c) {
c0105758:	8b 45 08             	mov    0x8(%ebp),%eax
c010575b:	0f b6 00             	movzbl (%eax),%eax
c010575e:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105761:	75 05                	jne    c0105768 <strchr+0x1e>
            return (char *)s;
c0105763:	8b 45 08             	mov    0x8(%ebp),%eax
c0105766:	eb 12                	jmp    c010577a <strchr+0x30>
        }
        s ++;
c0105768:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010576b:	8b 45 08             	mov    0x8(%ebp),%eax
c010576e:	0f b6 00             	movzbl (%eax),%eax
c0105771:	84 c0                	test   %al,%al
c0105773:	75 e3                	jne    c0105758 <strchr+0xe>
    }
    return NULL;
c0105775:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010577a:	c9                   	leave  
c010577b:	c3                   	ret    

c010577c <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010577c:	55                   	push   %ebp
c010577d:	89 e5                	mov    %esp,%ebp
c010577f:	83 ec 04             	sub    $0x4,%esp
c0105782:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105785:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105788:	eb 0e                	jmp    c0105798 <strfind+0x1c>
        if (*s == c) {
c010578a:	8b 45 08             	mov    0x8(%ebp),%eax
c010578d:	0f b6 00             	movzbl (%eax),%eax
c0105790:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105793:	74 0f                	je     c01057a4 <strfind+0x28>
            break;
        }
        s ++;
c0105795:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105798:	8b 45 08             	mov    0x8(%ebp),%eax
c010579b:	0f b6 00             	movzbl (%eax),%eax
c010579e:	84 c0                	test   %al,%al
c01057a0:	75 e8                	jne    c010578a <strfind+0xe>
c01057a2:	eb 01                	jmp    c01057a5 <strfind+0x29>
            break;
c01057a4:	90                   	nop
    }
    return (char *)s;
c01057a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01057a8:	c9                   	leave  
c01057a9:	c3                   	ret    

c01057aa <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01057aa:	55                   	push   %ebp
c01057ab:	89 e5                	mov    %esp,%ebp
c01057ad:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01057b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01057b7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01057be:	eb 03                	jmp    c01057c3 <strtol+0x19>
        s ++;
c01057c0:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01057c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c6:	0f b6 00             	movzbl (%eax),%eax
c01057c9:	3c 20                	cmp    $0x20,%al
c01057cb:	74 f3                	je     c01057c0 <strtol+0x16>
c01057cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d0:	0f b6 00             	movzbl (%eax),%eax
c01057d3:	3c 09                	cmp    $0x9,%al
c01057d5:	74 e9                	je     c01057c0 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01057d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057da:	0f b6 00             	movzbl (%eax),%eax
c01057dd:	3c 2b                	cmp    $0x2b,%al
c01057df:	75 05                	jne    c01057e6 <strtol+0x3c>
        s ++;
c01057e1:	ff 45 08             	incl   0x8(%ebp)
c01057e4:	eb 14                	jmp    c01057fa <strtol+0x50>
    }
    else if (*s == '-') {
c01057e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e9:	0f b6 00             	movzbl (%eax),%eax
c01057ec:	3c 2d                	cmp    $0x2d,%al
c01057ee:	75 0a                	jne    c01057fa <strtol+0x50>
        s ++, neg = 1;
c01057f0:	ff 45 08             	incl   0x8(%ebp)
c01057f3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01057fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057fe:	74 06                	je     c0105806 <strtol+0x5c>
c0105800:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105804:	75 22                	jne    c0105828 <strtol+0x7e>
c0105806:	8b 45 08             	mov    0x8(%ebp),%eax
c0105809:	0f b6 00             	movzbl (%eax),%eax
c010580c:	3c 30                	cmp    $0x30,%al
c010580e:	75 18                	jne    c0105828 <strtol+0x7e>
c0105810:	8b 45 08             	mov    0x8(%ebp),%eax
c0105813:	40                   	inc    %eax
c0105814:	0f b6 00             	movzbl (%eax),%eax
c0105817:	3c 78                	cmp    $0x78,%al
c0105819:	75 0d                	jne    c0105828 <strtol+0x7e>
        s += 2, base = 16;
c010581b:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010581f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105826:	eb 29                	jmp    c0105851 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105828:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010582c:	75 16                	jne    c0105844 <strtol+0x9a>
c010582e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105831:	0f b6 00             	movzbl (%eax),%eax
c0105834:	3c 30                	cmp    $0x30,%al
c0105836:	75 0c                	jne    c0105844 <strtol+0x9a>
        s ++, base = 8;
c0105838:	ff 45 08             	incl   0x8(%ebp)
c010583b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105842:	eb 0d                	jmp    c0105851 <strtol+0xa7>
    }
    else if (base == 0) {
c0105844:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105848:	75 07                	jne    c0105851 <strtol+0xa7>
        base = 10;
c010584a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105851:	8b 45 08             	mov    0x8(%ebp),%eax
c0105854:	0f b6 00             	movzbl (%eax),%eax
c0105857:	3c 2f                	cmp    $0x2f,%al
c0105859:	7e 1b                	jle    c0105876 <strtol+0xcc>
c010585b:	8b 45 08             	mov    0x8(%ebp),%eax
c010585e:	0f b6 00             	movzbl (%eax),%eax
c0105861:	3c 39                	cmp    $0x39,%al
c0105863:	7f 11                	jg     c0105876 <strtol+0xcc>
            dig = *s - '0';
c0105865:	8b 45 08             	mov    0x8(%ebp),%eax
c0105868:	0f b6 00             	movzbl (%eax),%eax
c010586b:	0f be c0             	movsbl %al,%eax
c010586e:	83 e8 30             	sub    $0x30,%eax
c0105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105874:	eb 48                	jmp    c01058be <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105876:	8b 45 08             	mov    0x8(%ebp),%eax
c0105879:	0f b6 00             	movzbl (%eax),%eax
c010587c:	3c 60                	cmp    $0x60,%al
c010587e:	7e 1b                	jle    c010589b <strtol+0xf1>
c0105880:	8b 45 08             	mov    0x8(%ebp),%eax
c0105883:	0f b6 00             	movzbl (%eax),%eax
c0105886:	3c 7a                	cmp    $0x7a,%al
c0105888:	7f 11                	jg     c010589b <strtol+0xf1>
            dig = *s - 'a' + 10;
c010588a:	8b 45 08             	mov    0x8(%ebp),%eax
c010588d:	0f b6 00             	movzbl (%eax),%eax
c0105890:	0f be c0             	movsbl %al,%eax
c0105893:	83 e8 57             	sub    $0x57,%eax
c0105896:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105899:	eb 23                	jmp    c01058be <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010589b:	8b 45 08             	mov    0x8(%ebp),%eax
c010589e:	0f b6 00             	movzbl (%eax),%eax
c01058a1:	3c 40                	cmp    $0x40,%al
c01058a3:	7e 3b                	jle    c01058e0 <strtol+0x136>
c01058a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a8:	0f b6 00             	movzbl (%eax),%eax
c01058ab:	3c 5a                	cmp    $0x5a,%al
c01058ad:	7f 31                	jg     c01058e0 <strtol+0x136>
            dig = *s - 'A' + 10;
c01058af:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b2:	0f b6 00             	movzbl (%eax),%eax
c01058b5:	0f be c0             	movsbl %al,%eax
c01058b8:	83 e8 37             	sub    $0x37,%eax
c01058bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01058be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c1:	3b 45 10             	cmp    0x10(%ebp),%eax
c01058c4:	7d 19                	jge    c01058df <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01058c6:	ff 45 08             	incl   0x8(%ebp)
c01058c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058cc:	0f af 45 10          	imul   0x10(%ebp),%eax
c01058d0:	89 c2                	mov    %eax,%edx
c01058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d5:	01 d0                	add    %edx,%eax
c01058d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01058da:	e9 72 ff ff ff       	jmp    c0105851 <strtol+0xa7>
            break;
c01058df:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01058e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01058e4:	74 08                	je     c01058ee <strtol+0x144>
        *endptr = (char *) s;
c01058e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01058ec:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01058ee:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01058f2:	74 07                	je     c01058fb <strtol+0x151>
c01058f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058f7:	f7 d8                	neg    %eax
c01058f9:	eb 03                	jmp    c01058fe <strtol+0x154>
c01058fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01058fe:	c9                   	leave  
c01058ff:	c3                   	ret    

c0105900 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105900:	55                   	push   %ebp
c0105901:	89 e5                	mov    %esp,%ebp
c0105903:	57                   	push   %edi
c0105904:	83 ec 24             	sub    $0x24,%esp
c0105907:	8b 45 0c             	mov    0xc(%ebp),%eax
c010590a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010590d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105911:	8b 55 08             	mov    0x8(%ebp),%edx
c0105914:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105917:	88 45 f7             	mov    %al,-0x9(%ebp)
c010591a:	8b 45 10             	mov    0x10(%ebp),%eax
c010591d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105920:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105923:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105927:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010592a:	89 d7                	mov    %edx,%edi
c010592c:	f3 aa                	rep stos %al,%es:(%edi)
c010592e:	89 fa                	mov    %edi,%edx
c0105930:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105933:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105936:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105939:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010593a:	83 c4 24             	add    $0x24,%esp
c010593d:	5f                   	pop    %edi
c010593e:	5d                   	pop    %ebp
c010593f:	c3                   	ret    

c0105940 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105940:	55                   	push   %ebp
c0105941:	89 e5                	mov    %esp,%ebp
c0105943:	57                   	push   %edi
c0105944:	56                   	push   %esi
c0105945:	53                   	push   %ebx
c0105946:	83 ec 30             	sub    $0x30,%esp
c0105949:	8b 45 08             	mov    0x8(%ebp),%eax
c010594c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010594f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105952:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105955:	8b 45 10             	mov    0x10(%ebp),%eax
c0105958:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010595b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010595e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105961:	73 42                	jae    c01059a5 <memmove+0x65>
c0105963:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105969:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010596c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010596f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105972:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105975:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105978:	c1 e8 02             	shr    $0x2,%eax
c010597b:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010597d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105980:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105983:	89 d7                	mov    %edx,%edi
c0105985:	89 c6                	mov    %eax,%esi
c0105987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105989:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010598c:	83 e1 03             	and    $0x3,%ecx
c010598f:	74 02                	je     c0105993 <memmove+0x53>
c0105991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105993:	89 f0                	mov    %esi,%eax
c0105995:	89 fa                	mov    %edi,%edx
c0105997:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010599a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010599d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c01059a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01059a3:	eb 36                	jmp    c01059db <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c01059a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059a8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01059ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059ae:	01 c2                	add    %eax,%edx
c01059b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059b3:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01059b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059b9:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01059bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059bf:	89 c1                	mov    %eax,%ecx
c01059c1:	89 d8                	mov    %ebx,%eax
c01059c3:	89 d6                	mov    %edx,%esi
c01059c5:	89 c7                	mov    %eax,%edi
c01059c7:	fd                   	std    
c01059c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01059ca:	fc                   	cld    
c01059cb:	89 f8                	mov    %edi,%eax
c01059cd:	89 f2                	mov    %esi,%edx
c01059cf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01059d2:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01059d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01059db:	83 c4 30             	add    $0x30,%esp
c01059de:	5b                   	pop    %ebx
c01059df:	5e                   	pop    %esi
c01059e0:	5f                   	pop    %edi
c01059e1:	5d                   	pop    %ebp
c01059e2:	c3                   	ret    

c01059e3 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01059e3:	55                   	push   %ebp
c01059e4:	89 e5                	mov    %esp,%ebp
c01059e6:	57                   	push   %edi
c01059e7:	56                   	push   %esi
c01059e8:	83 ec 20             	sub    $0x20,%esp
c01059eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01059fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01059fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a00:	c1 e8 02             	shr    $0x2,%eax
c0105a03:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105a05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a0b:	89 d7                	mov    %edx,%edi
c0105a0d:	89 c6                	mov    %eax,%esi
c0105a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105a11:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105a14:	83 e1 03             	and    $0x3,%ecx
c0105a17:	74 02                	je     c0105a1b <memcpy+0x38>
c0105a19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105a1b:	89 f0                	mov    %esi,%eax
c0105a1d:	89 fa                	mov    %edi,%edx
c0105a1f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105a22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105a25:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105a2b:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105a2c:	83 c4 20             	add    $0x20,%esp
c0105a2f:	5e                   	pop    %esi
c0105a30:	5f                   	pop    %edi
c0105a31:	5d                   	pop    %ebp
c0105a32:	c3                   	ret    

c0105a33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105a33:	55                   	push   %ebp
c0105a34:	89 e5                	mov    %esp,%ebp
c0105a36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105a39:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105a45:	eb 2e                	jmp    c0105a75 <memcmp+0x42>
        if (*s1 != *s2) {
c0105a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a4a:	0f b6 10             	movzbl (%eax),%edx
c0105a4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a50:	0f b6 00             	movzbl (%eax),%eax
c0105a53:	38 c2                	cmp    %al,%dl
c0105a55:	74 18                	je     c0105a6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a5a:	0f b6 00             	movzbl (%eax),%eax
c0105a5d:	0f b6 d0             	movzbl %al,%edx
c0105a60:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a63:	0f b6 00             	movzbl (%eax),%eax
c0105a66:	0f b6 c0             	movzbl %al,%eax
c0105a69:	29 c2                	sub    %eax,%edx
c0105a6b:	89 d0                	mov    %edx,%eax
c0105a6d:	eb 18                	jmp    c0105a87 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105a6f:	ff 45 fc             	incl   -0x4(%ebp)
c0105a72:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105a75:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a78:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a7b:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a7e:	85 c0                	test   %eax,%eax
c0105a80:	75 c5                	jne    c0105a47 <memcmp+0x14>
    }
    return 0;
c0105a82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a87:	c9                   	leave  
c0105a88:	c3                   	ret    

c0105a89 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105a89:	55                   	push   %ebp
c0105a8a:	89 e5                	mov    %esp,%ebp
c0105a8c:	83 ec 58             	sub    $0x58,%esp
c0105a8f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a92:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105a95:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105a9b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105a9e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105aa1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105aa4:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105aa7:	8b 45 18             	mov    0x18(%ebp),%eax
c0105aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105aad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ab0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105ab3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ab6:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105abf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105ac3:	74 1c                	je     c0105ae1 <printnum+0x58>
c0105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ac8:	ba 00 00 00 00       	mov    $0x0,%edx
c0105acd:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ad0:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ad6:	ba 00 00 00 00       	mov    $0x0,%edx
c0105adb:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ae7:	f7 75 e4             	divl   -0x1c(%ebp)
c0105aea:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105aed:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105af6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105af9:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105afc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105aff:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105b02:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b05:	ba 00 00 00 00       	mov    $0x0,%edx
c0105b0a:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105b0d:	72 56                	jb     c0105b65 <printnum+0xdc>
c0105b0f:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105b12:	77 05                	ja     c0105b19 <printnum+0x90>
c0105b14:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105b17:	72 4c                	jb     c0105b65 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105b19:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105b1c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105b1f:	8b 45 20             	mov    0x20(%ebp),%eax
c0105b22:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105b26:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105b2a:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b2d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105b31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b34:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b37:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b49:	89 04 24             	mov    %eax,(%esp)
c0105b4c:	e8 38 ff ff ff       	call   c0105a89 <printnum>
c0105b51:	eb 1b                	jmp    c0105b6e <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105b53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b5a:	8b 45 20             	mov    0x20(%ebp),%eax
c0105b5d:	89 04 24             	mov    %eax,(%esp)
c0105b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b63:	ff d0                	call   *%eax
        while (-- width > 0)
c0105b65:	ff 4d 1c             	decl   0x1c(%ebp)
c0105b68:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105b6c:	7f e5                	jg     c0105b53 <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105b6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105b71:	05 ac 72 10 c0       	add    $0xc01072ac,%eax
c0105b76:	0f b6 00             	movzbl (%eax),%eax
c0105b79:	0f be c0             	movsbl %al,%eax
c0105b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b7f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b83:	89 04 24             	mov    %eax,(%esp)
c0105b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b89:	ff d0                	call   *%eax
}
c0105b8b:	90                   	nop
c0105b8c:	c9                   	leave  
c0105b8d:	c3                   	ret    

c0105b8e <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105b8e:	55                   	push   %ebp
c0105b8f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105b91:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105b95:	7e 14                	jle    c0105bab <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9a:	8b 00                	mov    (%eax),%eax
c0105b9c:	8d 48 08             	lea    0x8(%eax),%ecx
c0105b9f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ba2:	89 0a                	mov    %ecx,(%edx)
c0105ba4:	8b 50 04             	mov    0x4(%eax),%edx
c0105ba7:	8b 00                	mov    (%eax),%eax
c0105ba9:	eb 30                	jmp    c0105bdb <getuint+0x4d>
    }
    else if (lflag) {
c0105bab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105baf:	74 16                	je     c0105bc7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105bb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb4:	8b 00                	mov    (%eax),%eax
c0105bb6:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bb9:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bbc:	89 0a                	mov    %ecx,(%edx)
c0105bbe:	8b 00                	mov    (%eax),%eax
c0105bc0:	ba 00 00 00 00       	mov    $0x0,%edx
c0105bc5:	eb 14                	jmp    c0105bdb <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bca:	8b 00                	mov    (%eax),%eax
c0105bcc:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bcf:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bd2:	89 0a                	mov    %ecx,(%edx)
c0105bd4:	8b 00                	mov    (%eax),%eax
c0105bd6:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105bdb:	5d                   	pop    %ebp
c0105bdc:	c3                   	ret    

c0105bdd <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105bdd:	55                   	push   %ebp
c0105bde:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105be0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105be4:	7e 14                	jle    c0105bfa <getint+0x1d>
        return va_arg(*ap, long long);
c0105be6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be9:	8b 00                	mov    (%eax),%eax
c0105beb:	8d 48 08             	lea    0x8(%eax),%ecx
c0105bee:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bf1:	89 0a                	mov    %ecx,(%edx)
c0105bf3:	8b 50 04             	mov    0x4(%eax),%edx
c0105bf6:	8b 00                	mov    (%eax),%eax
c0105bf8:	eb 28                	jmp    c0105c22 <getint+0x45>
    }
    else if (lflag) {
c0105bfa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bfe:	74 12                	je     c0105c12 <getint+0x35>
        return va_arg(*ap, long);
c0105c00:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c03:	8b 00                	mov    (%eax),%eax
c0105c05:	8d 48 04             	lea    0x4(%eax),%ecx
c0105c08:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c0b:	89 0a                	mov    %ecx,(%edx)
c0105c0d:	8b 00                	mov    (%eax),%eax
c0105c0f:	99                   	cltd   
c0105c10:	eb 10                	jmp    c0105c22 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105c12:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c15:	8b 00                	mov    (%eax),%eax
c0105c17:	8d 48 04             	lea    0x4(%eax),%ecx
c0105c1a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c1d:	89 0a                	mov    %ecx,(%edx)
c0105c1f:	8b 00                	mov    (%eax),%eax
c0105c21:	99                   	cltd   
    }
}
c0105c22:	5d                   	pop    %ebp
c0105c23:	c3                   	ret    

c0105c24 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105c24:	55                   	push   %ebp
c0105c25:	89 e5                	mov    %esp,%ebp
c0105c27:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105c2a:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c37:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c48:	89 04 24             	mov    %eax,(%esp)
c0105c4b:	e8 03 00 00 00       	call   c0105c53 <vprintfmt>
    va_end(ap);
}
c0105c50:	90                   	nop
c0105c51:	c9                   	leave  
c0105c52:	c3                   	ret    

c0105c53 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105c53:	55                   	push   %ebp
c0105c54:	89 e5                	mov    %esp,%ebp
c0105c56:	56                   	push   %esi
c0105c57:	53                   	push   %ebx
c0105c58:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c5b:	eb 17                	jmp    c0105c74 <vprintfmt+0x21>
            if (ch == '\0') {
c0105c5d:	85 db                	test   %ebx,%ebx
c0105c5f:	0f 84 bf 03 00 00    	je     c0106024 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105c65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c6c:	89 1c 24             	mov    %ebx,(%esp)
c0105c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c72:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c74:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c77:	8d 50 01             	lea    0x1(%eax),%edx
c0105c7a:	89 55 10             	mov    %edx,0x10(%ebp)
c0105c7d:	0f b6 00             	movzbl (%eax),%eax
c0105c80:	0f b6 d8             	movzbl %al,%ebx
c0105c83:	83 fb 25             	cmp    $0x25,%ebx
c0105c86:	75 d5                	jne    c0105c5d <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105c88:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105c8c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c96:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105c99:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105ca0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ca3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105ca6:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ca9:	8d 50 01             	lea    0x1(%eax),%edx
c0105cac:	89 55 10             	mov    %edx,0x10(%ebp)
c0105caf:	0f b6 00             	movzbl (%eax),%eax
c0105cb2:	0f b6 d8             	movzbl %al,%ebx
c0105cb5:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105cb8:	83 f8 55             	cmp    $0x55,%eax
c0105cbb:	0f 87 37 03 00 00    	ja     c0105ff8 <vprintfmt+0x3a5>
c0105cc1:	8b 04 85 d0 72 10 c0 	mov    -0x3fef8d30(,%eax,4),%eax
c0105cc8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105cca:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105cce:	eb d6                	jmp    c0105ca6 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105cd0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105cd4:	eb d0                	jmp    c0105ca6 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105cd6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105cdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ce0:	89 d0                	mov    %edx,%eax
c0105ce2:	c1 e0 02             	shl    $0x2,%eax
c0105ce5:	01 d0                	add    %edx,%eax
c0105ce7:	01 c0                	add    %eax,%eax
c0105ce9:	01 d8                	add    %ebx,%eax
c0105ceb:	83 e8 30             	sub    $0x30,%eax
c0105cee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105cf1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cf4:	0f b6 00             	movzbl (%eax),%eax
c0105cf7:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105cfa:	83 fb 2f             	cmp    $0x2f,%ebx
c0105cfd:	7e 38                	jle    c0105d37 <vprintfmt+0xe4>
c0105cff:	83 fb 39             	cmp    $0x39,%ebx
c0105d02:	7f 33                	jg     c0105d37 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105d04:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105d07:	eb d4                	jmp    c0105cdd <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105d09:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d0c:	8d 50 04             	lea    0x4(%eax),%edx
c0105d0f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d12:	8b 00                	mov    (%eax),%eax
c0105d14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105d17:	eb 1f                	jmp    c0105d38 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105d19:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d1d:	79 87                	jns    c0105ca6 <vprintfmt+0x53>
                width = 0;
c0105d1f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105d26:	e9 7b ff ff ff       	jmp    c0105ca6 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105d2b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105d32:	e9 6f ff ff ff       	jmp    c0105ca6 <vprintfmt+0x53>
            goto process_precision;
c0105d37:	90                   	nop

        process_precision:
            if (width < 0)
c0105d38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d3c:	0f 89 64 ff ff ff    	jns    c0105ca6 <vprintfmt+0x53>
                width = precision, precision = -1;
c0105d42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d45:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d48:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105d4f:	e9 52 ff ff ff       	jmp    c0105ca6 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105d54:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105d57:	e9 4a ff ff ff       	jmp    c0105ca6 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105d5c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d5f:	8d 50 04             	lea    0x4(%eax),%edx
c0105d62:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d65:	8b 00                	mov    (%eax),%eax
c0105d67:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d6e:	89 04 24             	mov    %eax,(%esp)
c0105d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d74:	ff d0                	call   *%eax
            break;
c0105d76:	e9 a4 02 00 00       	jmp    c010601f <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105d7b:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d7e:	8d 50 04             	lea    0x4(%eax),%edx
c0105d81:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d84:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105d86:	85 db                	test   %ebx,%ebx
c0105d88:	79 02                	jns    c0105d8c <vprintfmt+0x139>
                err = -err;
c0105d8a:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105d8c:	83 fb 06             	cmp    $0x6,%ebx
c0105d8f:	7f 0b                	jg     c0105d9c <vprintfmt+0x149>
c0105d91:	8b 34 9d 90 72 10 c0 	mov    -0x3fef8d70(,%ebx,4),%esi
c0105d98:	85 f6                	test   %esi,%esi
c0105d9a:	75 23                	jne    c0105dbf <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105d9c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105da0:	c7 44 24 08 bd 72 10 	movl   $0xc01072bd,0x8(%esp)
c0105da7:	c0 
c0105da8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db2:	89 04 24             	mov    %eax,(%esp)
c0105db5:	e8 6a fe ff ff       	call   c0105c24 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105dba:	e9 60 02 00 00       	jmp    c010601f <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105dbf:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105dc3:	c7 44 24 08 c6 72 10 	movl   $0xc01072c6,0x8(%esp)
c0105dca:	c0 
c0105dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd5:	89 04 24             	mov    %eax,(%esp)
c0105dd8:	e8 47 fe ff ff       	call   c0105c24 <printfmt>
            break;
c0105ddd:	e9 3d 02 00 00       	jmp    c010601f <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105de2:	8b 45 14             	mov    0x14(%ebp),%eax
c0105de5:	8d 50 04             	lea    0x4(%eax),%edx
c0105de8:	89 55 14             	mov    %edx,0x14(%ebp)
c0105deb:	8b 30                	mov    (%eax),%esi
c0105ded:	85 f6                	test   %esi,%esi
c0105def:	75 05                	jne    c0105df6 <vprintfmt+0x1a3>
                p = "(null)";
c0105df1:	be c9 72 10 c0       	mov    $0xc01072c9,%esi
            }
            if (width > 0 && padc != '-') {
c0105df6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105dfa:	7e 76                	jle    c0105e72 <vprintfmt+0x21f>
c0105dfc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105e00:	74 70                	je     c0105e72 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e09:	89 34 24             	mov    %esi,(%esp)
c0105e0c:	e8 f6 f7 ff ff       	call   c0105607 <strnlen>
c0105e11:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e14:	29 c2                	sub    %eax,%edx
c0105e16:	89 d0                	mov    %edx,%eax
c0105e18:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e1b:	eb 16                	jmp    c0105e33 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105e1d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105e21:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e24:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e28:	89 04 24             	mov    %eax,(%esp)
c0105e2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e2e:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105e30:	ff 4d e8             	decl   -0x18(%ebp)
c0105e33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e37:	7f e4                	jg     c0105e1d <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e39:	eb 37                	jmp    c0105e72 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105e3b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e3f:	74 1f                	je     c0105e60 <vprintfmt+0x20d>
c0105e41:	83 fb 1f             	cmp    $0x1f,%ebx
c0105e44:	7e 05                	jle    c0105e4b <vprintfmt+0x1f8>
c0105e46:	83 fb 7e             	cmp    $0x7e,%ebx
c0105e49:	7e 15                	jle    c0105e60 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e52:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105e59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e5c:	ff d0                	call   *%eax
c0105e5e:	eb 0f                	jmp    c0105e6f <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105e60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e67:	89 1c 24             	mov    %ebx,(%esp)
c0105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6d:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e6f:	ff 4d e8             	decl   -0x18(%ebp)
c0105e72:	89 f0                	mov    %esi,%eax
c0105e74:	8d 70 01             	lea    0x1(%eax),%esi
c0105e77:	0f b6 00             	movzbl (%eax),%eax
c0105e7a:	0f be d8             	movsbl %al,%ebx
c0105e7d:	85 db                	test   %ebx,%ebx
c0105e7f:	74 27                	je     c0105ea8 <vprintfmt+0x255>
c0105e81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e85:	78 b4                	js     c0105e3b <vprintfmt+0x1e8>
c0105e87:	ff 4d e4             	decl   -0x1c(%ebp)
c0105e8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e8e:	79 ab                	jns    c0105e3b <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105e90:	eb 16                	jmp    c0105ea8 <vprintfmt+0x255>
                putch(' ', putdat);
c0105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e99:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ea3:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105ea5:	ff 4d e8             	decl   -0x18(%ebp)
c0105ea8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105eac:	7f e4                	jg     c0105e92 <vprintfmt+0x23f>
            }
            break;
c0105eae:	e9 6c 01 00 00       	jmp    c010601f <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eba:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ebd:	89 04 24             	mov    %eax,(%esp)
c0105ec0:	e8 18 fd ff ff       	call   c0105bdd <getint>
c0105ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ec8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ece:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ed1:	85 d2                	test   %edx,%edx
c0105ed3:	79 26                	jns    c0105efb <vprintfmt+0x2a8>
                putch('-', putdat);
c0105ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105edc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105ee3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee6:	ff d0                	call   *%eax
                num = -(long long)num;
c0105ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105eee:	f7 d8                	neg    %eax
c0105ef0:	83 d2 00             	adc    $0x0,%edx
c0105ef3:	f7 da                	neg    %edx
c0105ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ef8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105efb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105f02:	e9 a8 00 00 00       	jmp    c0105faf <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105f07:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f0e:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f11:	89 04 24             	mov    %eax,(%esp)
c0105f14:	e8 75 fc ff ff       	call   c0105b8e <getuint>
c0105f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105f1f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105f26:	e9 84 00 00 00       	jmp    c0105faf <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f32:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f35:	89 04 24             	mov    %eax,(%esp)
c0105f38:	e8 51 fc ff ff       	call   c0105b8e <getuint>
c0105f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f40:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105f43:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105f4a:	eb 63                	jmp    c0105faf <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f53:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105f5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f5d:	ff d0                	call   *%eax
            putch('x', putdat);
c0105f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f66:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105f6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f70:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105f72:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f75:	8d 50 04             	lea    0x4(%eax),%edx
c0105f78:	89 55 14             	mov    %edx,0x14(%ebp)
c0105f7b:	8b 00                	mov    (%eax),%eax
c0105f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105f87:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105f8e:	eb 1f                	jmp    c0105faf <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f97:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f9a:	89 04 24             	mov    %eax,(%esp)
c0105f9d:	e8 ec fb ff ff       	call   c0105b8e <getuint>
c0105fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fa5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105fa8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105faf:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105fb6:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105fba:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105fbd:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105fc1:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fcb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fcf:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fdd:	89 04 24             	mov    %eax,(%esp)
c0105fe0:	e8 a4 fa ff ff       	call   c0105a89 <printnum>
            break;
c0105fe5:	eb 38                	jmp    c010601f <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fee:	89 1c 24             	mov    %ebx,(%esp)
c0105ff1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff4:	ff d0                	call   *%eax
            break;
c0105ff6:	eb 27                	jmp    c010601f <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106006:	8b 45 08             	mov    0x8(%ebp),%eax
c0106009:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010600b:	ff 4d 10             	decl   0x10(%ebp)
c010600e:	eb 03                	jmp    c0106013 <vprintfmt+0x3c0>
c0106010:	ff 4d 10             	decl   0x10(%ebp)
c0106013:	8b 45 10             	mov    0x10(%ebp),%eax
c0106016:	48                   	dec    %eax
c0106017:	0f b6 00             	movzbl (%eax),%eax
c010601a:	3c 25                	cmp    $0x25,%al
c010601c:	75 f2                	jne    c0106010 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c010601e:	90                   	nop
    while (1) {
c010601f:	e9 37 fc ff ff       	jmp    c0105c5b <vprintfmt+0x8>
                return;
c0106024:	90                   	nop
        }
    }
}
c0106025:	83 c4 40             	add    $0x40,%esp
c0106028:	5b                   	pop    %ebx
c0106029:	5e                   	pop    %esi
c010602a:	5d                   	pop    %ebp
c010602b:	c3                   	ret    

c010602c <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010602c:	55                   	push   %ebp
c010602d:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010602f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106032:	8b 40 08             	mov    0x8(%eax),%eax
c0106035:	8d 50 01             	lea    0x1(%eax),%edx
c0106038:	8b 45 0c             	mov    0xc(%ebp),%eax
c010603b:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010603e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106041:	8b 10                	mov    (%eax),%edx
c0106043:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106046:	8b 40 04             	mov    0x4(%eax),%eax
c0106049:	39 c2                	cmp    %eax,%edx
c010604b:	73 12                	jae    c010605f <sprintputch+0x33>
        *b->buf ++ = ch;
c010604d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106050:	8b 00                	mov    (%eax),%eax
c0106052:	8d 48 01             	lea    0x1(%eax),%ecx
c0106055:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106058:	89 0a                	mov    %ecx,(%edx)
c010605a:	8b 55 08             	mov    0x8(%ebp),%edx
c010605d:	88 10                	mov    %dl,(%eax)
    }
}
c010605f:	90                   	nop
c0106060:	5d                   	pop    %ebp
c0106061:	c3                   	ret    

c0106062 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106062:	55                   	push   %ebp
c0106063:	89 e5                	mov    %esp,%ebp
c0106065:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106068:	8d 45 14             	lea    0x14(%ebp),%eax
c010606b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010606e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106071:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106075:	8b 45 10             	mov    0x10(%ebp),%eax
c0106078:	89 44 24 08          	mov    %eax,0x8(%esp)
c010607c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010607f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106083:	8b 45 08             	mov    0x8(%ebp),%eax
c0106086:	89 04 24             	mov    %eax,(%esp)
c0106089:	e8 08 00 00 00       	call   c0106096 <vsnprintf>
c010608e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106091:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106094:	c9                   	leave  
c0106095:	c3                   	ret    

c0106096 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106096:	55                   	push   %ebp
c0106097:	89 e5                	mov    %esp,%ebp
c0106099:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010609c:	8b 45 08             	mov    0x8(%ebp),%eax
c010609f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01060a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060a5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01060a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01060ab:	01 d0                	add    %edx,%eax
c01060ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01060b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01060bb:	74 0a                	je     c01060c7 <vsnprintf+0x31>
c01060bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060c3:	39 c2                	cmp    %eax,%edx
c01060c5:	76 07                	jbe    c01060ce <vsnprintf+0x38>
        return -E_INVAL;
c01060c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01060cc:	eb 2a                	jmp    c01060f8 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01060ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01060d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01060d8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01060df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060e3:	c7 04 24 2c 60 10 c0 	movl   $0xc010602c,(%esp)
c01060ea:	e8 64 fb ff ff       	call   c0105c53 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01060ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060f2:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01060f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060f8:	c9                   	leave  
c01060f9:	c3                   	ret    
