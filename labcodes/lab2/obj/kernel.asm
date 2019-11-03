
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

    # unmap va 0 ~ 4M, it's temporary mapping
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
c010003c:	ba 28 bf 11 c0       	mov    $0xc011bf28,%edx
c0100041:	b8 00 b0 11 c0       	mov    $0xc011b000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c010005d:	e8 79 58 00 00       	call   c01058db <memset>

    cons_init();                // init the console
c0100062:	e8 a3 15 00 00       	call   c010160a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 60 10 c0 	movl   $0xc01060e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 60 10 c0 	movl   $0xc01060fc,(%esp)
c010007c:	e8 21 02 00 00       	call   c01002a2 <cprintf>

    print_kerninfo();
c0100081:	e8 c2 08 00 00       	call   c0100948 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8e 00 00 00       	call   c0100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 76 32 00 00       	call   c0103306 <pmm_init>

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
c010015a:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 01 61 10 c0 	movl   $0xc0106101,(%esp)
c010016e:	e8 2f 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 0f 61 10 c0 	movl   $0xc010610f,(%esp)
c010018d:	e8 10 01 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 1d 61 10 c0 	movl   $0xc010611d,(%esp)
c01001ac:	e8 f1 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 2b 61 10 c0 	movl   $0xc010612b,(%esp)
c01001cb:	e8 d2 00 00 00       	call   c01002a2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 39 61 10 c0 	movl   $0xc0106139,(%esp)
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
c010021f:	c7 04 24 48 61 10 c0 	movl   $0xc0106148,(%esp)
c0100226:	e8 77 00 00 00       	call   c01002a2 <cprintf>
    lab1_switch_to_user();
c010022b:	e8 cd ff ff ff       	call   c01001fd <lab1_switch_to_user>
    lab1_print_cur_status();
c0100230:	e8 0a ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100235:	c7 04 24 68 61 10 c0 	movl   $0xc0106168,(%esp)
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
c0100298:	e8 91 59 00 00       	call   c0105c2e <vprintfmt>
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
c0100357:	c7 04 24 87 61 10 c0 	movl   $0xc0106187,(%esp)
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
c0100426:	c7 04 24 8a 61 10 c0 	movl   $0xc010618a,(%esp)
c010042d:	e8 70 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c0100432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100435:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100439:	8b 45 10             	mov    0x10(%ebp),%eax
c010043c:	89 04 24             	mov    %eax,(%esp)
c010043f:	e8 2b fe ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c0100444:	c7 04 24 a6 61 10 c0 	movl   $0xc01061a6,(%esp)
c010044b:	e8 52 fe ff ff       	call   c01002a2 <cprintf>
    
    cprintf("stack trackback:\n");
c0100450:	c7 04 24 a8 61 10 c0 	movl   $0xc01061a8,(%esp)
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
c0100491:	c7 04 24 ba 61 10 c0 	movl   $0xc01061ba,(%esp)
c0100498:	e8 05 fe ff ff       	call   c01002a2 <cprintf>
    vcprintf(fmt, ap);
c010049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a7:	89 04 24             	mov    %eax,(%esp)
c01004aa:	e8 c0 fd ff ff       	call   c010026f <vcprintf>
    cprintf("\n");
c01004af:	c7 04 24 a6 61 10 c0 	movl   $0xc01061a6,(%esp)
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
c010061f:	c7 00 d8 61 10 c0    	movl   $0xc01061d8,(%eax)
    info->eip_line = 0;
c0100625:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100628:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	c7 40 08 d8 61 10 c0 	movl   $0xc01061d8,0x8(%eax)
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
c0100656:	c7 45 f4 e8 73 10 c0 	movl   $0xc01073e8,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065d:	c7 45 f0 b8 27 11 c0 	movl   $0xc01127b8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100664:	c7 45 ec b9 27 11 c0 	movl   $0xc01127b9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066b:	c7 45 e8 e6 52 11 c0 	movl   $0xc01152e6,-0x18(%ebp)

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
c01007c6:	e8 8c 4f 00 00       	call   c0105757 <strfind>
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
c010094e:	c7 04 24 e2 61 10 c0 	movl   $0xc01061e2,(%esp)
c0100955:	e8 48 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010095a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100961:	c0 
c0100962:	c7 04 24 fb 61 10 c0 	movl   $0xc01061fb,(%esp)
c0100969:	e8 34 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096e:	c7 44 24 04 d5 60 10 	movl   $0xc01060d5,0x4(%esp)
c0100975:	c0 
c0100976:	c7 04 24 13 62 10 c0 	movl   $0xc0106213,(%esp)
c010097d:	e8 20 f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100982:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c0100989:	c0 
c010098a:	c7 04 24 2b 62 10 c0 	movl   $0xc010622b,(%esp)
c0100991:	e8 0c f9 ff ff       	call   c01002a2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100996:	c7 44 24 04 28 bf 11 	movl   $0xc011bf28,0x4(%esp)
c010099d:	c0 
c010099e:	c7 04 24 43 62 10 c0 	movl   $0xc0106243,(%esp)
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
c01009d0:	c7 04 24 5c 62 10 c0 	movl   $0xc010625c,(%esp)
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
c0100a05:	c7 04 24 86 62 10 c0 	movl   $0xc0106286,(%esp)
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
c0100a73:	c7 04 24 a2 62 10 c0 	movl   $0xc01062a2,(%esp)
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
c0100ad0:	c7 04 24 b4 62 10 c0 	movl   $0xc01062b4,(%esp)
c0100ad7:	e8 c6 f7 ff ff       	call   c01002a2 <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
c0100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adf:	83 c0 08             	add    $0x8,%eax
c0100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
c0100ae5:	c7 04 24 d2 62 10 c0 	movl   $0xc01062d2,(%esp)
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
c0100b0f:	c7 04 24 d9 62 10 c0 	movl   $0xc01062d9,(%esp)
c0100b16:	e8 87 f7 ff ff       	call   c01002a2 <cprintf>
        for (int j = 0 ;j<4;j++)
c0100b1b:	ff 45 e8             	incl   -0x18(%ebp)
c0100b1e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b22:	7e d6                	jle    c0100afa <print_stackframe+0x67>
        }
        cprintf("\n");
c0100b24:	c7 04 24 e1 62 10 c0 	movl   $0xc01062e1,(%esp)
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
c0100b94:	c7 04 24 64 63 10 c0 	movl   $0xc0106364,(%esp)
c0100b9b:	e8 85 4b 00 00       	call   c0105725 <strchr>
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
c0100bbc:	c7 04 24 69 63 10 c0 	movl   $0xc0106369,(%esp)
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
c0100bfe:	c7 04 24 64 63 10 c0 	movl   $0xc0106364,(%esp)
c0100c05:	e8 1b 4b 00 00       	call   c0105725 <strchr>
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
c0100c6b:	e8 18 4a 00 00       	call   c0105688 <strcmp>
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
c0100cb7:	c7 04 24 87 63 10 c0 	movl   $0xc0106387,(%esp)
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
c0100cd4:	c7 04 24 a0 63 10 c0 	movl   $0xc01063a0,(%esp)
c0100cdb:	e8 c2 f5 ff ff       	call   c01002a2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ce0:	c7 04 24 c8 63 10 c0 	movl   $0xc01063c8,(%esp)
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
c0100cfd:	c7 04 24 ed 63 10 c0 	movl   $0xc01063ed,(%esp)
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
c0100d6b:	c7 04 24 f1 63 10 c0 	movl   $0xc01063f1,(%esp)
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
c0100df6:	c7 04 24 fa 63 10 c0 	movl   $0xc01063fa,(%esp)
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
c0101238:	e8 de 46 00 00       	call   c010591b <memmove>
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
c01015b8:	c7 04 24 15 64 10 c0 	movl   $0xc0106415,(%esp)
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
c0101628:	c7 04 24 21 64 10 c0 	movl   $0xc0106421,(%esp)
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
c01018c5:	c7 04 24 40 64 10 c0 	movl   $0xc0106440,(%esp)
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
c01018e9:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c01018f0:	0f b7 d0             	movzwl %ax,%edx
c01018f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f6:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c01018fd:	c0 
c01018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101901:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c0101908:	c0 08 00 
c010190b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190e:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c0101915:	c0 
c0101916:	80 e2 e0             	and    $0xe0,%dl
c0101919:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101920:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101923:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010192a:	c0 
c010192b:	80 e2 1f             	and    $0x1f,%dl
c010192e:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101938:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010193f:	c0 
c0101940:	80 e2 f0             	and    $0xf0,%dl
c0101943:	80 ca 0e             	or     $0xe,%dl
c0101946:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010194d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101950:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101957:	c0 
c0101958:	80 e2 ef             	and    $0xef,%dl
c010195b:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101962:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101965:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010196c:	c0 
c010196d:	80 e2 9f             	and    $0x9f,%dl
c0101970:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197a:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101981:	c0 
c0101982:	80 ca 80             	or     $0x80,%dl
c0101985:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010198c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010198f:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101996:	c1 e8 10             	shr    $0x10,%eax
c0101999:	0f b7 d0             	movzwl %ax,%edx
c010199c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010199f:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c01019a6:	c0 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
c01019a7:	ff 45 fc             	incl   -0x4(%ebp)
c01019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ad:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019b2:	0f 86 2e ff ff ff    	jbe    c01018e6 <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01019b8:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c01019bd:	0f b7 c0             	movzwl %ax,%eax
c01019c0:	66 a3 48 ba 11 c0    	mov    %ax,0xc011ba48
c01019c6:	66 c7 05 4a ba 11 c0 	movw   $0x8,0xc011ba4a
c01019cd:	08 00 
c01019cf:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c01019d6:	24 e0                	and    $0xe0,%al
c01019d8:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c01019dd:	0f b6 05 4c ba 11 c0 	movzbl 0xc011ba4c,%eax
c01019e4:	24 1f                	and    $0x1f,%al
c01019e6:	a2 4c ba 11 c0       	mov    %al,0xc011ba4c
c01019eb:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c01019f2:	24 f0                	and    $0xf0,%al
c01019f4:	0c 0e                	or     $0xe,%al
c01019f6:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c01019fb:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a02:	24 ef                	and    $0xef,%al
c0101a04:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a09:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a10:	0c 60                	or     $0x60,%al
c0101a12:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a17:	0f b6 05 4d ba 11 c0 	movzbl 0xc011ba4d,%eax
c0101a1e:	0c 80                	or     $0x80,%al
c0101a20:	a2 4d ba 11 c0       	mov    %al,0xc011ba4d
c0101a25:	a1 c4 87 11 c0       	mov    0xc01187c4,%eax
c0101a2a:	c1 e8 10             	shr    $0x10,%eax
c0101a2d:	0f b7 c0             	movzwl %ax,%eax
c0101a30:	66 a3 4e ba 11 c0    	mov    %ax,0xc011ba4e
c0101a36:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
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
c0101a54:	8b 04 85 a0 67 10 c0 	mov    -0x3fef9860(,%eax,4),%eax
c0101a5b:	eb 18                	jmp    c0101a75 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a5d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a61:	7e 0d                	jle    c0101a70 <trapname+0x2a>
c0101a63:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a67:	7f 07                	jg     c0101a70 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a69:	b8 4a 64 10 c0       	mov    $0xc010644a,%eax
c0101a6e:	eb 05                	jmp    c0101a75 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a70:	b8 5d 64 10 c0       	mov    $0xc010645d,%eax
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
c0101a99:	c7 04 24 9e 64 10 c0 	movl   $0xc010649e,(%esp)
c0101aa0:	e8 fd e7 ff ff       	call   c01002a2 <cprintf>
    print_regs(&tf->tf_regs);
c0101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa8:	89 04 24             	mov    %eax,(%esp)
c0101aab:	e8 8f 01 00 00       	call   c0101c3f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101abb:	c7 04 24 af 64 10 c0 	movl   $0xc01064af,(%esp)
c0101ac2:	e8 db e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aca:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ace:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad2:	c7 04 24 c2 64 10 c0 	movl   $0xc01064c2,(%esp)
c0101ad9:	e8 c4 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae1:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae9:	c7 04 24 d5 64 10 c0 	movl   $0xc01064d5,(%esp)
c0101af0:	e8 ad e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101af5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af8:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101afc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b00:	c7 04 24 e8 64 10 c0 	movl   $0xc01064e8,(%esp)
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
c0101b2a:	c7 04 24 fb 64 10 c0 	movl   $0xc01064fb,(%esp)
c0101b31:	e8 6c e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b36:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b39:	8b 40 34             	mov    0x34(%eax),%eax
c0101b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b40:	c7 04 24 0d 65 10 c0 	movl   $0xc010650d,(%esp)
c0101b47:	e8 56 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4f:	8b 40 38             	mov    0x38(%eax),%eax
c0101b52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b56:	c7 04 24 1c 65 10 c0 	movl   $0xc010651c,(%esp)
c0101b5d:	e8 40 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b62:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b65:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b6d:	c7 04 24 2b 65 10 c0 	movl   $0xc010652b,(%esp)
c0101b74:	e8 29 e7 ff ff       	call   c01002a2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7c:	8b 40 40             	mov    0x40(%eax),%eax
c0101b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b83:	c7 04 24 3e 65 10 c0 	movl   $0xc010653e,(%esp)
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
c0101bb1:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101bb8:	85 c0                	test   %eax,%eax
c0101bba:	74 1a                	je     c0101bd6 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bbf:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bca:	c7 04 24 4d 65 10 c0 	movl   $0xc010654d,(%esp)
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
c0101bf4:	c7 04 24 51 65 10 c0 	movl   $0xc0106551,(%esp)
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
c0101c19:	c7 04 24 5a 65 10 c0 	movl   $0xc010655a,(%esp)
c0101c20:	e8 7d e6 ff ff       	call   c01002a2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c28:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c30:	c7 04 24 69 65 10 c0 	movl   $0xc0106569,(%esp)
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
c0101c4e:	c7 04 24 7c 65 10 c0 	movl   $0xc010657c,(%esp)
c0101c55:	e8 48 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5d:	8b 40 04             	mov    0x4(%eax),%eax
c0101c60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c64:	c7 04 24 8b 65 10 c0 	movl   $0xc010658b,(%esp)
c0101c6b:	e8 32 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c73:	8b 40 08             	mov    0x8(%eax),%eax
c0101c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7a:	c7 04 24 9a 65 10 c0 	movl   $0xc010659a,(%esp)
c0101c81:	e8 1c e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c89:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c90:	c7 04 24 a9 65 10 c0 	movl   $0xc01065a9,(%esp)
c0101c97:	e8 06 e6 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9f:	8b 40 10             	mov    0x10(%eax),%eax
c0101ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca6:	c7 04 24 b8 65 10 c0 	movl   $0xc01065b8,(%esp)
c0101cad:	e8 f0 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb5:	8b 40 14             	mov    0x14(%eax),%eax
c0101cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cbc:	c7 04 24 c7 65 10 c0 	movl   $0xc01065c7,(%esp)
c0101cc3:	e8 da e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ccb:	8b 40 18             	mov    0x18(%eax),%eax
c0101cce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd2:	c7 04 24 d6 65 10 c0 	movl   $0xc01065d6,(%esp)
c0101cd9:	e8 c4 e5 ff ff       	call   c01002a2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce8:	c7 04 24 e5 65 10 c0 	movl   $0xc01065e5,(%esp)
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
c0101d43:	a1 0c bf 11 c0       	mov    0xc011bf0c,%eax
c0101d48:	40                   	inc    %eax
c0101d49:	a3 0c bf 11 c0       	mov    %eax,0xc011bf0c
        if(ticks % TICK_NUM == 0 )
c0101d4e:	8b 0d 0c bf 11 c0    	mov    0xc011bf0c,%ecx
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
c0101da1:	c7 04 24 f4 65 10 c0 	movl   $0xc01065f4,(%esp)
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
c0101dca:	c7 04 24 06 66 10 c0 	movl   $0xc0106606,(%esp)
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
c0101f05:	e8 11 3a 00 00       	call   c010591b <memmove>
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
c0101f30:	c7 44 24 08 15 66 10 	movl   $0xc0106615,0x8(%esp)
c0101f37:	c0 
c0101f38:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0101f3f:	00 
c0101f40:	c7 04 24 31 66 10 c0 	movl   $0xc0106631,(%esp)
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
c0102a0d:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
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
c0102a44:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102a49:	39 c2                	cmp    %eax,%edx
c0102a4b:	72 1c                	jb     c0102a69 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102a4d:	c7 44 24 08 f0 67 10 	movl   $0xc01067f0,0x8(%esp)
c0102a54:	c0 
c0102a55:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0102a5c:	00 
c0102a5d:	c7 04 24 0f 68 10 c0 	movl   $0xc010680f,(%esp)
c0102a64:	e8 90 d9 ff ff       	call   c01003f9 <__panic>
    }
    return &pages[PPN(pa)];
c0102a69:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
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
c0102aa2:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102aa7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102aaa:	72 23                	jb     c0102acf <page2kva+0x4a>
c0102aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102ab3:	c7 44 24 08 20 68 10 	movl   $0xc0106820,0x8(%esp)
c0102aba:	c0 
c0102abb:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0102ac2:	00 
c0102ac3:	c7 04 24 0f 68 10 c0 	movl   $0xc010680f,(%esp)
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
c0102ae9:	c7 44 24 08 44 68 10 	movl   $0xc0106844,0x8(%esp)
c0102af0:	c0 
c0102af1:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0102af8:	00 
c0102af9:	c7 04 24 0f 68 10 c0 	movl   $0xc010680f,(%esp)
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

c0102b39 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102b39:	55                   	push   %ebp
c0102b3a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b42:	89 10                	mov    %edx,(%eax)
}
c0102b44:	90                   	nop
c0102b45:	5d                   	pop    %ebp
c0102b46:	c3                   	ret    

c0102b47 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102b47:	55                   	push   %ebp
c0102b48:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102b4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b4d:	8b 00                	mov    (%eax),%eax
c0102b4f:	8d 50 01             	lea    0x1(%eax),%edx
c0102b52:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b55:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b5a:	8b 00                	mov    (%eax),%eax
}
c0102b5c:	5d                   	pop    %ebp
c0102b5d:	c3                   	ret    

c0102b5e <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102b5e:	55                   	push   %ebp
c0102b5f:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b64:	8b 00                	mov    (%eax),%eax
c0102b66:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b6c:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b71:	8b 00                	mov    (%eax),%eax
}
c0102b73:	5d                   	pop    %ebp
c0102b74:	c3                   	ret    

c0102b75 <__intr_save>:
__intr_save(void) {     //TS自旋锁机制
c0102b75:	55                   	push   %ebp
c0102b76:	89 e5                	mov    %esp,%ebp
c0102b78:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102b7b:	9c                   	pushf  
c0102b7c:	58                   	pop    %eax
c0102b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
c0102b83:	25 00 02 00 00       	and    $0x200,%eax
c0102b88:	85 c0                	test   %eax,%eax
c0102b8a:	74 0c                	je     c0102b98 <__intr_save+0x23>
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
c0102b8c:	e8 1f ed ff ff       	call   c01018b0 <intr_disable>
        return 1;
c0102b91:	b8 01 00 00 00       	mov    $0x1,%eax
c0102b96:	eb 05                	jmp    c0102b9d <__intr_save+0x28>
    return 0;       //否则表明中断标志位为0
c0102b98:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102b9d:	c9                   	leave  
c0102b9e:	c3                   	ret    

c0102b9f <__intr_restore>:
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
c0102b9f:	55                   	push   %ebp
c0102ba0:	89 e5                	mov    %esp,%ebp
c0102ba2:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102ba5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102ba9:	74 05                	je     c0102bb0 <__intr_restore+0x11>
        intr_enable();
c0102bab:	e8 f9 ec ff ff       	call   c01018a9 <intr_enable>
}
c0102bb0:	90                   	nop
c0102bb1:	c9                   	leave  
c0102bb2:	c3                   	ret    

c0102bb3 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102bb3:	55                   	push   %ebp
c0102bb4:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bb9:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102bbc:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bc1:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102bc3:	b8 23 00 00 00       	mov    $0x23,%eax
c0102bc8:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102bca:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bcf:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102bd1:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bd6:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102bd8:	b8 10 00 00 00       	mov    $0x10,%eax
c0102bdd:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102bdf:	ea e6 2b 10 c0 08 00 	ljmp   $0x8,$0xc0102be6
}
c0102be6:	90                   	nop
c0102be7:	5d                   	pop    %ebp
c0102be8:	c3                   	ret    

c0102be9 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102be9:	55                   	push   %ebp
c0102bea:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102bec:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bef:	a3 a4 be 11 c0       	mov    %eax,0xc011bea4
}
c0102bf4:	90                   	nop
c0102bf5:	5d                   	pop    %ebp
c0102bf6:	c3                   	ret    

c0102bf7 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102bf7:	55                   	push   %ebp
c0102bf8:	89 e5                	mov    %esp,%ebp
c0102bfa:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102bfd:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0102c02:	89 04 24             	mov    %eax,(%esp)
c0102c05:	e8 df ff ff ff       	call   c0102be9 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102c0a:	66 c7 05 a8 be 11 c0 	movw   $0x10,0xc011bea8
c0102c11:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102c13:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0102c1a:	68 00 
c0102c1c:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102c21:	0f b7 c0             	movzwl %ax,%eax
c0102c24:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0102c2a:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102c2f:	c1 e8 10             	shr    $0x10,%eax
c0102c32:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0102c37:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c3e:	24 f0                	and    $0xf0,%al
c0102c40:	0c 09                	or     $0x9,%al
c0102c42:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c47:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c4e:	24 ef                	and    $0xef,%al
c0102c50:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c55:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c5c:	24 9f                	and    $0x9f,%al
c0102c5e:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c63:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102c6a:	0c 80                	or     $0x80,%al
c0102c6c:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102c71:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102c78:	24 f0                	and    $0xf0,%al
c0102c7a:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102c7f:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102c86:	24 ef                	and    $0xef,%al
c0102c88:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102c8d:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102c94:	24 df                	and    $0xdf,%al
c0102c96:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102c9b:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102ca2:	0c 40                	or     $0x40,%al
c0102ca4:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102ca9:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102cb0:	24 7f                	and    $0x7f,%al
c0102cb2:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102cb7:	b8 a0 be 11 c0       	mov    $0xc011bea0,%eax
c0102cbc:	c1 e8 18             	shr    $0x18,%eax
c0102cbf:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102cc4:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0102ccb:	e8 e3 fe ff ff       	call   c0102bb3 <lgdt>
c0102cd0:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102cd6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102cda:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102cdd:	90                   	nop
c0102cde:	c9                   	leave  
c0102cdf:	c3                   	ret    

c0102ce0 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102ce0:	55                   	push   %ebp
c0102ce1:	89 e5                	mov    %esp,%ebp
c0102ce3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102ce6:	c7 05 10 bf 11 c0 d0 	movl   $0xc01071d0,0xc011bf10
c0102ced:	71 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102cf0:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102cf5:	8b 00                	mov    (%eax),%eax
c0102cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102cfb:	c7 04 24 70 68 10 c0 	movl   $0xc0106870,(%esp)
c0102d02:	e8 9b d5 ff ff       	call   c01002a2 <cprintf>
    pmm_manager->init();
c0102d07:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d0c:	8b 40 04             	mov    0x4(%eax),%eax
c0102d0f:	ff d0                	call   *%eax
}
c0102d11:	90                   	nop
c0102d12:	c9                   	leave  
c0102d13:	c3                   	ret    

c0102d14 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c0102d14:	55                   	push   %ebp
c0102d15:	89 e5                	mov    %esp,%ebp
c0102d17:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102d1a:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d1f:	8b 40 08             	mov    0x8(%eax),%eax
c0102d22:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d25:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d29:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d2c:	89 14 24             	mov    %edx,(%esp)
c0102d2f:	ff d0                	call   *%eax
}
c0102d31:	90                   	nop
c0102d32:	c9                   	leave  
c0102d33:	c3                   	ret    

c0102d34 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
//分配连续的n个pagesize大小的内存空间，问题是为什么对页表的相关函数调用都需要先关闭中断呢？？？？
struct Page *
alloc_pages(size_t n) {
c0102d34:	55                   	push   %ebp
c0102d35:	89 e5                	mov    %esp,%ebp
c0102d37:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag); //先关闭中断，再调用pmm_manager 的alloc_pages()函数进行页分配
c0102d41:	e8 2f fe ff ff       	call   c0102b75 <__intr_save>
c0102d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102d49:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d4e:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d51:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d54:	89 14 24             	mov    %edx,(%esp)
c0102d57:	ff d0                	call   *%eax
c0102d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);//开启中断
c0102d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d5f:	89 04 24             	mov    %eax,(%esp)
c0102d62:	e8 38 fe ff ff       	call   c0102b9f <__intr_restore>
    return page;
c0102d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102d6a:	c9                   	leave  
c0102d6b:	c3                   	ret    

c0102d6c <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//释放n个pagesize大小的内存
void
free_pages(struct Page *base, size_t n) {
c0102d6c:	55                   	push   %ebp
c0102d6d:	89 e5                	mov    %esp,%ebp
c0102d6f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102d72:	e8 fe fd ff ff       	call   c0102b75 <__intr_save>
c0102d77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102d7a:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102d7f:	8b 40 10             	mov    0x10(%eax),%eax
c0102d82:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d85:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102d89:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d8c:	89 14 24             	mov    %edx,(%esp)
c0102d8f:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d94:	89 04 24             	mov    %eax,(%esp)
c0102d97:	e8 03 fe ff ff       	call   c0102b9f <__intr_restore>
}
c0102d9c:	90                   	nop
c0102d9d:	c9                   	leave  
c0102d9e:	c3                   	ret    

c0102d9f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
//获取当前的空闲页数量
size_t
nr_free_pages(void) {
c0102d9f:	55                   	push   %ebp
c0102da0:	89 e5                	mov    %esp,%ebp
c0102da2:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102da5:	e8 cb fd ff ff       	call   c0102b75 <__intr_save>
c0102daa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102dad:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c0102db2:	8b 40 14             	mov    0x14(%eax),%eax
c0102db5:	ff d0                	call   *%eax
c0102db7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbd:	89 04 24             	mov    %eax,(%esp)
c0102dc0:	e8 da fd ff ff       	call   c0102b9f <__intr_restore>
    return ret;
c0102dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102dc8:	c9                   	leave  
c0102dc9:	c3                   	ret    

c0102dca <page_init>:

/* pmm_init - initialize the physical memory management */
// 初始化pmm
static void
page_init(void) {
c0102dca:	55                   	push   %ebp
c0102dcb:	89 e5                	mov    %esp,%ebp
c0102dcd:	57                   	push   %edi
c0102dce:	56                   	push   %esi
c0102dcf:	53                   	push   %ebx
c0102dd0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102dd6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102ddd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102de4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102deb:	c7 04 24 87 68 10 c0 	movl   $0xc0106887,(%esp)
c0102df2:	e8 ab d4 ff ff       	call   c01002a2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102df7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102dfe:	e9 22 01 00 00       	jmp    c0102f25 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e03:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e06:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e09:	89 d0                	mov    %edx,%eax
c0102e0b:	c1 e0 02             	shl    $0x2,%eax
c0102e0e:	01 d0                	add    %edx,%eax
c0102e10:	c1 e0 02             	shl    $0x2,%eax
c0102e13:	01 c8                	add    %ecx,%eax
c0102e15:	8b 50 08             	mov    0x8(%eax),%edx
c0102e18:	8b 40 04             	mov    0x4(%eax),%eax
c0102e1b:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102e1e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102e21:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e24:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e27:	89 d0                	mov    %edx,%eax
c0102e29:	c1 e0 02             	shl    $0x2,%eax
c0102e2c:	01 d0                	add    %edx,%eax
c0102e2e:	c1 e0 02             	shl    $0x2,%eax
c0102e31:	01 c8                	add    %ecx,%eax
c0102e33:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e36:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e39:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e3c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e3f:	01 c8                	add    %ecx,%eax
c0102e41:	11 da                	adc    %ebx,%edx
c0102e43:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e46:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102e49:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e4f:	89 d0                	mov    %edx,%eax
c0102e51:	c1 e0 02             	shl    $0x2,%eax
c0102e54:	01 d0                	add    %edx,%eax
c0102e56:	c1 e0 02             	shl    $0x2,%eax
c0102e59:	01 c8                	add    %ecx,%eax
c0102e5b:	83 c0 14             	add    $0x14,%eax
c0102e5e:	8b 00                	mov    (%eax),%eax
c0102e60:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102e63:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e66:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102e69:	83 c0 ff             	add    $0xffffffff,%eax
c0102e6c:	83 d2 ff             	adc    $0xffffffff,%edx
c0102e6f:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102e75:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102e7b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e81:	89 d0                	mov    %edx,%eax
c0102e83:	c1 e0 02             	shl    $0x2,%eax
c0102e86:	01 d0                	add    %edx,%eax
c0102e88:	c1 e0 02             	shl    $0x2,%eax
c0102e8b:	01 c8                	add    %ecx,%eax
c0102e8d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102e90:	8b 58 10             	mov    0x10(%eax),%ebx
c0102e93:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102e96:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102e9a:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102ea0:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102ea6:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102eaa:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102eae:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102eb1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102eb8:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102ebc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102ec0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102ec4:	c7 04 24 94 68 10 c0 	movl   $0xc0106894,(%esp)
c0102ecb:	e8 d2 d3 ff ff       	call   c01002a2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {      //用户区内存的第一段，获取交接处的地址
c0102ed0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ed3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ed6:	89 d0                	mov    %edx,%eax
c0102ed8:	c1 e0 02             	shl    $0x2,%eax
c0102edb:	01 d0                	add    %edx,%eax
c0102edd:	c1 e0 02             	shl    $0x2,%eax
c0102ee0:	01 c8                	add    %ecx,%eax
c0102ee2:	83 c0 14             	add    $0x14,%eax
c0102ee5:	8b 00                	mov    (%eax),%eax
c0102ee7:	83 f8 01             	cmp    $0x1,%eax
c0102eea:	75 36                	jne    c0102f22 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102eef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102ef2:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102ef5:	77 2b                	ja     c0102f22 <page_init+0x158>
c0102ef7:	3b 55 9c             	cmp    -0x64(%ebp),%edx
c0102efa:	72 05                	jb     c0102f01 <page_init+0x137>
c0102efc:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102eff:	73 21                	jae    c0102f22 <page_init+0x158>
c0102f01:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102f05:	77 1b                	ja     c0102f22 <page_init+0x158>
c0102f07:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0102f0b:	72 09                	jb     c0102f16 <page_init+0x14c>
c0102f0d:	81 7d a0 ff ff ff 37 	cmpl   $0x37ffffff,-0x60(%ebp)
c0102f14:	77 0c                	ja     c0102f22 <page_init+0x158>
                maxpa = end;
c0102f16:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f19:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102f1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102f1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102f22:	ff 45 dc             	incl   -0x24(%ebp)
c0102f25:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102f28:	8b 00                	mov    (%eax),%eax
c0102f2a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102f2d:	0f 8c d0 fe ff ff    	jl     c0102e03 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {   //获得内核区边界
c0102f33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f37:	72 1d                	jb     c0102f56 <page_init+0x18c>
c0102f39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102f3d:	77 09                	ja     c0102f48 <page_init+0x17e>
c0102f3f:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102f46:	76 0e                	jbe    c0102f56 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102f48:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102f4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f5c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102f60:	c1 ea 0c             	shr    $0xc,%edx
c0102f63:	89 c1                	mov    %eax,%ecx
c0102f65:	89 d3                	mov    %edx,%ebx
c0102f67:	89 c8                	mov    %ecx,%eax
c0102f69:	a3 80 be 11 c0       	mov    %eax,0xc011be80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102f6e:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102f75:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
c0102f7a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102f7d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102f80:	01 d0                	add    %edx,%eax
c0102f82:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102f85:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102f88:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f8d:	f7 75 c0             	divl   -0x40(%ebp)
c0102f90:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102f93:	29 d0                	sub    %edx,%eax
c0102f95:	a3 18 bf 11 c0       	mov    %eax,0xc011bf18
    //为所有的页设置保留位为1，即为内核保留的页空间
    for (i = 0; i < npage; i ++) {
c0102f9a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102fa1:	eb 2e                	jmp    c0102fd1 <page_init+0x207>
        SetPageReserved(pages + i);
c0102fa3:	8b 0d 18 bf 11 c0    	mov    0xc011bf18,%ecx
c0102fa9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fac:	89 d0                	mov    %edx,%eax
c0102fae:	c1 e0 02             	shl    $0x2,%eax
c0102fb1:	01 d0                	add    %edx,%eax
c0102fb3:	c1 e0 02             	shl    $0x2,%eax
c0102fb6:	01 c8                	add    %ecx,%eax
c0102fb8:	83 c0 04             	add    $0x4,%eax
c0102fbb:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0102fc2:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fc5:	8b 45 90             	mov    -0x70(%ebp),%eax
c0102fc8:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0102fcb:	0f ab 10             	bts    %edx,(%eax)
    for (i = 0; i < npage; i ++) {
c0102fce:	ff 45 dc             	incl   -0x24(%ebp)
c0102fd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fd4:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0102fd9:	39 c2                	cmp    %eax,%edx
c0102fdb:	72 c6                	jb     c0102fa3 <page_init+0x1d9>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102fdd:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0102fe3:	89 d0                	mov    %edx,%eax
c0102fe5:	c1 e0 02             	shl    $0x2,%eax
c0102fe8:	01 d0                	add    %edx,%eax
c0102fea:	c1 e0 02             	shl    $0x2,%eax
c0102fed:	89 c2                	mov    %eax,%edx
c0102fef:	a1 18 bf 11 c0       	mov    0xc011bf18,%eax
c0102ff4:	01 d0                	add    %edx,%eax
c0102ff6:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102ff9:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103000:	77 23                	ja     c0103025 <page_init+0x25b>
c0103002:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103005:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103009:	c7 44 24 08 c4 68 10 	movl   $0xc01068c4,0x8(%esp)
c0103010:	c0 
c0103011:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103018:	00 
c0103019:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103020:	e8 d4 d3 ff ff       	call   c01003f9 <__panic>
c0103025:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103028:	05 00 00 00 40       	add    $0x40000000,%eax
c010302d:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103030:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103037:	e9 69 01 00 00       	jmp    c01031a5 <page_init+0x3db>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010303c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010303f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103042:	89 d0                	mov    %edx,%eax
c0103044:	c1 e0 02             	shl    $0x2,%eax
c0103047:	01 d0                	add    %edx,%eax
c0103049:	c1 e0 02             	shl    $0x2,%eax
c010304c:	01 c8                	add    %ecx,%eax
c010304e:	8b 50 08             	mov    0x8(%eax),%edx
c0103051:	8b 40 04             	mov    0x4(%eax),%eax
c0103054:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103057:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010305a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010305d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103060:	89 d0                	mov    %edx,%eax
c0103062:	c1 e0 02             	shl    $0x2,%eax
c0103065:	01 d0                	add    %edx,%eax
c0103067:	c1 e0 02             	shl    $0x2,%eax
c010306a:	01 c8                	add    %ecx,%eax
c010306c:	8b 48 0c             	mov    0xc(%eax),%ecx
c010306f:	8b 58 10             	mov    0x10(%eax),%ebx
c0103072:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103075:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103078:	01 c8                	add    %ecx,%eax
c010307a:	11 da                	adc    %ebx,%edx
c010307c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010307f:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103082:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103085:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103088:	89 d0                	mov    %edx,%eax
c010308a:	c1 e0 02             	shl    $0x2,%eax
c010308d:	01 d0                	add    %edx,%eax
c010308f:	c1 e0 02             	shl    $0x2,%eax
c0103092:	01 c8                	add    %ecx,%eax
c0103094:	83 c0 14             	add    $0x14,%eax
c0103097:	8b 00                	mov    (%eax),%eax
c0103099:	83 f8 01             	cmp    $0x1,%eax
c010309c:	0f 85 00 01 00 00    	jne    c01031a2 <page_init+0x3d8>
            if (begin < freemem) {
c01030a2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01030a5:	ba 00 00 00 00       	mov    $0x0,%edx
c01030aa:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01030ad:	77 17                	ja     c01030c6 <page_init+0x2fc>
c01030af:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c01030b2:	72 05                	jb     c01030b9 <page_init+0x2ef>
c01030b4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01030b7:	73 0d                	jae    c01030c6 <page_init+0x2fc>
                begin = freemem;
c01030b9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01030bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01030c6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030ca:	72 1d                	jb     c01030e9 <page_init+0x31f>
c01030cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01030d0:	77 09                	ja     c01030db <page_init+0x311>
c01030d2:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01030d9:	76 0e                	jbe    c01030e9 <page_init+0x31f>
                end = KMEMSIZE;
c01030db:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01030e2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01030e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030ef:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030f2:	0f 87 aa 00 00 00    	ja     c01031a2 <page_init+0x3d8>
c01030f8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01030fb:	72 09                	jb     c0103106 <page_init+0x33c>
c01030fd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103100:	0f 83 9c 00 00 00    	jae    c01031a2 <page_init+0x3d8>
                begin = ROUNDUP(begin, PGSIZE);
c0103106:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010310d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103110:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103113:	01 d0                	add    %edx,%eax
c0103115:	48                   	dec    %eax
c0103116:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103119:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010311c:	ba 00 00 00 00       	mov    $0x0,%edx
c0103121:	f7 75 b0             	divl   -0x50(%ebp)
c0103124:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103127:	29 d0                	sub    %edx,%eax
c0103129:	ba 00 00 00 00       	mov    $0x0,%edx
c010312e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103131:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103134:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103137:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010313a:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010313d:	ba 00 00 00 00       	mov    $0x0,%edx
c0103142:	89 c3                	mov    %eax,%ebx
c0103144:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c010314a:	89 de                	mov    %ebx,%esi
c010314c:	89 d0                	mov    %edx,%eax
c010314e:	83 e0 00             	and    $0x0,%eax
c0103151:	89 c7                	mov    %eax,%edi
c0103153:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103156:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103159:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010315c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010315f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103162:	77 3e                	ja     c01031a2 <page_init+0x3d8>
c0103164:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103167:	72 05                	jb     c010316e <page_init+0x3a4>
c0103169:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010316c:	73 34                	jae    c01031a2 <page_init+0x3d8>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010316e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103171:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103174:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103177:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010317a:	89 c1                	mov    %eax,%ecx
c010317c:	89 d3                	mov    %edx,%ebx
c010317e:	89 c8                	mov    %ecx,%eax
c0103180:	89 da                	mov    %ebx,%edx
c0103182:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103186:	c1 ea 0c             	shr    $0xc,%edx
c0103189:	89 c3                	mov    %eax,%ebx
c010318b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010318e:	89 04 24             	mov    %eax,(%esp)
c0103191:	e8 a0 f8 ff ff       	call   c0102a36 <pa2page>
c0103196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010319a:	89 04 24             	mov    %eax,(%esp)
c010319d:	e8 72 fb ff ff       	call   c0102d14 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01031a2:	ff 45 dc             	incl   -0x24(%ebp)
c01031a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01031a8:	8b 00                	mov    (%eax),%eax
c01031aa:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01031ad:	0f 8c 89 fe ff ff    	jl     c010303c <page_init+0x272>
                }
            }
        }
    }
}
c01031b3:	90                   	nop
c01031b4:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01031ba:	5b                   	pop    %ebx
c01031bb:	5e                   	pop    %esi
c01031bc:	5f                   	pop    %edi
c01031bd:	5d                   	pop    %ebp
c01031be:	c3                   	ret    

c01031bf <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01031bf:	55                   	push   %ebp
c01031c0:	89 e5                	mov    %esp,%ebp
c01031c2:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01031c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031c8:	33 45 14             	xor    0x14(%ebp),%eax
c01031cb:	25 ff 0f 00 00       	and    $0xfff,%eax
c01031d0:	85 c0                	test   %eax,%eax
c01031d2:	74 24                	je     c01031f8 <boot_map_segment+0x39>
c01031d4:	c7 44 24 0c f6 68 10 	movl   $0xc01068f6,0xc(%esp)
c01031db:	c0 
c01031dc:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01031e3:	c0 
c01031e4:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c01031eb:	00 
c01031ec:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01031f3:	e8 01 d2 ff ff       	call   c01003f9 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01031f8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01031ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103202:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103207:	89 c2                	mov    %eax,%edx
c0103209:	8b 45 10             	mov    0x10(%ebp),%eax
c010320c:	01 c2                	add    %eax,%edx
c010320e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103211:	01 d0                	add    %edx,%eax
c0103213:	48                   	dec    %eax
c0103214:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103217:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010321a:	ba 00 00 00 00       	mov    $0x0,%edx
c010321f:	f7 75 f0             	divl   -0x10(%ebp)
c0103222:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103225:	29 d0                	sub    %edx,%eax
c0103227:	c1 e8 0c             	shr    $0xc,%eax
c010322a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010322d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103230:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103233:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103236:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010323b:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010323e:	8b 45 14             	mov    0x14(%ebp),%eax
c0103241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103247:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010324c:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010324f:	eb 68                	jmp    c01032b9 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103251:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103258:	00 
c0103259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010325c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103260:	8b 45 08             	mov    0x8(%ebp),%eax
c0103263:	89 04 24             	mov    %eax,(%esp)
c0103266:	e8 81 01 00 00       	call   c01033ec <get_pte>
c010326b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010326e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103272:	75 24                	jne    c0103298 <boot_map_segment+0xd9>
c0103274:	c7 44 24 0c 22 69 10 	movl   $0xc0106922,0xc(%esp)
c010327b:	c0 
c010327c:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103283:	c0 
c0103284:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010328b:	00 
c010328c:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103293:	e8 61 d1 ff ff       	call   c01003f9 <__panic>
        *ptep = pa | PTE_P | perm;
c0103298:	8b 45 14             	mov    0x14(%ebp),%eax
c010329b:	0b 45 18             	or     0x18(%ebp),%eax
c010329e:	83 c8 01             	or     $0x1,%eax
c01032a1:	89 c2                	mov    %eax,%edx
c01032a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01032a6:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01032a8:	ff 4d f4             	decl   -0xc(%ebp)
c01032ab:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01032b2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01032b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032bd:	75 92                	jne    c0103251 <boot_map_segment+0x92>
    }
}
c01032bf:	90                   	nop
c01032c0:	c9                   	leave  
c01032c1:	c3                   	ret    

c01032c2 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01032c2:	55                   	push   %ebp
c01032c3:	89 e5                	mov    %esp,%ebp
c01032c5:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01032c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032cf:	e8 60 fa ff ff       	call   c0102d34 <alloc_pages>
c01032d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01032d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032db:	75 1c                	jne    c01032f9 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01032dd:	c7 44 24 08 2f 69 10 	movl   $0xc010692f,0x8(%esp)
c01032e4:	c0 
c01032e5:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01032ec:	00 
c01032ed:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01032f4:	e8 00 d1 ff ff       	call   c01003f9 <__panic>
    }
    return page2kva(p);
c01032f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032fc:	89 04 24             	mov    %eax,(%esp)
c01032ff:	e8 81 f7 ff ff       	call   c0102a85 <page2kva>
}
c0103304:	c9                   	leave  
c0103305:	c3                   	ret    

c0103306 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103306:	55                   	push   %ebp
c0103307:	89 e5                	mov    %esp,%ebp
c0103309:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010330c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103311:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103314:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010331b:	77 23                	ja     c0103340 <pmm_init+0x3a>
c010331d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103320:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103324:	c7 44 24 08 c4 68 10 	movl   $0xc01068c4,0x8(%esp)
c010332b:	c0 
c010332c:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103333:	00 
c0103334:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010333b:	e8 b9 d0 ff ff       	call   c01003f9 <__panic>
c0103340:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103343:	05 00 00 00 40       	add    $0x40000000,%eax
c0103348:	a3 14 bf 11 c0       	mov    %eax,0xc011bf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010334d:	e8 8e f9 ff ff       	call   c0102ce0 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103352:	e8 73 fa ff ff       	call   c0102dca <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103357:	e8 e8 03 00 00       	call   c0103744 <check_alloc_page>

    check_pgdir();
c010335c:	e8 02 04 00 00       	call   c0103763 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103361:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103366:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103369:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103370:	77 23                	ja     c0103395 <pmm_init+0x8f>
c0103372:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103375:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103379:	c7 44 24 08 c4 68 10 	movl   $0xc01068c4,0x8(%esp)
c0103380:	c0 
c0103381:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103388:	00 
c0103389:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103390:	e8 64 d0 ff ff       	call   c01003f9 <__panic>
c0103395:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103398:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010339e:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01033a3:	05 ac 0f 00 00       	add    $0xfac,%eax
c01033a8:	83 ca 03             	or     $0x3,%edx
c01033ab:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01033ad:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01033b2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01033b9:	00 
c01033ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01033c1:	00 
c01033c2:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01033c9:	38 
c01033ca:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01033d1:	c0 
c01033d2:	89 04 24             	mov    %eax,(%esp)
c01033d5:	e8 e5 fd ff ff       	call   c01031bf <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01033da:	e8 18 f8 ff ff       	call   c0102bf7 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01033df:	e8 1b 0a 00 00       	call   c0103dff <check_boot_pgdir>

    print_pgdir();
c01033e4:	e8 94 0e 00 00       	call   c010427d <print_pgdir>

}
c01033e9:	90                   	nop
c01033ea:	c9                   	leave  
c01033eb:	c3                   	ret    

c01033ec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01033ec:	55                   	push   %ebp
c01033ed:	89 e5                	mov    %esp,%ebp
c01033ef:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = &pgdir[PDX(la)];   // (1) find page directory entry   通过参数中的pgdir加上页表目录偏移量（数组方式）获取页表目录地址
c01033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033f5:	c1 e8 16             	shr    $0x16,%eax
c01033f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01033ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103402:	01 d0                	add    %edx,%eax
c0103404:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep&PTE_P)) {              // (2) check if entry is not present
c0103407:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010340a:	8b 00                	mov    (%eax),%eax
c010340c:	83 e0 01             	and    $0x1,%eax
c010340f:	85 c0                	test   %eax,%eax
c0103411:	0f 85 b9 00 00 00    	jne    c01034d0 <get_pte+0xe4>
    struct Page*page;
    if(!create)  return NULL;                // (3) check if creating is needed, then alloc page for page table 不需要分配，直接返回NULL
c0103417:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010341b:	75 0a                	jne    c0103427 <get_pte+0x3b>
c010341d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103422:	e9 06 01 00 00       	jmp    c010352d <get_pte+0x141>
    page = alloc_page();
c0103427:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010342e:	e8 01 f9 ff ff       	call   c0102d34 <alloc_pages>
c0103433:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(page==NULL)   return NULL; //没有找到能够分配的页
c0103436:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010343a:	75 0a                	jne    c0103446 <get_pte+0x5a>
c010343c:	b8 00 00 00 00       	mov    $0x0,%eax
c0103441:	e9 e7 00 00 00       	jmp    c010352d <get_pte+0x141>
                                                          // CAUTION: this page is used for page table, not for common data page
    set_page_ref(page,1);     // (4) set page reference
c0103446:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010344d:	00 
c010344e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103451:	89 04 24             	mov    %eax,(%esp)
c0103454:	e8 e0 f6 ff ff       	call   c0102b39 <set_page_ref>
    uintptr_t pa =page2pa(page); // (5) get linear address of page
c0103459:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010345c:	89 04 24             	mov    %eax,(%esp)
c010345f:	e8 bc f5 ff ff       	call   c0102a20 <page2pa>
c0103464:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memset(KADDR(pa),0,PGSIZE);             // (6) clear page content using memset
c0103467:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010346a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010346d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103470:	c1 e8 0c             	shr    $0xc,%eax
c0103473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103476:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010347b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010347e:	72 23                	jb     c01034a3 <get_pte+0xb7>
c0103480:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103483:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103487:	c7 44 24 08 20 68 10 	movl   $0xc0106820,0x8(%esp)
c010348e:	c0 
c010348f:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c0103496:	00 
c0103497:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010349e:	e8 56 cf ff ff       	call   c01003f9 <__panic>
c01034a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034a6:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01034ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01034b2:	00 
c01034b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01034ba:	00 
c01034bb:	89 04 24             	mov    %eax,(%esp)
c01034be:	e8 18 24 00 00       	call   c01058db <memset>
    *pdep =pa|PTE_W|PTE_P|PTE_U;                      // (7) set page directory entry's permission  设置和物理地址，可写，用户可访问，可用位
c01034c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034c6:	83 c8 07             	or     $0x7,%eax
c01034c9:	89 c2                	mov    %eax,%edx
c01034cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034ce:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t*)KADDR(PDE_ADDR(*pdep)))[PTX(la)];          // (8) return page table entry  拼接页表项、页表目录、表内偏移，得到物理地址之后转为虚拟地址返回
c01034d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034d3:	8b 00                	mov    (%eax),%eax
c01034d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01034da:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01034dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034e0:	c1 e8 0c             	shr    $0xc,%eax
c01034e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01034e6:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c01034eb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01034ee:	72 23                	jb     c0103513 <get_pte+0x127>
c01034f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01034f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034f7:	c7 44 24 08 20 68 10 	movl   $0xc0106820,0x8(%esp)
c01034fe:	c0 
c01034ff:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0103506:	00 
c0103507:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010350e:	e8 e6 ce ff ff       	call   c01003f9 <__panic>
c0103513:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103516:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010351b:	89 c2                	mov    %eax,%edx
c010351d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103520:	c1 e8 0c             	shr    $0xc,%eax
c0103523:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103528:	c1 e0 02             	shl    $0x2,%eax
c010352b:	01 d0                	add    %edx,%eax
#endif
}
c010352d:	c9                   	leave  
c010352e:	c3                   	ret    

c010352f <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010352f:	55                   	push   %ebp
c0103530:	89 e5                	mov    %esp,%ebp
c0103532:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010353c:	00 
c010353d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103544:	8b 45 08             	mov    0x8(%ebp),%eax
c0103547:	89 04 24             	mov    %eax,(%esp)
c010354a:	e8 9d fe ff ff       	call   c01033ec <get_pte>
c010354f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103552:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103556:	74 08                	je     c0103560 <get_page+0x31>
        *ptep_store = ptep;
c0103558:	8b 45 10             	mov    0x10(%ebp),%eax
c010355b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010355e:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103560:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103564:	74 1b                	je     c0103581 <get_page+0x52>
c0103566:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103569:	8b 00                	mov    (%eax),%eax
c010356b:	83 e0 01             	and    $0x1,%eax
c010356e:	85 c0                	test   %eax,%eax
c0103570:	74 0f                	je     c0103581 <get_page+0x52>
        return pte2page(*ptep);
c0103572:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103575:	8b 00                	mov    (%eax),%eax
c0103577:	89 04 24             	mov    %eax,(%esp)
c010357a:	e8 5a f5 ff ff       	call   c0102ad9 <pte2page>
c010357f:	eb 05                	jmp    c0103586 <get_page+0x57>
    }
    return NULL;
c0103581:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103586:	c9                   	leave  
c0103587:	c3                   	ret    

c0103588 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103588:	55                   	push   %ebp
c0103589:	89 e5                	mov    %esp,%ebp
c010358b:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep&PTE_P) {                      //(1) check if this page table entry is present   ?
c010358e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103591:	8b 00                	mov    (%eax),%eax
c0103593:	83 e0 01             	and    $0x1,%eax
c0103596:	85 c0                	test   %eax,%eax
c0103598:	74 4d                	je     c01035e7 <page_remove_pte+0x5f>
        struct Page *page =pte2page(*ptep); //(2) find corresponding page to pte
c010359a:	8b 45 10             	mov    0x10(%ebp),%eax
c010359d:	8b 00                	mov    (%eax),%eax
c010359f:	89 04 24             	mov    %eax,(%esp)
c01035a2:	e8 32 f5 ff ff       	call   c0102ad9 <pte2page>
c01035a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0){                          //(3) decrease page reference
c01035aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ad:	89 04 24             	mov    %eax,(%esp)
c01035b0:	e8 a9 f5 ff ff       	call   c0102b5e <page_ref_dec>
c01035b5:	85 c0                	test   %eax,%eax
c01035b7:	75 13                	jne    c01035cc <page_remove_pte+0x44>
            free_page(page);  //(4) and free this page when page reference reachs 0
c01035b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01035c0:	00 
c01035c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035c4:	89 04 24             	mov    %eax,(%esp)
c01035c7:	e8 a0 f7 ff ff       	call   c0102d6c <free_pages>
        }
        *ptep = 0;                          //(5) clear second page table entry
c01035cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01035cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,la);                          //(6) flush tlb
c01035d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01035df:	89 04 24             	mov    %eax,(%esp)
c01035e2:	e8 01 01 00 00       	call   c01036e8 <tlb_invalidate>
    }
#endif
}
c01035e7:	90                   	nop
c01035e8:	c9                   	leave  
c01035e9:	c3                   	ret    

c01035ea <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01035ea:	55                   	push   %ebp
c01035eb:	89 e5                	mov    %esp,%ebp
c01035ed:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01035f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035f7:	00 
c01035f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103602:	89 04 24             	mov    %eax,(%esp)
c0103605:	e8 e2 fd ff ff       	call   c01033ec <get_pte>
c010360a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010360d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103611:	74 19                	je     c010362c <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103613:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103616:	89 44 24 08          	mov    %eax,0x8(%esp)
c010361a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010361d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103621:	8b 45 08             	mov    0x8(%ebp),%eax
c0103624:	89 04 24             	mov    %eax,(%esp)
c0103627:	e8 5c ff ff ff       	call   c0103588 <page_remove_pte>
    }
}
c010362c:	90                   	nop
c010362d:	c9                   	leave  
c010362e:	c3                   	ret    

c010362f <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010362f:	55                   	push   %ebp
c0103630:	89 e5                	mov    %esp,%ebp
c0103632:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103635:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010363c:	00 
c010363d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103640:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103644:	8b 45 08             	mov    0x8(%ebp),%eax
c0103647:	89 04 24             	mov    %eax,(%esp)
c010364a:	e8 9d fd ff ff       	call   c01033ec <get_pte>
c010364f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103652:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103656:	75 0a                	jne    c0103662 <page_insert+0x33>
        return -E_NO_MEM;
c0103658:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010365d:	e9 84 00 00 00       	jmp    c01036e6 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103662:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103665:	89 04 24             	mov    %eax,(%esp)
c0103668:	e8 da f4 ff ff       	call   c0102b47 <page_ref_inc>
    if (*ptep & PTE_P) {
c010366d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103670:	8b 00                	mov    (%eax),%eax
c0103672:	83 e0 01             	and    $0x1,%eax
c0103675:	85 c0                	test   %eax,%eax
c0103677:	74 3e                	je     c01036b7 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0103679:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010367c:	8b 00                	mov    (%eax),%eax
c010367e:	89 04 24             	mov    %eax,(%esp)
c0103681:	e8 53 f4 ff ff       	call   c0102ad9 <pte2page>
c0103686:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103689:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010368c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010368f:	75 0d                	jne    c010369e <page_insert+0x6f>
            page_ref_dec(page);
c0103691:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103694:	89 04 24             	mov    %eax,(%esp)
c0103697:	e8 c2 f4 ff ff       	call   c0102b5e <page_ref_dec>
c010369c:	eb 19                	jmp    c01036b7 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01036a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01036a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01036af:	89 04 24             	mov    %eax,(%esp)
c01036b2:	e8 d1 fe ff ff       	call   c0103588 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01036b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036ba:	89 04 24             	mov    %eax,(%esp)
c01036bd:	e8 5e f3 ff ff       	call   c0102a20 <page2pa>
c01036c2:	0b 45 14             	or     0x14(%ebp),%eax
c01036c5:	83 c8 01             	or     $0x1,%eax
c01036c8:	89 c2                	mov    %eax,%edx
c01036ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036cd:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01036cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01036d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d9:	89 04 24             	mov    %eax,(%esp)
c01036dc:	e8 07 00 00 00       	call   c01036e8 <tlb_invalidate>
    return 0;
c01036e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01036e6:	c9                   	leave  
c01036e7:	c3                   	ret    

c01036e8 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01036e8:	55                   	push   %ebp
c01036e9:	89 e5                	mov    %esp,%ebp
c01036eb:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01036ee:	0f 20 d8             	mov    %cr3,%eax
c01036f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01036f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01036f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01036fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036fd:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103704:	77 23                	ja     c0103729 <tlb_invalidate+0x41>
c0103706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103709:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010370d:	c7 44 24 08 c4 68 10 	movl   $0xc01068c4,0x8(%esp)
c0103714:	c0 
c0103715:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
c010371c:	00 
c010371d:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103724:	e8 d0 cc ff ff       	call   c01003f9 <__panic>
c0103729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010372c:	05 00 00 00 40       	add    $0x40000000,%eax
c0103731:	39 d0                	cmp    %edx,%eax
c0103733:	75 0c                	jne    c0103741 <tlb_invalidate+0x59>
        invlpg((void *)la);
c0103735:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103738:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010373b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010373e:	0f 01 38             	invlpg (%eax)
    }
}
c0103741:	90                   	nop
c0103742:	c9                   	leave  
c0103743:	c3                   	ret    

c0103744 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103744:	55                   	push   %ebp
c0103745:	89 e5                	mov    %esp,%ebp
c0103747:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010374a:	a1 10 bf 11 c0       	mov    0xc011bf10,%eax
c010374f:	8b 40 18             	mov    0x18(%eax),%eax
c0103752:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103754:	c7 04 24 48 69 10 c0 	movl   $0xc0106948,(%esp)
c010375b:	e8 42 cb ff ff       	call   c01002a2 <cprintf>
}
c0103760:	90                   	nop
c0103761:	c9                   	leave  
c0103762:	c3                   	ret    

c0103763 <check_pgdir>:

static void
check_pgdir(void) {
c0103763:	55                   	push   %ebp
c0103764:	89 e5                	mov    %esp,%ebp
c0103766:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103769:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c010376e:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103773:	76 24                	jbe    c0103799 <check_pgdir+0x36>
c0103775:	c7 44 24 0c 67 69 10 	movl   $0xc0106967,0xc(%esp)
c010377c:	c0 
c010377d:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103784:	c0 
c0103785:	c7 44 24 04 d8 01 00 	movl   $0x1d8,0x4(%esp)
c010378c:	00 
c010378d:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103794:	e8 60 cc ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103799:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010379e:	85 c0                	test   %eax,%eax
c01037a0:	74 0e                	je     c01037b0 <check_pgdir+0x4d>
c01037a2:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037a7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01037ac:	85 c0                	test   %eax,%eax
c01037ae:	74 24                	je     c01037d4 <check_pgdir+0x71>
c01037b0:	c7 44 24 0c 84 69 10 	movl   $0xc0106984,0xc(%esp)
c01037b7:	c0 
c01037b8:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01037bf:	c0 
c01037c0:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c01037c7:	00 
c01037c8:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01037cf:	e8 25 cc ff ff       	call   c01003f9 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01037d4:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01037d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037e0:	00 
c01037e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01037e8:	00 
c01037e9:	89 04 24             	mov    %eax,(%esp)
c01037ec:	e8 3e fd ff ff       	call   c010352f <get_page>
c01037f1:	85 c0                	test   %eax,%eax
c01037f3:	74 24                	je     c0103819 <check_pgdir+0xb6>
c01037f5:	c7 44 24 0c bc 69 10 	movl   $0xc01069bc,0xc(%esp)
c01037fc:	c0 
c01037fd:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103804:	c0 
c0103805:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c010380c:	00 
c010380d:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103814:	e8 e0 cb ff ff       	call   c01003f9 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103819:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103820:	e8 0f f5 ff ff       	call   c0102d34 <alloc_pages>
c0103825:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103828:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010382d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103834:	00 
c0103835:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010383c:	00 
c010383d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103840:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103844:	89 04 24             	mov    %eax,(%esp)
c0103847:	e8 e3 fd ff ff       	call   c010362f <page_insert>
c010384c:	85 c0                	test   %eax,%eax
c010384e:	74 24                	je     c0103874 <check_pgdir+0x111>
c0103850:	c7 44 24 0c e4 69 10 	movl   $0xc01069e4,0xc(%esp)
c0103857:	c0 
c0103858:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c010385f:	c0 
c0103860:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0103867:	00 
c0103868:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010386f:	e8 85 cb ff ff       	call   c01003f9 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103874:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103879:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103880:	00 
c0103881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103888:	00 
c0103889:	89 04 24             	mov    %eax,(%esp)
c010388c:	e8 5b fb ff ff       	call   c01033ec <get_pte>
c0103891:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103894:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103898:	75 24                	jne    c01038be <check_pgdir+0x15b>
c010389a:	c7 44 24 0c 10 6a 10 	movl   $0xc0106a10,0xc(%esp)
c01038a1:	c0 
c01038a2:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01038a9:	c0 
c01038aa:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01038b1:	00 
c01038b2:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01038b9:	e8 3b cb ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c01038be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038c1:	8b 00                	mov    (%eax),%eax
c01038c3:	89 04 24             	mov    %eax,(%esp)
c01038c6:	e8 0e f2 ff ff       	call   c0102ad9 <pte2page>
c01038cb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01038ce:	74 24                	je     c01038f4 <check_pgdir+0x191>
c01038d0:	c7 44 24 0c 3d 6a 10 	movl   $0xc0106a3d,0xc(%esp)
c01038d7:	c0 
c01038d8:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01038df:	c0 
c01038e0:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c01038e7:	00 
c01038e8:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01038ef:	e8 05 cb ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 1);
c01038f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038f7:	89 04 24             	mov    %eax,(%esp)
c01038fa:	e8 30 f2 ff ff       	call   c0102b2f <page_ref>
c01038ff:	83 f8 01             	cmp    $0x1,%eax
c0103902:	74 24                	je     c0103928 <check_pgdir+0x1c5>
c0103904:	c7 44 24 0c 53 6a 10 	movl   $0xc0106a53,0xc(%esp)
c010390b:	c0 
c010390c:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103913:	c0 
c0103914:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c010391b:	00 
c010391c:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103923:	e8 d1 ca ff ff       	call   c01003f9 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103928:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010392d:	8b 00                	mov    (%eax),%eax
c010392f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103934:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103937:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010393a:	c1 e8 0c             	shr    $0xc,%eax
c010393d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103940:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103945:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103948:	72 23                	jb     c010396d <check_pgdir+0x20a>
c010394a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010394d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103951:	c7 44 24 08 20 68 10 	movl   $0xc0106820,0x8(%esp)
c0103958:	c0 
c0103959:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0103960:	00 
c0103961:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103968:	e8 8c ca ff ff       	call   c01003f9 <__panic>
c010396d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103970:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103975:	83 c0 04             	add    $0x4,%eax
c0103978:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010397b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103980:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103987:	00 
c0103988:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010398f:	00 
c0103990:	89 04 24             	mov    %eax,(%esp)
c0103993:	e8 54 fa ff ff       	call   c01033ec <get_pte>
c0103998:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010399b:	74 24                	je     c01039c1 <check_pgdir+0x25e>
c010399d:	c7 44 24 0c 68 6a 10 	movl   $0xc0106a68,0xc(%esp)
c01039a4:	c0 
c01039a5:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01039ac:	c0 
c01039ad:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01039b4:	00 
c01039b5:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01039bc:	e8 38 ca ff ff       	call   c01003f9 <__panic>

    p2 = alloc_page();
c01039c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039c8:	e8 67 f3 ff ff       	call   c0102d34 <alloc_pages>
c01039cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01039d0:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01039d5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01039dc:	00 
c01039dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01039e4:	00 
c01039e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039e8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039ec:	89 04 24             	mov    %eax,(%esp)
c01039ef:	e8 3b fc ff ff       	call   c010362f <page_insert>
c01039f4:	85 c0                	test   %eax,%eax
c01039f6:	74 24                	je     c0103a1c <check_pgdir+0x2b9>
c01039f8:	c7 44 24 0c 90 6a 10 	movl   $0xc0106a90,0xc(%esp)
c01039ff:	c0 
c0103a00:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103a07:	c0 
c0103a08:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0103a0f:	00 
c0103a10:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103a17:	e8 dd c9 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a1c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103a21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a28:	00 
c0103a29:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a30:	00 
c0103a31:	89 04 24             	mov    %eax,(%esp)
c0103a34:	e8 b3 f9 ff ff       	call   c01033ec <get_pte>
c0103a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a40:	75 24                	jne    c0103a66 <check_pgdir+0x303>
c0103a42:	c7 44 24 0c c8 6a 10 	movl   $0xc0106ac8,0xc(%esp)
c0103a49:	c0 
c0103a4a:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103a51:	c0 
c0103a52:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103a59:	00 
c0103a5a:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103a61:	e8 93 c9 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_U);
c0103a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a69:	8b 00                	mov    (%eax),%eax
c0103a6b:	83 e0 04             	and    $0x4,%eax
c0103a6e:	85 c0                	test   %eax,%eax
c0103a70:	75 24                	jne    c0103a96 <check_pgdir+0x333>
c0103a72:	c7 44 24 0c f8 6a 10 	movl   $0xc0106af8,0xc(%esp)
c0103a79:	c0 
c0103a7a:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103a81:	c0 
c0103a82:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103a89:	00 
c0103a8a:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103a91:	e8 63 c9 ff ff       	call   c01003f9 <__panic>
    assert(*ptep & PTE_W);
c0103a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a99:	8b 00                	mov    (%eax),%eax
c0103a9b:	83 e0 02             	and    $0x2,%eax
c0103a9e:	85 c0                	test   %eax,%eax
c0103aa0:	75 24                	jne    c0103ac6 <check_pgdir+0x363>
c0103aa2:	c7 44 24 0c 06 6b 10 	movl   $0xc0106b06,0xc(%esp)
c0103aa9:	c0 
c0103aaa:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103ab1:	c0 
c0103ab2:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103ab9:	00 
c0103aba:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103ac1:	e8 33 c9 ff ff       	call   c01003f9 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103ac6:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103acb:	8b 00                	mov    (%eax),%eax
c0103acd:	83 e0 04             	and    $0x4,%eax
c0103ad0:	85 c0                	test   %eax,%eax
c0103ad2:	75 24                	jne    c0103af8 <check_pgdir+0x395>
c0103ad4:	c7 44 24 0c 14 6b 10 	movl   $0xc0106b14,0xc(%esp)
c0103adb:	c0 
c0103adc:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103ae3:	c0 
c0103ae4:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103aeb:	00 
c0103aec:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103af3:	e8 01 c9 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 1);
c0103af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103afb:	89 04 24             	mov    %eax,(%esp)
c0103afe:	e8 2c f0 ff ff       	call   c0102b2f <page_ref>
c0103b03:	83 f8 01             	cmp    $0x1,%eax
c0103b06:	74 24                	je     c0103b2c <check_pgdir+0x3c9>
c0103b08:	c7 44 24 0c 2a 6b 10 	movl   $0xc0106b2a,0xc(%esp)
c0103b0f:	c0 
c0103b10:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103b17:	c0 
c0103b18:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103b1f:	00 
c0103b20:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103b27:	e8 cd c8 ff ff       	call   c01003f9 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103b2c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103b31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103b38:	00 
c0103b39:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103b40:	00 
c0103b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b48:	89 04 24             	mov    %eax,(%esp)
c0103b4b:	e8 df fa ff ff       	call   c010362f <page_insert>
c0103b50:	85 c0                	test   %eax,%eax
c0103b52:	74 24                	je     c0103b78 <check_pgdir+0x415>
c0103b54:	c7 44 24 0c 3c 6b 10 	movl   $0xc0106b3c,0xc(%esp)
c0103b5b:	c0 
c0103b5c:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103b63:	c0 
c0103b64:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103b6b:	00 
c0103b6c:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103b73:	e8 81 c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p1) == 2);
c0103b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b7b:	89 04 24             	mov    %eax,(%esp)
c0103b7e:	e8 ac ef ff ff       	call   c0102b2f <page_ref>
c0103b83:	83 f8 02             	cmp    $0x2,%eax
c0103b86:	74 24                	je     c0103bac <check_pgdir+0x449>
c0103b88:	c7 44 24 0c 68 6b 10 	movl   $0xc0106b68,0xc(%esp)
c0103b8f:	c0 
c0103b90:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103b97:	c0 
c0103b98:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103b9f:	00 
c0103ba0:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103ba7:	e8 4d c8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103baf:	89 04 24             	mov    %eax,(%esp)
c0103bb2:	e8 78 ef ff ff       	call   c0102b2f <page_ref>
c0103bb7:	85 c0                	test   %eax,%eax
c0103bb9:	74 24                	je     c0103bdf <check_pgdir+0x47c>
c0103bbb:	c7 44 24 0c 7a 6b 10 	movl   $0xc0106b7a,0xc(%esp)
c0103bc2:	c0 
c0103bc3:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103bca:	c0 
c0103bcb:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0103bd2:	00 
c0103bd3:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103bda:	e8 1a c8 ff ff       	call   c01003f9 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103bdf:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103be4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103beb:	00 
c0103bec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103bf3:	00 
c0103bf4:	89 04 24             	mov    %eax,(%esp)
c0103bf7:	e8 f0 f7 ff ff       	call   c01033ec <get_pte>
c0103bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c03:	75 24                	jne    c0103c29 <check_pgdir+0x4c6>
c0103c05:	c7 44 24 0c c8 6a 10 	movl   $0xc0106ac8,0xc(%esp)
c0103c0c:	c0 
c0103c0d:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103c14:	c0 
c0103c15:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0103c1c:	00 
c0103c1d:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103c24:	e8 d0 c7 ff ff       	call   c01003f9 <__panic>
    assert(pte2page(*ptep) == p1);
c0103c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c2c:	8b 00                	mov    (%eax),%eax
c0103c2e:	89 04 24             	mov    %eax,(%esp)
c0103c31:	e8 a3 ee ff ff       	call   c0102ad9 <pte2page>
c0103c36:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103c39:	74 24                	je     c0103c5f <check_pgdir+0x4fc>
c0103c3b:	c7 44 24 0c 3d 6a 10 	movl   $0xc0106a3d,0xc(%esp)
c0103c42:	c0 
c0103c43:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103c4a:	c0 
c0103c4b:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103c52:	00 
c0103c53:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103c5a:	e8 9a c7 ff ff       	call   c01003f9 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c62:	8b 00                	mov    (%eax),%eax
c0103c64:	83 e0 04             	and    $0x4,%eax
c0103c67:	85 c0                	test   %eax,%eax
c0103c69:	74 24                	je     c0103c8f <check_pgdir+0x52c>
c0103c6b:	c7 44 24 0c 8c 6b 10 	movl   $0xc0106b8c,0xc(%esp)
c0103c72:	c0 
c0103c73:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103c7a:	c0 
c0103c7b:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103c82:	00 
c0103c83:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103c8a:	e8 6a c7 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103c8f:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103c9b:	00 
c0103c9c:	89 04 24             	mov    %eax,(%esp)
c0103c9f:	e8 46 f9 ff ff       	call   c01035ea <page_remove>
    assert(page_ref(p1) == 1);
c0103ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca7:	89 04 24             	mov    %eax,(%esp)
c0103caa:	e8 80 ee ff ff       	call   c0102b2f <page_ref>
c0103caf:	83 f8 01             	cmp    $0x1,%eax
c0103cb2:	74 24                	je     c0103cd8 <check_pgdir+0x575>
c0103cb4:	c7 44 24 0c 53 6a 10 	movl   $0xc0106a53,0xc(%esp)
c0103cbb:	c0 
c0103cbc:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103cc3:	c0 
c0103cc4:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0103ccb:	00 
c0103ccc:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103cd3:	e8 21 c7 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103cd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cdb:	89 04 24             	mov    %eax,(%esp)
c0103cde:	e8 4c ee ff ff       	call   c0102b2f <page_ref>
c0103ce3:	85 c0                	test   %eax,%eax
c0103ce5:	74 24                	je     c0103d0b <check_pgdir+0x5a8>
c0103ce7:	c7 44 24 0c 7a 6b 10 	movl   $0xc0106b7a,0xc(%esp)
c0103cee:	c0 
c0103cef:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103cf6:	c0 
c0103cf7:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103cfe:	00 
c0103cff:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103d06:	e8 ee c6 ff ff       	call   c01003f9 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103d0b:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103d10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103d17:	00 
c0103d18:	89 04 24             	mov    %eax,(%esp)
c0103d1b:	e8 ca f8 ff ff       	call   c01035ea <page_remove>
    assert(page_ref(p1) == 0);
c0103d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d23:	89 04 24             	mov    %eax,(%esp)
c0103d26:	e8 04 ee ff ff       	call   c0102b2f <page_ref>
c0103d2b:	85 c0                	test   %eax,%eax
c0103d2d:	74 24                	je     c0103d53 <check_pgdir+0x5f0>
c0103d2f:	c7 44 24 0c a1 6b 10 	movl   $0xc0106ba1,0xc(%esp)
c0103d36:	c0 
c0103d37:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103d3e:	c0 
c0103d3f:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0103d46:	00 
c0103d47:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103d4e:	e8 a6 c6 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p2) == 0);
c0103d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d56:	89 04 24             	mov    %eax,(%esp)
c0103d59:	e8 d1 ed ff ff       	call   c0102b2f <page_ref>
c0103d5e:	85 c0                	test   %eax,%eax
c0103d60:	74 24                	je     c0103d86 <check_pgdir+0x623>
c0103d62:	c7 44 24 0c 7a 6b 10 	movl   $0xc0106b7a,0xc(%esp)
c0103d69:	c0 
c0103d6a:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103d71:	c0 
c0103d72:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103d79:	00 
c0103d7a:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103d81:	e8 73 c6 ff ff       	call   c01003f9 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103d86:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103d8b:	8b 00                	mov    (%eax),%eax
c0103d8d:	89 04 24             	mov    %eax,(%esp)
c0103d90:	e8 82 ed ff ff       	call   c0102b17 <pde2page>
c0103d95:	89 04 24             	mov    %eax,(%esp)
c0103d98:	e8 92 ed ff ff       	call   c0102b2f <page_ref>
c0103d9d:	83 f8 01             	cmp    $0x1,%eax
c0103da0:	74 24                	je     c0103dc6 <check_pgdir+0x663>
c0103da2:	c7 44 24 0c b4 6b 10 	movl   $0xc0106bb4,0xc(%esp)
c0103da9:	c0 
c0103daa:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103db1:	c0 
c0103db2:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103db9:	00 
c0103dba:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103dc1:	e8 33 c6 ff ff       	call   c01003f9 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103dc6:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103dcb:	8b 00                	mov    (%eax),%eax
c0103dcd:	89 04 24             	mov    %eax,(%esp)
c0103dd0:	e8 42 ed ff ff       	call   c0102b17 <pde2page>
c0103dd5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ddc:	00 
c0103ddd:	89 04 24             	mov    %eax,(%esp)
c0103de0:	e8 87 ef ff ff       	call   c0102d6c <free_pages>
    boot_pgdir[0] = 0;
c0103de5:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103dea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103df0:	c7 04 24 db 6b 10 c0 	movl   $0xc0106bdb,(%esp)
c0103df7:	e8 a6 c4 ff ff       	call   c01002a2 <cprintf>
}
c0103dfc:	90                   	nop
c0103dfd:	c9                   	leave  
c0103dfe:	c3                   	ret    

c0103dff <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103dff:	55                   	push   %ebp
c0103e00:	89 e5                	mov    %esp,%ebp
c0103e02:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103e05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103e0c:	e9 ca 00 00 00       	jmp    c0103edb <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e1a:	c1 e8 0c             	shr    $0xc,%eax
c0103e1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103e20:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103e25:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103e28:	72 23                	jb     c0103e4d <check_boot_pgdir+0x4e>
c0103e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e31:	c7 44 24 08 20 68 10 	movl   $0xc0106820,0x8(%esp)
c0103e38:	c0 
c0103e39:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103e40:	00 
c0103e41:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103e48:	e8 ac c5 ff ff       	call   c01003f9 <__panic>
c0103e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e50:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103e55:	89 c2                	mov    %eax,%edx
c0103e57:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e63:	00 
c0103e64:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e68:	89 04 24             	mov    %eax,(%esp)
c0103e6b:	e8 7c f5 ff ff       	call   c01033ec <get_pte>
c0103e70:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103e73:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103e77:	75 24                	jne    c0103e9d <check_boot_pgdir+0x9e>
c0103e79:	c7 44 24 0c f8 6b 10 	movl   $0xc0106bf8,0xc(%esp)
c0103e80:	c0 
c0103e81:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103e88:	c0 
c0103e89:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103e90:	00 
c0103e91:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103e98:	e8 5c c5 ff ff       	call   c01003f9 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103e9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ea0:	8b 00                	mov    (%eax),%eax
c0103ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ea7:	89 c2                	mov    %eax,%edx
c0103ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103eac:	39 c2                	cmp    %eax,%edx
c0103eae:	74 24                	je     c0103ed4 <check_boot_pgdir+0xd5>
c0103eb0:	c7 44 24 0c 35 6c 10 	movl   $0xc0106c35,0xc(%esp)
c0103eb7:	c0 
c0103eb8:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103ebf:	c0 
c0103ec0:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103ec7:	00 
c0103ec8:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103ecf:	e8 25 c5 ff ff       	call   c01003f9 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103ed4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103edb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ede:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0103ee3:	39 c2                	cmp    %eax,%edx
c0103ee5:	0f 82 26 ff ff ff    	jb     c0103e11 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103eeb:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103ef0:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103ef5:	8b 00                	mov    (%eax),%eax
c0103ef7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103efc:	89 c2                	mov    %eax,%edx
c0103efe:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103f03:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f06:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103f0d:	77 23                	ja     c0103f32 <check_boot_pgdir+0x133>
c0103f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f16:	c7 44 24 08 c4 68 10 	movl   $0xc01068c4,0x8(%esp)
c0103f1d:	c0 
c0103f1e:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103f25:	00 
c0103f26:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103f2d:	e8 c7 c4 ff ff       	call   c01003f9 <__panic>
c0103f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f35:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f3a:	39 d0                	cmp    %edx,%eax
c0103f3c:	74 24                	je     c0103f62 <check_boot_pgdir+0x163>
c0103f3e:	c7 44 24 0c 4c 6c 10 	movl   $0xc0106c4c,0xc(%esp)
c0103f45:	c0 
c0103f46:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103f4d:	c0 
c0103f4e:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103f55:	00 
c0103f56:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103f5d:	e8 97 c4 ff ff       	call   c01003f9 <__panic>

    assert(boot_pgdir[0] == 0);
c0103f62:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103f67:	8b 00                	mov    (%eax),%eax
c0103f69:	85 c0                	test   %eax,%eax
c0103f6b:	74 24                	je     c0103f91 <check_boot_pgdir+0x192>
c0103f6d:	c7 44 24 0c 80 6c 10 	movl   $0xc0106c80,0xc(%esp)
c0103f74:	c0 
c0103f75:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103f7c:	c0 
c0103f7d:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0103f84:	00 
c0103f85:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103f8c:	e8 68 c4 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    p = alloc_page();
c0103f91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f98:	e8 97 ed ff ff       	call   c0102d34 <alloc_pages>
c0103f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103fa0:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103fa5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103fac:	00 
c0103fad:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103fb4:	00 
c0103fb5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103fb8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fbc:	89 04 24             	mov    %eax,(%esp)
c0103fbf:	e8 6b f6 ff ff       	call   c010362f <page_insert>
c0103fc4:	85 c0                	test   %eax,%eax
c0103fc6:	74 24                	je     c0103fec <check_boot_pgdir+0x1ed>
c0103fc8:	c7 44 24 0c 94 6c 10 	movl   $0xc0106c94,0xc(%esp)
c0103fcf:	c0 
c0103fd0:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0103fd7:	c0 
c0103fd8:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0103fdf:	00 
c0103fe0:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0103fe7:	e8 0d c4 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 1);
c0103fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fef:	89 04 24             	mov    %eax,(%esp)
c0103ff2:	e8 38 eb ff ff       	call   c0102b2f <page_ref>
c0103ff7:	83 f8 01             	cmp    $0x1,%eax
c0103ffa:	74 24                	je     c0104020 <check_boot_pgdir+0x221>
c0103ffc:	c7 44 24 0c c2 6c 10 	movl   $0xc0106cc2,0xc(%esp)
c0104003:	c0 
c0104004:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c010400b:	c0 
c010400c:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104013:	00 
c0104014:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010401b:	e8 d9 c3 ff ff       	call   c01003f9 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104020:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104025:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010402c:	00 
c010402d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104034:	00 
c0104035:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104038:	89 54 24 04          	mov    %edx,0x4(%esp)
c010403c:	89 04 24             	mov    %eax,(%esp)
c010403f:	e8 eb f5 ff ff       	call   c010362f <page_insert>
c0104044:	85 c0                	test   %eax,%eax
c0104046:	74 24                	je     c010406c <check_boot_pgdir+0x26d>
c0104048:	c7 44 24 0c d4 6c 10 	movl   $0xc0106cd4,0xc(%esp)
c010404f:	c0 
c0104050:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0104057:	c0 
c0104058:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c010405f:	00 
c0104060:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0104067:	e8 8d c3 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p) == 2);
c010406c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010406f:	89 04 24             	mov    %eax,(%esp)
c0104072:	e8 b8 ea ff ff       	call   c0102b2f <page_ref>
c0104077:	83 f8 02             	cmp    $0x2,%eax
c010407a:	74 24                	je     c01040a0 <check_boot_pgdir+0x2a1>
c010407c:	c7 44 24 0c 0b 6d 10 	movl   $0xc0106d0b,0xc(%esp)
c0104083:	c0 
c0104084:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c010408b:	c0 
c010408c:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104093:	00 
c0104094:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c010409b:	e8 59 c3 ff ff       	call   c01003f9 <__panic>

    const char *str = "ucore: Hello world!!";
c01040a0:	c7 45 e8 1c 6d 10 c0 	movl   $0xc0106d1c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c01040a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01040ae:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040b5:	e8 57 15 00 00       	call   c0105611 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01040ba:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01040c1:	00 
c01040c2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01040c9:	e8 ba 15 00 00       	call   c0105688 <strcmp>
c01040ce:	85 c0                	test   %eax,%eax
c01040d0:	74 24                	je     c01040f6 <check_boot_pgdir+0x2f7>
c01040d2:	c7 44 24 0c 34 6d 10 	movl   $0xc0106d34,0xc(%esp)
c01040d9:	c0 
c01040da:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c01040e1:	c0 
c01040e2:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c01040e9:	00 
c01040ea:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c01040f1:	e8 03 c3 ff ff       	call   c01003f9 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01040f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040f9:	89 04 24             	mov    %eax,(%esp)
c01040fc:	e8 84 e9 ff ff       	call   c0102a85 <page2kva>
c0104101:	05 00 01 00 00       	add    $0x100,%eax
c0104106:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0104109:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104110:	e8 a6 14 00 00       	call   c01055bb <strlen>
c0104115:	85 c0                	test   %eax,%eax
c0104117:	74 24                	je     c010413d <check_boot_pgdir+0x33e>
c0104119:	c7 44 24 0c 6c 6d 10 	movl   $0xc0106d6c,0xc(%esp)
c0104120:	c0 
c0104121:	c7 44 24 08 0d 69 10 	movl   $0xc010690d,0x8(%esp)
c0104128:	c0 
c0104129:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104130:	00 
c0104131:	c7 04 24 e8 68 10 c0 	movl   $0xc01068e8,(%esp)
c0104138:	e8 bc c2 ff ff       	call   c01003f9 <__panic>

    free_page(p);
c010413d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104144:	00 
c0104145:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104148:	89 04 24             	mov    %eax,(%esp)
c010414b:	e8 1c ec ff ff       	call   c0102d6c <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104150:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104155:	8b 00                	mov    (%eax),%eax
c0104157:	89 04 24             	mov    %eax,(%esp)
c010415a:	e8 b8 e9 ff ff       	call   c0102b17 <pde2page>
c010415f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104166:	00 
c0104167:	89 04 24             	mov    %eax,(%esp)
c010416a:	e8 fd eb ff ff       	call   c0102d6c <free_pages>
    boot_pgdir[0] = 0;
c010416f:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104174:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010417a:	c7 04 24 90 6d 10 c0 	movl   $0xc0106d90,(%esp)
c0104181:	e8 1c c1 ff ff       	call   c01002a2 <cprintf>
}
c0104186:	90                   	nop
c0104187:	c9                   	leave  
c0104188:	c3                   	ret    

c0104189 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104189:	55                   	push   %ebp
c010418a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010418c:	8b 45 08             	mov    0x8(%ebp),%eax
c010418f:	83 e0 04             	and    $0x4,%eax
c0104192:	85 c0                	test   %eax,%eax
c0104194:	74 04                	je     c010419a <perm2str+0x11>
c0104196:	b0 75                	mov    $0x75,%al
c0104198:	eb 02                	jmp    c010419c <perm2str+0x13>
c010419a:	b0 2d                	mov    $0x2d,%al
c010419c:	a2 08 bf 11 c0       	mov    %al,0xc011bf08
    str[1] = 'r';
c01041a1:	c6 05 09 bf 11 c0 72 	movb   $0x72,0xc011bf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01041a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041ab:	83 e0 02             	and    $0x2,%eax
c01041ae:	85 c0                	test   %eax,%eax
c01041b0:	74 04                	je     c01041b6 <perm2str+0x2d>
c01041b2:	b0 77                	mov    $0x77,%al
c01041b4:	eb 02                	jmp    c01041b8 <perm2str+0x2f>
c01041b6:	b0 2d                	mov    $0x2d,%al
c01041b8:	a2 0a bf 11 c0       	mov    %al,0xc011bf0a
    str[3] = '\0';
c01041bd:	c6 05 0b bf 11 c0 00 	movb   $0x0,0xc011bf0b
    return str;
c01041c4:	b8 08 bf 11 c0       	mov    $0xc011bf08,%eax
}
c01041c9:	5d                   	pop    %ebp
c01041ca:	c3                   	ret    

c01041cb <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01041cb:	55                   	push   %ebp
c01041cc:	89 e5                	mov    %esp,%ebp
c01041ce:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01041d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01041d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041d7:	72 0d                	jb     c01041e6 <get_pgtable_items+0x1b>
        return 0;
c01041d9:	b8 00 00 00 00       	mov    $0x0,%eax
c01041de:	e9 98 00 00 00       	jmp    c010427b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01041e3:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01041e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01041e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01041ec:	73 18                	jae    c0104206 <get_pgtable_items+0x3b>
c01041ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01041f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01041f8:	8b 45 14             	mov    0x14(%ebp),%eax
c01041fb:	01 d0                	add    %edx,%eax
c01041fd:	8b 00                	mov    (%eax),%eax
c01041ff:	83 e0 01             	and    $0x1,%eax
c0104202:	85 c0                	test   %eax,%eax
c0104204:	74 dd                	je     c01041e3 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0104206:	8b 45 10             	mov    0x10(%ebp),%eax
c0104209:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010420c:	73 68                	jae    c0104276 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c010420e:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104212:	74 08                	je     c010421c <get_pgtable_items+0x51>
            *left_store = start;
c0104214:	8b 45 18             	mov    0x18(%ebp),%eax
c0104217:	8b 55 10             	mov    0x10(%ebp),%edx
c010421a:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010421c:	8b 45 10             	mov    0x10(%ebp),%eax
c010421f:	8d 50 01             	lea    0x1(%eax),%edx
c0104222:	89 55 10             	mov    %edx,0x10(%ebp)
c0104225:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010422c:	8b 45 14             	mov    0x14(%ebp),%eax
c010422f:	01 d0                	add    %edx,%eax
c0104231:	8b 00                	mov    (%eax),%eax
c0104233:	83 e0 07             	and    $0x7,%eax
c0104236:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104239:	eb 03                	jmp    c010423e <get_pgtable_items+0x73>
            start ++;
c010423b:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010423e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104241:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104244:	73 1d                	jae    c0104263 <get_pgtable_items+0x98>
c0104246:	8b 45 10             	mov    0x10(%ebp),%eax
c0104249:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104250:	8b 45 14             	mov    0x14(%ebp),%eax
c0104253:	01 d0                	add    %edx,%eax
c0104255:	8b 00                	mov    (%eax),%eax
c0104257:	83 e0 07             	and    $0x7,%eax
c010425a:	89 c2                	mov    %eax,%edx
c010425c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010425f:	39 c2                	cmp    %eax,%edx
c0104261:	74 d8                	je     c010423b <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0104263:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104267:	74 08                	je     c0104271 <get_pgtable_items+0xa6>
            *right_store = start;
c0104269:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010426c:	8b 55 10             	mov    0x10(%ebp),%edx
c010426f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104271:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104274:	eb 05                	jmp    c010427b <get_pgtable_items+0xb0>
    }
    return 0;
c0104276:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010427b:	c9                   	leave  
c010427c:	c3                   	ret    

c010427d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010427d:	55                   	push   %ebp
c010427e:	89 e5                	mov    %esp,%ebp
c0104280:	57                   	push   %edi
c0104281:	56                   	push   %esi
c0104282:	53                   	push   %ebx
c0104283:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104286:	c7 04 24 b0 6d 10 c0 	movl   $0xc0106db0,(%esp)
c010428d:	e8 10 c0 ff ff       	call   c01002a2 <cprintf>
    size_t left, right = 0, perm;
c0104292:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104299:	e9 fa 00 00 00       	jmp    c0104398 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010429e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042a1:	89 04 24             	mov    %eax,(%esp)
c01042a4:	e8 e0 fe ff ff       	call   c0104189 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01042a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01042ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042af:	29 d1                	sub    %edx,%ecx
c01042b1:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01042b3:	89 d6                	mov    %edx,%esi
c01042b5:	c1 e6 16             	shl    $0x16,%esi
c01042b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042bb:	89 d3                	mov    %edx,%ebx
c01042bd:	c1 e3 16             	shl    $0x16,%ebx
c01042c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042c3:	89 d1                	mov    %edx,%ecx
c01042c5:	c1 e1 16             	shl    $0x16,%ecx
c01042c8:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01042cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042ce:	29 d7                	sub    %edx,%edi
c01042d0:	89 fa                	mov    %edi,%edx
c01042d2:	89 44 24 14          	mov    %eax,0x14(%esp)
c01042d6:	89 74 24 10          	mov    %esi,0x10(%esp)
c01042da:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01042de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01042e2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042e6:	c7 04 24 e1 6d 10 c0 	movl   $0xc0106de1,(%esp)
c01042ed:	e8 b0 bf ff ff       	call   c01002a2 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01042f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042f5:	c1 e0 0a             	shl    $0xa,%eax
c01042f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01042fb:	eb 54                	jmp    c0104351 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01042fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104300:	89 04 24             	mov    %eax,(%esp)
c0104303:	e8 81 fe ff ff       	call   c0104189 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104308:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010430b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010430e:	29 d1                	sub    %edx,%ecx
c0104310:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104312:	89 d6                	mov    %edx,%esi
c0104314:	c1 e6 0c             	shl    $0xc,%esi
c0104317:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010431a:	89 d3                	mov    %edx,%ebx
c010431c:	c1 e3 0c             	shl    $0xc,%ebx
c010431f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104322:	89 d1                	mov    %edx,%ecx
c0104324:	c1 e1 0c             	shl    $0xc,%ecx
c0104327:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010432a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010432d:	29 d7                	sub    %edx,%edi
c010432f:	89 fa                	mov    %edi,%edx
c0104331:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104335:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104339:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010433d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104341:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104345:	c7 04 24 00 6e 10 c0 	movl   $0xc0106e00,(%esp)
c010434c:	e8 51 bf ff ff       	call   c01002a2 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104351:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104359:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010435c:	89 d3                	mov    %edx,%ebx
c010435e:	c1 e3 0a             	shl    $0xa,%ebx
c0104361:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104364:	89 d1                	mov    %edx,%ecx
c0104366:	c1 e1 0a             	shl    $0xa,%ecx
c0104369:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c010436c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104370:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104373:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104377:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010437b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010437f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104383:	89 0c 24             	mov    %ecx,(%esp)
c0104386:	e8 40 fe ff ff       	call   c01041cb <get_pgtable_items>
c010438b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010438e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104392:	0f 85 65 ff ff ff    	jne    c01042fd <print_pgdir+0x80>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104398:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010439d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043a0:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01043a3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01043a7:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01043aa:	89 54 24 10          	mov    %edx,0x10(%esp)
c01043ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01043b2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01043b6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01043bd:	00 
c01043be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01043c5:	e8 01 fe ff ff       	call   c01041cb <get_pgtable_items>
c01043ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01043d1:	0f 85 c7 fe ff ff    	jne    c010429e <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01043d7:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01043de:	e8 bf be ff ff       	call   c01002a2 <cprintf>
}
c01043e3:	90                   	nop
c01043e4:	83 c4 4c             	add    $0x4c,%esp
c01043e7:	5b                   	pop    %ebx
c01043e8:	5e                   	pop    %esi
c01043e9:	5f                   	pop    %edi
c01043ea:	5d                   	pop    %ebp
c01043eb:	c3                   	ret    

c01043ec <page2ppn>:
page2ppn(struct Page *page) {
c01043ec:	55                   	push   %ebp
c01043ed:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01043ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01043f2:	8b 15 18 bf 11 c0    	mov    0xc011bf18,%edx
c01043f8:	29 d0                	sub    %edx,%eax
c01043fa:	c1 f8 02             	sar    $0x2,%eax
c01043fd:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104403:	5d                   	pop    %ebp
c0104404:	c3                   	ret    

c0104405 <page2pa>:
page2pa(struct Page *page) {
c0104405:	55                   	push   %ebp
c0104406:	89 e5                	mov    %esp,%ebp
c0104408:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010440b:	8b 45 08             	mov    0x8(%ebp),%eax
c010440e:	89 04 24             	mov    %eax,(%esp)
c0104411:	e8 d6 ff ff ff       	call   c01043ec <page2ppn>
c0104416:	c1 e0 0c             	shl    $0xc,%eax
}
c0104419:	c9                   	leave  
c010441a:	c3                   	ret    

c010441b <page_ref>:
page_ref(struct Page *page) {
c010441b:	55                   	push   %ebp
c010441c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010441e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104421:	8b 00                	mov    (%eax),%eax
}
c0104423:	5d                   	pop    %ebp
c0104424:	c3                   	ret    

c0104425 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104425:	55                   	push   %ebp
c0104426:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104428:	8b 45 08             	mov    0x8(%ebp),%eax
c010442b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010442e:	89 10                	mov    %edx,(%eax)
}
c0104430:	90                   	nop
c0104431:	5d                   	pop    %ebp
c0104432:	c3                   	ret    

c0104433 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104433:	55                   	push   %ebp
c0104434:	89 e5                	mov    %esp,%ebp
c0104436:	83 ec 10             	sub    $0x10,%esp
c0104439:	c7 45 fc 1c bf 11 c0 	movl   $0xc011bf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104440:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104443:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104446:	89 50 04             	mov    %edx,0x4(%eax)
c0104449:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010444c:	8b 50 04             	mov    0x4(%eax),%edx
c010444f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104452:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104454:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c010445b:	00 00 00 
}
c010445e:	90                   	nop
c010445f:	c9                   	leave  
c0104460:	c3                   	ret    

c0104461 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104461:	55                   	push   %ebp
c0104462:	89 e5                	mov    %esp,%ebp
c0104464:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);    //断言，如果判断为false，直接中断程序的执行
c0104467:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010446b:	75 24                	jne    c0104491 <default_init_memmap+0x30>
c010446d:	c7 44 24 0c 58 6e 10 	movl   $0xc0106e58,0xc(%esp)
c0104474:	c0 
c0104475:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c010447c:	c0 
c010447d:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104484:	00 
c0104485:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c010448c:	e8 68 bf ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c0104491:	8b 45 08             	mov    0x8(%ebp),%eax
c0104494:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104497:	eb 7d                	jmp    c0104516 <default_init_memmap+0xb5>
        assert(PageReserved(p));        //判断该页保留位是否为1，如果为内核占用页则清空该标志位
c0104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010449c:	83 c0 04             	add    $0x4,%eax
c010449f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01044a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01044a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01044af:	0f a3 10             	bt     %edx,(%eax)
c01044b2:	19 c0                	sbb    %eax,%eax
c01044b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01044b7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01044bb:	0f 95 c0             	setne  %al
c01044be:	0f b6 c0             	movzbl %al,%eax
c01044c1:	85 c0                	test   %eax,%eax
c01044c3:	75 24                	jne    c01044e9 <default_init_memmap+0x88>
c01044c5:	c7 44 24 0c 89 6e 10 	movl   $0xc0106e89,0xc(%esp)
c01044cc:	c0 
c01044cd:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01044d4:	c0 
c01044d5:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01044dc:	00 
c01044dd:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01044e4:	e8 10 bf ff ff       	call   c01003f9 <__panic>
        p->flags = p->property = 0;     //标志为清0，空闲块数量置0
c01044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01044f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f6:	8b 50 08             	mov    0x8(%eax),%edx
c01044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044fc:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);                   //设置引用量为0
c01044ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104506:	00 
c0104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010450a:	89 04 24             	mov    %eax,(%esp)
c010450d:	e8 13 ff ff ff       	call   c0104425 <set_page_ref>
    for (; p != base + n; p ++) {
c0104512:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104516:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104519:	89 d0                	mov    %edx,%eax
c010451b:	c1 e0 02             	shl    $0x2,%eax
c010451e:	01 d0                	add    %edx,%eax
c0104520:	c1 e0 02             	shl    $0x2,%eax
c0104523:	89 c2                	mov    %eax,%edx
c0104525:	8b 45 08             	mov    0x8(%ebp),%eax
c0104528:	01 d0                	add    %edx,%eax
c010452a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010452d:	0f 85 66 ff ff ff    	jne    c0104499 <default_init_memmap+0x38>
    }
    base->property = n;
c0104533:	8b 45 08             	mov    0x8(%ebp),%eax
c0104536:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104539:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010453c:	8b 45 08             	mov    0x8(%ebp),%eax
c010453f:	83 c0 04             	add    $0x4,%eax
c0104542:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104549:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010454c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010454f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104552:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104555:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c010455b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010455e:	01 d0                	add    %edx,%eax
c0104560:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
    //应该使用list_add_before,否则使用list_add默认为add_after,
    //这样新增加的页总是在后面，不适合FFMA算法，应该要按照地址排序
    list_add_before(&free_list, &(base->page_link));    //cc
c0104565:	8b 45 08             	mov    0x8(%ebp),%eax
c0104568:	83 c0 0c             	add    $0xc,%eax
c010456b:	c7 45 e4 1c bf 11 c0 	movl   $0xc011bf1c,-0x1c(%ebp)
c0104572:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104578:	8b 00                	mov    (%eax),%eax
c010457a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010457d:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104580:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104586:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010458c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010458f:	89 10                	mov    %edx,(%eax)
c0104591:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104594:	8b 10                	mov    (%eax),%edx
c0104596:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104599:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010459c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010459f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01045a2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01045a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01045ab:	89 10                	mov    %edx,(%eax)
}
c01045ad:	90                   	nop
c01045ae:	c9                   	leave  
c01045af:	c3                   	ret    

c01045b0 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01045b0:	55                   	push   %ebp
c01045b1:	89 e5                	mov    %esp,%ebp
c01045b3:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01045b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01045ba:	75 24                	jne    c01045e0 <default_alloc_pages+0x30>
c01045bc:	c7 44 24 0c 58 6e 10 	movl   $0xc0106e58,0xc(%esp)
c01045c3:	c0 
c01045c4:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01045cb:	c0 
c01045cc:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c01045d3:	00 
c01045d4:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01045db:	e8 19 be ff ff       	call   c01003f9 <__panic>
    if (n > nr_free) {      //要求的超过空闲空间大小，返回NULL
c01045e0:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c01045e5:	39 45 08             	cmp    %eax,0x8(%ebp)
c01045e8:	76 0a                	jbe    c01045f4 <default_alloc_pages+0x44>
        return NULL;
c01045ea:	b8 00 00 00 00       	mov    $0x0,%eax
c01045ef:	e9 3d 01 00 00       	jmp    c0104731 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c01045f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;          //查找符合条件的page
c01045fb:	c7 45 f0 1c bf 11 c0 	movl   $0xc011bf1c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104602:	eb 1c                	jmp    c0104620 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0104604:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104607:	83 e8 0c             	sub    $0xc,%eax
c010460a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {               //找到符合条件的块，赋值给page变量带出
c010460d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104610:	8b 40 08             	mov    0x8(%eax),%eax
c0104613:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104616:	77 08                	ja     c0104620 <default_alloc_pages+0x70>
            page = p;
c0104618:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010461b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010461e:	eb 18                	jmp    c0104638 <default_alloc_pages+0x88>
c0104620:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104623:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0104626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104629:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010462c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010462f:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c0104636:	75 cc                	jne    c0104604 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {           //找到了符合条件的页，进行设置
c0104638:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010463c:	0f 84 ec 00 00 00    	je     c010472e <default_alloc_pages+0x17e>
        if (page->property > n) {
c0104642:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104645:	8b 40 08             	mov    0x8(%eax),%eax
c0104648:	39 45 08             	cmp    %eax,0x8(%ebp)
c010464b:	0f 83 8c 00 00 00    	jae    c01046dd <default_alloc_pages+0x12d>
            struct Page *p = page + n;        //将多余的页空间，重新放入空闲页表目录
c0104651:	8b 55 08             	mov    0x8(%ebp),%edx
c0104654:	89 d0                	mov    %edx,%eax
c0104656:	c1 e0 02             	shl    $0x2,%eax
c0104659:	01 d0                	add    %edx,%eax
c010465b:	c1 e0 02             	shl    $0x2,%eax
c010465e:	89 c2                	mov    %eax,%edx
c0104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104663:	01 d0                	add    %edx,%eax
c0104665:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0104668:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466b:	8b 40 08             	mov    0x8(%eax),%eax
c010466e:	2b 45 08             	sub    0x8(%ebp),%eax
c0104671:	89 c2                	mov    %eax,%edx
c0104673:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104676:	89 50 08             	mov    %edx,0x8(%eax)
            //应该要对剩余的部分空闲页设置属性位，在init中属性位全为0，这里需要设为1,表明空闲块
            SetPageProperty(p);                 //++
c0104679:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010467c:	83 c0 04             	add    $0x4,%eax
c010467f:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0104686:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104689:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010468c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010468f:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));  //cc注意一定要添加在后面,按地址排序
c0104692:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104695:	83 c0 0c             	add    $0xc,%eax
c0104698:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010469b:	83 c2 0c             	add    $0xc,%edx
c010469e:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01046a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c01046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01046a7:	8b 40 04             	mov    0x4(%eax),%eax
c01046aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01046ad:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01046b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01046b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01046b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01046b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01046bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01046bf:	89 10                	mov    %edx,(%eax)
c01046c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01046c4:	8b 10                	mov    (%eax),%edx
c01046c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01046c9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01046cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01046d2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01046d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01046d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01046db:	89 10                	mov    %edx,(%eax)
    }
      list_del(&(page->page_link));     // 先要处理完剩余空间再删除该页，从空闲页表目录页删除该页
c01046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e0:	83 c0 0c             	add    $0xc,%eax
c01046e3:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01046e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01046e9:	8b 40 04             	mov    0x4(%eax),%eax
c01046ec:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01046ef:	8b 12                	mov    (%edx),%edx
c01046f1:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01046f4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01046f7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01046fa:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01046fd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104700:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104703:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104706:	89 10                	mov    %edx,(%eax)
      nr_free -= n;       //总空闲块数减去分配页块数
c0104708:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c010470d:	2b 45 08             	sub    0x8(%ebp),%eax
c0104710:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
      ClearPageProperty(page);//将属性位置0，标记该页已被分配
c0104715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104718:	83 c0 04             	add    $0x4,%eax
c010471b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104722:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104725:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104728:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010472b:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010472e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104731:	c9                   	leave  
c0104732:	c3                   	ret    

c0104733 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104733:	55                   	push   %ebp
c0104734:	89 e5                	mov    %esp,%ebp
c0104736:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010473c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104740:	75 24                	jne    c0104766 <default_free_pages+0x33>
c0104742:	c7 44 24 0c 58 6e 10 	movl   $0xc0106e58,0xc(%esp)
c0104749:	c0 
c010474a:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104751:	c0 
c0104752:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104759:	00 
c010475a:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104761:	e8 93 bc ff ff       	call   c01003f9 <__panic>
    struct Page *p = base;
c0104766:	8b 45 08             	mov    0x8(%ebp),%eax
c0104769:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
c010476c:	e9 9d 00 00 00       	jmp    c010480e <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));     //否则为用户态的占用区
c0104771:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104774:	83 c0 04             	add    $0x4,%eax
c0104777:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010477e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104781:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104784:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104787:	0f a3 10             	bt     %edx,(%eax)
c010478a:	19 c0                	sbb    %eax,%eax
c010478c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010478f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104793:	0f 95 c0             	setne  %al
c0104796:	0f b6 c0             	movzbl %al,%eax
c0104799:	85 c0                	test   %eax,%eax
c010479b:	75 2c                	jne    c01047c9 <default_free_pages+0x96>
c010479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a0:	83 c0 04             	add    $0x4,%eax
c01047a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01047aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01047b3:	0f a3 10             	bt     %edx,(%eax)
c01047b6:	19 c0                	sbb    %eax,%eax
c01047b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01047bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01047bf:	0f 95 c0             	setne  %al
c01047c2:	0f b6 c0             	movzbl %al,%eax
c01047c5:	85 c0                	test   %eax,%eax
c01047c7:	74 24                	je     c01047ed <default_free_pages+0xba>
c01047c9:	c7 44 24 0c 9c 6e 10 	movl   $0xc0106e9c,0xc(%esp)
c01047d0:	c0 
c01047d1:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01047d8:	c0 
c01047d9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01047e0:	00 
c01047e1:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01047e8:	e8 0c bc ff ff       	call   c01003f9 <__panic>
        p->flags = 0;         //标志位清零
c01047ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01047f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047fe:	00 
c01047ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104802:	89 04 24             	mov    %eax,(%esp)
c0104805:	e8 1b fc ff ff       	call   c0104425 <set_page_ref>
    for (; p != base + n; p ++) {   //释放合并页空间的时候，跳过内核占用的页，和可用的空闲页
c010480a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010480e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104811:	89 d0                	mov    %edx,%eax
c0104813:	c1 e0 02             	shl    $0x2,%eax
c0104816:	01 d0                	add    %edx,%eax
c0104818:	c1 e0 02             	shl    $0x2,%eax
c010481b:	89 c2                	mov    %eax,%edx
c010481d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104820:	01 d0                	add    %edx,%eax
c0104822:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104825:	0f 85 46 ff ff ff    	jne    c0104771 <default_free_pages+0x3e>
    }
    base->property = n;
c010482b:	8b 45 08             	mov    0x8(%ebp),%eax
c010482e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104831:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104834:	8b 45 08             	mov    0x8(%ebp),%eax
c0104837:	83 c0 04             	add    $0x4,%eax
c010483a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104841:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104844:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104847:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010484a:	0f ab 10             	bts    %edx,(%eax)
c010484d:	c7 45 d4 1c bf 11 c0 	movl   $0xc011bf1c,-0x2c(%ebp)
    return listelm->next;
c0104854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104857:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);    //获取头页地址
c010485a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {            //合并空页
c010485d:	e9 08 01 00 00       	jmp    c010496a <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104862:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104865:	83 e8 0c             	sub    $0xc,%eax
c0104868:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010486b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010486e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104871:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104874:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104877:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {     //如果该页为当前释放页的紧邻后页，则直接释放后面一页的属性位，将之和当前页合并
c010487a:	8b 45 08             	mov    0x8(%ebp),%eax
c010487d:	8b 50 08             	mov    0x8(%eax),%edx
c0104880:	89 d0                	mov    %edx,%eax
c0104882:	c1 e0 02             	shl    $0x2,%eax
c0104885:	01 d0                	add    %edx,%eax
c0104887:	c1 e0 02             	shl    $0x2,%eax
c010488a:	89 c2                	mov    %eax,%edx
c010488c:	8b 45 08             	mov    0x8(%ebp),%eax
c010488f:	01 d0                	add    %edx,%eax
c0104891:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104894:	75 5a                	jne    c01048f0 <default_free_pages+0x1bd>
            base->property += p->property;
c0104896:	8b 45 08             	mov    0x8(%ebp),%eax
c0104899:	8b 50 08             	mov    0x8(%eax),%edx
c010489c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010489f:	8b 40 08             	mov    0x8(%eax),%eax
c01048a2:	01 c2                	add    %eax,%edx
c01048a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a7:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);     //清楚属性位
c01048aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ad:	83 c0 04             	add    $0x4,%eax
c01048b0:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01048b7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01048ba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01048bd:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01048c0:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));    //在空闲页表中删除该页
c01048c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c6:	83 c0 0c             	add    $0xc,%eax
c01048c9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01048cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01048cf:	8b 40 04             	mov    0x4(%eax),%eax
c01048d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01048d5:	8b 12                	mov    (%edx),%edx
c01048d7:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01048da:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01048dd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01048e0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01048e3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01048e6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01048e9:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01048ec:	89 10                	mov    %edx,(%eax)
c01048ee:	eb 7a                	jmp    c010496a <default_free_pages+0x237>
        }
        else if (p + p->property == base) {   //如果找到紧邻前一页是空页，则把前页合并到当前页
c01048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f3:	8b 50 08             	mov    0x8(%eax),%edx
c01048f6:	89 d0                	mov    %edx,%eax
c01048f8:	c1 e0 02             	shl    $0x2,%eax
c01048fb:	01 d0                	add    %edx,%eax
c01048fd:	c1 e0 02             	shl    $0x2,%eax
c0104900:	89 c2                	mov    %eax,%edx
c0104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104905:	01 d0                	add    %edx,%eax
c0104907:	39 45 08             	cmp    %eax,0x8(%ebp)
c010490a:	75 5e                	jne    c010496a <default_free_pages+0x237>
            p->property += base->property;
c010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490f:	8b 50 08             	mov    0x8(%eax),%edx
c0104912:	8b 45 08             	mov    0x8(%ebp),%eax
c0104915:	8b 40 08             	mov    0x8(%eax),%eax
c0104918:	01 c2                	add    %eax,%edx
c010491a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010491d:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104920:	8b 45 08             	mov    0x8(%ebp),%eax
c0104923:	83 c0 04             	add    $0x4,%eax
c0104926:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c010492d:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104930:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104933:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104936:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104939:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010493c:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104942:	83 c0 0c             	add    $0xc,%eax
c0104945:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104948:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010494b:	8b 40 04             	mov    0x4(%eax),%eax
c010494e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104951:	8b 12                	mov    (%edx),%edx
c0104953:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0104956:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0104959:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010495c:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010495f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104962:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104965:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104968:	89 10                	mov    %edx,(%eax)
    while (le != &free_list) {            //合并空页
c010496a:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c0104971:	0f 85 eb fe ff ff    	jne    c0104862 <default_free_pages+0x12f>
        }
    }
    nr_free += n;
c0104977:	8b 15 24 bf 11 c0    	mov    0xc011bf24,%edx
c010497d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104980:	01 d0                	add    %edx,%eax
c0104982:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24
c0104987:	c7 45 9c 1c bf 11 c0 	movl   $0xc011bf1c,-0x64(%ebp)
    return listelm->next;
c010498e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104991:	8b 40 04             	mov    0x4(%eax),%eax
    //从头到尾进行一次遍历，找到合适的插入位置,把合并和的页插入到找到的位置前面
    le  = list_next(&free_list);
c0104994:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
c0104997:	eb 34                	jmp    c01049cd <default_free_pages+0x29a>
      p = le2page(le,page_link);
c0104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010499c:	83 e8 0c             	sub    $0xc,%eax
c010499f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(base+base->property<=p){
c01049a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01049a5:	8b 50 08             	mov    0x8(%eax),%edx
c01049a8:	89 d0                	mov    %edx,%eax
c01049aa:	c1 e0 02             	shl    $0x2,%eax
c01049ad:	01 d0                	add    %edx,%eax
c01049af:	c1 e0 02             	shl    $0x2,%eax
c01049b2:	89 c2                	mov    %eax,%edx
c01049b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01049b7:	01 d0                	add    %edx,%eax
c01049b9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01049bc:	73 1a                	jae    c01049d8 <default_free_pages+0x2a5>
c01049be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049c1:	89 45 98             	mov    %eax,-0x68(%ebp)
c01049c4:	8b 45 98             	mov    -0x68(%ebp),%eax
c01049c7:	8b 40 04             	mov    0x4(%eax),%eax
        break;
      }
      le = list_next(le);
c01049ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(le!=&free_list){
c01049cd:	81 7d f0 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x10(%ebp)
c01049d4:	75 c3                	jne    c0104999 <default_free_pages+0x266>
c01049d6:	eb 01                	jmp    c01049d9 <default_free_pages+0x2a6>
        break;
c01049d8:	90                   	nop
    }
    list_add_before(le, &(base->page_link));    //cc应该使用add_before把整合的页插入找到的位置
c01049d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01049dc:	8d 50 0c             	lea    0xc(%eax),%edx
c01049df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049e2:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01049e5:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01049e8:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01049eb:	8b 00                	mov    (%eax),%eax
c01049ed:	8b 55 90             	mov    -0x70(%ebp),%edx
c01049f0:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01049f3:	89 45 88             	mov    %eax,-0x78(%ebp)
c01049f6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01049f9:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c01049fc:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01049ff:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104a02:	89 10                	mov    %edx,(%eax)
c0104a04:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104a07:	8b 10                	mov    (%eax),%edx
c0104a09:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104a0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104a0f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a12:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104a15:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104a18:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104a1b:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104a1e:	89 10                	mov    %edx,(%eax)
}
c0104a20:	90                   	nop
c0104a21:	c9                   	leave  
c0104a22:	c3                   	ret    

c0104a23 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104a23:	55                   	push   %ebp
c0104a24:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104a26:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
}
c0104a2b:	5d                   	pop    %ebp
c0104a2c:	c3                   	ret    

c0104a2d <basic_check>:

static void
basic_check(void) {
c0104a2d:	55                   	push   %ebp
c0104a2e:	89 e5                	mov    %esp,%ebp
c0104a30:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104a33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104a46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a4d:	e8 e2 e2 ff ff       	call   c0102d34 <alloc_pages>
c0104a52:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104a59:	75 24                	jne    c0104a7f <basic_check+0x52>
c0104a5b:	c7 44 24 0c c1 6e 10 	movl   $0xc0106ec1,0xc(%esp)
c0104a62:	c0 
c0104a63:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104a6a:	c0 
c0104a6b:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104a72:	00 
c0104a73:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104a7a:	e8 7a b9 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104a7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a86:	e8 a9 e2 ff ff       	call   c0102d34 <alloc_pages>
c0104a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a92:	75 24                	jne    c0104ab8 <basic_check+0x8b>
c0104a94:	c7 44 24 0c dd 6e 10 	movl   $0xc0106edd,0xc(%esp)
c0104a9b:	c0 
c0104a9c:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104aa3:	c0 
c0104aa4:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104aab:	00 
c0104aac:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104ab3:	e8 41 b9 ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104ab8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104abf:	e8 70 e2 ff ff       	call   c0102d34 <alloc_pages>
c0104ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ac7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104acb:	75 24                	jne    c0104af1 <basic_check+0xc4>
c0104acd:	c7 44 24 0c f9 6e 10 	movl   $0xc0106ef9,0xc(%esp)
c0104ad4:	c0 
c0104ad5:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104adc:	c0 
c0104add:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104ae4:	00 
c0104ae5:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104aec:	e8 08 b9 ff ff       	call   c01003f9 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104af4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104af7:	74 10                	je     c0104b09 <basic_check+0xdc>
c0104af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104afc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104aff:	74 08                	je     c0104b09 <basic_check+0xdc>
c0104b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b07:	75 24                	jne    c0104b2d <basic_check+0x100>
c0104b09:	c7 44 24 0c 18 6f 10 	movl   $0xc0106f18,0xc(%esp)
c0104b10:	c0 
c0104b11:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104b18:	c0 
c0104b19:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104b20:	00 
c0104b21:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104b28:	e8 cc b8 ff ff       	call   c01003f9 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104b2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b30:	89 04 24             	mov    %eax,(%esp)
c0104b33:	e8 e3 f8 ff ff       	call   c010441b <page_ref>
c0104b38:	85 c0                	test   %eax,%eax
c0104b3a:	75 1e                	jne    c0104b5a <basic_check+0x12d>
c0104b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b3f:	89 04 24             	mov    %eax,(%esp)
c0104b42:	e8 d4 f8 ff ff       	call   c010441b <page_ref>
c0104b47:	85 c0                	test   %eax,%eax
c0104b49:	75 0f                	jne    c0104b5a <basic_check+0x12d>
c0104b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b4e:	89 04 24             	mov    %eax,(%esp)
c0104b51:	e8 c5 f8 ff ff       	call   c010441b <page_ref>
c0104b56:	85 c0                	test   %eax,%eax
c0104b58:	74 24                	je     c0104b7e <basic_check+0x151>
c0104b5a:	c7 44 24 0c 3c 6f 10 	movl   $0xc0106f3c,0xc(%esp)
c0104b61:	c0 
c0104b62:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104b69:	c0 
c0104b6a:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104b71:	00 
c0104b72:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104b79:	e8 7b b8 ff ff       	call   c01003f9 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104b7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b81:	89 04 24             	mov    %eax,(%esp)
c0104b84:	e8 7c f8 ff ff       	call   c0104405 <page2pa>
c0104b89:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104b8f:	c1 e2 0c             	shl    $0xc,%edx
c0104b92:	39 d0                	cmp    %edx,%eax
c0104b94:	72 24                	jb     c0104bba <basic_check+0x18d>
c0104b96:	c7 44 24 0c 78 6f 10 	movl   $0xc0106f78,0xc(%esp)
c0104b9d:	c0 
c0104b9e:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104ba5:	c0 
c0104ba6:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0104bad:	00 
c0104bae:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104bb5:	e8 3f b8 ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bbd:	89 04 24             	mov    %eax,(%esp)
c0104bc0:	e8 40 f8 ff ff       	call   c0104405 <page2pa>
c0104bc5:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104bcb:	c1 e2 0c             	shl    $0xc,%edx
c0104bce:	39 d0                	cmp    %edx,%eax
c0104bd0:	72 24                	jb     c0104bf6 <basic_check+0x1c9>
c0104bd2:	c7 44 24 0c 95 6f 10 	movl   $0xc0106f95,0xc(%esp)
c0104bd9:	c0 
c0104bda:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104be1:	c0 
c0104be2:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0104be9:	00 
c0104bea:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104bf1:	e8 03 b8 ff ff       	call   c01003f9 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf9:	89 04 24             	mov    %eax,(%esp)
c0104bfc:	e8 04 f8 ff ff       	call   c0104405 <page2pa>
c0104c01:	8b 15 80 be 11 c0    	mov    0xc011be80,%edx
c0104c07:	c1 e2 0c             	shl    $0xc,%edx
c0104c0a:	39 d0                	cmp    %edx,%eax
c0104c0c:	72 24                	jb     c0104c32 <basic_check+0x205>
c0104c0e:	c7 44 24 0c b2 6f 10 	movl   $0xc0106fb2,0xc(%esp)
c0104c15:	c0 
c0104c16:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104c1d:	c0 
c0104c1e:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0104c25:	00 
c0104c26:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104c2d:	e8 c7 b7 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c0104c32:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c0104c37:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c0104c3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c40:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c43:	c7 45 dc 1c bf 11 c0 	movl   $0xc011bf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104c4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c4d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c50:	89 50 04             	mov    %edx,0x4(%eax)
c0104c53:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c56:	8b 50 04             	mov    0x4(%eax),%edx
c0104c59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c5c:	89 10                	mov    %edx,(%eax)
c0104c5e:	c7 45 e0 1c bf 11 c0 	movl   $0xc011bf1c,-0x20(%ebp)
    return list->next == list;
c0104c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104c68:	8b 40 04             	mov    0x4(%eax),%eax
c0104c6b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104c6e:	0f 94 c0             	sete   %al
c0104c71:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104c74:	85 c0                	test   %eax,%eax
c0104c76:	75 24                	jne    c0104c9c <basic_check+0x26f>
c0104c78:	c7 44 24 0c cf 6f 10 	movl   $0xc0106fcf,0xc(%esp)
c0104c7f:	c0 
c0104c80:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104c87:	c0 
c0104c88:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0104c8f:	00 
c0104c90:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104c97:	e8 5d b7 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c0104c9c:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104ca1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104ca4:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c0104cab:	00 00 00 

    assert(alloc_page() == NULL);
c0104cae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cb5:	e8 7a e0 ff ff       	call   c0102d34 <alloc_pages>
c0104cba:	85 c0                	test   %eax,%eax
c0104cbc:	74 24                	je     c0104ce2 <basic_check+0x2b5>
c0104cbe:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c0104cc5:	c0 
c0104cc6:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104ccd:	c0 
c0104cce:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0104cd5:	00 
c0104cd6:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104cdd:	e8 17 b7 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104ce2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ce9:	00 
c0104cea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ced:	89 04 24             	mov    %eax,(%esp)
c0104cf0:	e8 77 e0 ff ff       	call   c0102d6c <free_pages>
    free_page(p1);
c0104cf5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cfc:	00 
c0104cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d00:	89 04 24             	mov    %eax,(%esp)
c0104d03:	e8 64 e0 ff ff       	call   c0102d6c <free_pages>
    free_page(p2);
c0104d08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d0f:	00 
c0104d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d13:	89 04 24             	mov    %eax,(%esp)
c0104d16:	e8 51 e0 ff ff       	call   c0102d6c <free_pages>
    assert(nr_free == 3);
c0104d1b:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104d20:	83 f8 03             	cmp    $0x3,%eax
c0104d23:	74 24                	je     c0104d49 <basic_check+0x31c>
c0104d25:	c7 44 24 0c fb 6f 10 	movl   $0xc0106ffb,0xc(%esp)
c0104d2c:	c0 
c0104d2d:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104d34:	c0 
c0104d35:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0104d3c:	00 
c0104d3d:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104d44:	e8 b0 b6 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104d49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d50:	e8 df df ff ff       	call   c0102d34 <alloc_pages>
c0104d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d5c:	75 24                	jne    c0104d82 <basic_check+0x355>
c0104d5e:	c7 44 24 0c c1 6e 10 	movl   $0xc0106ec1,0xc(%esp)
c0104d65:	c0 
c0104d66:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104d6d:	c0 
c0104d6e:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0104d75:	00 
c0104d76:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104d7d:	e8 77 b6 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d89:	e8 a6 df ff ff       	call   c0102d34 <alloc_pages>
c0104d8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d95:	75 24                	jne    c0104dbb <basic_check+0x38e>
c0104d97:	c7 44 24 0c dd 6e 10 	movl   $0xc0106edd,0xc(%esp)
c0104d9e:	c0 
c0104d9f:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104da6:	c0 
c0104da7:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0104dae:	00 
c0104daf:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104db6:	e8 3e b6 ff ff       	call   c01003f9 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104dbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dc2:	e8 6d df ff ff       	call   c0102d34 <alloc_pages>
c0104dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104dce:	75 24                	jne    c0104df4 <basic_check+0x3c7>
c0104dd0:	c7 44 24 0c f9 6e 10 	movl   $0xc0106ef9,0xc(%esp)
c0104dd7:	c0 
c0104dd8:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104ddf:	c0 
c0104de0:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0104de7:	00 
c0104de8:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104def:	e8 05 b6 ff ff       	call   c01003f9 <__panic>

    assert(alloc_page() == NULL);
c0104df4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dfb:	e8 34 df ff ff       	call   c0102d34 <alloc_pages>
c0104e00:	85 c0                	test   %eax,%eax
c0104e02:	74 24                	je     c0104e28 <basic_check+0x3fb>
c0104e04:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c0104e0b:	c0 
c0104e0c:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104e13:	c0 
c0104e14:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104e1b:	00 
c0104e1c:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104e23:	e8 d1 b5 ff ff       	call   c01003f9 <__panic>

    free_page(p0);
c0104e28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e2f:	00 
c0104e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e33:	89 04 24             	mov    %eax,(%esp)
c0104e36:	e8 31 df ff ff       	call   c0102d6c <free_pages>
c0104e3b:	c7 45 d8 1c bf 11 c0 	movl   $0xc011bf1c,-0x28(%ebp)
c0104e42:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e45:	8b 40 04             	mov    0x4(%eax),%eax
c0104e48:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104e4b:	0f 94 c0             	sete   %al
c0104e4e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104e51:	85 c0                	test   %eax,%eax
c0104e53:	74 24                	je     c0104e79 <basic_check+0x44c>
c0104e55:	c7 44 24 0c 08 70 10 	movl   $0xc0107008,0xc(%esp)
c0104e5c:	c0 
c0104e5d:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104e64:	c0 
c0104e65:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0104e6c:	00 
c0104e6d:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104e74:	e8 80 b5 ff ff       	call   c01003f9 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104e79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e80:	e8 af de ff ff       	call   c0102d34 <alloc_pages>
c0104e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104e8e:	74 24                	je     c0104eb4 <basic_check+0x487>
c0104e90:	c7 44 24 0c 20 70 10 	movl   $0xc0107020,0xc(%esp)
c0104e97:	c0 
c0104e98:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104e9f:	c0 
c0104ea0:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0104ea7:	00 
c0104ea8:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104eaf:	e8 45 b5 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0104eb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ebb:	e8 74 de ff ff       	call   c0102d34 <alloc_pages>
c0104ec0:	85 c0                	test   %eax,%eax
c0104ec2:	74 24                	je     c0104ee8 <basic_check+0x4bb>
c0104ec4:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c0104ecb:	c0 
c0104ecc:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104ed3:	c0 
c0104ed4:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0104edb:	00 
c0104edc:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104ee3:	e8 11 b5 ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c0104ee8:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0104eed:	85 c0                	test   %eax,%eax
c0104eef:	74 24                	je     c0104f15 <basic_check+0x4e8>
c0104ef1:	c7 44 24 0c 39 70 10 	movl   $0xc0107039,0xc(%esp)
c0104ef8:	c0 
c0104ef9:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104f00:	c0 
c0104f01:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104f08:	00 
c0104f09:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104f10:	e8 e4 b4 ff ff       	call   c01003f9 <__panic>
    free_list = free_list_store;
c0104f15:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f1b:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c0104f20:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    nr_free = nr_free_store;
c0104f26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f29:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_page(p);
c0104f2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f35:	00 
c0104f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f39:	89 04 24             	mov    %eax,(%esp)
c0104f3c:	e8 2b de ff ff       	call   c0102d6c <free_pages>
    free_page(p1);
c0104f41:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f48:	00 
c0104f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f4c:	89 04 24             	mov    %eax,(%esp)
c0104f4f:	e8 18 de ff ff       	call   c0102d6c <free_pages>
    free_page(p2);
c0104f54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f5b:	00 
c0104f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f5f:	89 04 24             	mov    %eax,(%esp)
c0104f62:	e8 05 de ff ff       	call   c0102d6c <free_pages>
}
c0104f67:	90                   	nop
c0104f68:	c9                   	leave  
c0104f69:	c3                   	ret    

c0104f6a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104f6a:	55                   	push   %ebp
c0104f6b:	89 e5                	mov    %esp,%ebp
c0104f6d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104f73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104f7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104f81:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104f88:	eb 6a                	jmp    c0104ff4 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f8d:	83 e8 0c             	sub    $0xc,%eax
c0104f90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0104f93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104f96:	83 c0 04             	add    $0x4,%eax
c0104f99:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104fa0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fa3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104fa6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104fa9:	0f a3 10             	bt     %edx,(%eax)
c0104fac:	19 c0                	sbb    %eax,%eax
c0104fae:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104fb1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104fb5:	0f 95 c0             	setne  %al
c0104fb8:	0f b6 c0             	movzbl %al,%eax
c0104fbb:	85 c0                	test   %eax,%eax
c0104fbd:	75 24                	jne    c0104fe3 <default_check+0x79>
c0104fbf:	c7 44 24 0c 46 70 10 	movl   $0xc0107046,0xc(%esp)
c0104fc6:	c0 
c0104fc7:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0104fce:	c0 
c0104fcf:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104fd6:	00 
c0104fd7:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0104fde:	e8 16 b4 ff ff       	call   c01003f9 <__panic>
        count ++, total += p->property;
c0104fe3:	ff 45 f4             	incl   -0xc(%ebp)
c0104fe6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104fe9:	8b 50 08             	mov    0x8(%eax),%edx
c0104fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fef:	01 d0                	add    %edx,%eax
c0104ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ff7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104ffa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ffd:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105000:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105003:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c010500a:	0f 85 7a ff ff ff    	jne    c0104f8a <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0105010:	e8 8a dd ff ff       	call   c0102d9f <nr_free_pages>
c0105015:	89 c2                	mov    %eax,%edx
c0105017:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010501a:	39 c2                	cmp    %eax,%edx
c010501c:	74 24                	je     c0105042 <default_check+0xd8>
c010501e:	c7 44 24 0c 56 70 10 	movl   $0xc0107056,0xc(%esp)
c0105025:	c0 
c0105026:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c010502d:	c0 
c010502e:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0105035:	00 
c0105036:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c010503d:	e8 b7 b3 ff ff       	call   c01003f9 <__panic>

    basic_check();
c0105042:	e8 e6 f9 ff ff       	call   c0104a2d <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105047:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010504e:	e8 e1 dc ff ff       	call   c0102d34 <alloc_pages>
c0105053:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0105056:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010505a:	75 24                	jne    c0105080 <default_check+0x116>
c010505c:	c7 44 24 0c 6f 70 10 	movl   $0xc010706f,0xc(%esp)
c0105063:	c0 
c0105064:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c010506b:	c0 
c010506c:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0105073:	00 
c0105074:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c010507b:	e8 79 b3 ff ff       	call   c01003f9 <__panic>
    assert(!PageProperty(p0));
c0105080:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105083:	83 c0 04             	add    $0x4,%eax
c0105086:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010508d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105090:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105093:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105096:	0f a3 10             	bt     %edx,(%eax)
c0105099:	19 c0                	sbb    %eax,%eax
c010509b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010509e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01050a2:	0f 95 c0             	setne  %al
c01050a5:	0f b6 c0             	movzbl %al,%eax
c01050a8:	85 c0                	test   %eax,%eax
c01050aa:	74 24                	je     c01050d0 <default_check+0x166>
c01050ac:	c7 44 24 0c 7a 70 10 	movl   $0xc010707a,0xc(%esp)
c01050b3:	c0 
c01050b4:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01050bb:	c0 
c01050bc:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01050c3:	00 
c01050c4:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01050cb:	e8 29 b3 ff ff       	call   c01003f9 <__panic>

    list_entry_t free_list_store = free_list;
c01050d0:	a1 1c bf 11 c0       	mov    0xc011bf1c,%eax
c01050d5:	8b 15 20 bf 11 c0    	mov    0xc011bf20,%edx
c01050db:	89 45 80             	mov    %eax,-0x80(%ebp)
c01050de:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01050e1:	c7 45 b0 1c bf 11 c0 	movl   $0xc011bf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01050e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01050eb:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01050ee:	89 50 04             	mov    %edx,0x4(%eax)
c01050f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01050f4:	8b 50 04             	mov    0x4(%eax),%edx
c01050f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01050fa:	89 10                	mov    %edx,(%eax)
c01050fc:	c7 45 b4 1c bf 11 c0 	movl   $0xc011bf1c,-0x4c(%ebp)
    return list->next == list;
c0105103:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105106:	8b 40 04             	mov    0x4(%eax),%eax
c0105109:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010510c:	0f 94 c0             	sete   %al
c010510f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105112:	85 c0                	test   %eax,%eax
c0105114:	75 24                	jne    c010513a <default_check+0x1d0>
c0105116:	c7 44 24 0c cf 6f 10 	movl   $0xc0106fcf,0xc(%esp)
c010511d:	c0 
c010511e:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105125:	c0 
c0105126:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c010512d:	00 
c010512e:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105135:	e8 bf b2 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c010513a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105141:	e8 ee db ff ff       	call   c0102d34 <alloc_pages>
c0105146:	85 c0                	test   %eax,%eax
c0105148:	74 24                	je     c010516e <default_check+0x204>
c010514a:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c0105151:	c0 
c0105152:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105159:	c0 
c010515a:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0105161:	00 
c0105162:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105169:	e8 8b b2 ff ff       	call   c01003f9 <__panic>

    unsigned int nr_free_store = nr_free;
c010516e:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c0105173:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105176:	c7 05 24 bf 11 c0 00 	movl   $0x0,0xc011bf24
c010517d:	00 00 00 

    free_pages(p0 + 2, 3);
c0105180:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105183:	83 c0 28             	add    $0x28,%eax
c0105186:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010518d:	00 
c010518e:	89 04 24             	mov    %eax,(%esp)
c0105191:	e8 d6 db ff ff       	call   c0102d6c <free_pages>
    assert(alloc_pages(4) == NULL);
c0105196:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010519d:	e8 92 db ff ff       	call   c0102d34 <alloc_pages>
c01051a2:	85 c0                	test   %eax,%eax
c01051a4:	74 24                	je     c01051ca <default_check+0x260>
c01051a6:	c7 44 24 0c 8c 70 10 	movl   $0xc010708c,0xc(%esp)
c01051ad:	c0 
c01051ae:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01051b5:	c0 
c01051b6:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01051bd:	00 
c01051be:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01051c5:	e8 2f b2 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01051ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051cd:	83 c0 28             	add    $0x28,%eax
c01051d0:	83 c0 04             	add    $0x4,%eax
c01051d3:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01051da:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01051dd:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01051e0:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01051e3:	0f a3 10             	bt     %edx,(%eax)
c01051e6:	19 c0                	sbb    %eax,%eax
c01051e8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01051eb:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01051ef:	0f 95 c0             	setne  %al
c01051f2:	0f b6 c0             	movzbl %al,%eax
c01051f5:	85 c0                	test   %eax,%eax
c01051f7:	74 0e                	je     c0105207 <default_check+0x29d>
c01051f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051fc:	83 c0 28             	add    $0x28,%eax
c01051ff:	8b 40 08             	mov    0x8(%eax),%eax
c0105202:	83 f8 03             	cmp    $0x3,%eax
c0105205:	74 24                	je     c010522b <default_check+0x2c1>
c0105207:	c7 44 24 0c a4 70 10 	movl   $0xc01070a4,0xc(%esp)
c010520e:	c0 
c010520f:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105216:	c0 
c0105217:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010521e:	00 
c010521f:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105226:	e8 ce b1 ff ff       	call   c01003f9 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010522b:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105232:	e8 fd da ff ff       	call   c0102d34 <alloc_pages>
c0105237:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010523a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010523e:	75 24                	jne    c0105264 <default_check+0x2fa>
c0105240:	c7 44 24 0c d0 70 10 	movl   $0xc01070d0,0xc(%esp)
c0105247:	c0 
c0105248:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c010524f:	c0 
c0105250:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0105257:	00 
c0105258:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c010525f:	e8 95 b1 ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c0105264:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010526b:	e8 c4 da ff ff       	call   c0102d34 <alloc_pages>
c0105270:	85 c0                	test   %eax,%eax
c0105272:	74 24                	je     c0105298 <default_check+0x32e>
c0105274:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c010527b:	c0 
c010527c:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105283:	c0 
c0105284:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010528b:	00 
c010528c:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105293:	e8 61 b1 ff ff       	call   c01003f9 <__panic>
    assert(p0 + 2 == p1);
c0105298:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010529b:	83 c0 28             	add    $0x28,%eax
c010529e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01052a1:	74 24                	je     c01052c7 <default_check+0x35d>
c01052a3:	c7 44 24 0c ee 70 10 	movl   $0xc01070ee,0xc(%esp)
c01052aa:	c0 
c01052ab:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01052b2:	c0 
c01052b3:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01052ba:	00 
c01052bb:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01052c2:	e8 32 b1 ff ff       	call   c01003f9 <__panic>

    p2 = p0 + 1;
c01052c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052ca:	83 c0 14             	add    $0x14,%eax
c01052cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01052d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052d7:	00 
c01052d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052db:	89 04 24             	mov    %eax,(%esp)
c01052de:	e8 89 da ff ff       	call   c0102d6c <free_pages>
    free_pages(p1, 3);
c01052e3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01052ea:	00 
c01052eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052ee:	89 04 24             	mov    %eax,(%esp)
c01052f1:	e8 76 da ff ff       	call   c0102d6c <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01052f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052f9:	83 c0 04             	add    $0x4,%eax
c01052fc:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0105303:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105306:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105309:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010530c:	0f a3 10             	bt     %edx,(%eax)
c010530f:	19 c0                	sbb    %eax,%eax
c0105311:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105314:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105318:	0f 95 c0             	setne  %al
c010531b:	0f b6 c0             	movzbl %al,%eax
c010531e:	85 c0                	test   %eax,%eax
c0105320:	74 0b                	je     c010532d <default_check+0x3c3>
c0105322:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105325:	8b 40 08             	mov    0x8(%eax),%eax
c0105328:	83 f8 01             	cmp    $0x1,%eax
c010532b:	74 24                	je     c0105351 <default_check+0x3e7>
c010532d:	c7 44 24 0c fc 70 10 	movl   $0xc01070fc,0xc(%esp)
c0105334:	c0 
c0105335:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c010533c:	c0 
c010533d:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0105344:	00 
c0105345:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c010534c:	e8 a8 b0 ff ff       	call   c01003f9 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105351:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105354:	83 c0 04             	add    $0x4,%eax
c0105357:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010535e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105361:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105364:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105367:	0f a3 10             	bt     %edx,(%eax)
c010536a:	19 c0                	sbb    %eax,%eax
c010536c:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010536f:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105373:	0f 95 c0             	setne  %al
c0105376:	0f b6 c0             	movzbl %al,%eax
c0105379:	85 c0                	test   %eax,%eax
c010537b:	74 0b                	je     c0105388 <default_check+0x41e>
c010537d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105380:	8b 40 08             	mov    0x8(%eax),%eax
c0105383:	83 f8 03             	cmp    $0x3,%eax
c0105386:	74 24                	je     c01053ac <default_check+0x442>
c0105388:	c7 44 24 0c 24 71 10 	movl   $0xc0107124,0xc(%esp)
c010538f:	c0 
c0105390:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105397:	c0 
c0105398:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010539f:	00 
c01053a0:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01053a7:	e8 4d b0 ff ff       	call   c01003f9 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01053ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01053b3:	e8 7c d9 ff ff       	call   c0102d34 <alloc_pages>
c01053b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053be:	83 e8 14             	sub    $0x14,%eax
c01053c1:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01053c4:	74 24                	je     c01053ea <default_check+0x480>
c01053c6:	c7 44 24 0c 4a 71 10 	movl   $0xc010714a,0xc(%esp)
c01053cd:	c0 
c01053ce:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01053d5:	c0 
c01053d6:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01053dd:	00 
c01053de:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01053e5:	e8 0f b0 ff ff       	call   c01003f9 <__panic>
    free_page(p0);
c01053ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053f1:	00 
c01053f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053f5:	89 04 24             	mov    %eax,(%esp)
c01053f8:	e8 6f d9 ff ff       	call   c0102d6c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01053fd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105404:	e8 2b d9 ff ff       	call   c0102d34 <alloc_pages>
c0105409:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010540c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010540f:	83 c0 14             	add    $0x14,%eax
c0105412:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105415:	74 24                	je     c010543b <default_check+0x4d1>
c0105417:	c7 44 24 0c 68 71 10 	movl   $0xc0107168,0xc(%esp)
c010541e:	c0 
c010541f:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105426:	c0 
c0105427:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010542e:	00 
c010542f:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105436:	e8 be af ff ff       	call   c01003f9 <__panic>

    free_pages(p0, 2);
c010543b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105442:	00 
c0105443:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105446:	89 04 24             	mov    %eax,(%esp)
c0105449:	e8 1e d9 ff ff       	call   c0102d6c <free_pages>
    free_page(p2);
c010544e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105455:	00 
c0105456:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105459:	89 04 24             	mov    %eax,(%esp)
c010545c:	e8 0b d9 ff ff       	call   c0102d6c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105461:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105468:	e8 c7 d8 ff ff       	call   c0102d34 <alloc_pages>
c010546d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105470:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105474:	75 24                	jne    c010549a <default_check+0x530>
c0105476:	c7 44 24 0c 88 71 10 	movl   $0xc0107188,0xc(%esp)
c010547d:	c0 
c010547e:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105485:	c0 
c0105486:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c010548d:	00 
c010548e:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105495:	e8 5f af ff ff       	call   c01003f9 <__panic>
    assert(alloc_page() == NULL);
c010549a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054a1:	e8 8e d8 ff ff       	call   c0102d34 <alloc_pages>
c01054a6:	85 c0                	test   %eax,%eax
c01054a8:	74 24                	je     c01054ce <default_check+0x564>
c01054aa:	c7 44 24 0c e6 6f 10 	movl   $0xc0106fe6,0xc(%esp)
c01054b1:	c0 
c01054b2:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01054b9:	c0 
c01054ba:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01054c1:	00 
c01054c2:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01054c9:	e8 2b af ff ff       	call   c01003f9 <__panic>

    assert(nr_free == 0);
c01054ce:	a1 24 bf 11 c0       	mov    0xc011bf24,%eax
c01054d3:	85 c0                	test   %eax,%eax
c01054d5:	74 24                	je     c01054fb <default_check+0x591>
c01054d7:	c7 44 24 0c 39 70 10 	movl   $0xc0107039,0xc(%esp)
c01054de:	c0 
c01054df:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01054e6:	c0 
c01054e7:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01054ee:	00 
c01054ef:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01054f6:	e8 fe ae ff ff       	call   c01003f9 <__panic>
    nr_free = nr_free_store;
c01054fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054fe:	a3 24 bf 11 c0       	mov    %eax,0xc011bf24

    free_list = free_list_store;
c0105503:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105506:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105509:	a3 1c bf 11 c0       	mov    %eax,0xc011bf1c
c010550e:	89 15 20 bf 11 c0    	mov    %edx,0xc011bf20
    free_pages(p0, 5);
c0105514:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010551b:	00 
c010551c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010551f:	89 04 24             	mov    %eax,(%esp)
c0105522:	e8 45 d8 ff ff       	call   c0102d6c <free_pages>

    le = &free_list;
c0105527:	c7 45 ec 1c bf 11 c0 	movl   $0xc011bf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010552e:	eb 1c                	jmp    c010554c <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0105530:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105533:	83 e8 0c             	sub    $0xc,%eax
c0105536:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105539:	ff 4d f4             	decl   -0xc(%ebp)
c010553c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010553f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105542:	8b 40 08             	mov    0x8(%eax),%eax
c0105545:	29 c2                	sub    %eax,%edx
c0105547:	89 d0                	mov    %edx,%eax
c0105549:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010554c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010554f:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105552:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105555:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105558:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010555b:	81 7d ec 1c bf 11 c0 	cmpl   $0xc011bf1c,-0x14(%ebp)
c0105562:	75 cc                	jne    c0105530 <default_check+0x5c6>
    }
    assert(count == 0);
c0105564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105568:	74 24                	je     c010558e <default_check+0x624>
c010556a:	c7 44 24 0c a6 71 10 	movl   $0xc01071a6,0xc(%esp)
c0105571:	c0 
c0105572:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c0105579:	c0 
c010557a:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0105581:	00 
c0105582:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c0105589:	e8 6b ae ff ff       	call   c01003f9 <__panic>
    assert(total == 0);
c010558e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105592:	74 24                	je     c01055b8 <default_check+0x64e>
c0105594:	c7 44 24 0c b1 71 10 	movl   $0xc01071b1,0xc(%esp)
c010559b:	c0 
c010559c:	c7 44 24 08 5e 6e 10 	movl   $0xc0106e5e,0x8(%esp)
c01055a3:	c0 
c01055a4:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c01055ab:	00 
c01055ac:	c7 04 24 73 6e 10 c0 	movl   $0xc0106e73,(%esp)
c01055b3:	e8 41 ae ff ff       	call   c01003f9 <__panic>
}
c01055b8:	90                   	nop
c01055b9:	c9                   	leave  
c01055ba:	c3                   	ret    

c01055bb <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01055bb:	55                   	push   %ebp
c01055bc:	89 e5                	mov    %esp,%ebp
c01055be:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01055c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01055c8:	eb 03                	jmp    c01055cd <strlen+0x12>
        cnt ++;
c01055ca:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01055cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d0:	8d 50 01             	lea    0x1(%eax),%edx
c01055d3:	89 55 08             	mov    %edx,0x8(%ebp)
c01055d6:	0f b6 00             	movzbl (%eax),%eax
c01055d9:	84 c0                	test   %al,%al
c01055db:	75 ed                	jne    c01055ca <strlen+0xf>
    }
    return cnt;
c01055dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01055e0:	c9                   	leave  
c01055e1:	c3                   	ret    

c01055e2 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01055e2:	55                   	push   %ebp
c01055e3:	89 e5                	mov    %esp,%ebp
c01055e5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01055e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01055ef:	eb 03                	jmp    c01055f4 <strnlen+0x12>
        cnt ++;
c01055f1:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01055f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01055f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01055fa:	73 10                	jae    c010560c <strnlen+0x2a>
c01055fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ff:	8d 50 01             	lea    0x1(%eax),%edx
c0105602:	89 55 08             	mov    %edx,0x8(%ebp)
c0105605:	0f b6 00             	movzbl (%eax),%eax
c0105608:	84 c0                	test   %al,%al
c010560a:	75 e5                	jne    c01055f1 <strnlen+0xf>
    }
    return cnt;
c010560c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010560f:	c9                   	leave  
c0105610:	c3                   	ret    

c0105611 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105611:	55                   	push   %ebp
c0105612:	89 e5                	mov    %esp,%ebp
c0105614:	57                   	push   %edi
c0105615:	56                   	push   %esi
c0105616:	83 ec 20             	sub    $0x20,%esp
c0105619:	8b 45 08             	mov    0x8(%ebp),%eax
c010561c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010561f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105622:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105625:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010562b:	89 d1                	mov    %edx,%ecx
c010562d:	89 c2                	mov    %eax,%edx
c010562f:	89 ce                	mov    %ecx,%esi
c0105631:	89 d7                	mov    %edx,%edi
c0105633:	ac                   	lods   %ds:(%esi),%al
c0105634:	aa                   	stos   %al,%es:(%edi)
c0105635:	84 c0                	test   %al,%al
c0105637:	75 fa                	jne    c0105633 <strcpy+0x22>
c0105639:	89 fa                	mov    %edi,%edx
c010563b:	89 f1                	mov    %esi,%ecx
c010563d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105640:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105643:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105646:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0105649:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010564a:	83 c4 20             	add    $0x20,%esp
c010564d:	5e                   	pop    %esi
c010564e:	5f                   	pop    %edi
c010564f:	5d                   	pop    %ebp
c0105650:	c3                   	ret    

c0105651 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105651:	55                   	push   %ebp
c0105652:	89 e5                	mov    %esp,%ebp
c0105654:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105657:	8b 45 08             	mov    0x8(%ebp),%eax
c010565a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010565d:	eb 1e                	jmp    c010567d <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010565f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105662:	0f b6 10             	movzbl (%eax),%edx
c0105665:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105668:	88 10                	mov    %dl,(%eax)
c010566a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010566d:	0f b6 00             	movzbl (%eax),%eax
c0105670:	84 c0                	test   %al,%al
c0105672:	74 03                	je     c0105677 <strncpy+0x26>
            src ++;
c0105674:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105677:	ff 45 fc             	incl   -0x4(%ebp)
c010567a:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010567d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105681:	75 dc                	jne    c010565f <strncpy+0xe>
    }
    return dst;
c0105683:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105686:	c9                   	leave  
c0105687:	c3                   	ret    

c0105688 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105688:	55                   	push   %ebp
c0105689:	89 e5                	mov    %esp,%ebp
c010568b:	57                   	push   %edi
c010568c:	56                   	push   %esi
c010568d:	83 ec 20             	sub    $0x20,%esp
c0105690:	8b 45 08             	mov    0x8(%ebp),%eax
c0105693:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105696:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105699:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010569c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010569f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056a2:	89 d1                	mov    %edx,%ecx
c01056a4:	89 c2                	mov    %eax,%edx
c01056a6:	89 ce                	mov    %ecx,%esi
c01056a8:	89 d7                	mov    %edx,%edi
c01056aa:	ac                   	lods   %ds:(%esi),%al
c01056ab:	ae                   	scas   %es:(%edi),%al
c01056ac:	75 08                	jne    c01056b6 <strcmp+0x2e>
c01056ae:	84 c0                	test   %al,%al
c01056b0:	75 f8                	jne    c01056aa <strcmp+0x22>
c01056b2:	31 c0                	xor    %eax,%eax
c01056b4:	eb 04                	jmp    c01056ba <strcmp+0x32>
c01056b6:	19 c0                	sbb    %eax,%eax
c01056b8:	0c 01                	or     $0x1,%al
c01056ba:	89 fa                	mov    %edi,%edx
c01056bc:	89 f1                	mov    %esi,%ecx
c01056be:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01056c1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01056c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01056c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01056ca:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01056cb:	83 c4 20             	add    $0x20,%esp
c01056ce:	5e                   	pop    %esi
c01056cf:	5f                   	pop    %edi
c01056d0:	5d                   	pop    %ebp
c01056d1:	c3                   	ret    

c01056d2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01056d2:	55                   	push   %ebp
c01056d3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01056d5:	eb 09                	jmp    c01056e0 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01056d7:	ff 4d 10             	decl   0x10(%ebp)
c01056da:	ff 45 08             	incl   0x8(%ebp)
c01056dd:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01056e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01056e4:	74 1a                	je     c0105700 <strncmp+0x2e>
c01056e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01056e9:	0f b6 00             	movzbl (%eax),%eax
c01056ec:	84 c0                	test   %al,%al
c01056ee:	74 10                	je     c0105700 <strncmp+0x2e>
c01056f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01056f3:	0f b6 10             	movzbl (%eax),%edx
c01056f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056f9:	0f b6 00             	movzbl (%eax),%eax
c01056fc:	38 c2                	cmp    %al,%dl
c01056fe:	74 d7                	je     c01056d7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105700:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105704:	74 18                	je     c010571e <strncmp+0x4c>
c0105706:	8b 45 08             	mov    0x8(%ebp),%eax
c0105709:	0f b6 00             	movzbl (%eax),%eax
c010570c:	0f b6 d0             	movzbl %al,%edx
c010570f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105712:	0f b6 00             	movzbl (%eax),%eax
c0105715:	0f b6 c0             	movzbl %al,%eax
c0105718:	29 c2                	sub    %eax,%edx
c010571a:	89 d0                	mov    %edx,%eax
c010571c:	eb 05                	jmp    c0105723 <strncmp+0x51>
c010571e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105723:	5d                   	pop    %ebp
c0105724:	c3                   	ret    

c0105725 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105725:	55                   	push   %ebp
c0105726:	89 e5                	mov    %esp,%ebp
c0105728:	83 ec 04             	sub    $0x4,%esp
c010572b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010572e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105731:	eb 13                	jmp    c0105746 <strchr+0x21>
        if (*s == c) {
c0105733:	8b 45 08             	mov    0x8(%ebp),%eax
c0105736:	0f b6 00             	movzbl (%eax),%eax
c0105739:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010573c:	75 05                	jne    c0105743 <strchr+0x1e>
            return (char *)s;
c010573e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105741:	eb 12                	jmp    c0105755 <strchr+0x30>
        }
        s ++;
c0105743:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105746:	8b 45 08             	mov    0x8(%ebp),%eax
c0105749:	0f b6 00             	movzbl (%eax),%eax
c010574c:	84 c0                	test   %al,%al
c010574e:	75 e3                	jne    c0105733 <strchr+0xe>
    }
    return NULL;
c0105750:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105755:	c9                   	leave  
c0105756:	c3                   	ret    

c0105757 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105757:	55                   	push   %ebp
c0105758:	89 e5                	mov    %esp,%ebp
c010575a:	83 ec 04             	sub    $0x4,%esp
c010575d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105760:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105763:	eb 0e                	jmp    c0105773 <strfind+0x1c>
        if (*s == c) {
c0105765:	8b 45 08             	mov    0x8(%ebp),%eax
c0105768:	0f b6 00             	movzbl (%eax),%eax
c010576b:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010576e:	74 0f                	je     c010577f <strfind+0x28>
            break;
        }
        s ++;
c0105770:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105773:	8b 45 08             	mov    0x8(%ebp),%eax
c0105776:	0f b6 00             	movzbl (%eax),%eax
c0105779:	84 c0                	test   %al,%al
c010577b:	75 e8                	jne    c0105765 <strfind+0xe>
c010577d:	eb 01                	jmp    c0105780 <strfind+0x29>
            break;
c010577f:	90                   	nop
    }
    return (char *)s;
c0105780:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105783:	c9                   	leave  
c0105784:	c3                   	ret    

c0105785 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105785:	55                   	push   %ebp
c0105786:	89 e5                	mov    %esp,%ebp
c0105788:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010578b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105792:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105799:	eb 03                	jmp    c010579e <strtol+0x19>
        s ++;
c010579b:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010579e:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a1:	0f b6 00             	movzbl (%eax),%eax
c01057a4:	3c 20                	cmp    $0x20,%al
c01057a6:	74 f3                	je     c010579b <strtol+0x16>
c01057a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ab:	0f b6 00             	movzbl (%eax),%eax
c01057ae:	3c 09                	cmp    $0x9,%al
c01057b0:	74 e9                	je     c010579b <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c01057b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b5:	0f b6 00             	movzbl (%eax),%eax
c01057b8:	3c 2b                	cmp    $0x2b,%al
c01057ba:	75 05                	jne    c01057c1 <strtol+0x3c>
        s ++;
c01057bc:	ff 45 08             	incl   0x8(%ebp)
c01057bf:	eb 14                	jmp    c01057d5 <strtol+0x50>
    }
    else if (*s == '-') {
c01057c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c4:	0f b6 00             	movzbl (%eax),%eax
c01057c7:	3c 2d                	cmp    $0x2d,%al
c01057c9:	75 0a                	jne    c01057d5 <strtol+0x50>
        s ++, neg = 1;
c01057cb:	ff 45 08             	incl   0x8(%ebp)
c01057ce:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01057d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057d9:	74 06                	je     c01057e1 <strtol+0x5c>
c01057db:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01057df:	75 22                	jne    c0105803 <strtol+0x7e>
c01057e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e4:	0f b6 00             	movzbl (%eax),%eax
c01057e7:	3c 30                	cmp    $0x30,%al
c01057e9:	75 18                	jne    c0105803 <strtol+0x7e>
c01057eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ee:	40                   	inc    %eax
c01057ef:	0f b6 00             	movzbl (%eax),%eax
c01057f2:	3c 78                	cmp    $0x78,%al
c01057f4:	75 0d                	jne    c0105803 <strtol+0x7e>
        s += 2, base = 16;
c01057f6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01057fa:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105801:	eb 29                	jmp    c010582c <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105803:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105807:	75 16                	jne    c010581f <strtol+0x9a>
c0105809:	8b 45 08             	mov    0x8(%ebp),%eax
c010580c:	0f b6 00             	movzbl (%eax),%eax
c010580f:	3c 30                	cmp    $0x30,%al
c0105811:	75 0c                	jne    c010581f <strtol+0x9a>
        s ++, base = 8;
c0105813:	ff 45 08             	incl   0x8(%ebp)
c0105816:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010581d:	eb 0d                	jmp    c010582c <strtol+0xa7>
    }
    else if (base == 0) {
c010581f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105823:	75 07                	jne    c010582c <strtol+0xa7>
        base = 10;
c0105825:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010582c:	8b 45 08             	mov    0x8(%ebp),%eax
c010582f:	0f b6 00             	movzbl (%eax),%eax
c0105832:	3c 2f                	cmp    $0x2f,%al
c0105834:	7e 1b                	jle    c0105851 <strtol+0xcc>
c0105836:	8b 45 08             	mov    0x8(%ebp),%eax
c0105839:	0f b6 00             	movzbl (%eax),%eax
c010583c:	3c 39                	cmp    $0x39,%al
c010583e:	7f 11                	jg     c0105851 <strtol+0xcc>
            dig = *s - '0';
c0105840:	8b 45 08             	mov    0x8(%ebp),%eax
c0105843:	0f b6 00             	movzbl (%eax),%eax
c0105846:	0f be c0             	movsbl %al,%eax
c0105849:	83 e8 30             	sub    $0x30,%eax
c010584c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010584f:	eb 48                	jmp    c0105899 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105851:	8b 45 08             	mov    0x8(%ebp),%eax
c0105854:	0f b6 00             	movzbl (%eax),%eax
c0105857:	3c 60                	cmp    $0x60,%al
c0105859:	7e 1b                	jle    c0105876 <strtol+0xf1>
c010585b:	8b 45 08             	mov    0x8(%ebp),%eax
c010585e:	0f b6 00             	movzbl (%eax),%eax
c0105861:	3c 7a                	cmp    $0x7a,%al
c0105863:	7f 11                	jg     c0105876 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105865:	8b 45 08             	mov    0x8(%ebp),%eax
c0105868:	0f b6 00             	movzbl (%eax),%eax
c010586b:	0f be c0             	movsbl %al,%eax
c010586e:	83 e8 57             	sub    $0x57,%eax
c0105871:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105874:	eb 23                	jmp    c0105899 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105876:	8b 45 08             	mov    0x8(%ebp),%eax
c0105879:	0f b6 00             	movzbl (%eax),%eax
c010587c:	3c 40                	cmp    $0x40,%al
c010587e:	7e 3b                	jle    c01058bb <strtol+0x136>
c0105880:	8b 45 08             	mov    0x8(%ebp),%eax
c0105883:	0f b6 00             	movzbl (%eax),%eax
c0105886:	3c 5a                	cmp    $0x5a,%al
c0105888:	7f 31                	jg     c01058bb <strtol+0x136>
            dig = *s - 'A' + 10;
c010588a:	8b 45 08             	mov    0x8(%ebp),%eax
c010588d:	0f b6 00             	movzbl (%eax),%eax
c0105890:	0f be c0             	movsbl %al,%eax
c0105893:	83 e8 37             	sub    $0x37,%eax
c0105896:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105899:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010589c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010589f:	7d 19                	jge    c01058ba <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01058a1:	ff 45 08             	incl   0x8(%ebp)
c01058a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058a7:	0f af 45 10          	imul   0x10(%ebp),%eax
c01058ab:	89 c2                	mov    %eax,%edx
c01058ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058b0:	01 d0                	add    %edx,%eax
c01058b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01058b5:	e9 72 ff ff ff       	jmp    c010582c <strtol+0xa7>
            break;
c01058ba:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01058bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01058bf:	74 08                	je     c01058c9 <strtol+0x144>
        *endptr = (char *) s;
c01058c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01058c7:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01058c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01058cd:	74 07                	je     c01058d6 <strtol+0x151>
c01058cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01058d2:	f7 d8                	neg    %eax
c01058d4:	eb 03                	jmp    c01058d9 <strtol+0x154>
c01058d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01058d9:	c9                   	leave  
c01058da:	c3                   	ret    

c01058db <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01058db:	55                   	push   %ebp
c01058dc:	89 e5                	mov    %esp,%ebp
c01058de:	57                   	push   %edi
c01058df:	83 ec 24             	sub    $0x24,%esp
c01058e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01058e8:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01058ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01058ef:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01058f2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01058f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01058f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01058fb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01058fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105902:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105905:	89 d7                	mov    %edx,%edi
c0105907:	f3 aa                	rep stos %al,%es:(%edi)
c0105909:	89 fa                	mov    %edi,%edx
c010590b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010590e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105911:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105914:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105915:	83 c4 24             	add    $0x24,%esp
c0105918:	5f                   	pop    %edi
c0105919:	5d                   	pop    %ebp
c010591a:	c3                   	ret    

c010591b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010591b:	55                   	push   %ebp
c010591c:	89 e5                	mov    %esp,%ebp
c010591e:	57                   	push   %edi
c010591f:	56                   	push   %esi
c0105920:	53                   	push   %ebx
c0105921:	83 ec 30             	sub    $0x30,%esp
c0105924:	8b 45 08             	mov    0x8(%ebp),%eax
c0105927:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010592a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105930:	8b 45 10             	mov    0x10(%ebp),%eax
c0105933:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105936:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105939:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010593c:	73 42                	jae    c0105980 <memmove+0x65>
c010593e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105941:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105944:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105947:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010594a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010594d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105950:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105953:	c1 e8 02             	shr    $0x2,%eax
c0105956:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105958:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010595b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010595e:	89 d7                	mov    %edx,%edi
c0105960:	89 c6                	mov    %eax,%esi
c0105962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105964:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105967:	83 e1 03             	and    $0x3,%ecx
c010596a:	74 02                	je     c010596e <memmove+0x53>
c010596c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010596e:	89 f0                	mov    %esi,%eax
c0105970:	89 fa                	mov    %edi,%edx
c0105972:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105975:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105978:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010597b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010597e:	eb 36                	jmp    c01059b6 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105980:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105983:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105986:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105989:	01 c2                	add    %eax,%edx
c010598b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010598e:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105991:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105994:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105997:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010599a:	89 c1                	mov    %eax,%ecx
c010599c:	89 d8                	mov    %ebx,%eax
c010599e:	89 d6                	mov    %edx,%esi
c01059a0:	89 c7                	mov    %eax,%edi
c01059a2:	fd                   	std    
c01059a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01059a5:	fc                   	cld    
c01059a6:	89 f8                	mov    %edi,%eax
c01059a8:	89 f2                	mov    %esi,%edx
c01059aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01059ad:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01059b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01059b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01059b6:	83 c4 30             	add    $0x30,%esp
c01059b9:	5b                   	pop    %ebx
c01059ba:	5e                   	pop    %esi
c01059bb:	5f                   	pop    %edi
c01059bc:	5d                   	pop    %ebp
c01059bd:	c3                   	ret    

c01059be <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01059be:	55                   	push   %ebp
c01059bf:	89 e5                	mov    %esp,%ebp
c01059c1:	57                   	push   %edi
c01059c2:	56                   	push   %esi
c01059c3:	83 ec 20             	sub    $0x20,%esp
c01059c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01059d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01059d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059db:	c1 e8 02             	shr    $0x2,%eax
c01059de:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01059e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059e6:	89 d7                	mov    %edx,%edi
c01059e8:	89 c6                	mov    %eax,%esi
c01059ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01059ec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01059ef:	83 e1 03             	and    $0x3,%ecx
c01059f2:	74 02                	je     c01059f6 <memcpy+0x38>
c01059f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01059f6:	89 f0                	mov    %esi,%eax
c01059f8:	89 fa                	mov    %edi,%edx
c01059fa:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01059fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105a00:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105a06:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105a07:	83 c4 20             	add    $0x20,%esp
c0105a0a:	5e                   	pop    %esi
c0105a0b:	5f                   	pop    %edi
c0105a0c:	5d                   	pop    %ebp
c0105a0d:	c3                   	ret    

c0105a0e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105a0e:	55                   	push   %ebp
c0105a0f:	89 e5                	mov    %esp,%ebp
c0105a11:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a17:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105a20:	eb 2e                	jmp    c0105a50 <memcmp+0x42>
        if (*s1 != *s2) {
c0105a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a25:	0f b6 10             	movzbl (%eax),%edx
c0105a28:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a2b:	0f b6 00             	movzbl (%eax),%eax
c0105a2e:	38 c2                	cmp    %al,%dl
c0105a30:	74 18                	je     c0105a4a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a35:	0f b6 00             	movzbl (%eax),%eax
c0105a38:	0f b6 d0             	movzbl %al,%edx
c0105a3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105a3e:	0f b6 00             	movzbl (%eax),%eax
c0105a41:	0f b6 c0             	movzbl %al,%eax
c0105a44:	29 c2                	sub    %eax,%edx
c0105a46:	89 d0                	mov    %edx,%eax
c0105a48:	eb 18                	jmp    c0105a62 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105a4a:	ff 45 fc             	incl   -0x4(%ebp)
c0105a4d:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105a50:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a53:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a56:	89 55 10             	mov    %edx,0x10(%ebp)
c0105a59:	85 c0                	test   %eax,%eax
c0105a5b:	75 c5                	jne    c0105a22 <memcmp+0x14>
    }
    return 0;
c0105a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a62:	c9                   	leave  
c0105a63:	c3                   	ret    

c0105a64 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105a64:	55                   	push   %ebp
c0105a65:	89 e5                	mov    %esp,%ebp
c0105a67:	83 ec 58             	sub    $0x58,%esp
c0105a6a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105a70:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105a76:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105a79:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105a7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a7f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105a82:	8b 45 18             	mov    0x18(%ebp),%eax
c0105a85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105a91:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a97:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a9e:	74 1c                	je     c0105abc <printnum+0x58>
c0105aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aa3:	ba 00 00 00 00       	mov    $0x0,%edx
c0105aa8:	f7 75 e4             	divl   -0x1c(%ebp)
c0105aab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ab1:	ba 00 00 00 00       	mov    $0x0,%edx
c0105ab6:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105abf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ac2:	f7 75 e4             	divl   -0x1c(%ebp)
c0105ac5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ac8:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ad1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ad4:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105ad7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ada:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105add:	8b 45 18             	mov    0x18(%ebp),%eax
c0105ae0:	ba 00 00 00 00       	mov    $0x0,%edx
c0105ae5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105ae8:	72 56                	jb     c0105b40 <printnum+0xdc>
c0105aea:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
c0105aed:	77 05                	ja     c0105af4 <printnum+0x90>
c0105aef:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105af2:	72 4c                	jb     c0105b40 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105af4:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105af7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105afa:	8b 45 20             	mov    0x20(%ebp),%eax
c0105afd:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105b01:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105b05:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b08:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105b0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b0f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b12:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b16:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b21:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b24:	89 04 24             	mov    %eax,(%esp)
c0105b27:	e8 38 ff ff ff       	call   c0105a64 <printnum>
c0105b2c:	eb 1b                	jmp    c0105b49 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b35:	8b 45 20             	mov    0x20(%ebp),%eax
c0105b38:	89 04 24             	mov    %eax,(%esp)
c0105b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3e:	ff d0                	call   *%eax
        while (-- width > 0)
c0105b40:	ff 4d 1c             	decl   0x1c(%ebp)
c0105b43:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105b47:	7f e5                	jg     c0105b2e <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105b49:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105b4c:	05 6c 72 10 c0       	add    $0xc010726c,%eax
c0105b51:	0f b6 00             	movzbl (%eax),%eax
c0105b54:	0f be c0             	movsbl %al,%eax
c0105b57:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b5e:	89 04 24             	mov    %eax,(%esp)
c0105b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b64:	ff d0                	call   *%eax
}
c0105b66:	90                   	nop
c0105b67:	c9                   	leave  
c0105b68:	c3                   	ret    

c0105b69 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105b69:	55                   	push   %ebp
c0105b6a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105b6c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105b70:	7e 14                	jle    c0105b86 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b75:	8b 00                	mov    (%eax),%eax
c0105b77:	8d 48 08             	lea    0x8(%eax),%ecx
c0105b7a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b7d:	89 0a                	mov    %ecx,(%edx)
c0105b7f:	8b 50 04             	mov    0x4(%eax),%edx
c0105b82:	8b 00                	mov    (%eax),%eax
c0105b84:	eb 30                	jmp    c0105bb6 <getuint+0x4d>
    }
    else if (lflag) {
c0105b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b8a:	74 16                	je     c0105ba2 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8f:	8b 00                	mov    (%eax),%eax
c0105b91:	8d 48 04             	lea    0x4(%eax),%ecx
c0105b94:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b97:	89 0a                	mov    %ecx,(%edx)
c0105b99:	8b 00                	mov    (%eax),%eax
c0105b9b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105ba0:	eb 14                	jmp    c0105bb6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105ba2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba5:	8b 00                	mov    (%eax),%eax
c0105ba7:	8d 48 04             	lea    0x4(%eax),%ecx
c0105baa:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bad:	89 0a                	mov    %ecx,(%edx)
c0105baf:	8b 00                	mov    (%eax),%eax
c0105bb1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105bb6:	5d                   	pop    %ebp
c0105bb7:	c3                   	ret    

c0105bb8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105bb8:	55                   	push   %ebp
c0105bb9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105bbb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105bbf:	7e 14                	jle    c0105bd5 <getint+0x1d>
        return va_arg(*ap, long long);
c0105bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc4:	8b 00                	mov    (%eax),%eax
c0105bc6:	8d 48 08             	lea    0x8(%eax),%ecx
c0105bc9:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bcc:	89 0a                	mov    %ecx,(%edx)
c0105bce:	8b 50 04             	mov    0x4(%eax),%edx
c0105bd1:	8b 00                	mov    (%eax),%eax
c0105bd3:	eb 28                	jmp    c0105bfd <getint+0x45>
    }
    else if (lflag) {
c0105bd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105bd9:	74 12                	je     c0105bed <getint+0x35>
        return va_arg(*ap, long);
c0105bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bde:	8b 00                	mov    (%eax),%eax
c0105be0:	8d 48 04             	lea    0x4(%eax),%ecx
c0105be3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105be6:	89 0a                	mov    %ecx,(%edx)
c0105be8:	8b 00                	mov    (%eax),%eax
c0105bea:	99                   	cltd   
c0105beb:	eb 10                	jmp    c0105bfd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf0:	8b 00                	mov    (%eax),%eax
c0105bf2:	8d 48 04             	lea    0x4(%eax),%ecx
c0105bf5:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bf8:	89 0a                	mov    %ecx,(%edx)
c0105bfa:	8b 00                	mov    (%eax),%eax
c0105bfc:	99                   	cltd   
    }
}
c0105bfd:	5d                   	pop    %ebp
c0105bfe:	c3                   	ret    

c0105bff <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105bff:	55                   	push   %ebp
c0105c00:	89 e5                	mov    %esp,%ebp
c0105c02:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105c05:	8d 45 14             	lea    0x14(%ebp),%eax
c0105c08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c12:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c15:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c23:	89 04 24             	mov    %eax,(%esp)
c0105c26:	e8 03 00 00 00       	call   c0105c2e <vprintfmt>
    va_end(ap);
}
c0105c2b:	90                   	nop
c0105c2c:	c9                   	leave  
c0105c2d:	c3                   	ret    

c0105c2e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105c2e:	55                   	push   %ebp
c0105c2f:	89 e5                	mov    %esp,%ebp
c0105c31:	56                   	push   %esi
c0105c32:	53                   	push   %ebx
c0105c33:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c36:	eb 17                	jmp    c0105c4f <vprintfmt+0x21>
            if (ch == '\0') {
c0105c38:	85 db                	test   %ebx,%ebx
c0105c3a:	0f 84 bf 03 00 00    	je     c0105fff <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105c40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c47:	89 1c 24             	mov    %ebx,(%esp)
c0105c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c4d:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105c4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c52:	8d 50 01             	lea    0x1(%eax),%edx
c0105c55:	89 55 10             	mov    %edx,0x10(%ebp)
c0105c58:	0f b6 00             	movzbl (%eax),%eax
c0105c5b:	0f b6 d8             	movzbl %al,%ebx
c0105c5e:	83 fb 25             	cmp    $0x25,%ebx
c0105c61:	75 d5                	jne    c0105c38 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105c63:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105c67:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c71:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105c74:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105c7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c7e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105c81:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c84:	8d 50 01             	lea    0x1(%eax),%edx
c0105c87:	89 55 10             	mov    %edx,0x10(%ebp)
c0105c8a:	0f b6 00             	movzbl (%eax),%eax
c0105c8d:	0f b6 d8             	movzbl %al,%ebx
c0105c90:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105c93:	83 f8 55             	cmp    $0x55,%eax
c0105c96:	0f 87 37 03 00 00    	ja     c0105fd3 <vprintfmt+0x3a5>
c0105c9c:	8b 04 85 90 72 10 c0 	mov    -0x3fef8d70(,%eax,4),%eax
c0105ca3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105ca5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105ca9:	eb d6                	jmp    c0105c81 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105cab:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105caf:	eb d0                	jmp    c0105c81 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105cb1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105cb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cbb:	89 d0                	mov    %edx,%eax
c0105cbd:	c1 e0 02             	shl    $0x2,%eax
c0105cc0:	01 d0                	add    %edx,%eax
c0105cc2:	01 c0                	add    %eax,%eax
c0105cc4:	01 d8                	add    %ebx,%eax
c0105cc6:	83 e8 30             	sub    $0x30,%eax
c0105cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105ccc:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ccf:	0f b6 00             	movzbl (%eax),%eax
c0105cd2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105cd5:	83 fb 2f             	cmp    $0x2f,%ebx
c0105cd8:	7e 38                	jle    c0105d12 <vprintfmt+0xe4>
c0105cda:	83 fb 39             	cmp    $0x39,%ebx
c0105cdd:	7f 33                	jg     c0105d12 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0105cdf:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105ce2:	eb d4                	jmp    c0105cb8 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105ce4:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ce7:	8d 50 04             	lea    0x4(%eax),%edx
c0105cea:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ced:	8b 00                	mov    (%eax),%eax
c0105cef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105cf2:	eb 1f                	jmp    c0105d13 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105cf4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105cf8:	79 87                	jns    c0105c81 <vprintfmt+0x53>
                width = 0;
c0105cfa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105d01:	e9 7b ff ff ff       	jmp    c0105c81 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105d06:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105d0d:	e9 6f ff ff ff       	jmp    c0105c81 <vprintfmt+0x53>
            goto process_precision;
c0105d12:	90                   	nop

        process_precision:
            if (width < 0)
c0105d13:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105d17:	0f 89 64 ff ff ff    	jns    c0105c81 <vprintfmt+0x53>
                width = precision, precision = -1;
c0105d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d20:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d23:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105d2a:	e9 52 ff ff ff       	jmp    c0105c81 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105d2f:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105d32:	e9 4a ff ff ff       	jmp    c0105c81 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105d37:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d3a:	8d 50 04             	lea    0x4(%eax),%edx
c0105d3d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d40:	8b 00                	mov    (%eax),%eax
c0105d42:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d45:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d49:	89 04 24             	mov    %eax,(%esp)
c0105d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4f:	ff d0                	call   *%eax
            break;
c0105d51:	e9 a4 02 00 00       	jmp    c0105ffa <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105d56:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d59:	8d 50 04             	lea    0x4(%eax),%edx
c0105d5c:	89 55 14             	mov    %edx,0x14(%ebp)
c0105d5f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105d61:	85 db                	test   %ebx,%ebx
c0105d63:	79 02                	jns    c0105d67 <vprintfmt+0x139>
                err = -err;
c0105d65:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105d67:	83 fb 06             	cmp    $0x6,%ebx
c0105d6a:	7f 0b                	jg     c0105d77 <vprintfmt+0x149>
c0105d6c:	8b 34 9d 50 72 10 c0 	mov    -0x3fef8db0(,%ebx,4),%esi
c0105d73:	85 f6                	test   %esi,%esi
c0105d75:	75 23                	jne    c0105d9a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0105d77:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105d7b:	c7 44 24 08 7d 72 10 	movl   $0xc010727d,0x8(%esp)
c0105d82:	c0 
c0105d83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8d:	89 04 24             	mov    %eax,(%esp)
c0105d90:	e8 6a fe ff ff       	call   c0105bff <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105d95:	e9 60 02 00 00       	jmp    c0105ffa <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105d9a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105d9e:	c7 44 24 08 86 72 10 	movl   $0xc0107286,0x8(%esp)
c0105da5:	c0 
c0105da6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105da9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db0:	89 04 24             	mov    %eax,(%esp)
c0105db3:	e8 47 fe ff ff       	call   c0105bff <printfmt>
            break;
c0105db8:	e9 3d 02 00 00       	jmp    c0105ffa <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105dbd:	8b 45 14             	mov    0x14(%ebp),%eax
c0105dc0:	8d 50 04             	lea    0x4(%eax),%edx
c0105dc3:	89 55 14             	mov    %edx,0x14(%ebp)
c0105dc6:	8b 30                	mov    (%eax),%esi
c0105dc8:	85 f6                	test   %esi,%esi
c0105dca:	75 05                	jne    c0105dd1 <vprintfmt+0x1a3>
                p = "(null)";
c0105dcc:	be 89 72 10 c0       	mov    $0xc0107289,%esi
            }
            if (width > 0 && padc != '-') {
c0105dd1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105dd5:	7e 76                	jle    c0105e4d <vprintfmt+0x21f>
c0105dd7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105ddb:	74 70                	je     c0105e4d <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105de0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105de4:	89 34 24             	mov    %esi,(%esp)
c0105de7:	e8 f6 f7 ff ff       	call   c01055e2 <strnlen>
c0105dec:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105def:	29 c2                	sub    %eax,%edx
c0105df1:	89 d0                	mov    %edx,%eax
c0105df3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105df6:	eb 16                	jmp    c0105e0e <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105df8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105dff:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e03:	89 04 24             	mov    %eax,(%esp)
c0105e06:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e09:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105e0b:	ff 4d e8             	decl   -0x18(%ebp)
c0105e0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e12:	7f e4                	jg     c0105df8 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e14:	eb 37                	jmp    c0105e4d <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105e16:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e1a:	74 1f                	je     c0105e3b <vprintfmt+0x20d>
c0105e1c:	83 fb 1f             	cmp    $0x1f,%ebx
c0105e1f:	7e 05                	jle    c0105e26 <vprintfmt+0x1f8>
c0105e21:	83 fb 7e             	cmp    $0x7e,%ebx
c0105e24:	7e 15                	jle    c0105e3b <vprintfmt+0x20d>
                    putch('?', putdat);
c0105e26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e2d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105e34:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e37:	ff d0                	call   *%eax
c0105e39:	eb 0f                	jmp    c0105e4a <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e42:	89 1c 24             	mov    %ebx,(%esp)
c0105e45:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e48:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105e4a:	ff 4d e8             	decl   -0x18(%ebp)
c0105e4d:	89 f0                	mov    %esi,%eax
c0105e4f:	8d 70 01             	lea    0x1(%eax),%esi
c0105e52:	0f b6 00             	movzbl (%eax),%eax
c0105e55:	0f be d8             	movsbl %al,%ebx
c0105e58:	85 db                	test   %ebx,%ebx
c0105e5a:	74 27                	je     c0105e83 <vprintfmt+0x255>
c0105e5c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e60:	78 b4                	js     c0105e16 <vprintfmt+0x1e8>
c0105e62:	ff 4d e4             	decl   -0x1c(%ebp)
c0105e65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e69:	79 ab                	jns    c0105e16 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105e6b:	eb 16                	jmp    c0105e83 <vprintfmt+0x255>
                putch(' ', putdat);
c0105e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e74:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105e7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e7e:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105e80:	ff 4d e8             	decl   -0x18(%ebp)
c0105e83:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e87:	7f e4                	jg     c0105e6d <vprintfmt+0x23f>
            }
            break;
c0105e89:	e9 6c 01 00 00       	jmp    c0105ffa <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105e8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e95:	8d 45 14             	lea    0x14(%ebp),%eax
c0105e98:	89 04 24             	mov    %eax,(%esp)
c0105e9b:	e8 18 fd ff ff       	call   c0105bb8 <getint>
c0105ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ea3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105eac:	85 d2                	test   %edx,%edx
c0105eae:	79 26                	jns    c0105ed6 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eb7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec1:	ff d0                	call   *%eax
                num = -(long long)num;
c0105ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ec6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ec9:	f7 d8                	neg    %eax
c0105ecb:	83 d2 00             	adc    $0x0,%edx
c0105ece:	f7 da                	neg    %edx
c0105ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ed3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105ed6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105edd:	e9 a8 00 00 00       	jmp    c0105f8a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105ee2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ee9:	8d 45 14             	lea    0x14(%ebp),%eax
c0105eec:	89 04 24             	mov    %eax,(%esp)
c0105eef:	e8 75 fc ff ff       	call   c0105b69 <getuint>
c0105ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ef7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105efa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105f01:	e9 84 00 00 00       	jmp    c0105f8a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f0d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f10:	89 04 24             	mov    %eax,(%esp)
c0105f13:	e8 51 fc ff ff       	call   c0105b69 <getuint>
c0105f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f1b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105f1e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105f25:	eb 63                	jmp    c0105f8a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105f27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f2e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f38:	ff d0                	call   *%eax
            putch('x', putdat);
c0105f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f41:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4b:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105f4d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f50:	8d 50 04             	lea    0x4(%eax),%edx
c0105f53:	89 55 14             	mov    %edx,0x14(%ebp)
c0105f56:	8b 00                	mov    (%eax),%eax
c0105f58:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105f62:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105f69:	eb 1f                	jmp    c0105f8a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f72:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f75:	89 04 24             	mov    %eax,(%esp)
c0105f78:	e8 ec fb ff ff       	call   c0105b69 <getuint>
c0105f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f80:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105f83:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105f8a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f91:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105f95:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105f98:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105f9c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fa6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105faa:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105fae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb8:	89 04 24             	mov    %eax,(%esp)
c0105fbb:	e8 a4 fa ff ff       	call   c0105a64 <printnum>
            break;
c0105fc0:	eb 38                	jmp    c0105ffa <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fc9:	89 1c 24             	mov    %ebx,(%esp)
c0105fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fcf:	ff d0                	call   *%eax
            break;
c0105fd1:	eb 27                	jmp    c0105ffa <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fda:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105fe1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe4:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105fe6:	ff 4d 10             	decl   0x10(%ebp)
c0105fe9:	eb 03                	jmp    c0105fee <vprintfmt+0x3c0>
c0105feb:	ff 4d 10             	decl   0x10(%ebp)
c0105fee:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ff1:	48                   	dec    %eax
c0105ff2:	0f b6 00             	movzbl (%eax),%eax
c0105ff5:	3c 25                	cmp    $0x25,%al
c0105ff7:	75 f2                	jne    c0105feb <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105ff9:	90                   	nop
    while (1) {
c0105ffa:	e9 37 fc ff ff       	jmp    c0105c36 <vprintfmt+0x8>
                return;
c0105fff:	90                   	nop
        }
    }
}
c0106000:	83 c4 40             	add    $0x40,%esp
c0106003:	5b                   	pop    %ebx
c0106004:	5e                   	pop    %esi
c0106005:	5d                   	pop    %ebp
c0106006:	c3                   	ret    

c0106007 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106007:	55                   	push   %ebp
c0106008:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010600a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010600d:	8b 40 08             	mov    0x8(%eax),%eax
c0106010:	8d 50 01             	lea    0x1(%eax),%edx
c0106013:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106016:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106019:	8b 45 0c             	mov    0xc(%ebp),%eax
c010601c:	8b 10                	mov    (%eax),%edx
c010601e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106021:	8b 40 04             	mov    0x4(%eax),%eax
c0106024:	39 c2                	cmp    %eax,%edx
c0106026:	73 12                	jae    c010603a <sprintputch+0x33>
        *b->buf ++ = ch;
c0106028:	8b 45 0c             	mov    0xc(%ebp),%eax
c010602b:	8b 00                	mov    (%eax),%eax
c010602d:	8d 48 01             	lea    0x1(%eax),%ecx
c0106030:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106033:	89 0a                	mov    %ecx,(%edx)
c0106035:	8b 55 08             	mov    0x8(%ebp),%edx
c0106038:	88 10                	mov    %dl,(%eax)
    }
}
c010603a:	90                   	nop
c010603b:	5d                   	pop    %ebp
c010603c:	c3                   	ret    

c010603d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010603d:	55                   	push   %ebp
c010603e:	89 e5                	mov    %esp,%ebp
c0106040:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106043:	8d 45 14             	lea    0x14(%ebp),%eax
c0106046:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106049:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010604c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106050:	8b 45 10             	mov    0x10(%ebp),%eax
c0106053:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106057:	8b 45 0c             	mov    0xc(%ebp),%eax
c010605a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010605e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106061:	89 04 24             	mov    %eax,(%esp)
c0106064:	e8 08 00 00 00       	call   c0106071 <vsnprintf>
c0106069:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010606c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010606f:	c9                   	leave  
c0106070:	c3                   	ret    

c0106071 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106071:	55                   	push   %ebp
c0106072:	89 e5                	mov    %esp,%ebp
c0106074:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106077:	8b 45 08             	mov    0x8(%ebp),%eax
c010607a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010607d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106080:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106083:	8b 45 08             	mov    0x8(%ebp),%eax
c0106086:	01 d0                	add    %edx,%eax
c0106088:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010608b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106092:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106096:	74 0a                	je     c01060a2 <vsnprintf+0x31>
c0106098:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010609e:	39 c2                	cmp    %eax,%edx
c01060a0:	76 07                	jbe    c01060a9 <vsnprintf+0x38>
        return -E_INVAL;
c01060a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01060a7:	eb 2a                	jmp    c01060d3 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01060a9:	8b 45 14             	mov    0x14(%ebp),%eax
c01060ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01060b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01060ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060be:	c7 04 24 07 60 10 c0 	movl   $0xc0106007,(%esp)
c01060c5:	e8 64 fb ff ff       	call   c0105c2e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01060ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060cd:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01060d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060d3:	c9                   	leave  
c01060d4:	c3                   	ret    
