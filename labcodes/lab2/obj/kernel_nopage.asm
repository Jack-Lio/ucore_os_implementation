
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
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
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
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
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 88 56 00 00       	call   1056ea <memset>

    cons_init();                // init the console
  100062:	e8 a3 15 00 00       	call   10160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 5f 10 00 	movl   $0x105f00,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 5f 10 00 	movl   $0x105f1c,(%esp)
  10007c:	e8 21 02 00 00       	call   1002a2 <cprintf>

    print_kerninfo();
  100081:	e8 c2 08 00 00       	call   100948 <print_kerninfo>

    grade_backtrace();
  100086:	e8 8e 00 00 00       	call   100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 68 32 00 00       	call   1032f8 <pmm_init>

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
  10015a:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 21 5f 10 00 	movl   $0x105f21,(%esp)
  10016e:	e8 2f 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 2f 5f 10 00 	movl   $0x105f2f,(%esp)
  10018d:	e8 10 01 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 a0 11 00       	mov    0x11a000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 3d 5f 10 00 	movl   $0x105f3d,(%esp)
  1001ac:	e8 f1 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 4b 5f 10 00 	movl   $0x105f4b,(%esp)
  1001cb:	e8 d2 00 00 00       	call   1002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 59 5f 10 00 	movl   $0x105f59,(%esp)
  1001ea:	e8 b3 00 00 00       	call   1002a2 <cprintf>
    round ++;
  1001ef:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
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
  10021f:	c7 04 24 68 5f 10 00 	movl   $0x105f68,(%esp)
  100226:	e8 77 00 00 00       	call   1002a2 <cprintf>
    lab1_switch_to_user();
  10022b:	e8 cd ff ff ff       	call   1001fd <lab1_switch_to_user>
    lab1_print_cur_status();
  100230:	e8 0a ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100235:	c7 04 24 88 5f 10 00 	movl   $0x105f88,(%esp)
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
  100298:	e8 a0 57 00 00       	call   105a3d <vprintfmt>
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
  100357:	c7 04 24 a7 5f 10 00 	movl   $0x105fa7,(%esp)
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
  1003a5:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
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
  1003e3:	05 20 a0 11 00       	add    $0x11a020,%eax
  1003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003eb:	b8 20 a0 11 00       	mov    $0x11a020,%eax
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
  1003ff:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100404:	85 c0                	test   %eax,%eax
  100406:	75 5b                	jne    100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100408:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
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
  100426:	c7 04 24 aa 5f 10 00 	movl   $0x105faa,(%esp)
  10042d:	e8 70 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100435:	89 44 24 04          	mov    %eax,0x4(%esp)
  100439:	8b 45 10             	mov    0x10(%ebp),%eax
  10043c:	89 04 24             	mov    %eax,(%esp)
  10043f:	e8 2b fe ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  100444:	c7 04 24 c6 5f 10 00 	movl   $0x105fc6,(%esp)
  10044b:	e8 52 fe ff ff       	call   1002a2 <cprintf>
    
    cprintf("stack trackback:\n");
  100450:	c7 04 24 c8 5f 10 00 	movl   $0x105fc8,(%esp)
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
  100491:	c7 04 24 da 5f 10 00 	movl   $0x105fda,(%esp)
  100498:	e8 05 fe ff ff       	call   1002a2 <cprintf>
    vcprintf(fmt, ap);
  10049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a7:	89 04 24             	mov    %eax,(%esp)
  1004aa:	e8 c0 fd ff ff       	call   10026f <vcprintf>
    cprintf("\n");
  1004af:	c7 04 24 c6 5f 10 00 	movl   $0x105fc6,(%esp)
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
  1004c1:	a1 20 a4 11 00       	mov    0x11a420,%eax
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
  10061f:	c7 00 f8 5f 10 00    	movl   $0x105ff8,(%eax)
    info->eip_line = 0;
  100625:	8b 45 0c             	mov    0xc(%ebp),%eax
  100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	c7 40 08 f8 5f 10 00 	movl   $0x105ff8,0x8(%eax)
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
  100656:	c7 45 f4 08 72 10 00 	movl   $0x107208,-0xc(%ebp)
    stab_end = __STAB_END__;
  10065d:	c7 45 f0 e4 22 11 00 	movl   $0x1122e4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100664:	c7 45 ec e5 22 11 00 	movl   $0x1122e5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10066b:	c7 45 e8 fc 4d 11 00 	movl   $0x114dfc,-0x18(%ebp)

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
  1007c6:	e8 9b 4d 00 00       	call   105566 <strfind>
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
  10094e:	c7 04 24 02 60 10 00 	movl   $0x106002,(%esp)
  100955:	e8 48 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10095a:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100961:	00 
  100962:	c7 04 24 1b 60 10 00 	movl   $0x10601b,(%esp)
  100969:	e8 34 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10096e:	c7 44 24 04 e4 5e 10 	movl   $0x105ee4,0x4(%esp)
  100975:	00 
  100976:	c7 04 24 33 60 10 00 	movl   $0x106033,(%esp)
  10097d:	e8 20 f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100982:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  100989:	00 
  10098a:	c7 04 24 4b 60 10 00 	movl   $0x10604b,(%esp)
  100991:	e8 0c f9 ff ff       	call   1002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100996:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  10099d:	00 
  10099e:	c7 04 24 63 60 10 00 	movl   $0x106063,(%esp)
  1009a5:	e8 f8 f8 ff ff       	call   1002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009aa:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b5:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009ba:	29 c2                	sub    %eax,%edx
  1009bc:	89 d0                	mov    %edx,%eax
  1009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	0f 48 c2             	cmovs  %edx,%eax
  1009c9:	c1 f8 0a             	sar    $0xa,%eax
  1009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d0:	c7 04 24 7c 60 10 00 	movl   $0x10607c,(%esp)
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
  100a05:	c7 04 24 a6 60 10 00 	movl   $0x1060a6,(%esp)
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
  100a73:	c7 04 24 c2 60 10 00 	movl   $0x1060c2,(%esp)
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
  100ad0:	c7 04 24 d4 60 10 00 	movl   $0x1060d4,(%esp)
  100ad7:	e8 c6 f7 ff ff       	call   1002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	83 c0 08             	add    $0x8,%eax
  100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
  100ae5:	c7 04 24 f2 60 10 00 	movl   $0x1060f2,(%esp)
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
  100b0f:	c7 04 24 f9 60 10 00 	movl   $0x1060f9,(%esp)
  100b16:	e8 87 f7 ff ff       	call   1002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
  100b1b:	ff 45 e8             	incl   -0x18(%ebp)
  100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b22:	7e d6                	jle    100afa <print_stackframe+0x67>
        }
        cprintf("\n");
  100b24:	c7 04 24 01 61 10 00 	movl   $0x106101,(%esp)
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
  100b94:	c7 04 24 84 61 10 00 	movl   $0x106184,(%esp)
  100b9b:	e8 94 49 00 00       	call   105534 <strchr>
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
  100bbc:	c7 04 24 89 61 10 00 	movl   $0x106189,(%esp)
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
  100bfe:	c7 04 24 84 61 10 00 	movl   $0x106184,(%esp)
  100c05:	e8 2a 49 00 00       	call   105534 <strchr>
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
  100c5d:	05 00 70 11 00       	add    $0x117000,%eax
  100c62:	8b 00                	mov    (%eax),%eax
  100c64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c68:	89 04 24             	mov    %eax,(%esp)
  100c6b:	e8 27 48 00 00       	call   105497 <strcmp>
  100c70:	85 c0                	test   %eax,%eax
  100c72:	75 31                	jne    100ca5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c77:	89 d0                	mov    %edx,%eax
  100c79:	01 c0                	add    %eax,%eax
  100c7b:	01 d0                	add    %edx,%eax
  100c7d:	c1 e0 02             	shl    $0x2,%eax
  100c80:	05 08 70 11 00       	add    $0x117008,%eax
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
  100cb7:	c7 04 24 a7 61 10 00 	movl   $0x1061a7,(%esp)
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
  100cd4:	c7 04 24 c0 61 10 00 	movl   $0x1061c0,(%esp)
  100cdb:	e8 c2 f5 ff ff       	call   1002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ce0:	c7 04 24 e8 61 10 00 	movl   $0x1061e8,(%esp)
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
  100cfd:	c7 04 24 0d 62 10 00 	movl   $0x10620d,(%esp)
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
  100d49:	05 04 70 11 00       	add    $0x117004,%eax
  100d4e:	8b 08                	mov    (%eax),%ecx
  100d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d53:	89 d0                	mov    %edx,%eax
  100d55:	01 c0                	add    %eax,%eax
  100d57:	01 d0                	add    %edx,%eax
  100d59:	c1 e0 02             	shl    $0x2,%eax
  100d5c:	05 00 70 11 00       	add    $0x117000,%eax
  100d61:	8b 00                	mov    (%eax),%eax
  100d63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d6b:	c7 04 24 11 62 10 00 	movl   $0x106211,(%esp)
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
  100dec:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100df3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df6:	c7 04 24 1a 62 10 00 	movl   $0x10621a,(%esp)
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
__intr_save(void) {
  100e11:	55                   	push   %ebp
  100e12:	89 e5                	mov    %esp,%ebp
  100e14:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e17:	9c                   	pushf  
  100e18:	58                   	pop    %eax
  100e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e1f:	25 00 02 00 00       	and    $0x200,%eax
  100e24:	85 c0                	test   %eax,%eax
  100e26:	74 0c                	je     100e34 <__intr_save+0x23>
        intr_disable();
  100e28:	e8 83 0a 00 00       	call   1018b0 <intr_disable>
        return 1;
  100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
  100e32:	eb 05                	jmp    100e39 <__intr_save+0x28>
    }
    return 0;
  100e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e39:	c9                   	leave  
  100e3a:	c3                   	ret    

00100e3b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
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
  100ece:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ed5:	b4 03 
  100ed7:	eb 13                	jmp    100eec <cga_init+0x54>
    } else {
        *cp = was;
  100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee3:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100eea:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);
  100eec:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ef7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100efb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f03:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100f04:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
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
  100f2a:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f41:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f42:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
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
  100f68:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f70:	0f b7 c0             	movzwl %ax,%eax
  100f73:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
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
  101023:	a3 48 a4 11 00       	mov    %eax,0x11a448
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
  101048:	a1 48 a4 11 00       	mov    0x11a448,%eax
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
  10114c:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101153:	85 c0                	test   %eax,%eax
  101155:	0f 84 af 00 00 00    	je     10120a <cga_putc+0xf1>
            crt_pos --;
  10115b:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101162:	48                   	dec    %eax
  101163:	0f b7 c0             	movzwl %ax,%eax
  101166:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10116c:	8b 45 08             	mov    0x8(%ebp),%eax
  10116f:	98                   	cwtl   
  101170:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101175:	98                   	cwtl   
  101176:	83 c8 20             	or     $0x20,%eax
  101179:	98                   	cwtl   
  10117a:	8b 15 40 a4 11 00    	mov    0x11a440,%edx
  101180:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101187:	01 c9                	add    %ecx,%ecx
  101189:	01 ca                	add    %ecx,%edx
  10118b:	0f b7 c0             	movzwl %ax,%eax
  10118e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101191:	eb 77                	jmp    10120a <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  101193:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10119a:	83 c0 50             	add    $0x50,%eax
  10119d:	0f b7 c0             	movzwl %ax,%eax
  1011a0:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011a6:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  1011ad:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
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
  1011d8:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011de:	eb 2b                	jmp    10120b <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011e0:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011e6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ed:	8d 50 01             	lea    0x1(%eax),%edx
  1011f0:	0f b7 d2             	movzwl %dx,%edx
  1011f3:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
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
  10120b:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101212:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101217:	76 5d                	jbe    101276 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101219:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10121e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101224:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101229:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101230:	00 
  101231:	89 54 24 04          	mov    %edx,0x4(%esp)
  101235:	89 04 24             	mov    %eax,(%esp)
  101238:	e8 ed 44 00 00       	call   10572a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10123d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101244:	eb 14                	jmp    10125a <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  101246:	a1 40 a4 11 00       	mov    0x11a440,%eax
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
  101263:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10126a:	83 e8 50             	sub    $0x50,%eax
  10126d:	0f b7 c0             	movzwl %ax,%eax
  101270:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101276:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10127d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101281:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101285:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101289:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10128e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101295:	c1 e8 08             	shr    $0x8,%eax
  101298:	0f b7 c0             	movzwl %ax,%eax
  10129b:	0f b6 c0             	movzbl %al,%eax
  10129e:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012a5:	42                   	inc    %edx
  1012a6:	0f b7 d2             	movzwl %dx,%edx
  1012a9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012ad:	88 45 e9             	mov    %al,-0x17(%ebp)
  1012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012b9:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  1012c0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012c4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  1012c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012d0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012d1:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012d8:	0f b6 c0             	movzbl %al,%eax
  1012db:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
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
  1013a4:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013a9:	8d 50 01             	lea    0x1(%eax),%edx
  1013ac:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  1013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013b5:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013bb:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013c0:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013c5:	75 0a                	jne    1013d1 <cons_intr+0x3b>
                cons.wpos = 0;
  1013c7:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
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
  10143f:	a1 48 a4 11 00       	mov    0x11a448,%eax
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
  1014a0:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a5:	83 c8 40             	or     $0x40,%eax
  1014a8:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014ad:	b8 00 00 00 00       	mov    $0x0,%eax
  1014b2:	e9 22 01 00 00       	jmp    1015d9 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  1014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bb:	84 c0                	test   %al,%al
  1014bd:	79 45                	jns    101504 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014bf:	a1 68 a6 11 00       	mov    0x11a668,%eax
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
  1014de:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014e5:	0c 40                	or     $0x40,%al
  1014e7:	0f b6 c0             	movzbl %al,%eax
  1014ea:	f7 d0                	not    %eax
  1014ec:	89 c2                	mov    %eax,%edx
  1014ee:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f3:	21 d0                	and    %edx,%eax
  1014f5:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ff:	e9 d5 00 00 00       	jmp    1015d9 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  101504:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101509:	83 e0 40             	and    $0x40,%eax
  10150c:	85 c0                	test   %eax,%eax
  10150e:	74 11                	je     101521 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101510:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101514:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101519:	83 e0 bf             	and    $0xffffffbf,%eax
  10151c:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  101521:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101525:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10152c:	0f b6 d0             	movzbl %al,%edx
  10152f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101534:	09 d0                	or     %edx,%eax
  101536:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10153b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10153f:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101546:	0f b6 d0             	movzbl %al,%edx
  101549:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10154e:	31 d0                	xor    %edx,%eax
  101550:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101555:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10155a:	83 e0 03             	and    $0x3,%eax
  10155d:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101564:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101568:	01 d0                	add    %edx,%eax
  10156a:	0f b6 00             	movzbl (%eax),%eax
  10156d:	0f b6 c0             	movzbl %al,%eax
  101570:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101573:	a1 68 a6 11 00       	mov    0x11a668,%eax
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
  1015a1:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1015a6:	f7 d0                	not    %eax
  1015a8:	83 e0 06             	and    $0x6,%eax
  1015ab:	85 c0                	test   %eax,%eax
  1015ad:	75 27                	jne    1015d6 <kbd_proc_data+0x17f>
  1015af:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015b6:	75 1e                	jne    1015d6 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  1015b8:	c7 04 24 35 62 10 00 	movl   $0x106235,(%esp)
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
  10161f:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101624:	85 c0                	test   %eax,%eax
  101626:	75 0c                	jne    101634 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101628:	c7 04 24 41 62 10 00 	movl   $0x106241,(%esp)
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
  101693:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101699:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10169e:	39 c2                	cmp    %eax,%edx
  1016a0:	74 31                	je     1016d3 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016a2:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1016a7:	8d 50 01             	lea    0x1(%eax),%edx
  1016aa:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  1016b0:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  1016b7:	0f b6 c0             	movzbl %al,%eax
  1016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016bd:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1016c2:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016c7:	75 0a                	jne    1016d3 <cons_getc+0x5f>
                cons.rpos = 0;
  1016c9:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
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
  1016f3:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016f9:	a1 6c a6 11 00       	mov    0x11a66c,%eax
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
  101756:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
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
  101775:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
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
  101889:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101890:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101895:	74 0f                	je     1018a6 <pic_init+0x137>
        pic_setmask(irq_mask);
  101897:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
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

/* intr_enable - enable irq interrupt */
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
  1018c5:	c7 04 24 60 62 10 00 	movl   $0x106260,(%esp)
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
  1018e9:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018f0:	0f b7 d0             	movzwl %ax,%edx
  1018f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f6:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018fd:	00 
  1018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101901:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  101908:	00 08 00 
  10190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190e:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  101915:	00 
  101916:	80 e2 e0             	and    $0xe0,%dl
  101919:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101920:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101923:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10192a:	00 
  10192b:	80 e2 1f             	and    $0x1f,%dl
  10192e:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101938:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10193f:	00 
  101940:	80 e2 f0             	and    $0xf0,%dl
  101943:	80 ca 0e             	or     $0xe,%dl
  101946:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101950:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101957:	00 
  101958:	80 e2 ef             	and    $0xef,%dl
  10195b:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101962:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101965:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10196c:	00 
  10196d:	80 e2 9f             	and    $0x9f,%dl
  101970:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197a:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101981:	00 
  101982:	80 ca 80             	or     $0x80,%dl
  101985:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198f:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  101996:	c1 e8 10             	shr    $0x10,%eax
  101999:	0f b7 d0             	movzwl %ax,%edx
  10199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199f:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  1019a6:	00 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  1019a7:	ff 45 fc             	incl   -0x4(%ebp)
  1019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019b2:	0f 86 2e ff ff ff    	jbe    1018e6 <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019b8:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  1019bd:	0f b7 c0             	movzwl %ax,%eax
  1019c0:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  1019c6:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  1019cd:	08 00 
  1019cf:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019d6:	24 e0                	and    $0xe0,%al
  1019d8:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019dd:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019e4:	24 1f                	and    $0x1f,%al
  1019e6:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019eb:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019f2:	24 f0                	and    $0xf0,%al
  1019f4:	0c 0e                	or     $0xe,%al
  1019f6:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019fb:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a02:	24 ef                	and    $0xef,%al
  101a04:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a09:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a10:	0c 60                	or     $0x60,%al
  101a12:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a17:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  101a1e:	0c 80                	or     $0x80,%al
  101a20:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  101a25:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a2a:	c1 e8 10             	shr    $0x10,%eax
  101a2d:	0f b7 c0             	movzwl %ax,%eax
  101a30:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a36:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
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
  101a54:	8b 04 85 c0 65 10 00 	mov    0x1065c0(,%eax,4),%eax
  101a5b:	eb 18                	jmp    101a75 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a5d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a61:	7e 0d                	jle    101a70 <trapname+0x2a>
  101a63:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a67:	7f 07                	jg     101a70 <trapname+0x2a>
        return "Hardware Interrupt";
  101a69:	b8 6a 62 10 00       	mov    $0x10626a,%eax
  101a6e:	eb 05                	jmp    101a75 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a70:	b8 7d 62 10 00       	mov    $0x10627d,%eax
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
  101a99:	c7 04 24 be 62 10 00 	movl   $0x1062be,(%esp)
  101aa0:	e8 fd e7 ff ff       	call   1002a2 <cprintf>
    print_regs(&tf->tf_regs);
  101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa8:	89 04 24             	mov    %eax,(%esp)
  101aab:	e8 8f 01 00 00       	call   101c3f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abb:	c7 04 24 cf 62 10 00 	movl   $0x1062cf,(%esp)
  101ac2:	e8 db e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aca:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ace:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad2:	c7 04 24 e2 62 10 00 	movl   $0x1062e2,(%esp)
  101ad9:	e8 c4 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ade:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae1:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae9:	c7 04 24 f5 62 10 00 	movl   $0x1062f5,(%esp)
  101af0:	e8 ad e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101af5:	8b 45 08             	mov    0x8(%ebp),%eax
  101af8:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b00:	c7 04 24 08 63 10 00 	movl   $0x106308,(%esp)
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
  101b2a:	c7 04 24 1b 63 10 00 	movl   $0x10631b,(%esp)
  101b31:	e8 6c e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b36:	8b 45 08             	mov    0x8(%ebp),%eax
  101b39:	8b 40 34             	mov    0x34(%eax),%eax
  101b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b40:	c7 04 24 2d 63 10 00 	movl   $0x10632d,(%esp)
  101b47:	e8 56 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4f:	8b 40 38             	mov    0x38(%eax),%eax
  101b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b56:	c7 04 24 3c 63 10 00 	movl   $0x10633c,(%esp)
  101b5d:	e8 40 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b62:	8b 45 08             	mov    0x8(%ebp),%eax
  101b65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6d:	c7 04 24 4b 63 10 00 	movl   $0x10634b,(%esp)
  101b74:	e8 29 e7 ff ff       	call   1002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b79:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7c:	8b 40 40             	mov    0x40(%eax),%eax
  101b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b83:	c7 04 24 5e 63 10 00 	movl   $0x10635e,(%esp)
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
  101bb1:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bb8:	85 c0                	test   %eax,%eax
  101bba:	74 1a                	je     101bd6 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bbf:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 6d 63 10 00 	movl   $0x10636d,(%esp)
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
  101bf4:	c7 04 24 71 63 10 00 	movl   $0x106371,(%esp)
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
  101c19:	c7 04 24 7a 63 10 00 	movl   $0x10637a,(%esp)
  101c20:	e8 7d e6 ff ff       	call   1002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c30:	c7 04 24 89 63 10 00 	movl   $0x106389,(%esp)
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
  101c4e:	c7 04 24 9c 63 10 00 	movl   $0x10639c,(%esp)
  101c55:	e8 48 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5d:	8b 40 04             	mov    0x4(%eax),%eax
  101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c64:	c7 04 24 ab 63 10 00 	movl   $0x1063ab,(%esp)
  101c6b:	e8 32 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c70:	8b 45 08             	mov    0x8(%ebp),%eax
  101c73:	8b 40 08             	mov    0x8(%eax),%eax
  101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7a:	c7 04 24 ba 63 10 00 	movl   $0x1063ba,(%esp)
  101c81:	e8 1c e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c86:	8b 45 08             	mov    0x8(%ebp),%eax
  101c89:	8b 40 0c             	mov    0xc(%eax),%eax
  101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c90:	c7 04 24 c9 63 10 00 	movl   $0x1063c9,(%esp)
  101c97:	e8 06 e6 ff ff       	call   1002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9f:	8b 40 10             	mov    0x10(%eax),%eax
  101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca6:	c7 04 24 d8 63 10 00 	movl   $0x1063d8,(%esp)
  101cad:	e8 f0 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb5:	8b 40 14             	mov    0x14(%eax),%eax
  101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cbc:	c7 04 24 e7 63 10 00 	movl   $0x1063e7,(%esp)
  101cc3:	e8 da e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101ccb:	8b 40 18             	mov    0x18(%eax),%eax
  101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd2:	c7 04 24 f6 63 10 00 	movl   $0x1063f6,(%esp)
  101cd9:	e8 c4 e5 ff ff       	call   1002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cde:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce1:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce8:	c7 04 24 05 64 10 00 	movl   $0x106405,(%esp)
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
  101d43:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d48:	40                   	inc    %eax
  101d49:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if(ticks % TICK_NUM == 0 )
  101d4e:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
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
  101da1:	c7 04 24 14 64 10 00 	movl   $0x106414,(%esp)
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
  101dca:	c7 04 24 26 64 10 00 	movl   $0x106426,(%esp)
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
  101f05:	e8 20 38 00 00       	call   10572a <memmove>
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
  101f30:	c7 44 24 08 35 64 10 	movl   $0x106435,0x8(%esp)
  101f37:	00 
  101f38:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  101f3f:	00 
  101f40:	c7 04 24 51 64 10 00 	movl   $0x106451,(%esp)
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
  102a0d:	8b 15 18 af 11 00    	mov    0x11af18,%edx
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
  102a44:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102a49:	39 c2                	cmp    %eax,%edx
  102a4b:	72 1c                	jb     102a69 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102a4d:	c7 44 24 08 10 66 10 	movl   $0x106610,0x8(%esp)
  102a54:	00 
  102a55:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102a5c:	00 
  102a5d:	c7 04 24 2f 66 10 00 	movl   $0x10662f,(%esp)
  102a64:	e8 90 d9 ff ff       	call   1003f9 <__panic>
    }
    return &pages[PPN(pa)];
  102a69:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
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
  102aa2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102aa7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102aaa:	72 23                	jb     102acf <page2kva+0x4a>
  102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ab3:	c7 44 24 08 40 66 10 	movl   $0x106640,0x8(%esp)
  102aba:	00 
  102abb:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102ac2:	00 
  102ac3:	c7 04 24 2f 66 10 00 	movl   $0x10662f,(%esp)
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
  102ae9:	c7 44 24 08 64 66 10 	movl   $0x106664,0x8(%esp)
  102af0:	00 
  102af1:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102af8:	00 
  102af9:	c7 04 24 2f 66 10 00 	movl   $0x10662f,(%esp)
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

00102b39 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
  102b39:	55                   	push   %ebp
  102b3a:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b3f:	8b 00                	mov    (%eax),%eax
  102b41:	8d 50 01             	lea    0x1(%eax),%edx
  102b44:	8b 45 08             	mov    0x8(%ebp),%eax
  102b47:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b49:	8b 45 08             	mov    0x8(%ebp),%eax
  102b4c:	8b 00                	mov    (%eax),%eax
}
  102b4e:	5d                   	pop    %ebp
  102b4f:	c3                   	ret    

00102b50 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102b50:	55                   	push   %ebp
  102b51:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102b53:	8b 45 08             	mov    0x8(%ebp),%eax
  102b56:	8b 00                	mov    (%eax),%eax
  102b58:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5e:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102b60:	8b 45 08             	mov    0x8(%ebp),%eax
  102b63:	8b 00                	mov    (%eax),%eax
}
  102b65:	5d                   	pop    %ebp
  102b66:	c3                   	ret    

00102b67 <__intr_save>:
__intr_save(void) {
  102b67:	55                   	push   %ebp
  102b68:	89 e5                	mov    %esp,%ebp
  102b6a:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102b6d:	9c                   	pushf  
  102b6e:	58                   	pop    %eax
  102b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102b75:	25 00 02 00 00       	and    $0x200,%eax
  102b7a:	85 c0                	test   %eax,%eax
  102b7c:	74 0c                	je     102b8a <__intr_save+0x23>
        intr_disable();
  102b7e:	e8 2d ed ff ff       	call   1018b0 <intr_disable>
        return 1;
  102b83:	b8 01 00 00 00       	mov    $0x1,%eax
  102b88:	eb 05                	jmp    102b8f <__intr_save+0x28>
    return 0;
  102b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102b8f:	c9                   	leave  
  102b90:	c3                   	ret    

00102b91 <__intr_restore>:
__intr_restore(bool flag) {
  102b91:	55                   	push   %ebp
  102b92:	89 e5                	mov    %esp,%ebp
  102b94:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102b97:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102b9b:	74 05                	je     102ba2 <__intr_restore+0x11>
        intr_enable();
  102b9d:	e8 07 ed ff ff       	call   1018a9 <intr_enable>
}
  102ba2:	90                   	nop
  102ba3:	c9                   	leave  
  102ba4:	c3                   	ret    

00102ba5 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102ba5:	55                   	push   %ebp
  102ba6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  102bab:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102bae:	b8 23 00 00 00       	mov    $0x23,%eax
  102bb3:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102bb5:	b8 23 00 00 00       	mov    $0x23,%eax
  102bba:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102bbc:	b8 10 00 00 00       	mov    $0x10,%eax
  102bc1:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102bc3:	b8 10 00 00 00       	mov    $0x10,%eax
  102bc8:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102bca:	b8 10 00 00 00       	mov    $0x10,%eax
  102bcf:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102bd1:	ea d8 2b 10 00 08 00 	ljmp   $0x8,$0x102bd8
}
  102bd8:	90                   	nop
  102bd9:	5d                   	pop    %ebp
  102bda:	c3                   	ret    

00102bdb <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102bdb:	55                   	push   %ebp
  102bdc:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102bde:	8b 45 08             	mov    0x8(%ebp),%eax
  102be1:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  102be6:	90                   	nop
  102be7:	5d                   	pop    %ebp
  102be8:	c3                   	ret    

00102be9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102be9:	55                   	push   %ebp
  102bea:	89 e5                	mov    %esp,%ebp
  102bec:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102bef:	b8 00 70 11 00       	mov    $0x117000,%eax
  102bf4:	89 04 24             	mov    %eax,(%esp)
  102bf7:	e8 df ff ff ff       	call   102bdb <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102bfc:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  102c03:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102c05:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  102c0c:	68 00 
  102c0e:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102c13:	0f b7 c0             	movzwl %ax,%eax
  102c16:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  102c1c:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102c21:	c1 e8 10             	shr    $0x10,%eax
  102c24:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  102c29:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c30:	24 f0                	and    $0xf0,%al
  102c32:	0c 09                	or     $0x9,%al
  102c34:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c39:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c40:	24 ef                	and    $0xef,%al
  102c42:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c47:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c4e:	24 9f                	and    $0x9f,%al
  102c50:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c55:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  102c5c:	0c 80                	or     $0x80,%al
  102c5e:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  102c63:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c6a:	24 f0                	and    $0xf0,%al
  102c6c:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c71:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c78:	24 ef                	and    $0xef,%al
  102c7a:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c7f:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c86:	24 df                	and    $0xdf,%al
  102c88:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c8d:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102c94:	0c 40                	or     $0x40,%al
  102c96:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102c9b:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  102ca2:	24 7f                	and    $0x7f,%al
  102ca4:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  102ca9:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  102cae:	c1 e8 18             	shr    $0x18,%eax
  102cb1:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102cb6:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  102cbd:	e8 e3 fe ff ff       	call   102ba5 <lgdt>
  102cc2:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102cc8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102ccc:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102ccf:	90                   	nop
  102cd0:	c9                   	leave  
  102cd1:	c3                   	ret    

00102cd2 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102cd2:	55                   	push   %ebp
  102cd3:	89 e5                	mov    %esp,%ebp
  102cd5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102cd8:	c7 05 10 af 11 00 f0 	movl   $0x106ff0,0x11af10
  102cdf:	6f 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102ce2:	a1 10 af 11 00       	mov    0x11af10,%eax
  102ce7:	8b 00                	mov    (%eax),%eax
  102ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ced:	c7 04 24 90 66 10 00 	movl   $0x106690,(%esp)
  102cf4:	e8 a9 d5 ff ff       	call   1002a2 <cprintf>
    pmm_manager->init();
  102cf9:	a1 10 af 11 00       	mov    0x11af10,%eax
  102cfe:	8b 40 04             	mov    0x4(%eax),%eax
  102d01:	ff d0                	call   *%eax
}
  102d03:	90                   	nop
  102d04:	c9                   	leave  
  102d05:	c3                   	ret    

00102d06 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102d06:	55                   	push   %ebp
  102d07:	89 e5                	mov    %esp,%ebp
  102d09:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102d0c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102d11:	8b 40 08             	mov    0x8(%eax),%eax
  102d14:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d17:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  102d1e:	89 14 24             	mov    %edx,(%esp)
  102d21:	ff d0                	call   *%eax
}
  102d23:	90                   	nop
  102d24:	c9                   	leave  
  102d25:	c3                   	ret    

00102d26 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102d26:	55                   	push   %ebp
  102d27:	89 e5                	mov    %esp,%ebp
  102d29:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102d2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102d33:	e8 2f fe ff ff       	call   102b67 <__intr_save>
  102d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102d3b:	a1 10 af 11 00       	mov    0x11af10,%eax
  102d40:	8b 40 0c             	mov    0xc(%eax),%eax
  102d43:	8b 55 08             	mov    0x8(%ebp),%edx
  102d46:	89 14 24             	mov    %edx,(%esp)
  102d49:	ff d0                	call   *%eax
  102d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d51:	89 04 24             	mov    %eax,(%esp)
  102d54:	e8 38 fe ff ff       	call   102b91 <__intr_restore>
    return page;
  102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102d5c:	c9                   	leave  
  102d5d:	c3                   	ret    

00102d5e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102d5e:	55                   	push   %ebp
  102d5f:	89 e5                	mov    %esp,%ebp
  102d61:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102d64:	e8 fe fd ff ff       	call   102b67 <__intr_save>
  102d69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102d6c:	a1 10 af 11 00       	mov    0x11af10,%eax
  102d71:	8b 40 10             	mov    0x10(%eax),%eax
  102d74:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d77:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  102d7e:	89 14 24             	mov    %edx,(%esp)
  102d81:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d86:	89 04 24             	mov    %eax,(%esp)
  102d89:	e8 03 fe ff ff       	call   102b91 <__intr_restore>
}
  102d8e:	90                   	nop
  102d8f:	c9                   	leave  
  102d90:	c3                   	ret    

00102d91 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102d91:	55                   	push   %ebp
  102d92:	89 e5                	mov    %esp,%ebp
  102d94:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102d97:	e8 cb fd ff ff       	call   102b67 <__intr_save>
  102d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102d9f:	a1 10 af 11 00       	mov    0x11af10,%eax
  102da4:	8b 40 14             	mov    0x14(%eax),%eax
  102da7:	ff d0                	call   *%eax
  102da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102daf:	89 04 24             	mov    %eax,(%esp)
  102db2:	e8 da fd ff ff       	call   102b91 <__intr_restore>
    return ret;
  102db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102dba:	c9                   	leave  
  102dbb:	c3                   	ret    

00102dbc <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102dbc:	55                   	push   %ebp
  102dbd:	89 e5                	mov    %esp,%ebp
  102dbf:	57                   	push   %edi
  102dc0:	56                   	push   %esi
  102dc1:	53                   	push   %ebx
  102dc2:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102dc8:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102dcf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102dd6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102ddd:	c7 04 24 a7 66 10 00 	movl   $0x1066a7,(%esp)
  102de4:	e8 b9 d4 ff ff       	call   1002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102de9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102df0:	e9 22 01 00 00       	jmp    102f17 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102df5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102df8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102dfb:	89 d0                	mov    %edx,%eax
  102dfd:	c1 e0 02             	shl    $0x2,%eax
  102e00:	01 d0                	add    %edx,%eax
  102e02:	c1 e0 02             	shl    $0x2,%eax
  102e05:	01 c8                	add    %ecx,%eax
  102e07:	8b 50 08             	mov    0x8(%eax),%edx
  102e0a:	8b 40 04             	mov    0x4(%eax),%eax
  102e0d:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102e10:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102e13:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e16:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e19:	89 d0                	mov    %edx,%eax
  102e1b:	c1 e0 02             	shl    $0x2,%eax
  102e1e:	01 d0                	add    %edx,%eax
  102e20:	c1 e0 02             	shl    $0x2,%eax
  102e23:	01 c8                	add    %ecx,%eax
  102e25:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e28:	8b 58 10             	mov    0x10(%eax),%ebx
  102e2b:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e2e:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e31:	01 c8                	add    %ecx,%eax
  102e33:	11 da                	adc    %ebx,%edx
  102e35:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e38:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102e3b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e41:	89 d0                	mov    %edx,%eax
  102e43:	c1 e0 02             	shl    $0x2,%eax
  102e46:	01 d0                	add    %edx,%eax
  102e48:	c1 e0 02             	shl    $0x2,%eax
  102e4b:	01 c8                	add    %ecx,%eax
  102e4d:	83 c0 14             	add    $0x14,%eax
  102e50:	8b 00                	mov    (%eax),%eax
  102e52:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102e55:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e58:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102e5b:	83 c0 ff             	add    $0xffffffff,%eax
  102e5e:	83 d2 ff             	adc    $0xffffffff,%edx
  102e61:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102e67:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102e6d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e70:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e73:	89 d0                	mov    %edx,%eax
  102e75:	c1 e0 02             	shl    $0x2,%eax
  102e78:	01 d0                	add    %edx,%eax
  102e7a:	c1 e0 02             	shl    $0x2,%eax
  102e7d:	01 c8                	add    %ecx,%eax
  102e7f:	8b 48 0c             	mov    0xc(%eax),%ecx
  102e82:	8b 58 10             	mov    0x10(%eax),%ebx
  102e85:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102e88:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102e8c:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102e92:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102e98:	89 44 24 14          	mov    %eax,0x14(%esp)
  102e9c:	89 54 24 18          	mov    %edx,0x18(%esp)
  102ea0:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ea3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ea6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102eaa:	89 54 24 10          	mov    %edx,0x10(%esp)
  102eae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102eb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102eb6:	c7 04 24 b4 66 10 00 	movl   $0x1066b4,(%esp)
  102ebd:	e8 e0 d3 ff ff       	call   1002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102ec2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ec5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ec8:	89 d0                	mov    %edx,%eax
  102eca:	c1 e0 02             	shl    $0x2,%eax
  102ecd:	01 d0                	add    %edx,%eax
  102ecf:	c1 e0 02             	shl    $0x2,%eax
  102ed2:	01 c8                	add    %ecx,%eax
  102ed4:	83 c0 14             	add    $0x14,%eax
  102ed7:	8b 00                	mov    (%eax),%eax
  102ed9:	83 f8 01             	cmp    $0x1,%eax
  102edc:	75 36                	jne    102f14 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102ede:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ee1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ee4:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102ee7:	77 2b                	ja     102f14 <page_init+0x158>
  102ee9:	3b 55 9c             	cmp    -0x64(%ebp),%edx
  102eec:	72 05                	jb     102ef3 <page_init+0x137>
  102eee:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102ef1:	73 21                	jae    102f14 <page_init+0x158>
  102ef3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102ef7:	77 1b                	ja     102f14 <page_init+0x158>
  102ef9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  102efd:	72 09                	jb     102f08 <page_init+0x14c>
  102eff:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
  102f06:	77 0c                	ja     102f14 <page_init+0x158>
                maxpa = end;
  102f08:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f0b:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102f0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102f14:	ff 45 dc             	incl   -0x24(%ebp)
  102f17:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102f1a:	8b 00                	mov    (%eax),%eax
  102f1c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102f1f:	0f 8c d0 fe ff ff    	jl     102df5 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102f25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f29:	72 1d                	jb     102f48 <page_init+0x18c>
  102f2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102f2f:	77 09                	ja     102f3a <page_init+0x17e>
  102f31:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102f38:	76 0e                	jbe    102f48 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102f3a:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102f41:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f4e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102f52:	c1 ea 0c             	shr    $0xc,%edx
  102f55:	89 c1                	mov    %eax,%ecx
  102f57:	89 d3                	mov    %edx,%ebx
  102f59:	89 c8                	mov    %ecx,%eax
  102f5b:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102f60:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102f67:	b8 28 af 11 00       	mov    $0x11af28,%eax
  102f6c:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f6f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102f72:	01 d0                	add    %edx,%eax
  102f74:	89 45 bc             	mov    %eax,-0x44(%ebp)
  102f77:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102f7a:	ba 00 00 00 00       	mov    $0x0,%edx
  102f7f:	f7 75 c0             	divl   -0x40(%ebp)
  102f82:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102f85:	29 d0                	sub    %edx,%eax
  102f87:	a3 18 af 11 00       	mov    %eax,0x11af18

    for (i = 0; i < npage; i ++) {
  102f8c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102f93:	eb 2e                	jmp    102fc3 <page_init+0x207>
        SetPageReserved(pages + i);
  102f95:	8b 0d 18 af 11 00    	mov    0x11af18,%ecx
  102f9b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f9e:	89 d0                	mov    %edx,%eax
  102fa0:	c1 e0 02             	shl    $0x2,%eax
  102fa3:	01 d0                	add    %edx,%eax
  102fa5:	c1 e0 02             	shl    $0x2,%eax
  102fa8:	01 c8                	add    %ecx,%eax
  102faa:	83 c0 04             	add    $0x4,%eax
  102fad:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  102fb4:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fb7:	8b 45 90             	mov    -0x70(%ebp),%eax
  102fba:	8b 55 94             	mov    -0x6c(%ebp),%edx
  102fbd:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
  102fc0:	ff 45 dc             	incl   -0x24(%ebp)
  102fc3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fc6:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  102fcb:	39 c2                	cmp    %eax,%edx
  102fcd:	72 c6                	jb     102f95 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102fcf:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  102fd5:	89 d0                	mov    %edx,%eax
  102fd7:	c1 e0 02             	shl    $0x2,%eax
  102fda:	01 d0                	add    %edx,%eax
  102fdc:	c1 e0 02             	shl    $0x2,%eax
  102fdf:	89 c2                	mov    %eax,%edx
  102fe1:	a1 18 af 11 00       	mov    0x11af18,%eax
  102fe6:	01 d0                	add    %edx,%eax
  102fe8:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102feb:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  102ff2:	77 23                	ja     103017 <page_init+0x25b>
  102ff4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ff7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102ffb:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  103002:	00 
  103003:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10300a:	00 
  10300b:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103012:	e8 e2 d3 ff ff       	call   1003f9 <__panic>
  103017:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10301a:	05 00 00 00 40       	add    $0x40000000,%eax
  10301f:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103022:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103029:	e9 69 01 00 00       	jmp    103197 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10302e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103031:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103034:	89 d0                	mov    %edx,%eax
  103036:	c1 e0 02             	shl    $0x2,%eax
  103039:	01 d0                	add    %edx,%eax
  10303b:	c1 e0 02             	shl    $0x2,%eax
  10303e:	01 c8                	add    %ecx,%eax
  103040:	8b 50 08             	mov    0x8(%eax),%edx
  103043:	8b 40 04             	mov    0x4(%eax),%eax
  103046:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103049:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10304c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10304f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103052:	89 d0                	mov    %edx,%eax
  103054:	c1 e0 02             	shl    $0x2,%eax
  103057:	01 d0                	add    %edx,%eax
  103059:	c1 e0 02             	shl    $0x2,%eax
  10305c:	01 c8                	add    %ecx,%eax
  10305e:	8b 48 0c             	mov    0xc(%eax),%ecx
  103061:	8b 58 10             	mov    0x10(%eax),%ebx
  103064:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103067:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10306a:	01 c8                	add    %ecx,%eax
  10306c:	11 da                	adc    %ebx,%edx
  10306e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103071:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  103074:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103077:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10307a:	89 d0                	mov    %edx,%eax
  10307c:	c1 e0 02             	shl    $0x2,%eax
  10307f:	01 d0                	add    %edx,%eax
  103081:	c1 e0 02             	shl    $0x2,%eax
  103084:	01 c8                	add    %ecx,%eax
  103086:	83 c0 14             	add    $0x14,%eax
  103089:	8b 00                	mov    (%eax),%eax
  10308b:	83 f8 01             	cmp    $0x1,%eax
  10308e:	0f 85 00 01 00 00    	jne    103194 <page_init+0x3d8>
            if (begin < freemem) {
  103094:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103097:	ba 00 00 00 00       	mov    $0x0,%edx
  10309c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  10309f:	77 17                	ja     1030b8 <page_init+0x2fc>
  1030a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1030a4:	72 05                	jb     1030ab <page_init+0x2ef>
  1030a6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1030a9:	73 0d                	jae    1030b8 <page_init+0x2fc>
                begin = freemem;
  1030ab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1030ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1030b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030bc:	72 1d                	jb     1030db <page_init+0x31f>
  1030be:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1030c2:	77 09                	ja     1030cd <page_init+0x311>
  1030c4:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1030cb:	76 0e                	jbe    1030db <page_init+0x31f>
                end = KMEMSIZE;
  1030cd:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1030d4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1030db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1030de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1030e1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030e4:	0f 87 aa 00 00 00    	ja     103194 <page_init+0x3d8>
  1030ea:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1030ed:	72 09                	jb     1030f8 <page_init+0x33c>
  1030ef:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1030f2:	0f 83 9c 00 00 00    	jae    103194 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
  1030f8:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  1030ff:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103102:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103105:	01 d0                	add    %edx,%eax
  103107:	48                   	dec    %eax
  103108:	89 45 ac             	mov    %eax,-0x54(%ebp)
  10310b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10310e:	ba 00 00 00 00       	mov    $0x0,%edx
  103113:	f7 75 b0             	divl   -0x50(%ebp)
  103116:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103119:	29 d0                	sub    %edx,%eax
  10311b:	ba 00 00 00 00       	mov    $0x0,%edx
  103120:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103123:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103126:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103129:	89 45 a8             	mov    %eax,-0x58(%ebp)
  10312c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10312f:	ba 00 00 00 00       	mov    $0x0,%edx
  103134:	89 c3                	mov    %eax,%ebx
  103136:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  10313c:	89 de                	mov    %ebx,%esi
  10313e:	89 d0                	mov    %edx,%eax
  103140:	83 e0 00             	and    $0x0,%eax
  103143:	89 c7                	mov    %eax,%edi
  103145:	89 75 c8             	mov    %esi,-0x38(%ebp)
  103148:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  10314b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10314e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103151:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103154:	77 3e                	ja     103194 <page_init+0x3d8>
  103156:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103159:	72 05                	jb     103160 <page_init+0x3a4>
  10315b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10315e:	73 34                	jae    103194 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  103160:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103163:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103166:	2b 45 d0             	sub    -0x30(%ebp),%eax
  103169:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10316c:	89 c1                	mov    %eax,%ecx
  10316e:	89 d3                	mov    %edx,%ebx
  103170:	89 c8                	mov    %ecx,%eax
  103172:	89 da                	mov    %ebx,%edx
  103174:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103178:	c1 ea 0c             	shr    $0xc,%edx
  10317b:	89 c3                	mov    %eax,%ebx
  10317d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103180:	89 04 24             	mov    %eax,(%esp)
  103183:	e8 ae f8 ff ff       	call   102a36 <pa2page>
  103188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10318c:	89 04 24             	mov    %eax,(%esp)
  10318f:	e8 72 fb ff ff       	call   102d06 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103194:	ff 45 dc             	incl   -0x24(%ebp)
  103197:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10319a:	8b 00                	mov    (%eax),%eax
  10319c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10319f:	0f 8c 89 fe ff ff    	jl     10302e <page_init+0x272>
                }
            }
        }
    }
}
  1031a5:	90                   	nop
  1031a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1031ac:	5b                   	pop    %ebx
  1031ad:	5e                   	pop    %esi
  1031ae:	5f                   	pop    %edi
  1031af:	5d                   	pop    %ebp
  1031b0:	c3                   	ret    

001031b1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1031b1:	55                   	push   %ebp
  1031b2:	89 e5                	mov    %esp,%ebp
  1031b4:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1031b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031ba:	33 45 14             	xor    0x14(%ebp),%eax
  1031bd:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031c2:	85 c0                	test   %eax,%eax
  1031c4:	74 24                	je     1031ea <boot_map_segment+0x39>
  1031c6:	c7 44 24 0c 16 67 10 	movl   $0x106716,0xc(%esp)
  1031cd:	00 
  1031ce:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1031d5:	00 
  1031d6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1031dd:	00 
  1031de:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1031e5:	e8 0f d2 ff ff       	call   1003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1031ea:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031f4:	25 ff 0f 00 00       	and    $0xfff,%eax
  1031f9:	89 c2                	mov    %eax,%edx
  1031fb:	8b 45 10             	mov    0x10(%ebp),%eax
  1031fe:	01 c2                	add    %eax,%edx
  103200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103203:	01 d0                	add    %edx,%eax
  103205:	48                   	dec    %eax
  103206:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103209:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10320c:	ba 00 00 00 00       	mov    $0x0,%edx
  103211:	f7 75 f0             	divl   -0x10(%ebp)
  103214:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103217:	29 d0                	sub    %edx,%eax
  103219:	c1 e8 0c             	shr    $0xc,%eax
  10321c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10321f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103222:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103225:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10322d:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103230:	8b 45 14             	mov    0x14(%ebp),%eax
  103233:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103239:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10323e:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103241:	eb 68                	jmp    1032ab <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103243:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10324a:	00 
  10324b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10324e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103252:	8b 45 08             	mov    0x8(%ebp),%eax
  103255:	89 04 24             	mov    %eax,(%esp)
  103258:	e8 81 01 00 00       	call   1033de <get_pte>
  10325d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103260:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  103264:	75 24                	jne    10328a <boot_map_segment+0xd9>
  103266:	c7 44 24 0c 42 67 10 	movl   $0x106742,0xc(%esp)
  10326d:	00 
  10326e:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103275:	00 
  103276:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  10327d:	00 
  10327e:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103285:	e8 6f d1 ff ff       	call   1003f9 <__panic>
        *ptep = pa | PTE_P | perm;
  10328a:	8b 45 14             	mov    0x14(%ebp),%eax
  10328d:	0b 45 18             	or     0x18(%ebp),%eax
  103290:	83 c8 01             	or     $0x1,%eax
  103293:	89 c2                	mov    %eax,%edx
  103295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103298:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10329a:	ff 4d f4             	decl   -0xc(%ebp)
  10329d:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1032a4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1032ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032af:	75 92                	jne    103243 <boot_map_segment+0x92>
    }
}
  1032b1:	90                   	nop
  1032b2:	c9                   	leave  
  1032b3:	c3                   	ret    

001032b4 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1032b4:	55                   	push   %ebp
  1032b5:	89 e5                	mov    %esp,%ebp
  1032b7:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1032ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032c1:	e8 60 fa ff ff       	call   102d26 <alloc_pages>
  1032c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1032c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032cd:	75 1c                	jne    1032eb <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1032cf:	c7 44 24 08 4f 67 10 	movl   $0x10674f,0x8(%esp)
  1032d6:	00 
  1032d7:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1032de:	00 
  1032df:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1032e6:	e8 0e d1 ff ff       	call   1003f9 <__panic>
    }
    return page2kva(p);
  1032eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032ee:	89 04 24             	mov    %eax,(%esp)
  1032f1:	e8 8f f7 ff ff       	call   102a85 <page2kva>
}
  1032f6:	c9                   	leave  
  1032f7:	c3                   	ret    

001032f8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1032f8:	55                   	push   %ebp
  1032f9:	89 e5                	mov    %esp,%ebp
  1032fb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1032fe:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103303:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103306:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10330d:	77 23                	ja     103332 <pmm_init+0x3a>
  10330f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103316:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  10331d:	00 
  10331e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  103325:	00 
  103326:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10332d:	e8 c7 d0 ff ff       	call   1003f9 <__panic>
  103332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103335:	05 00 00 00 40       	add    $0x40000000,%eax
  10333a:	a3 14 af 11 00       	mov    %eax,0x11af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10333f:	e8 8e f9 ff ff       	call   102cd2 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103344:	e8 73 fa ff ff       	call   102dbc <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103349:	e8 4f 02 00 00       	call   10359d <check_alloc_page>

    check_pgdir();
  10334e:	e8 69 02 00 00       	call   1035bc <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  103353:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103358:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10335b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103362:	77 23                	ja     103387 <pmm_init+0x8f>
  103364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10336b:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  103372:	00 
  103373:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  10337a:	00 
  10337b:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103382:	e8 72 d0 ff ff       	call   1003f9 <__panic>
  103387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10338a:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  103390:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103395:	05 ac 0f 00 00       	add    $0xfac,%eax
  10339a:	83 ca 03             	or     $0x3,%edx
  10339d:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10339f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1033a4:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1033ab:	00 
  1033ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1033b3:	00 
  1033b4:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1033bb:	38 
  1033bc:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1033c3:	c0 
  1033c4:	89 04 24             	mov    %eax,(%esp)
  1033c7:	e8 e5 fd ff ff       	call   1031b1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1033cc:	e8 18 f8 ff ff       	call   102be9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1033d1:	e8 82 08 00 00       	call   103c58 <check_boot_pgdir>

    print_pgdir();
  1033d6:	e8 fb 0c 00 00       	call   1040d6 <print_pgdir>

}
  1033db:	90                   	nop
  1033dc:	c9                   	leave  
  1033dd:	c3                   	ret    

001033de <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1033de:	55                   	push   %ebp
  1033df:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
  1033e1:	90                   	nop
  1033e2:	5d                   	pop    %ebp
  1033e3:	c3                   	ret    

001033e4 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1033e4:	55                   	push   %ebp
  1033e5:	89 e5                	mov    %esp,%ebp
  1033e7:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1033ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1033f1:	00 
  1033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1033fc:	89 04 24             	mov    %eax,(%esp)
  1033ff:	e8 da ff ff ff       	call   1033de <get_pte>
  103404:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103407:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10340b:	74 08                	je     103415 <get_page+0x31>
        *ptep_store = ptep;
  10340d:	8b 45 10             	mov    0x10(%ebp),%eax
  103410:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103413:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103415:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103419:	74 1b                	je     103436 <get_page+0x52>
  10341b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10341e:	8b 00                	mov    (%eax),%eax
  103420:	83 e0 01             	and    $0x1,%eax
  103423:	85 c0                	test   %eax,%eax
  103425:	74 0f                	je     103436 <get_page+0x52>
        return pte2page(*ptep);
  103427:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10342a:	8b 00                	mov    (%eax),%eax
  10342c:	89 04 24             	mov    %eax,(%esp)
  10342f:	e8 a5 f6 ff ff       	call   102ad9 <pte2page>
  103434:	eb 05                	jmp    10343b <get_page+0x57>
    }
    return NULL;
  103436:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10343b:	c9                   	leave  
  10343c:	c3                   	ret    

0010343d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10343d:	55                   	push   %ebp
  10343e:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
  103440:	90                   	nop
  103441:	5d                   	pop    %ebp
  103442:	c3                   	ret    

00103443 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103443:	55                   	push   %ebp
  103444:	89 e5                	mov    %esp,%ebp
  103446:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103449:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103450:	00 
  103451:	8b 45 0c             	mov    0xc(%ebp),%eax
  103454:	89 44 24 04          	mov    %eax,0x4(%esp)
  103458:	8b 45 08             	mov    0x8(%ebp),%eax
  10345b:	89 04 24             	mov    %eax,(%esp)
  10345e:	e8 7b ff ff ff       	call   1033de <get_pte>
  103463:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
  103466:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10346a:	74 19                	je     103485 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10346c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10346f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103473:	8b 45 0c             	mov    0xc(%ebp),%eax
  103476:	89 44 24 04          	mov    %eax,0x4(%esp)
  10347a:	8b 45 08             	mov    0x8(%ebp),%eax
  10347d:	89 04 24             	mov    %eax,(%esp)
  103480:	e8 b8 ff ff ff       	call   10343d <page_remove_pte>
    }
}
  103485:	90                   	nop
  103486:	c9                   	leave  
  103487:	c3                   	ret    

00103488 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103488:	55                   	push   %ebp
  103489:	89 e5                	mov    %esp,%ebp
  10348b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10348e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103495:	00 
  103496:	8b 45 10             	mov    0x10(%ebp),%eax
  103499:	89 44 24 04          	mov    %eax,0x4(%esp)
  10349d:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a0:	89 04 24             	mov    %eax,(%esp)
  1034a3:	e8 36 ff ff ff       	call   1033de <get_pte>
  1034a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1034ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034af:	75 0a                	jne    1034bb <page_insert+0x33>
        return -E_NO_MEM;
  1034b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1034b6:	e9 84 00 00 00       	jmp    10353f <page_insert+0xb7>
    }
    page_ref_inc(page);
  1034bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034be:	89 04 24             	mov    %eax,(%esp)
  1034c1:	e8 73 f6 ff ff       	call   102b39 <page_ref_inc>
    if (*ptep & PTE_P) {
  1034c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034c9:	8b 00                	mov    (%eax),%eax
  1034cb:	83 e0 01             	and    $0x1,%eax
  1034ce:	85 c0                	test   %eax,%eax
  1034d0:	74 3e                	je     103510 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1034d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034d5:	8b 00                	mov    (%eax),%eax
  1034d7:	89 04 24             	mov    %eax,(%esp)
  1034da:	e8 fa f5 ff ff       	call   102ad9 <pte2page>
  1034df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1034e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1034e8:	75 0d                	jne    1034f7 <page_insert+0x6f>
            page_ref_dec(page);
  1034ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ed:	89 04 24             	mov    %eax,(%esp)
  1034f0:	e8 5b f6 ff ff       	call   102b50 <page_ref_dec>
  1034f5:	eb 19                	jmp    103510 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034fe:	8b 45 10             	mov    0x10(%ebp),%eax
  103501:	89 44 24 04          	mov    %eax,0x4(%esp)
  103505:	8b 45 08             	mov    0x8(%ebp),%eax
  103508:	89 04 24             	mov    %eax,(%esp)
  10350b:	e8 2d ff ff ff       	call   10343d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103510:	8b 45 0c             	mov    0xc(%ebp),%eax
  103513:	89 04 24             	mov    %eax,(%esp)
  103516:	e8 05 f5 ff ff       	call   102a20 <page2pa>
  10351b:	0b 45 14             	or     0x14(%ebp),%eax
  10351e:	83 c8 01             	or     $0x1,%eax
  103521:	89 c2                	mov    %eax,%edx
  103523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103526:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103528:	8b 45 10             	mov    0x10(%ebp),%eax
  10352b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10352f:	8b 45 08             	mov    0x8(%ebp),%eax
  103532:	89 04 24             	mov    %eax,(%esp)
  103535:	e8 07 00 00 00       	call   103541 <tlb_invalidate>
    return 0;
  10353a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10353f:	c9                   	leave  
  103540:	c3                   	ret    

00103541 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103541:	55                   	push   %ebp
  103542:	89 e5                	mov    %esp,%ebp
  103544:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103547:	0f 20 d8             	mov    %cr3,%eax
  10354a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10354d:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103550:	8b 45 08             	mov    0x8(%ebp),%eax
  103553:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103556:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10355d:	77 23                	ja     103582 <tlb_invalidate+0x41>
  10355f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103562:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103566:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  10356d:	00 
  10356e:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
  103575:	00 
  103576:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10357d:	e8 77 ce ff ff       	call   1003f9 <__panic>
  103582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103585:	05 00 00 00 40       	add    $0x40000000,%eax
  10358a:	39 d0                	cmp    %edx,%eax
  10358c:	75 0c                	jne    10359a <tlb_invalidate+0x59>
        invlpg((void *)la);
  10358e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103591:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103594:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103597:	0f 01 38             	invlpg (%eax)
    }
}
  10359a:	90                   	nop
  10359b:	c9                   	leave  
  10359c:	c3                   	ret    

0010359d <check_alloc_page>:

static void
check_alloc_page(void) {
  10359d:	55                   	push   %ebp
  10359e:	89 e5                	mov    %esp,%ebp
  1035a0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1035a3:	a1 10 af 11 00       	mov    0x11af10,%eax
  1035a8:	8b 40 18             	mov    0x18(%eax),%eax
  1035ab:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1035ad:	c7 04 24 68 67 10 00 	movl   $0x106768,(%esp)
  1035b4:	e8 e9 cc ff ff       	call   1002a2 <cprintf>
}
  1035b9:	90                   	nop
  1035ba:	c9                   	leave  
  1035bb:	c3                   	ret    

001035bc <check_pgdir>:

static void
check_pgdir(void) {
  1035bc:	55                   	push   %ebp
  1035bd:	89 e5                	mov    %esp,%ebp
  1035bf:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1035c2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1035c7:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1035cc:	76 24                	jbe    1035f2 <check_pgdir+0x36>
  1035ce:	c7 44 24 0c 87 67 10 	movl   $0x106787,0xc(%esp)
  1035d5:	00 
  1035d6:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1035dd:	00 
  1035de:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  1035e5:	00 
  1035e6:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1035ed:	e8 07 ce ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1035f2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1035f7:	85 c0                	test   %eax,%eax
  1035f9:	74 0e                	je     103609 <check_pgdir+0x4d>
  1035fb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103600:	25 ff 0f 00 00       	and    $0xfff,%eax
  103605:	85 c0                	test   %eax,%eax
  103607:	74 24                	je     10362d <check_pgdir+0x71>
  103609:	c7 44 24 0c a4 67 10 	movl   $0x1067a4,0xc(%esp)
  103610:	00 
  103611:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103618:	00 
  103619:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  103620:	00 
  103621:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103628:	e8 cc cd ff ff       	call   1003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10362d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103632:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103639:	00 
  10363a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103641:	00 
  103642:	89 04 24             	mov    %eax,(%esp)
  103645:	e8 9a fd ff ff       	call   1033e4 <get_page>
  10364a:	85 c0                	test   %eax,%eax
  10364c:	74 24                	je     103672 <check_pgdir+0xb6>
  10364e:	c7 44 24 0c dc 67 10 	movl   $0x1067dc,0xc(%esp)
  103655:	00 
  103656:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  10365d:	00 
  10365e:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
  103665:	00 
  103666:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10366d:	e8 87 cd ff ff       	call   1003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103672:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103679:	e8 a8 f6 ff ff       	call   102d26 <alloc_pages>
  10367e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103681:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103686:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10368d:	00 
  10368e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103695:	00 
  103696:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103699:	89 54 24 04          	mov    %edx,0x4(%esp)
  10369d:	89 04 24             	mov    %eax,(%esp)
  1036a0:	e8 e3 fd ff ff       	call   103488 <page_insert>
  1036a5:	85 c0                	test   %eax,%eax
  1036a7:	74 24                	je     1036cd <check_pgdir+0x111>
  1036a9:	c7 44 24 0c 04 68 10 	movl   $0x106804,0xc(%esp)
  1036b0:	00 
  1036b1:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1036b8:	00 
  1036b9:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  1036c0:	00 
  1036c1:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1036c8:	e8 2c cd ff ff       	call   1003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1036cd:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1036d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036d9:	00 
  1036da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036e1:	00 
  1036e2:	89 04 24             	mov    %eax,(%esp)
  1036e5:	e8 f4 fc ff ff       	call   1033de <get_pte>
  1036ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036f1:	75 24                	jne    103717 <check_pgdir+0x15b>
  1036f3:	c7 44 24 0c 30 68 10 	movl   $0x106830,0xc(%esp)
  1036fa:	00 
  1036fb:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103702:	00 
  103703:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  10370a:	00 
  10370b:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103712:	e8 e2 cc ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  103717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10371a:	8b 00                	mov    (%eax),%eax
  10371c:	89 04 24             	mov    %eax,(%esp)
  10371f:	e8 b5 f3 ff ff       	call   102ad9 <pte2page>
  103724:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103727:	74 24                	je     10374d <check_pgdir+0x191>
  103729:	c7 44 24 0c 5d 68 10 	movl   $0x10685d,0xc(%esp)
  103730:	00 
  103731:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103738:	00 
  103739:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  103740:	00 
  103741:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103748:	e8 ac cc ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 1);
  10374d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103750:	89 04 24             	mov    %eax,(%esp)
  103753:	e8 d7 f3 ff ff       	call   102b2f <page_ref>
  103758:	83 f8 01             	cmp    $0x1,%eax
  10375b:	74 24                	je     103781 <check_pgdir+0x1c5>
  10375d:	c7 44 24 0c 73 68 10 	movl   $0x106873,0xc(%esp)
  103764:	00 
  103765:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  10376c:	00 
  10376d:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103774:	00 
  103775:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10377c:	e8 78 cc ff ff       	call   1003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103781:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103786:	8b 00                	mov    (%eax),%eax
  103788:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10378d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103793:	c1 e8 0c             	shr    $0xc,%eax
  103796:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103799:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10379e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1037a1:	72 23                	jb     1037c6 <check_pgdir+0x20a>
  1037a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1037aa:	c7 44 24 08 40 66 10 	movl   $0x106640,0x8(%esp)
  1037b1:	00 
  1037b2:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
  1037b9:	00 
  1037ba:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1037c1:	e8 33 cc ff ff       	call   1003f9 <__panic>
  1037c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1037ce:	83 c0 04             	add    $0x4,%eax
  1037d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1037d4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1037d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037e0:	00 
  1037e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1037e8:	00 
  1037e9:	89 04 24             	mov    %eax,(%esp)
  1037ec:	e8 ed fb ff ff       	call   1033de <get_pte>
  1037f1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1037f4:	74 24                	je     10381a <check_pgdir+0x25e>
  1037f6:	c7 44 24 0c 88 68 10 	movl   $0x106888,0xc(%esp)
  1037fd:	00 
  1037fe:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103805:	00 
  103806:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
  10380d:	00 
  10380e:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103815:	e8 df cb ff ff       	call   1003f9 <__panic>

    p2 = alloc_page();
  10381a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103821:	e8 00 f5 ff ff       	call   102d26 <alloc_pages>
  103826:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103829:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10382e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103835:	00 
  103836:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10383d:	00 
  10383e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103841:	89 54 24 04          	mov    %edx,0x4(%esp)
  103845:	89 04 24             	mov    %eax,(%esp)
  103848:	e8 3b fc ff ff       	call   103488 <page_insert>
  10384d:	85 c0                	test   %eax,%eax
  10384f:	74 24                	je     103875 <check_pgdir+0x2b9>
  103851:	c7 44 24 0c b0 68 10 	movl   $0x1068b0,0xc(%esp)
  103858:	00 
  103859:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103860:	00 
  103861:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  103868:	00 
  103869:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103870:	e8 84 cb ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103875:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10387a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103881:	00 
  103882:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103889:	00 
  10388a:	89 04 24             	mov    %eax,(%esp)
  10388d:	e8 4c fb ff ff       	call   1033de <get_pte>
  103892:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103895:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103899:	75 24                	jne    1038bf <check_pgdir+0x303>
  10389b:	c7 44 24 0c e8 68 10 	movl   $0x1068e8,0xc(%esp)
  1038a2:	00 
  1038a3:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1038aa:	00 
  1038ab:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
  1038b2:	00 
  1038b3:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1038ba:	e8 3a cb ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_U);
  1038bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038c2:	8b 00                	mov    (%eax),%eax
  1038c4:	83 e0 04             	and    $0x4,%eax
  1038c7:	85 c0                	test   %eax,%eax
  1038c9:	75 24                	jne    1038ef <check_pgdir+0x333>
  1038cb:	c7 44 24 0c 18 69 10 	movl   $0x106918,0xc(%esp)
  1038d2:	00 
  1038d3:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1038da:	00 
  1038db:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  1038e2:	00 
  1038e3:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1038ea:	e8 0a cb ff ff       	call   1003f9 <__panic>
    assert(*ptep & PTE_W);
  1038ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038f2:	8b 00                	mov    (%eax),%eax
  1038f4:	83 e0 02             	and    $0x2,%eax
  1038f7:	85 c0                	test   %eax,%eax
  1038f9:	75 24                	jne    10391f <check_pgdir+0x363>
  1038fb:	c7 44 24 0c 26 69 10 	movl   $0x106926,0xc(%esp)
  103902:	00 
  103903:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  10390a:	00 
  10390b:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  103912:	00 
  103913:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10391a:	e8 da ca ff ff       	call   1003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  10391f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103924:	8b 00                	mov    (%eax),%eax
  103926:	83 e0 04             	and    $0x4,%eax
  103929:	85 c0                	test   %eax,%eax
  10392b:	75 24                	jne    103951 <check_pgdir+0x395>
  10392d:	c7 44 24 0c 34 69 10 	movl   $0x106934,0xc(%esp)
  103934:	00 
  103935:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  10393c:	00 
  10393d:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  103944:	00 
  103945:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  10394c:	e8 a8 ca ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 1);
  103951:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103954:	89 04 24             	mov    %eax,(%esp)
  103957:	e8 d3 f1 ff ff       	call   102b2f <page_ref>
  10395c:	83 f8 01             	cmp    $0x1,%eax
  10395f:	74 24                	je     103985 <check_pgdir+0x3c9>
  103961:	c7 44 24 0c 4a 69 10 	movl   $0x10694a,0xc(%esp)
  103968:	00 
  103969:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103970:	00 
  103971:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  103978:	00 
  103979:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103980:	e8 74 ca ff ff       	call   1003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103985:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10398a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103991:	00 
  103992:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103999:	00 
  10399a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10399d:	89 54 24 04          	mov    %edx,0x4(%esp)
  1039a1:	89 04 24             	mov    %eax,(%esp)
  1039a4:	e8 df fa ff ff       	call   103488 <page_insert>
  1039a9:	85 c0                	test   %eax,%eax
  1039ab:	74 24                	je     1039d1 <check_pgdir+0x415>
  1039ad:	c7 44 24 0c 5c 69 10 	movl   $0x10695c,0xc(%esp)
  1039b4:	00 
  1039b5:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1039bc:	00 
  1039bd:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  1039c4:	00 
  1039c5:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  1039cc:	e8 28 ca ff ff       	call   1003f9 <__panic>
    assert(page_ref(p1) == 2);
  1039d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039d4:	89 04 24             	mov    %eax,(%esp)
  1039d7:	e8 53 f1 ff ff       	call   102b2f <page_ref>
  1039dc:	83 f8 02             	cmp    $0x2,%eax
  1039df:	74 24                	je     103a05 <check_pgdir+0x449>
  1039e1:	c7 44 24 0c 88 69 10 	movl   $0x106988,0xc(%esp)
  1039e8:	00 
  1039e9:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  1039f0:	00 
  1039f1:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  1039f8:	00 
  1039f9:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103a00:	e8 f4 c9 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a08:	89 04 24             	mov    %eax,(%esp)
  103a0b:	e8 1f f1 ff ff       	call   102b2f <page_ref>
  103a10:	85 c0                	test   %eax,%eax
  103a12:	74 24                	je     103a38 <check_pgdir+0x47c>
  103a14:	c7 44 24 0c 9a 69 10 	movl   $0x10699a,0xc(%esp)
  103a1b:	00 
  103a1c:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103a23:	00 
  103a24:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103a2b:	00 
  103a2c:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103a33:	e8 c1 c9 ff ff       	call   1003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a38:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103a3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a44:	00 
  103a45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a4c:	00 
  103a4d:	89 04 24             	mov    %eax,(%esp)
  103a50:	e8 89 f9 ff ff       	call   1033de <get_pte>
  103a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a5c:	75 24                	jne    103a82 <check_pgdir+0x4c6>
  103a5e:	c7 44 24 0c e8 68 10 	movl   $0x1068e8,0xc(%esp)
  103a65:	00 
  103a66:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103a6d:	00 
  103a6e:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103a75:	00 
  103a76:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103a7d:	e8 77 c9 ff ff       	call   1003f9 <__panic>
    assert(pte2page(*ptep) == p1);
  103a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a85:	8b 00                	mov    (%eax),%eax
  103a87:	89 04 24             	mov    %eax,(%esp)
  103a8a:	e8 4a f0 ff ff       	call   102ad9 <pte2page>
  103a8f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103a92:	74 24                	je     103ab8 <check_pgdir+0x4fc>
  103a94:	c7 44 24 0c 5d 68 10 	movl   $0x10685d,0xc(%esp)
  103a9b:	00 
  103a9c:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103aa3:	00 
  103aa4:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103aab:	00 
  103aac:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ab3:	e8 41 c9 ff ff       	call   1003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
  103ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103abb:	8b 00                	mov    (%eax),%eax
  103abd:	83 e0 04             	and    $0x4,%eax
  103ac0:	85 c0                	test   %eax,%eax
  103ac2:	74 24                	je     103ae8 <check_pgdir+0x52c>
  103ac4:	c7 44 24 0c ac 69 10 	movl   $0x1069ac,0xc(%esp)
  103acb:	00 
  103acc:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103ad3:	00 
  103ad4:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103adb:	00 
  103adc:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ae3:	e8 11 c9 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
  103ae8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103aed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103af4:	00 
  103af5:	89 04 24             	mov    %eax,(%esp)
  103af8:	e8 46 f9 ff ff       	call   103443 <page_remove>
    assert(page_ref(p1) == 1);
  103afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b00:	89 04 24             	mov    %eax,(%esp)
  103b03:	e8 27 f0 ff ff       	call   102b2f <page_ref>
  103b08:	83 f8 01             	cmp    $0x1,%eax
  103b0b:	74 24                	je     103b31 <check_pgdir+0x575>
  103b0d:	c7 44 24 0c 73 68 10 	movl   $0x106873,0xc(%esp)
  103b14:	00 
  103b15:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103b24:	00 
  103b25:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103b2c:	e8 c8 c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103b31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b34:	89 04 24             	mov    %eax,(%esp)
  103b37:	e8 f3 ef ff ff       	call   102b2f <page_ref>
  103b3c:	85 c0                	test   %eax,%eax
  103b3e:	74 24                	je     103b64 <check_pgdir+0x5a8>
  103b40:	c7 44 24 0c 9a 69 10 	movl   $0x10699a,0xc(%esp)
  103b47:	00 
  103b48:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103b4f:	00 
  103b50:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103b57:	00 
  103b58:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103b5f:	e8 95 c8 ff ff       	call   1003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103b64:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103b69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b70:	00 
  103b71:	89 04 24             	mov    %eax,(%esp)
  103b74:	e8 ca f8 ff ff       	call   103443 <page_remove>
    assert(page_ref(p1) == 0);
  103b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b7c:	89 04 24             	mov    %eax,(%esp)
  103b7f:	e8 ab ef ff ff       	call   102b2f <page_ref>
  103b84:	85 c0                	test   %eax,%eax
  103b86:	74 24                	je     103bac <check_pgdir+0x5f0>
  103b88:	c7 44 24 0c c1 69 10 	movl   $0x1069c1,0xc(%esp)
  103b8f:	00 
  103b90:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103b97:	00 
  103b98:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  103b9f:	00 
  103ba0:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ba7:	e8 4d c8 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p2) == 0);
  103bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103baf:	89 04 24             	mov    %eax,(%esp)
  103bb2:	e8 78 ef ff ff       	call   102b2f <page_ref>
  103bb7:	85 c0                	test   %eax,%eax
  103bb9:	74 24                	je     103bdf <check_pgdir+0x623>
  103bbb:	c7 44 24 0c 9a 69 10 	movl   $0x10699a,0xc(%esp)
  103bc2:	00 
  103bc3:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103bca:	00 
  103bcb:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103bd2:	00 
  103bd3:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103bda:	e8 1a c8 ff ff       	call   1003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103bdf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103be4:	8b 00                	mov    (%eax),%eax
  103be6:	89 04 24             	mov    %eax,(%esp)
  103be9:	e8 29 ef ff ff       	call   102b17 <pde2page>
  103bee:	89 04 24             	mov    %eax,(%esp)
  103bf1:	e8 39 ef ff ff       	call   102b2f <page_ref>
  103bf6:	83 f8 01             	cmp    $0x1,%eax
  103bf9:	74 24                	je     103c1f <check_pgdir+0x663>
  103bfb:	c7 44 24 0c d4 69 10 	movl   $0x1069d4,0xc(%esp)
  103c02:	00 
  103c03:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103c0a:	00 
  103c0b:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103c12:	00 
  103c13:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103c1a:	e8 da c7 ff ff       	call   1003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103c1f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c24:	8b 00                	mov    (%eax),%eax
  103c26:	89 04 24             	mov    %eax,(%esp)
  103c29:	e8 e9 ee ff ff       	call   102b17 <pde2page>
  103c2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c35:	00 
  103c36:	89 04 24             	mov    %eax,(%esp)
  103c39:	e8 20 f1 ff ff       	call   102d5e <free_pages>
    boot_pgdir[0] = 0;
  103c3e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103c43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c49:	c7 04 24 fb 69 10 00 	movl   $0x1069fb,(%esp)
  103c50:	e8 4d c6 ff ff       	call   1002a2 <cprintf>
}
  103c55:	90                   	nop
  103c56:	c9                   	leave  
  103c57:	c3                   	ret    

00103c58 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103c58:	55                   	push   %ebp
  103c59:	89 e5                	mov    %esp,%ebp
  103c5b:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c65:	e9 ca 00 00 00       	jmp    103d34 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c73:	c1 e8 0c             	shr    $0xc,%eax
  103c76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103c79:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103c7e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103c81:	72 23                	jb     103ca6 <check_boot_pgdir+0x4e>
  103c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c86:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c8a:	c7 44 24 08 40 66 10 	movl   $0x106640,0x8(%esp)
  103c91:	00 
  103c92:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103c99:	00 
  103c9a:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ca1:	e8 53 c7 ff ff       	call   1003f9 <__panic>
  103ca6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ca9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103cae:	89 c2                	mov    %eax,%edx
  103cb0:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103cb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103cbc:	00 
  103cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  103cc1:	89 04 24             	mov    %eax,(%esp)
  103cc4:	e8 15 f7 ff ff       	call   1033de <get_pte>
  103cc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103ccc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103cd0:	75 24                	jne    103cf6 <check_boot_pgdir+0x9e>
  103cd2:	c7 44 24 0c 18 6a 10 	movl   $0x106a18,0xc(%esp)
  103cd9:	00 
  103cda:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103ce1:	00 
  103ce2:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103ce9:	00 
  103cea:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103cf1:	e8 03 c7 ff ff       	call   1003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103cf6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103cf9:	8b 00                	mov    (%eax),%eax
  103cfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d00:	89 c2                	mov    %eax,%edx
  103d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d05:	39 c2                	cmp    %eax,%edx
  103d07:	74 24                	je     103d2d <check_boot_pgdir+0xd5>
  103d09:	c7 44 24 0c 55 6a 10 	movl   $0x106a55,0xc(%esp)
  103d10:	00 
  103d11:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103d18:	00 
  103d19:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103d20:	00 
  103d21:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103d28:	e8 cc c6 ff ff       	call   1003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103d2d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d37:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103d3c:	39 c2                	cmp    %eax,%edx
  103d3e:	0f 82 26 ff ff ff    	jb     103c6a <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d44:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d49:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d4e:	8b 00                	mov    (%eax),%eax
  103d50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d55:	89 c2                	mov    %eax,%edx
  103d57:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d5f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103d66:	77 23                	ja     103d8b <check_boot_pgdir+0x133>
  103d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d6f:	c7 44 24 08 e4 66 10 	movl   $0x1066e4,0x8(%esp)
  103d76:	00 
  103d77:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103d7e:	00 
  103d7f:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103d86:	e8 6e c6 ff ff       	call   1003f9 <__panic>
  103d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d8e:	05 00 00 00 40       	add    $0x40000000,%eax
  103d93:	39 d0                	cmp    %edx,%eax
  103d95:	74 24                	je     103dbb <check_boot_pgdir+0x163>
  103d97:	c7 44 24 0c 6c 6a 10 	movl   $0x106a6c,0xc(%esp)
  103d9e:	00 
  103d9f:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103da6:	00 
  103da7:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103dae:	00 
  103daf:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103db6:	e8 3e c6 ff ff       	call   1003f9 <__panic>

    assert(boot_pgdir[0] == 0);
  103dbb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dc0:	8b 00                	mov    (%eax),%eax
  103dc2:	85 c0                	test   %eax,%eax
  103dc4:	74 24                	je     103dea <check_boot_pgdir+0x192>
  103dc6:	c7 44 24 0c a0 6a 10 	movl   $0x106aa0,0xc(%esp)
  103dcd:	00 
  103dce:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103dd5:	00 
  103dd6:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103ddd:	00 
  103dde:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103de5:	e8 0f c6 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    p = alloc_page();
  103dea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103df1:	e8 30 ef ff ff       	call   102d26 <alloc_pages>
  103df6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103df9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103dfe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e05:	00 
  103e06:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103e0d:	00 
  103e0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e11:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e15:	89 04 24             	mov    %eax,(%esp)
  103e18:	e8 6b f6 ff ff       	call   103488 <page_insert>
  103e1d:	85 c0                	test   %eax,%eax
  103e1f:	74 24                	je     103e45 <check_boot_pgdir+0x1ed>
  103e21:	c7 44 24 0c b4 6a 10 	movl   $0x106ab4,0xc(%esp)
  103e28:	00 
  103e29:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103e30:	00 
  103e31:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103e38:	00 
  103e39:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103e40:	e8 b4 c5 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 1);
  103e45:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103e48:	89 04 24             	mov    %eax,(%esp)
  103e4b:	e8 df ec ff ff       	call   102b2f <page_ref>
  103e50:	83 f8 01             	cmp    $0x1,%eax
  103e53:	74 24                	je     103e79 <check_boot_pgdir+0x221>
  103e55:	c7 44 24 0c e2 6a 10 	movl   $0x106ae2,0xc(%esp)
  103e5c:	00 
  103e5d:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103e64:	00 
  103e65:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103e6c:	00 
  103e6d:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103e74:	e8 80 c5 ff ff       	call   1003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103e79:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103e7e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e85:	00 
  103e86:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103e8d:	00 
  103e8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103e91:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e95:	89 04 24             	mov    %eax,(%esp)
  103e98:	e8 eb f5 ff ff       	call   103488 <page_insert>
  103e9d:	85 c0                	test   %eax,%eax
  103e9f:	74 24                	je     103ec5 <check_boot_pgdir+0x26d>
  103ea1:	c7 44 24 0c f4 6a 10 	movl   $0x106af4,0xc(%esp)
  103ea8:	00 
  103ea9:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103eb0:	00 
  103eb1:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103eb8:	00 
  103eb9:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ec0:	e8 34 c5 ff ff       	call   1003f9 <__panic>
    assert(page_ref(p) == 2);
  103ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103ec8:	89 04 24             	mov    %eax,(%esp)
  103ecb:	e8 5f ec ff ff       	call   102b2f <page_ref>
  103ed0:	83 f8 02             	cmp    $0x2,%eax
  103ed3:	74 24                	je     103ef9 <check_boot_pgdir+0x2a1>
  103ed5:	c7 44 24 0c 2b 6b 10 	movl   $0x106b2b,0xc(%esp)
  103edc:	00 
  103edd:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103ee4:	00 
  103ee5:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  103eec:	00 
  103eed:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103ef4:	e8 00 c5 ff ff       	call   1003f9 <__panic>

    const char *str = "ucore: Hello world!!";
  103ef9:	c7 45 e8 3c 6b 10 00 	movl   $0x106b3c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  103f00:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  103f07:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f0e:	e8 0d 15 00 00       	call   105420 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103f13:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103f1a:	00 
  103f1b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f22:	e8 70 15 00 00       	call   105497 <strcmp>
  103f27:	85 c0                	test   %eax,%eax
  103f29:	74 24                	je     103f4f <check_boot_pgdir+0x2f7>
  103f2b:	c7 44 24 0c 54 6b 10 	movl   $0x106b54,0xc(%esp)
  103f32:	00 
  103f33:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103f3a:	00 
  103f3b:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  103f42:	00 
  103f43:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103f4a:	e8 aa c4 ff ff       	call   1003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103f52:	89 04 24             	mov    %eax,(%esp)
  103f55:	e8 2b eb ff ff       	call   102a85 <page2kva>
  103f5a:	05 00 01 00 00       	add    $0x100,%eax
  103f5f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103f62:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f69:	e8 5c 14 00 00       	call   1053ca <strlen>
  103f6e:	85 c0                	test   %eax,%eax
  103f70:	74 24                	je     103f96 <check_boot_pgdir+0x33e>
  103f72:	c7 44 24 0c 8c 6b 10 	movl   $0x106b8c,0xc(%esp)
  103f79:	00 
  103f7a:	c7 44 24 08 2d 67 10 	movl   $0x10672d,0x8(%esp)
  103f81:	00 
  103f82:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  103f89:	00 
  103f8a:	c7 04 24 08 67 10 00 	movl   $0x106708,(%esp)
  103f91:	e8 63 c4 ff ff       	call   1003f9 <__panic>

    free_page(p);
  103f96:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f9d:	00 
  103f9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103fa1:	89 04 24             	mov    %eax,(%esp)
  103fa4:	e8 b5 ed ff ff       	call   102d5e <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103fa9:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103fae:	8b 00                	mov    (%eax),%eax
  103fb0:	89 04 24             	mov    %eax,(%esp)
  103fb3:	e8 5f eb ff ff       	call   102b17 <pde2page>
  103fb8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fbf:	00 
  103fc0:	89 04 24             	mov    %eax,(%esp)
  103fc3:	e8 96 ed ff ff       	call   102d5e <free_pages>
    boot_pgdir[0] = 0;
  103fc8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  103fcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103fd3:	c7 04 24 b0 6b 10 00 	movl   $0x106bb0,(%esp)
  103fda:	e8 c3 c2 ff ff       	call   1002a2 <cprintf>
}
  103fdf:	90                   	nop
  103fe0:	c9                   	leave  
  103fe1:	c3                   	ret    

00103fe2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103fe2:	55                   	push   %ebp
  103fe3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  103fe8:	83 e0 04             	and    $0x4,%eax
  103feb:	85 c0                	test   %eax,%eax
  103fed:	74 04                	je     103ff3 <perm2str+0x11>
  103fef:	b0 75                	mov    $0x75,%al
  103ff1:	eb 02                	jmp    103ff5 <perm2str+0x13>
  103ff3:	b0 2d                	mov    $0x2d,%al
  103ff5:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  103ffa:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  104001:	8b 45 08             	mov    0x8(%ebp),%eax
  104004:	83 e0 02             	and    $0x2,%eax
  104007:	85 c0                	test   %eax,%eax
  104009:	74 04                	je     10400f <perm2str+0x2d>
  10400b:	b0 77                	mov    $0x77,%al
  10400d:	eb 02                	jmp    104011 <perm2str+0x2f>
  10400f:	b0 2d                	mov    $0x2d,%al
  104011:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  104016:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  10401d:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  104022:	5d                   	pop    %ebp
  104023:	c3                   	ret    

00104024 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104024:	55                   	push   %ebp
  104025:	89 e5                	mov    %esp,%ebp
  104027:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10402a:	8b 45 10             	mov    0x10(%ebp),%eax
  10402d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104030:	72 0d                	jb     10403f <get_pgtable_items+0x1b>
        return 0;
  104032:	b8 00 00 00 00       	mov    $0x0,%eax
  104037:	e9 98 00 00 00       	jmp    1040d4 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  10403c:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  10403f:	8b 45 10             	mov    0x10(%ebp),%eax
  104042:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104045:	73 18                	jae    10405f <get_pgtable_items+0x3b>
  104047:	8b 45 10             	mov    0x10(%ebp),%eax
  10404a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104051:	8b 45 14             	mov    0x14(%ebp),%eax
  104054:	01 d0                	add    %edx,%eax
  104056:	8b 00                	mov    (%eax),%eax
  104058:	83 e0 01             	and    $0x1,%eax
  10405b:	85 c0                	test   %eax,%eax
  10405d:	74 dd                	je     10403c <get_pgtable_items+0x18>
    }
    if (start < right) {
  10405f:	8b 45 10             	mov    0x10(%ebp),%eax
  104062:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104065:	73 68                	jae    1040cf <get_pgtable_items+0xab>
        if (left_store != NULL) {
  104067:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10406b:	74 08                	je     104075 <get_pgtable_items+0x51>
            *left_store = start;
  10406d:	8b 45 18             	mov    0x18(%ebp),%eax
  104070:	8b 55 10             	mov    0x10(%ebp),%edx
  104073:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104075:	8b 45 10             	mov    0x10(%ebp),%eax
  104078:	8d 50 01             	lea    0x1(%eax),%edx
  10407b:	89 55 10             	mov    %edx,0x10(%ebp)
  10407e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104085:	8b 45 14             	mov    0x14(%ebp),%eax
  104088:	01 d0                	add    %edx,%eax
  10408a:	8b 00                	mov    (%eax),%eax
  10408c:	83 e0 07             	and    $0x7,%eax
  10408f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104092:	eb 03                	jmp    104097 <get_pgtable_items+0x73>
            start ++;
  104094:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104097:	8b 45 10             	mov    0x10(%ebp),%eax
  10409a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10409d:	73 1d                	jae    1040bc <get_pgtable_items+0x98>
  10409f:	8b 45 10             	mov    0x10(%ebp),%eax
  1040a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1040a9:	8b 45 14             	mov    0x14(%ebp),%eax
  1040ac:	01 d0                	add    %edx,%eax
  1040ae:	8b 00                	mov    (%eax),%eax
  1040b0:	83 e0 07             	and    $0x7,%eax
  1040b3:	89 c2                	mov    %eax,%edx
  1040b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040b8:	39 c2                	cmp    %eax,%edx
  1040ba:	74 d8                	je     104094 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  1040bc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1040c0:	74 08                	je     1040ca <get_pgtable_items+0xa6>
            *right_store = start;
  1040c2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1040c5:	8b 55 10             	mov    0x10(%ebp),%edx
  1040c8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1040ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1040cd:	eb 05                	jmp    1040d4 <get_pgtable_items+0xb0>
    }
    return 0;
  1040cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1040d4:	c9                   	leave  
  1040d5:	c3                   	ret    

001040d6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1040d6:	55                   	push   %ebp
  1040d7:	89 e5                	mov    %esp,%ebp
  1040d9:	57                   	push   %edi
  1040da:	56                   	push   %esi
  1040db:	53                   	push   %ebx
  1040dc:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1040df:	c7 04 24 d0 6b 10 00 	movl   $0x106bd0,(%esp)
  1040e6:	e8 b7 c1 ff ff       	call   1002a2 <cprintf>
    size_t left, right = 0, perm;
  1040eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1040f2:	e9 fa 00 00 00       	jmp    1041f1 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040fa:	89 04 24             	mov    %eax,(%esp)
  1040fd:	e8 e0 fe ff ff       	call   103fe2 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104102:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104105:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104108:	29 d1                	sub    %edx,%ecx
  10410a:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10410c:	89 d6                	mov    %edx,%esi
  10410e:	c1 e6 16             	shl    $0x16,%esi
  104111:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104114:	89 d3                	mov    %edx,%ebx
  104116:	c1 e3 16             	shl    $0x16,%ebx
  104119:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10411c:	89 d1                	mov    %edx,%ecx
  10411e:	c1 e1 16             	shl    $0x16,%ecx
  104121:	8b 7d dc             	mov    -0x24(%ebp),%edi
  104124:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104127:	29 d7                	sub    %edx,%edi
  104129:	89 fa                	mov    %edi,%edx
  10412b:	89 44 24 14          	mov    %eax,0x14(%esp)
  10412f:	89 74 24 10          	mov    %esi,0x10(%esp)
  104133:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104137:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10413b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10413f:	c7 04 24 01 6c 10 00 	movl   $0x106c01,(%esp)
  104146:	e8 57 c1 ff ff       	call   1002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
  10414b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10414e:	c1 e0 0a             	shl    $0xa,%eax
  104151:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104154:	eb 54                	jmp    1041aa <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104159:	89 04 24             	mov    %eax,(%esp)
  10415c:	e8 81 fe ff ff       	call   103fe2 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104161:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104164:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104167:	29 d1                	sub    %edx,%ecx
  104169:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10416b:	89 d6                	mov    %edx,%esi
  10416d:	c1 e6 0c             	shl    $0xc,%esi
  104170:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104173:	89 d3                	mov    %edx,%ebx
  104175:	c1 e3 0c             	shl    $0xc,%ebx
  104178:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10417b:	89 d1                	mov    %edx,%ecx
  10417d:	c1 e1 0c             	shl    $0xc,%ecx
  104180:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104183:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104186:	29 d7                	sub    %edx,%edi
  104188:	89 fa                	mov    %edi,%edx
  10418a:	89 44 24 14          	mov    %eax,0x14(%esp)
  10418e:	89 74 24 10          	mov    %esi,0x10(%esp)
  104192:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104196:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  10419a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10419e:	c7 04 24 20 6c 10 00 	movl   $0x106c20,(%esp)
  1041a5:	e8 f8 c0 ff ff       	call   1002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1041aa:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1041af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1041b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041b5:	89 d3                	mov    %edx,%ebx
  1041b7:	c1 e3 0a             	shl    $0xa,%ebx
  1041ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1041bd:	89 d1                	mov    %edx,%ecx
  1041bf:	c1 e1 0a             	shl    $0xa,%ecx
  1041c2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  1041c5:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041c9:	8d 55 d8             	lea    -0x28(%ebp),%edx
  1041cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  1041d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041dc:	89 0c 24             	mov    %ecx,(%esp)
  1041df:	e8 40 fe ff ff       	call   104024 <get_pgtable_items>
  1041e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041eb:	0f 85 65 ff ff ff    	jne    104156 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1041f1:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1041f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1041fc:	89 54 24 14          	mov    %edx,0x14(%esp)
  104200:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104203:	89 54 24 10          	mov    %edx,0x10(%esp)
  104207:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10420b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10420f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  104216:	00 
  104217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10421e:	e8 01 fe ff ff       	call   104024 <get_pgtable_items>
  104223:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104226:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10422a:	0f 85 c7 fe ff ff    	jne    1040f7 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104230:	c7 04 24 44 6c 10 00 	movl   $0x106c44,(%esp)
  104237:	e8 66 c0 ff ff       	call   1002a2 <cprintf>
}
  10423c:	90                   	nop
  10423d:	83 c4 4c             	add    $0x4c,%esp
  104240:	5b                   	pop    %ebx
  104241:	5e                   	pop    %esi
  104242:	5f                   	pop    %edi
  104243:	5d                   	pop    %ebp
  104244:	c3                   	ret    

00104245 <page2ppn>:
page2ppn(struct Page *page) {
  104245:	55                   	push   %ebp
  104246:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104248:	8b 45 08             	mov    0x8(%ebp),%eax
  10424b:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  104251:	29 d0                	sub    %edx,%eax
  104253:	c1 f8 02             	sar    $0x2,%eax
  104256:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10425c:	5d                   	pop    %ebp
  10425d:	c3                   	ret    

0010425e <page2pa>:
page2pa(struct Page *page) {
  10425e:	55                   	push   %ebp
  10425f:	89 e5                	mov    %esp,%ebp
  104261:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104264:	8b 45 08             	mov    0x8(%ebp),%eax
  104267:	89 04 24             	mov    %eax,(%esp)
  10426a:	e8 d6 ff ff ff       	call   104245 <page2ppn>
  10426f:	c1 e0 0c             	shl    $0xc,%eax
}
  104272:	c9                   	leave  
  104273:	c3                   	ret    

00104274 <page_ref>:
page_ref(struct Page *page) {
  104274:	55                   	push   %ebp
  104275:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104277:	8b 45 08             	mov    0x8(%ebp),%eax
  10427a:	8b 00                	mov    (%eax),%eax
}
  10427c:	5d                   	pop    %ebp
  10427d:	c3                   	ret    

0010427e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10427e:	55                   	push   %ebp
  10427f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104281:	8b 45 08             	mov    0x8(%ebp),%eax
  104284:	8b 55 0c             	mov    0xc(%ebp),%edx
  104287:	89 10                	mov    %edx,(%eax)
}
  104289:	90                   	nop
  10428a:	5d                   	pop    %ebp
  10428b:	c3                   	ret    

0010428c <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10428c:	55                   	push   %ebp
  10428d:	89 e5                	mov    %esp,%ebp
  10428f:	83 ec 10             	sub    $0x10,%esp
  104292:	c7 45 fc 1c af 11 00 	movl   $0x11af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104299:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10429c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10429f:	89 50 04             	mov    %edx,0x4(%eax)
  1042a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042a5:	8b 50 04             	mov    0x4(%eax),%edx
  1042a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042ab:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1042ad:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  1042b4:	00 00 00 
}
  1042b7:	90                   	nop
  1042b8:	c9                   	leave  
  1042b9:	c3                   	ret    

001042ba <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1042ba:	55                   	push   %ebp
  1042bb:	89 e5                	mov    %esp,%ebp
  1042bd:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  1042c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1042c4:	75 24                	jne    1042ea <default_init_memmap+0x30>
  1042c6:	c7 44 24 0c 78 6c 10 	movl   $0x106c78,0xc(%esp)
  1042cd:	00 
  1042ce:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1042d5:	00 
  1042d6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1042dd:	00 
  1042de:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1042e5:	e8 0f c1 ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  1042ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1042ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1042f0:	eb 7d                	jmp    10436f <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1042f5:	83 c0 04             	add    $0x4,%eax
  1042f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1042ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104302:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104305:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104308:	0f a3 10             	bt     %edx,(%eax)
  10430b:	19 c0                	sbb    %eax,%eax
  10430d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104310:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104314:	0f 95 c0             	setne  %al
  104317:	0f b6 c0             	movzbl %al,%eax
  10431a:	85 c0                	test   %eax,%eax
  10431c:	75 24                	jne    104342 <default_init_memmap+0x88>
  10431e:	c7 44 24 0c a9 6c 10 	movl   $0x106ca9,0xc(%esp)
  104325:	00 
  104326:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  10432d:	00 
  10432e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  104335:	00 
  104336:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  10433d:	e8 b7 c0 ff ff       	call   1003f9 <__panic>
        p->flags = p->property = 0;
  104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104345:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10434f:	8b 50 08             	mov    0x8(%eax),%edx
  104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104355:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  104358:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10435f:	00 
  104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104363:	89 04 24             	mov    %eax,(%esp)
  104366:	e8 13 ff ff ff       	call   10427e <set_page_ref>
    for (; p != base + n; p ++) {
  10436b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10436f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104372:	89 d0                	mov    %edx,%eax
  104374:	c1 e0 02             	shl    $0x2,%eax
  104377:	01 d0                	add    %edx,%eax
  104379:	c1 e0 02             	shl    $0x2,%eax
  10437c:	89 c2                	mov    %eax,%edx
  10437e:	8b 45 08             	mov    0x8(%ebp),%eax
  104381:	01 d0                	add    %edx,%eax
  104383:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104386:	0f 85 66 ff ff ff    	jne    1042f2 <default_init_memmap+0x38>
    }
    base->property = n;
  10438c:	8b 45 08             	mov    0x8(%ebp),%eax
  10438f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104392:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104395:	8b 45 08             	mov    0x8(%ebp),%eax
  104398:	83 c0 04             	add    $0x4,%eax
  10439b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  1043a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1043a8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1043ab:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1043ae:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1043b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1043b7:	01 d0                	add    %edx,%eax
  1043b9:	a3 24 af 11 00       	mov    %eax,0x11af24
    list_add(&free_list, &(base->page_link));
  1043be:	8b 45 08             	mov    0x8(%ebp),%eax
  1043c1:	83 c0 0c             	add    $0xc,%eax
  1043c4:	c7 45 e4 1c af 11 00 	movl   $0x11af1c,-0x1c(%ebp)
  1043cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1043ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1043d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1043d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1043da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043dd:	8b 40 04             	mov    0x4(%eax),%eax
  1043e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1043e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  1043ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043f5:	89 10                	mov    %edx,(%eax)
  1043f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043fa:	8b 10                	mov    (%eax),%edx
  1043fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043ff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104402:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104405:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104408:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10440b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10440e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104411:	89 10                	mov    %edx,(%eax)
}
  104413:	90                   	nop
  104414:	c9                   	leave  
  104415:	c3                   	ret    

00104416 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  104416:	55                   	push   %ebp
  104417:	89 e5                	mov    %esp,%ebp
  104419:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  10441c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104420:	75 24                	jne    104446 <default_alloc_pages+0x30>
  104422:	c7 44 24 0c 78 6c 10 	movl   $0x106c78,0xc(%esp)
  104429:	00 
  10442a:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104431:	00 
  104432:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  104439:	00 
  10443a:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104441:	e8 b3 bf ff ff       	call   1003f9 <__panic>
    if (n > nr_free) {
  104446:	a1 24 af 11 00       	mov    0x11af24,%eax
  10444b:	39 45 08             	cmp    %eax,0x8(%ebp)
  10444e:	76 0a                	jbe    10445a <default_alloc_pages+0x44>
        return NULL;
  104450:	b8 00 00 00 00       	mov    $0x0,%eax
  104455:	e9 2a 01 00 00       	jmp    104584 <default_alloc_pages+0x16e>
    }
    struct Page *page = NULL;
  10445a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104461:	c7 45 f0 1c af 11 00 	movl   $0x11af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104468:	eb 1c                	jmp    104486 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  10446a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10446d:	83 e8 0c             	sub    $0xc,%eax
  104470:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  104473:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104476:	8b 40 08             	mov    0x8(%eax),%eax
  104479:	39 45 08             	cmp    %eax,0x8(%ebp)
  10447c:	77 08                	ja     104486 <default_alloc_pages+0x70>
            page = p;
  10447e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104481:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104484:	eb 18                	jmp    10449e <default_alloc_pages+0x88>
  104486:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104489:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  10448c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10448f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104492:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104495:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  10449c:	75 cc                	jne    10446a <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
  10449e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1044a2:	0f 84 d9 00 00 00    	je     104581 <default_alloc_pages+0x16b>
        list_del(&(page->page_link));
  1044a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044ab:	83 c0 0c             	add    $0xc,%eax
  1044ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
  1044b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044b4:	8b 40 04             	mov    0x4(%eax),%eax
  1044b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1044ba:	8b 12                	mov    (%edx),%edx
  1044bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1044bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1044c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1044c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1044c8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1044cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1044ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044d1:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
  1044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044d6:	8b 40 08             	mov    0x8(%eax),%eax
  1044d9:	39 45 08             	cmp    %eax,0x8(%ebp)
  1044dc:	73 7d                	jae    10455b <default_alloc_pages+0x145>
            struct Page *p = page + n;
  1044de:	8b 55 08             	mov    0x8(%ebp),%edx
  1044e1:	89 d0                	mov    %edx,%eax
  1044e3:	c1 e0 02             	shl    $0x2,%eax
  1044e6:	01 d0                	add    %edx,%eax
  1044e8:	c1 e0 02             	shl    $0x2,%eax
  1044eb:	89 c2                	mov    %eax,%edx
  1044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f0:	01 d0                	add    %edx,%eax
  1044f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  1044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f8:	8b 40 08             	mov    0x8(%eax),%eax
  1044fb:	2b 45 08             	sub    0x8(%ebp),%eax
  1044fe:	89 c2                	mov    %eax,%edx
  104500:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104503:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
  104506:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104509:	83 c0 0c             	add    $0xc,%eax
  10450c:	c7 45 d4 1c af 11 00 	movl   $0x11af1c,-0x2c(%ebp)
  104513:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104516:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104519:	89 45 cc             	mov    %eax,-0x34(%ebp)
  10451c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10451f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
  104522:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104525:	8b 40 04             	mov    0x4(%eax),%eax
  104528:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10452b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  10452e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104531:	89 55 c0             	mov    %edx,-0x40(%ebp)
  104534:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
  104537:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10453a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10453d:	89 10                	mov    %edx,(%eax)
  10453f:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104542:	8b 10                	mov    (%eax),%edx
  104544:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104547:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10454a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10454d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104550:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104553:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104556:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104559:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
  10455b:	a1 24 af 11 00       	mov    0x11af24,%eax
  104560:	2b 45 08             	sub    0x8(%ebp),%eax
  104563:	a3 24 af 11 00       	mov    %eax,0x11af24
        ClearPageProperty(page);
  104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10456b:	83 c0 04             	add    $0x4,%eax
  10456e:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  104575:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104578:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10457b:	8b 55 b8             	mov    -0x48(%ebp),%edx
  10457e:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104584:	c9                   	leave  
  104585:	c3                   	ret    

00104586 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104586:	55                   	push   %ebp
  104587:	89 e5                	mov    %esp,%ebp
  104589:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  10458f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104593:	75 24                	jne    1045b9 <default_free_pages+0x33>
  104595:	c7 44 24 0c 78 6c 10 	movl   $0x106c78,0xc(%esp)
  10459c:	00 
  10459d:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1045a4:	00 
  1045a5:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  1045ac:	00 
  1045ad:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1045b4:	e8 40 be ff ff       	call   1003f9 <__panic>
    struct Page *p = base;
  1045b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1045bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1045bf:	e9 9d 00 00 00       	jmp    104661 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  1045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c7:	83 c0 04             	add    $0x4,%eax
  1045ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1045d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1045d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1045d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1045da:	0f a3 10             	bt     %edx,(%eax)
  1045dd:	19 c0                	sbb    %eax,%eax
  1045df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  1045e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045e6:	0f 95 c0             	setne  %al
  1045e9:	0f b6 c0             	movzbl %al,%eax
  1045ec:	85 c0                	test   %eax,%eax
  1045ee:	75 2c                	jne    10461c <default_free_pages+0x96>
  1045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045f3:	83 c0 04             	add    $0x4,%eax
  1045f6:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  1045fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104600:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104603:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104606:	0f a3 10             	bt     %edx,(%eax)
  104609:	19 c0                	sbb    %eax,%eax
  10460b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10460e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  104612:	0f 95 c0             	setne  %al
  104615:	0f b6 c0             	movzbl %al,%eax
  104618:	85 c0                	test   %eax,%eax
  10461a:	74 24                	je     104640 <default_free_pages+0xba>
  10461c:	c7 44 24 0c bc 6c 10 	movl   $0x106cbc,0xc(%esp)
  104623:	00 
  104624:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  10462b:	00 
  10462c:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  104633:	00 
  104634:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  10463b:	e8 b9 bd ff ff       	call   1003f9 <__panic>
        p->flags = 0;
  104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104643:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  10464a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104651:	00 
  104652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104655:	89 04 24             	mov    %eax,(%esp)
  104658:	e8 21 fc ff ff       	call   10427e <set_page_ref>
    for (; p != base + n; p ++) {
  10465d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104661:	8b 55 0c             	mov    0xc(%ebp),%edx
  104664:	89 d0                	mov    %edx,%eax
  104666:	c1 e0 02             	shl    $0x2,%eax
  104669:	01 d0                	add    %edx,%eax
  10466b:	c1 e0 02             	shl    $0x2,%eax
  10466e:	89 c2                	mov    %eax,%edx
  104670:	8b 45 08             	mov    0x8(%ebp),%eax
  104673:	01 d0                	add    %edx,%eax
  104675:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104678:	0f 85 46 ff ff ff    	jne    1045c4 <default_free_pages+0x3e>
    }
    base->property = n;
  10467e:	8b 45 08             	mov    0x8(%ebp),%eax
  104681:	8b 55 0c             	mov    0xc(%ebp),%edx
  104684:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104687:	8b 45 08             	mov    0x8(%ebp),%eax
  10468a:	83 c0 04             	add    $0x4,%eax
  10468d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104694:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104697:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10469a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10469d:	0f ab 10             	bts    %edx,(%eax)
  1046a0:	c7 45 d4 1c af 11 00 	movl   $0x11af1c,-0x2c(%ebp)
    return listelm->next;
  1046a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1046aa:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  1046ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1046b0:	e9 08 01 00 00       	jmp    1047bd <default_free_pages+0x237>
        p = le2page(le, page_link);
  1046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046b8:	83 e8 0c             	sub    $0xc,%eax
  1046bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1046be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1046c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1046c7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  1046ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  1046cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1046d0:	8b 50 08             	mov    0x8(%eax),%edx
  1046d3:	89 d0                	mov    %edx,%eax
  1046d5:	c1 e0 02             	shl    $0x2,%eax
  1046d8:	01 d0                	add    %edx,%eax
  1046da:	c1 e0 02             	shl    $0x2,%eax
  1046dd:	89 c2                	mov    %eax,%edx
  1046df:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e2:	01 d0                	add    %edx,%eax
  1046e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1046e7:	75 5a                	jne    104743 <default_free_pages+0x1bd>
            base->property += p->property;
  1046e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1046ec:	8b 50 08             	mov    0x8(%eax),%edx
  1046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046f2:	8b 40 08             	mov    0x8(%eax),%eax
  1046f5:	01 c2                	add    %eax,%edx
  1046f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1046fa:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  1046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104700:	83 c0 04             	add    $0x4,%eax
  104703:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  10470a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10470d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104710:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104713:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104719:	83 c0 0c             	add    $0xc,%eax
  10471c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  10471f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104722:	8b 40 04             	mov    0x4(%eax),%eax
  104725:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104728:	8b 12                	mov    (%edx),%edx
  10472a:	89 55 c0             	mov    %edx,-0x40(%ebp)
  10472d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  104730:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104733:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104736:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104739:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10473c:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10473f:	89 10                	mov    %edx,(%eax)
  104741:	eb 7a                	jmp    1047bd <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  104743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104746:	8b 50 08             	mov    0x8(%eax),%edx
  104749:	89 d0                	mov    %edx,%eax
  10474b:	c1 e0 02             	shl    $0x2,%eax
  10474e:	01 d0                	add    %edx,%eax
  104750:	c1 e0 02             	shl    $0x2,%eax
  104753:	89 c2                	mov    %eax,%edx
  104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104758:	01 d0                	add    %edx,%eax
  10475a:	39 45 08             	cmp    %eax,0x8(%ebp)
  10475d:	75 5e                	jne    1047bd <default_free_pages+0x237>
            p->property += base->property;
  10475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104762:	8b 50 08             	mov    0x8(%eax),%edx
  104765:	8b 45 08             	mov    0x8(%ebp),%eax
  104768:	8b 40 08             	mov    0x8(%eax),%eax
  10476b:	01 c2                	add    %eax,%edx
  10476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104770:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104773:	8b 45 08             	mov    0x8(%ebp),%eax
  104776:	83 c0 04             	add    $0x4,%eax
  104779:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  104780:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104783:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104786:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104789:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  10478c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10478f:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104795:	83 c0 0c             	add    $0xc,%eax
  104798:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  10479b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10479e:	8b 40 04             	mov    0x4(%eax),%eax
  1047a1:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1047a4:	8b 12                	mov    (%edx),%edx
  1047a6:	89 55 ac             	mov    %edx,-0x54(%ebp)
  1047a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  1047ac:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1047af:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1047b2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1047b5:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1047b8:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1047bb:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
  1047bd:	81 7d f0 1c af 11 00 	cmpl   $0x11af1c,-0x10(%ebp)
  1047c4:	0f 85 eb fe ff ff    	jne    1046b5 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
  1047ca:	8b 15 24 af 11 00    	mov    0x11af24,%edx
  1047d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047d3:	01 d0                	add    %edx,%eax
  1047d5:	a3 24 af 11 00       	mov    %eax,0x11af24
    list_add(&free_list, &(base->page_link));
  1047da:	8b 45 08             	mov    0x8(%ebp),%eax
  1047dd:	83 c0 0c             	add    $0xc,%eax
  1047e0:	c7 45 9c 1c af 11 00 	movl   $0x11af1c,-0x64(%ebp)
  1047e7:	89 45 98             	mov    %eax,-0x68(%ebp)
  1047ea:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1047ed:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1047f0:	8b 45 98             	mov    -0x68(%ebp),%eax
  1047f3:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm, listelm->next);
  1047f6:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1047f9:	8b 40 04             	mov    0x4(%eax),%eax
  1047fc:	8b 55 90             	mov    -0x70(%ebp),%edx
  1047ff:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104802:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104805:	89 55 88             	mov    %edx,-0x78(%ebp)
  104808:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  10480b:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10480e:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104811:	89 10                	mov    %edx,(%eax)
  104813:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104816:	8b 10                	mov    (%eax),%edx
  104818:	8b 45 88             	mov    -0x78(%ebp),%eax
  10481b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10481e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104821:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104824:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104827:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10482a:	8b 55 88             	mov    -0x78(%ebp),%edx
  10482d:	89 10                	mov    %edx,(%eax)
}
  10482f:	90                   	nop
  104830:	c9                   	leave  
  104831:	c3                   	ret    

00104832 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104832:	55                   	push   %ebp
  104833:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104835:	a1 24 af 11 00       	mov    0x11af24,%eax
}
  10483a:	5d                   	pop    %ebp
  10483b:	c3                   	ret    

0010483c <basic_check>:

static void
basic_check(void) {
  10483c:	55                   	push   %ebp
  10483d:	89 e5                	mov    %esp,%ebp
  10483f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10484c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10484f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104852:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104855:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10485c:	e8 c5 e4 ff ff       	call   102d26 <alloc_pages>
  104861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104864:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104868:	75 24                	jne    10488e <basic_check+0x52>
  10486a:	c7 44 24 0c e1 6c 10 	movl   $0x106ce1,0xc(%esp)
  104871:	00 
  104872:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104879:	00 
  10487a:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
  104881:	00 
  104882:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104889:	e8 6b bb ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10488e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104895:	e8 8c e4 ff ff       	call   102d26 <alloc_pages>
  10489a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10489d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048a1:	75 24                	jne    1048c7 <basic_check+0x8b>
  1048a3:	c7 44 24 0c fd 6c 10 	movl   $0x106cfd,0xc(%esp)
  1048aa:	00 
  1048ab:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1048b2:	00 
  1048b3:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
  1048ba:	00 
  1048bb:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1048c2:	e8 32 bb ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1048c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1048ce:	e8 53 e4 ff ff       	call   102d26 <alloc_pages>
  1048d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1048d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048da:	75 24                	jne    104900 <basic_check+0xc4>
  1048dc:	c7 44 24 0c 19 6d 10 	movl   $0x106d19,0xc(%esp)
  1048e3:	00 
  1048e4:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1048eb:	00 
  1048ec:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
  1048f3:	00 
  1048f4:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1048fb:	e8 f9 ba ff ff       	call   1003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104900:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104903:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104906:	74 10                	je     104918 <basic_check+0xdc>
  104908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10490b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10490e:	74 08                	je     104918 <basic_check+0xdc>
  104910:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104913:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104916:	75 24                	jne    10493c <basic_check+0x100>
  104918:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  10491f:	00 
  104920:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104927:	00 
  104928:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  10492f:	00 
  104930:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104937:	e8 bd ba ff ff       	call   1003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10493c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10493f:	89 04 24             	mov    %eax,(%esp)
  104942:	e8 2d f9 ff ff       	call   104274 <page_ref>
  104947:	85 c0                	test   %eax,%eax
  104949:	75 1e                	jne    104969 <basic_check+0x12d>
  10494b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10494e:	89 04 24             	mov    %eax,(%esp)
  104951:	e8 1e f9 ff ff       	call   104274 <page_ref>
  104956:	85 c0                	test   %eax,%eax
  104958:	75 0f                	jne    104969 <basic_check+0x12d>
  10495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10495d:	89 04 24             	mov    %eax,(%esp)
  104960:	e8 0f f9 ff ff       	call   104274 <page_ref>
  104965:	85 c0                	test   %eax,%eax
  104967:	74 24                	je     10498d <basic_check+0x151>
  104969:	c7 44 24 0c 5c 6d 10 	movl   $0x106d5c,0xc(%esp)
  104970:	00 
  104971:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104978:	00 
  104979:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
  104980:	00 
  104981:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104988:	e8 6c ba ff ff       	call   1003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  10498d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104990:	89 04 24             	mov    %eax,(%esp)
  104993:	e8 c6 f8 ff ff       	call   10425e <page2pa>
  104998:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  10499e:	c1 e2 0c             	shl    $0xc,%edx
  1049a1:	39 d0                	cmp    %edx,%eax
  1049a3:	72 24                	jb     1049c9 <basic_check+0x18d>
  1049a5:	c7 44 24 0c 98 6d 10 	movl   $0x106d98,0xc(%esp)
  1049ac:	00 
  1049ad:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1049b4:	00 
  1049b5:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
  1049bc:	00 
  1049bd:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1049c4:	e8 30 ba ff ff       	call   1003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1049c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049cc:	89 04 24             	mov    %eax,(%esp)
  1049cf:	e8 8a f8 ff ff       	call   10425e <page2pa>
  1049d4:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1049da:	c1 e2 0c             	shl    $0xc,%edx
  1049dd:	39 d0                	cmp    %edx,%eax
  1049df:	72 24                	jb     104a05 <basic_check+0x1c9>
  1049e1:	c7 44 24 0c b5 6d 10 	movl   $0x106db5,0xc(%esp)
  1049e8:	00 
  1049e9:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1049f0:	00 
  1049f1:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
  1049f8:	00 
  1049f9:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104a00:	e8 f4 b9 ff ff       	call   1003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a08:	89 04 24             	mov    %eax,(%esp)
  104a0b:	e8 4e f8 ff ff       	call   10425e <page2pa>
  104a10:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104a16:	c1 e2 0c             	shl    $0xc,%edx
  104a19:	39 d0                	cmp    %edx,%eax
  104a1b:	72 24                	jb     104a41 <basic_check+0x205>
  104a1d:	c7 44 24 0c d2 6d 10 	movl   $0x106dd2,0xc(%esp)
  104a24:	00 
  104a25:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104a2c:	00 
  104a2d:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  104a34:	00 
  104a35:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104a3c:	e8 b8 b9 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  104a41:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104a46:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104a4f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104a52:	c7 45 dc 1c af 11 00 	movl   $0x11af1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104a59:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104a5f:	89 50 04             	mov    %edx,0x4(%eax)
  104a62:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a65:	8b 50 04             	mov    0x4(%eax),%edx
  104a68:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104a6b:	89 10                	mov    %edx,(%eax)
  104a6d:	c7 45 e0 1c af 11 00 	movl   $0x11af1c,-0x20(%ebp)
    return list->next == list;
  104a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a77:	8b 40 04             	mov    0x4(%eax),%eax
  104a7a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104a7d:	0f 94 c0             	sete   %al
  104a80:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104a83:	85 c0                	test   %eax,%eax
  104a85:	75 24                	jne    104aab <basic_check+0x26f>
  104a87:	c7 44 24 0c ef 6d 10 	movl   $0x106def,0xc(%esp)
  104a8e:	00 
  104a8f:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104a96:	00 
  104a97:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  104a9e:	00 
  104a9f:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104aa6:	e8 4e b9 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  104aab:	a1 24 af 11 00       	mov    0x11af24,%eax
  104ab0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104ab3:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104aba:	00 00 00 

    assert(alloc_page() == NULL);
  104abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ac4:	e8 5d e2 ff ff       	call   102d26 <alloc_pages>
  104ac9:	85 c0                	test   %eax,%eax
  104acb:	74 24                	je     104af1 <basic_check+0x2b5>
  104acd:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104ad4:	00 
  104ad5:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104adc:	00 
  104add:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  104ae4:	00 
  104ae5:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104aec:	e8 08 b9 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104af1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104af8:	00 
  104af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104afc:	89 04 24             	mov    %eax,(%esp)
  104aff:	e8 5a e2 ff ff       	call   102d5e <free_pages>
    free_page(p1);
  104b04:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b0b:	00 
  104b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b0f:	89 04 24             	mov    %eax,(%esp)
  104b12:	e8 47 e2 ff ff       	call   102d5e <free_pages>
    free_page(p2);
  104b17:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104b1e:	00 
  104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b22:	89 04 24             	mov    %eax,(%esp)
  104b25:	e8 34 e2 ff ff       	call   102d5e <free_pages>
    assert(nr_free == 3);
  104b2a:	a1 24 af 11 00       	mov    0x11af24,%eax
  104b2f:	83 f8 03             	cmp    $0x3,%eax
  104b32:	74 24                	je     104b58 <basic_check+0x31c>
  104b34:	c7 44 24 0c 1b 6e 10 	movl   $0x106e1b,0xc(%esp)
  104b3b:	00 
  104b3c:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104b43:	00 
  104b44:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  104b4b:	00 
  104b4c:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104b53:	e8 a1 b8 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104b58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b5f:	e8 c2 e1 ff ff       	call   102d26 <alloc_pages>
  104b64:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104b67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104b6b:	75 24                	jne    104b91 <basic_check+0x355>
  104b6d:	c7 44 24 0c e1 6c 10 	movl   $0x106ce1,0xc(%esp)
  104b74:	00 
  104b75:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104b7c:	00 
  104b7d:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  104b84:	00 
  104b85:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104b8c:	e8 68 b8 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104b91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b98:	e8 89 e1 ff ff       	call   102d26 <alloc_pages>
  104b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ba0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ba4:	75 24                	jne    104bca <basic_check+0x38e>
  104ba6:	c7 44 24 0c fd 6c 10 	movl   $0x106cfd,0xc(%esp)
  104bad:	00 
  104bae:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104bb5:	00 
  104bb6:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  104bbd:	00 
  104bbe:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104bc5:	e8 2f b8 ff ff       	call   1003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104bca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bd1:	e8 50 e1 ff ff       	call   102d26 <alloc_pages>
  104bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104bd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104bdd:	75 24                	jne    104c03 <basic_check+0x3c7>
  104bdf:	c7 44 24 0c 19 6d 10 	movl   $0x106d19,0xc(%esp)
  104be6:	00 
  104be7:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104bee:	00 
  104bef:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  104bf6:	00 
  104bf7:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104bfe:	e8 f6 b7 ff ff       	call   1003f9 <__panic>

    assert(alloc_page() == NULL);
  104c03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c0a:	e8 17 e1 ff ff       	call   102d26 <alloc_pages>
  104c0f:	85 c0                	test   %eax,%eax
  104c11:	74 24                	je     104c37 <basic_check+0x3fb>
  104c13:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104c1a:	00 
  104c1b:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104c22:	00 
  104c23:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  104c2a:	00 
  104c2b:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104c32:	e8 c2 b7 ff ff       	call   1003f9 <__panic>

    free_page(p0);
  104c37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104c3e:	00 
  104c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c42:	89 04 24             	mov    %eax,(%esp)
  104c45:	e8 14 e1 ff ff       	call   102d5e <free_pages>
  104c4a:	c7 45 d8 1c af 11 00 	movl   $0x11af1c,-0x28(%ebp)
  104c51:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c54:	8b 40 04             	mov    0x4(%eax),%eax
  104c57:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104c5a:	0f 94 c0             	sete   %al
  104c5d:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104c60:	85 c0                	test   %eax,%eax
  104c62:	74 24                	je     104c88 <basic_check+0x44c>
  104c64:	c7 44 24 0c 28 6e 10 	movl   $0x106e28,0xc(%esp)
  104c6b:	00 
  104c6c:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104c73:	00 
  104c74:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
  104c7b:	00 
  104c7c:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104c83:	e8 71 b7 ff ff       	call   1003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104c88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c8f:	e8 92 e0 ff ff       	call   102d26 <alloc_pages>
  104c94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c9a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104c9d:	74 24                	je     104cc3 <basic_check+0x487>
  104c9f:	c7 44 24 0c 40 6e 10 	movl   $0x106e40,0xc(%esp)
  104ca6:	00 
  104ca7:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104cae:	00 
  104caf:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  104cb6:	00 
  104cb7:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104cbe:	e8 36 b7 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  104cc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cca:	e8 57 e0 ff ff       	call   102d26 <alloc_pages>
  104ccf:	85 c0                	test   %eax,%eax
  104cd1:	74 24                	je     104cf7 <basic_check+0x4bb>
  104cd3:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104cda:	00 
  104cdb:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104ce2:	00 
  104ce3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  104cea:	00 
  104ceb:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104cf2:	e8 02 b7 ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  104cf7:	a1 24 af 11 00       	mov    0x11af24,%eax
  104cfc:	85 c0                	test   %eax,%eax
  104cfe:	74 24                	je     104d24 <basic_check+0x4e8>
  104d00:	c7 44 24 0c 59 6e 10 	movl   $0x106e59,0xc(%esp)
  104d07:	00 
  104d08:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104d0f:	00 
  104d10:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  104d17:	00 
  104d18:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104d1f:	e8 d5 b6 ff ff       	call   1003f9 <__panic>
    free_list = free_list_store;
  104d24:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104d27:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104d2a:	a3 1c af 11 00       	mov    %eax,0x11af1c
  104d2f:	89 15 20 af 11 00    	mov    %edx,0x11af20
    nr_free = nr_free_store;
  104d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d38:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_page(p);
  104d3d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d44:	00 
  104d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d48:	89 04 24             	mov    %eax,(%esp)
  104d4b:	e8 0e e0 ff ff       	call   102d5e <free_pages>
    free_page(p1);
  104d50:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d57:	00 
  104d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d5b:	89 04 24             	mov    %eax,(%esp)
  104d5e:	e8 fb df ff ff       	call   102d5e <free_pages>
    free_page(p2);
  104d63:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d6a:	00 
  104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d6e:	89 04 24             	mov    %eax,(%esp)
  104d71:	e8 e8 df ff ff       	call   102d5e <free_pages>
}
  104d76:	90                   	nop
  104d77:	c9                   	leave  
  104d78:	c3                   	ret    

00104d79 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  104d79:	55                   	push   %ebp
  104d7a:	89 e5                	mov    %esp,%ebp
  104d7c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  104d82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104d89:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  104d90:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  104d97:	eb 6a                	jmp    104e03 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  104d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d9c:	83 e8 0c             	sub    $0xc,%eax
  104d9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  104da2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104da5:	83 c0 04             	add    $0x4,%eax
  104da8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  104daf:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104db2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104db5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104db8:	0f a3 10             	bt     %edx,(%eax)
  104dbb:	19 c0                	sbb    %eax,%eax
  104dbd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  104dc0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  104dc4:	0f 95 c0             	setne  %al
  104dc7:	0f b6 c0             	movzbl %al,%eax
  104dca:	85 c0                	test   %eax,%eax
  104dcc:	75 24                	jne    104df2 <default_check+0x79>
  104dce:	c7 44 24 0c 66 6e 10 	movl   $0x106e66,0xc(%esp)
  104dd5:	00 
  104dd6:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104ddd:	00 
  104dde:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  104de5:	00 
  104de6:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104ded:	e8 07 b6 ff ff       	call   1003f9 <__panic>
        count ++, total += p->property;
  104df2:	ff 45 f4             	incl   -0xc(%ebp)
  104df5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104df8:	8b 50 08             	mov    0x8(%eax),%edx
  104dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dfe:	01 d0                	add    %edx,%eax
  104e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e06:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  104e09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104e0c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104e0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e12:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  104e19:	0f 85 7a ff ff ff    	jne    104d99 <default_check+0x20>
    }
    assert(total == nr_free_pages());
  104e1f:	e8 6d df ff ff       	call   102d91 <nr_free_pages>
  104e24:	89 c2                	mov    %eax,%edx
  104e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e29:	39 c2                	cmp    %eax,%edx
  104e2b:	74 24                	je     104e51 <default_check+0xd8>
  104e2d:	c7 44 24 0c 76 6e 10 	movl   $0x106e76,0xc(%esp)
  104e34:	00 
  104e35:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104e3c:	00 
  104e3d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104e44:	00 
  104e45:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104e4c:	e8 a8 b5 ff ff       	call   1003f9 <__panic>

    basic_check();
  104e51:	e8 e6 f9 ff ff       	call   10483c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  104e56:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  104e5d:	e8 c4 de ff ff       	call   102d26 <alloc_pages>
  104e62:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  104e65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104e69:	75 24                	jne    104e8f <default_check+0x116>
  104e6b:	c7 44 24 0c 8f 6e 10 	movl   $0x106e8f,0xc(%esp)
  104e72:	00 
  104e73:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104e7a:	00 
  104e7b:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
  104e82:	00 
  104e83:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104e8a:	e8 6a b5 ff ff       	call   1003f9 <__panic>
    assert(!PageProperty(p0));
  104e8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e92:	83 c0 04             	add    $0x4,%eax
  104e95:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104e9c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104e9f:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104ea2:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104ea5:	0f a3 10             	bt     %edx,(%eax)
  104ea8:	19 c0                	sbb    %eax,%eax
  104eaa:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104ead:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104eb1:	0f 95 c0             	setne  %al
  104eb4:	0f b6 c0             	movzbl %al,%eax
  104eb7:	85 c0                	test   %eax,%eax
  104eb9:	74 24                	je     104edf <default_check+0x166>
  104ebb:	c7 44 24 0c 9a 6e 10 	movl   $0x106e9a,0xc(%esp)
  104ec2:	00 
  104ec3:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104eca:	00 
  104ecb:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  104ed2:	00 
  104ed3:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104eda:	e8 1a b5 ff ff       	call   1003f9 <__panic>

    list_entry_t free_list_store = free_list;
  104edf:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104ee4:	8b 15 20 af 11 00    	mov    0x11af20,%edx
  104eea:	89 45 80             	mov    %eax,-0x80(%ebp)
  104eed:	89 55 84             	mov    %edx,-0x7c(%ebp)
  104ef0:	c7 45 b0 1c af 11 00 	movl   $0x11af1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  104ef7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104efa:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104efd:	89 50 04             	mov    %edx,0x4(%eax)
  104f00:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f03:	8b 50 04             	mov    0x4(%eax),%edx
  104f06:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104f09:	89 10                	mov    %edx,(%eax)
  104f0b:	c7 45 b4 1c af 11 00 	movl   $0x11af1c,-0x4c(%ebp)
    return list->next == list;
  104f12:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104f15:	8b 40 04             	mov    0x4(%eax),%eax
  104f18:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  104f1b:	0f 94 c0             	sete   %al
  104f1e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104f21:	85 c0                	test   %eax,%eax
  104f23:	75 24                	jne    104f49 <default_check+0x1d0>
  104f25:	c7 44 24 0c ef 6d 10 	movl   $0x106def,0xc(%esp)
  104f2c:	00 
  104f2d:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104f34:	00 
  104f35:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  104f3c:	00 
  104f3d:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104f44:	e8 b0 b4 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  104f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f50:	e8 d1 dd ff ff       	call   102d26 <alloc_pages>
  104f55:	85 c0                	test   %eax,%eax
  104f57:	74 24                	je     104f7d <default_check+0x204>
  104f59:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104f60:	00 
  104f61:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104f68:	00 
  104f69:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  104f70:	00 
  104f71:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104f78:	e8 7c b4 ff ff       	call   1003f9 <__panic>

    unsigned int nr_free_store = nr_free;
  104f7d:	a1 24 af 11 00       	mov    0x11af24,%eax
  104f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  104f85:	c7 05 24 af 11 00 00 	movl   $0x0,0x11af24
  104f8c:	00 00 00 

    free_pages(p0 + 2, 3);
  104f8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f92:	83 c0 28             	add    $0x28,%eax
  104f95:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  104f9c:	00 
  104f9d:	89 04 24             	mov    %eax,(%esp)
  104fa0:	e8 b9 dd ff ff       	call   102d5e <free_pages>
    assert(alloc_pages(4) == NULL);
  104fa5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  104fac:	e8 75 dd ff ff       	call   102d26 <alloc_pages>
  104fb1:	85 c0                	test   %eax,%eax
  104fb3:	74 24                	je     104fd9 <default_check+0x260>
  104fb5:	c7 44 24 0c ac 6e 10 	movl   $0x106eac,0xc(%esp)
  104fbc:	00 
  104fbd:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  104fc4:	00 
  104fc5:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  104fcc:	00 
  104fcd:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  104fd4:	e8 20 b4 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  104fd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104fdc:	83 c0 28             	add    $0x28,%eax
  104fdf:	83 c0 04             	add    $0x4,%eax
  104fe2:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  104fe9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104fec:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104fef:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104ff2:	0f a3 10             	bt     %edx,(%eax)
  104ff5:	19 c0                	sbb    %eax,%eax
  104ff7:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  104ffa:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  104ffe:	0f 95 c0             	setne  %al
  105001:	0f b6 c0             	movzbl %al,%eax
  105004:	85 c0                	test   %eax,%eax
  105006:	74 0e                	je     105016 <default_check+0x29d>
  105008:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10500b:	83 c0 28             	add    $0x28,%eax
  10500e:	8b 40 08             	mov    0x8(%eax),%eax
  105011:	83 f8 03             	cmp    $0x3,%eax
  105014:	74 24                	je     10503a <default_check+0x2c1>
  105016:	c7 44 24 0c c4 6e 10 	movl   $0x106ec4,0xc(%esp)
  10501d:	00 
  10501e:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  105025:	00 
  105026:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  10502d:	00 
  10502e:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  105035:	e8 bf b3 ff ff       	call   1003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10503a:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105041:	e8 e0 dc ff ff       	call   102d26 <alloc_pages>
  105046:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105049:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10504d:	75 24                	jne    105073 <default_check+0x2fa>
  10504f:	c7 44 24 0c f0 6e 10 	movl   $0x106ef0,0xc(%esp)
  105056:	00 
  105057:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  10505e:	00 
  10505f:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  105066:	00 
  105067:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  10506e:	e8 86 b3 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  105073:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10507a:	e8 a7 dc ff ff       	call   102d26 <alloc_pages>
  10507f:	85 c0                	test   %eax,%eax
  105081:	74 24                	je     1050a7 <default_check+0x32e>
  105083:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  10508a:	00 
  10508b:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  105092:	00 
  105093:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10509a:	00 
  10509b:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1050a2:	e8 52 b3 ff ff       	call   1003f9 <__panic>
    assert(p0 + 2 == p1);
  1050a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050aa:	83 c0 28             	add    $0x28,%eax
  1050ad:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1050b0:	74 24                	je     1050d6 <default_check+0x35d>
  1050b2:	c7 44 24 0c 0e 6f 10 	movl   $0x106f0e,0xc(%esp)
  1050b9:	00 
  1050ba:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1050c1:	00 
  1050c2:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  1050c9:	00 
  1050ca:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1050d1:	e8 23 b3 ff ff       	call   1003f9 <__panic>

    p2 = p0 + 1;
  1050d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050d9:	83 c0 14             	add    $0x14,%eax
  1050dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1050df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050e6:	00 
  1050e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1050ea:	89 04 24             	mov    %eax,(%esp)
  1050ed:	e8 6c dc ff ff       	call   102d5e <free_pages>
    free_pages(p1, 3);
  1050f2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1050f9:	00 
  1050fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050fd:	89 04 24             	mov    %eax,(%esp)
  105100:	e8 59 dc ff ff       	call   102d5e <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105105:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105108:	83 c0 04             	add    $0x4,%eax
  10510b:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  105112:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105115:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105118:	8b 55 a0             	mov    -0x60(%ebp),%edx
  10511b:	0f a3 10             	bt     %edx,(%eax)
  10511e:	19 c0                	sbb    %eax,%eax
  105120:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105123:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105127:	0f 95 c0             	setne  %al
  10512a:	0f b6 c0             	movzbl %al,%eax
  10512d:	85 c0                	test   %eax,%eax
  10512f:	74 0b                	je     10513c <default_check+0x3c3>
  105131:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105134:	8b 40 08             	mov    0x8(%eax),%eax
  105137:	83 f8 01             	cmp    $0x1,%eax
  10513a:	74 24                	je     105160 <default_check+0x3e7>
  10513c:	c7 44 24 0c 1c 6f 10 	movl   $0x106f1c,0xc(%esp)
  105143:	00 
  105144:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  10514b:	00 
  10514c:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  105153:	00 
  105154:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  10515b:	e8 99 b2 ff ff       	call   1003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105160:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105163:	83 c0 04             	add    $0x4,%eax
  105166:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10516d:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105170:	8b 45 90             	mov    -0x70(%ebp),%eax
  105173:	8b 55 94             	mov    -0x6c(%ebp),%edx
  105176:	0f a3 10             	bt     %edx,(%eax)
  105179:	19 c0                	sbb    %eax,%eax
  10517b:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  10517e:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105182:	0f 95 c0             	setne  %al
  105185:	0f b6 c0             	movzbl %al,%eax
  105188:	85 c0                	test   %eax,%eax
  10518a:	74 0b                	je     105197 <default_check+0x41e>
  10518c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10518f:	8b 40 08             	mov    0x8(%eax),%eax
  105192:	83 f8 03             	cmp    $0x3,%eax
  105195:	74 24                	je     1051bb <default_check+0x442>
  105197:	c7 44 24 0c 44 6f 10 	movl   $0x106f44,0xc(%esp)
  10519e:	00 
  10519f:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1051a6:	00 
  1051a7:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1051ae:	00 
  1051af:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1051b6:	e8 3e b2 ff ff       	call   1003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  1051bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051c2:	e8 5f db ff ff       	call   102d26 <alloc_pages>
  1051c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1051ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051cd:	83 e8 14             	sub    $0x14,%eax
  1051d0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1051d3:	74 24                	je     1051f9 <default_check+0x480>
  1051d5:	c7 44 24 0c 6a 6f 10 	movl   $0x106f6a,0xc(%esp)
  1051dc:	00 
  1051dd:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1051e4:	00 
  1051e5:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1051ec:	00 
  1051ed:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1051f4:	e8 00 b2 ff ff       	call   1003f9 <__panic>
    free_page(p0);
  1051f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105200:	00 
  105201:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105204:	89 04 24             	mov    %eax,(%esp)
  105207:	e8 52 db ff ff       	call   102d5e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10520c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105213:	e8 0e db ff ff       	call   102d26 <alloc_pages>
  105218:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10521b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10521e:	83 c0 14             	add    $0x14,%eax
  105221:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105224:	74 24                	je     10524a <default_check+0x4d1>
  105226:	c7 44 24 0c 88 6f 10 	movl   $0x106f88,0xc(%esp)
  10522d:	00 
  10522e:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  105235:	00 
  105236:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  10523d:	00 
  10523e:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  105245:	e8 af b1 ff ff       	call   1003f9 <__panic>

    free_pages(p0, 2);
  10524a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105251:	00 
  105252:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105255:	89 04 24             	mov    %eax,(%esp)
  105258:	e8 01 db ff ff       	call   102d5e <free_pages>
    free_page(p2);
  10525d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105264:	00 
  105265:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105268:	89 04 24             	mov    %eax,(%esp)
  10526b:	e8 ee da ff ff       	call   102d5e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105270:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105277:	e8 aa da ff ff       	call   102d26 <alloc_pages>
  10527c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10527f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105283:	75 24                	jne    1052a9 <default_check+0x530>
  105285:	c7 44 24 0c a8 6f 10 	movl   $0x106fa8,0xc(%esp)
  10528c:	00 
  10528d:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  105294:	00 
  105295:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  10529c:	00 
  10529d:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1052a4:	e8 50 b1 ff ff       	call   1003f9 <__panic>
    assert(alloc_page() == NULL);
  1052a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1052b0:	e8 71 da ff ff       	call   102d26 <alloc_pages>
  1052b5:	85 c0                	test   %eax,%eax
  1052b7:	74 24                	je     1052dd <default_check+0x564>
  1052b9:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  1052c0:	00 
  1052c1:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1052c8:	00 
  1052c9:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1052d0:	00 
  1052d1:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1052d8:	e8 1c b1 ff ff       	call   1003f9 <__panic>

    assert(nr_free == 0);
  1052dd:	a1 24 af 11 00       	mov    0x11af24,%eax
  1052e2:	85 c0                	test   %eax,%eax
  1052e4:	74 24                	je     10530a <default_check+0x591>
  1052e6:	c7 44 24 0c 59 6e 10 	movl   $0x106e59,0xc(%esp)
  1052ed:	00 
  1052ee:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1052f5:	00 
  1052f6:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  1052fd:	00 
  1052fe:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  105305:	e8 ef b0 ff ff       	call   1003f9 <__panic>
    nr_free = nr_free_store;
  10530a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10530d:	a3 24 af 11 00       	mov    %eax,0x11af24

    free_list = free_list_store;
  105312:	8b 45 80             	mov    -0x80(%ebp),%eax
  105315:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105318:	a3 1c af 11 00       	mov    %eax,0x11af1c
  10531d:	89 15 20 af 11 00    	mov    %edx,0x11af20
    free_pages(p0, 5);
  105323:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10532a:	00 
  10532b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10532e:	89 04 24             	mov    %eax,(%esp)
  105331:	e8 28 da ff ff       	call   102d5e <free_pages>

    le = &free_list;
  105336:	c7 45 ec 1c af 11 00 	movl   $0x11af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10533d:	eb 1c                	jmp    10535b <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
  10533f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105342:	83 e8 0c             	sub    $0xc,%eax
  105345:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105348:	ff 4d f4             	decl   -0xc(%ebp)
  10534b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10534e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105351:	8b 40 08             	mov    0x8(%eax),%eax
  105354:	29 c2                	sub    %eax,%edx
  105356:	89 d0                	mov    %edx,%eax
  105358:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10535b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10535e:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105361:	8b 45 88             	mov    -0x78(%ebp),%eax
  105364:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105367:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10536a:	81 7d ec 1c af 11 00 	cmpl   $0x11af1c,-0x14(%ebp)
  105371:	75 cc                	jne    10533f <default_check+0x5c6>
    }
    assert(count == 0);
  105373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105377:	74 24                	je     10539d <default_check+0x624>
  105379:	c7 44 24 0c c6 6f 10 	movl   $0x106fc6,0xc(%esp)
  105380:	00 
  105381:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  105388:	00 
  105389:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  105390:	00 
  105391:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  105398:	e8 5c b0 ff ff       	call   1003f9 <__panic>
    assert(total == 0);
  10539d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1053a1:	74 24                	je     1053c7 <default_check+0x64e>
  1053a3:	c7 44 24 0c d1 6f 10 	movl   $0x106fd1,0xc(%esp)
  1053aa:	00 
  1053ab:	c7 44 24 08 7e 6c 10 	movl   $0x106c7e,0x8(%esp)
  1053b2:	00 
  1053b3:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  1053ba:	00 
  1053bb:	c7 04 24 93 6c 10 00 	movl   $0x106c93,(%esp)
  1053c2:	e8 32 b0 ff ff       	call   1003f9 <__panic>
}
  1053c7:	90                   	nop
  1053c8:	c9                   	leave  
  1053c9:	c3                   	ret    

001053ca <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1053ca:	55                   	push   %ebp
  1053cb:	89 e5                	mov    %esp,%ebp
  1053cd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1053d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  1053d7:	eb 03                	jmp    1053dc <strlen+0x12>
        cnt ++;
  1053d9:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1053dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1053df:	8d 50 01             	lea    0x1(%eax),%edx
  1053e2:	89 55 08             	mov    %edx,0x8(%ebp)
  1053e5:	0f b6 00             	movzbl (%eax),%eax
  1053e8:	84 c0                	test   %al,%al
  1053ea:	75 ed                	jne    1053d9 <strlen+0xf>
    }
    return cnt;
  1053ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1053ef:	c9                   	leave  
  1053f0:	c3                   	ret    

001053f1 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1053f1:	55                   	push   %ebp
  1053f2:	89 e5                	mov    %esp,%ebp
  1053f4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1053f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1053fe:	eb 03                	jmp    105403 <strnlen+0x12>
        cnt ++;
  105400:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105403:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105406:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105409:	73 10                	jae    10541b <strnlen+0x2a>
  10540b:	8b 45 08             	mov    0x8(%ebp),%eax
  10540e:	8d 50 01             	lea    0x1(%eax),%edx
  105411:	89 55 08             	mov    %edx,0x8(%ebp)
  105414:	0f b6 00             	movzbl (%eax),%eax
  105417:	84 c0                	test   %al,%al
  105419:	75 e5                	jne    105400 <strnlen+0xf>
    }
    return cnt;
  10541b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10541e:	c9                   	leave  
  10541f:	c3                   	ret    

00105420 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105420:	55                   	push   %ebp
  105421:	89 e5                	mov    %esp,%ebp
  105423:	57                   	push   %edi
  105424:	56                   	push   %esi
  105425:	83 ec 20             	sub    $0x20,%esp
  105428:	8b 45 08             	mov    0x8(%ebp),%eax
  10542b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10542e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105431:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105434:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10543a:	89 d1                	mov    %edx,%ecx
  10543c:	89 c2                	mov    %eax,%edx
  10543e:	89 ce                	mov    %ecx,%esi
  105440:	89 d7                	mov    %edx,%edi
  105442:	ac                   	lods   %ds:(%esi),%al
  105443:	aa                   	stos   %al,%es:(%edi)
  105444:	84 c0                	test   %al,%al
  105446:	75 fa                	jne    105442 <strcpy+0x22>
  105448:	89 fa                	mov    %edi,%edx
  10544a:	89 f1                	mov    %esi,%ecx
  10544c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10544f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105452:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105455:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  105458:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105459:	83 c4 20             	add    $0x20,%esp
  10545c:	5e                   	pop    %esi
  10545d:	5f                   	pop    %edi
  10545e:	5d                   	pop    %ebp
  10545f:	c3                   	ret    

00105460 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105460:	55                   	push   %ebp
  105461:	89 e5                	mov    %esp,%ebp
  105463:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105466:	8b 45 08             	mov    0x8(%ebp),%eax
  105469:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10546c:	eb 1e                	jmp    10548c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  10546e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105471:	0f b6 10             	movzbl (%eax),%edx
  105474:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105477:	88 10                	mov    %dl,(%eax)
  105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10547c:	0f b6 00             	movzbl (%eax),%eax
  10547f:	84 c0                	test   %al,%al
  105481:	74 03                	je     105486 <strncpy+0x26>
            src ++;
  105483:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105486:	ff 45 fc             	incl   -0x4(%ebp)
  105489:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10548c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105490:	75 dc                	jne    10546e <strncpy+0xe>
    }
    return dst;
  105492:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105495:	c9                   	leave  
  105496:	c3                   	ret    

00105497 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105497:	55                   	push   %ebp
  105498:	89 e5                	mov    %esp,%ebp
  10549a:	57                   	push   %edi
  10549b:	56                   	push   %esi
  10549c:	83 ec 20             	sub    $0x20,%esp
  10549f:	8b 45 08             	mov    0x8(%ebp),%eax
  1054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1054a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1054a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1054ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1054b1:	89 d1                	mov    %edx,%ecx
  1054b3:	89 c2                	mov    %eax,%edx
  1054b5:	89 ce                	mov    %ecx,%esi
  1054b7:	89 d7                	mov    %edx,%edi
  1054b9:	ac                   	lods   %ds:(%esi),%al
  1054ba:	ae                   	scas   %es:(%edi),%al
  1054bb:	75 08                	jne    1054c5 <strcmp+0x2e>
  1054bd:	84 c0                	test   %al,%al
  1054bf:	75 f8                	jne    1054b9 <strcmp+0x22>
  1054c1:	31 c0                	xor    %eax,%eax
  1054c3:	eb 04                	jmp    1054c9 <strcmp+0x32>
  1054c5:	19 c0                	sbb    %eax,%eax
  1054c7:	0c 01                	or     $0x1,%al
  1054c9:	89 fa                	mov    %edi,%edx
  1054cb:	89 f1                	mov    %esi,%ecx
  1054cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1054d0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1054d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1054d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  1054d9:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1054da:	83 c4 20             	add    $0x20,%esp
  1054dd:	5e                   	pop    %esi
  1054de:	5f                   	pop    %edi
  1054df:	5d                   	pop    %ebp
  1054e0:	c3                   	ret    

001054e1 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1054e1:	55                   	push   %ebp
  1054e2:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1054e4:	eb 09                	jmp    1054ef <strncmp+0xe>
        n --, s1 ++, s2 ++;
  1054e6:	ff 4d 10             	decl   0x10(%ebp)
  1054e9:	ff 45 08             	incl   0x8(%ebp)
  1054ec:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1054ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1054f3:	74 1a                	je     10550f <strncmp+0x2e>
  1054f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1054f8:	0f b6 00             	movzbl (%eax),%eax
  1054fb:	84 c0                	test   %al,%al
  1054fd:	74 10                	je     10550f <strncmp+0x2e>
  1054ff:	8b 45 08             	mov    0x8(%ebp),%eax
  105502:	0f b6 10             	movzbl (%eax),%edx
  105505:	8b 45 0c             	mov    0xc(%ebp),%eax
  105508:	0f b6 00             	movzbl (%eax),%eax
  10550b:	38 c2                	cmp    %al,%dl
  10550d:	74 d7                	je     1054e6 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  10550f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105513:	74 18                	je     10552d <strncmp+0x4c>
  105515:	8b 45 08             	mov    0x8(%ebp),%eax
  105518:	0f b6 00             	movzbl (%eax),%eax
  10551b:	0f b6 d0             	movzbl %al,%edx
  10551e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105521:	0f b6 00             	movzbl (%eax),%eax
  105524:	0f b6 c0             	movzbl %al,%eax
  105527:	29 c2                	sub    %eax,%edx
  105529:	89 d0                	mov    %edx,%eax
  10552b:	eb 05                	jmp    105532 <strncmp+0x51>
  10552d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105532:	5d                   	pop    %ebp
  105533:	c3                   	ret    

00105534 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105534:	55                   	push   %ebp
  105535:	89 e5                	mov    %esp,%ebp
  105537:	83 ec 04             	sub    $0x4,%esp
  10553a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10553d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105540:	eb 13                	jmp    105555 <strchr+0x21>
        if (*s == c) {
  105542:	8b 45 08             	mov    0x8(%ebp),%eax
  105545:	0f b6 00             	movzbl (%eax),%eax
  105548:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10554b:	75 05                	jne    105552 <strchr+0x1e>
            return (char *)s;
  10554d:	8b 45 08             	mov    0x8(%ebp),%eax
  105550:	eb 12                	jmp    105564 <strchr+0x30>
        }
        s ++;
  105552:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105555:	8b 45 08             	mov    0x8(%ebp),%eax
  105558:	0f b6 00             	movzbl (%eax),%eax
  10555b:	84 c0                	test   %al,%al
  10555d:	75 e3                	jne    105542 <strchr+0xe>
    }
    return NULL;
  10555f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105564:	c9                   	leave  
  105565:	c3                   	ret    

00105566 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105566:	55                   	push   %ebp
  105567:	89 e5                	mov    %esp,%ebp
  105569:	83 ec 04             	sub    $0x4,%esp
  10556c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10556f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105572:	eb 0e                	jmp    105582 <strfind+0x1c>
        if (*s == c) {
  105574:	8b 45 08             	mov    0x8(%ebp),%eax
  105577:	0f b6 00             	movzbl (%eax),%eax
  10557a:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10557d:	74 0f                	je     10558e <strfind+0x28>
            break;
        }
        s ++;
  10557f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105582:	8b 45 08             	mov    0x8(%ebp),%eax
  105585:	0f b6 00             	movzbl (%eax),%eax
  105588:	84 c0                	test   %al,%al
  10558a:	75 e8                	jne    105574 <strfind+0xe>
  10558c:	eb 01                	jmp    10558f <strfind+0x29>
            break;
  10558e:	90                   	nop
    }
    return (char *)s;
  10558f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105592:	c9                   	leave  
  105593:	c3                   	ret    

00105594 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105594:	55                   	push   %ebp
  105595:	89 e5                	mov    %esp,%ebp
  105597:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10559a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1055a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1055a8:	eb 03                	jmp    1055ad <strtol+0x19>
        s ++;
  1055aa:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  1055ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b0:	0f b6 00             	movzbl (%eax),%eax
  1055b3:	3c 20                	cmp    $0x20,%al
  1055b5:	74 f3                	je     1055aa <strtol+0x16>
  1055b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ba:	0f b6 00             	movzbl (%eax),%eax
  1055bd:	3c 09                	cmp    $0x9,%al
  1055bf:	74 e9                	je     1055aa <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  1055c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c4:	0f b6 00             	movzbl (%eax),%eax
  1055c7:	3c 2b                	cmp    $0x2b,%al
  1055c9:	75 05                	jne    1055d0 <strtol+0x3c>
        s ++;
  1055cb:	ff 45 08             	incl   0x8(%ebp)
  1055ce:	eb 14                	jmp    1055e4 <strtol+0x50>
    }
    else if (*s == '-') {
  1055d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d3:	0f b6 00             	movzbl (%eax),%eax
  1055d6:	3c 2d                	cmp    $0x2d,%al
  1055d8:	75 0a                	jne    1055e4 <strtol+0x50>
        s ++, neg = 1;
  1055da:	ff 45 08             	incl   0x8(%ebp)
  1055dd:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1055e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1055e8:	74 06                	je     1055f0 <strtol+0x5c>
  1055ea:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1055ee:	75 22                	jne    105612 <strtol+0x7e>
  1055f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1055f3:	0f b6 00             	movzbl (%eax),%eax
  1055f6:	3c 30                	cmp    $0x30,%al
  1055f8:	75 18                	jne    105612 <strtol+0x7e>
  1055fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1055fd:	40                   	inc    %eax
  1055fe:	0f b6 00             	movzbl (%eax),%eax
  105601:	3c 78                	cmp    $0x78,%al
  105603:	75 0d                	jne    105612 <strtol+0x7e>
        s += 2, base = 16;
  105605:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105609:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105610:	eb 29                	jmp    10563b <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105612:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105616:	75 16                	jne    10562e <strtol+0x9a>
  105618:	8b 45 08             	mov    0x8(%ebp),%eax
  10561b:	0f b6 00             	movzbl (%eax),%eax
  10561e:	3c 30                	cmp    $0x30,%al
  105620:	75 0c                	jne    10562e <strtol+0x9a>
        s ++, base = 8;
  105622:	ff 45 08             	incl   0x8(%ebp)
  105625:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10562c:	eb 0d                	jmp    10563b <strtol+0xa7>
    }
    else if (base == 0) {
  10562e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105632:	75 07                	jne    10563b <strtol+0xa7>
        base = 10;
  105634:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10563b:	8b 45 08             	mov    0x8(%ebp),%eax
  10563e:	0f b6 00             	movzbl (%eax),%eax
  105641:	3c 2f                	cmp    $0x2f,%al
  105643:	7e 1b                	jle    105660 <strtol+0xcc>
  105645:	8b 45 08             	mov    0x8(%ebp),%eax
  105648:	0f b6 00             	movzbl (%eax),%eax
  10564b:	3c 39                	cmp    $0x39,%al
  10564d:	7f 11                	jg     105660 <strtol+0xcc>
            dig = *s - '0';
  10564f:	8b 45 08             	mov    0x8(%ebp),%eax
  105652:	0f b6 00             	movzbl (%eax),%eax
  105655:	0f be c0             	movsbl %al,%eax
  105658:	83 e8 30             	sub    $0x30,%eax
  10565b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10565e:	eb 48                	jmp    1056a8 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105660:	8b 45 08             	mov    0x8(%ebp),%eax
  105663:	0f b6 00             	movzbl (%eax),%eax
  105666:	3c 60                	cmp    $0x60,%al
  105668:	7e 1b                	jle    105685 <strtol+0xf1>
  10566a:	8b 45 08             	mov    0x8(%ebp),%eax
  10566d:	0f b6 00             	movzbl (%eax),%eax
  105670:	3c 7a                	cmp    $0x7a,%al
  105672:	7f 11                	jg     105685 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105674:	8b 45 08             	mov    0x8(%ebp),%eax
  105677:	0f b6 00             	movzbl (%eax),%eax
  10567a:	0f be c0             	movsbl %al,%eax
  10567d:	83 e8 57             	sub    $0x57,%eax
  105680:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105683:	eb 23                	jmp    1056a8 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105685:	8b 45 08             	mov    0x8(%ebp),%eax
  105688:	0f b6 00             	movzbl (%eax),%eax
  10568b:	3c 40                	cmp    $0x40,%al
  10568d:	7e 3b                	jle    1056ca <strtol+0x136>
  10568f:	8b 45 08             	mov    0x8(%ebp),%eax
  105692:	0f b6 00             	movzbl (%eax),%eax
  105695:	3c 5a                	cmp    $0x5a,%al
  105697:	7f 31                	jg     1056ca <strtol+0x136>
            dig = *s - 'A' + 10;
  105699:	8b 45 08             	mov    0x8(%ebp),%eax
  10569c:	0f b6 00             	movzbl (%eax),%eax
  10569f:	0f be c0             	movsbl %al,%eax
  1056a2:	83 e8 37             	sub    $0x37,%eax
  1056a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1056a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056ab:	3b 45 10             	cmp    0x10(%ebp),%eax
  1056ae:	7d 19                	jge    1056c9 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  1056b0:	ff 45 08             	incl   0x8(%ebp)
  1056b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056b6:	0f af 45 10          	imul   0x10(%ebp),%eax
  1056ba:	89 c2                	mov    %eax,%edx
  1056bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1056bf:	01 d0                	add    %edx,%eax
  1056c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1056c4:	e9 72 ff ff ff       	jmp    10563b <strtol+0xa7>
            break;
  1056c9:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1056ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1056ce:	74 08                	je     1056d8 <strtol+0x144>
        *endptr = (char *) s;
  1056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056d3:	8b 55 08             	mov    0x8(%ebp),%edx
  1056d6:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1056d8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1056dc:	74 07                	je     1056e5 <strtol+0x151>
  1056de:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1056e1:	f7 d8                	neg    %eax
  1056e3:	eb 03                	jmp    1056e8 <strtol+0x154>
  1056e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1056e8:	c9                   	leave  
  1056e9:	c3                   	ret    

001056ea <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1056ea:	55                   	push   %ebp
  1056eb:	89 e5                	mov    %esp,%ebp
  1056ed:	57                   	push   %edi
  1056ee:	83 ec 24             	sub    $0x24,%esp
  1056f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056f4:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1056f7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1056fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1056fe:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105701:	88 45 f7             	mov    %al,-0x9(%ebp)
  105704:	8b 45 10             	mov    0x10(%ebp),%eax
  105707:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10570a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10570d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105711:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105714:	89 d7                	mov    %edx,%edi
  105716:	f3 aa                	rep stos %al,%es:(%edi)
  105718:	89 fa                	mov    %edi,%edx
  10571a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10571d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105720:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105723:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105724:	83 c4 24             	add    $0x24,%esp
  105727:	5f                   	pop    %edi
  105728:	5d                   	pop    %ebp
  105729:	c3                   	ret    

0010572a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10572a:	55                   	push   %ebp
  10572b:	89 e5                	mov    %esp,%ebp
  10572d:	57                   	push   %edi
  10572e:	56                   	push   %esi
  10572f:	53                   	push   %ebx
  105730:	83 ec 30             	sub    $0x30,%esp
  105733:	8b 45 08             	mov    0x8(%ebp),%eax
  105736:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105739:	8b 45 0c             	mov    0xc(%ebp),%eax
  10573c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10573f:	8b 45 10             	mov    0x10(%ebp),%eax
  105742:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105748:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10574b:	73 42                	jae    10578f <memmove+0x65>
  10574d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105756:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105759:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10575c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10575f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105762:	c1 e8 02             	shr    $0x2,%eax
  105765:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10576a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10576d:	89 d7                	mov    %edx,%edi
  10576f:	89 c6                	mov    %eax,%esi
  105771:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105773:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105776:	83 e1 03             	and    $0x3,%ecx
  105779:	74 02                	je     10577d <memmove+0x53>
  10577b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10577d:	89 f0                	mov    %esi,%eax
  10577f:	89 fa                	mov    %edi,%edx
  105781:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105784:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105787:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  10578a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  10578d:	eb 36                	jmp    1057c5 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10578f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105792:	8d 50 ff             	lea    -0x1(%eax),%edx
  105795:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105798:	01 c2                	add    %eax,%edx
  10579a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10579d:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1057a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057a3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  1057a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1057a9:	89 c1                	mov    %eax,%ecx
  1057ab:	89 d8                	mov    %ebx,%eax
  1057ad:	89 d6                	mov    %edx,%esi
  1057af:	89 c7                	mov    %eax,%edi
  1057b1:	fd                   	std    
  1057b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1057b4:	fc                   	cld    
  1057b5:	89 f8                	mov    %edi,%eax
  1057b7:	89 f2                	mov    %esi,%edx
  1057b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1057bc:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1057bf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  1057c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  1057c5:	83 c4 30             	add    $0x30,%esp
  1057c8:	5b                   	pop    %ebx
  1057c9:	5e                   	pop    %esi
  1057ca:	5f                   	pop    %edi
  1057cb:	5d                   	pop    %ebp
  1057cc:	c3                   	ret    

001057cd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  1057cd:	55                   	push   %ebp
  1057ce:	89 e5                	mov    %esp,%ebp
  1057d0:	57                   	push   %edi
  1057d1:	56                   	push   %esi
  1057d2:	83 ec 20             	sub    $0x20,%esp
  1057d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1057db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1057e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1057e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1057e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057ea:	c1 e8 02             	shr    $0x2,%eax
  1057ed:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1057ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1057f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1057f5:	89 d7                	mov    %edx,%edi
  1057f7:	89 c6                	mov    %eax,%esi
  1057f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1057fb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1057fe:	83 e1 03             	and    $0x3,%ecx
  105801:	74 02                	je     105805 <memcpy+0x38>
  105803:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105805:	89 f0                	mov    %esi,%eax
  105807:	89 fa                	mov    %edi,%edx
  105809:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10580c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10580f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105812:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105815:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105816:	83 c4 20             	add    $0x20,%esp
  105819:	5e                   	pop    %esi
  10581a:	5f                   	pop    %edi
  10581b:	5d                   	pop    %ebp
  10581c:	c3                   	ret    

0010581d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10581d:	55                   	push   %ebp
  10581e:	89 e5                	mov    %esp,%ebp
  105820:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105823:	8b 45 08             	mov    0x8(%ebp),%eax
  105826:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105829:	8b 45 0c             	mov    0xc(%ebp),%eax
  10582c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10582f:	eb 2e                	jmp    10585f <memcmp+0x42>
        if (*s1 != *s2) {
  105831:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105834:	0f b6 10             	movzbl (%eax),%edx
  105837:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10583a:	0f b6 00             	movzbl (%eax),%eax
  10583d:	38 c2                	cmp    %al,%dl
  10583f:	74 18                	je     105859 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105841:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105844:	0f b6 00             	movzbl (%eax),%eax
  105847:	0f b6 d0             	movzbl %al,%edx
  10584a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10584d:	0f b6 00             	movzbl (%eax),%eax
  105850:	0f b6 c0             	movzbl %al,%eax
  105853:	29 c2                	sub    %eax,%edx
  105855:	89 d0                	mov    %edx,%eax
  105857:	eb 18                	jmp    105871 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105859:	ff 45 fc             	incl   -0x4(%ebp)
  10585c:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10585f:	8b 45 10             	mov    0x10(%ebp),%eax
  105862:	8d 50 ff             	lea    -0x1(%eax),%edx
  105865:	89 55 10             	mov    %edx,0x10(%ebp)
  105868:	85 c0                	test   %eax,%eax
  10586a:	75 c5                	jne    105831 <memcmp+0x14>
    }
    return 0;
  10586c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105871:	c9                   	leave  
  105872:	c3                   	ret    

00105873 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105873:	55                   	push   %ebp
  105874:	89 e5                	mov    %esp,%ebp
  105876:	83 ec 58             	sub    $0x58,%esp
  105879:	8b 45 10             	mov    0x10(%ebp),%eax
  10587c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10587f:	8b 45 14             	mov    0x14(%ebp),%eax
  105882:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105885:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105888:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10588b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10588e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105891:	8b 45 18             	mov    0x18(%ebp),%eax
  105894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105897:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10589a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10589d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1058a0:	89 55 f0             	mov    %edx,-0x10(%ebp)
  1058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1058a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1058ad:	74 1c                	je     1058cb <printnum+0x58>
  1058af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058b2:	ba 00 00 00 00       	mov    $0x0,%edx
  1058b7:	f7 75 e4             	divl   -0x1c(%ebp)
  1058ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058c0:	ba 00 00 00 00       	mov    $0x0,%edx
  1058c5:	f7 75 e4             	divl   -0x1c(%ebp)
  1058c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058d1:	f7 75 e4             	divl   -0x1c(%ebp)
  1058d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1058d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1058da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1058e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1058e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1058e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058e9:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1058ec:	8b 45 18             	mov    0x18(%ebp),%eax
  1058ef:	ba 00 00 00 00       	mov    $0x0,%edx
  1058f4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1058f7:	72 56                	jb     10594f <printnum+0xdc>
  1058f9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  1058fc:	77 05                	ja     105903 <printnum+0x90>
  1058fe:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105901:	72 4c                	jb     10594f <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105903:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105906:	8d 50 ff             	lea    -0x1(%eax),%edx
  105909:	8b 45 20             	mov    0x20(%ebp),%eax
  10590c:	89 44 24 18          	mov    %eax,0x18(%esp)
  105910:	89 54 24 14          	mov    %edx,0x14(%esp)
  105914:	8b 45 18             	mov    0x18(%ebp),%eax
  105917:	89 44 24 10          	mov    %eax,0x10(%esp)
  10591b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10591e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105921:	89 44 24 08          	mov    %eax,0x8(%esp)
  105925:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105929:	8b 45 0c             	mov    0xc(%ebp),%eax
  10592c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105930:	8b 45 08             	mov    0x8(%ebp),%eax
  105933:	89 04 24             	mov    %eax,(%esp)
  105936:	e8 38 ff ff ff       	call   105873 <printnum>
  10593b:	eb 1b                	jmp    105958 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10593d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105940:	89 44 24 04          	mov    %eax,0x4(%esp)
  105944:	8b 45 20             	mov    0x20(%ebp),%eax
  105947:	89 04 24             	mov    %eax,(%esp)
  10594a:	8b 45 08             	mov    0x8(%ebp),%eax
  10594d:	ff d0                	call   *%eax
        while (-- width > 0)
  10594f:	ff 4d 1c             	decl   0x1c(%ebp)
  105952:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105956:	7f e5                	jg     10593d <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105958:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10595b:	05 8c 70 10 00       	add    $0x10708c,%eax
  105960:	0f b6 00             	movzbl (%eax),%eax
  105963:	0f be c0             	movsbl %al,%eax
  105966:	8b 55 0c             	mov    0xc(%ebp),%edx
  105969:	89 54 24 04          	mov    %edx,0x4(%esp)
  10596d:	89 04 24             	mov    %eax,(%esp)
  105970:	8b 45 08             	mov    0x8(%ebp),%eax
  105973:	ff d0                	call   *%eax
}
  105975:	90                   	nop
  105976:	c9                   	leave  
  105977:	c3                   	ret    

00105978 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105978:	55                   	push   %ebp
  105979:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10597b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10597f:	7e 14                	jle    105995 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105981:	8b 45 08             	mov    0x8(%ebp),%eax
  105984:	8b 00                	mov    (%eax),%eax
  105986:	8d 48 08             	lea    0x8(%eax),%ecx
  105989:	8b 55 08             	mov    0x8(%ebp),%edx
  10598c:	89 0a                	mov    %ecx,(%edx)
  10598e:	8b 50 04             	mov    0x4(%eax),%edx
  105991:	8b 00                	mov    (%eax),%eax
  105993:	eb 30                	jmp    1059c5 <getuint+0x4d>
    }
    else if (lflag) {
  105995:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105999:	74 16                	je     1059b1 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10599b:	8b 45 08             	mov    0x8(%ebp),%eax
  10599e:	8b 00                	mov    (%eax),%eax
  1059a0:	8d 48 04             	lea    0x4(%eax),%ecx
  1059a3:	8b 55 08             	mov    0x8(%ebp),%edx
  1059a6:	89 0a                	mov    %ecx,(%edx)
  1059a8:	8b 00                	mov    (%eax),%eax
  1059aa:	ba 00 00 00 00       	mov    $0x0,%edx
  1059af:	eb 14                	jmp    1059c5 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  1059b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b4:	8b 00                	mov    (%eax),%eax
  1059b6:	8d 48 04             	lea    0x4(%eax),%ecx
  1059b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1059bc:	89 0a                	mov    %ecx,(%edx)
  1059be:	8b 00                	mov    (%eax),%eax
  1059c0:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1059c5:	5d                   	pop    %ebp
  1059c6:	c3                   	ret    

001059c7 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1059c7:	55                   	push   %ebp
  1059c8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1059ca:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1059ce:	7e 14                	jle    1059e4 <getint+0x1d>
        return va_arg(*ap, long long);
  1059d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1059d3:	8b 00                	mov    (%eax),%eax
  1059d5:	8d 48 08             	lea    0x8(%eax),%ecx
  1059d8:	8b 55 08             	mov    0x8(%ebp),%edx
  1059db:	89 0a                	mov    %ecx,(%edx)
  1059dd:	8b 50 04             	mov    0x4(%eax),%edx
  1059e0:	8b 00                	mov    (%eax),%eax
  1059e2:	eb 28                	jmp    105a0c <getint+0x45>
    }
    else if (lflag) {
  1059e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1059e8:	74 12                	je     1059fc <getint+0x35>
        return va_arg(*ap, long);
  1059ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ed:	8b 00                	mov    (%eax),%eax
  1059ef:	8d 48 04             	lea    0x4(%eax),%ecx
  1059f2:	8b 55 08             	mov    0x8(%ebp),%edx
  1059f5:	89 0a                	mov    %ecx,(%edx)
  1059f7:	8b 00                	mov    (%eax),%eax
  1059f9:	99                   	cltd   
  1059fa:	eb 10                	jmp    105a0c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1059fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ff:	8b 00                	mov    (%eax),%eax
  105a01:	8d 48 04             	lea    0x4(%eax),%ecx
  105a04:	8b 55 08             	mov    0x8(%ebp),%edx
  105a07:	89 0a                	mov    %ecx,(%edx)
  105a09:	8b 00                	mov    (%eax),%eax
  105a0b:	99                   	cltd   
    }
}
  105a0c:	5d                   	pop    %ebp
  105a0d:	c3                   	ret    

00105a0e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105a0e:	55                   	push   %ebp
  105a0f:	89 e5                	mov    %esp,%ebp
  105a11:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105a14:	8d 45 14             	lea    0x14(%ebp),%eax
  105a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a21:	8b 45 10             	mov    0x10(%ebp),%eax
  105a24:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  105a32:	89 04 24             	mov    %eax,(%esp)
  105a35:	e8 03 00 00 00       	call   105a3d <vprintfmt>
    va_end(ap);
}
  105a3a:	90                   	nop
  105a3b:	c9                   	leave  
  105a3c:	c3                   	ret    

00105a3d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105a3d:	55                   	push   %ebp
  105a3e:	89 e5                	mov    %esp,%ebp
  105a40:	56                   	push   %esi
  105a41:	53                   	push   %ebx
  105a42:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a45:	eb 17                	jmp    105a5e <vprintfmt+0x21>
            if (ch == '\0') {
  105a47:	85 db                	test   %ebx,%ebx
  105a49:	0f 84 bf 03 00 00    	je     105e0e <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a56:	89 1c 24             	mov    %ebx,(%esp)
  105a59:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5c:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a5e:	8b 45 10             	mov    0x10(%ebp),%eax
  105a61:	8d 50 01             	lea    0x1(%eax),%edx
  105a64:	89 55 10             	mov    %edx,0x10(%ebp)
  105a67:	0f b6 00             	movzbl (%eax),%eax
  105a6a:	0f b6 d8             	movzbl %al,%ebx
  105a6d:	83 fb 25             	cmp    $0x25,%ebx
  105a70:	75 d5                	jne    105a47 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105a72:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105a76:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a80:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105a83:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105a8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105a90:	8b 45 10             	mov    0x10(%ebp),%eax
  105a93:	8d 50 01             	lea    0x1(%eax),%edx
  105a96:	89 55 10             	mov    %edx,0x10(%ebp)
  105a99:	0f b6 00             	movzbl (%eax),%eax
  105a9c:	0f b6 d8             	movzbl %al,%ebx
  105a9f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105aa2:	83 f8 55             	cmp    $0x55,%eax
  105aa5:	0f 87 37 03 00 00    	ja     105de2 <vprintfmt+0x3a5>
  105aab:	8b 04 85 b0 70 10 00 	mov    0x1070b0(,%eax,4),%eax
  105ab2:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105ab4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105ab8:	eb d6                	jmp    105a90 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105aba:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105abe:	eb d0                	jmp    105a90 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105ac0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105ac7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105aca:	89 d0                	mov    %edx,%eax
  105acc:	c1 e0 02             	shl    $0x2,%eax
  105acf:	01 d0                	add    %edx,%eax
  105ad1:	01 c0                	add    %eax,%eax
  105ad3:	01 d8                	add    %ebx,%eax
  105ad5:	83 e8 30             	sub    $0x30,%eax
  105ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105adb:	8b 45 10             	mov    0x10(%ebp),%eax
  105ade:	0f b6 00             	movzbl (%eax),%eax
  105ae1:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105ae4:	83 fb 2f             	cmp    $0x2f,%ebx
  105ae7:	7e 38                	jle    105b21 <vprintfmt+0xe4>
  105ae9:	83 fb 39             	cmp    $0x39,%ebx
  105aec:	7f 33                	jg     105b21 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  105aee:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105af1:	eb d4                	jmp    105ac7 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105af3:	8b 45 14             	mov    0x14(%ebp),%eax
  105af6:	8d 50 04             	lea    0x4(%eax),%edx
  105af9:	89 55 14             	mov    %edx,0x14(%ebp)
  105afc:	8b 00                	mov    (%eax),%eax
  105afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105b01:	eb 1f                	jmp    105b22 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105b03:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b07:	79 87                	jns    105a90 <vprintfmt+0x53>
                width = 0;
  105b09:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105b10:	e9 7b ff ff ff       	jmp    105a90 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105b15:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105b1c:	e9 6f ff ff ff       	jmp    105a90 <vprintfmt+0x53>
            goto process_precision;
  105b21:	90                   	nop

        process_precision:
            if (width < 0)
  105b22:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105b26:	0f 89 64 ff ff ff    	jns    105a90 <vprintfmt+0x53>
                width = precision, precision = -1;
  105b2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105b2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b32:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105b39:	e9 52 ff ff ff       	jmp    105a90 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105b3e:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105b41:	e9 4a ff ff ff       	jmp    105a90 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105b46:	8b 45 14             	mov    0x14(%ebp),%eax
  105b49:	8d 50 04             	lea    0x4(%eax),%edx
  105b4c:	89 55 14             	mov    %edx,0x14(%ebp)
  105b4f:	8b 00                	mov    (%eax),%eax
  105b51:	8b 55 0c             	mov    0xc(%ebp),%edx
  105b54:	89 54 24 04          	mov    %edx,0x4(%esp)
  105b58:	89 04 24             	mov    %eax,(%esp)
  105b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105b5e:	ff d0                	call   *%eax
            break;
  105b60:	e9 a4 02 00 00       	jmp    105e09 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105b65:	8b 45 14             	mov    0x14(%ebp),%eax
  105b68:	8d 50 04             	lea    0x4(%eax),%edx
  105b6b:	89 55 14             	mov    %edx,0x14(%ebp)
  105b6e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105b70:	85 db                	test   %ebx,%ebx
  105b72:	79 02                	jns    105b76 <vprintfmt+0x139>
                err = -err;
  105b74:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105b76:	83 fb 06             	cmp    $0x6,%ebx
  105b79:	7f 0b                	jg     105b86 <vprintfmt+0x149>
  105b7b:	8b 34 9d 70 70 10 00 	mov    0x107070(,%ebx,4),%esi
  105b82:	85 f6                	test   %esi,%esi
  105b84:	75 23                	jne    105ba9 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  105b86:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105b8a:	c7 44 24 08 9d 70 10 	movl   $0x10709d,0x8(%esp)
  105b91:	00 
  105b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b99:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9c:	89 04 24             	mov    %eax,(%esp)
  105b9f:	e8 6a fe ff ff       	call   105a0e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105ba4:	e9 60 02 00 00       	jmp    105e09 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105ba9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105bad:	c7 44 24 08 a6 70 10 	movl   $0x1070a6,0x8(%esp)
  105bb4:	00 
  105bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  105bbf:	89 04 24             	mov    %eax,(%esp)
  105bc2:	e8 47 fe ff ff       	call   105a0e <printfmt>
            break;
  105bc7:	e9 3d 02 00 00       	jmp    105e09 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105bcc:	8b 45 14             	mov    0x14(%ebp),%eax
  105bcf:	8d 50 04             	lea    0x4(%eax),%edx
  105bd2:	89 55 14             	mov    %edx,0x14(%ebp)
  105bd5:	8b 30                	mov    (%eax),%esi
  105bd7:	85 f6                	test   %esi,%esi
  105bd9:	75 05                	jne    105be0 <vprintfmt+0x1a3>
                p = "(null)";
  105bdb:	be a9 70 10 00       	mov    $0x1070a9,%esi
            }
            if (width > 0 && padc != '-') {
  105be0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105be4:	7e 76                	jle    105c5c <vprintfmt+0x21f>
  105be6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105bea:	74 70                	je     105c5c <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  105bf3:	89 34 24             	mov    %esi,(%esp)
  105bf6:	e8 f6 f7 ff ff       	call   1053f1 <strnlen>
  105bfb:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105bfe:	29 c2                	sub    %eax,%edx
  105c00:	89 d0                	mov    %edx,%eax
  105c02:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105c05:	eb 16                	jmp    105c1d <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105c07:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c12:	89 04 24             	mov    %eax,(%esp)
  105c15:	8b 45 08             	mov    0x8(%ebp),%eax
  105c18:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105c1a:	ff 4d e8             	decl   -0x18(%ebp)
  105c1d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c21:	7f e4                	jg     105c07 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c23:	eb 37                	jmp    105c5c <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105c25:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105c29:	74 1f                	je     105c4a <vprintfmt+0x20d>
  105c2b:	83 fb 1f             	cmp    $0x1f,%ebx
  105c2e:	7e 05                	jle    105c35 <vprintfmt+0x1f8>
  105c30:	83 fb 7e             	cmp    $0x7e,%ebx
  105c33:	7e 15                	jle    105c4a <vprintfmt+0x20d>
                    putch('?', putdat);
  105c35:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c3c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105c43:	8b 45 08             	mov    0x8(%ebp),%eax
  105c46:	ff d0                	call   *%eax
  105c48:	eb 0f                	jmp    105c59 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c51:	89 1c 24             	mov    %ebx,(%esp)
  105c54:	8b 45 08             	mov    0x8(%ebp),%eax
  105c57:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105c59:	ff 4d e8             	decl   -0x18(%ebp)
  105c5c:	89 f0                	mov    %esi,%eax
  105c5e:	8d 70 01             	lea    0x1(%eax),%esi
  105c61:	0f b6 00             	movzbl (%eax),%eax
  105c64:	0f be d8             	movsbl %al,%ebx
  105c67:	85 db                	test   %ebx,%ebx
  105c69:	74 27                	je     105c92 <vprintfmt+0x255>
  105c6b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105c6f:	78 b4                	js     105c25 <vprintfmt+0x1e8>
  105c71:	ff 4d e4             	decl   -0x1c(%ebp)
  105c74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105c78:	79 ab                	jns    105c25 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105c7a:	eb 16                	jmp    105c92 <vprintfmt+0x255>
                putch(' ', putdat);
  105c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c83:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c8d:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105c8f:	ff 4d e8             	decl   -0x18(%ebp)
  105c92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105c96:	7f e4                	jg     105c7c <vprintfmt+0x23f>
            }
            break;
  105c98:	e9 6c 01 00 00       	jmp    105e09 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ca4:	8d 45 14             	lea    0x14(%ebp),%eax
  105ca7:	89 04 24             	mov    %eax,(%esp)
  105caa:	e8 18 fd ff ff       	call   1059c7 <getint>
  105caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cb2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cbb:	85 d2                	test   %edx,%edx
  105cbd:	79 26                	jns    105ce5 <vprintfmt+0x2a8>
                putch('-', putdat);
  105cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cc6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd0:	ff d0                	call   *%eax
                num = -(long long)num;
  105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105cd8:	f7 d8                	neg    %eax
  105cda:	83 d2 00             	adc    $0x0,%edx
  105cdd:	f7 da                	neg    %edx
  105cdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ce2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105ce5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105cec:	e9 a8 00 00 00       	jmp    105d99 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105cf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105cf8:	8d 45 14             	lea    0x14(%ebp),%eax
  105cfb:	89 04 24             	mov    %eax,(%esp)
  105cfe:	e8 75 fc ff ff       	call   105978 <getuint>
  105d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d06:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105d09:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105d10:	e9 84 00 00 00       	jmp    105d99 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d18:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d1c:	8d 45 14             	lea    0x14(%ebp),%eax
  105d1f:	89 04 24             	mov    %eax,(%esp)
  105d22:	e8 51 fc ff ff       	call   105978 <getuint>
  105d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105d2d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105d34:	eb 63                	jmp    105d99 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105d36:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d39:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d3d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105d44:	8b 45 08             	mov    0x8(%ebp),%eax
  105d47:	ff d0                	call   *%eax
            putch('x', putdat);
  105d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d50:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105d57:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  105d5f:	8d 50 04             	lea    0x4(%eax),%edx
  105d62:	89 55 14             	mov    %edx,0x14(%ebp)
  105d65:	8b 00                	mov    (%eax),%eax
  105d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105d71:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105d78:	eb 1f                	jmp    105d99 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d81:	8d 45 14             	lea    0x14(%ebp),%eax
  105d84:	89 04 24             	mov    %eax,(%esp)
  105d87:	e8 ec fb ff ff       	call   105978 <getuint>
  105d8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d8f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105d92:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105d99:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105da0:	89 54 24 18          	mov    %edx,0x18(%esp)
  105da4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105da7:	89 54 24 14          	mov    %edx,0x14(%esp)
  105dab:	89 44 24 10          	mov    %eax,0x10(%esp)
  105daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105db5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105db9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  105dc7:	89 04 24             	mov    %eax,(%esp)
  105dca:	e8 a4 fa ff ff       	call   105873 <printnum>
            break;
  105dcf:	eb 38                	jmp    105e09 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105dd8:	89 1c 24             	mov    %ebx,(%esp)
  105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  105dde:	ff d0                	call   *%eax
            break;
  105de0:	eb 27                	jmp    105e09 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105de5:	89 44 24 04          	mov    %eax,0x4(%esp)
  105de9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105df0:	8b 45 08             	mov    0x8(%ebp),%eax
  105df3:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105df5:	ff 4d 10             	decl   0x10(%ebp)
  105df8:	eb 03                	jmp    105dfd <vprintfmt+0x3c0>
  105dfa:	ff 4d 10             	decl   0x10(%ebp)
  105dfd:	8b 45 10             	mov    0x10(%ebp),%eax
  105e00:	48                   	dec    %eax
  105e01:	0f b6 00             	movzbl (%eax),%eax
  105e04:	3c 25                	cmp    $0x25,%al
  105e06:	75 f2                	jne    105dfa <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105e08:	90                   	nop
    while (1) {
  105e09:	e9 37 fc ff ff       	jmp    105a45 <vprintfmt+0x8>
                return;
  105e0e:	90                   	nop
        }
    }
}
  105e0f:	83 c4 40             	add    $0x40,%esp
  105e12:	5b                   	pop    %ebx
  105e13:	5e                   	pop    %esi
  105e14:	5d                   	pop    %ebp
  105e15:	c3                   	ret    

00105e16 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105e16:	55                   	push   %ebp
  105e17:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e1c:	8b 40 08             	mov    0x8(%eax),%eax
  105e1f:	8d 50 01             	lea    0x1(%eax),%edx
  105e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e25:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e2b:	8b 10                	mov    (%eax),%edx
  105e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e30:	8b 40 04             	mov    0x4(%eax),%eax
  105e33:	39 c2                	cmp    %eax,%edx
  105e35:	73 12                	jae    105e49 <sprintputch+0x33>
        *b->buf ++ = ch;
  105e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e3a:	8b 00                	mov    (%eax),%eax
  105e3c:	8d 48 01             	lea    0x1(%eax),%ecx
  105e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e42:	89 0a                	mov    %ecx,(%edx)
  105e44:	8b 55 08             	mov    0x8(%ebp),%edx
  105e47:	88 10                	mov    %dl,(%eax)
    }
}
  105e49:	90                   	nop
  105e4a:	5d                   	pop    %ebp
  105e4b:	c3                   	ret    

00105e4c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105e4c:	55                   	push   %ebp
  105e4d:	89 e5                	mov    %esp,%ebp
  105e4f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105e52:	8d 45 14             	lea    0x14(%ebp),%eax
  105e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105e5f:	8b 45 10             	mov    0x10(%ebp),%eax
  105e62:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e69:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  105e70:	89 04 24             	mov    %eax,(%esp)
  105e73:	e8 08 00 00 00       	call   105e80 <vsnprintf>
  105e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105e7e:	c9                   	leave  
  105e7f:	c3                   	ret    

00105e80 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105e80:	55                   	push   %ebp
  105e81:	89 e5                	mov    %esp,%ebp
  105e83:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105e86:	8b 45 08             	mov    0x8(%ebp),%eax
  105e89:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e8f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e92:	8b 45 08             	mov    0x8(%ebp),%eax
  105e95:	01 d0                	add    %edx,%eax
  105e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105ea1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105ea5:	74 0a                	je     105eb1 <vsnprintf+0x31>
  105ea7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ead:	39 c2                	cmp    %eax,%edx
  105eaf:	76 07                	jbe    105eb8 <vsnprintf+0x38>
        return -E_INVAL;
  105eb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105eb6:	eb 2a                	jmp    105ee2 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  105ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  105ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ec6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ecd:	c7 04 24 16 5e 10 00 	movl   $0x105e16,(%esp)
  105ed4:	e8 64 fb ff ff       	call   105a3d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105edc:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ee2:	c9                   	leave  
  105ee3:	c3                   	ret    
