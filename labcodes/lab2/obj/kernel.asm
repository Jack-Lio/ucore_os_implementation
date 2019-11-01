
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
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
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 88 56 00 00       	call   c01056ea <memset>

    cons_init();                // init the console
c0100062:	e8 a3 15 00 00       	call   c010160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 5f 10 c0 	movl   $0xc0105f00,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 5f 10 c0 	movl   $0xc0105f1c,(%esp)
c010007c:	e8 21 02 00 00       	call   c01002a2 <cprintf>

    print_kerninfo();
c0100081:	e8 c2 08 00 00       	call   c0100948 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8e 00 00 00       	call   c0100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 68 32 00 00       	call   c01032f8 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 da 16 00 00       	call   c010176f <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 3a 18 00 00       	call   c01018d4 <idt_init>

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
c010015a:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 21 5f 10 c0 	movl   $0xc0105f21,(%esp)
c010016e:	e8 2f 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 2f 5f 10 c0 	movl   $0xc0105f2f,(%esp)
c010018d:	e8 10 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 3d 5f 10 c0 	movl   $0xc0105f3d,(%esp)
c01001ac:	e8 f1 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 4b 5f 10 c0 	movl   $0xc0105f4b,(%esp)
c01001cb:	e8 d2 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 59 5f 10 c0 	movl   $0xc0105f59,(%esp)
c01001ea:	e8 b3 00 00 00       	call   c01002a2 <cprintf>
    round ++;
c01001ef:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
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
c010021f:	c7 04 24 68 5f 10 c0 	movl   $0xc0105f68,(%esp)
c0100226:	e8 77 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_user();
c010022b:	e8 cd ff ff ff       	call   c01001fd <lab1_switch_to_user>
    lab1_print_cur_status();
c0100230:	e8 0a ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100235:	c7 04 24 88 5f 10 c0 	movl   $0xc0105f88,(%esp)
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
c0100298:	e8 a0 57 00 00       	call   c0105a3d <vprintfmt>
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
c0100357:	c7 04 24 a7 5f 10 c0 	movl   $0xc0105fa7,(%esp)
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
c01003a5:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
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
c01003e3:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01003e8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003eb:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
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
c01003ff:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100404:	85 c0                	test   %eax,%eax
c0100406:	75 5b                	jne    c0100463 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100408:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
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
c0100426:	c7 04 24 aa 5f 10 c0 	movl   $0xc0105faa,(%esp)
c010042d:	e8 70 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c0100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100435:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100439:	8b 45 10             	mov    0x10(%ebp),%eax
c010043c:	89 04 24             	mov    %eax,(%esp)
c010043f:	e8 2b fe ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c0100444:	c7 04 24 c6 5f 10 c0 	movl   $0xc0105fc6,(%esp)
c010044b:	e8 52 fe ff ff       	call   c01002a2 <cprintf>
    
    cprintf("stack trackback:\n");
c0100450:	c7 04 24 c8 5f 10 c0 	movl   $0xc0105fc8,(%esp)
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
c0100491:	c7 04 24 da 5f 10 c0 	movl   $0xc0105fda,(%esp)
c0100498:	e8 05 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c010049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a7:	89 04 24             	mov    %eax,(%esp)
c01004aa:	e8 c0 fd ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c01004af:	c7 04 24 c6 5f 10 c0 	movl   $0xc0105fc6,(%esp)
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
c01004c1:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
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
c010061f:	c7 00 f8 5f 10 c0    	movl   $0xc0105ff8,(%eax)
    info->eip_line = 0;
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 08 f8 5f 10 c0 	movl   $0xc0105ff8,0x8(%eax)
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
c0100656:	c7 45 f4 08 72 10 c0 	movl   $0xc0107208,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065d:	c7 45 f0 e4 22 11 c0 	movl   $0xc01122e4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100664:	c7 45 ec e5 22 11 c0 	movl   $0xc01122e5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066b:	c7 45 e8 fc 4d 11 c0 	movl   $0xc0114dfc,-0x18(%ebp)

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
c01007c6:	e8 9b 4d 00 00       	call   c0105566 <strfind>
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
c010094e:	c7 04 24 02 60 10 c0 	movl   $0xc0106002,(%esp)
c0100955:	e8 48 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010095a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100961:	c0 
c0100962:	c7 04 24 1b 60 10 c0 	movl   $0xc010601b,(%esp)
c0100969:	e8 34 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096e:	c7 44 24 04 e4 5e 10 	movl   $0xc0105ee4,0x4(%esp)
c0100975:	c0 
c0100976:	c7 04 24 33 60 10 c0 	movl   $0xc0106033,(%esp)
c010097d:	e8 20 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100982:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c0100989:	c0 
c010098a:	c7 04 24 4b 60 10 c0 	movl   $0xc010604b,(%esp)
c0100991:	e8 0c f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100996:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c010099d:	c0 
c010099e:	c7 04 24 63 60 10 c0 	movl   $0xc0106063,(%esp)
c01009a5:	e8 f8 f8 ff ff       	call   c01002a2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009aa:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01009af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b5:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009ba:	29 c2                	sub    %eax,%edx
c01009bc:	89 d0                	mov    %edx,%eax
c01009be:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c4:	85 c0                	test   %eax,%eax
c01009c6:	0f 48 c2             	cmovs  %edx,%eax
c01009c9:	c1 f8 0a             	sar    $0xa,%eax
c01009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d0:	c7 04 24 7c 60 10 c0 	movl   $0xc010607c,(%esp)
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
c0100a05:	c7 04 24 a6 60 10 c0 	movl   $0xc01060a6,(%esp)
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
c0100a73:	c7 04 24 c2 60 10 c0 	movl   $0xc01060c2,(%esp)
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
c0100ad0:	c7 04 24 d4 60 10 c0 	movl   $0xc01060d4,(%esp)
c0100ad7:	e8 c6 f7 ff ff       	call   c01002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
c0100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adf:	83 c0 08             	add    $0x8,%eax
c0100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
c0100ae5:	c7 04 24 f2 60 10 c0 	movl   $0xc01060f2,(%esp)
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
c0100b0f:	c7 04 24 f9 60 10 c0 	movl   $0xc01060f9,(%esp)
c0100b16:	e8 87 f7 ff ff       	call   c01002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
c0100b1b:	ff 45 e8             	incl   -0x18(%ebp)
c0100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b22:	7e d6                	jle    c0100afa <print_stackframe+0x67>
        }
        cprintf("\n");
c0100b24:	c7 04 24 01 61 10 c0 	movl   $0xc0106101,(%esp)
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
c0100b94:	c7 04 24 84 61 10 c0 	movl   $0xc0106184,(%esp)
c0100b9b:	e8 94 49 00 00       	call   c0105534 <strchr>
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
c0100bbc:	c7 04 24 89 61 10 c0 	movl   $0xc0106189,(%esp)
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
c0100bfe:	c7 04 24 84 61 10 c0 	movl   $0xc0106184,(%esp)
c0100c05:	e8 2a 49 00 00       	call   c0105534 <strchr>
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
c0100c5d:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c62:	8b 00                	mov    (%eax),%eax
c0100c64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c68:	89 04 24             	mov    %eax,(%esp)
c0100c6b:	e8 27 48 00 00       	call   c0105497 <strcmp>
c0100c70:	85 c0                	test   %eax,%eax
c0100c72:	75 31                	jne    c0100ca5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 08 70 11 c0       	add    $0xc0117008,%eax
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
c0100cb7:	c7 04 24 a7 61 10 c0 	movl   $0xc01061a7,(%esp)
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
c0100cd4:	c7 04 24 c0 61 10 c0 	movl   $0xc01061c0,(%esp)
c0100cdb:	e8 c2 f5 ff ff       	call   c01002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ce0:	c7 04 24 e8 61 10 c0 	movl   $0xc01061e8,(%esp)
c0100ce7:	e8 b6 f5 ff ff       	call   c01002a2 <cprintf>

    if (tf != NULL) {
c0100cec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cf0:	74 0b                	je     c0100cfd <kmonitor+0x2f>
        print_trapframe(tf);
c0100cf2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf5:	89 04 24             	mov    %eax,(%esp)
c0100cf8:	e8 8f 0d 00 00       	call   c0101a8c <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cfd:	c7 04 24 0d 62 10 c0 	movl   $0xc010620d,(%esp)
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
c0100d49:	05 04 70 11 c0       	add    $0xc0117004,%eax
c0100d4e:	8b 08                	mov    (%eax),%ecx
c0100d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d53:	89 d0                	mov    %edx,%eax
c0100d55:	01 c0                	add    %eax,%eax
c0100d57:	01 d0                	add    %edx,%eax
c0100d59:	c1 e0 02             	shl    $0x2,%eax
c0100d5c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100d61:	8b 00                	mov    (%eax),%eax
c0100d63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6b:	c7 04 24 11 62 10 c0 	movl   $0xc0106211,(%esp)
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
c0100dec:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100df3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df6:	c7 04 24 1a 62 10 c0 	movl   $0xc010621a,(%esp)
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
__intr_save(void) {
c0100e11:	55                   	push   %ebp
c0100e12:	89 e5                	mov    %esp,%ebp
c0100e14:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e17:	9c                   	pushf  
c0100e18:	58                   	pop    %eax
c0100e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e1f:	25 00 02 00 00       	and    $0x200,%eax
c0100e24:	85 c0                	test   %eax,%eax
c0100e26:	74 0c                	je     c0100e34 <__intr_save+0x23>
        intr_disable();
c0100e28:	e8 83 0a 00 00       	call   c01018b0 <intr_disable>
        return 1;
c0100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e32:	eb 05                	jmp    c0100e39 <__intr_save+0x28>
    }
    return 0;
c0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e39:	c9                   	leave  
c0100e3a:	c3                   	ret    

c0100e3b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
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
c0100ece:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ed5:	b4 03 
c0100ed7:	eb 13                	jmp    c0100eec <cga_init+0x54>
    } else {
        *cp = was;
c0100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee3:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100eea:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);
c0100eec:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100ef7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100efb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100eff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f03:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f04:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
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
c0100f2a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f31:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f35:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f39:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f3d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f41:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f42:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
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
c0100f68:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f70:	0f b7 c0             	movzwl %ax,%eax
c0100f73:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
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
c0101023:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
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
c0101048:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
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
c010114c:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101153:	85 c0                	test   %eax,%eax
c0101155:	0f 84 af 00 00 00    	je     c010120a <cga_putc+0xf1>
            crt_pos --;
c010115b:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101162:	48                   	dec    %eax
c0101163:	0f b7 c0             	movzwl %ax,%eax
c0101166:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010116c:	8b 45 08             	mov    0x8(%ebp),%eax
c010116f:	98                   	cwtl   
c0101170:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101175:	98                   	cwtl   
c0101176:	83 c8 20             	or     $0x20,%eax
c0101179:	98                   	cwtl   
c010117a:	8b 15 40 a4 11 c0    	mov    0xc011a440,%edx
c0101180:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101187:	01 c9                	add    %ecx,%ecx
c0101189:	01 ca                	add    %ecx,%edx
c010118b:	0f b7 c0             	movzwl %ax,%eax
c010118e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101191:	eb 77                	jmp    c010120a <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
c0101193:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010119a:	83 c0 50             	add    $0x50,%eax
c010119d:	0f b7 c0             	movzwl %ax,%eax
c01011a0:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011a6:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c01011ad:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
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
c01011d8:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011de:	eb 2b                	jmp    c010120b <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011e0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011e6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ed:	8d 50 01             	lea    0x1(%eax),%edx
c01011f0:	0f b7 d2             	movzwl %dx,%edx
c01011f3:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
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
c010120b:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101212:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101217:	76 5d                	jbe    c0101276 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101219:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010121e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101224:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101229:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101230:	00 
c0101231:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101235:	89 04 24             	mov    %eax,(%esp)
c0101238:	e8 ed 44 00 00       	call   c010572a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010123d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101244:	eb 14                	jmp    c010125a <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
c0101246:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
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
c0101263:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010126a:	83 e8 50             	sub    $0x50,%eax
c010126d:	0f b7 c0             	movzwl %ax,%eax
c0101270:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101276:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010127d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101281:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
c0101285:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101289:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010128d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010128e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101295:	c1 e8 08             	shr    $0x8,%eax
c0101298:	0f b7 c0             	movzwl %ax,%eax
c010129b:	0f b6 c0             	movzbl %al,%eax
c010129e:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012a5:	42                   	inc    %edx
c01012a6:	0f b7 d2             	movzwl %dx,%edx
c01012a9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012ad:	88 45 e9             	mov    %al,-0x17(%ebp)
c01012b0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012b4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012b9:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c01012c0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012c4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
c01012c8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012cc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012d0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012d1:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012d8:	0f b6 c0             	movzbl %al,%eax
c01012db:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
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
c01013a4:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013a9:	8d 50 01             	lea    0x1(%eax),%edx
c01013ac:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c01013b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013b5:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013bb:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013c0:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013c5:	75 0a                	jne    c01013d1 <cons_intr+0x3b>
                cons.wpos = 0;
c01013c7:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
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
c010143f:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
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
c01014a0:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a5:	83 c8 40             	or     $0x40,%eax
c01014a8:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014ad:	b8 00 00 00 00       	mov    $0x0,%eax
c01014b2:	e9 22 01 00 00       	jmp    c01015d9 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
c01014b7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bb:	84 c0                	test   %al,%al
c01014bd:	79 45                	jns    c0101504 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014bf:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
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
c01014de:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014e5:	0c 40                	or     $0x40,%al
c01014e7:	0f b6 c0             	movzbl %al,%eax
c01014ea:	f7 d0                	not    %eax
c01014ec:	89 c2                	mov    %eax,%edx
c01014ee:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f3:	21 d0                	and    %edx,%eax
c01014f5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014fa:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ff:	e9 d5 00 00 00       	jmp    c01015d9 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
c0101504:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101509:	83 e0 40             	and    $0x40,%eax
c010150c:	85 c0                	test   %eax,%eax
c010150e:	74 11                	je     c0101521 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101510:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101514:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101519:	83 e0 bf             	and    $0xffffffbf,%eax
c010151c:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101521:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101525:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010152c:	0f b6 d0             	movzbl %al,%edx
c010152f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101534:	09 d0                	or     %edx,%eax
c0101536:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010153b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010153f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101546:	0f b6 d0             	movzbl %al,%edx
c0101549:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010154e:	31 d0                	xor    %edx,%eax
c0101550:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101555:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010155a:	83 e0 03             	and    $0x3,%eax
c010155d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101564:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101568:	01 d0                	add    %edx,%eax
c010156a:	0f b6 00             	movzbl (%eax),%eax
c010156d:	0f b6 c0             	movzbl %al,%eax
c0101570:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101573:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
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
c01015a1:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01015a6:	f7 d0                	not    %eax
c01015a8:	83 e0 06             	and    $0x6,%eax
c01015ab:	85 c0                	test   %eax,%eax
c01015ad:	75 27                	jne    c01015d6 <kbd_proc_data+0x17f>
c01015af:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015b6:	75 1e                	jne    c01015d6 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
c01015b8:	c7 04 24 35 62 10 c0 	movl   $0xc0106235,(%esp)
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
c010161f:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101624:	85 c0                	test   %eax,%eax
c0101626:	75 0c                	jne    c0101634 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101628:	c7 04 24 41 62 10 c0 	movl   $0xc0106241,(%esp)
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
c0101693:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101699:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010169e:	39 c2                	cmp    %eax,%edx
c01016a0:	74 31                	je     c01016d3 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016a2:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01016a7:	8d 50 01             	lea    0x1(%eax),%edx
c01016aa:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c01016b0:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c01016b7:	0f b6 c0             	movzbl %al,%eax
c01016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016bd:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01016c2:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016c7:	75 0a                	jne    c01016d3 <cons_getc+0x5f>
                cons.rpos = 0;
c01016c9:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
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
c01016f3:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016f9:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
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
c0101756:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
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
c0101775:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
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
c0101889:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101890:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101895:	74 0f                	je     c01018a6 <pic_init+0x137>
        pic_setmask(irq_mask);
c0101897:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
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

/* intr_enable - enable irq interrupt */
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
c01018c5:	c7 04 24 60 62 10 c0 	movl   $0xc0106260,(%esp)
c01018cc:	e8 d1 e9 ff ff       	call   c01002a2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018d1:	90                   	nop
c01018d2:	c9                   	leave  
c01018d3:	c3                   	ret    

c01018d4 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018d4:	55                   	push   %ebp
c01018d5:	89 e5                	mov    %esp,%ebp
c01018d7:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uint32_t __vectors[];
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
c01018da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018e1:	e9 c4 00 00 00       	jmp    c01019aa <idt_init+0xd6>
    {
      SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c01018e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e9:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018f0:	0f b7 d0             	movzwl %ax,%edx
c01018f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f6:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018fd:	c0 
c01018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101901:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c0101908:	c0 08 00 
c010190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190e:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101915:	c0 
c0101916:	80 e2 e0             	and    $0xe0,%dl
c0101919:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101920:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101923:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010192a:	c0 
c010192b:	80 e2 1f             	and    $0x1f,%dl
c010192e:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101938:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010193f:	c0 
c0101940:	80 e2 f0             	and    $0xf0,%dl
c0101943:	80 ca 0e             	or     $0xe,%dl
c0101946:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101950:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101957:	c0 
c0101958:	80 e2 ef             	and    $0xef,%dl
c010195b:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101962:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101965:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010196c:	c0 
c010196d:	80 e2 9f             	and    $0x9f,%dl
c0101970:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101981:	c0 
c0101982:	80 ca 80             	or     $0x80,%dl
c0101985:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198f:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101996:	c1 e8 10             	shr    $0x10,%eax
c0101999:	0f b7 d0             	movzwl %ax,%edx
c010199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010199f:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c01019a6:	c0 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
c01019a7:	ff 45 fc             	incl   -0x4(%ebp)
c01019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ad:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019b2:	0f 86 2e ff ff ff    	jbe    c01018e6 <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01019b8:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c01019bd:	0f b7 c0             	movzwl %ax,%eax
c01019c0:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c01019c6:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c01019cd:	08 00 
c01019cf:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019d6:	24 e0                	and    $0xe0,%al
c01019d8:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019dd:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019e4:	24 1f                	and    $0x1f,%al
c01019e6:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019eb:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019f2:	24 f0                	and    $0xf0,%al
c01019f4:	0c 0e                	or     $0xe,%al
c01019f6:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019fb:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a02:	24 ef                	and    $0xef,%al
c0101a04:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a09:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a10:	0c 60                	or     $0x60,%al
c0101a12:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a17:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c0101a1e:	0c 80                	or     $0x80,%al
c0101a20:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c0101a25:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a2a:	c1 e8 10             	shr    $0x10,%eax
c0101a2d:	0f b7 c0             	movzwl %ax,%eax
c0101a30:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a36:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a40:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0101a43:	90                   	nop
c0101a44:	c9                   	leave  
c0101a45:	c3                   	ret    

c0101a46 <trapname>:

static const char *
trapname(int trapno) {
c0101a46:	55                   	push   %ebp
c0101a47:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4c:	83 f8 13             	cmp    $0x13,%eax
c0101a4f:	77 0c                	ja     c0101a5d <trapname+0x17>
        return excnames[trapno];
c0101a51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a54:	8b 04 85 c0 65 10 c0 	mov    -0x3fef9a40(,%eax,4),%eax
c0101a5b:	eb 18                	jmp    c0101a75 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a5d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a61:	7e 0d                	jle    c0101a70 <trapname+0x2a>
c0101a63:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a67:	7f 07                	jg     c0101a70 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a69:	b8 6a 62 10 c0       	mov    $0xc010626a,%eax
c0101a6e:	eb 05                	jmp    c0101a75 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a70:	b8 7d 62 10 c0       	mov    $0xc010627d,%eax
}
c0101a75:	5d                   	pop    %ebp
c0101a76:	c3                   	ret    

c0101a77 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a77:	55                   	push   %ebp
c0101a78:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a81:	83 f8 08             	cmp    $0x8,%eax
c0101a84:	0f 94 c0             	sete   %al
c0101a87:	0f b6 c0             	movzbl %al,%eax
}
c0101a8a:	5d                   	pop    %ebp
c0101a8b:	c3                   	ret    

c0101a8c <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a8c:	55                   	push   %ebp
c0101a8d:	89 e5                	mov    %esp,%ebp
c0101a8f:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a99:	c7 04 24 be 62 10 c0 	movl   $0xc01062be,(%esp)
c0101aa0:	e8 fd e7 ff ff       	call   c01002a2 <cprintf>
    print_regs(&tf->tf_regs);
c0101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa8:	89 04 24             	mov    %eax,(%esp)
c0101aab:	e8 8f 01 00 00       	call   c0101c3f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101abb:	c7 04 24 cf 62 10 c0 	movl   $0xc01062cf,(%esp)
c0101ac2:	e8 db e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aca:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ace:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad2:	c7 04 24 e2 62 10 c0 	movl   $0xc01062e2,(%esp)
c0101ad9:	e8 c4 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae1:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae9:	c7 04 24 f5 62 10 c0 	movl   $0xc01062f5,(%esp)
c0101af0:	e8 ad e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101af5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af8:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101afc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b00:	c7 04 24 08 63 10 c0 	movl   $0xc0106308,(%esp)
c0101b07:	e8 96 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0f:	8b 40 30             	mov    0x30(%eax),%eax
c0101b12:	89 04 24             	mov    %eax,(%esp)
c0101b15:	e8 2c ff ff ff       	call   c0101a46 <trapname>
c0101b1a:	89 c2                	mov    %eax,%edx
c0101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1f:	8b 40 30             	mov    0x30(%eax),%eax
c0101b22:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b2a:	c7 04 24 1b 63 10 c0 	movl   $0xc010631b,(%esp)
c0101b31:	e8 6c e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b36:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b39:	8b 40 34             	mov    0x34(%eax),%eax
c0101b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b40:	c7 04 24 2d 63 10 c0 	movl   $0xc010632d,(%esp)
c0101b47:	e8 56 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4f:	8b 40 38             	mov    0x38(%eax),%eax
c0101b52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b56:	c7 04 24 3c 63 10 c0 	movl   $0xc010633c,(%esp)
c0101b5d:	e8 40 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b62:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b6d:	c7 04 24 4b 63 10 c0 	movl   $0xc010634b,(%esp)
c0101b74:	e8 29 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7c:	8b 40 40             	mov    0x40(%eax),%eax
c0101b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b83:	c7 04 24 5e 63 10 c0 	movl   $0xc010635e,(%esp)
c0101b8a:	e8 13 e7 ff ff       	call   c01002a2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b96:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b9d:	eb 3d                	jmp    c0101bdc <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba2:	8b 50 40             	mov    0x40(%eax),%edx
c0101ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101ba8:	21 d0                	and    %edx,%eax
c0101baa:	85 c0                	test   %eax,%eax
c0101bac:	74 28                	je     c0101bd6 <print_trapframe+0x14a>
c0101bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb1:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bb8:	85 c0                	test   %eax,%eax
c0101bba:	74 1a                	je     c0101bd6 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bbf:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bca:	c7 04 24 6d 63 10 c0 	movl   $0xc010636d,(%esp)
c0101bd1:	e8 cc e6 ff ff       	call   c01002a2 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bd6:	ff 45 f4             	incl   -0xc(%ebp)
c0101bd9:	d1 65 f0             	shll   -0x10(%ebp)
c0101bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bdf:	83 f8 17             	cmp    $0x17,%eax
c0101be2:	76 bb                	jbe    c0101b9f <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be7:	8b 40 40             	mov    0x40(%eax),%eax
c0101bea:	c1 e8 0c             	shr    $0xc,%eax
c0101bed:	83 e0 03             	and    $0x3,%eax
c0101bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf4:	c7 04 24 71 63 10 c0 	movl   $0xc0106371,(%esp)
c0101bfb:	e8 a2 e6 ff ff       	call   c01002a2 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c03:	89 04 24             	mov    %eax,(%esp)
c0101c06:	e8 6c fe ff ff       	call   c0101a77 <trap_in_kernel>
c0101c0b:	85 c0                	test   %eax,%eax
c0101c0d:	75 2d                	jne    c0101c3c <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c12:	8b 40 44             	mov    0x44(%eax),%eax
c0101c15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c19:	c7 04 24 7a 63 10 c0 	movl   $0xc010637a,(%esp)
c0101c20:	e8 7d e6 ff ff       	call   c01002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c28:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 89 63 10 c0 	movl   $0xc0106389,(%esp)
c0101c37:	e8 66 e6 ff ff       	call   c01002a2 <cprintf>
    }
}
c0101c3c:	90                   	nop
c0101c3d:	c9                   	leave  
c0101c3e:	c3                   	ret    

c0101c3f <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c3f:	55                   	push   %ebp
c0101c40:	89 e5                	mov    %esp,%ebp
c0101c42:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	8b 00                	mov    (%eax),%eax
c0101c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4e:	c7 04 24 9c 63 10 c0 	movl   $0xc010639c,(%esp)
c0101c55:	e8 48 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5d:	8b 40 04             	mov    0x4(%eax),%eax
c0101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c64:	c7 04 24 ab 63 10 c0 	movl   $0xc01063ab,(%esp)
c0101c6b:	e8 32 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c73:	8b 40 08             	mov    0x8(%eax),%eax
c0101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7a:	c7 04 24 ba 63 10 c0 	movl   $0xc01063ba,(%esp)
c0101c81:	e8 1c e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c89:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c90:	c7 04 24 c9 63 10 c0 	movl   $0xc01063c9,(%esp)
c0101c97:	e8 06 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9f:	8b 40 10             	mov    0x10(%eax),%eax
c0101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca6:	c7 04 24 d8 63 10 c0 	movl   $0xc01063d8,(%esp)
c0101cad:	e8 f0 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb5:	8b 40 14             	mov    0x14(%eax),%eax
c0101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cbc:	c7 04 24 e7 63 10 c0 	movl   $0xc01063e7,(%esp)
c0101cc3:	e8 da e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ccb:	8b 40 18             	mov    0x18(%eax),%eax
c0101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd2:	c7 04 24 f6 63 10 c0 	movl   $0xc01063f6,(%esp)
c0101cd9:	e8 c4 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce8:	c7 04 24 05 64 10 c0 	movl   $0xc0106405,(%esp)
c0101cef:	e8 ae e5 ff ff       	call   c01002a2 <cprintf>
}
c0101cf4:	90                   	nop
c0101cf5:	c9                   	leave  
c0101cf6:	c3                   	ret    

c0101cf7 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cf7:	55                   	push   %ebp
c0101cf8:	89 e5                	mov    %esp,%ebp
c0101cfa:	57                   	push   %edi
c0101cfb:	56                   	push   %esi
c0101cfc:	53                   	push   %ebx
c0101cfd:	83 ec 7c             	sub    $0x7c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101d00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d03:	8b 40 30             	mov    0x30(%eax),%eax
c0101d06:	83 f8 2f             	cmp    $0x2f,%eax
c0101d09:	77 21                	ja     c0101d2c <trap_dispatch+0x35>
c0101d0b:	83 f8 2e             	cmp    $0x2e,%eax
c0101d0e:	0f 83 38 02 00 00    	jae    c0101f4c <trap_dispatch+0x255>
c0101d14:	83 f8 21             	cmp    $0x21,%eax
c0101d17:	0f 84 95 00 00 00    	je     c0101db2 <trap_dispatch+0xbb>
c0101d1d:	83 f8 24             	cmp    $0x24,%eax
c0101d20:	74 67                	je     c0101d89 <trap_dispatch+0x92>
c0101d22:	83 f8 20             	cmp    $0x20,%eax
c0101d25:	74 1c                	je     c0101d43 <trap_dispatch+0x4c>
c0101d27:	e9 eb 01 00 00       	jmp    c0101f17 <trap_dispatch+0x220>
c0101d2c:	83 f8 78             	cmp    $0x78,%eax
c0101d2f:	0f 84 a6 00 00 00    	je     c0101ddb <trap_dispatch+0xe4>
c0101d35:	83 f8 79             	cmp    $0x79,%eax
c0101d38:	0f 84 63 01 00 00    	je     c0101ea1 <trap_dispatch+0x1aa>
c0101d3e:	e9 d4 01 00 00       	jmp    c0101f17 <trap_dispatch+0x220>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0101d43:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d48:	40                   	inc    %eax
c0101d49:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if(ticks % TICK_NUM == 0 )
c0101d4e:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d54:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d59:	89 c8                	mov    %ecx,%eax
c0101d5b:	f7 e2                	mul    %edx
c0101d5d:	c1 ea 05             	shr    $0x5,%edx
c0101d60:	89 d0                	mov    %edx,%eax
c0101d62:	c1 e0 02             	shl    $0x2,%eax
c0101d65:	01 d0                	add    %edx,%eax
c0101d67:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101d6e:	01 d0                	add    %edx,%eax
c0101d70:	c1 e0 02             	shl    $0x2,%eax
c0101d73:	29 c1                	sub    %eax,%ecx
c0101d75:	89 ca                	mov    %ecx,%edx
c0101d77:	85 d2                	test   %edx,%edx
c0101d79:	0f 85 d0 01 00 00    	jne    c0101f4f <trap_dispatch+0x258>
        {
          print_ticks();
c0101d7f:	e8 33 fb ff ff       	call   c01018b7 <print_ticks>
        }
        break;
c0101d84:	e9 c6 01 00 00       	jmp    c0101f4f <trap_dispatch+0x258>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d89:	e8 e6 f8 ff ff       	call   c0101674 <cons_getc>
c0101d8e:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d91:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0101d95:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0101d99:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da1:	c7 04 24 14 64 10 c0 	movl   $0xc0106414,(%esp)
c0101da8:	e8 f5 e4 ff ff       	call   c01002a2 <cprintf>
        break;
c0101dad:	e9 a4 01 00 00       	jmp    c0101f56 <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101db2:	e8 bd f8 ff ff       	call   c0101674 <cons_getc>
c0101db7:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101dba:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
c0101dbe:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
c0101dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dca:	c7 04 24 26 64 10 c0 	movl   $0xc0106426,(%esp)
c0101dd1:	e8 cc e4 ff ff       	call   c01002a2 <cprintf>
        break;
c0101dd6:	e9 7b 01 00 00       	jmp    c0101f56 <trap_dispatch+0x25f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
      if (tf->tf_cs!=USER_CS)
c0101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dde:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101de2:	83 f8 1b             	cmp    $0x1b,%eax
c0101de5:	0f 84 67 01 00 00    	je     c0101f52 <trap_dispatch+0x25b>
      {
        struct trapframe temp1 = *tf;//保留寄存器值
c0101deb:	8b 55 08             	mov    0x8(%ebp),%edx
c0101dee:	8d 45 97             	lea    -0x69(%ebp),%eax
c0101df1:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0101df6:	89 c1                	mov    %eax,%ecx
c0101df8:	83 e1 01             	and    $0x1,%ecx
c0101dfb:	85 c9                	test   %ecx,%ecx
c0101dfd:	74 0c                	je     c0101e0b <trap_dispatch+0x114>
c0101dff:	0f b6 0a             	movzbl (%edx),%ecx
c0101e02:	88 08                	mov    %cl,(%eax)
c0101e04:	8d 40 01             	lea    0x1(%eax),%eax
c0101e07:	8d 52 01             	lea    0x1(%edx),%edx
c0101e0a:	4b                   	dec    %ebx
c0101e0b:	89 c1                	mov    %eax,%ecx
c0101e0d:	83 e1 02             	and    $0x2,%ecx
c0101e10:	85 c9                	test   %ecx,%ecx
c0101e12:	74 0f                	je     c0101e23 <trap_dispatch+0x12c>
c0101e14:	0f b7 0a             	movzwl (%edx),%ecx
c0101e17:	66 89 08             	mov    %cx,(%eax)
c0101e1a:	8d 40 02             	lea    0x2(%eax),%eax
c0101e1d:	8d 52 02             	lea    0x2(%edx),%edx
c0101e20:	83 eb 02             	sub    $0x2,%ebx
c0101e23:	89 df                	mov    %ebx,%edi
c0101e25:	83 e7 fc             	and    $0xfffffffc,%edi
c0101e28:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101e2d:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0101e30:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0101e33:	83 c1 04             	add    $0x4,%ecx
c0101e36:	39 f9                	cmp    %edi,%ecx
c0101e38:	72 f3                	jb     c0101e2d <trap_dispatch+0x136>
c0101e3a:	01 c8                	add    %ecx,%eax
c0101e3c:	01 ca                	add    %ecx,%edx
c0101e3e:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101e43:	89 de                	mov    %ebx,%esi
c0101e45:	83 e6 02             	and    $0x2,%esi
c0101e48:	85 f6                	test   %esi,%esi
c0101e4a:	74 0b                	je     c0101e57 <trap_dispatch+0x160>
c0101e4c:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0101e50:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0101e54:	83 c1 02             	add    $0x2,%ecx
c0101e57:	83 e3 01             	and    $0x1,%ebx
c0101e5a:	85 db                	test   %ebx,%ebx
c0101e5c:	74 07                	je     c0101e65 <trap_dispatch+0x16e>
c0101e5e:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0101e62:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        temp1.tf_cs = USER_CS;
c0101e65:	66 c7 45 d3 1b 00    	movw   $0x1b,-0x2d(%ebp)
        temp1.tf_es = USER_DS;
c0101e6b:	66 c7 45 bf 23 00    	movw   $0x23,-0x41(%ebp)
        temp1.tf_ds=USER_DS;
c0101e71:	66 c7 45 c3 23 00    	movw   $0x23,-0x3d(%ebp)
        temp1.tf_ss = USER_DS;
c0101e77:	66 c7 45 df 23 00    	movw   $0x23,-0x21(%ebp)
        temp1.tf_esp=(uint32_t)tf+sizeof(struct trapframe) -8;
c0101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e80:	83 c0 44             	add    $0x44,%eax
c0101e83:	89 45 db             	mov    %eax,-0x25(%ebp)

        temp1.tf_eflags |=FL_IOPL_MASK;
c0101e86:	8b 45 d7             	mov    -0x29(%ebp),%eax
c0101e89:	0d 00 30 00 00       	or     $0x3000,%eax
c0101e8e:	89 45 d7             	mov    %eax,-0x29(%ebp)

        *((uint32_t *)tf -1) = (uint32_t) &temp1;
c0101e91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e94:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101e97:	8d 45 97             	lea    -0x69(%ebp),%eax
c0101e9a:	89 02                	mov    %eax,(%edx)
      }
      break;
c0101e9c:	e9 b1 00 00 00       	jmp    c0101f52 <trap_dispatch+0x25b>
    case T_SWITCH_TOK:
    if (tf->tf_cs != KERNEL_CS) {
c0101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ea8:	83 f8 08             	cmp    $0x8,%eax
c0101eab:	0f 84 a4 00 00 00    	je     c0101f55 <trap_dispatch+0x25e>
        tf->tf_cs = KERNEL_CS;
c0101eb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb4:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101eba:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ebd:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec6:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101eca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ecd:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
c0101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed4:	8b 40 40             	mov    0x40(%eax),%eax
c0101ed7:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101edc:	89 c2                	mov    %eax,%edx
c0101ede:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee1:	89 50 40             	mov    %edx,0x40(%eax)
        struct trapframe*  temp2 = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee7:	8b 40 44             	mov    0x44(%eax),%eax
c0101eea:	83 e8 44             	sub    $0x44,%eax
c0101eed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        memmove(temp2, tf, sizeof(struct trapframe) - 8);
c0101ef0:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101ef7:	00 
c0101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101efb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101f02:	89 04 24             	mov    %eax,(%esp)
c0101f05:	e8 20 38 00 00       	call   c010572a <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)temp2;
c0101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f0d:	8d 50 fc             	lea    -0x4(%eax),%edx
c0101f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101f13:	89 02                	mov    %eax,(%edx)
    }
        break;
c0101f15:	eb 3e                	jmp    c0101f55 <trap_dispatch+0x25e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101f17:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f1a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f1e:	83 e0 03             	and    $0x3,%eax
c0101f21:	85 c0                	test   %eax,%eax
c0101f23:	75 31                	jne    c0101f56 <trap_dispatch+0x25f>
            print_trapframe(tf);
c0101f25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f28:	89 04 24             	mov    %eax,(%esp)
c0101f2b:	e8 5c fb ff ff       	call   c0101a8c <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101f30:	c7 44 24 08 35 64 10 	movl   $0xc0106435,0x8(%esp)
c0101f37:	c0 
c0101f38:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0101f3f:	00 
c0101f40:	c7 04 24 51 64 10 c0 	movl   $0xc0106451,(%esp)
c0101f47:	e8 ad e4 ff ff       	call   c01003f9 <__panic>
        break;
c0101f4c:	90                   	nop
c0101f4d:	eb 07                	jmp    c0101f56 <trap_dispatch+0x25f>
        break;
c0101f4f:	90                   	nop
c0101f50:	eb 04                	jmp    c0101f56 <trap_dispatch+0x25f>
      break;
c0101f52:	90                   	nop
c0101f53:	eb 01                	jmp    c0101f56 <trap_dispatch+0x25f>
        break;
c0101f55:	90                   	nop
        }
    }
}
c0101f56:	90                   	nop
c0101f57:	83 c4 7c             	add    $0x7c,%esp
c0101f5a:	5b                   	pop    %ebx
c0101f5b:	5e                   	pop    %esi
c0101f5c:	5f                   	pop    %edi
c0101f5d:	5d                   	pop    %ebp
c0101f5e:	c3                   	ret    

c0101f5f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101f5f:	55                   	push   %ebp
c0101f60:	89 e5                	mov    %esp,%ebp
c0101f62:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101f65:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f68:	89 04 24             	mov    %eax,(%esp)
c0101f6b:	e8 87 fd ff ff       	call   c0101cf7 <trap_dispatch>
}
c0101f70:	90                   	nop
c0101f71:	c9                   	leave  
c0101f72:	c3                   	ret    

c0101f73 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101f73:	6a 00                	push   $0x0
  pushl $0
c0101f75:	6a 00                	push   $0x0
  jmp __alltraps
c0101f77:	e9 69 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101f7c <vector1>:
.globl vector1
vector1:
  pushl $0
c0101f7c:	6a 00                	push   $0x0
  pushl $1
c0101f7e:	6a 01                	push   $0x1
  jmp __alltraps
c0101f80:	e9 60 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101f85 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101f85:	6a 00                	push   $0x0
  pushl $2
c0101f87:	6a 02                	push   $0x2
  jmp __alltraps
c0101f89:	e9 57 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101f8e <vector3>:
.globl vector3
vector3:
  pushl $0
c0101f8e:	6a 00                	push   $0x0
  pushl $3
c0101f90:	6a 03                	push   $0x3
  jmp __alltraps
c0101f92:	e9 4e 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101f97 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101f97:	6a 00                	push   $0x0
  pushl $4
c0101f99:	6a 04                	push   $0x4
  jmp __alltraps
c0101f9b:	e9 45 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fa0 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101fa0:	6a 00                	push   $0x0
  pushl $5
c0101fa2:	6a 05                	push   $0x5
  jmp __alltraps
c0101fa4:	e9 3c 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fa9 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101fa9:	6a 00                	push   $0x0
  pushl $6
c0101fab:	6a 06                	push   $0x6
  jmp __alltraps
c0101fad:	e9 33 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fb2 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101fb2:	6a 00                	push   $0x0
  pushl $7
c0101fb4:	6a 07                	push   $0x7
  jmp __alltraps
c0101fb6:	e9 2a 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fbb <vector8>:
.globl vector8
vector8:
  pushl $8
c0101fbb:	6a 08                	push   $0x8
  jmp __alltraps
c0101fbd:	e9 23 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fc2 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101fc2:	6a 00                	push   $0x0
  pushl $9
c0101fc4:	6a 09                	push   $0x9
  jmp __alltraps
c0101fc6:	e9 1a 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fcb <vector10>:
.globl vector10
vector10:
  pushl $10
c0101fcb:	6a 0a                	push   $0xa
  jmp __alltraps
c0101fcd:	e9 13 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fd2 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101fd2:	6a 0b                	push   $0xb
  jmp __alltraps
c0101fd4:	e9 0c 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fd9 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101fd9:	6a 0c                	push   $0xc
  jmp __alltraps
c0101fdb:	e9 05 0a 00 00       	jmp    c01029e5 <__alltraps>

c0101fe0 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101fe0:	6a 0d                	push   $0xd
  jmp __alltraps
c0101fe2:	e9 fe 09 00 00       	jmp    c01029e5 <__alltraps>

c0101fe7 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101fe7:	6a 0e                	push   $0xe
  jmp __alltraps
c0101fe9:	e9 f7 09 00 00       	jmp    c01029e5 <__alltraps>

c0101fee <vector15>:
.globl vector15
vector15:
  pushl $0
c0101fee:	6a 00                	push   $0x0
  pushl $15
c0101ff0:	6a 0f                	push   $0xf
  jmp __alltraps
c0101ff2:	e9 ee 09 00 00       	jmp    c01029e5 <__alltraps>

c0101ff7 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101ff7:	6a 00                	push   $0x0
  pushl $16
c0101ff9:	6a 10                	push   $0x10
  jmp __alltraps
c0101ffb:	e9 e5 09 00 00       	jmp    c01029e5 <__alltraps>

c0102000 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102000:	6a 11                	push   $0x11
  jmp __alltraps
c0102002:	e9 de 09 00 00       	jmp    c01029e5 <__alltraps>

c0102007 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102007:	6a 00                	push   $0x0
  pushl $18
c0102009:	6a 12                	push   $0x12
  jmp __alltraps
c010200b:	e9 d5 09 00 00       	jmp    c01029e5 <__alltraps>

c0102010 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102010:	6a 00                	push   $0x0
  pushl $19
c0102012:	6a 13                	push   $0x13
  jmp __alltraps
c0102014:	e9 cc 09 00 00       	jmp    c01029e5 <__alltraps>

c0102019 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102019:	6a 00                	push   $0x0
  pushl $20
c010201b:	6a 14                	push   $0x14
  jmp __alltraps
c010201d:	e9 c3 09 00 00       	jmp    c01029e5 <__alltraps>

c0102022 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102022:	6a 00                	push   $0x0
  pushl $21
c0102024:	6a 15                	push   $0x15
  jmp __alltraps
c0102026:	e9 ba 09 00 00       	jmp    c01029e5 <__alltraps>

c010202b <vector22>:
.globl vector22
vector22:
  pushl $0
c010202b:	6a 00                	push   $0x0
  pushl $22
c010202d:	6a 16                	push   $0x16
  jmp __alltraps
c010202f:	e9 b1 09 00 00       	jmp    c01029e5 <__alltraps>

c0102034 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102034:	6a 00                	push   $0x0
  pushl $23
c0102036:	6a 17                	push   $0x17
  jmp __alltraps
c0102038:	e9 a8 09 00 00       	jmp    c01029e5 <__alltraps>

c010203d <vector24>:
.globl vector24
vector24:
  pushl $0
c010203d:	6a 00                	push   $0x0
  pushl $24
c010203f:	6a 18                	push   $0x18
  jmp __alltraps
c0102041:	e9 9f 09 00 00       	jmp    c01029e5 <__alltraps>

c0102046 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102046:	6a 00                	push   $0x0
  pushl $25
c0102048:	6a 19                	push   $0x19
  jmp __alltraps
c010204a:	e9 96 09 00 00       	jmp    c01029e5 <__alltraps>

c010204f <vector26>:
.globl vector26
vector26:
  pushl $0
c010204f:	6a 00                	push   $0x0
  pushl $26
c0102051:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102053:	e9 8d 09 00 00       	jmp    c01029e5 <__alltraps>

c0102058 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102058:	6a 00                	push   $0x0
  pushl $27
c010205a:	6a 1b                	push   $0x1b
  jmp __alltraps
c010205c:	e9 84 09 00 00       	jmp    c01029e5 <__alltraps>

c0102061 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102061:	6a 00                	push   $0x0
  pushl $28
c0102063:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102065:	e9 7b 09 00 00       	jmp    c01029e5 <__alltraps>

c010206a <vector29>:
.globl vector29
vector29:
  pushl $0
c010206a:	6a 00                	push   $0x0
  pushl $29
c010206c:	6a 1d                	push   $0x1d
  jmp __alltraps
c010206e:	e9 72 09 00 00       	jmp    c01029e5 <__alltraps>

c0102073 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102073:	6a 00                	push   $0x0
  pushl $30
c0102075:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102077:	e9 69 09 00 00       	jmp    c01029e5 <__alltraps>

c010207c <vector31>:
.globl vector31
vector31:
  pushl $0
c010207c:	6a 00                	push   $0x0
  pushl $31
c010207e:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102080:	e9 60 09 00 00       	jmp    c01029e5 <__alltraps>

c0102085 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102085:	6a 00                	push   $0x0
  pushl $32
c0102087:	6a 20                	push   $0x20
  jmp __alltraps
c0102089:	e9 57 09 00 00       	jmp    c01029e5 <__alltraps>

c010208e <vector33>:
.globl vector33
vector33:
  pushl $0
c010208e:	6a 00                	push   $0x0
  pushl $33
c0102090:	6a 21                	push   $0x21
  jmp __alltraps
c0102092:	e9 4e 09 00 00       	jmp    c01029e5 <__alltraps>

c0102097 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102097:	6a 00                	push   $0x0
  pushl $34
c0102099:	6a 22                	push   $0x22
  jmp __alltraps
c010209b:	e9 45 09 00 00       	jmp    c01029e5 <__alltraps>

c01020a0 <vector35>:
.globl vector35
vector35:
  pushl $0
c01020a0:	6a 00                	push   $0x0
  pushl $35
c01020a2:	6a 23                	push   $0x23
  jmp __alltraps
c01020a4:	e9 3c 09 00 00       	jmp    c01029e5 <__alltraps>

c01020a9 <vector36>:
.globl vector36
vector36:
  pushl $0
c01020a9:	6a 00                	push   $0x0
  pushl $36
c01020ab:	6a 24                	push   $0x24
  jmp __alltraps
c01020ad:	e9 33 09 00 00       	jmp    c01029e5 <__alltraps>

c01020b2 <vector37>:
.globl vector37
vector37:
  pushl $0
c01020b2:	6a 00                	push   $0x0
  pushl $37
c01020b4:	6a 25                	push   $0x25
  jmp __alltraps
c01020b6:	e9 2a 09 00 00       	jmp    c01029e5 <__alltraps>

c01020bb <vector38>:
.globl vector38
vector38:
  pushl $0
c01020bb:	6a 00                	push   $0x0
  pushl $38
c01020bd:	6a 26                	push   $0x26
  jmp __alltraps
c01020bf:	e9 21 09 00 00       	jmp    c01029e5 <__alltraps>

c01020c4 <vector39>:
.globl vector39
vector39:
  pushl $0
c01020c4:	6a 00                	push   $0x0
  pushl $39
c01020c6:	6a 27                	push   $0x27
  jmp __alltraps
c01020c8:	e9 18 09 00 00       	jmp    c01029e5 <__alltraps>

c01020cd <vector40>:
.globl vector40
vector40:
  pushl $0
c01020cd:	6a 00                	push   $0x0
  pushl $40
c01020cf:	6a 28                	push   $0x28
  jmp __alltraps
c01020d1:	e9 0f 09 00 00       	jmp    c01029e5 <__alltraps>

c01020d6 <vector41>:
.globl vector41
vector41:
  pushl $0
c01020d6:	6a 00                	push   $0x0
  pushl $41
c01020d8:	6a 29                	push   $0x29
  jmp __alltraps
c01020da:	e9 06 09 00 00       	jmp    c01029e5 <__alltraps>

c01020df <vector42>:
.globl vector42
vector42:
  pushl $0
c01020df:	6a 00                	push   $0x0
  pushl $42
c01020e1:	6a 2a                	push   $0x2a
  jmp __alltraps
c01020e3:	e9 fd 08 00 00       	jmp    c01029e5 <__alltraps>

c01020e8 <vector43>:
.globl vector43
vector43:
  pushl $0
c01020e8:	6a 00                	push   $0x0
  pushl $43
c01020ea:	6a 2b                	push   $0x2b
  jmp __alltraps
c01020ec:	e9 f4 08 00 00       	jmp    c01029e5 <__alltraps>

c01020f1 <vector44>:
.globl vector44
vector44:
  pushl $0
c01020f1:	6a 00                	push   $0x0
  pushl $44
c01020f3:	6a 2c                	push   $0x2c
  jmp __alltraps
c01020f5:	e9 eb 08 00 00       	jmp    c01029e5 <__alltraps>

c01020fa <vector45>:
.globl vector45
vector45:
  pushl $0
c01020fa:	6a 00                	push   $0x0
  pushl $45
c01020fc:	6a 2d                	push   $0x2d
  jmp __alltraps
c01020fe:	e9 e2 08 00 00       	jmp    c01029e5 <__alltraps>

c0102103 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102103:	6a 00                	push   $0x0
  pushl $46
c0102105:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102107:	e9 d9 08 00 00       	jmp    c01029e5 <__alltraps>

c010210c <vector47>:
.globl vector47
vector47:
  pushl $0
c010210c:	6a 00                	push   $0x0
  pushl $47
c010210e:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102110:	e9 d0 08 00 00       	jmp    c01029e5 <__alltraps>

c0102115 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102115:	6a 00                	push   $0x0
  pushl $48
c0102117:	6a 30                	push   $0x30
  jmp __alltraps
c0102119:	e9 c7 08 00 00       	jmp    c01029e5 <__alltraps>

c010211e <vector49>:
.globl vector49
vector49:
  pushl $0
c010211e:	6a 00                	push   $0x0
  pushl $49
c0102120:	6a 31                	push   $0x31
  jmp __alltraps
c0102122:	e9 be 08 00 00       	jmp    c01029e5 <__alltraps>

c0102127 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102127:	6a 00                	push   $0x0
  pushl $50
c0102129:	6a 32                	push   $0x32
  jmp __alltraps
c010212b:	e9 b5 08 00 00       	jmp    c01029e5 <__alltraps>

c0102130 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102130:	6a 00                	push   $0x0
  pushl $51
c0102132:	6a 33                	push   $0x33
  jmp __alltraps
c0102134:	e9 ac 08 00 00       	jmp    c01029e5 <__alltraps>

c0102139 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102139:	6a 00                	push   $0x0
  pushl $52
c010213b:	6a 34                	push   $0x34
  jmp __alltraps
c010213d:	e9 a3 08 00 00       	jmp    c01029e5 <__alltraps>

c0102142 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102142:	6a 00                	push   $0x0
  pushl $53
c0102144:	6a 35                	push   $0x35
  jmp __alltraps
c0102146:	e9 9a 08 00 00       	jmp    c01029e5 <__alltraps>

c010214b <vector54>:
.globl vector54
vector54:
  pushl $0
c010214b:	6a 00                	push   $0x0
  pushl $54
c010214d:	6a 36                	push   $0x36
  jmp __alltraps
c010214f:	e9 91 08 00 00       	jmp    c01029e5 <__alltraps>

c0102154 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102154:	6a 00                	push   $0x0
  pushl $55
c0102156:	6a 37                	push   $0x37
  jmp __alltraps
c0102158:	e9 88 08 00 00       	jmp    c01029e5 <__alltraps>

c010215d <vector56>:
.globl vector56
vector56:
  pushl $0
c010215d:	6a 00                	push   $0x0
  pushl $56
c010215f:	6a 38                	push   $0x38
  jmp __alltraps
c0102161:	e9 7f 08 00 00       	jmp    c01029e5 <__alltraps>

c0102166 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102166:	6a 00                	push   $0x0
  pushl $57
c0102168:	6a 39                	push   $0x39
  jmp __alltraps
c010216a:	e9 76 08 00 00       	jmp    c01029e5 <__alltraps>

c010216f <vector58>:
.globl vector58
vector58:
  pushl $0
c010216f:	6a 00                	push   $0x0
  pushl $58
c0102171:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102173:	e9 6d 08 00 00       	jmp    c01029e5 <__alltraps>

c0102178 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102178:	6a 00                	push   $0x0
  pushl $59
c010217a:	6a 3b                	push   $0x3b
  jmp __alltraps
c010217c:	e9 64 08 00 00       	jmp    c01029e5 <__alltraps>

c0102181 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102181:	6a 00                	push   $0x0
  pushl $60
c0102183:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102185:	e9 5b 08 00 00       	jmp    c01029e5 <__alltraps>

c010218a <vector61>:
.globl vector61
vector61:
  pushl $0
c010218a:	6a 00                	push   $0x0
  pushl $61
c010218c:	6a 3d                	push   $0x3d
  jmp __alltraps
c010218e:	e9 52 08 00 00       	jmp    c01029e5 <__alltraps>

c0102193 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102193:	6a 00                	push   $0x0
  pushl $62
c0102195:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102197:	e9 49 08 00 00       	jmp    c01029e5 <__alltraps>

c010219c <vector63>:
.globl vector63
vector63:
  pushl $0
c010219c:	6a 00                	push   $0x0
  pushl $63
c010219e:	6a 3f                	push   $0x3f
  jmp __alltraps
c01021a0:	e9 40 08 00 00       	jmp    c01029e5 <__alltraps>

c01021a5 <vector64>:
.globl vector64
vector64:
  pushl $0
c01021a5:	6a 00                	push   $0x0
  pushl $64
c01021a7:	6a 40                	push   $0x40
  jmp __alltraps
c01021a9:	e9 37 08 00 00       	jmp    c01029e5 <__alltraps>

c01021ae <vector65>:
.globl vector65
vector65:
  pushl $0
c01021ae:	6a 00                	push   $0x0
  pushl $65
c01021b0:	6a 41                	push   $0x41
  jmp __alltraps
c01021b2:	e9 2e 08 00 00       	jmp    c01029e5 <__alltraps>

c01021b7 <vector66>:
.globl vector66
vector66:
  pushl $0
c01021b7:	6a 00                	push   $0x0
  pushl $66
c01021b9:	6a 42                	push   $0x42
  jmp __alltraps
c01021bb:	e9 25 08 00 00       	jmp    c01029e5 <__alltraps>

c01021c0 <vector67>:
.globl vector67
vector67:
  pushl $0
c01021c0:	6a 00                	push   $0x0
  pushl $67
c01021c2:	6a 43                	push   $0x43
  jmp __alltraps
c01021c4:	e9 1c 08 00 00       	jmp    c01029e5 <__alltraps>

c01021c9 <vector68>:
.globl vector68
vector68:
  pushl $0
c01021c9:	6a 00                	push   $0x0
  pushl $68
c01021cb:	6a 44                	push   $0x44
  jmp __alltraps
c01021cd:	e9 13 08 00 00       	jmp    c01029e5 <__alltraps>

c01021d2 <vector69>:
.globl vector69
vector69:
  pushl $0
c01021d2:	6a 00                	push   $0x0
  pushl $69
c01021d4:	6a 45                	push   $0x45
  jmp __alltraps
c01021d6:	e9 0a 08 00 00       	jmp    c01029e5 <__alltraps>

c01021db <vector70>:
.globl vector70
vector70:
  pushl $0
c01021db:	6a 00                	push   $0x0
  pushl $70
c01021dd:	6a 46                	push   $0x46
  jmp __alltraps
c01021df:	e9 01 08 00 00       	jmp    c01029e5 <__alltraps>

c01021e4 <vector71>:
.globl vector71
vector71:
  pushl $0
c01021e4:	6a 00                	push   $0x0
  pushl $71
c01021e6:	6a 47                	push   $0x47
  jmp __alltraps
c01021e8:	e9 f8 07 00 00       	jmp    c01029e5 <__alltraps>

c01021ed <vector72>:
.globl vector72
vector72:
  pushl $0
c01021ed:	6a 00                	push   $0x0
  pushl $72
c01021ef:	6a 48                	push   $0x48
  jmp __alltraps
c01021f1:	e9 ef 07 00 00       	jmp    c01029e5 <__alltraps>

c01021f6 <vector73>:
.globl vector73
vector73:
  pushl $0
c01021f6:	6a 00                	push   $0x0
  pushl $73
c01021f8:	6a 49                	push   $0x49
  jmp __alltraps
c01021fa:	e9 e6 07 00 00       	jmp    c01029e5 <__alltraps>

c01021ff <vector74>:
.globl vector74
vector74:
  pushl $0
c01021ff:	6a 00                	push   $0x0
  pushl $74
c0102201:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102203:	e9 dd 07 00 00       	jmp    c01029e5 <__alltraps>

c0102208 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102208:	6a 00                	push   $0x0
  pushl $75
c010220a:	6a 4b                	push   $0x4b
  jmp __alltraps
c010220c:	e9 d4 07 00 00       	jmp    c01029e5 <__alltraps>

c0102211 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102211:	6a 00                	push   $0x0
  pushl $76
c0102213:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102215:	e9 cb 07 00 00       	jmp    c01029e5 <__alltraps>

c010221a <vector77>:
.globl vector77
vector77:
  pushl $0
c010221a:	6a 00                	push   $0x0
  pushl $77
c010221c:	6a 4d                	push   $0x4d
  jmp __alltraps
c010221e:	e9 c2 07 00 00       	jmp    c01029e5 <__alltraps>

c0102223 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102223:	6a 00                	push   $0x0
  pushl $78
c0102225:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102227:	e9 b9 07 00 00       	jmp    c01029e5 <__alltraps>

c010222c <vector79>:
.globl vector79
vector79:
  pushl $0
c010222c:	6a 00                	push   $0x0
  pushl $79
c010222e:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102230:	e9 b0 07 00 00       	jmp    c01029e5 <__alltraps>

c0102235 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102235:	6a 00                	push   $0x0
  pushl $80
c0102237:	6a 50                	push   $0x50
  jmp __alltraps
c0102239:	e9 a7 07 00 00       	jmp    c01029e5 <__alltraps>

c010223e <vector81>:
.globl vector81
vector81:
  pushl $0
c010223e:	6a 00                	push   $0x0
  pushl $81
c0102240:	6a 51                	push   $0x51
  jmp __alltraps
c0102242:	e9 9e 07 00 00       	jmp    c01029e5 <__alltraps>

c0102247 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102247:	6a 00                	push   $0x0
  pushl $82
c0102249:	6a 52                	push   $0x52
  jmp __alltraps
c010224b:	e9 95 07 00 00       	jmp    c01029e5 <__alltraps>

c0102250 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102250:	6a 00                	push   $0x0
  pushl $83
c0102252:	6a 53                	push   $0x53
  jmp __alltraps
c0102254:	e9 8c 07 00 00       	jmp    c01029e5 <__alltraps>

c0102259 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102259:	6a 00                	push   $0x0
  pushl $84
c010225b:	6a 54                	push   $0x54
  jmp __alltraps
c010225d:	e9 83 07 00 00       	jmp    c01029e5 <__alltraps>

c0102262 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102262:	6a 00                	push   $0x0
  pushl $85
c0102264:	6a 55                	push   $0x55
  jmp __alltraps
c0102266:	e9 7a 07 00 00       	jmp    c01029e5 <__alltraps>

c010226b <vector86>:
.globl vector86
vector86:
  pushl $0
c010226b:	6a 00                	push   $0x0
  pushl $86
c010226d:	6a 56                	push   $0x56
  jmp __alltraps
c010226f:	e9 71 07 00 00       	jmp    c01029e5 <__alltraps>

c0102274 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102274:	6a 00                	push   $0x0
  pushl $87
c0102276:	6a 57                	push   $0x57
  jmp __alltraps
c0102278:	e9 68 07 00 00       	jmp    c01029e5 <__alltraps>

c010227d <vector88>:
.globl vector88
vector88:
  pushl $0
c010227d:	6a 00                	push   $0x0
  pushl $88
c010227f:	6a 58                	push   $0x58
  jmp __alltraps
c0102281:	e9 5f 07 00 00       	jmp    c01029e5 <__alltraps>

c0102286 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102286:	6a 00                	push   $0x0
  pushl $89
c0102288:	6a 59                	push   $0x59
  jmp __alltraps
c010228a:	e9 56 07 00 00       	jmp    c01029e5 <__alltraps>

c010228f <vector90>:
.globl vector90
vector90:
  pushl $0
c010228f:	6a 00                	push   $0x0
  pushl $90
c0102291:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102293:	e9 4d 07 00 00       	jmp    c01029e5 <__alltraps>

c0102298 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102298:	6a 00                	push   $0x0
  pushl $91
c010229a:	6a 5b                	push   $0x5b
  jmp __alltraps
c010229c:	e9 44 07 00 00       	jmp    c01029e5 <__alltraps>

c01022a1 <vector92>:
.globl vector92
vector92:
  pushl $0
c01022a1:	6a 00                	push   $0x0
  pushl $92
c01022a3:	6a 5c                	push   $0x5c
  jmp __alltraps
c01022a5:	e9 3b 07 00 00       	jmp    c01029e5 <__alltraps>

c01022aa <vector93>:
.globl vector93
vector93:
  pushl $0
c01022aa:	6a 00                	push   $0x0
  pushl $93
c01022ac:	6a 5d                	push   $0x5d
  jmp __alltraps
c01022ae:	e9 32 07 00 00       	jmp    c01029e5 <__alltraps>

c01022b3 <vector94>:
.globl vector94
vector94:
  pushl $0
c01022b3:	6a 00                	push   $0x0
  pushl $94
c01022b5:	6a 5e                	push   $0x5e
  jmp __alltraps
c01022b7:	e9 29 07 00 00       	jmp    c01029e5 <__alltraps>

c01022bc <vector95>:
.globl vector95
vector95:
  pushl $0
c01022bc:	6a 00                	push   $0x0
  pushl $95
c01022be:	6a 5f                	push   $0x5f
  jmp __alltraps
c01022c0:	e9 20 07 00 00       	jmp    c01029e5 <__alltraps>

c01022c5 <vector96>:
.globl vector96
vector96:
  pushl $0
c01022c5:	6a 00                	push   $0x0
  pushl $96
c01022c7:	6a 60                	push   $0x60
  jmp __alltraps
c01022c9:	e9 17 07 00 00       	jmp    c01029e5 <__alltraps>

c01022ce <vector97>:
.globl vector97
vector97:
  pushl $0
c01022ce:	6a 00                	push   $0x0
  pushl $97
c01022d0:	6a 61                	push   $0x61
  jmp __alltraps
c01022d2:	e9 0e 07 00 00       	jmp    c01029e5 <__alltraps>

c01022d7 <vector98>:
.globl vector98
vector98:
  pushl $0
c01022d7:	6a 00                	push   $0x0
  pushl $98
c01022d9:	6a 62                	push   $0x62
  jmp __alltraps
c01022db:	e9 05 07 00 00       	jmp    c01029e5 <__alltraps>

c01022e0 <vector99>:
.globl vector99
vector99:
  pushl $0
c01022e0:	6a 00                	push   $0x0
  pushl $99
c01022e2:	6a 63                	push   $0x63
  jmp __alltraps
c01022e4:	e9 fc 06 00 00       	jmp    c01029e5 <__alltraps>

c01022e9 <vector100>:
.globl vector100
vector100:
  pushl $0
c01022e9:	6a 00                	push   $0x0
  pushl $100
c01022eb:	6a 64                	push   $0x64
  jmp __alltraps
c01022ed:	e9 f3 06 00 00       	jmp    c01029e5 <__alltraps>

c01022f2 <vector101>:
.globl vector101
vector101:
  pushl $0
c01022f2:	6a 00                	push   $0x0
  pushl $101
c01022f4:	6a 65                	push   $0x65
  jmp __alltraps
c01022f6:	e9 ea 06 00 00       	jmp    c01029e5 <__alltraps>

c01022fb <vector102>:
.globl vector102
vector102:
  pushl $0
c01022fb:	6a 00                	push   $0x0
  pushl $102
c01022fd:	6a 66                	push   $0x66
  jmp __alltraps
c01022ff:	e9 e1 06 00 00       	jmp    c01029e5 <__alltraps>

c0102304 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102304:	6a 00                	push   $0x0
  pushl $103
c0102306:	6a 67                	push   $0x67
  jmp __alltraps
c0102308:	e9 d8 06 00 00       	jmp    c01029e5 <__alltraps>

c010230d <vector104>:
.globl vector104
vector104:
  pushl $0
c010230d:	6a 00                	push   $0x0
  pushl $104
c010230f:	6a 68                	push   $0x68
  jmp __alltraps
c0102311:	e9 cf 06 00 00       	jmp    c01029e5 <__alltraps>

c0102316 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102316:	6a 00                	push   $0x0
  pushl $105
c0102318:	6a 69                	push   $0x69
  jmp __alltraps
c010231a:	e9 c6 06 00 00       	jmp    c01029e5 <__alltraps>

c010231f <vector106>:
.globl vector106
vector106:
  pushl $0
c010231f:	6a 00                	push   $0x0
  pushl $106
c0102321:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102323:	e9 bd 06 00 00       	jmp    c01029e5 <__alltraps>

c0102328 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102328:	6a 00                	push   $0x0
  pushl $107
c010232a:	6a 6b                	push   $0x6b
  jmp __alltraps
c010232c:	e9 b4 06 00 00       	jmp    c01029e5 <__alltraps>

c0102331 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102331:	6a 00                	push   $0x0
  pushl $108
c0102333:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102335:	e9 ab 06 00 00       	jmp    c01029e5 <__alltraps>

c010233a <vector109>:
.globl vector109
vector109:
  pushl $0
c010233a:	6a 00                	push   $0x0
  pushl $109
c010233c:	6a 6d                	push   $0x6d
  jmp __alltraps
c010233e:	e9 a2 06 00 00       	jmp    c01029e5 <__alltraps>

c0102343 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102343:	6a 00                	push   $0x0
  pushl $110
c0102345:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102347:	e9 99 06 00 00       	jmp    c01029e5 <__alltraps>

c010234c <vector111>:
.globl vector111
vector111:
  pushl $0
c010234c:	6a 00                	push   $0x0
  pushl $111
c010234e:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102350:	e9 90 06 00 00       	jmp    c01029e5 <__alltraps>

c0102355 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102355:	6a 00                	push   $0x0
  pushl $112
c0102357:	6a 70                	push   $0x70
  jmp __alltraps
c0102359:	e9 87 06 00 00       	jmp    c01029e5 <__alltraps>

c010235e <vector113>:
.globl vector113
vector113:
  pushl $0
c010235e:	6a 00                	push   $0x0
  pushl $113
c0102360:	6a 71                	push   $0x71
  jmp __alltraps
c0102362:	e9 7e 06 00 00       	jmp    c01029e5 <__alltraps>

c0102367 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102367:	6a 00                	push   $0x0
  pushl $114
c0102369:	6a 72                	push   $0x72
  jmp __alltraps
c010236b:	e9 75 06 00 00       	jmp    c01029e5 <__alltraps>

c0102370 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102370:	6a 00                	push   $0x0
  pushl $115
c0102372:	6a 73                	push   $0x73
  jmp __alltraps
c0102374:	e9 6c 06 00 00       	jmp    c01029e5 <__alltraps>

c0102379 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102379:	6a 00                	push   $0x0
  pushl $116
c010237b:	6a 74                	push   $0x74
  jmp __alltraps
c010237d:	e9 63 06 00 00       	jmp    c01029e5 <__alltraps>

c0102382 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102382:	6a 00                	push   $0x0
  pushl $117
c0102384:	6a 75                	push   $0x75
  jmp __alltraps
c0102386:	e9 5a 06 00 00       	jmp    c01029e5 <__alltraps>

c010238b <vector118>:
.globl vector118
vector118:
  pushl $0
c010238b:	6a 00                	push   $0x0
  pushl $118
c010238d:	6a 76                	push   $0x76
  jmp __alltraps
c010238f:	e9 51 06 00 00       	jmp    c01029e5 <__alltraps>

c0102394 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102394:	6a 00                	push   $0x0
  pushl $119
c0102396:	6a 77                	push   $0x77
  jmp __alltraps
c0102398:	e9 48 06 00 00       	jmp    c01029e5 <__alltraps>

c010239d <vector120>:
.globl vector120
vector120:
  pushl $0
c010239d:	6a 00                	push   $0x0
  pushl $120
c010239f:	6a 78                	push   $0x78
  jmp __alltraps
c01023a1:	e9 3f 06 00 00       	jmp    c01029e5 <__alltraps>

c01023a6 <vector121>:
.globl vector121
vector121:
  pushl $0
c01023a6:	6a 00                	push   $0x0
  pushl $121
c01023a8:	6a 79                	push   $0x79
  jmp __alltraps
c01023aa:	e9 36 06 00 00       	jmp    c01029e5 <__alltraps>

c01023af <vector122>:
.globl vector122
vector122:
  pushl $0
c01023af:	6a 00                	push   $0x0
  pushl $122
c01023b1:	6a 7a                	push   $0x7a
  jmp __alltraps
c01023b3:	e9 2d 06 00 00       	jmp    c01029e5 <__alltraps>

c01023b8 <vector123>:
.globl vector123
vector123:
  pushl $0
c01023b8:	6a 00                	push   $0x0
  pushl $123
c01023ba:	6a 7b                	push   $0x7b
  jmp __alltraps
c01023bc:	e9 24 06 00 00       	jmp    c01029e5 <__alltraps>

c01023c1 <vector124>:
.globl vector124
vector124:
  pushl $0
c01023c1:	6a 00                	push   $0x0
  pushl $124
c01023c3:	6a 7c                	push   $0x7c
  jmp __alltraps
c01023c5:	e9 1b 06 00 00       	jmp    c01029e5 <__alltraps>

c01023ca <vector125>:
.globl vector125
vector125:
  pushl $0
c01023ca:	6a 00                	push   $0x0
  pushl $125
c01023cc:	6a 7d                	push   $0x7d
  jmp __alltraps
c01023ce:	e9 12 06 00 00       	jmp    c01029e5 <__alltraps>

c01023d3 <vector126>:
.globl vector126
vector126:
  pushl $0
c01023d3:	6a 00                	push   $0x0
  pushl $126
c01023d5:	6a 7e                	push   $0x7e
  jmp __alltraps
c01023d7:	e9 09 06 00 00       	jmp    c01029e5 <__alltraps>

c01023dc <vector127>:
.globl vector127
vector127:
  pushl $0
c01023dc:	6a 00                	push   $0x0
  pushl $127
c01023de:	6a 7f                	push   $0x7f
  jmp __alltraps
c01023e0:	e9 00 06 00 00       	jmp    c01029e5 <__alltraps>

c01023e5 <vector128>:
.globl vector128
vector128:
  pushl $0
c01023e5:	6a 00                	push   $0x0
  pushl $128
c01023e7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01023ec:	e9 f4 05 00 00       	jmp    c01029e5 <__alltraps>

c01023f1 <vector129>:
.globl vector129
vector129:
  pushl $0
c01023f1:	6a 00                	push   $0x0
  pushl $129
c01023f3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01023f8:	e9 e8 05 00 00       	jmp    c01029e5 <__alltraps>

c01023fd <vector130>:
.globl vector130
vector130:
  pushl $0
c01023fd:	6a 00                	push   $0x0
  pushl $130
c01023ff:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102404:	e9 dc 05 00 00       	jmp    c01029e5 <__alltraps>

c0102409 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102409:	6a 00                	push   $0x0
  pushl $131
c010240b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102410:	e9 d0 05 00 00       	jmp    c01029e5 <__alltraps>

c0102415 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102415:	6a 00                	push   $0x0
  pushl $132
c0102417:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010241c:	e9 c4 05 00 00       	jmp    c01029e5 <__alltraps>

c0102421 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102421:	6a 00                	push   $0x0
  pushl $133
c0102423:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102428:	e9 b8 05 00 00       	jmp    c01029e5 <__alltraps>

c010242d <vector134>:
.globl vector134
vector134:
  pushl $0
c010242d:	6a 00                	push   $0x0
  pushl $134
c010242f:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102434:	e9 ac 05 00 00       	jmp    c01029e5 <__alltraps>

c0102439 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102439:	6a 00                	push   $0x0
  pushl $135
c010243b:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102440:	e9 a0 05 00 00       	jmp    c01029e5 <__alltraps>

c0102445 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102445:	6a 00                	push   $0x0
  pushl $136
c0102447:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010244c:	e9 94 05 00 00       	jmp    c01029e5 <__alltraps>

c0102451 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102451:	6a 00                	push   $0x0
  pushl $137
c0102453:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102458:	e9 88 05 00 00       	jmp    c01029e5 <__alltraps>

c010245d <vector138>:
.globl vector138
vector138:
  pushl $0
c010245d:	6a 00                	push   $0x0
  pushl $138
c010245f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102464:	e9 7c 05 00 00       	jmp    c01029e5 <__alltraps>

c0102469 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102469:	6a 00                	push   $0x0
  pushl $139
c010246b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102470:	e9 70 05 00 00       	jmp    c01029e5 <__alltraps>

c0102475 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102475:	6a 00                	push   $0x0
  pushl $140
c0102477:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010247c:	e9 64 05 00 00       	jmp    c01029e5 <__alltraps>

c0102481 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102481:	6a 00                	push   $0x0
  pushl $141
c0102483:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102488:	e9 58 05 00 00       	jmp    c01029e5 <__alltraps>

c010248d <vector142>:
.globl vector142
vector142:
  pushl $0
c010248d:	6a 00                	push   $0x0
  pushl $142
c010248f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102494:	e9 4c 05 00 00       	jmp    c01029e5 <__alltraps>

c0102499 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102499:	6a 00                	push   $0x0
  pushl $143
c010249b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01024a0:	e9 40 05 00 00       	jmp    c01029e5 <__alltraps>

c01024a5 <vector144>:
.globl vector144
vector144:
  pushl $0
c01024a5:	6a 00                	push   $0x0
  pushl $144
c01024a7:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01024ac:	e9 34 05 00 00       	jmp    c01029e5 <__alltraps>

c01024b1 <vector145>:
.globl vector145
vector145:
  pushl $0
c01024b1:	6a 00                	push   $0x0
  pushl $145
c01024b3:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01024b8:	e9 28 05 00 00       	jmp    c01029e5 <__alltraps>

c01024bd <vector146>:
.globl vector146
vector146:
  pushl $0
c01024bd:	6a 00                	push   $0x0
  pushl $146
c01024bf:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01024c4:	e9 1c 05 00 00       	jmp    c01029e5 <__alltraps>

c01024c9 <vector147>:
.globl vector147
vector147:
  pushl $0
c01024c9:	6a 00                	push   $0x0
  pushl $147
c01024cb:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01024d0:	e9 10 05 00 00       	jmp    c01029e5 <__alltraps>

c01024d5 <vector148>:
.globl vector148
vector148:
  pushl $0
c01024d5:	6a 00                	push   $0x0
  pushl $148
c01024d7:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01024dc:	e9 04 05 00 00       	jmp    c01029e5 <__alltraps>

c01024e1 <vector149>:
.globl vector149
vector149:
  pushl $0
c01024e1:	6a 00                	push   $0x0
  pushl $149
c01024e3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01024e8:	e9 f8 04 00 00       	jmp    c01029e5 <__alltraps>

c01024ed <vector150>:
.globl vector150
vector150:
  pushl $0
c01024ed:	6a 00                	push   $0x0
  pushl $150
c01024ef:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01024f4:	e9 ec 04 00 00       	jmp    c01029e5 <__alltraps>

c01024f9 <vector151>:
.globl vector151
vector151:
  pushl $0
c01024f9:	6a 00                	push   $0x0
  pushl $151
c01024fb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102500:	e9 e0 04 00 00       	jmp    c01029e5 <__alltraps>

c0102505 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102505:	6a 00                	push   $0x0
  pushl $152
c0102507:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010250c:	e9 d4 04 00 00       	jmp    c01029e5 <__alltraps>

c0102511 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102511:	6a 00                	push   $0x0
  pushl $153
c0102513:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102518:	e9 c8 04 00 00       	jmp    c01029e5 <__alltraps>

c010251d <vector154>:
.globl vector154
vector154:
  pushl $0
c010251d:	6a 00                	push   $0x0
  pushl $154
c010251f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102524:	e9 bc 04 00 00       	jmp    c01029e5 <__alltraps>

c0102529 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102529:	6a 00                	push   $0x0
  pushl $155
c010252b:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102530:	e9 b0 04 00 00       	jmp    c01029e5 <__alltraps>

c0102535 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102535:	6a 00                	push   $0x0
  pushl $156
c0102537:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010253c:	e9 a4 04 00 00       	jmp    c01029e5 <__alltraps>

c0102541 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102541:	6a 00                	push   $0x0
  pushl $157
c0102543:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102548:	e9 98 04 00 00       	jmp    c01029e5 <__alltraps>

c010254d <vector158>:
.globl vector158
vector158:
  pushl $0
c010254d:	6a 00                	push   $0x0
  pushl $158
c010254f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102554:	e9 8c 04 00 00       	jmp    c01029e5 <__alltraps>

c0102559 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102559:	6a 00                	push   $0x0
  pushl $159
c010255b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102560:	e9 80 04 00 00       	jmp    c01029e5 <__alltraps>

c0102565 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102565:	6a 00                	push   $0x0
  pushl $160
c0102567:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010256c:	e9 74 04 00 00       	jmp    c01029e5 <__alltraps>

c0102571 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102571:	6a 00                	push   $0x0
  pushl $161
c0102573:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102578:	e9 68 04 00 00       	jmp    c01029e5 <__alltraps>

c010257d <vector162>:
.globl vector162
vector162:
  pushl $0
c010257d:	6a 00                	push   $0x0
  pushl $162
c010257f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102584:	e9 5c 04 00 00       	jmp    c01029e5 <__alltraps>

c0102589 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102589:	6a 00                	push   $0x0
  pushl $163
c010258b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102590:	e9 50 04 00 00       	jmp    c01029e5 <__alltraps>

c0102595 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102595:	6a 00                	push   $0x0
  pushl $164
c0102597:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010259c:	e9 44 04 00 00       	jmp    c01029e5 <__alltraps>

c01025a1 <vector165>:
.globl vector165
vector165:
  pushl $0
c01025a1:	6a 00                	push   $0x0
  pushl $165
c01025a3:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01025a8:	e9 38 04 00 00       	jmp    c01029e5 <__alltraps>

c01025ad <vector166>:
.globl vector166
vector166:
  pushl $0
c01025ad:	6a 00                	push   $0x0
  pushl $166
c01025af:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01025b4:	e9 2c 04 00 00       	jmp    c01029e5 <__alltraps>

c01025b9 <vector167>:
.globl vector167
vector167:
  pushl $0
c01025b9:	6a 00                	push   $0x0
  pushl $167
c01025bb:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01025c0:	e9 20 04 00 00       	jmp    c01029e5 <__alltraps>

c01025c5 <vector168>:
.globl vector168
vector168:
  pushl $0
c01025c5:	6a 00                	push   $0x0
  pushl $168
c01025c7:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01025cc:	e9 14 04 00 00       	jmp    c01029e5 <__alltraps>

c01025d1 <vector169>:
.globl vector169
vector169:
  pushl $0
c01025d1:	6a 00                	push   $0x0
  pushl $169
c01025d3:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01025d8:	e9 08 04 00 00       	jmp    c01029e5 <__alltraps>

c01025dd <vector170>:
.globl vector170
vector170:
  pushl $0
c01025dd:	6a 00                	push   $0x0
  pushl $170
c01025df:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01025e4:	e9 fc 03 00 00       	jmp    c01029e5 <__alltraps>

c01025e9 <vector171>:
.globl vector171
vector171:
  pushl $0
c01025e9:	6a 00                	push   $0x0
  pushl $171
c01025eb:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01025f0:	e9 f0 03 00 00       	jmp    c01029e5 <__alltraps>

c01025f5 <vector172>:
.globl vector172
vector172:
  pushl $0
c01025f5:	6a 00                	push   $0x0
  pushl $172
c01025f7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01025fc:	e9 e4 03 00 00       	jmp    c01029e5 <__alltraps>

c0102601 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102601:	6a 00                	push   $0x0
  pushl $173
c0102603:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102608:	e9 d8 03 00 00       	jmp    c01029e5 <__alltraps>

c010260d <vector174>:
.globl vector174
vector174:
  pushl $0
c010260d:	6a 00                	push   $0x0
  pushl $174
c010260f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102614:	e9 cc 03 00 00       	jmp    c01029e5 <__alltraps>

c0102619 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102619:	6a 00                	push   $0x0
  pushl $175
c010261b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102620:	e9 c0 03 00 00       	jmp    c01029e5 <__alltraps>

c0102625 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102625:	6a 00                	push   $0x0
  pushl $176
c0102627:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010262c:	e9 b4 03 00 00       	jmp    c01029e5 <__alltraps>

c0102631 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102631:	6a 00                	push   $0x0
  pushl $177
c0102633:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102638:	e9 a8 03 00 00       	jmp    c01029e5 <__alltraps>

c010263d <vector178>:
.globl vector178
vector178:
  pushl $0
c010263d:	6a 00                	push   $0x0
  pushl $178
c010263f:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102644:	e9 9c 03 00 00       	jmp    c01029e5 <__alltraps>

c0102649 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102649:	6a 00                	push   $0x0
  pushl $179
c010264b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102650:	e9 90 03 00 00       	jmp    c01029e5 <__alltraps>

c0102655 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102655:	6a 00                	push   $0x0
  pushl $180
c0102657:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010265c:	e9 84 03 00 00       	jmp    c01029e5 <__alltraps>

c0102661 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102661:	6a 00                	push   $0x0
  pushl $181
c0102663:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102668:	e9 78 03 00 00       	jmp    c01029e5 <__alltraps>

c010266d <vector182>:
.globl vector182
vector182:
  pushl $0
c010266d:	6a 00                	push   $0x0
  pushl $182
c010266f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102674:	e9 6c 03 00 00       	jmp    c01029e5 <__alltraps>

c0102679 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102679:	6a 00                	push   $0x0
  pushl $183
c010267b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102680:	e9 60 03 00 00       	jmp    c01029e5 <__alltraps>

c0102685 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102685:	6a 00                	push   $0x0
  pushl $184
c0102687:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010268c:	e9 54 03 00 00       	jmp    c01029e5 <__alltraps>

c0102691 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102691:	6a 00                	push   $0x0
  pushl $185
c0102693:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102698:	e9 48 03 00 00       	jmp    c01029e5 <__alltraps>

c010269d <vector186>:
.globl vector186
vector186:
  pushl $0
c010269d:	6a 00                	push   $0x0
  pushl $186
c010269f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01026a4:	e9 3c 03 00 00       	jmp    c01029e5 <__alltraps>

c01026a9 <vector187>:
.globl vector187
vector187:
  pushl $0
c01026a9:	6a 00                	push   $0x0
  pushl $187
c01026ab:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01026b0:	e9 30 03 00 00       	jmp    c01029e5 <__alltraps>

c01026b5 <vector188>:
.globl vector188
vector188:
  pushl $0
c01026b5:	6a 00                	push   $0x0
  pushl $188
c01026b7:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01026bc:	e9 24 03 00 00       	jmp    c01029e5 <__alltraps>

c01026c1 <vector189>:
.globl vector189
vector189:
  pushl $0
c01026c1:	6a 00                	push   $0x0
  pushl $189
c01026c3:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01026c8:	e9 18 03 00 00       	jmp    c01029e5 <__alltraps>

c01026cd <vector190>:
.globl vector190
vector190:
  pushl $0
c01026cd:	6a 00                	push   $0x0
  pushl $190
c01026cf:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01026d4:	e9 0c 03 00 00       	jmp    c01029e5 <__alltraps>

c01026d9 <vector191>:
.globl vector191
vector191:
  pushl $0
c01026d9:	6a 00                	push   $0x0
  pushl $191
c01026db:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01026e0:	e9 00 03 00 00       	jmp    c01029e5 <__alltraps>

c01026e5 <vector192>:
.globl vector192
vector192:
  pushl $0
c01026e5:	6a 00                	push   $0x0
  pushl $192
c01026e7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01026ec:	e9 f4 02 00 00       	jmp    c01029e5 <__alltraps>

c01026f1 <vector193>:
.globl vector193
vector193:
  pushl $0
c01026f1:	6a 00                	push   $0x0
  pushl $193
c01026f3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01026f8:	e9 e8 02 00 00       	jmp    c01029e5 <__alltraps>

c01026fd <vector194>:
.globl vector194
vector194:
  pushl $0
c01026fd:	6a 00                	push   $0x0
  pushl $194
c01026ff:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102704:	e9 dc 02 00 00       	jmp    c01029e5 <__alltraps>

c0102709 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102709:	6a 00                	push   $0x0
  pushl $195
c010270b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102710:	e9 d0 02 00 00       	jmp    c01029e5 <__alltraps>

c0102715 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102715:	6a 00                	push   $0x0
  pushl $196
c0102717:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010271c:	e9 c4 02 00 00       	jmp    c01029e5 <__alltraps>

c0102721 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102721:	6a 00                	push   $0x0
  pushl $197
c0102723:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102728:	e9 b8 02 00 00       	jmp    c01029e5 <__alltraps>

c010272d <vector198>:
.globl vector198
vector198:
  pushl $0
c010272d:	6a 00                	push   $0x0
  pushl $198
c010272f:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102734:	e9 ac 02 00 00       	jmp    c01029e5 <__alltraps>

c0102739 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102739:	6a 00                	push   $0x0
  pushl $199
c010273b:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102740:	e9 a0 02 00 00       	jmp    c01029e5 <__alltraps>

c0102745 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $200
c0102747:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010274c:	e9 94 02 00 00       	jmp    c01029e5 <__alltraps>

c0102751 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102751:	6a 00                	push   $0x0
  pushl $201
c0102753:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102758:	e9 88 02 00 00       	jmp    c01029e5 <__alltraps>

c010275d <vector202>:
.globl vector202
vector202:
  pushl $0
c010275d:	6a 00                	push   $0x0
  pushl $202
c010275f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102764:	e9 7c 02 00 00       	jmp    c01029e5 <__alltraps>

c0102769 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $203
c010276b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102770:	e9 70 02 00 00       	jmp    c01029e5 <__alltraps>

c0102775 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102775:	6a 00                	push   $0x0
  pushl $204
c0102777:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010277c:	e9 64 02 00 00       	jmp    c01029e5 <__alltraps>

c0102781 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102781:	6a 00                	push   $0x0
  pushl $205
c0102783:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102788:	e9 58 02 00 00       	jmp    c01029e5 <__alltraps>

c010278d <vector206>:
.globl vector206
vector206:
  pushl $0
c010278d:	6a 00                	push   $0x0
  pushl $206
c010278f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102794:	e9 4c 02 00 00       	jmp    c01029e5 <__alltraps>

c0102799 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102799:	6a 00                	push   $0x0
  pushl $207
c010279b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01027a0:	e9 40 02 00 00       	jmp    c01029e5 <__alltraps>

c01027a5 <vector208>:
.globl vector208
vector208:
  pushl $0
c01027a5:	6a 00                	push   $0x0
  pushl $208
c01027a7:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01027ac:	e9 34 02 00 00       	jmp    c01029e5 <__alltraps>

c01027b1 <vector209>:
.globl vector209
vector209:
  pushl $0
c01027b1:	6a 00                	push   $0x0
  pushl $209
c01027b3:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01027b8:	e9 28 02 00 00       	jmp    c01029e5 <__alltraps>

c01027bd <vector210>:
.globl vector210
vector210:
  pushl $0
c01027bd:	6a 00                	push   $0x0
  pushl $210
c01027bf:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01027c4:	e9 1c 02 00 00       	jmp    c01029e5 <__alltraps>

c01027c9 <vector211>:
.globl vector211
vector211:
  pushl $0
c01027c9:	6a 00                	push   $0x0
  pushl $211
c01027cb:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01027d0:	e9 10 02 00 00       	jmp    c01029e5 <__alltraps>

c01027d5 <vector212>:
.globl vector212
vector212:
  pushl $0
c01027d5:	6a 00                	push   $0x0
  pushl $212
c01027d7:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01027dc:	e9 04 02 00 00       	jmp    c01029e5 <__alltraps>

c01027e1 <vector213>:
.globl vector213
vector213:
  pushl $0
c01027e1:	6a 00                	push   $0x0
  pushl $213
c01027e3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01027e8:	e9 f8 01 00 00       	jmp    c01029e5 <__alltraps>

c01027ed <vector214>:
.globl vector214
vector214:
  pushl $0
c01027ed:	6a 00                	push   $0x0
  pushl $214
c01027ef:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01027f4:	e9 ec 01 00 00       	jmp    c01029e5 <__alltraps>

c01027f9 <vector215>:
.globl vector215
vector215:
  pushl $0
c01027f9:	6a 00                	push   $0x0
  pushl $215
c01027fb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102800:	e9 e0 01 00 00       	jmp    c01029e5 <__alltraps>

c0102805 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102805:	6a 00                	push   $0x0
  pushl $216
c0102807:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010280c:	e9 d4 01 00 00       	jmp    c01029e5 <__alltraps>

c0102811 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102811:	6a 00                	push   $0x0
  pushl $217
c0102813:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102818:	e9 c8 01 00 00       	jmp    c01029e5 <__alltraps>

c010281d <vector218>:
.globl vector218
vector218:
  pushl $0
c010281d:	6a 00                	push   $0x0
  pushl $218
c010281f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102824:	e9 bc 01 00 00       	jmp    c01029e5 <__alltraps>

c0102829 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102829:	6a 00                	push   $0x0
  pushl $219
c010282b:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102830:	e9 b0 01 00 00       	jmp    c01029e5 <__alltraps>

c0102835 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102835:	6a 00                	push   $0x0
  pushl $220
c0102837:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010283c:	e9 a4 01 00 00       	jmp    c01029e5 <__alltraps>

c0102841 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $221
c0102843:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102848:	e9 98 01 00 00       	jmp    c01029e5 <__alltraps>

c010284d <vector222>:
.globl vector222
vector222:
  pushl $0
c010284d:	6a 00                	push   $0x0
  pushl $222
c010284f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102854:	e9 8c 01 00 00       	jmp    c01029e5 <__alltraps>

c0102859 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102859:	6a 00                	push   $0x0
  pushl $223
c010285b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102860:	e9 80 01 00 00       	jmp    c01029e5 <__alltraps>

c0102865 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $224
c0102867:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010286c:	e9 74 01 00 00       	jmp    c01029e5 <__alltraps>

c0102871 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102871:	6a 00                	push   $0x0
  pushl $225
c0102873:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102878:	e9 68 01 00 00       	jmp    c01029e5 <__alltraps>

c010287d <vector226>:
.globl vector226
vector226:
  pushl $0
c010287d:	6a 00                	push   $0x0
  pushl $226
c010287f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102884:	e9 5c 01 00 00       	jmp    c01029e5 <__alltraps>

c0102889 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $227
c010288b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102890:	e9 50 01 00 00       	jmp    c01029e5 <__alltraps>

c0102895 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102895:	6a 00                	push   $0x0
  pushl $228
c0102897:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010289c:	e9 44 01 00 00       	jmp    c01029e5 <__alltraps>

c01028a1 <vector229>:
.globl vector229
vector229:
  pushl $0
c01028a1:	6a 00                	push   $0x0
  pushl $229
c01028a3:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01028a8:	e9 38 01 00 00       	jmp    c01029e5 <__alltraps>

c01028ad <vector230>:
.globl vector230
vector230:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $230
c01028af:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01028b4:	e9 2c 01 00 00       	jmp    c01029e5 <__alltraps>

c01028b9 <vector231>:
.globl vector231
vector231:
  pushl $0
c01028b9:	6a 00                	push   $0x0
  pushl $231
c01028bb:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01028c0:	e9 20 01 00 00       	jmp    c01029e5 <__alltraps>

c01028c5 <vector232>:
.globl vector232
vector232:
  pushl $0
c01028c5:	6a 00                	push   $0x0
  pushl $232
c01028c7:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01028cc:	e9 14 01 00 00       	jmp    c01029e5 <__alltraps>

c01028d1 <vector233>:
.globl vector233
vector233:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $233
c01028d3:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01028d8:	e9 08 01 00 00       	jmp    c01029e5 <__alltraps>

c01028dd <vector234>:
.globl vector234
vector234:
  pushl $0
c01028dd:	6a 00                	push   $0x0
  pushl $234
c01028df:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01028e4:	e9 fc 00 00 00       	jmp    c01029e5 <__alltraps>

c01028e9 <vector235>:
.globl vector235
vector235:
  pushl $0
c01028e9:	6a 00                	push   $0x0
  pushl $235
c01028eb:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01028f0:	e9 f0 00 00 00       	jmp    c01029e5 <__alltraps>

c01028f5 <vector236>:
.globl vector236
vector236:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $236
c01028f7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01028fc:	e9 e4 00 00 00       	jmp    c01029e5 <__alltraps>

c0102901 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102901:	6a 00                	push   $0x0
  pushl $237
c0102903:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102908:	e9 d8 00 00 00       	jmp    c01029e5 <__alltraps>

c010290d <vector238>:
.globl vector238
vector238:
  pushl $0
c010290d:	6a 00                	push   $0x0
  pushl $238
c010290f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102914:	e9 cc 00 00 00       	jmp    c01029e5 <__alltraps>

c0102919 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $239
c010291b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102920:	e9 c0 00 00 00       	jmp    c01029e5 <__alltraps>

c0102925 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102925:	6a 00                	push   $0x0
  pushl $240
c0102927:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010292c:	e9 b4 00 00 00       	jmp    c01029e5 <__alltraps>

c0102931 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102931:	6a 00                	push   $0x0
  pushl $241
c0102933:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102938:	e9 a8 00 00 00       	jmp    c01029e5 <__alltraps>

c010293d <vector242>:
.globl vector242
vector242:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $242
c010293f:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102944:	e9 9c 00 00 00       	jmp    c01029e5 <__alltraps>

c0102949 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102949:	6a 00                	push   $0x0
  pushl $243
c010294b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102950:	e9 90 00 00 00       	jmp    c01029e5 <__alltraps>

c0102955 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102955:	6a 00                	push   $0x0
  pushl $244
c0102957:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010295c:	e9 84 00 00 00       	jmp    c01029e5 <__alltraps>

c0102961 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $245
c0102963:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102968:	e9 78 00 00 00       	jmp    c01029e5 <__alltraps>

c010296d <vector246>:
.globl vector246
vector246:
  pushl $0
c010296d:	6a 00                	push   $0x0
  pushl $246
c010296f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102974:	e9 6c 00 00 00       	jmp    c01029e5 <__alltraps>

c0102979 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102979:	6a 00                	push   $0x0
  pushl $247
c010297b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102980:	e9 60 00 00 00       	jmp    c01029e5 <__alltraps>

c0102985 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $248
c0102987:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010298c:	e9 54 00 00 00       	jmp    c01029e5 <__alltraps>

c0102991 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102991:	6a 00                	push   $0x0
  pushl $249
c0102993:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102998:	e9 48 00 00 00       	jmp    c01029e5 <__alltraps>

c010299d <vector250>:
.globl vector250
vector250:
  pushl $0
c010299d:	6a 00                	push   $0x0
  pushl $250
c010299f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01029a4:	e9 3c 00 00 00       	jmp    c01029e5 <__alltraps>

c01029a9 <vector251>:
.globl vector251
vector251:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $251
c01029ab:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01029b0:	e9 30 00 00 00       	jmp    c01029e5 <__alltraps>

c01029b5 <vector252>:
.globl vector252
vector252:
  pushl $0
c01029b5:	6a 00                	push   $0x0
  pushl $252
c01029b7:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01029bc:	e9 24 00 00 00       	jmp    c01029e5 <__alltraps>

c01029c1 <vector253>:
.globl vector253
vector253:
  pushl $0
c01029c1:	6a 00                	push   $0x0
  pushl $253
c01029c3:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01029c8:	e9 18 00 00 00       	jmp    c01029e5 <__alltraps>

c01029cd <vector254>:
.globl vector254
vector254:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $254
c01029cf:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01029d4:	e9 0c 00 00 00       	jmp    c01029e5 <__alltraps>

c01029d9 <vector255>:
.globl vector255
vector255:
  pushl $0
c01029d9:	6a 00                	push   $0x0
  pushl $255
c01029db:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01029e0:	e9 00 00 00 00       	jmp    c01029e5 <__alltraps>

c01029e5 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01029e5:	1e                   	push   %ds
    pushl %es
c01029e6:	06                   	push   %es
    pushl %fs
c01029e7:	0f a0                	push   %fs
    pushl %gs
c01029e9:	0f a8                	push   %gs
    pushal
c01029eb:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01029ec:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01029f1:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01029f3:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01029f5:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01029f6:	e8 64 f5 ff ff       	call   c0101f5f <trap>

    # pop the pushed stack pointer
    popl %esp
c01029fb:	5c                   	pop    %esp

c01029fc <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01029fc:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01029fd:	0f a9                	pop    %gs
    popl %fs
c01029ff:	0f a1                	pop    %fs
    popl %es
c0102a01:	07                   	pop    %es
    popl %ds
c0102a02:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a03:	83 c4 08             	add    $0x8,%esp
    iret
c0102a06:	cf                   	iret   

c0102a07 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102a07:	55                   	push   %ebp
c0102a08:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a0d:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102a13:	29 d0                	sub    %edx,%eax
c0102a15:	c1 f8 02             	sar    $0x2,%eax
c0102a18:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102a1e:	5d                   	pop    %ebp
c0102a1f:	c3                   	ret    

c0102a20 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102a20:	55                   	push   %ebp
c0102a21:	89 e5                	mov    %esp,%ebp
c0102a23:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102a26:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a29:	89 04 24             	mov    %eax,(%esp)
c0102a2c:	e8 d6 ff ff ff       	call   c0102a07 <page2ppn>
c0102a31:	c1 e0 0c             	shl    $0xc,%eax
}
c0102a34:	c9                   	leave  
c0102a35:	c3                   	ret    

c0102a36 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102a36:	55                   	push   %ebp
c0102a37:	89 e5                	mov    %esp,%ebp
c0102a39:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a3f:	c1 e8 0c             	shr    $0xc,%eax
c0102a42:	89 c2                	mov    %eax,%edx
c0102a44:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102a49:	39 c2                	cmp    %eax,%edx
c0102a4b:	72 1c                	jb     c0102a69 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102a4d:	c7 44 24 08 10 66 10 	movl   $0xc0106610,0x8(%esp)
c0102a54:	c0 
c0102a55:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102a5c:	00 
c0102a5d:	c7 04 24 2f 66 10 c0 	movl   $0xc010662f,(%esp)
c0102a64:	e8 90 d9 ff ff       	call   c01003f9 <__panic>
    }
    return &pages[PPN(pa)];
c0102a69:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a72:	c1 e8 0c             	shr    $0xc,%eax
c0102a75:	89 c2                	mov    %eax,%edx
c0102a77:	89 d0                	mov    %edx,%eax
c0102a79:	c1 e0 02             	shl    $0x2,%eax
c0102a7c:	01 d0                	add    %edx,%eax
c0102a7e:	c1 e0 02             	shl    $0x2,%eax
c0102a81:	01 c8                	add    %ecx,%eax
}
c0102a83:	c9                   	leave  
c0102a84:	c3                   	ret    

c0102a85 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102a85:	55                   	push   %ebp
c0102a86:	89 e5                	mov    %esp,%ebp
c0102a88:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102a8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a8e:	89 04 24             	mov    %eax,(%esp)
c0102a91:	e8 8a ff ff ff       	call   c0102a20 <page2pa>
c0102a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a9c:	c1 e8 0c             	shr    $0xc,%eax
c0102a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102aa2:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102aa7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102aaa:	72 23                	jb     c0102acf <page2kva+0x4a>
c0102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ab3:	c7 44 24 08 40 66 10 	movl   $0xc0106640,0x8(%esp)
c0102aba:	c0 
c0102abb:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102ac2:	00 
c0102ac3:	c7 04 24 2f 66 10 c0 	movl   $0xc010662f,(%esp)
c0102aca:	e8 2a d9 ff ff       	call   c01003f9 <__panic>
c0102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102ad7:	c9                   	leave  
c0102ad8:	c3                   	ret    

c0102ad9 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102ad9:	55                   	push   %ebp
c0102ada:	89 e5                	mov    %esp,%ebp
c0102adc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae2:	83 e0 01             	and    $0x1,%eax
c0102ae5:	85 c0                	test   %eax,%eax
c0102ae7:	75 1c                	jne    c0102b05 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102ae9:	c7 44 24 08 64 66 10 	movl   $0xc0106664,0x8(%esp)
c0102af0:	c0 
c0102af1:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102af8:	00 
c0102af9:	c7 04 24 2f 66 10 c0 	movl   $0xc010662f,(%esp)
c0102b00:	e8 f4 d8 ff ff       	call   c01003f9 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102b05:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b0d:	89 04 24             	mov    %eax,(%esp)
c0102b10:	e8 21 ff ff ff       	call   c0102a36 <pa2page>
}
c0102b15:	c9                   	leave  
c0102b16:	c3                   	ret    

c0102b17 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102b17:	55                   	push   %ebp
c0102b18:	89 e5                	mov    %esp,%ebp
c0102b1a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b25:	89 04 24             	mov    %eax,(%esp)
c0102b28:	e8 09 ff ff ff       	call   c0102a36 <pa2page>
}
c0102b2d:	c9                   	leave  
c0102b2e:	c3                   	ret    

c0102b2f <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102b2f:	55                   	push   %ebp
c0102b30:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b35:	8b 00                	mov    (%eax),%eax
}
c0102b37:	5d                   	pop    %ebp
c0102b38:	c3                   	ret    

c0102b39 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c0102b39:	55                   	push   %ebp
c0102b3a:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b3f:	8b 00                	mov    (%eax),%eax
c0102b41:	8d 50 01             	lea    0x1(%eax),%edx
c0102b44:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b47:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b49:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b4c:	8b 00                	mov    (%eax),%eax
}
c0102b4e:	5d                   	pop    %ebp
c0102b4f:	c3                   	ret    

c0102b50 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102b50:	55                   	push   %ebp
c0102b51:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b56:	8b 00                	mov    (%eax),%eax
c0102b58:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b5e:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b63:	8b 00                	mov    (%eax),%eax
}
c0102b65:	5d                   	pop    %ebp
c0102b66:	c3                   	ret    

c0102b67 <__intr_save>:
__intr_save(void) {
c0102b67:	55                   	push   %ebp
c0102b68:	89 e5                	mov    %esp,%ebp
c0102b6a:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102b6d:	9c                   	pushf  
c0102b6e:	58                   	pop    %eax
c0102b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102b75:	25 00 02 00 00       	and    $0x200,%eax
c0102b7a:	85 c0                	test   %eax,%eax
c0102b7c:	74 0c                	je     c0102b8a <__intr_save+0x23>
        intr_disable();
c0102b7e:	e8 2d ed ff ff       	call   c01018b0 <intr_disable>
        return 1;
c0102b83:	b8 01 00 00 00       	mov    $0x1,%eax
c0102b88:	eb 05                	jmp    c0102b8f <__intr_save+0x28>
    return 0;
c0102b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102b8f:	c9                   	leave  
c0102b90:	c3                   	ret    

c0102b91 <__intr_restore>:
__intr_restore(bool flag) {
c0102b91:	55                   	push   %ebp
c0102b92:	89 e5                	mov    %esp,%ebp
c0102b94:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102b97:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102b9b:	74 05                	je     c0102ba2 <__intr_restore+0x11>
        intr_enable();
c0102b9d:	e8 07 ed ff ff       	call   c01018a9 <intr_enable>
}
c0102ba2:	90                   	nop
c0102ba3:	c9                   	leave  
c0102ba4:	c3                   	ret    

c0102ba5 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102ba5:	55                   	push   %ebp
c0102ba6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bab:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102bae:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bb3:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102bb5:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bba:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102bbc:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bc1:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102bc3:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bc8:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102bca:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bcf:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102bd1:	ea d8 2b 10 c0 08 00 	ljmp   $0x8,$0xc0102bd8
}
c0102bd8:	90                   	nop
c0102bd9:	5d                   	pop    %ebp
c0102bda:	c3                   	ret    

c0102bdb <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102bdb:	55                   	push   %ebp
c0102bdc:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0102be1:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0102be6:	90                   	nop
c0102be7:	5d                   	pop    %ebp
c0102be8:	c3                   	ret    

c0102be9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102be9:	55                   	push   %ebp
c0102bea:	89 e5                	mov    %esp,%ebp
c0102bec:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102bef:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0102bf4:	89 04 24             	mov    %eax,(%esp)
c0102bf7:	e8 df ff ff ff       	call   c0102bdb <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102bfc:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0102c03:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102c05:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0102c0c:	68 00 
c0102c0e:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102c13:	0f b7 c0             	movzwl %ax,%eax
c0102c16:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0102c1c:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102c21:	c1 e8 10             	shr    $0x10,%eax
c0102c24:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0102c29:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c30:	24 f0                	and    $0xf0,%al
c0102c32:	0c 09                	or     $0x9,%al
c0102c34:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c39:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c40:	24 ef                	and    $0xef,%al
c0102c42:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c47:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c4e:	24 9f                	and    $0x9f,%al
c0102c50:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c55:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0102c5c:	0c 80                	or     $0x80,%al
c0102c5e:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0102c63:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c6a:	24 f0                	and    $0xf0,%al
c0102c6c:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c71:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c78:	24 ef                	and    $0xef,%al
c0102c7a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c7f:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c86:	24 df                	and    $0xdf,%al
c0102c88:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c8d:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102c94:	0c 40                	or     $0x40,%al
c0102c96:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102c9b:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0102ca2:	24 7f                	and    $0x7f,%al
c0102ca4:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0102ca9:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0102cae:	c1 e8 18             	shr    $0x18,%eax
c0102cb1:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102cb6:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0102cbd:	e8 e3 fe ff ff       	call   c0102ba5 <lgdt>
c0102cc2:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102cc8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102ccc:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102ccf:	90                   	nop
c0102cd0:	c9                   	leave  
c0102cd1:	c3                   	ret    

c0102cd2 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102cd2:	55                   	push   %ebp
c0102cd3:	89 e5                	mov    %esp,%ebp
c0102cd5:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102cd8:	c7 05 10 af 11 c0 f0 	movl   $0xc0106ff0,0xc011af10
c0102cdf:	6f 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102ce2:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102ce7:	8b 00                	mov    (%eax),%eax
c0102ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102ced:	c7 04 24 90 66 10 c0 	movl   $0xc0106690,(%esp)
c0102cf4:	e8 a9 d5 ff ff       	call   c01002a2 <cprintf>
    pmm_manager->init();
c0102cf9:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102cfe:	8b 40 04             	mov    0x4(%eax),%eax
c0102d01:	ff d0                	call   *%eax
}
c0102d03:	90                   	nop
c0102d04:	c9                   	leave  
c0102d05:	c3                   	ret    

c0102d06 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102d06:	55                   	push   %ebp
c0102d07:	89 e5                	mov    %esp,%ebp
c0102d09:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102d0c:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102d11:	8b 40 08             	mov    0x8(%eax),%eax
c0102d14:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d17:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d1b:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d1e:	89 14 24             	mov    %edx,(%esp)
c0102d21:	ff d0                	call   *%eax
}
c0102d23:	90                   	nop
c0102d24:	c9                   	leave  
c0102d25:	c3                   	ret    

c0102d26 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102d26:	55                   	push   %ebp
c0102d27:	89 e5                	mov    %esp,%ebp
c0102d29:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102d2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d33:	e8 2f fe ff ff       	call   c0102b67 <__intr_save>
c0102d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102d3b:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102d40:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d43:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d46:	89 14 24             	mov    %edx,(%esp)
c0102d49:	ff d0                	call   *%eax
c0102d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d51:	89 04 24             	mov    %eax,(%esp)
c0102d54:	e8 38 fe ff ff       	call   c0102b91 <__intr_restore>
    return page;
c0102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102d5c:	c9                   	leave  
c0102d5d:	c3                   	ret    

c0102d5e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102d5e:	55                   	push   %ebp
c0102d5f:	89 e5                	mov    %esp,%ebp
c0102d61:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d64:	e8 fe fd ff ff       	call   c0102b67 <__intr_save>
c0102d69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102d6c:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102d71:	8b 40 10             	mov    0x10(%eax),%eax
c0102d74:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d77:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d7e:	89 14 24             	mov    %edx,(%esp)
c0102d81:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d86:	89 04 24             	mov    %eax,(%esp)
c0102d89:	e8 03 fe ff ff       	call   c0102b91 <__intr_restore>
}
c0102d8e:	90                   	nop
c0102d8f:	c9                   	leave  
c0102d90:	c3                   	ret    

c0102d91 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102d91:	55                   	push   %ebp
c0102d92:	89 e5                	mov    %esp,%ebp
c0102d94:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d97:	e8 cb fd ff ff       	call   c0102b67 <__intr_save>
c0102d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102d9f:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102da4:	8b 40 14             	mov    0x14(%eax),%eax
c0102da7:	ff d0                	call   *%eax
c0102da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102daf:	89 04 24             	mov    %eax,(%esp)
c0102db2:	e8 da fd ff ff       	call   c0102b91 <__intr_restore>
    return ret;
c0102db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102dba:	c9                   	leave  
c0102dbb:	c3                   	ret    

c0102dbc <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102dbc:	55                   	push   %ebp
c0102dbd:	89 e5                	mov    %esp,%ebp
c0102dbf:	57                   	push   %edi
c0102dc0:	56                   	push   %esi
c0102dc1:	53                   	push   %ebx
c0102dc2:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102dc8:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102dcf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102dd6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102ddd:	c7 04 24 a7 66 10 c0 	movl   $0xc01066a7,(%esp)
c0102de4:	e8 b9 d4 ff ff       	call   c01002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102de9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102df0:	e9 22 01 00 00       	jmp    c0102f17 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102df5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102df8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102dfb:	89 d0                	mov    %edx,%eax
c0102dfd:	c1 e0 02             	shl    $0x2,%eax
c0102e00:	01 d0                	add    %edx,%eax
c0102e02:	c1 e0 02             	shl    $0x2,%eax
c0102e05:	01 c8                	add    %ecx,%eax
c0102e07:	8b 50 08             	mov    0x8(%eax),%edx
c0102e0a:	8b 40 04             	mov    0x4(%eax),%eax
c0102e0d:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102e10:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102e13:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e16:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e19:	89 d0                	mov    %edx,%eax
c0102e1b:	c1 e0 02             	shl    $0x2,%eax
c0102e1e:	01 d0                	add    %edx,%eax
c0102e20:	c1 e0 02             	shl    $0x2,%eax
c0102e23:	01 c8                	add    %ecx,%eax
c0102e25:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e28:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e2b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e2e:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e31:	01 c8                	add    %ecx,%eax
c0102e33:	11 da                	adc    %ebx,%edx
c0102e35:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e38:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102e3b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e41:	89 d0                	mov    %edx,%eax
c0102e43:	c1 e0 02             	shl    $0x2,%eax
c0102e46:	01 d0                	add    %edx,%eax
c0102e48:	c1 e0 02             	shl    $0x2,%eax
c0102e4b:	01 c8                	add    %ecx,%eax
c0102e4d:	83 c0 14             	add    $0x14,%eax
c0102e50:	8b 00                	mov    (%eax),%eax
c0102e52:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102e55:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e58:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102e5b:	83 c0 ff             	add    $0xffffffff,%eax
c0102e5e:	83 d2 ff             	adc    $0xffffffff,%edx
c0102e61:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102e67:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102e6d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e70:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e73:	89 d0                	mov    %edx,%eax
c0102e75:	c1 e0 02             	shl    $0x2,%eax
c0102e78:	01 d0                	add    %edx,%eax
c0102e7a:	c1 e0 02             	shl    $0x2,%eax
c0102e7d:	01 c8                	add    %ecx,%eax
c0102e7f:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e82:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e85:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e88:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102e8c:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102e92:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102e98:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102e9c:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102ea0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ea3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102ea6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102eaa:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102eae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102eb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102eb6:	c7 04 24 b4 66 10 c0 	movl   $0xc01066b4,(%esp)
c0102ebd:	e8 e0 d3 ff ff       	call   c01002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102ec2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ec5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ec8:	89 d0                	mov    %edx,%eax
c0102eca:	c1 e0 02             	shl    $0x2,%eax
c0102ecd:	01 d0                	add    %edx,%eax
c0102ecf:	c1 e0 02             	shl    $0x2,%eax
c0102ed2:	01 c8                	add    %ecx,%eax
c0102ed4:	83 c0 14             	add    $0x14,%eax
c0102ed7:	8b 00                	mov    (%eax),%eax
c0102ed9:	83 f8 01             	cmp    $0x1,%eax
c0102edc:	75 36                	jne    c0102f14 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102ede:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ee1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102ee4:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102ee7:	77 2b                	ja     c0102f14 <page_init+0x158>
c0102ee9:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102eec:	72 05                	jb     c0102ef3 <page_init+0x137>
c0102eee:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102ef1:	73 21                	jae    c0102f14 <page_init+0x158>
c0102ef3:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102ef7:	77 1b                	ja     c0102f14 <page_init+0x158>
c0102ef9:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102efd:	72 09                	jb     c0102f08 <page_init+0x14c>
c0102eff:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102f06:	77 0c                	ja     c0102f14 <page_init+0x158>
                maxpa = end;
c0102f08:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f0b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102f0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102f11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102f14:	ff 45 dc             	incl   -0x24(%ebp)
c0102f17:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102f1a:	8b 00                	mov    (%eax),%eax
c0102f1c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102f1f:	0f 8c d0 fe ff ff    	jl     c0102df5 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102f25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f29:	72 1d                	jb     c0102f48 <page_init+0x18c>
c0102f2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f2f:	77 09                	ja     c0102f3a <page_init+0x17e>
c0102f31:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102f38:	76 0e                	jbe    c0102f48 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102f3a:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102f41:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f4e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f52:	c1 ea 0c             	shr    $0xc,%edx
c0102f55:	89 c1                	mov    %eax,%ecx
c0102f57:	89 d3                	mov    %edx,%ebx
c0102f59:	89 c8                	mov    %ecx,%eax
c0102f5b:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102f60:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102f67:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0102f6c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102f6f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102f72:	01 d0                	add    %edx,%eax
c0102f74:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102f77:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102f7a:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f7f:	f7 75 c0             	divl   -0x40(%ebp)
c0102f82:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102f85:	29 d0                	sub    %edx,%eax
c0102f87:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    for (i = 0; i < npage; i ++) {
c0102f8c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102f93:	eb 2e                	jmp    c0102fc3 <page_init+0x207>
        SetPageReserved(pages + i);
c0102f95:	8b 0d 18 af 11 c0    	mov    0xc011af18,%ecx
c0102f9b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f9e:	89 d0                	mov    %edx,%eax
c0102fa0:	c1 e0 02             	shl    $0x2,%eax
c0102fa3:	01 d0                	add    %edx,%eax
c0102fa5:	c1 e0 02             	shl    $0x2,%eax
c0102fa8:	01 c8                	add    %ecx,%eax
c0102faa:	83 c0 04             	add    $0x4,%eax
c0102fad:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102fb4:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fb7:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102fba:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102fbd:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102fc0:	ff 45 dc             	incl   -0x24(%ebp)
c0102fc3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fc6:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0102fcb:	39 c2                	cmp    %eax,%edx
c0102fcd:	72 c6                	jb     c0102f95 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102fcf:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102fd5:	89 d0                	mov    %edx,%eax
c0102fd7:	c1 e0 02             	shl    $0x2,%eax
c0102fda:	01 d0                	add    %edx,%eax
c0102fdc:	c1 e0 02             	shl    $0x2,%eax
c0102fdf:	89 c2                	mov    %eax,%edx
c0102fe1:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102fe6:	01 d0                	add    %edx,%eax
c0102fe8:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102feb:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0102ff2:	77 23                	ja     c0103017 <page_init+0x25b>
c0102ff4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ff7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ffb:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c0103002:	c0 
c0103003:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010300a:	00 
c010300b:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103012:	e8 e2 d3 ff ff       	call   c01003f9 <__panic>
c0103017:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010301a:	05 00 00 00 40       	add    $0x40000000,%eax
c010301f:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103022:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103029:	e9 69 01 00 00       	jmp    c0103197 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010302e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103031:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103034:	89 d0                	mov    %edx,%eax
c0103036:	c1 e0 02             	shl    $0x2,%eax
c0103039:	01 d0                	add    %edx,%eax
c010303b:	c1 e0 02             	shl    $0x2,%eax
c010303e:	01 c8                	add    %ecx,%eax
c0103040:	8b 50 08             	mov    0x8(%eax),%edx
c0103043:	8b 40 04             	mov    0x4(%eax),%eax
c0103046:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103049:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010304c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010304f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103052:	89 d0                	mov    %edx,%eax
c0103054:	c1 e0 02             	shl    $0x2,%eax
c0103057:	01 d0                	add    %edx,%eax
c0103059:	c1 e0 02             	shl    $0x2,%eax
c010305c:	01 c8                	add    %ecx,%eax
c010305e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103061:	8b 58 10             	mov    0x10(%eax),%ebx
c0103064:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103067:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010306a:	01 c8                	add    %ecx,%eax
c010306c:	11 da                	adc    %ebx,%edx
c010306e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103071:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103074:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103077:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010307a:	89 d0                	mov    %edx,%eax
c010307c:	c1 e0 02             	shl    $0x2,%eax
c010307f:	01 d0                	add    %edx,%eax
c0103081:	c1 e0 02             	shl    $0x2,%eax
c0103084:	01 c8                	add    %ecx,%eax
c0103086:	83 c0 14             	add    $0x14,%eax
c0103089:	8b 00                	mov    (%eax),%eax
c010308b:	83 f8 01             	cmp    $0x1,%eax
c010308e:	0f 85 00 01 00 00    	jne    c0103194 <page_init+0x3d8>
            if (begin < freemem) {
c0103094:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103097:	ba 00 00 00 00       	mov    $0x0,%edx
c010309c:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c010309f:	77 17                	ja     c01030b8 <page_init+0x2fc>
c01030a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01030a4:	72 05                	jb     c01030ab <page_init+0x2ef>
c01030a6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01030a9:	73 0d                	jae    c01030b8 <page_init+0x2fc>
                begin = freemem;
c01030ab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01030ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01030b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030bc:	72 1d                	jb     c01030db <page_init+0x31f>
c01030be:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030c2:	77 09                	ja     c01030cd <page_init+0x311>
c01030c4:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01030cb:	76 0e                	jbe    c01030db <page_init+0x31f>
                end = KMEMSIZE;
c01030cd:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01030d4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01030db:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030e1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030e4:	0f 87 aa 00 00 00    	ja     c0103194 <page_init+0x3d8>
c01030ea:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030ed:	72 09                	jb     c01030f8 <page_init+0x33c>
c01030ef:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01030f2:	0f 83 9c 00 00 00    	jae    c0103194 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c01030f8:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c01030ff:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103102:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103105:	01 d0                	add    %edx,%eax
c0103107:	48                   	dec    %eax
c0103108:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010310b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010310e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103113:	f7 75 b0             	divl   -0x50(%ebp)
c0103116:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103119:	29 d0                	sub    %edx,%eax
c010311b:	ba 00 00 00 00       	mov    $0x0,%edx
c0103120:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103123:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103126:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103129:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010312c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010312f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103134:	89 c3                	mov    %eax,%ebx
c0103136:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c010313c:	89 de                	mov    %ebx,%esi
c010313e:	89 d0                	mov    %edx,%eax
c0103140:	83 e0 00             	and    $0x0,%eax
c0103143:	89 c7                	mov    %eax,%edi
c0103145:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103148:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c010314b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010314e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103151:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103154:	77 3e                	ja     c0103194 <page_init+0x3d8>
c0103156:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103159:	72 05                	jb     c0103160 <page_init+0x3a4>
c010315b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010315e:	73 34                	jae    c0103194 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103160:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103163:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103166:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103169:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010316c:	89 c1                	mov    %eax,%ecx
c010316e:	89 d3                	mov    %edx,%ebx
c0103170:	89 c8                	mov    %ecx,%eax
c0103172:	89 da                	mov    %ebx,%edx
c0103174:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103178:	c1 ea 0c             	shr    $0xc,%edx
c010317b:	89 c3                	mov    %eax,%ebx
c010317d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103180:	89 04 24             	mov    %eax,(%esp)
c0103183:	e8 ae f8 ff ff       	call   c0102a36 <pa2page>
c0103188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010318c:	89 04 24             	mov    %eax,(%esp)
c010318f:	e8 72 fb ff ff       	call   c0102d06 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0103194:	ff 45 dc             	incl   -0x24(%ebp)
c0103197:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010319a:	8b 00                	mov    (%eax),%eax
c010319c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010319f:	0f 8c 89 fe ff ff    	jl     c010302e <page_init+0x272>
                }
            }
        }
    }
}
c01031a5:	90                   	nop
c01031a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01031ac:	5b                   	pop    %ebx
c01031ad:	5e                   	pop    %esi
c01031ae:	5f                   	pop    %edi
c01031af:	5d                   	pop    %ebp
c01031b0:	c3                   	ret    

c01031b1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01031b1:	55                   	push   %ebp
c01031b2:	89 e5                	mov    %esp,%ebp
c01031b4:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01031b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031ba:	33 45 14             	xor    0x14(%ebp),%eax
c01031bd:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031c2:	85 c0                	test   %eax,%eax
c01031c4:	74 24                	je     c01031ea <boot_map_segment+0x39>
c01031c6:	c7 44 24 0c 16 67 10 	movl   $0xc0106716,0xc(%esp)
c01031cd:	c0 
c01031ce:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01031d5:	c0 
c01031d6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01031dd:	00 
c01031de:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01031e5:	e8 0f d2 ff ff       	call   c01003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01031ea:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031f4:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031f9:	89 c2                	mov    %eax,%edx
c01031fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01031fe:	01 c2                	add    %eax,%edx
c0103200:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103203:	01 d0                	add    %edx,%eax
c0103205:	48                   	dec    %eax
c0103206:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103209:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010320c:	ba 00 00 00 00       	mov    $0x0,%edx
c0103211:	f7 75 f0             	divl   -0x10(%ebp)
c0103214:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103217:	29 d0                	sub    %edx,%eax
c0103219:	c1 e8 0c             	shr    $0xc,%eax
c010321c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010321f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103222:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103225:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010322d:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103230:	8b 45 14             	mov    0x14(%ebp),%eax
c0103233:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103239:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010323e:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103241:	eb 68                	jmp    c01032ab <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103243:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010324a:	00 
c010324b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010324e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103252:	8b 45 08             	mov    0x8(%ebp),%eax
c0103255:	89 04 24             	mov    %eax,(%esp)
c0103258:	e8 81 01 00 00       	call   c01033de <get_pte>
c010325d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103260:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103264:	75 24                	jne    c010328a <boot_map_segment+0xd9>
c0103266:	c7 44 24 0c 42 67 10 	movl   $0xc0106742,0xc(%esp)
c010326d:	c0 
c010326e:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103275:	c0 
c0103276:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010327d:	00 
c010327e:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103285:	e8 6f d1 ff ff       	call   c01003f9 <__panic>
        *ptep = pa | PTE_P | perm;
c010328a:	8b 45 14             	mov    0x14(%ebp),%eax
c010328d:	0b 45 18             	or     0x18(%ebp),%eax
c0103290:	83 c8 01             	or     $0x1,%eax
c0103293:	89 c2                	mov    %eax,%edx
c0103295:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103298:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010329a:	ff 4d f4             	decl   -0xc(%ebp)
c010329d:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01032a4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01032ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032af:	75 92                	jne    c0103243 <boot_map_segment+0x92>
    }
}
c01032b1:	90                   	nop
c01032b2:	c9                   	leave  
c01032b3:	c3                   	ret    

c01032b4 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01032b4:	55                   	push   %ebp
c01032b5:	89 e5                	mov    %esp,%ebp
c01032b7:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01032ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032c1:	e8 60 fa ff ff       	call   c0102d26 <alloc_pages>
c01032c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01032c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032cd:	75 1c                	jne    c01032eb <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01032cf:	c7 44 24 08 4f 67 10 	movl   $0xc010674f,0x8(%esp)
c01032d6:	c0 
c01032d7:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01032de:	00 
c01032df:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01032e6:	e8 0e d1 ff ff       	call   c01003f9 <__panic>
    }
    return page2kva(p);
c01032eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ee:	89 04 24             	mov    %eax,(%esp)
c01032f1:	e8 8f f7 ff ff       	call   c0102a85 <page2kva>
}
c01032f6:	c9                   	leave  
c01032f7:	c3                   	ret    

c01032f8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01032f8:	55                   	push   %ebp
c01032f9:	89 e5                	mov    %esp,%ebp
c01032fb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01032fe:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103303:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103306:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010330d:	77 23                	ja     c0103332 <pmm_init+0x3a>
c010330f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103312:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103316:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c010331d:	c0 
c010331e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0103325:	00 
c0103326:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010332d:	e8 c7 d0 ff ff       	call   c01003f9 <__panic>
c0103332:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103335:	05 00 00 00 40       	add    $0x40000000,%eax
c010333a:	a3 14 af 11 c0       	mov    %eax,0xc011af14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010333f:	e8 8e f9 ff ff       	call   c0102cd2 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103344:	e8 73 fa ff ff       	call   c0102dbc <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103349:	e8 4f 02 00 00       	call   c010359d <check_alloc_page>

    check_pgdir();
c010334e:	e8 69 02 00 00       	call   c01035bc <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103353:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103358:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010335b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103362:	77 23                	ja     c0103387 <pmm_init+0x8f>
c0103364:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103367:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010336b:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c0103372:	c0 
c0103373:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010337a:	00 
c010337b:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103382:	e8 72 d0 ff ff       	call   c01003f9 <__panic>
c0103387:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010338a:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103390:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103395:	05 ac 0f 00 00       	add    $0xfac,%eax
c010339a:	83 ca 03             	or     $0x3,%edx
c010339d:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010339f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01033a4:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01033ab:	00 
c01033ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01033b3:	00 
c01033b4:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01033bb:	38 
c01033bc:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01033c3:	c0 
c01033c4:	89 04 24             	mov    %eax,(%esp)
c01033c7:	e8 e5 fd ff ff       	call   c01031b1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01033cc:	e8 18 f8 ff ff       	call   c0102be9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01033d1:	e8 82 08 00 00       	call   c0103c58 <check_boot_pgdir>

    print_pgdir();
c01033d6:	e8 fb 0c 00 00       	call   c01040d6 <print_pgdir>

}
c01033db:	90                   	nop
c01033dc:	c9                   	leave  
c01033dd:	c3                   	ret    

c01033de <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01033de:	55                   	push   %ebp
c01033df:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c01033e1:	90                   	nop
c01033e2:	5d                   	pop    %ebp
c01033e3:	c3                   	ret    

c01033e4 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01033e4:	55                   	push   %ebp
c01033e5:	89 e5                	mov    %esp,%ebp
c01033e7:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01033ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01033f1:	00 
c01033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01033f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01033fc:	89 04 24             	mov    %eax,(%esp)
c01033ff:	e8 da ff ff ff       	call   c01033de <get_pte>
c0103404:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103407:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010340b:	74 08                	je     c0103415 <get_page+0x31>
        *ptep_store = ptep;
c010340d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103410:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103413:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103415:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103419:	74 1b                	je     c0103436 <get_page+0x52>
c010341b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010341e:	8b 00                	mov    (%eax),%eax
c0103420:	83 e0 01             	and    $0x1,%eax
c0103423:	85 c0                	test   %eax,%eax
c0103425:	74 0f                	je     c0103436 <get_page+0x52>
        return pte2page(*ptep);
c0103427:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010342a:	8b 00                	mov    (%eax),%eax
c010342c:	89 04 24             	mov    %eax,(%esp)
c010342f:	e8 a5 f6 ff ff       	call   c0102ad9 <pte2page>
c0103434:	eb 05                	jmp    c010343b <get_page+0x57>
    }
    return NULL;
c0103436:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010343b:	c9                   	leave  
c010343c:	c3                   	ret    

c010343d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010343d:	55                   	push   %ebp
c010343e:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c0103440:	90                   	nop
c0103441:	5d                   	pop    %ebp
c0103442:	c3                   	ret    

c0103443 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103443:	55                   	push   %ebp
c0103444:	89 e5                	mov    %esp,%ebp
c0103446:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103449:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103450:	00 
c0103451:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103454:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103458:	8b 45 08             	mov    0x8(%ebp),%eax
c010345b:	89 04 24             	mov    %eax,(%esp)
c010345e:	e8 7b ff ff ff       	call   c01033de <get_pte>
c0103463:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c0103466:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010346a:	74 19                	je     c0103485 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010346c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010346f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103476:	89 44 24 04          	mov    %eax,0x4(%esp)
c010347a:	8b 45 08             	mov    0x8(%ebp),%eax
c010347d:	89 04 24             	mov    %eax,(%esp)
c0103480:	e8 b8 ff ff ff       	call   c010343d <page_remove_pte>
    }
}
c0103485:	90                   	nop
c0103486:	c9                   	leave  
c0103487:	c3                   	ret    

c0103488 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103488:	55                   	push   %ebp
c0103489:	89 e5                	mov    %esp,%ebp
c010348b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010348e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103495:	00 
c0103496:	8b 45 10             	mov    0x10(%ebp),%eax
c0103499:	89 44 24 04          	mov    %eax,0x4(%esp)
c010349d:	8b 45 08             	mov    0x8(%ebp),%eax
c01034a0:	89 04 24             	mov    %eax,(%esp)
c01034a3:	e8 36 ff ff ff       	call   c01033de <get_pte>
c01034a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01034ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034af:	75 0a                	jne    c01034bb <page_insert+0x33>
        return -E_NO_MEM;
c01034b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01034b6:	e9 84 00 00 00       	jmp    c010353f <page_insert+0xb7>
    }
    page_ref_inc(page);
c01034bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034be:	89 04 24             	mov    %eax,(%esp)
c01034c1:	e8 73 f6 ff ff       	call   c0102b39 <page_ref_inc>
    if (*ptep & PTE_P) {
c01034c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034c9:	8b 00                	mov    (%eax),%eax
c01034cb:	83 e0 01             	and    $0x1,%eax
c01034ce:	85 c0                	test   %eax,%eax
c01034d0:	74 3e                	je     c0103510 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01034d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034d5:	8b 00                	mov    (%eax),%eax
c01034d7:	89 04 24             	mov    %eax,(%esp)
c01034da:	e8 fa f5 ff ff       	call   c0102ad9 <pte2page>
c01034df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01034e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01034e8:	75 0d                	jne    c01034f7 <page_insert+0x6f>
            page_ref_dec(page);
c01034ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ed:	89 04 24             	mov    %eax,(%esp)
c01034f0:	e8 5b f6 ff ff       	call   c0102b50 <page_ref_dec>
c01034f5:	eb 19                	jmp    c0103510 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01034f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034fa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0103501:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103505:	8b 45 08             	mov    0x8(%ebp),%eax
c0103508:	89 04 24             	mov    %eax,(%esp)
c010350b:	e8 2d ff ff ff       	call   c010343d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103510:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103513:	89 04 24             	mov    %eax,(%esp)
c0103516:	e8 05 f5 ff ff       	call   c0102a20 <page2pa>
c010351b:	0b 45 14             	or     0x14(%ebp),%eax
c010351e:	83 c8 01             	or     $0x1,%eax
c0103521:	89 c2                	mov    %eax,%edx
c0103523:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103526:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103528:	8b 45 10             	mov    0x10(%ebp),%eax
c010352b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010352f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103532:	89 04 24             	mov    %eax,(%esp)
c0103535:	e8 07 00 00 00       	call   c0103541 <tlb_invalidate>
    return 0;
c010353a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010353f:	c9                   	leave  
c0103540:	c3                   	ret    

c0103541 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103541:	55                   	push   %ebp
c0103542:	89 e5                	mov    %esp,%ebp
c0103544:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103547:	0f 20 d8             	mov    %cr3,%eax
c010354a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010354d:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103550:	8b 45 08             	mov    0x8(%ebp),%eax
c0103553:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103556:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010355d:	77 23                	ja     c0103582 <tlb_invalidate+0x41>
c010355f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103562:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103566:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c010356d:	c0 
c010356e:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
c0103575:	00 
c0103576:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010357d:	e8 77 ce ff ff       	call   c01003f9 <__panic>
c0103582:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103585:	05 00 00 00 40       	add    $0x40000000,%eax
c010358a:	39 d0                	cmp    %edx,%eax
c010358c:	75 0c                	jne    c010359a <tlb_invalidate+0x59>
        invlpg((void *)la);
c010358e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103591:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103594:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103597:	0f 01 38             	invlpg (%eax)
    }
}
c010359a:	90                   	nop
c010359b:	c9                   	leave  
c010359c:	c3                   	ret    

c010359d <check_alloc_page>:

static void
check_alloc_page(void) {
c010359d:	55                   	push   %ebp
c010359e:	89 e5                	mov    %esp,%ebp
c01035a0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01035a3:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01035a8:	8b 40 18             	mov    0x18(%eax),%eax
c01035ab:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01035ad:	c7 04 24 68 67 10 c0 	movl   $0xc0106768,(%esp)
c01035b4:	e8 e9 cc ff ff       	call   c01002a2 <cprintf>
}
c01035b9:	90                   	nop
c01035ba:	c9                   	leave  
c01035bb:	c3                   	ret    

c01035bc <check_pgdir>:

static void
check_pgdir(void) {
c01035bc:	55                   	push   %ebp
c01035bd:	89 e5                	mov    %esp,%ebp
c01035bf:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01035c2:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01035c7:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01035cc:	76 24                	jbe    c01035f2 <check_pgdir+0x36>
c01035ce:	c7 44 24 0c 87 67 10 	movl   $0xc0106787,0xc(%esp)
c01035d5:	c0 
c01035d6:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01035dd:	c0 
c01035de:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c01035e5:	00 
c01035e6:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01035ed:	e8 07 ce ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01035f2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01035f7:	85 c0                	test   %eax,%eax
c01035f9:	74 0e                	je     c0103609 <check_pgdir+0x4d>
c01035fb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103600:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103605:	85 c0                	test   %eax,%eax
c0103607:	74 24                	je     c010362d <check_pgdir+0x71>
c0103609:	c7 44 24 0c a4 67 10 	movl   $0xc01067a4,0xc(%esp)
c0103610:	c0 
c0103611:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103618:	c0 
c0103619:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0103620:	00 
c0103621:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103628:	e8 cc cd ff ff       	call   c01003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010362d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103632:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103639:	00 
c010363a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103641:	00 
c0103642:	89 04 24             	mov    %eax,(%esp)
c0103645:	e8 9a fd ff ff       	call   c01033e4 <get_page>
c010364a:	85 c0                	test   %eax,%eax
c010364c:	74 24                	je     c0103672 <check_pgdir+0xb6>
c010364e:	c7 44 24 0c dc 67 10 	movl   $0xc01067dc,0xc(%esp)
c0103655:	c0 
c0103656:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c010365d:	c0 
c010365e:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0103665:	00 
c0103666:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010366d:	e8 87 cd ff ff       	call   c01003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103672:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103679:	e8 a8 f6 ff ff       	call   c0102d26 <alloc_pages>
c010367e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103681:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103686:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010368d:	00 
c010368e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103695:	00 
c0103696:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103699:	89 54 24 04          	mov    %edx,0x4(%esp)
c010369d:	89 04 24             	mov    %eax,(%esp)
c01036a0:	e8 e3 fd ff ff       	call   c0103488 <page_insert>
c01036a5:	85 c0                	test   %eax,%eax
c01036a7:	74 24                	je     c01036cd <check_pgdir+0x111>
c01036a9:	c7 44 24 0c 04 68 10 	movl   $0xc0106804,0xc(%esp)
c01036b0:	c0 
c01036b1:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01036b8:	c0 
c01036b9:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c01036c0:	00 
c01036c1:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01036c8:	e8 2c cd ff ff       	call   c01003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01036cd:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01036d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036d9:	00 
c01036da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036e1:	00 
c01036e2:	89 04 24             	mov    %eax,(%esp)
c01036e5:	e8 f4 fc ff ff       	call   c01033de <get_pte>
c01036ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036f1:	75 24                	jne    c0103717 <check_pgdir+0x15b>
c01036f3:	c7 44 24 0c 30 68 10 	movl   $0xc0106830,0xc(%esp)
c01036fa:	c0 
c01036fb:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103702:	c0 
c0103703:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c010370a:	00 
c010370b:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103712:	e8 e2 cc ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103717:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010371a:	8b 00                	mov    (%eax),%eax
c010371c:	89 04 24             	mov    %eax,(%esp)
c010371f:	e8 b5 f3 ff ff       	call   c0102ad9 <pte2page>
c0103724:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103727:	74 24                	je     c010374d <check_pgdir+0x191>
c0103729:	c7 44 24 0c 5d 68 10 	movl   $0xc010685d,0xc(%esp)
c0103730:	c0 
c0103731:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103738:	c0 
c0103739:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c0103740:	00 
c0103741:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103748:	e8 ac cc ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 1);
c010374d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103750:	89 04 24             	mov    %eax,(%esp)
c0103753:	e8 d7 f3 ff ff       	call   c0102b2f <page_ref>
c0103758:	83 f8 01             	cmp    $0x1,%eax
c010375b:	74 24                	je     c0103781 <check_pgdir+0x1c5>
c010375d:	c7 44 24 0c 73 68 10 	movl   $0xc0106873,0xc(%esp)
c0103764:	c0 
c0103765:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c010376c:	c0 
c010376d:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103774:	00 
c0103775:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010377c:	e8 78 cc ff ff       	call   c01003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103781:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103786:	8b 00                	mov    (%eax),%eax
c0103788:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010378d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103790:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103793:	c1 e8 0c             	shr    $0xc,%eax
c0103796:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103799:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010379e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01037a1:	72 23                	jb     c01037c6 <check_pgdir+0x20a>
c01037a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01037aa:	c7 44 24 08 40 66 10 	movl   $0xc0106640,0x8(%esp)
c01037b1:	c0 
c01037b2:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c01037b9:	00 
c01037ba:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01037c1:	e8 33 cc ff ff       	call   c01003f9 <__panic>
c01037c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01037ce:	83 c0 04             	add    $0x4,%eax
c01037d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01037d4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01037d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037e0:	00 
c01037e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01037e8:	00 
c01037e9:	89 04 24             	mov    %eax,(%esp)
c01037ec:	e8 ed fb ff ff       	call   c01033de <get_pte>
c01037f1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01037f4:	74 24                	je     c010381a <check_pgdir+0x25e>
c01037f6:	c7 44 24 0c 88 68 10 	movl   $0xc0106888,0xc(%esp)
c01037fd:	c0 
c01037fe:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103805:	c0 
c0103806:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c010380d:	00 
c010380e:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103815:	e8 df cb ff ff       	call   c01003f9 <__panic>

    p2 = alloc_page();
c010381a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103821:	e8 00 f5 ff ff       	call   c0102d26 <alloc_pages>
c0103826:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103829:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010382e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103835:	00 
c0103836:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010383d:	00 
c010383e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103841:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103845:	89 04 24             	mov    %eax,(%esp)
c0103848:	e8 3b fc ff ff       	call   c0103488 <page_insert>
c010384d:	85 c0                	test   %eax,%eax
c010384f:	74 24                	je     c0103875 <check_pgdir+0x2b9>
c0103851:	c7 44 24 0c b0 68 10 	movl   $0xc01068b0,0xc(%esp)
c0103858:	c0 
c0103859:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103860:	c0 
c0103861:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0103868:	00 
c0103869:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103870:	e8 84 cb ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103875:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010387a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103881:	00 
c0103882:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103889:	00 
c010388a:	89 04 24             	mov    %eax,(%esp)
c010388d:	e8 4c fb ff ff       	call   c01033de <get_pte>
c0103892:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103895:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103899:	75 24                	jne    c01038bf <check_pgdir+0x303>
c010389b:	c7 44 24 0c e8 68 10 	movl   $0xc01068e8,0xc(%esp)
c01038a2:	c0 
c01038a3:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01038aa:	c0 
c01038ab:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c01038b2:	00 
c01038b3:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01038ba:	e8 3a cb ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_U);
c01038bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038c2:	8b 00                	mov    (%eax),%eax
c01038c4:	83 e0 04             	and    $0x4,%eax
c01038c7:	85 c0                	test   %eax,%eax
c01038c9:	75 24                	jne    c01038ef <check_pgdir+0x333>
c01038cb:	c7 44 24 0c 18 69 10 	movl   $0xc0106918,0xc(%esp)
c01038d2:	c0 
c01038d3:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01038da:	c0 
c01038db:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c01038e2:	00 
c01038e3:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01038ea:	e8 0a cb ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_W);
c01038ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038f2:	8b 00                	mov    (%eax),%eax
c01038f4:	83 e0 02             	and    $0x2,%eax
c01038f7:	85 c0                	test   %eax,%eax
c01038f9:	75 24                	jne    c010391f <check_pgdir+0x363>
c01038fb:	c7 44 24 0c 26 69 10 	movl   $0xc0106926,0xc(%esp)
c0103902:	c0 
c0103903:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c010390a:	c0 
c010390b:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0103912:	00 
c0103913:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010391a:	e8 da ca ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010391f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103924:	8b 00                	mov    (%eax),%eax
c0103926:	83 e0 04             	and    $0x4,%eax
c0103929:	85 c0                	test   %eax,%eax
c010392b:	75 24                	jne    c0103951 <check_pgdir+0x395>
c010392d:	c7 44 24 0c 34 69 10 	movl   $0xc0106934,0xc(%esp)
c0103934:	c0 
c0103935:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c010393c:	c0 
c010393d:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0103944:	00 
c0103945:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c010394c:	e8 a8 ca ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 1);
c0103951:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103954:	89 04 24             	mov    %eax,(%esp)
c0103957:	e8 d3 f1 ff ff       	call   c0102b2f <page_ref>
c010395c:	83 f8 01             	cmp    $0x1,%eax
c010395f:	74 24                	je     c0103985 <check_pgdir+0x3c9>
c0103961:	c7 44 24 0c 4a 69 10 	movl   $0xc010694a,0xc(%esp)
c0103968:	c0 
c0103969:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103970:	c0 
c0103971:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0103978:	00 
c0103979:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103980:	e8 74 ca ff ff       	call   c01003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103985:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010398a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103991:	00 
c0103992:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103999:	00 
c010399a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010399d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039a1:	89 04 24             	mov    %eax,(%esp)
c01039a4:	e8 df fa ff ff       	call   c0103488 <page_insert>
c01039a9:	85 c0                	test   %eax,%eax
c01039ab:	74 24                	je     c01039d1 <check_pgdir+0x415>
c01039ad:	c7 44 24 0c 5c 69 10 	movl   $0xc010695c,0xc(%esp)
c01039b4:	c0 
c01039b5:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01039bc:	c0 
c01039bd:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c01039c4:	00 
c01039c5:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c01039cc:	e8 28 ca ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 2);
c01039d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039d4:	89 04 24             	mov    %eax,(%esp)
c01039d7:	e8 53 f1 ff ff       	call   c0102b2f <page_ref>
c01039dc:	83 f8 02             	cmp    $0x2,%eax
c01039df:	74 24                	je     c0103a05 <check_pgdir+0x449>
c01039e1:	c7 44 24 0c 88 69 10 	movl   $0xc0106988,0xc(%esp)
c01039e8:	c0 
c01039e9:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c01039f0:	c0 
c01039f1:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c01039f8:	00 
c01039f9:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103a00:	e8 f4 c9 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a08:	89 04 24             	mov    %eax,(%esp)
c0103a0b:	e8 1f f1 ff ff       	call   c0102b2f <page_ref>
c0103a10:	85 c0                	test   %eax,%eax
c0103a12:	74 24                	je     c0103a38 <check_pgdir+0x47c>
c0103a14:	c7 44 24 0c 9a 69 10 	movl   $0xc010699a,0xc(%esp)
c0103a1b:	c0 
c0103a1c:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103a23:	c0 
c0103a24:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103a2b:	00 
c0103a2c:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103a33:	e8 c1 c9 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a38:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103a3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a44:	00 
c0103a45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a4c:	00 
c0103a4d:	89 04 24             	mov    %eax,(%esp)
c0103a50:	e8 89 f9 ff ff       	call   c01033de <get_pte>
c0103a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a5c:	75 24                	jne    c0103a82 <check_pgdir+0x4c6>
c0103a5e:	c7 44 24 0c e8 68 10 	movl   $0xc01068e8,0xc(%esp)
c0103a65:	c0 
c0103a66:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103a6d:	c0 
c0103a6e:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103a75:	00 
c0103a76:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103a7d:	e8 77 c9 ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a85:	8b 00                	mov    (%eax),%eax
c0103a87:	89 04 24             	mov    %eax,(%esp)
c0103a8a:	e8 4a f0 ff ff       	call   c0102ad9 <pte2page>
c0103a8f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a92:	74 24                	je     c0103ab8 <check_pgdir+0x4fc>
c0103a94:	c7 44 24 0c 5d 68 10 	movl   $0xc010685d,0xc(%esp)
c0103a9b:	c0 
c0103a9c:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103aa3:	c0 
c0103aa4:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103aab:	00 
c0103aac:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ab3:	e8 41 c9 ff ff       	call   c01003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103abb:	8b 00                	mov    (%eax),%eax
c0103abd:	83 e0 04             	and    $0x4,%eax
c0103ac0:	85 c0                	test   %eax,%eax
c0103ac2:	74 24                	je     c0103ae8 <check_pgdir+0x52c>
c0103ac4:	c7 44 24 0c ac 69 10 	movl   $0xc01069ac,0xc(%esp)
c0103acb:	c0 
c0103acc:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103ad3:	c0 
c0103ad4:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103adb:	00 
c0103adc:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ae3:	e8 11 c9 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103ae8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103aed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103af4:	00 
c0103af5:	89 04 24             	mov    %eax,(%esp)
c0103af8:	e8 46 f9 ff ff       	call   c0103443 <page_remove>
    assert(page_ref(p1) == 1);
c0103afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b00:	89 04 24             	mov    %eax,(%esp)
c0103b03:	e8 27 f0 ff ff       	call   c0102b2f <page_ref>
c0103b08:	83 f8 01             	cmp    $0x1,%eax
c0103b0b:	74 24                	je     c0103b31 <check_pgdir+0x575>
c0103b0d:	c7 44 24 0c 73 68 10 	movl   $0xc0106873,0xc(%esp)
c0103b14:	c0 
c0103b15:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103b2c:	e8 c8 c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103b31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b34:	89 04 24             	mov    %eax,(%esp)
c0103b37:	e8 f3 ef ff ff       	call   c0102b2f <page_ref>
c0103b3c:	85 c0                	test   %eax,%eax
c0103b3e:	74 24                	je     c0103b64 <check_pgdir+0x5a8>
c0103b40:	c7 44 24 0c 9a 69 10 	movl   $0xc010699a,0xc(%esp)
c0103b47:	c0 
c0103b48:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103b4f:	c0 
c0103b50:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103b57:	00 
c0103b58:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103b5f:	e8 95 c8 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103b64:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103b69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b70:	00 
c0103b71:	89 04 24             	mov    %eax,(%esp)
c0103b74:	e8 ca f8 ff ff       	call   c0103443 <page_remove>
    assert(page_ref(p1) == 0);
c0103b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b7c:	89 04 24             	mov    %eax,(%esp)
c0103b7f:	e8 ab ef ff ff       	call   c0102b2f <page_ref>
c0103b84:	85 c0                	test   %eax,%eax
c0103b86:	74 24                	je     c0103bac <check_pgdir+0x5f0>
c0103b88:	c7 44 24 0c c1 69 10 	movl   $0xc01069c1,0xc(%esp)
c0103b8f:	c0 
c0103b90:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103b97:	c0 
c0103b98:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103b9f:	00 
c0103ba0:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ba7:	e8 4d c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103baf:	89 04 24             	mov    %eax,(%esp)
c0103bb2:	e8 78 ef ff ff       	call   c0102b2f <page_ref>
c0103bb7:	85 c0                	test   %eax,%eax
c0103bb9:	74 24                	je     c0103bdf <check_pgdir+0x623>
c0103bbb:	c7 44 24 0c 9a 69 10 	movl   $0xc010699a,0xc(%esp)
c0103bc2:	c0 
c0103bc3:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103bca:	c0 
c0103bcb:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103bd2:	00 
c0103bd3:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103bda:	e8 1a c8 ff ff       	call   c01003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103bdf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103be4:	8b 00                	mov    (%eax),%eax
c0103be6:	89 04 24             	mov    %eax,(%esp)
c0103be9:	e8 29 ef ff ff       	call   c0102b17 <pde2page>
c0103bee:	89 04 24             	mov    %eax,(%esp)
c0103bf1:	e8 39 ef ff ff       	call   c0102b2f <page_ref>
c0103bf6:	83 f8 01             	cmp    $0x1,%eax
c0103bf9:	74 24                	je     c0103c1f <check_pgdir+0x663>
c0103bfb:	c7 44 24 0c d4 69 10 	movl   $0xc01069d4,0xc(%esp)
c0103c02:	c0 
c0103c03:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103c0a:	c0 
c0103c0b:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103c12:	00 
c0103c13:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103c1a:	e8 da c7 ff ff       	call   c01003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103c1f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c24:	8b 00                	mov    (%eax),%eax
c0103c26:	89 04 24             	mov    %eax,(%esp)
c0103c29:	e8 e9 ee ff ff       	call   c0102b17 <pde2page>
c0103c2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c35:	00 
c0103c36:	89 04 24             	mov    %eax,(%esp)
c0103c39:	e8 20 f1 ff ff       	call   c0102d5e <free_pages>
    boot_pgdir[0] = 0;
c0103c3e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103c43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103c49:	c7 04 24 fb 69 10 c0 	movl   $0xc01069fb,(%esp)
c0103c50:	e8 4d c6 ff ff       	call   c01002a2 <cprintf>
}
c0103c55:	90                   	nop
c0103c56:	c9                   	leave  
c0103c57:	c3                   	ret    

c0103c58 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103c58:	55                   	push   %ebp
c0103c59:	89 e5                	mov    %esp,%ebp
c0103c5b:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c65:	e9 ca 00 00 00       	jmp    c0103d34 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c73:	c1 e8 0c             	shr    $0xc,%eax
c0103c76:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103c79:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103c7e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c81:	72 23                	jb     c0103ca6 <check_boot_pgdir+0x4e>
c0103c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c86:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c8a:	c7 44 24 08 40 66 10 	movl   $0xc0106640,0x8(%esp)
c0103c91:	c0 
c0103c92:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103c99:	00 
c0103c9a:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ca1:	e8 53 c7 ff ff       	call   c01003f9 <__panic>
c0103ca6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ca9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103cae:	89 c2                	mov    %eax,%edx
c0103cb0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103cb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103cbc:	00 
c0103cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cc1:	89 04 24             	mov    %eax,(%esp)
c0103cc4:	e8 15 f7 ff ff       	call   c01033de <get_pte>
c0103cc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103ccc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103cd0:	75 24                	jne    c0103cf6 <check_boot_pgdir+0x9e>
c0103cd2:	c7 44 24 0c 18 6a 10 	movl   $0xc0106a18,0xc(%esp)
c0103cd9:	c0 
c0103cda:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103ce1:	c0 
c0103ce2:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103ce9:	00 
c0103cea:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103cf1:	e8 03 c7 ff ff       	call   c01003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103cf6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cf9:	8b 00                	mov    (%eax),%eax
c0103cfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d00:	89 c2                	mov    %eax,%edx
c0103d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d05:	39 c2                	cmp    %eax,%edx
c0103d07:	74 24                	je     c0103d2d <check_boot_pgdir+0xd5>
c0103d09:	c7 44 24 0c 55 6a 10 	movl   $0xc0106a55,0xc(%esp)
c0103d10:	c0 
c0103d11:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103d18:	c0 
c0103d19:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103d20:	00 
c0103d21:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103d28:	e8 cc c6 ff ff       	call   c01003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103d2d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d37:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103d3c:	39 c2                	cmp    %eax,%edx
c0103d3e:	0f 82 26 ff ff ff    	jb     c0103c6a <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103d44:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d49:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d4e:	8b 00                	mov    (%eax),%eax
c0103d50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d55:	89 c2                	mov    %eax,%edx
c0103d57:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d5f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103d66:	77 23                	ja     c0103d8b <check_boot_pgdir+0x133>
c0103d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d6f:	c7 44 24 08 e4 66 10 	movl   $0xc01066e4,0x8(%esp)
c0103d76:	c0 
c0103d77:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103d7e:	00 
c0103d7f:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103d86:	e8 6e c6 ff ff       	call   c01003f9 <__panic>
c0103d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d8e:	05 00 00 00 40       	add    $0x40000000,%eax
c0103d93:	39 d0                	cmp    %edx,%eax
c0103d95:	74 24                	je     c0103dbb <check_boot_pgdir+0x163>
c0103d97:	c7 44 24 0c 6c 6a 10 	movl   $0xc0106a6c,0xc(%esp)
c0103d9e:	c0 
c0103d9f:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103da6:	c0 
c0103da7:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103dae:	00 
c0103daf:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103db6:	e8 3e c6 ff ff       	call   c01003f9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103dbb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103dc0:	8b 00                	mov    (%eax),%eax
c0103dc2:	85 c0                	test   %eax,%eax
c0103dc4:	74 24                	je     c0103dea <check_boot_pgdir+0x192>
c0103dc6:	c7 44 24 0c a0 6a 10 	movl   $0xc0106aa0,0xc(%esp)
c0103dcd:	c0 
c0103dce:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103dd5:	c0 
c0103dd6:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103ddd:	00 
c0103dde:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103de5:	e8 0f c6 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103dea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103df1:	e8 30 ef ff ff       	call   c0102d26 <alloc_pages>
c0103df6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103df9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103dfe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e05:	00 
c0103e06:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103e0d:	00 
c0103e0e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e15:	89 04 24             	mov    %eax,(%esp)
c0103e18:	e8 6b f6 ff ff       	call   c0103488 <page_insert>
c0103e1d:	85 c0                	test   %eax,%eax
c0103e1f:	74 24                	je     c0103e45 <check_boot_pgdir+0x1ed>
c0103e21:	c7 44 24 0c b4 6a 10 	movl   $0xc0106ab4,0xc(%esp)
c0103e28:	c0 
c0103e29:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103e30:	c0 
c0103e31:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103e38:	00 
c0103e39:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103e40:	e8 b4 c5 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 1);
c0103e45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e48:	89 04 24             	mov    %eax,(%esp)
c0103e4b:	e8 df ec ff ff       	call   c0102b2f <page_ref>
c0103e50:	83 f8 01             	cmp    $0x1,%eax
c0103e53:	74 24                	je     c0103e79 <check_boot_pgdir+0x221>
c0103e55:	c7 44 24 0c e2 6a 10 	movl   $0xc0106ae2,0xc(%esp)
c0103e5c:	c0 
c0103e5d:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103e64:	c0 
c0103e65:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103e6c:	00 
c0103e6d:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103e74:	e8 80 c5 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103e79:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103e7e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e85:	00 
c0103e86:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103e8d:	00 
c0103e8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103e91:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e95:	89 04 24             	mov    %eax,(%esp)
c0103e98:	e8 eb f5 ff ff       	call   c0103488 <page_insert>
c0103e9d:	85 c0                	test   %eax,%eax
c0103e9f:	74 24                	je     c0103ec5 <check_boot_pgdir+0x26d>
c0103ea1:	c7 44 24 0c f4 6a 10 	movl   $0xc0106af4,0xc(%esp)
c0103ea8:	c0 
c0103ea9:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103eb0:	c0 
c0103eb1:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103eb8:	00 
c0103eb9:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ec0:	e8 34 c5 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 2);
c0103ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ec8:	89 04 24             	mov    %eax,(%esp)
c0103ecb:	e8 5f ec ff ff       	call   c0102b2f <page_ref>
c0103ed0:	83 f8 02             	cmp    $0x2,%eax
c0103ed3:	74 24                	je     c0103ef9 <check_boot_pgdir+0x2a1>
c0103ed5:	c7 44 24 0c 2b 6b 10 	movl   $0xc0106b2b,0xc(%esp)
c0103edc:	c0 
c0103edd:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103ee4:	c0 
c0103ee5:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0103eec:	00 
c0103eed:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103ef4:	e8 00 c5 ff ff       	call   c01003f9 <__panic>

    const char *str = "ucore: Hello world!!";
c0103ef9:	c7 45 e8 3c 6b 10 c0 	movl   $0xc0106b3c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0103f00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f07:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f0e:	e8 0d 15 00 00       	call   c0105420 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103f13:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103f1a:	00 
c0103f1b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f22:	e8 70 15 00 00       	call   c0105497 <strcmp>
c0103f27:	85 c0                	test   %eax,%eax
c0103f29:	74 24                	je     c0103f4f <check_boot_pgdir+0x2f7>
c0103f2b:	c7 44 24 0c 54 6b 10 	movl   $0xc0106b54,0xc(%esp)
c0103f32:	c0 
c0103f33:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103f3a:	c0 
c0103f3b:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103f42:	00 
c0103f43:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103f4a:	e8 aa c4 ff ff       	call   c01003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f52:	89 04 24             	mov    %eax,(%esp)
c0103f55:	e8 2b eb ff ff       	call   c0102a85 <page2kva>
c0103f5a:	05 00 01 00 00       	add    $0x100,%eax
c0103f5f:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103f62:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f69:	e8 5c 14 00 00       	call   c01053ca <strlen>
c0103f6e:	85 c0                	test   %eax,%eax
c0103f70:	74 24                	je     c0103f96 <check_boot_pgdir+0x33e>
c0103f72:	c7 44 24 0c 8c 6b 10 	movl   $0xc0106b8c,0xc(%esp)
c0103f79:	c0 
c0103f7a:	c7 44 24 08 2d 67 10 	movl   $0xc010672d,0x8(%esp)
c0103f81:	c0 
c0103f82:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0103f89:	00 
c0103f8a:	c7 04 24 08 67 10 c0 	movl   $0xc0106708,(%esp)
c0103f91:	e8 63 c4 ff ff       	call   c01003f9 <__panic>

    free_page(p);
c0103f96:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f9d:	00 
c0103f9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fa1:	89 04 24             	mov    %eax,(%esp)
c0103fa4:	e8 b5 ed ff ff       	call   c0102d5e <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103fa9:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103fae:	8b 00                	mov    (%eax),%eax
c0103fb0:	89 04 24             	mov    %eax,(%esp)
c0103fb3:	e8 5f eb ff ff       	call   c0102b17 <pde2page>
c0103fb8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fbf:	00 
c0103fc0:	89 04 24             	mov    %eax,(%esp)
c0103fc3:	e8 96 ed ff ff       	call   c0102d5e <free_pages>
    boot_pgdir[0] = 0;
c0103fc8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0103fcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103fd3:	c7 04 24 b0 6b 10 c0 	movl   $0xc0106bb0,(%esp)
c0103fda:	e8 c3 c2 ff ff       	call   c01002a2 <cprintf>
}
c0103fdf:	90                   	nop
c0103fe0:	c9                   	leave  
c0103fe1:	c3                   	ret    

c0103fe2 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103fe2:	55                   	push   %ebp
c0103fe3:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fe8:	83 e0 04             	and    $0x4,%eax
c0103feb:	85 c0                	test   %eax,%eax
c0103fed:	74 04                	je     c0103ff3 <perm2str+0x11>
c0103fef:	b0 75                	mov    $0x75,%al
c0103ff1:	eb 02                	jmp    c0103ff5 <perm2str+0x13>
c0103ff3:	b0 2d                	mov    $0x2d,%al
c0103ff5:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0103ffa:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104001:	8b 45 08             	mov    0x8(%ebp),%eax
c0104004:	83 e0 02             	and    $0x2,%eax
c0104007:	85 c0                	test   %eax,%eax
c0104009:	74 04                	je     c010400f <perm2str+0x2d>
c010400b:	b0 77                	mov    $0x77,%al
c010400d:	eb 02                	jmp    c0104011 <perm2str+0x2f>
c010400f:	b0 2d                	mov    $0x2d,%al
c0104011:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0104016:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c010401d:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0104022:	5d                   	pop    %ebp
c0104023:	c3                   	ret    

c0104024 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104024:	55                   	push   %ebp
c0104025:	89 e5                	mov    %esp,%ebp
c0104027:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010402a:	8b 45 10             	mov    0x10(%ebp),%eax
c010402d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104030:	72 0d                	jb     c010403f <get_pgtable_items+0x1b>
        return 0;
c0104032:	b8 00 00 00 00       	mov    $0x0,%eax
c0104037:	e9 98 00 00 00       	jmp    c01040d4 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c010403c:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c010403f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104042:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104045:	73 18                	jae    c010405f <get_pgtable_items+0x3b>
c0104047:	8b 45 10             	mov    0x10(%ebp),%eax
c010404a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104051:	8b 45 14             	mov    0x14(%ebp),%eax
c0104054:	01 d0                	add    %edx,%eax
c0104056:	8b 00                	mov    (%eax),%eax
c0104058:	83 e0 01             	and    $0x1,%eax
c010405b:	85 c0                	test   %eax,%eax
c010405d:	74 dd                	je     c010403c <get_pgtable_items+0x18>
    }
    if (start < right) {
c010405f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104062:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104065:	73 68                	jae    c01040cf <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0104067:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010406b:	74 08                	je     c0104075 <get_pgtable_items+0x51>
            *left_store = start;
c010406d:	8b 45 18             	mov    0x18(%ebp),%eax
c0104070:	8b 55 10             	mov    0x10(%ebp),%edx
c0104073:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0104075:	8b 45 10             	mov    0x10(%ebp),%eax
c0104078:	8d 50 01             	lea    0x1(%eax),%edx
c010407b:	89 55 10             	mov    %edx,0x10(%ebp)
c010407e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104085:	8b 45 14             	mov    0x14(%ebp),%eax
c0104088:	01 d0                	add    %edx,%eax
c010408a:	8b 00                	mov    (%eax),%eax
c010408c:	83 e0 07             	and    $0x7,%eax
c010408f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104092:	eb 03                	jmp    c0104097 <get_pgtable_items+0x73>
            start ++;
c0104094:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104097:	8b 45 10             	mov    0x10(%ebp),%eax
c010409a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010409d:	73 1d                	jae    c01040bc <get_pgtable_items+0x98>
c010409f:	8b 45 10             	mov    0x10(%ebp),%eax
c01040a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01040a9:	8b 45 14             	mov    0x14(%ebp),%eax
c01040ac:	01 d0                	add    %edx,%eax
c01040ae:	8b 00                	mov    (%eax),%eax
c01040b0:	83 e0 07             	and    $0x7,%eax
c01040b3:	89 c2                	mov    %eax,%edx
c01040b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040b8:	39 c2                	cmp    %eax,%edx
c01040ba:	74 d8                	je     c0104094 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c01040bc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01040c0:	74 08                	je     c01040ca <get_pgtable_items+0xa6>
            *right_store = start;
c01040c2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01040c5:	8b 55 10             	mov    0x10(%ebp),%edx
c01040c8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01040ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040cd:	eb 05                	jmp    c01040d4 <get_pgtable_items+0xb0>
    }
    return 0;
c01040cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01040d4:	c9                   	leave  
c01040d5:	c3                   	ret    

c01040d6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01040d6:	55                   	push   %ebp
c01040d7:	89 e5                	mov    %esp,%ebp
c01040d9:	57                   	push   %edi
c01040da:	56                   	push   %esi
c01040db:	53                   	push   %ebx
c01040dc:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01040df:	c7 04 24 d0 6b 10 c0 	movl   $0xc0106bd0,(%esp)
c01040e6:	e8 b7 c1 ff ff       	call   c01002a2 <cprintf>
    size_t left, right = 0, perm;
c01040eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01040f2:	e9 fa 00 00 00       	jmp    c01041f1 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01040f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040fa:	89 04 24             	mov    %eax,(%esp)
c01040fd:	e8 e0 fe ff ff       	call   c0103fe2 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104102:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104105:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104108:	29 d1                	sub    %edx,%ecx
c010410a:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010410c:	89 d6                	mov    %edx,%esi
c010410e:	c1 e6 16             	shl    $0x16,%esi
c0104111:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104114:	89 d3                	mov    %edx,%ebx
c0104116:	c1 e3 16             	shl    $0x16,%ebx
c0104119:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010411c:	89 d1                	mov    %edx,%ecx
c010411e:	c1 e1 16             	shl    $0x16,%ecx
c0104121:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104124:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104127:	29 d7                	sub    %edx,%edi
c0104129:	89 fa                	mov    %edi,%edx
c010412b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010412f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104133:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104137:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010413b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010413f:	c7 04 24 01 6c 10 c0 	movl   $0xc0106c01,(%esp)
c0104146:	e8 57 c1 ff ff       	call   c01002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010414b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010414e:	c1 e0 0a             	shl    $0xa,%eax
c0104151:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104154:	eb 54                	jmp    c01041aa <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104159:	89 04 24             	mov    %eax,(%esp)
c010415c:	e8 81 fe ff ff       	call   c0103fe2 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104161:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104164:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104167:	29 d1                	sub    %edx,%ecx
c0104169:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010416b:	89 d6                	mov    %edx,%esi
c010416d:	c1 e6 0c             	shl    $0xc,%esi
c0104170:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104173:	89 d3                	mov    %edx,%ebx
c0104175:	c1 e3 0c             	shl    $0xc,%ebx
c0104178:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010417b:	89 d1                	mov    %edx,%ecx
c010417d:	c1 e1 0c             	shl    $0xc,%ecx
c0104180:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104183:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104186:	29 d7                	sub    %edx,%edi
c0104188:	89 fa                	mov    %edi,%edx
c010418a:	89 44 24 14          	mov    %eax,0x14(%esp)
c010418e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104192:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104196:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010419a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010419e:	c7 04 24 20 6c 10 c0 	movl   $0xc0106c20,(%esp)
c01041a5:	e8 f8 c0 ff ff       	call   c01002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01041aa:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01041af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041b5:	89 d3                	mov    %edx,%ebx
c01041b7:	c1 e3 0a             	shl    $0xa,%ebx
c01041ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01041bd:	89 d1                	mov    %edx,%ecx
c01041bf:	c1 e1 0a             	shl    $0xa,%ecx
c01041c2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01041c5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041c9:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01041cc:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01041d4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041dc:	89 0c 24             	mov    %ecx,(%esp)
c01041df:	e8 40 fe ff ff       	call   c0104024 <get_pgtable_items>
c01041e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041eb:	0f 85 65 ff ff ff    	jne    c0104156 <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01041f1:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01041f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01041f9:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01041fc:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104200:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104203:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104207:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010420b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010420f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104216:	00 
c0104217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010421e:	e8 01 fe ff ff       	call   c0104024 <get_pgtable_items>
c0104223:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104226:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010422a:	0f 85 c7 fe ff ff    	jne    c01040f7 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104230:	c7 04 24 44 6c 10 c0 	movl   $0xc0106c44,(%esp)
c0104237:	e8 66 c0 ff ff       	call   c01002a2 <cprintf>
}
c010423c:	90                   	nop
c010423d:	83 c4 4c             	add    $0x4c,%esp
c0104240:	5b                   	pop    %ebx
c0104241:	5e                   	pop    %esi
c0104242:	5f                   	pop    %edi
c0104243:	5d                   	pop    %ebp
c0104244:	c3                   	ret    

c0104245 <page2ppn>:
page2ppn(struct Page *page) {
c0104245:	55                   	push   %ebp
c0104246:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104248:	8b 45 08             	mov    0x8(%ebp),%eax
c010424b:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0104251:	29 d0                	sub    %edx,%eax
c0104253:	c1 f8 02             	sar    $0x2,%eax
c0104256:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010425c:	5d                   	pop    %ebp
c010425d:	c3                   	ret    

c010425e <page2pa>:
page2pa(struct Page *page) {
c010425e:	55                   	push   %ebp
c010425f:	89 e5                	mov    %esp,%ebp
c0104261:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104264:	8b 45 08             	mov    0x8(%ebp),%eax
c0104267:	89 04 24             	mov    %eax,(%esp)
c010426a:	e8 d6 ff ff ff       	call   c0104245 <page2ppn>
c010426f:	c1 e0 0c             	shl    $0xc,%eax
}
c0104272:	c9                   	leave  
c0104273:	c3                   	ret    

c0104274 <page_ref>:
page_ref(struct Page *page) {
c0104274:	55                   	push   %ebp
c0104275:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104277:	8b 45 08             	mov    0x8(%ebp),%eax
c010427a:	8b 00                	mov    (%eax),%eax
}
c010427c:	5d                   	pop    %ebp
c010427d:	c3                   	ret    

c010427e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010427e:	55                   	push   %ebp
c010427f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104281:	8b 45 08             	mov    0x8(%ebp),%eax
c0104284:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104287:	89 10                	mov    %edx,(%eax)
}
c0104289:	90                   	nop
c010428a:	5d                   	pop    %ebp
c010428b:	c3                   	ret    

c010428c <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010428c:	55                   	push   %ebp
c010428d:	89 e5                	mov    %esp,%ebp
c010428f:	83 ec 10             	sub    $0x10,%esp
c0104292:	c7 45 fc 1c af 11 c0 	movl   $0xc011af1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104299:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010429c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010429f:	89 50 04             	mov    %edx,0x4(%eax)
c01042a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042a5:	8b 50 04             	mov    0x4(%eax),%edx
c01042a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042ab:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01042ad:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c01042b4:	00 00 00 
}
c01042b7:	90                   	nop
c01042b8:	c9                   	leave  
c01042b9:	c3                   	ret    

c01042ba <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01042ba:	55                   	push   %ebp
c01042bb:	89 e5                	mov    %esp,%ebp
c01042bd:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01042c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01042c4:	75 24                	jne    c01042ea <default_init_memmap+0x30>
c01042c6:	c7 44 24 0c 78 6c 10 	movl   $0xc0106c78,0xc(%esp)
c01042cd:	c0 
c01042ce:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01042d5:	c0 
c01042d6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01042dd:	00 
c01042de:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01042e5:	e8 0f c1 ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c01042ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01042ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01042f0:	eb 7d                	jmp    c010436f <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01042f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042f5:	83 c0 04             	add    $0x4,%eax
c01042f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01042ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104302:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104305:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104308:	0f a3 10             	bt     %edx,(%eax)
c010430b:	19 c0                	sbb    %eax,%eax
c010430d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104310:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104314:	0f 95 c0             	setne  %al
c0104317:	0f b6 c0             	movzbl %al,%eax
c010431a:	85 c0                	test   %eax,%eax
c010431c:	75 24                	jne    c0104342 <default_init_memmap+0x88>
c010431e:	c7 44 24 0c a9 6c 10 	movl   $0xc0106ca9,0xc(%esp)
c0104325:	c0 
c0104326:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c010432d:	c0 
c010432e:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104335:	00 
c0104336:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c010433d:	e8 b7 c0 ff ff       	call   c01003f9 <__panic>
        p->flags = p->property = 0;
c0104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104345:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010434f:	8b 50 08             	mov    0x8(%eax),%edx
c0104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104355:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104358:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010435f:	00 
c0104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104363:	89 04 24             	mov    %eax,(%esp)
c0104366:	e8 13 ff ff ff       	call   c010427e <set_page_ref>
    for (; p != base + n; p ++) {
c010436b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010436f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104372:	89 d0                	mov    %edx,%eax
c0104374:	c1 e0 02             	shl    $0x2,%eax
c0104377:	01 d0                	add    %edx,%eax
c0104379:	c1 e0 02             	shl    $0x2,%eax
c010437c:	89 c2                	mov    %eax,%edx
c010437e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104381:	01 d0                	add    %edx,%eax
c0104383:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104386:	0f 85 66 ff ff ff    	jne    c01042f2 <default_init_memmap+0x38>
    }
    base->property = n;
c010438c:	8b 45 08             	mov    0x8(%ebp),%eax
c010438f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104392:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104395:	8b 45 08             	mov    0x8(%ebp),%eax
c0104398:	83 c0 04             	add    $0x4,%eax
c010439b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01043a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01043a8:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01043ab:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01043ae:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01043b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01043b7:	01 d0                	add    %edx,%eax
c01043b9:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    list_add(&free_list, &(base->page_link));
c01043be:	8b 45 08             	mov    0x8(%ebp),%eax
c01043c1:	83 c0 0c             	add    $0xc,%eax
c01043c4:	c7 45 e4 1c af 11 c0 	movl   $0xc011af1c,-0x1c(%ebp)
c01043cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01043ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01043d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01043d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01043da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043dd:	8b 40 04             	mov    0x4(%eax),%eax
c01043e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01043e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043e9:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01043ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01043ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043f5:	89 10                	mov    %edx,(%eax)
c01043f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043fa:	8b 10                	mov    (%eax),%edx
c01043fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043ff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104402:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104405:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104408:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010440b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010440e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104411:	89 10                	mov    %edx,(%eax)
}
c0104413:	90                   	nop
c0104414:	c9                   	leave  
c0104415:	c3                   	ret    

c0104416 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104416:	55                   	push   %ebp
c0104417:	89 e5                	mov    %esp,%ebp
c0104419:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010441c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104420:	75 24                	jne    c0104446 <default_alloc_pages+0x30>
c0104422:	c7 44 24 0c 78 6c 10 	movl   $0xc0106c78,0xc(%esp)
c0104429:	c0 
c010442a:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104431:	c0 
c0104432:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0104439:	00 
c010443a:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104441:	e8 b3 bf ff ff       	call   c01003f9 <__panic>
    if (n > nr_free) {
c0104446:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c010444b:	39 45 08             	cmp    %eax,0x8(%ebp)
c010444e:	76 0a                	jbe    c010445a <default_alloc_pages+0x44>
        return NULL;
c0104450:	b8 00 00 00 00       	mov    $0x0,%eax
c0104455:	e9 2a 01 00 00       	jmp    c0104584 <default_alloc_pages+0x16e>
    }
    struct Page *page = NULL;
c010445a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104461:	c7 45 f0 1c af 11 c0 	movl   $0xc011af1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104468:	eb 1c                	jmp    c0104486 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c010446a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010446d:	83 e8 0c             	sub    $0xc,%eax
c0104470:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0104473:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104476:	8b 40 08             	mov    0x8(%eax),%eax
c0104479:	39 45 08             	cmp    %eax,0x8(%ebp)
c010447c:	77 08                	ja     c0104486 <default_alloc_pages+0x70>
            page = p;
c010447e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104481:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104484:	eb 18                	jmp    c010449e <default_alloc_pages+0x88>
c0104486:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104489:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010448c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010448f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104492:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104495:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c010449c:	75 cc                	jne    c010446a <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c010449e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044a2:	0f 84 d9 00 00 00    	je     c0104581 <default_alloc_pages+0x16b>
        list_del(&(page->page_link));
c01044a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044ab:	83 c0 0c             	add    $0xc,%eax
c01044ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c01044b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044b4:	8b 40 04             	mov    0x4(%eax),%eax
c01044b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01044ba:	8b 12                	mov    (%edx),%edx
c01044bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01044bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01044c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01044c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01044c8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01044cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044d1:	89 10                	mov    %edx,(%eax)
        if (page->property > n) {
c01044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d6:	8b 40 08             	mov    0x8(%eax),%eax
c01044d9:	39 45 08             	cmp    %eax,0x8(%ebp)
c01044dc:	73 7d                	jae    c010455b <default_alloc_pages+0x145>
            struct Page *p = page + n;
c01044de:	8b 55 08             	mov    0x8(%ebp),%edx
c01044e1:	89 d0                	mov    %edx,%eax
c01044e3:	c1 e0 02             	shl    $0x2,%eax
c01044e6:	01 d0                	add    %edx,%eax
c01044e8:	c1 e0 02             	shl    $0x2,%eax
c01044eb:	89 c2                	mov    %eax,%edx
c01044ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f0:	01 d0                	add    %edx,%eax
c01044f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c01044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f8:	8b 40 08             	mov    0x8(%eax),%eax
c01044fb:	2b 45 08             	sub    0x8(%ebp),%eax
c01044fe:	89 c2                	mov    %eax,%edx
c0104500:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104503:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
c0104506:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104509:	83 c0 0c             	add    $0xc,%eax
c010450c:	c7 45 d4 1c af 11 c0 	movl   $0xc011af1c,-0x2c(%ebp)
c0104513:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104516:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104519:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010451c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010451f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104522:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104525:	8b 40 04             	mov    0x4(%eax),%eax
c0104528:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010452b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c010452e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104531:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0104534:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0104537:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010453a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010453d:	89 10                	mov    %edx,(%eax)
c010453f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104542:	8b 10                	mov    (%eax),%edx
c0104544:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104547:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010454a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010454d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104550:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104553:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104556:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104559:	89 10                	mov    %edx,(%eax)
    }
        nr_free -= n;
c010455b:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104560:	2b 45 08             	sub    0x8(%ebp),%eax
c0104563:	a3 24 af 11 c0       	mov    %eax,0xc011af24
        ClearPageProperty(page);
c0104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010456b:	83 c0 04             	add    $0x4,%eax
c010456e:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0104575:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104578:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010457b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010457e:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104584:	c9                   	leave  
c0104585:	c3                   	ret    

c0104586 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104586:	55                   	push   %ebp
c0104587:	89 e5                	mov    %esp,%ebp
c0104589:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010458f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104593:	75 24                	jne    c01045b9 <default_free_pages+0x33>
c0104595:	c7 44 24 0c 78 6c 10 	movl   $0xc0106c78,0xc(%esp)
c010459c:	c0 
c010459d:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01045a4:	c0 
c01045a5:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01045ac:	00 
c01045ad:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01045b4:	e8 40 be ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c01045b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01045bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01045bf:	e9 9d 00 00 00       	jmp    c0104661 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c01045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c7:	83 c0 04             	add    $0x4,%eax
c01045ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01045d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01045d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01045da:	0f a3 10             	bt     %edx,(%eax)
c01045dd:	19 c0                	sbb    %eax,%eax
c01045df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01045e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045e6:	0f 95 c0             	setne  %al
c01045e9:	0f b6 c0             	movzbl %al,%eax
c01045ec:	85 c0                	test   %eax,%eax
c01045ee:	75 2c                	jne    c010461c <default_free_pages+0x96>
c01045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f3:	83 c0 04             	add    $0x4,%eax
c01045f6:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01045fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104600:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104603:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104606:	0f a3 10             	bt     %edx,(%eax)
c0104609:	19 c0                	sbb    %eax,%eax
c010460b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010460e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104612:	0f 95 c0             	setne  %al
c0104615:	0f b6 c0             	movzbl %al,%eax
c0104618:	85 c0                	test   %eax,%eax
c010461a:	74 24                	je     c0104640 <default_free_pages+0xba>
c010461c:	c7 44 24 0c bc 6c 10 	movl   $0xc0106cbc,0xc(%esp)
c0104623:	c0 
c0104624:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c010462b:	c0 
c010462c:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
c0104633:	00 
c0104634:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c010463b:	e8 b9 bd ff ff       	call   c01003f9 <__panic>
        p->flags = 0;
c0104640:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104643:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c010464a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104651:	00 
c0104652:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104655:	89 04 24             	mov    %eax,(%esp)
c0104658:	e8 21 fc ff ff       	call   c010427e <set_page_ref>
    for (; p != base + n; p ++) {
c010465d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104661:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104664:	89 d0                	mov    %edx,%eax
c0104666:	c1 e0 02             	shl    $0x2,%eax
c0104669:	01 d0                	add    %edx,%eax
c010466b:	c1 e0 02             	shl    $0x2,%eax
c010466e:	89 c2                	mov    %eax,%edx
c0104670:	8b 45 08             	mov    0x8(%ebp),%eax
c0104673:	01 d0                	add    %edx,%eax
c0104675:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104678:	0f 85 46 ff ff ff    	jne    c01045c4 <default_free_pages+0x3e>
    }
    base->property = n;
c010467e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104681:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104684:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104687:	8b 45 08             	mov    0x8(%ebp),%eax
c010468a:	83 c0 04             	add    $0x4,%eax
c010468d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104694:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104697:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010469a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010469d:	0f ab 10             	bts    %edx,(%eax)
c01046a0:	c7 45 d4 1c af 11 c0 	movl   $0xc011af1c,-0x2c(%ebp)
    return listelm->next;
c01046a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046aa:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01046ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01046b0:	e9 08 01 00 00       	jmp    c01047bd <default_free_pages+0x237>
        p = le2page(le, page_link);
c01046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046b8:	83 e8 0c             	sub    $0xc,%eax
c01046bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01046c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01046c7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01046ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c01046cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d0:	8b 50 08             	mov    0x8(%eax),%edx
c01046d3:	89 d0                	mov    %edx,%eax
c01046d5:	c1 e0 02             	shl    $0x2,%eax
c01046d8:	01 d0                	add    %edx,%eax
c01046da:	c1 e0 02             	shl    $0x2,%eax
c01046dd:	89 c2                	mov    %eax,%edx
c01046df:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e2:	01 d0                	add    %edx,%eax
c01046e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01046e7:	75 5a                	jne    c0104743 <default_free_pages+0x1bd>
            base->property += p->property;
c01046e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ec:	8b 50 08             	mov    0x8(%eax),%edx
c01046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f2:	8b 40 08             	mov    0x8(%eax),%eax
c01046f5:	01 c2                	add    %eax,%edx
c01046f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01046fa:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104700:	83 c0 04             	add    $0x4,%eax
c0104703:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010470a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010470d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104710:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104713:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104719:	83 c0 0c             	add    $0xc,%eax
c010471c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010471f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104722:	8b 40 04             	mov    0x4(%eax),%eax
c0104725:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104728:	8b 12                	mov    (%edx),%edx
c010472a:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010472d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0104730:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104733:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104736:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104739:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010473c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010473f:	89 10                	mov    %edx,(%eax)
c0104741:	eb 7a                	jmp    c01047bd <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0104743:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104746:	8b 50 08             	mov    0x8(%eax),%edx
c0104749:	89 d0                	mov    %edx,%eax
c010474b:	c1 e0 02             	shl    $0x2,%eax
c010474e:	01 d0                	add    %edx,%eax
c0104750:	c1 e0 02             	shl    $0x2,%eax
c0104753:	89 c2                	mov    %eax,%edx
c0104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104758:	01 d0                	add    %edx,%eax
c010475a:	39 45 08             	cmp    %eax,0x8(%ebp)
c010475d:	75 5e                	jne    c01047bd <default_free_pages+0x237>
            p->property += base->property;
c010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104762:	8b 50 08             	mov    0x8(%eax),%edx
c0104765:	8b 45 08             	mov    0x8(%ebp),%eax
c0104768:	8b 40 08             	mov    0x8(%eax),%eax
c010476b:	01 c2                	add    %eax,%edx
c010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104770:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104773:	8b 45 08             	mov    0x8(%ebp),%eax
c0104776:	83 c0 04             	add    $0x4,%eax
c0104779:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104780:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104783:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104786:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104789:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010478c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010478f:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104792:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104795:	83 c0 0c             	add    $0xc,%eax
c0104798:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010479b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010479e:	8b 40 04             	mov    0x4(%eax),%eax
c01047a1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01047a4:	8b 12                	mov    (%edx),%edx
c01047a6:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01047a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c01047ac:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01047af:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01047b2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01047b5:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01047b8:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01047bb:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {
c01047bd:	81 7d f0 1c af 11 c0 	cmpl   $0xc011af1c,-0x10(%ebp)
c01047c4:	0f 85 eb fe ff ff    	jne    c01046b5 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
c01047ca:	8b 15 24 af 11 c0    	mov    0xc011af24,%edx
c01047d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047d3:	01 d0                	add    %edx,%eax
c01047d5:	a3 24 af 11 c0       	mov    %eax,0xc011af24
    list_add(&free_list, &(base->page_link));
c01047da:	8b 45 08             	mov    0x8(%ebp),%eax
c01047dd:	83 c0 0c             	add    $0xc,%eax
c01047e0:	c7 45 9c 1c af 11 c0 	movl   $0xc011af1c,-0x64(%ebp)
c01047e7:	89 45 98             	mov    %eax,-0x68(%ebp)
c01047ea:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01047ed:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01047f0:	8b 45 98             	mov    -0x68(%ebp),%eax
c01047f3:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm, listelm->next);
c01047f6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01047f9:	8b 40 04             	mov    0x4(%eax),%eax
c01047fc:	8b 55 90             	mov    -0x70(%ebp),%edx
c01047ff:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104802:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104805:	89 55 88             	mov    %edx,-0x78(%ebp)
c0104808:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c010480b:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010480e:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104811:	89 10                	mov    %edx,(%eax)
c0104813:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104816:	8b 10                	mov    (%eax),%edx
c0104818:	8b 45 88             	mov    -0x78(%ebp),%eax
c010481b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010481e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104821:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104824:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104827:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010482a:	8b 55 88             	mov    -0x78(%ebp),%edx
c010482d:	89 10                	mov    %edx,(%eax)
}
c010482f:	90                   	nop
c0104830:	c9                   	leave  
c0104831:	c3                   	ret    

c0104832 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104832:	55                   	push   %ebp
c0104833:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104835:	a1 24 af 11 c0       	mov    0xc011af24,%eax
}
c010483a:	5d                   	pop    %ebp
c010483b:	c3                   	ret    

c010483c <basic_check>:

static void
basic_check(void) {
c010483c:	55                   	push   %ebp
c010483d:	89 e5                	mov    %esp,%ebp
c010483f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104849:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010484c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010484f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104852:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104855:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010485c:	e8 c5 e4 ff ff       	call   c0102d26 <alloc_pages>
c0104861:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104864:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104868:	75 24                	jne    c010488e <basic_check+0x52>
c010486a:	c7 44 24 0c e1 6c 10 	movl   $0xc0106ce1,0xc(%esp)
c0104871:	c0 
c0104872:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104879:	c0 
c010487a:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0104881:	00 
c0104882:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104889:	e8 6b bb ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010488e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104895:	e8 8c e4 ff ff       	call   c0102d26 <alloc_pages>
c010489a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010489d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048a1:	75 24                	jne    c01048c7 <basic_check+0x8b>
c01048a3:	c7 44 24 0c fd 6c 10 	movl   $0xc0106cfd,0xc(%esp)
c01048aa:	c0 
c01048ab:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01048b2:	c0 
c01048b3:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c01048ba:	00 
c01048bb:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01048c2:	e8 32 bb ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01048c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01048ce:	e8 53 e4 ff ff       	call   c0102d26 <alloc_pages>
c01048d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048da:	75 24                	jne    c0104900 <basic_check+0xc4>
c01048dc:	c7 44 24 0c 19 6d 10 	movl   $0xc0106d19,0xc(%esp)
c01048e3:	c0 
c01048e4:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01048eb:	c0 
c01048ec:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c01048f3:	00 
c01048f4:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01048fb:	e8 f9 ba ff ff       	call   c01003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104900:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104903:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104906:	74 10                	je     c0104918 <basic_check+0xdc>
c0104908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010490b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010490e:	74 08                	je     c0104918 <basic_check+0xdc>
c0104910:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104913:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104916:	75 24                	jne    c010493c <basic_check+0x100>
c0104918:	c7 44 24 0c 38 6d 10 	movl   $0xc0106d38,0xc(%esp)
c010491f:	c0 
c0104920:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104927:	c0 
c0104928:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c010492f:	00 
c0104930:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104937:	e8 bd ba ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010493c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010493f:	89 04 24             	mov    %eax,(%esp)
c0104942:	e8 2d f9 ff ff       	call   c0104274 <page_ref>
c0104947:	85 c0                	test   %eax,%eax
c0104949:	75 1e                	jne    c0104969 <basic_check+0x12d>
c010494b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010494e:	89 04 24             	mov    %eax,(%esp)
c0104951:	e8 1e f9 ff ff       	call   c0104274 <page_ref>
c0104956:	85 c0                	test   %eax,%eax
c0104958:	75 0f                	jne    c0104969 <basic_check+0x12d>
c010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495d:	89 04 24             	mov    %eax,(%esp)
c0104960:	e8 0f f9 ff ff       	call   c0104274 <page_ref>
c0104965:	85 c0                	test   %eax,%eax
c0104967:	74 24                	je     c010498d <basic_check+0x151>
c0104969:	c7 44 24 0c 5c 6d 10 	movl   $0xc0106d5c,0xc(%esp)
c0104970:	c0 
c0104971:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104978:	c0 
c0104979:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0104980:	00 
c0104981:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104988:	e8 6c ba ff ff       	call   c01003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010498d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104990:	89 04 24             	mov    %eax,(%esp)
c0104993:	e8 c6 f8 ff ff       	call   c010425e <page2pa>
c0104998:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c010499e:	c1 e2 0c             	shl    $0xc,%edx
c01049a1:	39 d0                	cmp    %edx,%eax
c01049a3:	72 24                	jb     c01049c9 <basic_check+0x18d>
c01049a5:	c7 44 24 0c 98 6d 10 	movl   $0xc0106d98,0xc(%esp)
c01049ac:	c0 
c01049ad:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01049b4:	c0 
c01049b5:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01049bc:	00 
c01049bd:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01049c4:	e8 30 ba ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01049c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049cc:	89 04 24             	mov    %eax,(%esp)
c01049cf:	e8 8a f8 ff ff       	call   c010425e <page2pa>
c01049d4:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01049da:	c1 e2 0c             	shl    $0xc,%edx
c01049dd:	39 d0                	cmp    %edx,%eax
c01049df:	72 24                	jb     c0104a05 <basic_check+0x1c9>
c01049e1:	c7 44 24 0c b5 6d 10 	movl   $0xc0106db5,0xc(%esp)
c01049e8:	c0 
c01049e9:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01049f0:	c0 
c01049f1:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01049f8:	00 
c01049f9:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104a00:	e8 f4 b9 ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a08:	89 04 24             	mov    %eax,(%esp)
c0104a0b:	e8 4e f8 ff ff       	call   c010425e <page2pa>
c0104a10:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104a16:	c1 e2 0c             	shl    $0xc,%edx
c0104a19:	39 d0                	cmp    %edx,%eax
c0104a1b:	72 24                	jb     c0104a41 <basic_check+0x205>
c0104a1d:	c7 44 24 0c d2 6d 10 	movl   $0xc0106dd2,0xc(%esp)
c0104a24:	c0 
c0104a25:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104a2c:	c0 
c0104a2d:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0104a34:	00 
c0104a35:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104a3c:	e8 b8 b9 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0104a41:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104a46:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a4f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a52:	c7 45 dc 1c af 11 c0 	movl   $0xc011af1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104a59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a5f:	89 50 04             	mov    %edx,0x4(%eax)
c0104a62:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a65:	8b 50 04             	mov    0x4(%eax),%edx
c0104a68:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a6b:	89 10                	mov    %edx,(%eax)
c0104a6d:	c7 45 e0 1c af 11 c0 	movl   $0xc011af1c,-0x20(%ebp)
    return list->next == list;
c0104a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a77:	8b 40 04             	mov    0x4(%eax),%eax
c0104a7a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104a7d:	0f 94 c0             	sete   %al
c0104a80:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104a83:	85 c0                	test   %eax,%eax
c0104a85:	75 24                	jne    c0104aab <basic_check+0x26f>
c0104a87:	c7 44 24 0c ef 6d 10 	movl   $0xc0106def,0xc(%esp)
c0104a8e:	c0 
c0104a8f:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104a96:	c0 
c0104a97:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104a9e:	00 
c0104a9f:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104aa6:	e8 4e b9 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104aab:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104ab0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104ab3:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104aba:	00 00 00 

    assert(alloc_page() == NULL);
c0104abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ac4:	e8 5d e2 ff ff       	call   c0102d26 <alloc_pages>
c0104ac9:	85 c0                	test   %eax,%eax
c0104acb:	74 24                	je     c0104af1 <basic_check+0x2b5>
c0104acd:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104ad4:	c0 
c0104ad5:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104adc:	c0 
c0104add:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104ae4:	00 
c0104ae5:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104aec:	e8 08 b9 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104af1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104af8:	00 
c0104af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104afc:	89 04 24             	mov    %eax,(%esp)
c0104aff:	e8 5a e2 ff ff       	call   c0102d5e <free_pages>
    free_page(p1);
c0104b04:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b0b:	00 
c0104b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b0f:	89 04 24             	mov    %eax,(%esp)
c0104b12:	e8 47 e2 ff ff       	call   c0102d5e <free_pages>
    free_page(p2);
c0104b17:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104b1e:	00 
c0104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b22:	89 04 24             	mov    %eax,(%esp)
c0104b25:	e8 34 e2 ff ff       	call   c0102d5e <free_pages>
    assert(nr_free == 3);
c0104b2a:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104b2f:	83 f8 03             	cmp    $0x3,%eax
c0104b32:	74 24                	je     c0104b58 <basic_check+0x31c>
c0104b34:	c7 44 24 0c 1b 6e 10 	movl   $0xc0106e1b,0xc(%esp)
c0104b3b:	c0 
c0104b3c:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104b43:	c0 
c0104b44:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0104b4b:	00 
c0104b4c:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104b53:	e8 a1 b8 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104b58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b5f:	e8 c2 e1 ff ff       	call   c0102d26 <alloc_pages>
c0104b64:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b6b:	75 24                	jne    c0104b91 <basic_check+0x355>
c0104b6d:	c7 44 24 0c e1 6c 10 	movl   $0xc0106ce1,0xc(%esp)
c0104b74:	c0 
c0104b75:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104b7c:	c0 
c0104b7d:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0104b84:	00 
c0104b85:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104b8c:	e8 68 b8 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104b91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b98:	e8 89 e1 ff ff       	call   c0102d26 <alloc_pages>
c0104b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ba0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ba4:	75 24                	jne    c0104bca <basic_check+0x38e>
c0104ba6:	c7 44 24 0c fd 6c 10 	movl   $0xc0106cfd,0xc(%esp)
c0104bad:	c0 
c0104bae:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104bb5:	c0 
c0104bb6:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104bbd:	00 
c0104bbe:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104bc5:	e8 2f b8 ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104bca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bd1:	e8 50 e1 ff ff       	call   c0102d26 <alloc_pages>
c0104bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104bdd:	75 24                	jne    c0104c03 <basic_check+0x3c7>
c0104bdf:	c7 44 24 0c 19 6d 10 	movl   $0xc0106d19,0xc(%esp)
c0104be6:	c0 
c0104be7:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104bee:	c0 
c0104bef:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0104bf6:	00 
c0104bf7:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104bfe:	e8 f6 b7 ff ff       	call   c01003f9 <__panic>

    assert(alloc_page() == NULL);
c0104c03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c0a:	e8 17 e1 ff ff       	call   c0102d26 <alloc_pages>
c0104c0f:	85 c0                	test   %eax,%eax
c0104c11:	74 24                	je     c0104c37 <basic_check+0x3fb>
c0104c13:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104c1a:	c0 
c0104c1b:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104c22:	c0 
c0104c23:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0104c2a:	00 
c0104c2b:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104c32:	e8 c2 b7 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104c37:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104c3e:	00 
c0104c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c42:	89 04 24             	mov    %eax,(%esp)
c0104c45:	e8 14 e1 ff ff       	call   c0102d5e <free_pages>
c0104c4a:	c7 45 d8 1c af 11 c0 	movl   $0xc011af1c,-0x28(%ebp)
c0104c51:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c54:	8b 40 04             	mov    0x4(%eax),%eax
c0104c57:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104c5a:	0f 94 c0             	sete   %al
c0104c5d:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104c60:	85 c0                	test   %eax,%eax
c0104c62:	74 24                	je     c0104c88 <basic_check+0x44c>
c0104c64:	c7 44 24 0c 28 6e 10 	movl   $0xc0106e28,0xc(%esp)
c0104c6b:	c0 
c0104c6c:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104c73:	c0 
c0104c74:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0104c7b:	00 
c0104c7c:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104c83:	e8 71 b7 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104c88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c8f:	e8 92 e0 ff ff       	call   c0102d26 <alloc_pages>
c0104c94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c9a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104c9d:	74 24                	je     c0104cc3 <basic_check+0x487>
c0104c9f:	c7 44 24 0c 40 6e 10 	movl   $0xc0106e40,0xc(%esp)
c0104ca6:	c0 
c0104ca7:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104cae:	c0 
c0104caf:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104cb6:	00 
c0104cb7:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104cbe:	e8 36 b7 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0104cc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cca:	e8 57 e0 ff ff       	call   c0102d26 <alloc_pages>
c0104ccf:	85 c0                	test   %eax,%eax
c0104cd1:	74 24                	je     c0104cf7 <basic_check+0x4bb>
c0104cd3:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104cda:	c0 
c0104cdb:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104ce2:	c0 
c0104ce3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0104cea:	00 
c0104ceb:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104cf2:	e8 02 b7 ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c0104cf7:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104cfc:	85 c0                	test   %eax,%eax
c0104cfe:	74 24                	je     c0104d24 <basic_check+0x4e8>
c0104d00:	c7 44 24 0c 59 6e 10 	movl   $0xc0106e59,0xc(%esp)
c0104d07:	c0 
c0104d08:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104d0f:	c0 
c0104d10:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104d17:	00 
c0104d18:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104d1f:	e8 d5 b6 ff ff       	call   c01003f9 <__panic>
    free_list = free_list_store;
c0104d24:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d27:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d2a:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c0104d2f:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    nr_free = nr_free_store;
c0104d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d38:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_page(p);
c0104d3d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d44:	00 
c0104d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d48:	89 04 24             	mov    %eax,(%esp)
c0104d4b:	e8 0e e0 ff ff       	call   c0102d5e <free_pages>
    free_page(p1);
c0104d50:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d57:	00 
c0104d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d5b:	89 04 24             	mov    %eax,(%esp)
c0104d5e:	e8 fb df ff ff       	call   c0102d5e <free_pages>
    free_page(p2);
c0104d63:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d6a:	00 
c0104d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d6e:	89 04 24             	mov    %eax,(%esp)
c0104d71:	e8 e8 df ff ff       	call   c0102d5e <free_pages>
}
c0104d76:	90                   	nop
c0104d77:	c9                   	leave  
c0104d78:	c3                   	ret    

c0104d79 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104d79:	55                   	push   %ebp
c0104d7a:	89 e5                	mov    %esp,%ebp
c0104d7c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104d82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d89:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104d90:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104d97:	eb 6a                	jmp    c0104e03 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d9c:	83 e8 0c             	sub    $0xc,%eax
c0104d9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104da2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104da5:	83 c0 04             	add    $0x4,%eax
c0104da8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104daf:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104db2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104db5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104db8:	0f a3 10             	bt     %edx,(%eax)
c0104dbb:	19 c0                	sbb    %eax,%eax
c0104dbd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104dc0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104dc4:	0f 95 c0             	setne  %al
c0104dc7:	0f b6 c0             	movzbl %al,%eax
c0104dca:	85 c0                	test   %eax,%eax
c0104dcc:	75 24                	jne    c0104df2 <default_check+0x79>
c0104dce:	c7 44 24 0c 66 6e 10 	movl   $0xc0106e66,0xc(%esp)
c0104dd5:	c0 
c0104dd6:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104ddd:	c0 
c0104dde:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0104de5:	00 
c0104de6:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104ded:	e8 07 b6 ff ff       	call   c01003f9 <__panic>
        count ++, total += p->property;
c0104df2:	ff 45 f4             	incl   -0xc(%ebp)
c0104df5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104df8:	8b 50 08             	mov    0x8(%eax),%edx
c0104dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dfe:	01 d0                	add    %edx,%eax
c0104e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e06:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104e09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104e0c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104e0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e12:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0104e19:	0f 85 7a ff ff ff    	jne    c0104d99 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104e1f:	e8 6d df ff ff       	call   c0102d91 <nr_free_pages>
c0104e24:	89 c2                	mov    %eax,%edx
c0104e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e29:	39 c2                	cmp    %eax,%edx
c0104e2b:	74 24                	je     c0104e51 <default_check+0xd8>
c0104e2d:	c7 44 24 0c 76 6e 10 	movl   $0xc0106e76,0xc(%esp)
c0104e34:	c0 
c0104e35:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104e3c:	c0 
c0104e3d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104e44:	00 
c0104e45:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104e4c:	e8 a8 b5 ff ff       	call   c01003f9 <__panic>

    basic_check();
c0104e51:	e8 e6 f9 ff ff       	call   c010483c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104e56:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104e5d:	e8 c4 de ff ff       	call   c0102d26 <alloc_pages>
c0104e62:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104e65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104e69:	75 24                	jne    c0104e8f <default_check+0x116>
c0104e6b:	c7 44 24 0c 8f 6e 10 	movl   $0xc0106e8f,0xc(%esp)
c0104e72:	c0 
c0104e73:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104e7a:	c0 
c0104e7b:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0104e82:	00 
c0104e83:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104e8a:	e8 6a b5 ff ff       	call   c01003f9 <__panic>
    assert(!PageProperty(p0));
c0104e8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e92:	83 c0 04             	add    $0x4,%eax
c0104e95:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104e9c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104e9f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104ea2:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104ea5:	0f a3 10             	bt     %edx,(%eax)
c0104ea8:	19 c0                	sbb    %eax,%eax
c0104eaa:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104ead:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104eb1:	0f 95 c0             	setne  %al
c0104eb4:	0f b6 c0             	movzbl %al,%eax
c0104eb7:	85 c0                	test   %eax,%eax
c0104eb9:	74 24                	je     c0104edf <default_check+0x166>
c0104ebb:	c7 44 24 0c 9a 6e 10 	movl   $0xc0106e9a,0xc(%esp)
c0104ec2:	c0 
c0104ec3:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104eca:	c0 
c0104ecb:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0104ed2:	00 
c0104ed3:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104eda:	e8 1a b5 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0104edf:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104ee4:	8b 15 20 af 11 c0    	mov    0xc011af20,%edx
c0104eea:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104eed:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104ef0:	c7 45 b0 1c af 11 c0 	movl   $0xc011af1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104ef7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104efa:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104efd:	89 50 04             	mov    %edx,0x4(%eax)
c0104f00:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f03:	8b 50 04             	mov    0x4(%eax),%edx
c0104f06:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104f09:	89 10                	mov    %edx,(%eax)
c0104f0b:	c7 45 b4 1c af 11 c0 	movl   $0xc011af1c,-0x4c(%ebp)
    return list->next == list;
c0104f12:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104f15:	8b 40 04             	mov    0x4(%eax),%eax
c0104f18:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104f1b:	0f 94 c0             	sete   %al
c0104f1e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104f21:	85 c0                	test   %eax,%eax
c0104f23:	75 24                	jne    c0104f49 <default_check+0x1d0>
c0104f25:	c7 44 24 0c ef 6d 10 	movl   $0xc0106def,0xc(%esp)
c0104f2c:	c0 
c0104f2d:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104f34:	c0 
c0104f35:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104f3c:	00 
c0104f3d:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104f44:	e8 b0 b4 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0104f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f50:	e8 d1 dd ff ff       	call   c0102d26 <alloc_pages>
c0104f55:	85 c0                	test   %eax,%eax
c0104f57:	74 24                	je     c0104f7d <default_check+0x204>
c0104f59:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104f60:	c0 
c0104f61:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104f68:	c0 
c0104f69:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0104f70:	00 
c0104f71:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104f78:	e8 7c b4 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104f7d:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104f85:	c7 05 24 af 11 c0 00 	movl   $0x0,0xc011af24
c0104f8c:	00 00 00 

    free_pages(p0 + 2, 3);
c0104f8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f92:	83 c0 28             	add    $0x28,%eax
c0104f95:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104f9c:	00 
c0104f9d:	89 04 24             	mov    %eax,(%esp)
c0104fa0:	e8 b9 dd ff ff       	call   c0102d5e <free_pages>
    assert(alloc_pages(4) == NULL);
c0104fa5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104fac:	e8 75 dd ff ff       	call   c0102d26 <alloc_pages>
c0104fb1:	85 c0                	test   %eax,%eax
c0104fb3:	74 24                	je     c0104fd9 <default_check+0x260>
c0104fb5:	c7 44 24 0c ac 6e 10 	movl   $0xc0106eac,0xc(%esp)
c0104fbc:	c0 
c0104fbd:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0104fc4:	c0 
c0104fc5:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104fcc:	00 
c0104fcd:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0104fd4:	e8 20 b4 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104fd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fdc:	83 c0 28             	add    $0x28,%eax
c0104fdf:	83 c0 04             	add    $0x4,%eax
c0104fe2:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104fe9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fec:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104fef:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104ff2:	0f a3 10             	bt     %edx,(%eax)
c0104ff5:	19 c0                	sbb    %eax,%eax
c0104ff7:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104ffa:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104ffe:	0f 95 c0             	setne  %al
c0105001:	0f b6 c0             	movzbl %al,%eax
c0105004:	85 c0                	test   %eax,%eax
c0105006:	74 0e                	je     c0105016 <default_check+0x29d>
c0105008:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010500b:	83 c0 28             	add    $0x28,%eax
c010500e:	8b 40 08             	mov    0x8(%eax),%eax
c0105011:	83 f8 03             	cmp    $0x3,%eax
c0105014:	74 24                	je     c010503a <default_check+0x2c1>
c0105016:	c7 44 24 0c c4 6e 10 	movl   $0xc0106ec4,0xc(%esp)
c010501d:	c0 
c010501e:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0105025:	c0 
c0105026:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c010502d:	00 
c010502e:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0105035:	e8 bf b3 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010503a:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105041:	e8 e0 dc ff ff       	call   c0102d26 <alloc_pages>
c0105046:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105049:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010504d:	75 24                	jne    c0105073 <default_check+0x2fa>
c010504f:	c7 44 24 0c f0 6e 10 	movl   $0xc0106ef0,0xc(%esp)
c0105056:	c0 
c0105057:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c010505e:	c0 
c010505f:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0105066:	00 
c0105067:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c010506e:	e8 86 b3 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105073:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010507a:	e8 a7 dc ff ff       	call   c0102d26 <alloc_pages>
c010507f:	85 c0                	test   %eax,%eax
c0105081:	74 24                	je     c01050a7 <default_check+0x32e>
c0105083:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c010508a:	c0 
c010508b:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0105092:	c0 
c0105093:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010509a:	00 
c010509b:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01050a2:	e8 52 b3 ff ff       	call   c01003f9 <__panic>
    assert(p0 + 2 == p1);
c01050a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050aa:	83 c0 28             	add    $0x28,%eax
c01050ad:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01050b0:	74 24                	je     c01050d6 <default_check+0x35d>
c01050b2:	c7 44 24 0c 0e 6f 10 	movl   $0xc0106f0e,0xc(%esp)
c01050b9:	c0 
c01050ba:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01050c1:	c0 
c01050c2:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01050c9:	00 
c01050ca:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01050d1:	e8 23 b3 ff ff       	call   c01003f9 <__panic>

    p2 = p0 + 1;
c01050d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050d9:	83 c0 14             	add    $0x14,%eax
c01050dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01050df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050e6:	00 
c01050e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050ea:	89 04 24             	mov    %eax,(%esp)
c01050ed:	e8 6c dc ff ff       	call   c0102d5e <free_pages>
    free_pages(p1, 3);
c01050f2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01050f9:	00 
c01050fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050fd:	89 04 24             	mov    %eax,(%esp)
c0105100:	e8 59 dc ff ff       	call   c0102d5e <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105105:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105108:	83 c0 04             	add    $0x4,%eax
c010510b:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105112:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105115:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105118:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010511b:	0f a3 10             	bt     %edx,(%eax)
c010511e:	19 c0                	sbb    %eax,%eax
c0105120:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105123:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105127:	0f 95 c0             	setne  %al
c010512a:	0f b6 c0             	movzbl %al,%eax
c010512d:	85 c0                	test   %eax,%eax
c010512f:	74 0b                	je     c010513c <default_check+0x3c3>
c0105131:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105134:	8b 40 08             	mov    0x8(%eax),%eax
c0105137:	83 f8 01             	cmp    $0x1,%eax
c010513a:	74 24                	je     c0105160 <default_check+0x3e7>
c010513c:	c7 44 24 0c 1c 6f 10 	movl   $0xc0106f1c,0xc(%esp)
c0105143:	c0 
c0105144:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c010514b:	c0 
c010514c:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0105153:	00 
c0105154:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c010515b:	e8 99 b2 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105160:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105163:	83 c0 04             	add    $0x4,%eax
c0105166:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010516d:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105170:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105173:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105176:	0f a3 10             	bt     %edx,(%eax)
c0105179:	19 c0                	sbb    %eax,%eax
c010517b:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010517e:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105182:	0f 95 c0             	setne  %al
c0105185:	0f b6 c0             	movzbl %al,%eax
c0105188:	85 c0                	test   %eax,%eax
c010518a:	74 0b                	je     c0105197 <default_check+0x41e>
c010518c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010518f:	8b 40 08             	mov    0x8(%eax),%eax
c0105192:	83 f8 03             	cmp    $0x3,%eax
c0105195:	74 24                	je     c01051bb <default_check+0x442>
c0105197:	c7 44 24 0c 44 6f 10 	movl   $0xc0106f44,0xc(%esp)
c010519e:	c0 
c010519f:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01051a6:	c0 
c01051a7:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01051ae:	00 
c01051af:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01051b6:	e8 3e b2 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01051bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051c2:	e8 5f db ff ff       	call   c0102d26 <alloc_pages>
c01051c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01051ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051cd:	83 e8 14             	sub    $0x14,%eax
c01051d0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01051d3:	74 24                	je     c01051f9 <default_check+0x480>
c01051d5:	c7 44 24 0c 6a 6f 10 	movl   $0xc0106f6a,0xc(%esp)
c01051dc:	c0 
c01051dd:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01051e4:	c0 
c01051e5:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01051ec:	00 
c01051ed:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01051f4:	e8 00 b2 ff ff       	call   c01003f9 <__panic>
    free_page(p0);
c01051f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105200:	00 
c0105201:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105204:	89 04 24             	mov    %eax,(%esp)
c0105207:	e8 52 db ff ff       	call   c0102d5e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010520c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105213:	e8 0e db ff ff       	call   c0102d26 <alloc_pages>
c0105218:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010521b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010521e:	83 c0 14             	add    $0x14,%eax
c0105221:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105224:	74 24                	je     c010524a <default_check+0x4d1>
c0105226:	c7 44 24 0c 88 6f 10 	movl   $0xc0106f88,0xc(%esp)
c010522d:	c0 
c010522e:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0105235:	c0 
c0105236:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010523d:	00 
c010523e:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0105245:	e8 af b1 ff ff       	call   c01003f9 <__panic>

    free_pages(p0, 2);
c010524a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105251:	00 
c0105252:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105255:	89 04 24             	mov    %eax,(%esp)
c0105258:	e8 01 db ff ff       	call   c0102d5e <free_pages>
    free_page(p2);
c010525d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105264:	00 
c0105265:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105268:	89 04 24             	mov    %eax,(%esp)
c010526b:	e8 ee da ff ff       	call   c0102d5e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105270:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105277:	e8 aa da ff ff       	call   c0102d26 <alloc_pages>
c010527c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010527f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105283:	75 24                	jne    c01052a9 <default_check+0x530>
c0105285:	c7 44 24 0c a8 6f 10 	movl   $0xc0106fa8,0xc(%esp)
c010528c:	c0 
c010528d:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0105294:	c0 
c0105295:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c010529c:	00 
c010529d:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01052a4:	e8 50 b1 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c01052a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01052b0:	e8 71 da ff ff       	call   c0102d26 <alloc_pages>
c01052b5:	85 c0                	test   %eax,%eax
c01052b7:	74 24                	je     c01052dd <default_check+0x564>
c01052b9:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c01052c0:	c0 
c01052c1:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01052c8:	c0 
c01052c9:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01052d0:	00 
c01052d1:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01052d8:	e8 1c b1 ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c01052dd:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01052e2:	85 c0                	test   %eax,%eax
c01052e4:	74 24                	je     c010530a <default_check+0x591>
c01052e6:	c7 44 24 0c 59 6e 10 	movl   $0xc0106e59,0xc(%esp)
c01052ed:	c0 
c01052ee:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01052f5:	c0 
c01052f6:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01052fd:	00 
c01052fe:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0105305:	e8 ef b0 ff ff       	call   c01003f9 <__panic>
    nr_free = nr_free_store;
c010530a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010530d:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    free_list = free_list_store;
c0105312:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105315:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105318:	a3 1c af 11 c0       	mov    %eax,0xc011af1c
c010531d:	89 15 20 af 11 c0    	mov    %edx,0xc011af20
    free_pages(p0, 5);
c0105323:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010532a:	00 
c010532b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010532e:	89 04 24             	mov    %eax,(%esp)
c0105331:	e8 28 da ff ff       	call   c0102d5e <free_pages>

    le = &free_list;
c0105336:	c7 45 ec 1c af 11 c0 	movl   $0xc011af1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010533d:	eb 1c                	jmp    c010535b <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c010533f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105342:	83 e8 0c             	sub    $0xc,%eax
c0105345:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105348:	ff 4d f4             	decl   -0xc(%ebp)
c010534b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010534e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105351:	8b 40 08             	mov    0x8(%eax),%eax
c0105354:	29 c2                	sub    %eax,%edx
c0105356:	89 d0                	mov    %edx,%eax
c0105358:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010535b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010535e:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105361:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105364:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105367:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010536a:	81 7d ec 1c af 11 c0 	cmpl   $0xc011af1c,-0x14(%ebp)
c0105371:	75 cc                	jne    c010533f <default_check+0x5c6>
    }
    assert(count == 0);
c0105373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105377:	74 24                	je     c010539d <default_check+0x624>
c0105379:	c7 44 24 0c c6 6f 10 	movl   $0xc0106fc6,0xc(%esp)
c0105380:	c0 
c0105381:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c0105388:	c0 
c0105389:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0105390:	00 
c0105391:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c0105398:	e8 5c b0 ff ff       	call   c01003f9 <__panic>
    assert(total == 0);
c010539d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01053a1:	74 24                	je     c01053c7 <default_check+0x64e>
c01053a3:	c7 44 24 0c d1 6f 10 	movl   $0xc0106fd1,0xc(%esp)
c01053aa:	c0 
c01053ab:	c7 44 24 08 7e 6c 10 	movl   $0xc0106c7e,0x8(%esp)
c01053b2:	c0 
c01053b3:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01053ba:	00 
c01053bb:	c7 04 24 93 6c 10 c0 	movl   $0xc0106c93,(%esp)
c01053c2:	e8 32 b0 ff ff       	call   c01003f9 <__panic>
}
c01053c7:	90                   	nop
c01053c8:	c9                   	leave  
c01053c9:	c3                   	ret    

c01053ca <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01053ca:	55                   	push   %ebp
c01053cb:	89 e5                	mov    %esp,%ebp
c01053cd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01053d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01053d7:	eb 03                	jmp    c01053dc <strlen+0x12>
        cnt ++;
c01053d9:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01053dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01053df:	8d 50 01             	lea    0x1(%eax),%edx
c01053e2:	89 55 08             	mov    %edx,0x8(%ebp)
c01053e5:	0f b6 00             	movzbl (%eax),%eax
c01053e8:	84 c0                	test   %al,%al
c01053ea:	75 ed                	jne    c01053d9 <strlen+0xf>
    }
    return cnt;
c01053ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01053ef:	c9                   	leave  
c01053f0:	c3                   	ret    

c01053f1 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01053f1:	55                   	push   %ebp
c01053f2:	89 e5                	mov    %esp,%ebp
c01053f4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01053f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01053fe:	eb 03                	jmp    c0105403 <strnlen+0x12>
        cnt ++;
c0105400:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105403:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105406:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105409:	73 10                	jae    c010541b <strnlen+0x2a>
c010540b:	8b 45 08             	mov    0x8(%ebp),%eax
c010540e:	8d 50 01             	lea    0x1(%eax),%edx
c0105411:	89 55 08             	mov    %edx,0x8(%ebp)
c0105414:	0f b6 00             	movzbl (%eax),%eax
c0105417:	84 c0                	test   %al,%al
c0105419:	75 e5                	jne    c0105400 <strnlen+0xf>
    }
    return cnt;
c010541b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010541e:	c9                   	leave  
c010541f:	c3                   	ret    

c0105420 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105420:	55                   	push   %ebp
c0105421:	89 e5                	mov    %esp,%ebp
c0105423:	57                   	push   %edi
c0105424:	56                   	push   %esi
c0105425:	83 ec 20             	sub    $0x20,%esp
c0105428:	8b 45 08             	mov    0x8(%ebp),%eax
c010542b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010542e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105431:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105434:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105437:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010543a:	89 d1                	mov    %edx,%ecx
c010543c:	89 c2                	mov    %eax,%edx
c010543e:	89 ce                	mov    %ecx,%esi
c0105440:	89 d7                	mov    %edx,%edi
c0105442:	ac                   	lods   %ds:(%esi),%al
c0105443:	aa                   	stos   %al,%es:(%edi)
c0105444:	84 c0                	test   %al,%al
c0105446:	75 fa                	jne    c0105442 <strcpy+0x22>
c0105448:	89 fa                	mov    %edi,%edx
c010544a:	89 f1                	mov    %esi,%ecx
c010544c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010544f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105452:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105455:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105458:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105459:	83 c4 20             	add    $0x20,%esp
c010545c:	5e                   	pop    %esi
c010545d:	5f                   	pop    %edi
c010545e:	5d                   	pop    %ebp
c010545f:	c3                   	ret    

c0105460 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105460:	55                   	push   %ebp
c0105461:	89 e5                	mov    %esp,%ebp
c0105463:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105466:	8b 45 08             	mov    0x8(%ebp),%eax
c0105469:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010546c:	eb 1e                	jmp    c010548c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010546e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105471:	0f b6 10             	movzbl (%eax),%edx
c0105474:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105477:	88 10                	mov    %dl,(%eax)
c0105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010547c:	0f b6 00             	movzbl (%eax),%eax
c010547f:	84 c0                	test   %al,%al
c0105481:	74 03                	je     c0105486 <strncpy+0x26>
            src ++;
c0105483:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105486:	ff 45 fc             	incl   -0x4(%ebp)
c0105489:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010548c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105490:	75 dc                	jne    c010546e <strncpy+0xe>
    }
    return dst;
c0105492:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105495:	c9                   	leave  
c0105496:	c3                   	ret    

c0105497 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105497:	55                   	push   %ebp
c0105498:	89 e5                	mov    %esp,%ebp
c010549a:	57                   	push   %edi
c010549b:	56                   	push   %esi
c010549c:	83 ec 20             	sub    $0x20,%esp
c010549f:	8b 45 08             	mov    0x8(%ebp),%eax
c01054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01054ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054b1:	89 d1                	mov    %edx,%ecx
c01054b3:	89 c2                	mov    %eax,%edx
c01054b5:	89 ce                	mov    %ecx,%esi
c01054b7:	89 d7                	mov    %edx,%edi
c01054b9:	ac                   	lods   %ds:(%esi),%al
c01054ba:	ae                   	scas   %es:(%edi),%al
c01054bb:	75 08                	jne    c01054c5 <strcmp+0x2e>
c01054bd:	84 c0                	test   %al,%al
c01054bf:	75 f8                	jne    c01054b9 <strcmp+0x22>
c01054c1:	31 c0                	xor    %eax,%eax
c01054c3:	eb 04                	jmp    c01054c9 <strcmp+0x32>
c01054c5:	19 c0                	sbb    %eax,%eax
c01054c7:	0c 01                	or     $0x1,%al
c01054c9:	89 fa                	mov    %edi,%edx
c01054cb:	89 f1                	mov    %esi,%ecx
c01054cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01054d0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01054d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01054d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01054d9:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01054da:	83 c4 20             	add    $0x20,%esp
c01054dd:	5e                   	pop    %esi
c01054de:	5f                   	pop    %edi
c01054df:	5d                   	pop    %ebp
c01054e0:	c3                   	ret    

c01054e1 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01054e1:	55                   	push   %ebp
c01054e2:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01054e4:	eb 09                	jmp    c01054ef <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01054e6:	ff 4d 10             	decl   0x10(%ebp)
c01054e9:	ff 45 08             	incl   0x8(%ebp)
c01054ec:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01054ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01054f3:	74 1a                	je     c010550f <strncmp+0x2e>
c01054f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01054f8:	0f b6 00             	movzbl (%eax),%eax
c01054fb:	84 c0                	test   %al,%al
c01054fd:	74 10                	je     c010550f <strncmp+0x2e>
c01054ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105502:	0f b6 10             	movzbl (%eax),%edx
c0105505:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105508:	0f b6 00             	movzbl (%eax),%eax
c010550b:	38 c2                	cmp    %al,%dl
c010550d:	74 d7                	je     c01054e6 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010550f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105513:	74 18                	je     c010552d <strncmp+0x4c>
c0105515:	8b 45 08             	mov    0x8(%ebp),%eax
c0105518:	0f b6 00             	movzbl (%eax),%eax
c010551b:	0f b6 d0             	movzbl %al,%edx
c010551e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105521:	0f b6 00             	movzbl (%eax),%eax
c0105524:	0f b6 c0             	movzbl %al,%eax
c0105527:	29 c2                	sub    %eax,%edx
c0105529:	89 d0                	mov    %edx,%eax
c010552b:	eb 05                	jmp    c0105532 <strncmp+0x51>
c010552d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105532:	5d                   	pop    %ebp
c0105533:	c3                   	ret    

c0105534 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105534:	55                   	push   %ebp
c0105535:	89 e5                	mov    %esp,%ebp
c0105537:	83 ec 04             	sub    $0x4,%esp
c010553a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010553d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105540:	eb 13                	jmp    c0105555 <strchr+0x21>
        if (*s == c) {
c0105542:	8b 45 08             	mov    0x8(%ebp),%eax
c0105545:	0f b6 00             	movzbl (%eax),%eax
c0105548:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010554b:	75 05                	jne    c0105552 <strchr+0x1e>
            return (char *)s;
c010554d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105550:	eb 12                	jmp    c0105564 <strchr+0x30>
        }
        s ++;
c0105552:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105555:	8b 45 08             	mov    0x8(%ebp),%eax
c0105558:	0f b6 00             	movzbl (%eax),%eax
c010555b:	84 c0                	test   %al,%al
c010555d:	75 e3                	jne    c0105542 <strchr+0xe>
    }
    return NULL;
c010555f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105564:	c9                   	leave  
c0105565:	c3                   	ret    

c0105566 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105566:	55                   	push   %ebp
c0105567:	89 e5                	mov    %esp,%ebp
c0105569:	83 ec 04             	sub    $0x4,%esp
c010556c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010556f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105572:	eb 0e                	jmp    c0105582 <strfind+0x1c>
        if (*s == c) {
c0105574:	8b 45 08             	mov    0x8(%ebp),%eax
c0105577:	0f b6 00             	movzbl (%eax),%eax
c010557a:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010557d:	74 0f                	je     c010558e <strfind+0x28>
            break;
        }
        s ++;
c010557f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105582:	8b 45 08             	mov    0x8(%ebp),%eax
c0105585:	0f b6 00             	movzbl (%eax),%eax
c0105588:	84 c0                	test   %al,%al
c010558a:	75 e8                	jne    c0105574 <strfind+0xe>
c010558c:	eb 01                	jmp    c010558f <strfind+0x29>
            break;
c010558e:	90                   	nop
    }
    return (char *)s;
c010558f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105592:	c9                   	leave  
c0105593:	c3                   	ret    

c0105594 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105594:	55                   	push   %ebp
c0105595:	89 e5                	mov    %esp,%ebp
c0105597:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010559a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01055a1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01055a8:	eb 03                	jmp    c01055ad <strtol+0x19>
        s ++;
c01055aa:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c01055ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b0:	0f b6 00             	movzbl (%eax),%eax
c01055b3:	3c 20                	cmp    $0x20,%al
c01055b5:	74 f3                	je     c01055aa <strtol+0x16>
c01055b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ba:	0f b6 00             	movzbl (%eax),%eax
c01055bd:	3c 09                	cmp    $0x9,%al
c01055bf:	74 e9                	je     c01055aa <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01055c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c4:	0f b6 00             	movzbl (%eax),%eax
c01055c7:	3c 2b                	cmp    $0x2b,%al
c01055c9:	75 05                	jne    c01055d0 <strtol+0x3c>
        s ++;
c01055cb:	ff 45 08             	incl   0x8(%ebp)
c01055ce:	eb 14                	jmp    c01055e4 <strtol+0x50>
    }
    else if (*s == '-') {
c01055d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d3:	0f b6 00             	movzbl (%eax),%eax
c01055d6:	3c 2d                	cmp    $0x2d,%al
c01055d8:	75 0a                	jne    c01055e4 <strtol+0x50>
        s ++, neg = 1;
c01055da:	ff 45 08             	incl   0x8(%ebp)
c01055dd:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01055e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055e8:	74 06                	je     c01055f0 <strtol+0x5c>
c01055ea:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01055ee:	75 22                	jne    c0105612 <strtol+0x7e>
c01055f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01055f3:	0f b6 00             	movzbl (%eax),%eax
c01055f6:	3c 30                	cmp    $0x30,%al
c01055f8:	75 18                	jne    c0105612 <strtol+0x7e>
c01055fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01055fd:	40                   	inc    %eax
c01055fe:	0f b6 00             	movzbl (%eax),%eax
c0105601:	3c 78                	cmp    $0x78,%al
c0105603:	75 0d                	jne    c0105612 <strtol+0x7e>
        s += 2, base = 16;
c0105605:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105609:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105610:	eb 29                	jmp    c010563b <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105612:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105616:	75 16                	jne    c010562e <strtol+0x9a>
c0105618:	8b 45 08             	mov    0x8(%ebp),%eax
c010561b:	0f b6 00             	movzbl (%eax),%eax
c010561e:	3c 30                	cmp    $0x30,%al
c0105620:	75 0c                	jne    c010562e <strtol+0x9a>
        s ++, base = 8;
c0105622:	ff 45 08             	incl   0x8(%ebp)
c0105625:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010562c:	eb 0d                	jmp    c010563b <strtol+0xa7>
    }
    else if (base == 0) {
c010562e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105632:	75 07                	jne    c010563b <strtol+0xa7>
        base = 10;
c0105634:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010563b:	8b 45 08             	mov    0x8(%ebp),%eax
c010563e:	0f b6 00             	movzbl (%eax),%eax
c0105641:	3c 2f                	cmp    $0x2f,%al
c0105643:	7e 1b                	jle    c0105660 <strtol+0xcc>
c0105645:	8b 45 08             	mov    0x8(%ebp),%eax
c0105648:	0f b6 00             	movzbl (%eax),%eax
c010564b:	3c 39                	cmp    $0x39,%al
c010564d:	7f 11                	jg     c0105660 <strtol+0xcc>
            dig = *s - '0';
c010564f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105652:	0f b6 00             	movzbl (%eax),%eax
c0105655:	0f be c0             	movsbl %al,%eax
c0105658:	83 e8 30             	sub    $0x30,%eax
c010565b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010565e:	eb 48                	jmp    c01056a8 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105660:	8b 45 08             	mov    0x8(%ebp),%eax
c0105663:	0f b6 00             	movzbl (%eax),%eax
c0105666:	3c 60                	cmp    $0x60,%al
c0105668:	7e 1b                	jle    c0105685 <strtol+0xf1>
c010566a:	8b 45 08             	mov    0x8(%ebp),%eax
c010566d:	0f b6 00             	movzbl (%eax),%eax
c0105670:	3c 7a                	cmp    $0x7a,%al
c0105672:	7f 11                	jg     c0105685 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105674:	8b 45 08             	mov    0x8(%ebp),%eax
c0105677:	0f b6 00             	movzbl (%eax),%eax
c010567a:	0f be c0             	movsbl %al,%eax
c010567d:	83 e8 57             	sub    $0x57,%eax
c0105680:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105683:	eb 23                	jmp    c01056a8 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105685:	8b 45 08             	mov    0x8(%ebp),%eax
c0105688:	0f b6 00             	movzbl (%eax),%eax
c010568b:	3c 40                	cmp    $0x40,%al
c010568d:	7e 3b                	jle    c01056ca <strtol+0x136>
c010568f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105692:	0f b6 00             	movzbl (%eax),%eax
c0105695:	3c 5a                	cmp    $0x5a,%al
c0105697:	7f 31                	jg     c01056ca <strtol+0x136>
            dig = *s - 'A' + 10;
c0105699:	8b 45 08             	mov    0x8(%ebp),%eax
c010569c:	0f b6 00             	movzbl (%eax),%eax
c010569f:	0f be c0             	movsbl %al,%eax
c01056a2:	83 e8 37             	sub    $0x37,%eax
c01056a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01056a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056ab:	3b 45 10             	cmp    0x10(%ebp),%eax
c01056ae:	7d 19                	jge    c01056c9 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01056b0:	ff 45 08             	incl   0x8(%ebp)
c01056b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056b6:	0f af 45 10          	imul   0x10(%ebp),%eax
c01056ba:	89 c2                	mov    %eax,%edx
c01056bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056bf:	01 d0                	add    %edx,%eax
c01056c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01056c4:	e9 72 ff ff ff       	jmp    c010563b <strtol+0xa7>
            break;
c01056c9:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01056ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01056ce:	74 08                	je     c01056d8 <strtol+0x144>
        *endptr = (char *) s;
c01056d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01056d6:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01056d8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01056dc:	74 07                	je     c01056e5 <strtol+0x151>
c01056de:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01056e1:	f7 d8                	neg    %eax
c01056e3:	eb 03                	jmp    c01056e8 <strtol+0x154>
c01056e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01056e8:	c9                   	leave  
c01056e9:	c3                   	ret    

c01056ea <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01056ea:	55                   	push   %ebp
c01056eb:	89 e5                	mov    %esp,%ebp
c01056ed:	57                   	push   %edi
c01056ee:	83 ec 24             	sub    $0x24,%esp
c01056f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056f4:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01056f7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01056fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01056fe:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105701:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105704:	8b 45 10             	mov    0x10(%ebp),%eax
c0105707:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010570a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010570d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105711:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105714:	89 d7                	mov    %edx,%edi
c0105716:	f3 aa                	rep stos %al,%es:(%edi)
c0105718:	89 fa                	mov    %edi,%edx
c010571a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010571d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105720:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105723:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105724:	83 c4 24             	add    $0x24,%esp
c0105727:	5f                   	pop    %edi
c0105728:	5d                   	pop    %ebp
c0105729:	c3                   	ret    

c010572a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010572a:	55                   	push   %ebp
c010572b:	89 e5                	mov    %esp,%ebp
c010572d:	57                   	push   %edi
c010572e:	56                   	push   %esi
c010572f:	53                   	push   %ebx
c0105730:	83 ec 30             	sub    $0x30,%esp
c0105733:	8b 45 08             	mov    0x8(%ebp),%eax
c0105736:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105739:	8b 45 0c             	mov    0xc(%ebp),%eax
c010573c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010573f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105742:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105748:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010574b:	73 42                	jae    c010578f <memmove+0x65>
c010574d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105753:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105756:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105759:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010575c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010575f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105762:	c1 e8 02             	shr    $0x2,%eax
c0105765:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010576a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010576d:	89 d7                	mov    %edx,%edi
c010576f:	89 c6                	mov    %eax,%esi
c0105771:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105773:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105776:	83 e1 03             	and    $0x3,%ecx
c0105779:	74 02                	je     c010577d <memmove+0x53>
c010577b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010577d:	89 f0                	mov    %esi,%eax
c010577f:	89 fa                	mov    %edi,%edx
c0105781:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105784:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105787:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010578a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010578d:	eb 36                	jmp    c01057c5 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010578f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105792:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105795:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105798:	01 c2                	add    %eax,%edx
c010579a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010579d:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01057a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057a3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01057a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057a9:	89 c1                	mov    %eax,%ecx
c01057ab:	89 d8                	mov    %ebx,%eax
c01057ad:	89 d6                	mov    %edx,%esi
c01057af:	89 c7                	mov    %eax,%edi
c01057b1:	fd                   	std    
c01057b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01057b4:	fc                   	cld    
c01057b5:	89 f8                	mov    %edi,%eax
c01057b7:	89 f2                	mov    %esi,%edx
c01057b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01057bc:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01057bf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01057c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01057c5:	83 c4 30             	add    $0x30,%esp
c01057c8:	5b                   	pop    %ebx
c01057c9:	5e                   	pop    %esi
c01057ca:	5f                   	pop    %edi
c01057cb:	5d                   	pop    %ebp
c01057cc:	c3                   	ret    

c01057cd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01057cd:	55                   	push   %ebp
c01057ce:	89 e5                	mov    %esp,%ebp
c01057d0:	57                   	push   %edi
c01057d1:	56                   	push   %esi
c01057d2:	83 ec 20             	sub    $0x20,%esp
c01057d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01057db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01057e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01057e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057ea:	c1 e8 02             	shr    $0x2,%eax
c01057ed:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01057ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f5:	89 d7                	mov    %edx,%edi
c01057f7:	89 c6                	mov    %eax,%esi
c01057f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01057fb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01057fe:	83 e1 03             	and    $0x3,%ecx
c0105801:	74 02                	je     c0105805 <memcpy+0x38>
c0105803:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105805:	89 f0                	mov    %esi,%eax
c0105807:	89 fa                	mov    %edi,%edx
c0105809:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010580c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010580f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105812:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105815:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105816:	83 c4 20             	add    $0x20,%esp
c0105819:	5e                   	pop    %esi
c010581a:	5f                   	pop    %edi
c010581b:	5d                   	pop    %ebp
c010581c:	c3                   	ret    

c010581d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010581d:	55                   	push   %ebp
c010581e:	89 e5                	mov    %esp,%ebp
c0105820:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105823:	8b 45 08             	mov    0x8(%ebp),%eax
c0105826:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105829:	8b 45 0c             	mov    0xc(%ebp),%eax
c010582c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010582f:	eb 2e                	jmp    c010585f <memcmp+0x42>
        if (*s1 != *s2) {
c0105831:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105834:	0f b6 10             	movzbl (%eax),%edx
c0105837:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010583a:	0f b6 00             	movzbl (%eax),%eax
c010583d:	38 c2                	cmp    %al,%dl
c010583f:	74 18                	je     c0105859 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105841:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105844:	0f b6 00             	movzbl (%eax),%eax
c0105847:	0f b6 d0             	movzbl %al,%edx
c010584a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010584d:	0f b6 00             	movzbl (%eax),%eax
c0105850:	0f b6 c0             	movzbl %al,%eax
c0105853:	29 c2                	sub    %eax,%edx
c0105855:	89 d0                	mov    %edx,%eax
c0105857:	eb 18                	jmp    c0105871 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105859:	ff 45 fc             	incl   -0x4(%ebp)
c010585c:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010585f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105862:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105865:	89 55 10             	mov    %edx,0x10(%ebp)
c0105868:	85 c0                	test   %eax,%eax
c010586a:	75 c5                	jne    c0105831 <memcmp+0x14>
    }
    return 0;
c010586c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105871:	c9                   	leave  
c0105872:	c3                   	ret    

c0105873 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105873:	55                   	push   %ebp
c0105874:	89 e5                	mov    %esp,%ebp
c0105876:	83 ec 58             	sub    $0x58,%esp
c0105879:	8b 45 10             	mov    0x10(%ebp),%eax
c010587c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010587f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105882:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105885:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105888:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010588b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010588e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105891:	8b 45 18             	mov    0x18(%ebp),%eax
c0105894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105897:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010589a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010589d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058a0:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058ad:	74 1c                	je     c01058cb <printnum+0x58>
c01058af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058b2:	ba 00 00 00 00       	mov    $0x0,%edx
c01058b7:	f7 75 e4             	divl   -0x1c(%ebp)
c01058ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c0:	ba 00 00 00 00       	mov    $0x0,%edx
c01058c5:	f7 75 e4             	divl   -0x1c(%ebp)
c01058c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058d1:	f7 75 e4             	divl   -0x1c(%ebp)
c01058d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01058da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01058e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01058e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058e9:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01058ec:	8b 45 18             	mov    0x18(%ebp),%eax
c01058ef:	ba 00 00 00 00       	mov    $0x0,%edx
c01058f4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01058f7:	72 56                	jb     c010594f <printnum+0xdc>
c01058f9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01058fc:	77 05                	ja     c0105903 <printnum+0x90>
c01058fe:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105901:	72 4c                	jb     c010594f <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105903:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105906:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105909:	8b 45 20             	mov    0x20(%ebp),%eax
c010590c:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105910:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105914:	8b 45 18             	mov    0x18(%ebp),%eax
c0105917:	89 44 24 10          	mov    %eax,0x10(%esp)
c010591b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010591e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105921:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105925:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105929:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105930:	8b 45 08             	mov    0x8(%ebp),%eax
c0105933:	89 04 24             	mov    %eax,(%esp)
c0105936:	e8 38 ff ff ff       	call   c0105873 <printnum>
c010593b:	eb 1b                	jmp    c0105958 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010593d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105940:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105944:	8b 45 20             	mov    0x20(%ebp),%eax
c0105947:	89 04 24             	mov    %eax,(%esp)
c010594a:	8b 45 08             	mov    0x8(%ebp),%eax
c010594d:	ff d0                	call   *%eax
        while (-- width > 0)
c010594f:	ff 4d 1c             	decl   0x1c(%ebp)
c0105952:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105956:	7f e5                	jg     c010593d <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105958:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010595b:	05 8c 70 10 c0       	add    $0xc010708c,%eax
c0105960:	0f b6 00             	movzbl (%eax),%eax
c0105963:	0f be c0             	movsbl %al,%eax
c0105966:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105969:	89 54 24 04          	mov    %edx,0x4(%esp)
c010596d:	89 04 24             	mov    %eax,(%esp)
c0105970:	8b 45 08             	mov    0x8(%ebp),%eax
c0105973:	ff d0                	call   *%eax
}
c0105975:	90                   	nop
c0105976:	c9                   	leave  
c0105977:	c3                   	ret    

c0105978 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105978:	55                   	push   %ebp
c0105979:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010597b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010597f:	7e 14                	jle    c0105995 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105981:	8b 45 08             	mov    0x8(%ebp),%eax
c0105984:	8b 00                	mov    (%eax),%eax
c0105986:	8d 48 08             	lea    0x8(%eax),%ecx
c0105989:	8b 55 08             	mov    0x8(%ebp),%edx
c010598c:	89 0a                	mov    %ecx,(%edx)
c010598e:	8b 50 04             	mov    0x4(%eax),%edx
c0105991:	8b 00                	mov    (%eax),%eax
c0105993:	eb 30                	jmp    c01059c5 <getuint+0x4d>
    }
    else if (lflag) {
c0105995:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105999:	74 16                	je     c01059b1 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010599b:	8b 45 08             	mov    0x8(%ebp),%eax
c010599e:	8b 00                	mov    (%eax),%eax
c01059a0:	8d 48 04             	lea    0x4(%eax),%ecx
c01059a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01059a6:	89 0a                	mov    %ecx,(%edx)
c01059a8:	8b 00                	mov    (%eax),%eax
c01059aa:	ba 00 00 00 00       	mov    $0x0,%edx
c01059af:	eb 14                	jmp    c01059c5 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01059b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b4:	8b 00                	mov    (%eax),%eax
c01059b6:	8d 48 04             	lea    0x4(%eax),%ecx
c01059b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01059bc:	89 0a                	mov    %ecx,(%edx)
c01059be:	8b 00                	mov    (%eax),%eax
c01059c0:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01059c5:	5d                   	pop    %ebp
c01059c6:	c3                   	ret    

c01059c7 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01059c7:	55                   	push   %ebp
c01059c8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01059ca:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01059ce:	7e 14                	jle    c01059e4 <getint+0x1d>
        return va_arg(*ap, long long);
c01059d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059d3:	8b 00                	mov    (%eax),%eax
c01059d5:	8d 48 08             	lea    0x8(%eax),%ecx
c01059d8:	8b 55 08             	mov    0x8(%ebp),%edx
c01059db:	89 0a                	mov    %ecx,(%edx)
c01059dd:	8b 50 04             	mov    0x4(%eax),%edx
c01059e0:	8b 00                	mov    (%eax),%eax
c01059e2:	eb 28                	jmp    c0105a0c <getint+0x45>
    }
    else if (lflag) {
c01059e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01059e8:	74 12                	je     c01059fc <getint+0x35>
        return va_arg(*ap, long);
c01059ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ed:	8b 00                	mov    (%eax),%eax
c01059ef:	8d 48 04             	lea    0x4(%eax),%ecx
c01059f2:	8b 55 08             	mov    0x8(%ebp),%edx
c01059f5:	89 0a                	mov    %ecx,(%edx)
c01059f7:	8b 00                	mov    (%eax),%eax
c01059f9:	99                   	cltd   
c01059fa:	eb 10                	jmp    c0105a0c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01059fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ff:	8b 00                	mov    (%eax),%eax
c0105a01:	8d 48 04             	lea    0x4(%eax),%ecx
c0105a04:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a07:	89 0a                	mov    %ecx,(%edx)
c0105a09:	8b 00                	mov    (%eax),%eax
c0105a0b:	99                   	cltd   
    }
}
c0105a0c:	5d                   	pop    %ebp
c0105a0d:	c3                   	ret    

c0105a0e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105a0e:	55                   	push   %ebp
c0105a0f:	89 e5                	mov    %esp,%ebp
c0105a11:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105a14:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a21:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a24:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a32:	89 04 24             	mov    %eax,(%esp)
c0105a35:	e8 03 00 00 00       	call   c0105a3d <vprintfmt>
    va_end(ap);
}
c0105a3a:	90                   	nop
c0105a3b:	c9                   	leave  
c0105a3c:	c3                   	ret    

c0105a3d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105a3d:	55                   	push   %ebp
c0105a3e:	89 e5                	mov    %esp,%ebp
c0105a40:	56                   	push   %esi
c0105a41:	53                   	push   %ebx
c0105a42:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a45:	eb 17                	jmp    c0105a5e <vprintfmt+0x21>
            if (ch == '\0') {
c0105a47:	85 db                	test   %ebx,%ebx
c0105a49:	0f 84 bf 03 00 00    	je     c0105e0e <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a56:	89 1c 24             	mov    %ebx,(%esp)
c0105a59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5c:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a5e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a61:	8d 50 01             	lea    0x1(%eax),%edx
c0105a64:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a67:	0f b6 00             	movzbl (%eax),%eax
c0105a6a:	0f b6 d8             	movzbl %al,%ebx
c0105a6d:	83 fb 25             	cmp    $0x25,%ebx
c0105a70:	75 d5                	jne    c0105a47 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105a72:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105a76:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a80:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105a83:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105a8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105a90:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a93:	8d 50 01             	lea    0x1(%eax),%edx
c0105a96:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a99:	0f b6 00             	movzbl (%eax),%eax
c0105a9c:	0f b6 d8             	movzbl %al,%ebx
c0105a9f:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105aa2:	83 f8 55             	cmp    $0x55,%eax
c0105aa5:	0f 87 37 03 00 00    	ja     c0105de2 <vprintfmt+0x3a5>
c0105aab:	8b 04 85 b0 70 10 c0 	mov    -0x3fef8f50(,%eax,4),%eax
c0105ab2:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105ab4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105ab8:	eb d6                	jmp    c0105a90 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105aba:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105abe:	eb d0                	jmp    c0105a90 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105ac0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105ac7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105aca:	89 d0                	mov    %edx,%eax
c0105acc:	c1 e0 02             	shl    $0x2,%eax
c0105acf:	01 d0                	add    %edx,%eax
c0105ad1:	01 c0                	add    %eax,%eax
c0105ad3:	01 d8                	add    %ebx,%eax
c0105ad5:	83 e8 30             	sub    $0x30,%eax
c0105ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105adb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ade:	0f b6 00             	movzbl (%eax),%eax
c0105ae1:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105ae4:	83 fb 2f             	cmp    $0x2f,%ebx
c0105ae7:	7e 38                	jle    c0105b21 <vprintfmt+0xe4>
c0105ae9:	83 fb 39             	cmp    $0x39,%ebx
c0105aec:	7f 33                	jg     c0105b21 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105aee:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105af1:	eb d4                	jmp    c0105ac7 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105af3:	8b 45 14             	mov    0x14(%ebp),%eax
c0105af6:	8d 50 04             	lea    0x4(%eax),%edx
c0105af9:	89 55 14             	mov    %edx,0x14(%ebp)
c0105afc:	8b 00                	mov    (%eax),%eax
c0105afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105b01:	eb 1f                	jmp    c0105b22 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105b03:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b07:	79 87                	jns    c0105a90 <vprintfmt+0x53>
                width = 0;
c0105b09:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105b10:	e9 7b ff ff ff       	jmp    c0105a90 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105b15:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105b1c:	e9 6f ff ff ff       	jmp    c0105a90 <vprintfmt+0x53>
            goto process_precision;
c0105b21:	90                   	nop

        process_precision:
            if (width < 0)
c0105b22:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b26:	0f 89 64 ff ff ff    	jns    c0105a90 <vprintfmt+0x53>
                width = precision, precision = -1;
c0105b2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b32:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105b39:	e9 52 ff ff ff       	jmp    c0105a90 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105b3e:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105b41:	e9 4a ff ff ff       	jmp    c0105a90 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105b46:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b49:	8d 50 04             	lea    0x4(%eax),%edx
c0105b4c:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b4f:	8b 00                	mov    (%eax),%eax
c0105b51:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b54:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b58:	89 04 24             	mov    %eax,(%esp)
c0105b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b5e:	ff d0                	call   *%eax
            break;
c0105b60:	e9 a4 02 00 00       	jmp    c0105e09 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105b65:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b68:	8d 50 04             	lea    0x4(%eax),%edx
c0105b6b:	89 55 14             	mov    %edx,0x14(%ebp)
c0105b6e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105b70:	85 db                	test   %ebx,%ebx
c0105b72:	79 02                	jns    c0105b76 <vprintfmt+0x139>
                err = -err;
c0105b74:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105b76:	83 fb 06             	cmp    $0x6,%ebx
c0105b79:	7f 0b                	jg     c0105b86 <vprintfmt+0x149>
c0105b7b:	8b 34 9d 70 70 10 c0 	mov    -0x3fef8f90(,%ebx,4),%esi
c0105b82:	85 f6                	test   %esi,%esi
c0105b84:	75 23                	jne    c0105ba9 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105b86:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105b8a:	c7 44 24 08 9d 70 10 	movl   $0xc010709d,0x8(%esp)
c0105b91:	c0 
c0105b92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b99:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9c:	89 04 24             	mov    %eax,(%esp)
c0105b9f:	e8 6a fe ff ff       	call   c0105a0e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105ba4:	e9 60 02 00 00       	jmp    c0105e09 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105ba9:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105bad:	c7 44 24 08 a6 70 10 	movl   $0xc01070a6,0x8(%esp)
c0105bb4:	c0 
c0105bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bbf:	89 04 24             	mov    %eax,(%esp)
c0105bc2:	e8 47 fe ff ff       	call   c0105a0e <printfmt>
            break;
c0105bc7:	e9 3d 02 00 00       	jmp    c0105e09 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105bcc:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bcf:	8d 50 04             	lea    0x4(%eax),%edx
c0105bd2:	89 55 14             	mov    %edx,0x14(%ebp)
c0105bd5:	8b 30                	mov    (%eax),%esi
c0105bd7:	85 f6                	test   %esi,%esi
c0105bd9:	75 05                	jne    c0105be0 <vprintfmt+0x1a3>
                p = "(null)";
c0105bdb:	be a9 70 10 c0       	mov    $0xc01070a9,%esi
            }
            if (width > 0 && padc != '-') {
c0105be0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105be4:	7e 76                	jle    c0105c5c <vprintfmt+0x21f>
c0105be6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105bea:	74 70                	je     c0105c5c <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105bec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bf3:	89 34 24             	mov    %esi,(%esp)
c0105bf6:	e8 f6 f7 ff ff       	call   c01053f1 <strnlen>
c0105bfb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105bfe:	29 c2                	sub    %eax,%edx
c0105c00:	89 d0                	mov    %edx,%eax
c0105c02:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105c05:	eb 16                	jmp    c0105c1d <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105c07:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c0e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c12:	89 04 24             	mov    %eax,(%esp)
c0105c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c18:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105c1a:	ff 4d e8             	decl   -0x18(%ebp)
c0105c1d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c21:	7f e4                	jg     c0105c07 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105c23:	eb 37                	jmp    c0105c5c <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105c25:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105c29:	74 1f                	je     c0105c4a <vprintfmt+0x20d>
c0105c2b:	83 fb 1f             	cmp    $0x1f,%ebx
c0105c2e:	7e 05                	jle    c0105c35 <vprintfmt+0x1f8>
c0105c30:	83 fb 7e             	cmp    $0x7e,%ebx
c0105c33:	7e 15                	jle    c0105c4a <vprintfmt+0x20d>
                    putch('?', putdat);
c0105c35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c3c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105c43:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c46:	ff d0                	call   *%eax
c0105c48:	eb 0f                	jmp    c0105c59 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c51:	89 1c 24             	mov    %ebx,(%esp)
c0105c54:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c57:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105c59:	ff 4d e8             	decl   -0x18(%ebp)
c0105c5c:	89 f0                	mov    %esi,%eax
c0105c5e:	8d 70 01             	lea    0x1(%eax),%esi
c0105c61:	0f b6 00             	movzbl (%eax),%eax
c0105c64:	0f be d8             	movsbl %al,%ebx
c0105c67:	85 db                	test   %ebx,%ebx
c0105c69:	74 27                	je     c0105c92 <vprintfmt+0x255>
c0105c6b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c6f:	78 b4                	js     c0105c25 <vprintfmt+0x1e8>
c0105c71:	ff 4d e4             	decl   -0x1c(%ebp)
c0105c74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105c78:	79 ab                	jns    c0105c25 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105c7a:	eb 16                	jmp    c0105c92 <vprintfmt+0x255>
                putch(' ', putdat);
c0105c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c83:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105c8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8d:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105c8f:	ff 4d e8             	decl   -0x18(%ebp)
c0105c92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105c96:	7f e4                	jg     c0105c7c <vprintfmt+0x23f>
            }
            break;
c0105c98:	e9 6c 01 00 00       	jmp    c0105e09 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ca4:	8d 45 14             	lea    0x14(%ebp),%eax
c0105ca7:	89 04 24             	mov    %eax,(%esp)
c0105caa:	e8 18 fd ff ff       	call   c01059c7 <getint>
c0105caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cb2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105cbb:	85 d2                	test   %edx,%edx
c0105cbd:	79 26                	jns    c0105ce5 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cc6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd0:	ff d0                	call   *%eax
                num = -(long long)num;
c0105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105cd8:	f7 d8                	neg    %eax
c0105cda:	83 d2 00             	adc    $0x0,%edx
c0105cdd:	f7 da                	neg    %edx
c0105cdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ce2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105ce5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105cec:	e9 a8 00 00 00       	jmp    c0105d99 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105cf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cf8:	8d 45 14             	lea    0x14(%ebp),%eax
c0105cfb:	89 04 24             	mov    %eax,(%esp)
c0105cfe:	e8 75 fc ff ff       	call   c0105978 <getuint>
c0105d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d06:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105d09:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105d10:	e9 84 00 00 00       	jmp    c0105d99 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105d15:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d1c:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d1f:	89 04 24             	mov    %eax,(%esp)
c0105d22:	e8 51 fc ff ff       	call   c0105978 <getuint>
c0105d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105d2d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105d34:	eb 63                	jmp    c0105d99 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105d36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d3d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d47:	ff d0                	call   *%eax
            putch('x', putdat);
c0105d49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d50:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105d57:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105d5c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d5f:	8d 50 04             	lea    0x4(%eax),%edx
c0105d62:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d65:	8b 00                	mov    (%eax),%eax
c0105d67:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105d71:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105d78:	eb 1f                	jmp    c0105d99 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d81:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d84:	89 04 24             	mov    %eax,(%esp)
c0105d87:	e8 ec fb ff ff       	call   c0105978 <getuint>
c0105d8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d8f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105d92:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105d99:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105d9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105da0:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105da4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105da7:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105dab:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105db5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105db9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dc7:	89 04 24             	mov    %eax,(%esp)
c0105dca:	e8 a4 fa ff ff       	call   c0105873 <printnum>
            break;
c0105dcf:	eb 38                	jmp    c0105e09 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dd8:	89 1c 24             	mov    %ebx,(%esp)
c0105ddb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dde:	ff d0                	call   *%eax
            break;
c0105de0:	eb 27                	jmp    c0105e09 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105de2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105de5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105de9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105df0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df3:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105df5:	ff 4d 10             	decl   0x10(%ebp)
c0105df8:	eb 03                	jmp    c0105dfd <vprintfmt+0x3c0>
c0105dfa:	ff 4d 10             	decl   0x10(%ebp)
c0105dfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e00:	48                   	dec    %eax
c0105e01:	0f b6 00             	movzbl (%eax),%eax
c0105e04:	3c 25                	cmp    $0x25,%al
c0105e06:	75 f2                	jne    c0105dfa <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105e08:	90                   	nop
    while (1) {
c0105e09:	e9 37 fc ff ff       	jmp    c0105a45 <vprintfmt+0x8>
                return;
c0105e0e:	90                   	nop
        }
    }
}
c0105e0f:	83 c4 40             	add    $0x40,%esp
c0105e12:	5b                   	pop    %ebx
c0105e13:	5e                   	pop    %esi
c0105e14:	5d                   	pop    %ebp
c0105e15:	c3                   	ret    

c0105e16 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105e16:	55                   	push   %ebp
c0105e17:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105e19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e1c:	8b 40 08             	mov    0x8(%eax),%eax
c0105e1f:	8d 50 01             	lea    0x1(%eax),%edx
c0105e22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e25:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105e28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2b:	8b 10                	mov    (%eax),%edx
c0105e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e30:	8b 40 04             	mov    0x4(%eax),%eax
c0105e33:	39 c2                	cmp    %eax,%edx
c0105e35:	73 12                	jae    c0105e49 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105e37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e3a:	8b 00                	mov    (%eax),%eax
c0105e3c:	8d 48 01             	lea    0x1(%eax),%ecx
c0105e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e42:	89 0a                	mov    %ecx,(%edx)
c0105e44:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e47:	88 10                	mov    %dl,(%eax)
    }
}
c0105e49:	90                   	nop
c0105e4a:	5d                   	pop    %ebp
c0105e4b:	c3                   	ret    

c0105e4c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105e4c:	55                   	push   %ebp
c0105e4d:	89 e5                	mov    %esp,%ebp
c0105e4f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105e52:	8d 45 14             	lea    0x14(%ebp),%eax
c0105e55:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e62:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e70:	89 04 24             	mov    %eax,(%esp)
c0105e73:	e8 08 00 00 00       	call   c0105e80 <vsnprintf>
c0105e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e7e:	c9                   	leave  
c0105e7f:	c3                   	ret    

c0105e80 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105e80:	55                   	push   %ebp
c0105e81:	89 e5                	mov    %esp,%ebp
c0105e83:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e89:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e8f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e95:	01 d0                	add    %edx,%eax
c0105e97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105ea1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ea5:	74 0a                	je     c0105eb1 <vsnprintf+0x31>
c0105ea7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ead:	39 c2                	cmp    %eax,%edx
c0105eaf:	76 07                	jbe    c0105eb8 <vsnprintf+0x38>
        return -E_INVAL;
c0105eb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105eb6:	eb 2a                	jmp    c0105ee2 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105eb8:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ebf:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ec6:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ecd:	c7 04 24 16 5e 10 c0 	movl   $0xc0105e16,(%esp)
c0105ed4:	e8 64 fb ff ff       	call   c0105a3d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105edc:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ee2:	c9                   	leave  
c0105ee3:	c3                   	ret    
