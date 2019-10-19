
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 9b 2d 00 00       	call   102dc7 <memset>

    cons_init();                // init the console
  10002c:	e8 65 15 00 00       	call   101596 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 e0 35 10 00 	movl   $0x1035e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 fc 35 10 00 	movl   $0x1035fc,(%esp)
  100046:	e8 21 02 00 00       	call   10026c <cprintf>

    print_kerninfo();
  10004b:	e8 c2 08 00 00       	call   100912 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8e 00 00 00       	call   1000e3 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 42 2a 00 00       	call   102a9c <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 76 16 00 00       	call   1016d5 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 d6 17 00 00       	call   10183a <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 0e 0d 00 00       	call   100d77 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 a1 17 00 00       	call   10180f <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6b 01 00 00       	call   1001de <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 ce 0c 00 00       	call   100d65 <mon_backtrace>
}
  100097:	90                   	nop
  100098:	c9                   	leave  
  100099:	c3                   	ret    

0010009a <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10009a:	55                   	push   %ebp
  10009b:	89 e5                	mov    %esp,%ebp
  10009d:	53                   	push   %ebx
  10009e:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a7:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b9:	89 04 24             	mov    %eax,(%esp)
  1000bc:	e8 b4 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c1:	90                   	nop
  1000c2:	83 c4 14             	add    $0x14,%esp
  1000c5:	5b                   	pop    %ebx
  1000c6:	5d                   	pop    %ebp
  1000c7:	c3                   	ret    

001000c8 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c8:	55                   	push   %ebp
  1000c9:	89 e5                	mov    %esp,%ebp
  1000cb:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d8:	89 04 24             	mov    %eax,(%esp)
  1000db:	e8 ba ff ff ff       	call   10009a <grade_backtrace1>
}
  1000e0:	90                   	nop
  1000e1:	c9                   	leave  
  1000e2:	c3                   	ret    

001000e3 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e3:	55                   	push   %ebp
  1000e4:	89 e5                	mov    %esp,%ebp
  1000e6:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e9:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000ee:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f5:	ff 
  1000f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100101:	e8 c2 ff ff ff       	call   1000c8 <grade_backtrace0>
}
  100106:	90                   	nop
  100107:	c9                   	leave  
  100108:	c3                   	ret    

00100109 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100109:	55                   	push   %ebp
  10010a:	89 e5                	mov    %esp,%ebp
  10010c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100112:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100115:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100118:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10011b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011f:	83 e0 03             	and    $0x3,%eax
  100122:	89 c2                	mov    %eax,%edx
  100124:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100129:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100131:	c7 04 24 01 36 10 00 	movl   $0x103601,(%esp)
  100138:	e8 2f 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100141:	89 c2                	mov    %eax,%edx
  100143:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 0f 36 10 00 	movl   $0x10360f,(%esp)
  100157:	e8 10 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	89 c2                	mov    %eax,%edx
  100162:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100167:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016f:	c7 04 24 1d 36 10 00 	movl   $0x10361d,(%esp)
  100176:	e8 f1 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017f:	89 c2                	mov    %eax,%edx
  100181:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100186:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018e:	c7 04 24 2b 36 10 00 	movl   $0x10362b,(%esp)
  100195:	e8 d2 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019e:	89 c2                	mov    %eax,%edx
  1001a0:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ad:	c7 04 24 39 36 10 00 	movl   $0x103639,(%esp)
  1001b4:	e8 b3 00 00 00       	call   10026c <cprintf>
    round ++;
  1001b9:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001be:	40                   	inc    %eax
  1001bf:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c4:	90                   	nop
  1001c5:	c9                   	leave  
  1001c6:	c3                   	ret    

001001c7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c7:	55                   	push   %ebp
  1001c8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  1001ca:	83 ec 08             	sub    $0x8,%esp
  1001cd:	cd 78                	int    $0x78
  1001cf:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        :
        : "i"(T_SWITCH_TOU)
    );
}
  1001d1:	90                   	nop
  1001d2:	5d                   	pop    %ebp
  1001d3:	c3                   	ret    

001001d4 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d4:	55                   	push   %ebp
  1001d5:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  1001d7:	cd 79                	int    $0x79
  1001d9:	89 ec                	mov    %ebp,%esp
    "int %0 \n"
    "movl %%ebp, %%esp \n"
    :
    : "i"(T_SWITCH_TOK)
    );
}
  1001db:	90                   	nop
  1001dc:	5d                   	pop    %ebp
  1001dd:	c3                   	ret    

001001de <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001de:	55                   	push   %ebp
  1001df:	89 e5                	mov    %esp,%ebp
  1001e1:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e4:	e8 20 ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001e9:	c7 04 24 48 36 10 00 	movl   $0x103648,(%esp)
  1001f0:	e8 77 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_user();
  1001f5:	e8 cd ff ff ff       	call   1001c7 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fa:	e8 0a ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001ff:	c7 04 24 68 36 10 00 	movl   $0x103668,(%esp)
  100206:	e8 61 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_kernel();
  10020b:	e8 c4 ff ff ff       	call   1001d4 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100210:	e8 f4 fe ff ff       	call   100109 <lab1_print_cur_status>
}
  100215:	90                   	nop
  100216:	c9                   	leave  
  100217:	c3                   	ret    

00100218 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100218:	55                   	push   %ebp
  100219:	89 e5                	mov    %esp,%ebp
  10021b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10021e:	8b 45 08             	mov    0x8(%ebp),%eax
  100221:	89 04 24             	mov    %eax,(%esp)
  100224:	e8 9a 13 00 00       	call   1015c3 <cons_putc>
    (*cnt) ++;
  100229:	8b 45 0c             	mov    0xc(%ebp),%eax
  10022c:	8b 00                	mov    (%eax),%eax
  10022e:	8d 50 01             	lea    0x1(%eax),%edx
  100231:	8b 45 0c             	mov    0xc(%ebp),%eax
  100234:	89 10                	mov    %edx,(%eax)
}
  100236:	90                   	nop
  100237:	c9                   	leave  
  100238:	c3                   	ret    

00100239 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100239:	55                   	push   %ebp
  10023a:	89 e5                	mov    %esp,%ebp
  10023c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10023f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100246:	8b 45 0c             	mov    0xc(%ebp),%eax
  100249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10024d:	8b 45 08             	mov    0x8(%ebp),%eax
  100250:	89 44 24 08          	mov    %eax,0x8(%esp)
  100254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100257:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025b:	c7 04 24 18 02 10 00 	movl   $0x100218,(%esp)
  100262:	e8 b3 2e 00 00       	call   10311a <vprintfmt>
    return cnt;
  100267:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10026a:	c9                   	leave  
  10026b:	c3                   	ret    

0010026c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10026c:	55                   	push   %ebp
  10026d:	89 e5                	mov    %esp,%ebp
  10026f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100272:	8d 45 0c             	lea    0xc(%ebp),%eax
  100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10027f:	8b 45 08             	mov    0x8(%ebp),%eax
  100282:	89 04 24             	mov    %eax,(%esp)
  100285:	e8 af ff ff ff       	call   100239 <vcprintf>
  10028a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100298:	8b 45 08             	mov    0x8(%ebp),%eax
  10029b:	89 04 24             	mov    %eax,(%esp)
  10029e:	e8 20 13 00 00       	call   1015c3 <cons_putc>
}
  1002a3:	90                   	nop
  1002a4:	c9                   	leave  
  1002a5:	c3                   	ret    

001002a6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002a6:	55                   	push   %ebp
  1002a7:	89 e5                	mov    %esp,%ebp
  1002a9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002b3:	eb 13                	jmp    1002c8 <cputs+0x22>
        cputch(c, &cnt);
  1002b5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002b9:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002c0:	89 04 24             	mov    %eax,(%esp)
  1002c3:	e8 50 ff ff ff       	call   100218 <cputch>
    while ((c = *str ++) != '\0') {
  1002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1002cb:	8d 50 01             	lea    0x1(%eax),%edx
  1002ce:	89 55 08             	mov    %edx,0x8(%ebp)
  1002d1:	0f b6 00             	movzbl (%eax),%eax
  1002d4:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002d7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002db:	75 d8                	jne    1002b5 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1002dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002e4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1002eb:	e8 28 ff ff ff       	call   100218 <cputch>
    return cnt;
  1002f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002fb:	e8 ed 12 00 00       	call   1015ed <cons_getc>
  100300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100303:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100307:	74 f2                	je     1002fb <getchar+0x6>
        /* do nothing */;
    return c;
  100309:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10030c:	c9                   	leave  
  10030d:	c3                   	ret    

0010030e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10030e:	55                   	push   %ebp
  10030f:	89 e5                	mov    %esp,%ebp
  100311:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100314:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100318:	74 13                	je     10032d <readline+0x1f>
        cprintf("%s", prompt);
  10031a:	8b 45 08             	mov    0x8(%ebp),%eax
  10031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100321:	c7 04 24 87 36 10 00 	movl   $0x103687,(%esp)
  100328:	e8 3f ff ff ff       	call   10026c <cprintf>
    }
    int i = 0, c;
  10032d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100334:	e8 bc ff ff ff       	call   1002f5 <getchar>
  100339:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10033c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100340:	79 07                	jns    100349 <readline+0x3b>
            return NULL;
  100342:	b8 00 00 00 00       	mov    $0x0,%eax
  100347:	eb 78                	jmp    1003c1 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100349:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10034d:	7e 28                	jle    100377 <readline+0x69>
  10034f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100356:	7f 1f                	jg     100377 <readline+0x69>
            cputchar(c);
  100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10035b:	89 04 24             	mov    %eax,(%esp)
  10035e:	e8 2f ff ff ff       	call   100292 <cputchar>
            buf[i ++] = c;
  100363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100366:	8d 50 01             	lea    0x1(%eax),%edx
  100369:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10036c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10036f:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100375:	eb 45                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  100377:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10037b:	75 16                	jne    100393 <readline+0x85>
  10037d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100381:	7e 10                	jle    100393 <readline+0x85>
            cputchar(c);
  100383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100386:	89 04 24             	mov    %eax,(%esp)
  100389:	e8 04 ff ff ff       	call   100292 <cputchar>
            i --;
  10038e:	ff 4d f4             	decl   -0xc(%ebp)
  100391:	eb 29                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  100393:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100397:	74 06                	je     10039f <readline+0x91>
  100399:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10039d:	75 95                	jne    100334 <readline+0x26>
            cputchar(c);
  10039f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003a2:	89 04 24             	mov    %eax,(%esp)
  1003a5:	e8 e8 fe ff ff       	call   100292 <cputchar>
            buf[i] = '\0';
  1003aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ad:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003b2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003b5:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003ba:	eb 05                	jmp    1003c1 <readline+0xb3>
        c = getchar();
  1003bc:	e9 73 ff ff ff       	jmp    100334 <readline+0x26>
        }
    }
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003c9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003ce:	85 c0                	test   %eax,%eax
  1003d0:	75 5b                	jne    10042d <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003d2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003d9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003dc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f0:	c7 04 24 8a 36 10 00 	movl   $0x10368a,(%esp)
  1003f7:	e8 70 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  1003fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  100403:	8b 45 10             	mov    0x10(%ebp),%eax
  100406:	89 04 24             	mov    %eax,(%esp)
  100409:	e8 2b fe ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  10040e:	c7 04 24 a6 36 10 00 	movl   $0x1036a6,(%esp)
  100415:	e8 52 fe ff ff       	call   10026c <cprintf>
    
    cprintf("stack trackback:\n");
  10041a:	c7 04 24 a8 36 10 00 	movl   $0x1036a8,(%esp)
  100421:	e8 46 fe ff ff       	call   10026c <cprintf>
    print_stackframe();
  100426:	e8 32 06 00 00       	call   100a5d <print_stackframe>
  10042b:	eb 01                	jmp    10042e <__panic+0x6b>
        goto panic_dead;
  10042d:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  10042e:	e8 e3 13 00 00       	call   101816 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10043a:	e8 59 08 00 00       	call   100c98 <kmonitor>
  10043f:	eb f2                	jmp    100433 <__panic+0x70>

00100441 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100441:	55                   	push   %ebp
  100442:	89 e5                	mov    %esp,%ebp
  100444:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100447:	8d 45 14             	lea    0x14(%ebp),%eax
  10044a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10044d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100450:	89 44 24 08          	mov    %eax,0x8(%esp)
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	89 44 24 04          	mov    %eax,0x4(%esp)
  10045b:	c7 04 24 ba 36 10 00 	movl   $0x1036ba,(%esp)
  100462:	e8 05 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  100467:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10046e:	8b 45 10             	mov    0x10(%ebp),%eax
  100471:	89 04 24             	mov    %eax,(%esp)
  100474:	e8 c0 fd ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  100479:	c7 04 24 a6 36 10 00 	movl   $0x1036a6,(%esp)
  100480:	e8 e7 fd ff ff       	call   10026c <cprintf>
    va_end(ap);
}
  100485:	90                   	nop
  100486:	c9                   	leave  
  100487:	c3                   	ret    

00100488 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100488:	55                   	push   %ebp
  100489:	89 e5                	mov    %esp,%ebp
    return is_panic;
  10048b:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100490:	5d                   	pop    %ebp
  100491:	c3                   	ret    

00100492 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100492:	55                   	push   %ebp
  100493:	89 e5                	mov    %esp,%ebp
  100495:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049b:	8b 00                	mov    (%eax),%eax
  10049d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a3:	8b 00                	mov    (%eax),%eax
  1004a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004af:	e9 ca 00 00 00       	jmp    10057e <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004ba:	01 d0                	add    %edx,%eax
  1004bc:	89 c2                	mov    %eax,%edx
  1004be:	c1 ea 1f             	shr    $0x1f,%edx
  1004c1:	01 d0                	add    %edx,%eax
  1004c3:	d1 f8                	sar    %eax
  1004c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ce:	eb 03                	jmp    1004d3 <stab_binsearch+0x41>
            m --;
  1004d0:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004d9:	7c 1f                	jl     1004fa <stab_binsearch+0x68>
  1004db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004de:	89 d0                	mov    %edx,%eax
  1004e0:	01 c0                	add    %eax,%eax
  1004e2:	01 d0                	add    %edx,%eax
  1004e4:	c1 e0 02             	shl    $0x2,%eax
  1004e7:	89 c2                	mov    %eax,%edx
  1004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ec:	01 d0                	add    %edx,%eax
  1004ee:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004f2:	0f b6 c0             	movzbl %al,%eax
  1004f5:	39 45 14             	cmp    %eax,0x14(%ebp)
  1004f8:	75 d6                	jne    1004d0 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  1004fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100500:	7d 09                	jge    10050b <stab_binsearch+0x79>
            l = true_m + 1;
  100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100505:	40                   	inc    %eax
  100506:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100509:	eb 73                	jmp    10057e <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10050b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100512:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100515:	89 d0                	mov    %edx,%eax
  100517:	01 c0                	add    %eax,%eax
  100519:	01 d0                	add    %edx,%eax
  10051b:	c1 e0 02             	shl    $0x2,%eax
  10051e:	89 c2                	mov    %eax,%edx
  100520:	8b 45 08             	mov    0x8(%ebp),%eax
  100523:	01 d0                	add    %edx,%eax
  100525:	8b 40 08             	mov    0x8(%eax),%eax
  100528:	39 45 18             	cmp    %eax,0x18(%ebp)
  10052b:	76 11                	jbe    10053e <stab_binsearch+0xac>
            *region_left = m;
  10052d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100533:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100538:	40                   	inc    %eax
  100539:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10053c:	eb 40                	jmp    10057e <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  10053e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100541:	89 d0                	mov    %edx,%eax
  100543:	01 c0                	add    %eax,%eax
  100545:	01 d0                	add    %edx,%eax
  100547:	c1 e0 02             	shl    $0x2,%eax
  10054a:	89 c2                	mov    %eax,%edx
  10054c:	8b 45 08             	mov    0x8(%ebp),%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	8b 40 08             	mov    0x8(%eax),%eax
  100554:	39 45 18             	cmp    %eax,0x18(%ebp)
  100557:	73 14                	jae    10056d <stab_binsearch+0xdb>
            *region_right = m - 1;
  100559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10055c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10055f:	8b 45 10             	mov    0x10(%ebp),%eax
  100562:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100567:	48                   	dec    %eax
  100568:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10056b:	eb 11                	jmp    10057e <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10056d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100570:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100573:	89 10                	mov    %edx,(%eax)
            l = m;
  100575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100578:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10057b:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  10057e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100581:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100584:	0f 8e 2a ff ff ff    	jle    1004b4 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  10058a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10058e:	75 0f                	jne    10059f <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  100590:	8b 45 0c             	mov    0xc(%ebp),%eax
  100593:	8b 00                	mov    (%eax),%eax
  100595:	8d 50 ff             	lea    -0x1(%eax),%edx
  100598:	8b 45 10             	mov    0x10(%ebp),%eax
  10059b:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10059d:	eb 3e                	jmp    1005dd <stab_binsearch+0x14b>
        l = *region_right;
  10059f:	8b 45 10             	mov    0x10(%ebp),%eax
  1005a2:	8b 00                	mov    (%eax),%eax
  1005a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a7:	eb 03                	jmp    1005ac <stab_binsearch+0x11a>
  1005a9:	ff 4d fc             	decl   -0x4(%ebp)
  1005ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005af:	8b 00                	mov    (%eax),%eax
  1005b1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  1005b4:	7e 1f                	jle    1005d5 <stab_binsearch+0x143>
  1005b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b9:	89 d0                	mov    %edx,%eax
  1005bb:	01 c0                	add    %eax,%eax
  1005bd:	01 d0                	add    %edx,%eax
  1005bf:	c1 e0 02             	shl    $0x2,%eax
  1005c2:	89 c2                	mov    %eax,%edx
  1005c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c7:	01 d0                	add    %edx,%eax
  1005c9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005cd:	0f b6 c0             	movzbl %al,%eax
  1005d0:	39 45 14             	cmp    %eax,0x14(%ebp)
  1005d3:	75 d4                	jne    1005a9 <stab_binsearch+0x117>
        *region_left = l;
  1005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005db:	89 10                	mov    %edx,(%eax)
}
  1005dd:	90                   	nop
  1005de:	c9                   	leave  
  1005df:	c3                   	ret    

001005e0 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005e0:	55                   	push   %ebp
  1005e1:	89 e5                	mov    %esp,%ebp
  1005e3:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e9:	c7 00 d8 36 10 00    	movl   $0x1036d8,(%eax)
    info->eip_line = 0;
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fc:	c7 40 08 d8 36 10 00 	movl   $0x1036d8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100603:	8b 45 0c             	mov    0xc(%ebp),%eax
  100606:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10060d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100610:	8b 55 08             	mov    0x8(%ebp),%edx
  100613:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100616:	8b 45 0c             	mov    0xc(%ebp),%eax
  100619:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100620:	c7 45 f4 ec 3e 10 00 	movl   $0x103eec,-0xc(%ebp)
    stab_end = __STAB_END__;
  100627:	c7 45 f0 a0 bd 10 00 	movl   $0x10bda0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10062e:	c7 45 ec a1 bd 10 00 	movl   $0x10bda1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100635:	c7 45 e8 9f de 10 00 	movl   $0x10de9f,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10063c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100642:	76 0b                	jbe    10064f <debuginfo_eip+0x6f>
  100644:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100647:	48                   	dec    %eax
  100648:	0f b6 00             	movzbl (%eax),%eax
  10064b:	84 c0                	test   %al,%al
  10064d:	74 0a                	je     100659 <debuginfo_eip+0x79>
        return -1;
  10064f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100654:	e9 b7 02 00 00       	jmp    100910 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100666:	29 c2                	sub    %eax,%edx
  100668:	89 d0                	mov    %edx,%eax
  10066a:	c1 f8 02             	sar    $0x2,%eax
  10066d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100673:	48                   	dec    %eax
  100674:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100677:	8b 45 08             	mov    0x8(%ebp),%eax
  10067a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10067e:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100685:	00 
  100686:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100689:	89 44 24 08          	mov    %eax,0x8(%esp)
  10068d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100690:	89 44 24 04          	mov    %eax,0x4(%esp)
  100694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100697:	89 04 24             	mov    %eax,(%esp)
  10069a:	e8 f3 fd ff ff       	call   100492 <stab_binsearch>
    if (lfile == 0)
  10069f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a2:	85 c0                	test   %eax,%eax
  1006a4:	75 0a                	jne    1006b0 <debuginfo_eip+0xd0>
        return -1;
  1006a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006ab:	e9 60 02 00 00       	jmp    100910 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1006bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006c3:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006ca:	00 
  1006cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006dc:	89 04 24             	mov    %eax,(%esp)
  1006df:	e8 ae fd ff ff       	call   100492 <stab_binsearch>

    if (lfun <= rfun) {
  1006e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ea:	39 c2                	cmp    %eax,%edx
  1006ec:	7f 7c                	jg     10076a <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f1:	89 c2                	mov    %eax,%edx
  1006f3:	89 d0                	mov    %edx,%eax
  1006f5:	01 c0                	add    %eax,%eax
  1006f7:	01 d0                	add    %edx,%eax
  1006f9:	c1 e0 02             	shl    $0x2,%eax
  1006fc:	89 c2                	mov    %eax,%edx
  1006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100701:	01 d0                	add    %edx,%eax
  100703:	8b 00                	mov    (%eax),%eax
  100705:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100708:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10070b:	29 d1                	sub    %edx,%ecx
  10070d:	89 ca                	mov    %ecx,%edx
  10070f:	39 d0                	cmp    %edx,%eax
  100711:	73 22                	jae    100735 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100713:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100716:	89 c2                	mov    %eax,%edx
  100718:	89 d0                	mov    %edx,%eax
  10071a:	01 c0                	add    %eax,%eax
  10071c:	01 d0                	add    %edx,%eax
  10071e:	c1 e0 02             	shl    $0x2,%eax
  100721:	89 c2                	mov    %eax,%edx
  100723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100726:	01 d0                	add    %edx,%eax
  100728:	8b 10                	mov    (%eax),%edx
  10072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10072d:	01 c2                	add    %eax,%edx
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100735:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100738:	89 c2                	mov    %eax,%edx
  10073a:	89 d0                	mov    %edx,%eax
  10073c:	01 c0                	add    %eax,%eax
  10073e:	01 d0                	add    %edx,%eax
  100740:	c1 e0 02             	shl    $0x2,%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100748:	01 d0                	add    %edx,%eax
  10074a:	8b 50 08             	mov    0x8(%eax),%edx
  10074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100750:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100753:	8b 45 0c             	mov    0xc(%ebp),%eax
  100756:	8b 40 10             	mov    0x10(%eax),%eax
  100759:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10075c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100765:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100768:	eb 15                	jmp    10077f <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10076d:	8b 55 08             	mov    0x8(%ebp),%edx
  100770:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100779:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100782:	8b 40 08             	mov    0x8(%eax),%eax
  100785:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10078c:	00 
  10078d:	89 04 24             	mov    %eax,(%esp)
  100790:	e8 ae 24 00 00       	call   102c43 <strfind>
  100795:	89 c2                	mov    %eax,%edx
  100797:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079a:	8b 40 08             	mov    0x8(%eax),%eax
  10079d:	29 c2                	sub    %eax,%edx
  10079f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1007a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007ac:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007b3:	00 
  1007b4:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007bb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c5:	89 04 24             	mov    %eax,(%esp)
  1007c8:	e8 c5 fc ff ff       	call   100492 <stab_binsearch>
    if (lline <= rline) {
  1007cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d3:	39 c2                	cmp    %eax,%edx
  1007d5:	7f 23                	jg     1007fa <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007da:	89 c2                	mov    %eax,%edx
  1007dc:	89 d0                	mov    %edx,%eax
  1007de:	01 c0                	add    %eax,%eax
  1007e0:	01 d0                	add    %edx,%eax
  1007e2:	c1 e0 02             	shl    $0x2,%eax
  1007e5:	89 c2                	mov    %eax,%edx
  1007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ea:	01 d0                	add    %edx,%eax
  1007ec:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007f0:	89 c2                	mov    %eax,%edx
  1007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f5:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f8:	eb 11                	jmp    10080b <debuginfo_eip+0x22b>
        return -1;
  1007fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007ff:	e9 0c 01 00 00       	jmp    100910 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100804:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100807:	48                   	dec    %eax
  100808:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10080b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100811:	39 c2                	cmp    %eax,%edx
  100813:	7c 56                	jl     10086b <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100818:	89 c2                	mov    %eax,%edx
  10081a:	89 d0                	mov    %edx,%eax
  10081c:	01 c0                	add    %eax,%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	c1 e0 02             	shl    $0x2,%eax
  100823:	89 c2                	mov    %eax,%edx
  100825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100828:	01 d0                	add    %edx,%eax
  10082a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10082e:	3c 84                	cmp    $0x84,%al
  100830:	74 39                	je     10086b <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c 64                	cmp    $0x64,%al
  10084d:	75 b5                	jne    100804 <debuginfo_eip+0x224>
  10084f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100852:	89 c2                	mov    %eax,%edx
  100854:	89 d0                	mov    %edx,%eax
  100856:	01 c0                	add    %eax,%eax
  100858:	01 d0                	add    %edx,%eax
  10085a:	c1 e0 02             	shl    $0x2,%eax
  10085d:	89 c2                	mov    %eax,%edx
  10085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100862:	01 d0                	add    %edx,%eax
  100864:	8b 40 08             	mov    0x8(%eax),%eax
  100867:	85 c0                	test   %eax,%eax
  100869:	74 99                	je     100804 <debuginfo_eip+0x224>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10086b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10086e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100871:	39 c2                	cmp    %eax,%edx
  100873:	7c 46                	jl     1008bb <debuginfo_eip+0x2db>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 00                	mov    (%eax),%eax
  10088c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100892:	29 d1                	sub    %edx,%ecx
  100894:	89 ca                	mov    %ecx,%edx
  100896:	39 d0                	cmp    %edx,%eax
  100898:	73 21                	jae    1008bb <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10089a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089d:	89 c2                	mov    %eax,%edx
  10089f:	89 d0                	mov    %edx,%eax
  1008a1:	01 c0                	add    %eax,%eax
  1008a3:	01 d0                	add    %edx,%eax
  1008a5:	c1 e0 02             	shl    $0x2,%eax
  1008a8:	89 c2                	mov    %eax,%edx
  1008aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ad:	01 d0                	add    %edx,%eax
  1008af:	8b 10                	mov    (%eax),%edx
  1008b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008b4:	01 c2                	add    %eax,%edx
  1008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008c1:	39 c2                	cmp    %eax,%edx
  1008c3:	7d 46                	jge    10090b <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c8:	40                   	inc    %eax
  1008c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008cc:	eb 16                	jmp    1008e4 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d1:	8b 40 14             	mov    0x14(%eax),%eax
  1008d4:	8d 50 01             	lea    0x1(%eax),%edx
  1008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008da:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  1008dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008e0:	40                   	inc    %eax
  1008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  1008ea:	39 c2                	cmp    %eax,%edx
  1008ec:	7d 1d                	jge    10090b <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f1:	89 c2                	mov    %eax,%edx
  1008f3:	89 d0                	mov    %edx,%eax
  1008f5:	01 c0                	add    %eax,%eax
  1008f7:	01 d0                	add    %edx,%eax
  1008f9:	c1 e0 02             	shl    $0x2,%eax
  1008fc:	89 c2                	mov    %eax,%edx
  1008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100901:	01 d0                	add    %edx,%eax
  100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100907:	3c a0                	cmp    $0xa0,%al
  100909:	74 c3                	je     1008ce <debuginfo_eip+0x2ee>
        }
    }
    return 0;
  10090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100918:	c7 04 24 e2 36 10 00 	movl   $0x1036e2,(%esp)
  10091f:	e8 48 f9 ff ff       	call   10026c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100924:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10092b:	00 
  10092c:	c7 04 24 fb 36 10 00 	movl   $0x1036fb,(%esp)
  100933:	e8 34 f9 ff ff       	call   10026c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100938:	c7 44 24 04 c1 35 10 	movl   $0x1035c1,0x4(%esp)
  10093f:	00 
  100940:	c7 04 24 13 37 10 00 	movl   $0x103713,(%esp)
  100947:	e8 20 f9 ff ff       	call   10026c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10094c:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100953:	00 
  100954:	c7 04 24 2b 37 10 00 	movl   $0x10372b,(%esp)
  10095b:	e8 0c f9 ff ff       	call   10026c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100960:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  100967:	00 
  100968:	c7 04 24 43 37 10 00 	movl   $0x103743,(%esp)
  10096f:	e8 f8 f8 ff ff       	call   10026c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100974:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  100979:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10097f:	b8 00 00 10 00       	mov    $0x100000,%eax
  100984:	29 c2                	sub    %eax,%edx
  100986:	89 d0                	mov    %edx,%eax
  100988:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10098e:	85 c0                	test   %eax,%eax
  100990:	0f 48 c2             	cmovs  %edx,%eax
  100993:	c1 f8 0a             	sar    $0xa,%eax
  100996:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099a:	c7 04 24 5c 37 10 00 	movl   $0x10375c,(%esp)
  1009a1:	e8 c6 f8 ff ff       	call   10026c <cprintf>
}
  1009a6:	90                   	nop
  1009a7:	c9                   	leave  
  1009a8:	c3                   	ret    

001009a9 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009a9:	55                   	push   %ebp
  1009aa:	89 e5                	mov    %esp,%ebp
  1009ac:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1009bc:	89 04 24             	mov    %eax,(%esp)
  1009bf:	e8 1c fc ff ff       	call   1005e0 <debuginfo_eip>
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	74 15                	je     1009dd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009cf:	c7 04 24 86 37 10 00 	movl   $0x103786,(%esp)
  1009d6:	e8 91 f8 ff ff       	call   10026c <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009db:	eb 6c                	jmp    100a49 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009e4:	eb 1b                	jmp    100a01 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  1009e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ec:	01 d0                	add    %edx,%eax
  1009ee:	0f b6 00             	movzbl (%eax),%eax
  1009f1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009fa:	01 ca                	add    %ecx,%edx
  1009fc:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009fe:	ff 45 f4             	incl   -0xc(%ebp)
  100a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a07:	7c dd                	jl     1009e6 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100a09:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  100a1d:	89 d1                	mov    %edx,%ecx
  100a1f:	29 c1                	sub    %eax,%ecx
  100a21:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a24:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a27:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a2b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a31:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a35:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3d:	c7 04 24 a2 37 10 00 	movl   $0x1037a2,(%esp)
  100a44:	e8 23 f8 ff ff       	call   10026c <cprintf>
}
  100a49:	90                   	nop
  100a4a:	c9                   	leave  
  100a4b:	c3                   	ret    

00100a4c <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a4c:	55                   	push   %ebp
  100a4d:	89 e5                	mov    %esp,%ebp
  100a4f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a52:	8b 45 04             	mov    0x4(%ebp),%eax
  100a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a5b:	c9                   	leave  
  100a5c:	c3                   	ret    

00100a5d <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */

void
print_stackframe(void) {
  100a5d:	55                   	push   %ebp
  100a5e:	89 e5                	mov    %esp,%ebp
  100a60:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a63:	89 e8                	mov    %ebp,%eax
  100a65:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a68:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip = read_eip();
  100a6e:	e8 d9 ff ff ff       	call   100a4c <read_eip>
  100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
  100a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a7d:	e9 9a 00 00 00       	jmp    100b1c <print_stackframe+0xbf>
      {
        if (ebp==0)  break;
  100a82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a86:	0f 84 9c 00 00 00    	je     100b28 <print_stackframe+0xcb>
        cprintf("-> ebp:0x%08x   eip:0x%08x   " ,ebp,eip);
  100a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a9a:	c7 04 24 b4 37 10 00 	movl   $0x1037b4,(%esp)
  100aa1:	e8 c6 f7 ff ff       	call   10026c <cprintf>
        uint32_t* arguments = (uint32_t*) ebp+2;
  100aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aa9:	83 c0 08             	add    $0x8,%eax
  100aac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        cprintf("args: ");
  100aaf:	c7 04 24 d2 37 10 00 	movl   $0x1037d2,(%esp)
  100ab6:	e8 b1 f7 ff ff       	call   10026c <cprintf>
        for (int j = 0 ;j<4;j++)
  100abb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ac2:	eb 24                	jmp    100ae8 <print_stackframe+0x8b>
        {
          cprintf("0x%08x ",arguments[j]);
  100ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ac7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ad1:	01 d0                	add    %edx,%eax
  100ad3:	8b 00                	mov    (%eax),%eax
  100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ad9:	c7 04 24 d9 37 10 00 	movl   $0x1037d9,(%esp)
  100ae0:	e8 87 f7 ff ff       	call   10026c <cprintf>
        for (int j = 0 ;j<4;j++)
  100ae5:	ff 45 e8             	incl   -0x18(%ebp)
  100ae8:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100aec:	7e d6                	jle    100ac4 <print_stackframe+0x67>
        }
        cprintf("\n");
  100aee:	c7 04 24 e1 37 10 00 	movl   $0x1037e1,(%esp)
  100af5:	e8 72 f7 ff ff       	call   10026c <cprintf>
        print_debuginfo(eip-1);
  100afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100afd:	48                   	dec    %eax
  100afe:	89 04 24             	mov    %eax,(%esp)
  100b01:	e8 a3 fe ff ff       	call   1009a9 <print_debuginfo>
        eip =( (uint32_t*) ebp)[1];
  100b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b09:	83 c0 04             	add    $0x4,%eax
  100b0c:	8b 00                	mov    (%eax),%eax
  100b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp= ((uint32_t* ) ebp)[0];
  100b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b14:	8b 00                	mov    (%eax),%eax
  100b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for (int i = 0;i  < STACKFRAME_DEPTH;i++)
  100b19:	ff 45 ec             	incl   -0x14(%ebp)
  100b1c:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b20:	0f 8e 5c ff ff ff    	jle    100a82 <print_stackframe+0x25>
      }

}
  100b26:	eb 01                	jmp    100b29 <print_stackframe+0xcc>
        if (ebp==0)  break;
  100b28:	90                   	nop
}
  100b29:	90                   	nop
  100b2a:	c9                   	leave  
  100b2b:	c3                   	ret    

00100b2c <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b2c:	55                   	push   %ebp
  100b2d:	89 e5                	mov    %esp,%ebp
  100b2f:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b39:	eb 0c                	jmp    100b47 <parse+0x1b>
            *buf ++ = '\0';
  100b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b3e:	8d 50 01             	lea    0x1(%eax),%edx
  100b41:	89 55 08             	mov    %edx,0x8(%ebp)
  100b44:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b47:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4a:	0f b6 00             	movzbl (%eax),%eax
  100b4d:	84 c0                	test   %al,%al
  100b4f:	74 1d                	je     100b6e <parse+0x42>
  100b51:	8b 45 08             	mov    0x8(%ebp),%eax
  100b54:	0f b6 00             	movzbl (%eax),%eax
  100b57:	0f be c0             	movsbl %al,%eax
  100b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b5e:	c7 04 24 64 38 10 00 	movl   $0x103864,(%esp)
  100b65:	e8 a7 20 00 00       	call   102c11 <strchr>
  100b6a:	85 c0                	test   %eax,%eax
  100b6c:	75 cd                	jne    100b3b <parse+0xf>
        }
        if (*buf == '\0') {
  100b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b71:	0f b6 00             	movzbl (%eax),%eax
  100b74:	84 c0                	test   %al,%al
  100b76:	74 65                	je     100bdd <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b78:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b7c:	75 14                	jne    100b92 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b7e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b85:	00 
  100b86:	c7 04 24 69 38 10 00 	movl   $0x103869,(%esp)
  100b8d:	e8 da f6 ff ff       	call   10026c <cprintf>
        }
        argv[argc ++] = buf;
  100b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b95:	8d 50 01             	lea    0x1(%eax),%edx
  100b98:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ba5:	01 c2                	add    %eax,%edx
  100ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  100baa:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bac:	eb 03                	jmp    100bb1 <parse+0x85>
            buf ++;
  100bae:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb4:	0f b6 00             	movzbl (%eax),%eax
  100bb7:	84 c0                	test   %al,%al
  100bb9:	74 8c                	je     100b47 <parse+0x1b>
  100bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbe:	0f b6 00             	movzbl (%eax),%eax
  100bc1:	0f be c0             	movsbl %al,%eax
  100bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bc8:	c7 04 24 64 38 10 00 	movl   $0x103864,(%esp)
  100bcf:	e8 3d 20 00 00       	call   102c11 <strchr>
  100bd4:	85 c0                	test   %eax,%eax
  100bd6:	74 d6                	je     100bae <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bd8:	e9 6a ff ff ff       	jmp    100b47 <parse+0x1b>
            break;
  100bdd:	90                   	nop
        }
    }
    return argc;
  100bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100be1:	c9                   	leave  
  100be2:	c3                   	ret    

00100be3 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100be3:	55                   	push   %ebp
  100be4:	89 e5                	mov    %esp,%ebp
  100be6:	53                   	push   %ebx
  100be7:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bea:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf4:	89 04 24             	mov    %eax,(%esp)
  100bf7:	e8 30 ff ff ff       	call   100b2c <parse>
  100bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c03:	75 0a                	jne    100c0f <runcmd+0x2c>
        return 0;
  100c05:	b8 00 00 00 00       	mov    $0x0,%eax
  100c0a:	e9 83 00 00 00       	jmp    100c92 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c16:	eb 5a                	jmp    100c72 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c18:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c1e:	89 d0                	mov    %edx,%eax
  100c20:	01 c0                	add    %eax,%eax
  100c22:	01 d0                	add    %edx,%eax
  100c24:	c1 e0 02             	shl    $0x2,%eax
  100c27:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c2c:	8b 00                	mov    (%eax),%eax
  100c2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c32:	89 04 24             	mov    %eax,(%esp)
  100c35:	e8 3a 1f 00 00       	call   102b74 <strcmp>
  100c3a:	85 c0                	test   %eax,%eax
  100c3c:	75 31                	jne    100c6f <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c41:	89 d0                	mov    %edx,%eax
  100c43:	01 c0                	add    %eax,%eax
  100c45:	01 d0                	add    %edx,%eax
  100c47:	c1 e0 02             	shl    $0x2,%eax
  100c4a:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c4f:	8b 10                	mov    (%eax),%edx
  100c51:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c54:	83 c0 04             	add    $0x4,%eax
  100c57:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c5a:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c60:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c68:	89 1c 24             	mov    %ebx,(%esp)
  100c6b:	ff d2                	call   *%edx
  100c6d:	eb 23                	jmp    100c92 <runcmd+0xaf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c6f:	ff 45 f4             	incl   -0xc(%ebp)
  100c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c75:	83 f8 02             	cmp    $0x2,%eax
  100c78:	76 9e                	jbe    100c18 <runcmd+0x35>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c7a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c81:	c7 04 24 87 38 10 00 	movl   $0x103887,(%esp)
  100c88:	e8 df f5 ff ff       	call   10026c <cprintf>
    return 0;
  100c8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c92:	83 c4 64             	add    $0x64,%esp
  100c95:	5b                   	pop    %ebx
  100c96:	5d                   	pop    %ebp
  100c97:	c3                   	ret    

00100c98 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c98:	55                   	push   %ebp
  100c99:	89 e5                	mov    %esp,%ebp
  100c9b:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c9e:	c7 04 24 a0 38 10 00 	movl   $0x1038a0,(%esp)
  100ca5:	e8 c2 f5 ff ff       	call   10026c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100caa:	c7 04 24 c8 38 10 00 	movl   $0x1038c8,(%esp)
  100cb1:	e8 b6 f5 ff ff       	call   10026c <cprintf>

    if (tf != NULL) {
  100cb6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cba:	74 0b                	je     100cc7 <kmonitor+0x2f>
        print_trapframe(tf);
  100cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  100cbf:	89 04 24             	mov    %eax,(%esp)
  100cc2:	e8 2b 0d 00 00       	call   1019f2 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cc7:	c7 04 24 ed 38 10 00 	movl   $0x1038ed,(%esp)
  100cce:	e8 3b f6 ff ff       	call   10030e <readline>
  100cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cda:	74 eb                	je     100cc7 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  100cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ce6:	89 04 24             	mov    %eax,(%esp)
  100ce9:	e8 f5 fe ff ff       	call   100be3 <runcmd>
  100cee:	85 c0                	test   %eax,%eax
  100cf0:	78 02                	js     100cf4 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100cf2:	eb d3                	jmp    100cc7 <kmonitor+0x2f>
                break;
  100cf4:	90                   	nop
            }
        }
    }
}
  100cf5:	90                   	nop
  100cf6:	c9                   	leave  
  100cf7:	c3                   	ret    

00100cf8 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cf8:	55                   	push   %ebp
  100cf9:	89 e5                	mov    %esp,%ebp
  100cfb:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d05:	eb 3d                	jmp    100d44 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d0a:	89 d0                	mov    %edx,%eax
  100d0c:	01 c0                	add    %eax,%eax
  100d0e:	01 d0                	add    %edx,%eax
  100d10:	c1 e0 02             	shl    $0x2,%eax
  100d13:	05 04 e0 10 00       	add    $0x10e004,%eax
  100d18:	8b 08                	mov    (%eax),%ecx
  100d1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d1d:	89 d0                	mov    %edx,%eax
  100d1f:	01 c0                	add    %eax,%eax
  100d21:	01 d0                	add    %edx,%eax
  100d23:	c1 e0 02             	shl    $0x2,%eax
  100d26:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d2b:	8b 00                	mov    (%eax),%eax
  100d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d35:	c7 04 24 f1 38 10 00 	movl   $0x1038f1,(%esp)
  100d3c:	e8 2b f5 ff ff       	call   10026c <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d41:	ff 45 f4             	incl   -0xc(%ebp)
  100d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d47:	83 f8 02             	cmp    $0x2,%eax
  100d4a:	76 bb                	jbe    100d07 <mon_help+0xf>
    }
    return 0;
  100d4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d51:	c9                   	leave  
  100d52:	c3                   	ret    

00100d53 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d53:	55                   	push   %ebp
  100d54:	89 e5                	mov    %esp,%ebp
  100d56:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d59:	e8 b4 fb ff ff       	call   100912 <print_kerninfo>
    return 0;
  100d5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d63:	c9                   	leave  
  100d64:	c3                   	ret    

00100d65 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d65:	55                   	push   %ebp
  100d66:	89 e5                	mov    %esp,%ebp
  100d68:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d6b:	e8 ed fc ff ff       	call   100a5d <print_stackframe>
    return 0;
  100d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d75:	c9                   	leave  
  100d76:	c3                   	ret    

00100d77 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d77:	55                   	push   %ebp
  100d78:	89 e5                	mov    %esp,%ebp
  100d7a:	83 ec 28             	sub    $0x28,%esp
  100d7d:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100d83:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d87:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100d8b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100d8f:	ee                   	out    %al,(%dx)
  100d90:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d96:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d9a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d9e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100da2:	ee                   	out    %al,(%dx)
  100da3:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100da9:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
  100dad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100db1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100db5:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100db6:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100dbd:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dc0:	c7 04 24 fa 38 10 00 	movl   $0x1038fa,(%esp)
  100dc7:	e8 a0 f4 ff ff       	call   10026c <cprintf>
    pic_enable(IRQ_TIMER);
  100dcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dd3:	e8 ca 08 00 00       	call   1016a2 <pic_enable>
}
  100dd8:	90                   	nop
  100dd9:	c9                   	leave  
  100dda:	c3                   	ret    

00100ddb <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100ddb:	55                   	push   %ebp
  100ddc:	89 e5                	mov    %esp,%ebp
  100dde:	83 ec 10             	sub    $0x10,%esp
  100de1:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100de7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100deb:	89 c2                	mov    %eax,%edx
  100ded:	ec                   	in     (%dx),%al
  100dee:	88 45 f1             	mov    %al,-0xf(%ebp)
  100df1:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100df7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100dfb:	89 c2                	mov    %eax,%edx
  100dfd:	ec                   	in     (%dx),%al
  100dfe:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e01:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e07:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e0b:	89 c2                	mov    %eax,%edx
  100e0d:	ec                   	in     (%dx),%al
  100e0e:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e11:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e17:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e1b:	89 c2                	mov    %eax,%edx
  100e1d:	ec                   	in     (%dx),%al
  100e1e:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e21:	90                   	nop
  100e22:	c9                   	leave  
  100e23:	c3                   	ret    

00100e24 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e24:	55                   	push   %ebp
  100e25:	89 e5                	mov    %esp,%ebp
  100e27:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e2a:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e34:	0f b7 00             	movzwl (%eax),%eax
  100e37:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e3e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e46:	0f b7 00             	movzwl (%eax),%eax
  100e49:	0f b7 c0             	movzwl %ax,%eax
  100e4c:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e51:	74 12                	je     100e65 <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e53:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e5a:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e61:	b4 03 
  100e63:	eb 13                	jmp    100e78 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e68:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e6c:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4
  100e6f:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e76:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);
  100e78:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e7f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100e83:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e87:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100e8b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100e8f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e90:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e97:	40                   	inc    %eax
  100e98:	0f b7 c0             	movzwl %ax,%eax
  100e9b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e9f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100ea3:	89 c2                	mov    %eax,%edx
  100ea5:	ec                   	in     (%dx),%al
  100ea6:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100ea9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ead:	0f b6 c0             	movzbl %al,%eax
  100eb0:	c1 e0 08             	shl    $0x8,%eax
  100eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100eb6:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ebd:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100ec1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ec5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ec9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ecd:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ece:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ed5:	40                   	inc    %eax
  100ed6:	0f b7 c0             	movzwl %ax,%eax
  100ed9:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100edd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ee1:	89 c2                	mov    %eax,%edx
  100ee3:	ec                   	in     (%dx),%al
  100ee4:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100ee7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eeb:	0f b6 c0             	movzbl %al,%eax
  100eee:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ef1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ef4:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100efc:	0f b7 c0             	movzwl %ax,%eax
  100eff:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100f05:	90                   	nop
  100f06:	c9                   	leave  
  100f07:	c3                   	ret    

00100f08 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f08:	55                   	push   %ebp
  100f09:	89 e5                	mov    %esp,%ebp
  100f0b:	83 ec 48             	sub    $0x48,%esp
  100f0e:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f14:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f18:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f1c:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f20:	ee                   	out    %al,(%dx)
  100f21:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f27:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
  100f2b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f2f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f33:	ee                   	out    %al,(%dx)
  100f34:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f3a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
  100f3e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f42:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f46:	ee                   	out    %al,(%dx)
  100f47:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f4d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f51:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f55:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f59:	ee                   	out    %al,(%dx)
  100f5a:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100f60:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
  100f64:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f68:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f6c:	ee                   	out    %al,(%dx)
  100f6d:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100f73:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
  100f77:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f7b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f7f:	ee                   	out    %al,(%dx)
  100f80:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f86:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
  100f8a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f8e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f92:	ee                   	out    %al,(%dx)
  100f93:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f99:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f9d:	89 c2                	mov    %eax,%edx
  100f9f:	ec                   	in     (%dx),%al
  100fa0:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fa7:	3c ff                	cmp    $0xff,%al
  100fa9:	0f 95 c0             	setne  %al
  100fac:	0f b6 c0             	movzbl %al,%eax
  100faf:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fb4:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fba:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fbe:	89 c2                	mov    %eax,%edx
  100fc0:	ec                   	in     (%dx),%al
  100fc1:	88 45 f1             	mov    %al,-0xf(%ebp)
  100fc4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  100fca:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100fce:	89 c2                	mov    %eax,%edx
  100fd0:	ec                   	in     (%dx),%al
  100fd1:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fd4:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fd9:	85 c0                	test   %eax,%eax
  100fdb:	74 0c                	je     100fe9 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fdd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fe4:	e8 b9 06 00 00       	call   1016a2 <pic_enable>
    }
}
  100fe9:	90                   	nop
  100fea:	c9                   	leave  
  100feb:	c3                   	ret    

00100fec <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fec:	55                   	push   %ebp
  100fed:	89 e5                	mov    %esp,%ebp
  100fef:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ff2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100ff9:	eb 08                	jmp    101003 <lpt_putc_sub+0x17>
        delay();
  100ffb:	e8 db fd ff ff       	call   100ddb <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101000:	ff 45 fc             	incl   -0x4(%ebp)
  101003:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101009:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10100d:	89 c2                	mov    %eax,%edx
  10100f:	ec                   	in     (%dx),%al
  101010:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101013:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101017:	84 c0                	test   %al,%al
  101019:	78 09                	js     101024 <lpt_putc_sub+0x38>
  10101b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101022:	7e d7                	jle    100ffb <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101024:	8b 45 08             	mov    0x8(%ebp),%eax
  101027:	0f b6 c0             	movzbl %al,%eax
  10102a:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101030:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101033:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101037:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10103b:	ee                   	out    %al,(%dx)
  10103c:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101042:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101046:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10104a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10104e:	ee                   	out    %al,(%dx)
  10104f:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101055:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
  101059:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10105d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101061:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101062:	90                   	nop
  101063:	c9                   	leave  
  101064:	c3                   	ret    

00101065 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101065:	55                   	push   %ebp
  101066:	89 e5                	mov    %esp,%ebp
  101068:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10106b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10106f:	74 0d                	je     10107e <lpt_putc+0x19>
        lpt_putc_sub(c);
  101071:	8b 45 08             	mov    0x8(%ebp),%eax
  101074:	89 04 24             	mov    %eax,(%esp)
  101077:	e8 70 ff ff ff       	call   100fec <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10107c:	eb 24                	jmp    1010a2 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  10107e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101085:	e8 62 ff ff ff       	call   100fec <lpt_putc_sub>
        lpt_putc_sub(' ');
  10108a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101091:	e8 56 ff ff ff       	call   100fec <lpt_putc_sub>
        lpt_putc_sub('\b');
  101096:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10109d:	e8 4a ff ff ff       	call   100fec <lpt_putc_sub>
}
  1010a2:	90                   	nop
  1010a3:	c9                   	leave  
  1010a4:	c3                   	ret    

001010a5 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010a5:	55                   	push   %ebp
  1010a6:	89 e5                	mov    %esp,%ebp
  1010a8:	53                   	push   %ebx
  1010a9:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1010af:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010b4:	85 c0                	test   %eax,%eax
  1010b6:	75 07                	jne    1010bf <cga_putc+0x1a>
        c |= 0x0700;
  1010b8:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c2:	0f b6 c0             	movzbl %al,%eax
  1010c5:	83 f8 0a             	cmp    $0xa,%eax
  1010c8:	74 55                	je     10111f <cga_putc+0x7a>
  1010ca:	83 f8 0d             	cmp    $0xd,%eax
  1010cd:	74 63                	je     101132 <cga_putc+0x8d>
  1010cf:	83 f8 08             	cmp    $0x8,%eax
  1010d2:	0f 85 94 00 00 00    	jne    10116c <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
  1010d8:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010df:	85 c0                	test   %eax,%eax
  1010e1:	0f 84 af 00 00 00    	je     101196 <cga_putc+0xf1>
            crt_pos --;
  1010e7:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010ee:	48                   	dec    %eax
  1010ef:	0f b7 c0             	movzwl %ax,%eax
  1010f2:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1010fb:	98                   	cwtl   
  1010fc:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101101:	98                   	cwtl   
  101102:	83 c8 20             	or     $0x20,%eax
  101105:	98                   	cwtl   
  101106:	8b 15 60 ee 10 00    	mov    0x10ee60,%edx
  10110c:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101113:	01 c9                	add    %ecx,%ecx
  101115:	01 ca                	add    %ecx,%edx
  101117:	0f b7 c0             	movzwl %ax,%eax
  10111a:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10111d:	eb 77                	jmp    101196 <cga_putc+0xf1>
    case '\n':
        crt_pos += CRT_COLS;
  10111f:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101126:	83 c0 50             	add    $0x50,%eax
  101129:	0f b7 c0             	movzwl %ax,%eax
  10112c:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101132:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101139:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101140:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101145:	89 c8                	mov    %ecx,%eax
  101147:	f7 e2                	mul    %edx
  101149:	c1 ea 06             	shr    $0x6,%edx
  10114c:	89 d0                	mov    %edx,%eax
  10114e:	c1 e0 02             	shl    $0x2,%eax
  101151:	01 d0                	add    %edx,%eax
  101153:	c1 e0 04             	shl    $0x4,%eax
  101156:	29 c1                	sub    %eax,%ecx
  101158:	89 c8                	mov    %ecx,%eax
  10115a:	0f b7 c0             	movzwl %ax,%eax
  10115d:	29 c3                	sub    %eax,%ebx
  10115f:	89 d8                	mov    %ebx,%eax
  101161:	0f b7 c0             	movzwl %ax,%eax
  101164:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10116a:	eb 2b                	jmp    101197 <cga_putc+0xf2>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10116c:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101172:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101179:	8d 50 01             	lea    0x1(%eax),%edx
  10117c:	0f b7 d2             	movzwl %dx,%edx
  10117f:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101186:	01 c0                	add    %eax,%eax
  101188:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10118b:	8b 45 08             	mov    0x8(%ebp),%eax
  10118e:	0f b7 c0             	movzwl %ax,%eax
  101191:	66 89 02             	mov    %ax,(%edx)
        break;
  101194:	eb 01                	jmp    101197 <cga_putc+0xf2>
        break;
  101196:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101197:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10119e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011a3:	76 5d                	jbe    101202 <cga_putc+0x15d>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011a5:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011aa:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011b0:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011b5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011bc:	00 
  1011bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011c1:	89 04 24             	mov    %eax,(%esp)
  1011c4:	e8 3e 1c 00 00       	call   102e07 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011c9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011d0:	eb 14                	jmp    1011e6 <cga_putc+0x141>
            crt_buf[i] = 0x0700 | ' ';
  1011d2:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011da:	01 d2                	add    %edx,%edx
  1011dc:	01 d0                	add    %edx,%eax
  1011de:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011e3:	ff 45 f4             	incl   -0xc(%ebp)
  1011e6:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011ed:	7e e3                	jle    1011d2 <cga_putc+0x12d>
        }
        crt_pos -= CRT_COLS;
  1011ef:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011f6:	83 e8 50             	sub    $0x50,%eax
  1011f9:	0f b7 c0             	movzwl %ax,%eax
  1011fc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101202:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101209:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10120d:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
  101211:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101215:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101219:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10121a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101221:	c1 e8 08             	shr    $0x8,%eax
  101224:	0f b7 c0             	movzwl %ax,%eax
  101227:	0f b6 c0             	movzbl %al,%eax
  10122a:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101231:	42                   	inc    %edx
  101232:	0f b7 d2             	movzwl %dx,%edx
  101235:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101239:	88 45 e9             	mov    %al,-0x17(%ebp)
  10123c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101240:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101244:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101245:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  10124c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101250:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
  101254:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101258:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10125c:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10125d:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101264:	0f b6 c0             	movzbl %al,%eax
  101267:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10126e:	42                   	inc    %edx
  10126f:	0f b7 d2             	movzwl %dx,%edx
  101272:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101276:	88 45 f1             	mov    %al,-0xf(%ebp)
  101279:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10127d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101281:	ee                   	out    %al,(%dx)
}
  101282:	90                   	nop
  101283:	83 c4 34             	add    $0x34,%esp
  101286:	5b                   	pop    %ebx
  101287:	5d                   	pop    %ebp
  101288:	c3                   	ret    

00101289 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101289:	55                   	push   %ebp
  10128a:	89 e5                	mov    %esp,%ebp
  10128c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10128f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101296:	eb 08                	jmp    1012a0 <serial_putc_sub+0x17>
        delay();
  101298:	e8 3e fb ff ff       	call   100ddb <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10129d:	ff 45 fc             	incl   -0x4(%ebp)
  1012a0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1012a6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012aa:	89 c2                	mov    %eax,%edx
  1012ac:	ec                   	in     (%dx),%al
  1012ad:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012b0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012b4:	0f b6 c0             	movzbl %al,%eax
  1012b7:	83 e0 20             	and    $0x20,%eax
  1012ba:	85 c0                	test   %eax,%eax
  1012bc:	75 09                	jne    1012c7 <serial_putc_sub+0x3e>
  1012be:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012c5:	7e d1                	jle    101298 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  1012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1012ca:	0f b6 c0             	movzbl %al,%eax
  1012cd:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012d3:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012d6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012da:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012de:	ee                   	out    %al,(%dx)
}
  1012df:	90                   	nop
  1012e0:	c9                   	leave  
  1012e1:	c3                   	ret    

001012e2 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012e2:	55                   	push   %ebp
  1012e3:	89 e5                	mov    %esp,%ebp
  1012e5:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012e8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012ec:	74 0d                	je     1012fb <serial_putc+0x19>
        serial_putc_sub(c);
  1012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1012f1:	89 04 24             	mov    %eax,(%esp)
  1012f4:	e8 90 ff ff ff       	call   101289 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012f9:	eb 24                	jmp    10131f <serial_putc+0x3d>
        serial_putc_sub('\b');
  1012fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101302:	e8 82 ff ff ff       	call   101289 <serial_putc_sub>
        serial_putc_sub(' ');
  101307:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10130e:	e8 76 ff ff ff       	call   101289 <serial_putc_sub>
        serial_putc_sub('\b');
  101313:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10131a:	e8 6a ff ff ff       	call   101289 <serial_putc_sub>
}
  10131f:	90                   	nop
  101320:	c9                   	leave  
  101321:	c3                   	ret    

00101322 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101322:	55                   	push   %ebp
  101323:	89 e5                	mov    %esp,%ebp
  101325:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101328:	eb 33                	jmp    10135d <cons_intr+0x3b>
        if (c != 0) {
  10132a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10132e:	74 2d                	je     10135d <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101330:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101335:	8d 50 01             	lea    0x1(%eax),%edx
  101338:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  10133e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101341:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101347:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10134c:	3d 00 02 00 00       	cmp    $0x200,%eax
  101351:	75 0a                	jne    10135d <cons_intr+0x3b>
                cons.wpos = 0;
  101353:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  10135a:	00 00 00 
    while ((c = (*proc)()) != -1) {
  10135d:	8b 45 08             	mov    0x8(%ebp),%eax
  101360:	ff d0                	call   *%eax
  101362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101365:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101369:	75 bf                	jne    10132a <cons_intr+0x8>
            }
        }
    }
}
  10136b:	90                   	nop
  10136c:	c9                   	leave  
  10136d:	c3                   	ret    

0010136e <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10136e:	55                   	push   %ebp
  10136f:	89 e5                	mov    %esp,%ebp
  101371:	83 ec 10             	sub    $0x10,%esp
  101374:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10137a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10137e:	89 c2                	mov    %eax,%edx
  101380:	ec                   	in     (%dx),%al
  101381:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101384:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101388:	0f b6 c0             	movzbl %al,%eax
  10138b:	83 e0 01             	and    $0x1,%eax
  10138e:	85 c0                	test   %eax,%eax
  101390:	75 07                	jne    101399 <serial_proc_data+0x2b>
        return -1;
  101392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101397:	eb 2a                	jmp    1013c3 <serial_proc_data+0x55>
  101399:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10139f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013a3:	89 c2                	mov    %eax,%edx
  1013a5:	ec                   	in     (%dx),%al
  1013a6:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013a9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013ad:	0f b6 c0             	movzbl %al,%eax
  1013b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013b3:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013b7:	75 07                	jne    1013c0 <serial_proc_data+0x52>
        c = '\b';
  1013b9:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013c3:	c9                   	leave  
  1013c4:	c3                   	ret    

001013c5 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013c5:	55                   	push   %ebp
  1013c6:	89 e5                	mov    %esp,%ebp
  1013c8:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013cb:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013d0:	85 c0                	test   %eax,%eax
  1013d2:	74 0c                	je     1013e0 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013d4:	c7 04 24 6e 13 10 00 	movl   $0x10136e,(%esp)
  1013db:	e8 42 ff ff ff       	call   101322 <cons_intr>
    }
}
  1013e0:	90                   	nop
  1013e1:	c9                   	leave  
  1013e2:	c3                   	ret    

001013e3 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013e3:	55                   	push   %ebp
  1013e4:	89 e5                	mov    %esp,%ebp
  1013e6:	83 ec 38             	sub    $0x38,%esp
  1013e9:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1013f2:	89 c2                	mov    %eax,%edx
  1013f4:	ec                   	in     (%dx),%al
  1013f5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013f8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013fc:	0f b6 c0             	movzbl %al,%eax
  1013ff:	83 e0 01             	and    $0x1,%eax
  101402:	85 c0                	test   %eax,%eax
  101404:	75 0a                	jne    101410 <kbd_proc_data+0x2d>
        return -1;
  101406:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10140b:	e9 55 01 00 00       	jmp    101565 <kbd_proc_data+0x182>
  101410:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101416:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101419:	89 c2                	mov    %eax,%edx
  10141b:	ec                   	in     (%dx),%al
  10141c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10141f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101423:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101426:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10142a:	75 17                	jne    101443 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10142c:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101431:	83 c8 40             	or     $0x40,%eax
  101434:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101439:	b8 00 00 00 00       	mov    $0x0,%eax
  10143e:	e9 22 01 00 00       	jmp    101565 <kbd_proc_data+0x182>
    } else if (data & 0x80) {
  101443:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101447:	84 c0                	test   %al,%al
  101449:	79 45                	jns    101490 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10144b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101450:	83 e0 40             	and    $0x40,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 08                	jne    10145f <kbd_proc_data+0x7c>
  101457:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10145b:	24 7f                	and    $0x7f,%al
  10145d:	eb 04                	jmp    101463 <kbd_proc_data+0x80>
  10145f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101463:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101466:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10146a:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101471:	0c 40                	or     $0x40,%al
  101473:	0f b6 c0             	movzbl %al,%eax
  101476:	f7 d0                	not    %eax
  101478:	89 c2                	mov    %eax,%edx
  10147a:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10147f:	21 d0                	and    %edx,%eax
  101481:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101486:	b8 00 00 00 00       	mov    $0x0,%eax
  10148b:	e9 d5 00 00 00       	jmp    101565 <kbd_proc_data+0x182>
    } else if (shift & E0ESC) {
  101490:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101495:	83 e0 40             	and    $0x40,%eax
  101498:	85 c0                	test   %eax,%eax
  10149a:	74 11                	je     1014ad <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10149c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014a0:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014a5:	83 e0 bf             	and    $0xffffffbf,%eax
  1014a8:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  1014ad:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b1:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014b8:	0f b6 d0             	movzbl %al,%edx
  1014bb:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c0:	09 d0                	or     %edx,%eax
  1014c2:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014cb:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014d2:	0f b6 d0             	movzbl %al,%edx
  1014d5:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014da:	31 d0                	xor    %edx,%eax
  1014dc:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014e1:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014e6:	83 e0 03             	and    $0x3,%eax
  1014e9:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014f0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f4:	01 d0                	add    %edx,%eax
  1014f6:	0f b6 00             	movzbl (%eax),%eax
  1014f9:	0f b6 c0             	movzbl %al,%eax
  1014fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014ff:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101504:	83 e0 08             	and    $0x8,%eax
  101507:	85 c0                	test   %eax,%eax
  101509:	74 22                	je     10152d <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10150b:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10150f:	7e 0c                	jle    10151d <kbd_proc_data+0x13a>
  101511:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101515:	7f 06                	jg     10151d <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101517:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10151b:	eb 10                	jmp    10152d <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10151d:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101521:	7e 0a                	jle    10152d <kbd_proc_data+0x14a>
  101523:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101527:	7f 04                	jg     10152d <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101529:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10152d:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101532:	f7 d0                	not    %eax
  101534:	83 e0 06             	and    $0x6,%eax
  101537:	85 c0                	test   %eax,%eax
  101539:	75 27                	jne    101562 <kbd_proc_data+0x17f>
  10153b:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101542:	75 1e                	jne    101562 <kbd_proc_data+0x17f>
        cprintf("Rebooting!\n");
  101544:	c7 04 24 15 39 10 00 	movl   $0x103915,(%esp)
  10154b:	e8 1c ed ff ff       	call   10026c <cprintf>
  101550:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101556:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10155a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10155e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101561:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101562:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101565:	c9                   	leave  
  101566:	c3                   	ret    

00101567 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101567:	55                   	push   %ebp
  101568:	89 e5                	mov    %esp,%ebp
  10156a:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10156d:	c7 04 24 e3 13 10 00 	movl   $0x1013e3,(%esp)
  101574:	e8 a9 fd ff ff       	call   101322 <cons_intr>
}
  101579:	90                   	nop
  10157a:	c9                   	leave  
  10157b:	c3                   	ret    

0010157c <kbd_init>:

static void
kbd_init(void) {
  10157c:	55                   	push   %ebp
  10157d:	89 e5                	mov    %esp,%ebp
  10157f:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101582:	e8 e0 ff ff ff       	call   101567 <kbd_intr>
    pic_enable(IRQ_KBD);
  101587:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10158e:	e8 0f 01 00 00       	call   1016a2 <pic_enable>
}
  101593:	90                   	nop
  101594:	c9                   	leave  
  101595:	c3                   	ret    

00101596 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101596:	55                   	push   %ebp
  101597:	89 e5                	mov    %esp,%ebp
  101599:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10159c:	e8 83 f8 ff ff       	call   100e24 <cga_init>
    serial_init();
  1015a1:	e8 62 f9 ff ff       	call   100f08 <serial_init>
    kbd_init();
  1015a6:	e8 d1 ff ff ff       	call   10157c <kbd_init>
    if (!serial_exists) {
  1015ab:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1015b0:	85 c0                	test   %eax,%eax
  1015b2:	75 0c                	jne    1015c0 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015b4:	c7 04 24 21 39 10 00 	movl   $0x103921,(%esp)
  1015bb:	e8 ac ec ff ff       	call   10026c <cprintf>
    }
}
  1015c0:	90                   	nop
  1015c1:	c9                   	leave  
  1015c2:	c3                   	ret    

001015c3 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015c3:	55                   	push   %ebp
  1015c4:	89 e5                	mov    %esp,%ebp
  1015c6:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1015cc:	89 04 24             	mov    %eax,(%esp)
  1015cf:	e8 91 fa ff ff       	call   101065 <lpt_putc>
    cga_putc(c);
  1015d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1015d7:	89 04 24             	mov    %eax,(%esp)
  1015da:	e8 c6 fa ff ff       	call   1010a5 <cga_putc>
    serial_putc(c);
  1015df:	8b 45 08             	mov    0x8(%ebp),%eax
  1015e2:	89 04 24             	mov    %eax,(%esp)
  1015e5:	e8 f8 fc ff ff       	call   1012e2 <serial_putc>
}
  1015ea:	90                   	nop
  1015eb:	c9                   	leave  
  1015ec:	c3                   	ret    

001015ed <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015ed:	55                   	push   %ebp
  1015ee:	89 e5                	mov    %esp,%ebp
  1015f0:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015f3:	e8 cd fd ff ff       	call   1013c5 <serial_intr>
    kbd_intr();
  1015f8:	e8 6a ff ff ff       	call   101567 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015fd:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  101603:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101608:	39 c2                	cmp    %eax,%edx
  10160a:	74 36                	je     101642 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  10160c:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101611:	8d 50 01             	lea    0x1(%eax),%edx
  101614:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  10161a:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101621:	0f b6 c0             	movzbl %al,%eax
  101624:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101627:	a1 80 f0 10 00       	mov    0x10f080,%eax
  10162c:	3d 00 02 00 00       	cmp    $0x200,%eax
  101631:	75 0a                	jne    10163d <cons_getc+0x50>
            cons.rpos = 0;
  101633:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10163a:	00 00 00 
        }
        return c;
  10163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101640:	eb 05                	jmp    101647 <cons_getc+0x5a>
    }
    return 0;
  101642:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101647:	c9                   	leave  
  101648:	c3                   	ret    

00101649 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101649:	55                   	push   %ebp
  10164a:	89 e5                	mov    %esp,%ebp
  10164c:	83 ec 14             	sub    $0x14,%esp
  10164f:	8b 45 08             	mov    0x8(%ebp),%eax
  101652:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101656:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101659:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  10165f:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101664:	85 c0                	test   %eax,%eax
  101666:	74 37                	je     10169f <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10166b:	0f b6 c0             	movzbl %al,%eax
  10166e:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101674:	88 45 f9             	mov    %al,-0x7(%ebp)
  101677:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10167b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10167f:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101680:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101684:	c1 e8 08             	shr    $0x8,%eax
  101687:	0f b7 c0             	movzwl %ax,%eax
  10168a:	0f b6 c0             	movzbl %al,%eax
  10168d:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101693:	88 45 fd             	mov    %al,-0x3(%ebp)
  101696:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10169a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10169e:	ee                   	out    %al,(%dx)
    }
}
  10169f:	90                   	nop
  1016a0:	c9                   	leave  
  1016a1:	c3                   	ret    

001016a2 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1016a2:	55                   	push   %ebp
  1016a3:	89 e5                	mov    %esp,%ebp
  1016a5:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1016ab:	ba 01 00 00 00       	mov    $0x1,%edx
  1016b0:	88 c1                	mov    %al,%cl
  1016b2:	d3 e2                	shl    %cl,%edx
  1016b4:	89 d0                	mov    %edx,%eax
  1016b6:	98                   	cwtl   
  1016b7:	f7 d0                	not    %eax
  1016b9:	0f bf d0             	movswl %ax,%edx
  1016bc:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016c3:	98                   	cwtl   
  1016c4:	21 d0                	and    %edx,%eax
  1016c6:	98                   	cwtl   
  1016c7:	0f b7 c0             	movzwl %ax,%eax
  1016ca:	89 04 24             	mov    %eax,(%esp)
  1016cd:	e8 77 ff ff ff       	call   101649 <pic_setmask>
}
  1016d2:	90                   	nop
  1016d3:	c9                   	leave  
  1016d4:	c3                   	ret    

001016d5 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016d5:	55                   	push   %ebp
  1016d6:	89 e5                	mov    %esp,%ebp
  1016d8:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016db:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016e2:	00 00 00 
  1016e5:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1016eb:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
  1016ef:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1016f3:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1016f7:	ee                   	out    %al,(%dx)
  1016f8:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1016fe:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
  101702:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101706:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10170a:	ee                   	out    %al,(%dx)
  10170b:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101711:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
  101715:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101719:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10171d:	ee                   	out    %al,(%dx)
  10171e:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101724:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
  101728:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10172c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101730:	ee                   	out    %al,(%dx)
  101731:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101737:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
  10173b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10173f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101743:	ee                   	out    %al,(%dx)
  101744:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  10174a:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
  10174e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101752:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101756:	ee                   	out    %al,(%dx)
  101757:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  10175d:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
  101761:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101765:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101769:	ee                   	out    %al,(%dx)
  10176a:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101770:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
  101774:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101778:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10177c:	ee                   	out    %al,(%dx)
  10177d:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101783:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
  101787:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10178b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10178f:	ee                   	out    %al,(%dx)
  101790:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101796:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
  10179a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10179e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017a2:	ee                   	out    %al,(%dx)
  1017a3:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1017a9:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
  1017ad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017b1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017b5:	ee                   	out    %al,(%dx)
  1017b6:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1017bc:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
  1017c0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017c4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017c8:	ee                   	out    %al,(%dx)
  1017c9:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1017cf:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
  1017d3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017d7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017db:	ee                   	out    %al,(%dx)
  1017dc:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1017e2:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
  1017e6:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017ea:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017ee:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017ef:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017f6:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1017fb:	74 0f                	je     10180c <pic_init+0x137>
        pic_setmask(irq_mask);
  1017fd:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  101804:	89 04 24             	mov    %eax,(%esp)
  101807:	e8 3d fe ff ff       	call   101649 <pic_setmask>
    }
}
  10180c:	90                   	nop
  10180d:	c9                   	leave  
  10180e:	c3                   	ret    

0010180f <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10180f:	55                   	push   %ebp
  101810:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101812:	fb                   	sti    
    sti();
}
  101813:	90                   	nop
  101814:	5d                   	pop    %ebp
  101815:	c3                   	ret    

00101816 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101816:	55                   	push   %ebp
  101817:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101819:	fa                   	cli    
    cli();
}
  10181a:	90                   	nop
  10181b:	5d                   	pop    %ebp
  10181c:	c3                   	ret    

0010181d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10181d:	55                   	push   %ebp
  10181e:	89 e5                	mov    %esp,%ebp
  101820:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101823:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10182a:	00 
  10182b:	c7 04 24 40 39 10 00 	movl   $0x103940,(%esp)
  101832:	e8 35 ea ff ff       	call   10026c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101837:	90                   	nop
  101838:	c9                   	leave  
  101839:	c3                   	ret    

0010183a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10183a:	55                   	push   %ebp
  10183b:	89 e5                	mov    %esp,%ebp
  10183d:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uint32_t __vectors[];
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  101840:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101847:	e9 c4 00 00 00       	jmp    101910 <idt_init+0xd6>
    {
      SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  10184c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10184f:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101856:	0f b7 d0             	movzwl %ax,%edx
  101859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10185c:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  101863:	00 
  101864:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101867:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10186e:	00 08 00 
  101871:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101874:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10187b:	00 
  10187c:	80 e2 e0             	and    $0xe0,%dl
  10187f:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101886:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101889:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101890:	00 
  101891:	80 e2 1f             	and    $0x1f,%dl
  101894:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  10189b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10189e:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018a5:	00 
  1018a6:	80 e2 f0             	and    $0xf0,%dl
  1018a9:	80 ca 0e             	or     $0xe,%dl
  1018ac:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b6:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018bd:	00 
  1018be:	80 e2 ef             	and    $0xef,%dl
  1018c1:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018cb:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018d2:	00 
  1018d3:	80 e2 9f             	and    $0x9f,%dl
  1018d6:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e0:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018e7:	00 
  1018e8:	80 ca 80             	or     $0x80,%dl
  1018eb:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f5:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018fc:	c1 e8 10             	shr    $0x10,%eax
  1018ff:	0f b7 d0             	movzwl %ax,%edx
  101902:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101905:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  10190c:	00 
    for (int i =0 ; i < sizeof(idt)/sizeof(struct gatedesc);i++)
  10190d:	ff 45 fc             	incl   -0x4(%ebp)
  101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101913:	3d ff 00 00 00       	cmp    $0xff,%eax
  101918:	0f 86 2e ff ff ff    	jbe    10184c <idt_init+0x12>
    }
    // set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  10191e:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101923:	0f b7 c0             	movzwl %ax,%eax
  101926:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  10192c:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  101933:	08 00 
  101935:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10193c:	24 e0                	and    $0xe0,%al
  10193e:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101943:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10194a:	24 1f                	and    $0x1f,%al
  10194c:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101951:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101958:	24 f0                	and    $0xf0,%al
  10195a:	0c 0e                	or     $0xe,%al
  10195c:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101961:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101968:	24 ef                	and    $0xef,%al
  10196a:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10196f:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101976:	0c 60                	or     $0x60,%al
  101978:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10197d:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101984:	0c 80                	or     $0x80,%al
  101986:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10198b:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101990:	c1 e8 10             	shr    $0x10,%eax
  101993:	0f b7 c0             	movzwl %ax,%eax
  101996:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  10199c:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  1019a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019a6:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
  1019a9:	90                   	nop
  1019aa:	c9                   	leave  
  1019ab:	c3                   	ret    

001019ac <trapname>:

static const char *
trapname(int trapno) {
  1019ac:	55                   	push   %ebp
  1019ad:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019af:	8b 45 08             	mov    0x8(%ebp),%eax
  1019b2:	83 f8 13             	cmp    $0x13,%eax
  1019b5:	77 0c                	ja     1019c3 <trapname+0x17>
        return excnames[trapno];
  1019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ba:	8b 04 85 a0 3c 10 00 	mov    0x103ca0(,%eax,4),%eax
  1019c1:	eb 18                	jmp    1019db <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019c3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019c7:	7e 0d                	jle    1019d6 <trapname+0x2a>
  1019c9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019cd:	7f 07                	jg     1019d6 <trapname+0x2a>
        return "Hardware Interrupt";
  1019cf:	b8 4a 39 10 00       	mov    $0x10394a,%eax
  1019d4:	eb 05                	jmp    1019db <trapname+0x2f>
    }
    return "(unknown trap)";
  1019d6:	b8 5d 39 10 00       	mov    $0x10395d,%eax
}
  1019db:	5d                   	pop    %ebp
  1019dc:	c3                   	ret    

001019dd <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019dd:	55                   	push   %ebp
  1019de:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1019e3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019e7:	83 f8 08             	cmp    $0x8,%eax
  1019ea:	0f 94 c0             	sete   %al
  1019ed:	0f b6 c0             	movzbl %al,%eax
}
  1019f0:	5d                   	pop    %ebp
  1019f1:	c3                   	ret    

001019f2 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019f2:	55                   	push   %ebp
  1019f3:	89 e5                	mov    %esp,%ebp
  1019f5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019ff:	c7 04 24 9e 39 10 00 	movl   $0x10399e,(%esp)
  101a06:	e8 61 e8 ff ff       	call   10026c <cprintf>
    print_regs(&tf->tf_regs);
  101a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0e:	89 04 24             	mov    %eax,(%esp)
  101a11:	e8 8f 01 00 00       	call   101ba5 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a16:	8b 45 08             	mov    0x8(%ebp),%eax
  101a19:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a21:	c7 04 24 af 39 10 00 	movl   $0x1039af,(%esp)
  101a28:	e8 3f e8 ff ff       	call   10026c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a30:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a38:	c7 04 24 c2 39 10 00 	movl   $0x1039c2,(%esp)
  101a3f:	e8 28 e8 ff ff       	call   10026c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a44:	8b 45 08             	mov    0x8(%ebp),%eax
  101a47:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a4f:	c7 04 24 d5 39 10 00 	movl   $0x1039d5,(%esp)
  101a56:	e8 11 e8 ff ff       	call   10026c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a66:	c7 04 24 e8 39 10 00 	movl   $0x1039e8,(%esp)
  101a6d:	e8 fa e7 ff ff       	call   10026c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a72:	8b 45 08             	mov    0x8(%ebp),%eax
  101a75:	8b 40 30             	mov    0x30(%eax),%eax
  101a78:	89 04 24             	mov    %eax,(%esp)
  101a7b:	e8 2c ff ff ff       	call   1019ac <trapname>
  101a80:	89 c2                	mov    %eax,%edx
  101a82:	8b 45 08             	mov    0x8(%ebp),%eax
  101a85:	8b 40 30             	mov    0x30(%eax),%eax
  101a88:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a90:	c7 04 24 fb 39 10 00 	movl   $0x1039fb,(%esp)
  101a97:	e8 d0 e7 ff ff       	call   10026c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a9f:	8b 40 34             	mov    0x34(%eax),%eax
  101aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aa6:	c7 04 24 0d 3a 10 00 	movl   $0x103a0d,(%esp)
  101aad:	e8 ba e7 ff ff       	call   10026c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab5:	8b 40 38             	mov    0x38(%eax),%eax
  101ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abc:	c7 04 24 1c 3a 10 00 	movl   $0x103a1c,(%esp)
  101ac3:	e8 a4 e7 ff ff       	call   10026c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  101acb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad3:	c7 04 24 2b 3a 10 00 	movl   $0x103a2b,(%esp)
  101ada:	e8 8d e7 ff ff       	call   10026c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101adf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae2:	8b 40 40             	mov    0x40(%eax),%eax
  101ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae9:	c7 04 24 3e 3a 10 00 	movl   $0x103a3e,(%esp)
  101af0:	e8 77 e7 ff ff       	call   10026c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101afc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b03:	eb 3d                	jmp    101b42 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b05:	8b 45 08             	mov    0x8(%ebp),%eax
  101b08:	8b 50 40             	mov    0x40(%eax),%edx
  101b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b0e:	21 d0                	and    %edx,%eax
  101b10:	85 c0                	test   %eax,%eax
  101b12:	74 28                	je     101b3c <print_trapframe+0x14a>
  101b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b17:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b1e:	85 c0                	test   %eax,%eax
  101b20:	74 1a                	je     101b3c <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b25:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b30:	c7 04 24 4d 3a 10 00 	movl   $0x103a4d,(%esp)
  101b37:	e8 30 e7 ff ff       	call   10026c <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b3c:	ff 45 f4             	incl   -0xc(%ebp)
  101b3f:	d1 65 f0             	shll   -0x10(%ebp)
  101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b45:	83 f8 17             	cmp    $0x17,%eax
  101b48:	76 bb                	jbe    101b05 <print_trapframe+0x113>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4d:	8b 40 40             	mov    0x40(%eax),%eax
  101b50:	c1 e8 0c             	shr    $0xc,%eax
  101b53:	83 e0 03             	and    $0x3,%eax
  101b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5a:	c7 04 24 51 3a 10 00 	movl   $0x103a51,(%esp)
  101b61:	e8 06 e7 ff ff       	call   10026c <cprintf>

    if (!trap_in_kernel(tf)) {
  101b66:	8b 45 08             	mov    0x8(%ebp),%eax
  101b69:	89 04 24             	mov    %eax,(%esp)
  101b6c:	e8 6c fe ff ff       	call   1019dd <trap_in_kernel>
  101b71:	85 c0                	test   %eax,%eax
  101b73:	75 2d                	jne    101ba2 <print_trapframe+0x1b0>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b75:	8b 45 08             	mov    0x8(%ebp),%eax
  101b78:	8b 40 44             	mov    0x44(%eax),%eax
  101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7f:	c7 04 24 5a 3a 10 00 	movl   $0x103a5a,(%esp)
  101b86:	e8 e1 e6 ff ff       	call   10026c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b96:	c7 04 24 69 3a 10 00 	movl   $0x103a69,(%esp)
  101b9d:	e8 ca e6 ff ff       	call   10026c <cprintf>
    }
}
  101ba2:	90                   	nop
  101ba3:	c9                   	leave  
  101ba4:	c3                   	ret    

00101ba5 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ba5:	55                   	push   %ebp
  101ba6:	89 e5                	mov    %esp,%ebp
  101ba8:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bab:	8b 45 08             	mov    0x8(%ebp),%eax
  101bae:	8b 00                	mov    (%eax),%eax
  101bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb4:	c7 04 24 7c 3a 10 00 	movl   $0x103a7c,(%esp)
  101bbb:	e8 ac e6 ff ff       	call   10026c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc3:	8b 40 04             	mov    0x4(%eax),%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 8b 3a 10 00 	movl   $0x103a8b,(%esp)
  101bd1:	e8 96 e6 ff ff       	call   10026c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd9:	8b 40 08             	mov    0x8(%eax),%eax
  101bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be0:	c7 04 24 9a 3a 10 00 	movl   $0x103a9a,(%esp)
  101be7:	e8 80 e6 ff ff       	call   10026c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bec:	8b 45 08             	mov    0x8(%ebp),%eax
  101bef:	8b 40 0c             	mov    0xc(%eax),%eax
  101bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf6:	c7 04 24 a9 3a 10 00 	movl   $0x103aa9,(%esp)
  101bfd:	e8 6a e6 ff ff       	call   10026c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c02:	8b 45 08             	mov    0x8(%ebp),%eax
  101c05:	8b 40 10             	mov    0x10(%eax),%eax
  101c08:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0c:	c7 04 24 b8 3a 10 00 	movl   $0x103ab8,(%esp)
  101c13:	e8 54 e6 ff ff       	call   10026c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c18:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1b:	8b 40 14             	mov    0x14(%eax),%eax
  101c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c22:	c7 04 24 c7 3a 10 00 	movl   $0x103ac7,(%esp)
  101c29:	e8 3e e6 ff ff       	call   10026c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c31:	8b 40 18             	mov    0x18(%eax),%eax
  101c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c38:	c7 04 24 d6 3a 10 00 	movl   $0x103ad6,(%esp)
  101c3f:	e8 28 e6 ff ff       	call   10026c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c44:	8b 45 08             	mov    0x8(%ebp),%eax
  101c47:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4e:	c7 04 24 e5 3a 10 00 	movl   $0x103ae5,(%esp)
  101c55:	e8 12 e6 ff ff       	call   10026c <cprintf>
}
  101c5a:	90                   	nop
  101c5b:	c9                   	leave  
  101c5c:	c3                   	ret    

00101c5d <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c5d:	55                   	push   %ebp
  101c5e:	89 e5                	mov    %esp,%ebp
  101c60:	57                   	push   %edi
  101c61:	56                   	push   %esi
  101c62:	53                   	push   %ebx
  101c63:	83 ec 7c             	sub    $0x7c,%esp
    char c;

    switch (tf->tf_trapno) {
  101c66:	8b 45 08             	mov    0x8(%ebp),%eax
  101c69:	8b 40 30             	mov    0x30(%eax),%eax
  101c6c:	83 f8 2f             	cmp    $0x2f,%eax
  101c6f:	77 21                	ja     101c92 <trap_dispatch+0x35>
  101c71:	83 f8 2e             	cmp    $0x2e,%eax
  101c74:	0f 83 38 02 00 00    	jae    101eb2 <trap_dispatch+0x255>
  101c7a:	83 f8 21             	cmp    $0x21,%eax
  101c7d:	0f 84 95 00 00 00    	je     101d18 <trap_dispatch+0xbb>
  101c83:	83 f8 24             	cmp    $0x24,%eax
  101c86:	74 67                	je     101cef <trap_dispatch+0x92>
  101c88:	83 f8 20             	cmp    $0x20,%eax
  101c8b:	74 1c                	je     101ca9 <trap_dispatch+0x4c>
  101c8d:	e9 eb 01 00 00       	jmp    101e7d <trap_dispatch+0x220>
  101c92:	83 f8 78             	cmp    $0x78,%eax
  101c95:	0f 84 a6 00 00 00    	je     101d41 <trap_dispatch+0xe4>
  101c9b:	83 f8 79             	cmp    $0x79,%eax
  101c9e:	0f 84 63 01 00 00    	je     101e07 <trap_dispatch+0x1aa>
  101ca4:	e9 d4 01 00 00       	jmp    101e7d <trap_dispatch+0x220>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101ca9:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cae:	40                   	inc    %eax
  101caf:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if(ticks % TICK_NUM == 0 )
  101cb4:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101cba:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cbf:	89 c8                	mov    %ecx,%eax
  101cc1:	f7 e2                	mul    %edx
  101cc3:	c1 ea 05             	shr    $0x5,%edx
  101cc6:	89 d0                	mov    %edx,%eax
  101cc8:	c1 e0 02             	shl    $0x2,%eax
  101ccb:	01 d0                	add    %edx,%eax
  101ccd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101cd4:	01 d0                	add    %edx,%eax
  101cd6:	c1 e0 02             	shl    $0x2,%eax
  101cd9:	29 c1                	sub    %eax,%ecx
  101cdb:	89 ca                	mov    %ecx,%edx
  101cdd:	85 d2                	test   %edx,%edx
  101cdf:	0f 85 d0 01 00 00    	jne    101eb5 <trap_dispatch+0x258>
        {
          print_ticks();
  101ce5:	e8 33 fb ff ff       	call   10181d <print_ticks>
        }
        break;
  101cea:	e9 c6 01 00 00       	jmp    101eb5 <trap_dispatch+0x258>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cef:	e8 f9 f8 ff ff       	call   1015ed <cons_getc>
  101cf4:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cf7:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101cfb:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101cff:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d07:	c7 04 24 f4 3a 10 00 	movl   $0x103af4,(%esp)
  101d0e:	e8 59 e5 ff ff       	call   10026c <cprintf>
        break;
  101d13:	e9 a4 01 00 00       	jmp    101ebc <trap_dispatch+0x25f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d18:	e8 d0 f8 ff ff       	call   1015ed <cons_getc>
  101d1d:	88 45 e3             	mov    %al,-0x1d(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d20:	0f be 55 e3          	movsbl -0x1d(%ebp),%edx
  101d24:	0f be 45 e3          	movsbl -0x1d(%ebp),%eax
  101d28:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d30:	c7 04 24 06 3b 10 00 	movl   $0x103b06,(%esp)
  101d37:	e8 30 e5 ff ff       	call   10026c <cprintf>
        break;
  101d3c:	e9 7b 01 00 00       	jmp    101ebc <trap_dispatch+0x25f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
      if (tf->tf_cs!=USER_CS)
  101d41:	8b 45 08             	mov    0x8(%ebp),%eax
  101d44:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d48:	83 f8 1b             	cmp    $0x1b,%eax
  101d4b:	0f 84 67 01 00 00    	je     101eb8 <trap_dispatch+0x25b>
      {
        struct trapframe temp1 = *tf;//保留寄存器值
  101d51:	8b 55 08             	mov    0x8(%ebp),%edx
  101d54:	8d 45 97             	lea    -0x69(%ebp),%eax
  101d57:	bb 4c 00 00 00       	mov    $0x4c,%ebx
  101d5c:	89 c1                	mov    %eax,%ecx
  101d5e:	83 e1 01             	and    $0x1,%ecx
  101d61:	85 c9                	test   %ecx,%ecx
  101d63:	74 0c                	je     101d71 <trap_dispatch+0x114>
  101d65:	0f b6 0a             	movzbl (%edx),%ecx
  101d68:	88 08                	mov    %cl,(%eax)
  101d6a:	8d 40 01             	lea    0x1(%eax),%eax
  101d6d:	8d 52 01             	lea    0x1(%edx),%edx
  101d70:	4b                   	dec    %ebx
  101d71:	89 c1                	mov    %eax,%ecx
  101d73:	83 e1 02             	and    $0x2,%ecx
  101d76:	85 c9                	test   %ecx,%ecx
  101d78:	74 0f                	je     101d89 <trap_dispatch+0x12c>
  101d7a:	0f b7 0a             	movzwl (%edx),%ecx
  101d7d:	66 89 08             	mov    %cx,(%eax)
  101d80:	8d 40 02             	lea    0x2(%eax),%eax
  101d83:	8d 52 02             	lea    0x2(%edx),%edx
  101d86:	83 eb 02             	sub    $0x2,%ebx
  101d89:	89 df                	mov    %ebx,%edi
  101d8b:	83 e7 fc             	and    $0xfffffffc,%edi
  101d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  101d93:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
  101d96:	89 34 08             	mov    %esi,(%eax,%ecx,1)
  101d99:	83 c1 04             	add    $0x4,%ecx
  101d9c:	39 f9                	cmp    %edi,%ecx
  101d9e:	72 f3                	jb     101d93 <trap_dispatch+0x136>
  101da0:	01 c8                	add    %ecx,%eax
  101da2:	01 ca                	add    %ecx,%edx
  101da4:	b9 00 00 00 00       	mov    $0x0,%ecx
  101da9:	89 de                	mov    %ebx,%esi
  101dab:	83 e6 02             	and    $0x2,%esi
  101dae:	85 f6                	test   %esi,%esi
  101db0:	74 0b                	je     101dbd <trap_dispatch+0x160>
  101db2:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
  101db6:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
  101dba:	83 c1 02             	add    $0x2,%ecx
  101dbd:	83 e3 01             	and    $0x1,%ebx
  101dc0:	85 db                	test   %ebx,%ebx
  101dc2:	74 07                	je     101dcb <trap_dispatch+0x16e>
  101dc4:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
  101dc8:	88 14 08             	mov    %dl,(%eax,%ecx,1)
        temp1.tf_cs = USER_CS;
  101dcb:	66 c7 45 d3 1b 00    	movw   $0x1b,-0x2d(%ebp)
        temp1.tf_es = USER_DS;
  101dd1:	66 c7 45 bf 23 00    	movw   $0x23,-0x41(%ebp)
        temp1.tf_ds=USER_DS;
  101dd7:	66 c7 45 c3 23 00    	movw   $0x23,-0x3d(%ebp)
        temp1.tf_ss = USER_DS;
  101ddd:	66 c7 45 df 23 00    	movw   $0x23,-0x21(%ebp)
        temp1.tf_esp=(uint32_t)tf+sizeof(struct trapframe) -8;
  101de3:	8b 45 08             	mov    0x8(%ebp),%eax
  101de6:	83 c0 44             	add    $0x44,%eax
  101de9:	89 45 db             	mov    %eax,-0x25(%ebp)

        temp1.tf_eflags |=FL_IOPL_MASK;
  101dec:	8b 45 d7             	mov    -0x29(%ebp),%eax
  101def:	0d 00 30 00 00       	or     $0x3000,%eax
  101df4:	89 45 d7             	mov    %eax,-0x29(%ebp)

        *((uint32_t *)tf -1) = (uint32_t) &temp1;
  101df7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfa:	8d 50 fc             	lea    -0x4(%eax),%edx
  101dfd:	8d 45 97             	lea    -0x69(%ebp),%eax
  101e00:	89 02                	mov    %eax,(%edx)
      }
      break;
  101e02:	e9 b1 00 00 00       	jmp    101eb8 <trap_dispatch+0x25b>
    case T_SWITCH_TOK:
    if (tf->tf_cs != KERNEL_CS) {
  101e07:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e0e:	83 f8 08             	cmp    $0x8,%eax
  101e11:	0f 84 a4 00 00 00    	je     101ebb <trap_dispatch+0x25e>
        tf->tf_cs = KERNEL_CS;
  101e17:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1a:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = KERNEL_DS;
  101e20:	8b 45 08             	mov    0x8(%ebp),%eax
  101e23:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101e29:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2c:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e30:	8b 45 08             	mov    0x8(%ebp),%eax
  101e33:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags &= ~FL_IOPL_MASK;
  101e37:	8b 45 08             	mov    0x8(%ebp),%eax
  101e3a:	8b 40 40             	mov    0x40(%eax),%eax
  101e3d:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101e42:	89 c2                	mov    %eax,%edx
  101e44:	8b 45 08             	mov    0x8(%ebp),%eax
  101e47:	89 50 40             	mov    %edx,0x40(%eax)
        struct trapframe*  temp2 = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4d:	8b 40 44             	mov    0x44(%eax),%eax
  101e50:	83 e8 44             	sub    $0x44,%eax
  101e53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        memmove(temp2, tf, sizeof(struct trapframe) - 8);
  101e56:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101e5d:	00 
  101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e68:	89 04 24             	mov    %eax,(%esp)
  101e6b:	e8 97 0f 00 00       	call   102e07 <memmove>
        *((uint32_t *)tf - 1) = (uint32_t)temp2;
  101e70:	8b 45 08             	mov    0x8(%ebp),%eax
  101e73:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  101e79:	89 02                	mov    %eax,(%edx)
    }
        break;
  101e7b:	eb 3e                	jmp    101ebb <trap_dispatch+0x25e>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e84:	83 e0 03             	and    $0x3,%eax
  101e87:	85 c0                	test   %eax,%eax
  101e89:	75 31                	jne    101ebc <trap_dispatch+0x25f>
            print_trapframe(tf);
  101e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8e:	89 04 24             	mov    %eax,(%esp)
  101e91:	e8 5c fb ff ff       	call   1019f2 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e96:	c7 44 24 08 15 3b 10 	movl   $0x103b15,0x8(%esp)
  101e9d:	00 
  101e9e:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  101ea5:	00 
  101ea6:	c7 04 24 31 3b 10 00 	movl   $0x103b31,(%esp)
  101ead:	e8 11 e5 ff ff       	call   1003c3 <__panic>
        break;
  101eb2:	90                   	nop
  101eb3:	eb 07                	jmp    101ebc <trap_dispatch+0x25f>
        break;
  101eb5:	90                   	nop
  101eb6:	eb 04                	jmp    101ebc <trap_dispatch+0x25f>
      break;
  101eb8:	90                   	nop
  101eb9:	eb 01                	jmp    101ebc <trap_dispatch+0x25f>
        break;
  101ebb:	90                   	nop
        }
    }
}
  101ebc:	90                   	nop
  101ebd:	83 c4 7c             	add    $0x7c,%esp
  101ec0:	5b                   	pop    %ebx
  101ec1:	5e                   	pop    %esi
  101ec2:	5f                   	pop    %edi
  101ec3:	5d                   	pop    %ebp
  101ec4:	c3                   	ret    

00101ec5 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101ec5:	55                   	push   %ebp
  101ec6:	89 e5                	mov    %esp,%ebp
  101ec8:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ece:	89 04 24             	mov    %eax,(%esp)
  101ed1:	e8 87 fd ff ff       	call   101c5d <trap_dispatch>
}
  101ed6:	90                   	nop
  101ed7:	c9                   	leave  
  101ed8:	c3                   	ret    

00101ed9 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101ed9:	6a 00                	push   $0x0
  pushl $0
  101edb:	6a 00                	push   $0x0
  jmp __alltraps
  101edd:	e9 69 0a 00 00       	jmp    10294b <__alltraps>

00101ee2 <vector1>:
.globl vector1
vector1:
  pushl $0
  101ee2:	6a 00                	push   $0x0
  pushl $1
  101ee4:	6a 01                	push   $0x1
  jmp __alltraps
  101ee6:	e9 60 0a 00 00       	jmp    10294b <__alltraps>

00101eeb <vector2>:
.globl vector2
vector2:
  pushl $0
  101eeb:	6a 00                	push   $0x0
  pushl $2
  101eed:	6a 02                	push   $0x2
  jmp __alltraps
  101eef:	e9 57 0a 00 00       	jmp    10294b <__alltraps>

00101ef4 <vector3>:
.globl vector3
vector3:
  pushl $0
  101ef4:	6a 00                	push   $0x0
  pushl $3
  101ef6:	6a 03                	push   $0x3
  jmp __alltraps
  101ef8:	e9 4e 0a 00 00       	jmp    10294b <__alltraps>

00101efd <vector4>:
.globl vector4
vector4:
  pushl $0
  101efd:	6a 00                	push   $0x0
  pushl $4
  101eff:	6a 04                	push   $0x4
  jmp __alltraps
  101f01:	e9 45 0a 00 00       	jmp    10294b <__alltraps>

00101f06 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f06:	6a 00                	push   $0x0
  pushl $5
  101f08:	6a 05                	push   $0x5
  jmp __alltraps
  101f0a:	e9 3c 0a 00 00       	jmp    10294b <__alltraps>

00101f0f <vector6>:
.globl vector6
vector6:
  pushl $0
  101f0f:	6a 00                	push   $0x0
  pushl $6
  101f11:	6a 06                	push   $0x6
  jmp __alltraps
  101f13:	e9 33 0a 00 00       	jmp    10294b <__alltraps>

00101f18 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f18:	6a 00                	push   $0x0
  pushl $7
  101f1a:	6a 07                	push   $0x7
  jmp __alltraps
  101f1c:	e9 2a 0a 00 00       	jmp    10294b <__alltraps>

00101f21 <vector8>:
.globl vector8
vector8:
  pushl $8
  101f21:	6a 08                	push   $0x8
  jmp __alltraps
  101f23:	e9 23 0a 00 00       	jmp    10294b <__alltraps>

00101f28 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $9
  101f2a:	6a 09                	push   $0x9
  jmp __alltraps
  101f2c:	e9 1a 0a 00 00       	jmp    10294b <__alltraps>

00101f31 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f31:	6a 0a                	push   $0xa
  jmp __alltraps
  101f33:	e9 13 0a 00 00       	jmp    10294b <__alltraps>

00101f38 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f38:	6a 0b                	push   $0xb
  jmp __alltraps
  101f3a:	e9 0c 0a 00 00       	jmp    10294b <__alltraps>

00101f3f <vector12>:
.globl vector12
vector12:
  pushl $12
  101f3f:	6a 0c                	push   $0xc
  jmp __alltraps
  101f41:	e9 05 0a 00 00       	jmp    10294b <__alltraps>

00101f46 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f46:	6a 0d                	push   $0xd
  jmp __alltraps
  101f48:	e9 fe 09 00 00       	jmp    10294b <__alltraps>

00101f4d <vector14>:
.globl vector14
vector14:
  pushl $14
  101f4d:	6a 0e                	push   $0xe
  jmp __alltraps
  101f4f:	e9 f7 09 00 00       	jmp    10294b <__alltraps>

00101f54 <vector15>:
.globl vector15
vector15:
  pushl $0
  101f54:	6a 00                	push   $0x0
  pushl $15
  101f56:	6a 0f                	push   $0xf
  jmp __alltraps
  101f58:	e9 ee 09 00 00       	jmp    10294b <__alltraps>

00101f5d <vector16>:
.globl vector16
vector16:
  pushl $0
  101f5d:	6a 00                	push   $0x0
  pushl $16
  101f5f:	6a 10                	push   $0x10
  jmp __alltraps
  101f61:	e9 e5 09 00 00       	jmp    10294b <__alltraps>

00101f66 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f66:	6a 11                	push   $0x11
  jmp __alltraps
  101f68:	e9 de 09 00 00       	jmp    10294b <__alltraps>

00101f6d <vector18>:
.globl vector18
vector18:
  pushl $0
  101f6d:	6a 00                	push   $0x0
  pushl $18
  101f6f:	6a 12                	push   $0x12
  jmp __alltraps
  101f71:	e9 d5 09 00 00       	jmp    10294b <__alltraps>

00101f76 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f76:	6a 00                	push   $0x0
  pushl $19
  101f78:	6a 13                	push   $0x13
  jmp __alltraps
  101f7a:	e9 cc 09 00 00       	jmp    10294b <__alltraps>

00101f7f <vector20>:
.globl vector20
vector20:
  pushl $0
  101f7f:	6a 00                	push   $0x0
  pushl $20
  101f81:	6a 14                	push   $0x14
  jmp __alltraps
  101f83:	e9 c3 09 00 00       	jmp    10294b <__alltraps>

00101f88 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f88:	6a 00                	push   $0x0
  pushl $21
  101f8a:	6a 15                	push   $0x15
  jmp __alltraps
  101f8c:	e9 ba 09 00 00       	jmp    10294b <__alltraps>

00101f91 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f91:	6a 00                	push   $0x0
  pushl $22
  101f93:	6a 16                	push   $0x16
  jmp __alltraps
  101f95:	e9 b1 09 00 00       	jmp    10294b <__alltraps>

00101f9a <vector23>:
.globl vector23
vector23:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $23
  101f9c:	6a 17                	push   $0x17
  jmp __alltraps
  101f9e:	e9 a8 09 00 00       	jmp    10294b <__alltraps>

00101fa3 <vector24>:
.globl vector24
vector24:
  pushl $0
  101fa3:	6a 00                	push   $0x0
  pushl $24
  101fa5:	6a 18                	push   $0x18
  jmp __alltraps
  101fa7:	e9 9f 09 00 00       	jmp    10294b <__alltraps>

00101fac <vector25>:
.globl vector25
vector25:
  pushl $0
  101fac:	6a 00                	push   $0x0
  pushl $25
  101fae:	6a 19                	push   $0x19
  jmp __alltraps
  101fb0:	e9 96 09 00 00       	jmp    10294b <__alltraps>

00101fb5 <vector26>:
.globl vector26
vector26:
  pushl $0
  101fb5:	6a 00                	push   $0x0
  pushl $26
  101fb7:	6a 1a                	push   $0x1a
  jmp __alltraps
  101fb9:	e9 8d 09 00 00       	jmp    10294b <__alltraps>

00101fbe <vector27>:
.globl vector27
vector27:
  pushl $0
  101fbe:	6a 00                	push   $0x0
  pushl $27
  101fc0:	6a 1b                	push   $0x1b
  jmp __alltraps
  101fc2:	e9 84 09 00 00       	jmp    10294b <__alltraps>

00101fc7 <vector28>:
.globl vector28
vector28:
  pushl $0
  101fc7:	6a 00                	push   $0x0
  pushl $28
  101fc9:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fcb:	e9 7b 09 00 00       	jmp    10294b <__alltraps>

00101fd0 <vector29>:
.globl vector29
vector29:
  pushl $0
  101fd0:	6a 00                	push   $0x0
  pushl $29
  101fd2:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fd4:	e9 72 09 00 00       	jmp    10294b <__alltraps>

00101fd9 <vector30>:
.globl vector30
vector30:
  pushl $0
  101fd9:	6a 00                	push   $0x0
  pushl $30
  101fdb:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fdd:	e9 69 09 00 00       	jmp    10294b <__alltraps>

00101fe2 <vector31>:
.globl vector31
vector31:
  pushl $0
  101fe2:	6a 00                	push   $0x0
  pushl $31
  101fe4:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fe6:	e9 60 09 00 00       	jmp    10294b <__alltraps>

00101feb <vector32>:
.globl vector32
vector32:
  pushl $0
  101feb:	6a 00                	push   $0x0
  pushl $32
  101fed:	6a 20                	push   $0x20
  jmp __alltraps
  101fef:	e9 57 09 00 00       	jmp    10294b <__alltraps>

00101ff4 <vector33>:
.globl vector33
vector33:
  pushl $0
  101ff4:	6a 00                	push   $0x0
  pushl $33
  101ff6:	6a 21                	push   $0x21
  jmp __alltraps
  101ff8:	e9 4e 09 00 00       	jmp    10294b <__alltraps>

00101ffd <vector34>:
.globl vector34
vector34:
  pushl $0
  101ffd:	6a 00                	push   $0x0
  pushl $34
  101fff:	6a 22                	push   $0x22
  jmp __alltraps
  102001:	e9 45 09 00 00       	jmp    10294b <__alltraps>

00102006 <vector35>:
.globl vector35
vector35:
  pushl $0
  102006:	6a 00                	push   $0x0
  pushl $35
  102008:	6a 23                	push   $0x23
  jmp __alltraps
  10200a:	e9 3c 09 00 00       	jmp    10294b <__alltraps>

0010200f <vector36>:
.globl vector36
vector36:
  pushl $0
  10200f:	6a 00                	push   $0x0
  pushl $36
  102011:	6a 24                	push   $0x24
  jmp __alltraps
  102013:	e9 33 09 00 00       	jmp    10294b <__alltraps>

00102018 <vector37>:
.globl vector37
vector37:
  pushl $0
  102018:	6a 00                	push   $0x0
  pushl $37
  10201a:	6a 25                	push   $0x25
  jmp __alltraps
  10201c:	e9 2a 09 00 00       	jmp    10294b <__alltraps>

00102021 <vector38>:
.globl vector38
vector38:
  pushl $0
  102021:	6a 00                	push   $0x0
  pushl $38
  102023:	6a 26                	push   $0x26
  jmp __alltraps
  102025:	e9 21 09 00 00       	jmp    10294b <__alltraps>

0010202a <vector39>:
.globl vector39
vector39:
  pushl $0
  10202a:	6a 00                	push   $0x0
  pushl $39
  10202c:	6a 27                	push   $0x27
  jmp __alltraps
  10202e:	e9 18 09 00 00       	jmp    10294b <__alltraps>

00102033 <vector40>:
.globl vector40
vector40:
  pushl $0
  102033:	6a 00                	push   $0x0
  pushl $40
  102035:	6a 28                	push   $0x28
  jmp __alltraps
  102037:	e9 0f 09 00 00       	jmp    10294b <__alltraps>

0010203c <vector41>:
.globl vector41
vector41:
  pushl $0
  10203c:	6a 00                	push   $0x0
  pushl $41
  10203e:	6a 29                	push   $0x29
  jmp __alltraps
  102040:	e9 06 09 00 00       	jmp    10294b <__alltraps>

00102045 <vector42>:
.globl vector42
vector42:
  pushl $0
  102045:	6a 00                	push   $0x0
  pushl $42
  102047:	6a 2a                	push   $0x2a
  jmp __alltraps
  102049:	e9 fd 08 00 00       	jmp    10294b <__alltraps>

0010204e <vector43>:
.globl vector43
vector43:
  pushl $0
  10204e:	6a 00                	push   $0x0
  pushl $43
  102050:	6a 2b                	push   $0x2b
  jmp __alltraps
  102052:	e9 f4 08 00 00       	jmp    10294b <__alltraps>

00102057 <vector44>:
.globl vector44
vector44:
  pushl $0
  102057:	6a 00                	push   $0x0
  pushl $44
  102059:	6a 2c                	push   $0x2c
  jmp __alltraps
  10205b:	e9 eb 08 00 00       	jmp    10294b <__alltraps>

00102060 <vector45>:
.globl vector45
vector45:
  pushl $0
  102060:	6a 00                	push   $0x0
  pushl $45
  102062:	6a 2d                	push   $0x2d
  jmp __alltraps
  102064:	e9 e2 08 00 00       	jmp    10294b <__alltraps>

00102069 <vector46>:
.globl vector46
vector46:
  pushl $0
  102069:	6a 00                	push   $0x0
  pushl $46
  10206b:	6a 2e                	push   $0x2e
  jmp __alltraps
  10206d:	e9 d9 08 00 00       	jmp    10294b <__alltraps>

00102072 <vector47>:
.globl vector47
vector47:
  pushl $0
  102072:	6a 00                	push   $0x0
  pushl $47
  102074:	6a 2f                	push   $0x2f
  jmp __alltraps
  102076:	e9 d0 08 00 00       	jmp    10294b <__alltraps>

0010207b <vector48>:
.globl vector48
vector48:
  pushl $0
  10207b:	6a 00                	push   $0x0
  pushl $48
  10207d:	6a 30                	push   $0x30
  jmp __alltraps
  10207f:	e9 c7 08 00 00       	jmp    10294b <__alltraps>

00102084 <vector49>:
.globl vector49
vector49:
  pushl $0
  102084:	6a 00                	push   $0x0
  pushl $49
  102086:	6a 31                	push   $0x31
  jmp __alltraps
  102088:	e9 be 08 00 00       	jmp    10294b <__alltraps>

0010208d <vector50>:
.globl vector50
vector50:
  pushl $0
  10208d:	6a 00                	push   $0x0
  pushl $50
  10208f:	6a 32                	push   $0x32
  jmp __alltraps
  102091:	e9 b5 08 00 00       	jmp    10294b <__alltraps>

00102096 <vector51>:
.globl vector51
vector51:
  pushl $0
  102096:	6a 00                	push   $0x0
  pushl $51
  102098:	6a 33                	push   $0x33
  jmp __alltraps
  10209a:	e9 ac 08 00 00       	jmp    10294b <__alltraps>

0010209f <vector52>:
.globl vector52
vector52:
  pushl $0
  10209f:	6a 00                	push   $0x0
  pushl $52
  1020a1:	6a 34                	push   $0x34
  jmp __alltraps
  1020a3:	e9 a3 08 00 00       	jmp    10294b <__alltraps>

001020a8 <vector53>:
.globl vector53
vector53:
  pushl $0
  1020a8:	6a 00                	push   $0x0
  pushl $53
  1020aa:	6a 35                	push   $0x35
  jmp __alltraps
  1020ac:	e9 9a 08 00 00       	jmp    10294b <__alltraps>

001020b1 <vector54>:
.globl vector54
vector54:
  pushl $0
  1020b1:	6a 00                	push   $0x0
  pushl $54
  1020b3:	6a 36                	push   $0x36
  jmp __alltraps
  1020b5:	e9 91 08 00 00       	jmp    10294b <__alltraps>

001020ba <vector55>:
.globl vector55
vector55:
  pushl $0
  1020ba:	6a 00                	push   $0x0
  pushl $55
  1020bc:	6a 37                	push   $0x37
  jmp __alltraps
  1020be:	e9 88 08 00 00       	jmp    10294b <__alltraps>

001020c3 <vector56>:
.globl vector56
vector56:
  pushl $0
  1020c3:	6a 00                	push   $0x0
  pushl $56
  1020c5:	6a 38                	push   $0x38
  jmp __alltraps
  1020c7:	e9 7f 08 00 00       	jmp    10294b <__alltraps>

001020cc <vector57>:
.globl vector57
vector57:
  pushl $0
  1020cc:	6a 00                	push   $0x0
  pushl $57
  1020ce:	6a 39                	push   $0x39
  jmp __alltraps
  1020d0:	e9 76 08 00 00       	jmp    10294b <__alltraps>

001020d5 <vector58>:
.globl vector58
vector58:
  pushl $0
  1020d5:	6a 00                	push   $0x0
  pushl $58
  1020d7:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020d9:	e9 6d 08 00 00       	jmp    10294b <__alltraps>

001020de <vector59>:
.globl vector59
vector59:
  pushl $0
  1020de:	6a 00                	push   $0x0
  pushl $59
  1020e0:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020e2:	e9 64 08 00 00       	jmp    10294b <__alltraps>

001020e7 <vector60>:
.globl vector60
vector60:
  pushl $0
  1020e7:	6a 00                	push   $0x0
  pushl $60
  1020e9:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020eb:	e9 5b 08 00 00       	jmp    10294b <__alltraps>

001020f0 <vector61>:
.globl vector61
vector61:
  pushl $0
  1020f0:	6a 00                	push   $0x0
  pushl $61
  1020f2:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020f4:	e9 52 08 00 00       	jmp    10294b <__alltraps>

001020f9 <vector62>:
.globl vector62
vector62:
  pushl $0
  1020f9:	6a 00                	push   $0x0
  pushl $62
  1020fb:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020fd:	e9 49 08 00 00       	jmp    10294b <__alltraps>

00102102 <vector63>:
.globl vector63
vector63:
  pushl $0
  102102:	6a 00                	push   $0x0
  pushl $63
  102104:	6a 3f                	push   $0x3f
  jmp __alltraps
  102106:	e9 40 08 00 00       	jmp    10294b <__alltraps>

0010210b <vector64>:
.globl vector64
vector64:
  pushl $0
  10210b:	6a 00                	push   $0x0
  pushl $64
  10210d:	6a 40                	push   $0x40
  jmp __alltraps
  10210f:	e9 37 08 00 00       	jmp    10294b <__alltraps>

00102114 <vector65>:
.globl vector65
vector65:
  pushl $0
  102114:	6a 00                	push   $0x0
  pushl $65
  102116:	6a 41                	push   $0x41
  jmp __alltraps
  102118:	e9 2e 08 00 00       	jmp    10294b <__alltraps>

0010211d <vector66>:
.globl vector66
vector66:
  pushl $0
  10211d:	6a 00                	push   $0x0
  pushl $66
  10211f:	6a 42                	push   $0x42
  jmp __alltraps
  102121:	e9 25 08 00 00       	jmp    10294b <__alltraps>

00102126 <vector67>:
.globl vector67
vector67:
  pushl $0
  102126:	6a 00                	push   $0x0
  pushl $67
  102128:	6a 43                	push   $0x43
  jmp __alltraps
  10212a:	e9 1c 08 00 00       	jmp    10294b <__alltraps>

0010212f <vector68>:
.globl vector68
vector68:
  pushl $0
  10212f:	6a 00                	push   $0x0
  pushl $68
  102131:	6a 44                	push   $0x44
  jmp __alltraps
  102133:	e9 13 08 00 00       	jmp    10294b <__alltraps>

00102138 <vector69>:
.globl vector69
vector69:
  pushl $0
  102138:	6a 00                	push   $0x0
  pushl $69
  10213a:	6a 45                	push   $0x45
  jmp __alltraps
  10213c:	e9 0a 08 00 00       	jmp    10294b <__alltraps>

00102141 <vector70>:
.globl vector70
vector70:
  pushl $0
  102141:	6a 00                	push   $0x0
  pushl $70
  102143:	6a 46                	push   $0x46
  jmp __alltraps
  102145:	e9 01 08 00 00       	jmp    10294b <__alltraps>

0010214a <vector71>:
.globl vector71
vector71:
  pushl $0
  10214a:	6a 00                	push   $0x0
  pushl $71
  10214c:	6a 47                	push   $0x47
  jmp __alltraps
  10214e:	e9 f8 07 00 00       	jmp    10294b <__alltraps>

00102153 <vector72>:
.globl vector72
vector72:
  pushl $0
  102153:	6a 00                	push   $0x0
  pushl $72
  102155:	6a 48                	push   $0x48
  jmp __alltraps
  102157:	e9 ef 07 00 00       	jmp    10294b <__alltraps>

0010215c <vector73>:
.globl vector73
vector73:
  pushl $0
  10215c:	6a 00                	push   $0x0
  pushl $73
  10215e:	6a 49                	push   $0x49
  jmp __alltraps
  102160:	e9 e6 07 00 00       	jmp    10294b <__alltraps>

00102165 <vector74>:
.globl vector74
vector74:
  pushl $0
  102165:	6a 00                	push   $0x0
  pushl $74
  102167:	6a 4a                	push   $0x4a
  jmp __alltraps
  102169:	e9 dd 07 00 00       	jmp    10294b <__alltraps>

0010216e <vector75>:
.globl vector75
vector75:
  pushl $0
  10216e:	6a 00                	push   $0x0
  pushl $75
  102170:	6a 4b                	push   $0x4b
  jmp __alltraps
  102172:	e9 d4 07 00 00       	jmp    10294b <__alltraps>

00102177 <vector76>:
.globl vector76
vector76:
  pushl $0
  102177:	6a 00                	push   $0x0
  pushl $76
  102179:	6a 4c                	push   $0x4c
  jmp __alltraps
  10217b:	e9 cb 07 00 00       	jmp    10294b <__alltraps>

00102180 <vector77>:
.globl vector77
vector77:
  pushl $0
  102180:	6a 00                	push   $0x0
  pushl $77
  102182:	6a 4d                	push   $0x4d
  jmp __alltraps
  102184:	e9 c2 07 00 00       	jmp    10294b <__alltraps>

00102189 <vector78>:
.globl vector78
vector78:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $78
  10218b:	6a 4e                	push   $0x4e
  jmp __alltraps
  10218d:	e9 b9 07 00 00       	jmp    10294b <__alltraps>

00102192 <vector79>:
.globl vector79
vector79:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $79
  102194:	6a 4f                	push   $0x4f
  jmp __alltraps
  102196:	e9 b0 07 00 00       	jmp    10294b <__alltraps>

0010219b <vector80>:
.globl vector80
vector80:
  pushl $0
  10219b:	6a 00                	push   $0x0
  pushl $80
  10219d:	6a 50                	push   $0x50
  jmp __alltraps
  10219f:	e9 a7 07 00 00       	jmp    10294b <__alltraps>

001021a4 <vector81>:
.globl vector81
vector81:
  pushl $0
  1021a4:	6a 00                	push   $0x0
  pushl $81
  1021a6:	6a 51                	push   $0x51
  jmp __alltraps
  1021a8:	e9 9e 07 00 00       	jmp    10294b <__alltraps>

001021ad <vector82>:
.globl vector82
vector82:
  pushl $0
  1021ad:	6a 00                	push   $0x0
  pushl $82
  1021af:	6a 52                	push   $0x52
  jmp __alltraps
  1021b1:	e9 95 07 00 00       	jmp    10294b <__alltraps>

001021b6 <vector83>:
.globl vector83
vector83:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $83
  1021b8:	6a 53                	push   $0x53
  jmp __alltraps
  1021ba:	e9 8c 07 00 00       	jmp    10294b <__alltraps>

001021bf <vector84>:
.globl vector84
vector84:
  pushl $0
  1021bf:	6a 00                	push   $0x0
  pushl $84
  1021c1:	6a 54                	push   $0x54
  jmp __alltraps
  1021c3:	e9 83 07 00 00       	jmp    10294b <__alltraps>

001021c8 <vector85>:
.globl vector85
vector85:
  pushl $0
  1021c8:	6a 00                	push   $0x0
  pushl $85
  1021ca:	6a 55                	push   $0x55
  jmp __alltraps
  1021cc:	e9 7a 07 00 00       	jmp    10294b <__alltraps>

001021d1 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021d1:	6a 00                	push   $0x0
  pushl $86
  1021d3:	6a 56                	push   $0x56
  jmp __alltraps
  1021d5:	e9 71 07 00 00       	jmp    10294b <__alltraps>

001021da <vector87>:
.globl vector87
vector87:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $87
  1021dc:	6a 57                	push   $0x57
  jmp __alltraps
  1021de:	e9 68 07 00 00       	jmp    10294b <__alltraps>

001021e3 <vector88>:
.globl vector88
vector88:
  pushl $0
  1021e3:	6a 00                	push   $0x0
  pushl $88
  1021e5:	6a 58                	push   $0x58
  jmp __alltraps
  1021e7:	e9 5f 07 00 00       	jmp    10294b <__alltraps>

001021ec <vector89>:
.globl vector89
vector89:
  pushl $0
  1021ec:	6a 00                	push   $0x0
  pushl $89
  1021ee:	6a 59                	push   $0x59
  jmp __alltraps
  1021f0:	e9 56 07 00 00       	jmp    10294b <__alltraps>

001021f5 <vector90>:
.globl vector90
vector90:
  pushl $0
  1021f5:	6a 00                	push   $0x0
  pushl $90
  1021f7:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021f9:	e9 4d 07 00 00       	jmp    10294b <__alltraps>

001021fe <vector91>:
.globl vector91
vector91:
  pushl $0
  1021fe:	6a 00                	push   $0x0
  pushl $91
  102200:	6a 5b                	push   $0x5b
  jmp __alltraps
  102202:	e9 44 07 00 00       	jmp    10294b <__alltraps>

00102207 <vector92>:
.globl vector92
vector92:
  pushl $0
  102207:	6a 00                	push   $0x0
  pushl $92
  102209:	6a 5c                	push   $0x5c
  jmp __alltraps
  10220b:	e9 3b 07 00 00       	jmp    10294b <__alltraps>

00102210 <vector93>:
.globl vector93
vector93:
  pushl $0
  102210:	6a 00                	push   $0x0
  pushl $93
  102212:	6a 5d                	push   $0x5d
  jmp __alltraps
  102214:	e9 32 07 00 00       	jmp    10294b <__alltraps>

00102219 <vector94>:
.globl vector94
vector94:
  pushl $0
  102219:	6a 00                	push   $0x0
  pushl $94
  10221b:	6a 5e                	push   $0x5e
  jmp __alltraps
  10221d:	e9 29 07 00 00       	jmp    10294b <__alltraps>

00102222 <vector95>:
.globl vector95
vector95:
  pushl $0
  102222:	6a 00                	push   $0x0
  pushl $95
  102224:	6a 5f                	push   $0x5f
  jmp __alltraps
  102226:	e9 20 07 00 00       	jmp    10294b <__alltraps>

0010222b <vector96>:
.globl vector96
vector96:
  pushl $0
  10222b:	6a 00                	push   $0x0
  pushl $96
  10222d:	6a 60                	push   $0x60
  jmp __alltraps
  10222f:	e9 17 07 00 00       	jmp    10294b <__alltraps>

00102234 <vector97>:
.globl vector97
vector97:
  pushl $0
  102234:	6a 00                	push   $0x0
  pushl $97
  102236:	6a 61                	push   $0x61
  jmp __alltraps
  102238:	e9 0e 07 00 00       	jmp    10294b <__alltraps>

0010223d <vector98>:
.globl vector98
vector98:
  pushl $0
  10223d:	6a 00                	push   $0x0
  pushl $98
  10223f:	6a 62                	push   $0x62
  jmp __alltraps
  102241:	e9 05 07 00 00       	jmp    10294b <__alltraps>

00102246 <vector99>:
.globl vector99
vector99:
  pushl $0
  102246:	6a 00                	push   $0x0
  pushl $99
  102248:	6a 63                	push   $0x63
  jmp __alltraps
  10224a:	e9 fc 06 00 00       	jmp    10294b <__alltraps>

0010224f <vector100>:
.globl vector100
vector100:
  pushl $0
  10224f:	6a 00                	push   $0x0
  pushl $100
  102251:	6a 64                	push   $0x64
  jmp __alltraps
  102253:	e9 f3 06 00 00       	jmp    10294b <__alltraps>

00102258 <vector101>:
.globl vector101
vector101:
  pushl $0
  102258:	6a 00                	push   $0x0
  pushl $101
  10225a:	6a 65                	push   $0x65
  jmp __alltraps
  10225c:	e9 ea 06 00 00       	jmp    10294b <__alltraps>

00102261 <vector102>:
.globl vector102
vector102:
  pushl $0
  102261:	6a 00                	push   $0x0
  pushl $102
  102263:	6a 66                	push   $0x66
  jmp __alltraps
  102265:	e9 e1 06 00 00       	jmp    10294b <__alltraps>

0010226a <vector103>:
.globl vector103
vector103:
  pushl $0
  10226a:	6a 00                	push   $0x0
  pushl $103
  10226c:	6a 67                	push   $0x67
  jmp __alltraps
  10226e:	e9 d8 06 00 00       	jmp    10294b <__alltraps>

00102273 <vector104>:
.globl vector104
vector104:
  pushl $0
  102273:	6a 00                	push   $0x0
  pushl $104
  102275:	6a 68                	push   $0x68
  jmp __alltraps
  102277:	e9 cf 06 00 00       	jmp    10294b <__alltraps>

0010227c <vector105>:
.globl vector105
vector105:
  pushl $0
  10227c:	6a 00                	push   $0x0
  pushl $105
  10227e:	6a 69                	push   $0x69
  jmp __alltraps
  102280:	e9 c6 06 00 00       	jmp    10294b <__alltraps>

00102285 <vector106>:
.globl vector106
vector106:
  pushl $0
  102285:	6a 00                	push   $0x0
  pushl $106
  102287:	6a 6a                	push   $0x6a
  jmp __alltraps
  102289:	e9 bd 06 00 00       	jmp    10294b <__alltraps>

0010228e <vector107>:
.globl vector107
vector107:
  pushl $0
  10228e:	6a 00                	push   $0x0
  pushl $107
  102290:	6a 6b                	push   $0x6b
  jmp __alltraps
  102292:	e9 b4 06 00 00       	jmp    10294b <__alltraps>

00102297 <vector108>:
.globl vector108
vector108:
  pushl $0
  102297:	6a 00                	push   $0x0
  pushl $108
  102299:	6a 6c                	push   $0x6c
  jmp __alltraps
  10229b:	e9 ab 06 00 00       	jmp    10294b <__alltraps>

001022a0 <vector109>:
.globl vector109
vector109:
  pushl $0
  1022a0:	6a 00                	push   $0x0
  pushl $109
  1022a2:	6a 6d                	push   $0x6d
  jmp __alltraps
  1022a4:	e9 a2 06 00 00       	jmp    10294b <__alltraps>

001022a9 <vector110>:
.globl vector110
vector110:
  pushl $0
  1022a9:	6a 00                	push   $0x0
  pushl $110
  1022ab:	6a 6e                	push   $0x6e
  jmp __alltraps
  1022ad:	e9 99 06 00 00       	jmp    10294b <__alltraps>

001022b2 <vector111>:
.globl vector111
vector111:
  pushl $0
  1022b2:	6a 00                	push   $0x0
  pushl $111
  1022b4:	6a 6f                	push   $0x6f
  jmp __alltraps
  1022b6:	e9 90 06 00 00       	jmp    10294b <__alltraps>

001022bb <vector112>:
.globl vector112
vector112:
  pushl $0
  1022bb:	6a 00                	push   $0x0
  pushl $112
  1022bd:	6a 70                	push   $0x70
  jmp __alltraps
  1022bf:	e9 87 06 00 00       	jmp    10294b <__alltraps>

001022c4 <vector113>:
.globl vector113
vector113:
  pushl $0
  1022c4:	6a 00                	push   $0x0
  pushl $113
  1022c6:	6a 71                	push   $0x71
  jmp __alltraps
  1022c8:	e9 7e 06 00 00       	jmp    10294b <__alltraps>

001022cd <vector114>:
.globl vector114
vector114:
  pushl $0
  1022cd:	6a 00                	push   $0x0
  pushl $114
  1022cf:	6a 72                	push   $0x72
  jmp __alltraps
  1022d1:	e9 75 06 00 00       	jmp    10294b <__alltraps>

001022d6 <vector115>:
.globl vector115
vector115:
  pushl $0
  1022d6:	6a 00                	push   $0x0
  pushl $115
  1022d8:	6a 73                	push   $0x73
  jmp __alltraps
  1022da:	e9 6c 06 00 00       	jmp    10294b <__alltraps>

001022df <vector116>:
.globl vector116
vector116:
  pushl $0
  1022df:	6a 00                	push   $0x0
  pushl $116
  1022e1:	6a 74                	push   $0x74
  jmp __alltraps
  1022e3:	e9 63 06 00 00       	jmp    10294b <__alltraps>

001022e8 <vector117>:
.globl vector117
vector117:
  pushl $0
  1022e8:	6a 00                	push   $0x0
  pushl $117
  1022ea:	6a 75                	push   $0x75
  jmp __alltraps
  1022ec:	e9 5a 06 00 00       	jmp    10294b <__alltraps>

001022f1 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022f1:	6a 00                	push   $0x0
  pushl $118
  1022f3:	6a 76                	push   $0x76
  jmp __alltraps
  1022f5:	e9 51 06 00 00       	jmp    10294b <__alltraps>

001022fa <vector119>:
.globl vector119
vector119:
  pushl $0
  1022fa:	6a 00                	push   $0x0
  pushl $119
  1022fc:	6a 77                	push   $0x77
  jmp __alltraps
  1022fe:	e9 48 06 00 00       	jmp    10294b <__alltraps>

00102303 <vector120>:
.globl vector120
vector120:
  pushl $0
  102303:	6a 00                	push   $0x0
  pushl $120
  102305:	6a 78                	push   $0x78
  jmp __alltraps
  102307:	e9 3f 06 00 00       	jmp    10294b <__alltraps>

0010230c <vector121>:
.globl vector121
vector121:
  pushl $0
  10230c:	6a 00                	push   $0x0
  pushl $121
  10230e:	6a 79                	push   $0x79
  jmp __alltraps
  102310:	e9 36 06 00 00       	jmp    10294b <__alltraps>

00102315 <vector122>:
.globl vector122
vector122:
  pushl $0
  102315:	6a 00                	push   $0x0
  pushl $122
  102317:	6a 7a                	push   $0x7a
  jmp __alltraps
  102319:	e9 2d 06 00 00       	jmp    10294b <__alltraps>

0010231e <vector123>:
.globl vector123
vector123:
  pushl $0
  10231e:	6a 00                	push   $0x0
  pushl $123
  102320:	6a 7b                	push   $0x7b
  jmp __alltraps
  102322:	e9 24 06 00 00       	jmp    10294b <__alltraps>

00102327 <vector124>:
.globl vector124
vector124:
  pushl $0
  102327:	6a 00                	push   $0x0
  pushl $124
  102329:	6a 7c                	push   $0x7c
  jmp __alltraps
  10232b:	e9 1b 06 00 00       	jmp    10294b <__alltraps>

00102330 <vector125>:
.globl vector125
vector125:
  pushl $0
  102330:	6a 00                	push   $0x0
  pushl $125
  102332:	6a 7d                	push   $0x7d
  jmp __alltraps
  102334:	e9 12 06 00 00       	jmp    10294b <__alltraps>

00102339 <vector126>:
.globl vector126
vector126:
  pushl $0
  102339:	6a 00                	push   $0x0
  pushl $126
  10233b:	6a 7e                	push   $0x7e
  jmp __alltraps
  10233d:	e9 09 06 00 00       	jmp    10294b <__alltraps>

00102342 <vector127>:
.globl vector127
vector127:
  pushl $0
  102342:	6a 00                	push   $0x0
  pushl $127
  102344:	6a 7f                	push   $0x7f
  jmp __alltraps
  102346:	e9 00 06 00 00       	jmp    10294b <__alltraps>

0010234b <vector128>:
.globl vector128
vector128:
  pushl $0
  10234b:	6a 00                	push   $0x0
  pushl $128
  10234d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102352:	e9 f4 05 00 00       	jmp    10294b <__alltraps>

00102357 <vector129>:
.globl vector129
vector129:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $129
  102359:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10235e:	e9 e8 05 00 00       	jmp    10294b <__alltraps>

00102363 <vector130>:
.globl vector130
vector130:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $130
  102365:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10236a:	e9 dc 05 00 00       	jmp    10294b <__alltraps>

0010236f <vector131>:
.globl vector131
vector131:
  pushl $0
  10236f:	6a 00                	push   $0x0
  pushl $131
  102371:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102376:	e9 d0 05 00 00       	jmp    10294b <__alltraps>

0010237b <vector132>:
.globl vector132
vector132:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $132
  10237d:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102382:	e9 c4 05 00 00       	jmp    10294b <__alltraps>

00102387 <vector133>:
.globl vector133
vector133:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $133
  102389:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10238e:	e9 b8 05 00 00       	jmp    10294b <__alltraps>

00102393 <vector134>:
.globl vector134
vector134:
  pushl $0
  102393:	6a 00                	push   $0x0
  pushl $134
  102395:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10239a:	e9 ac 05 00 00       	jmp    10294b <__alltraps>

0010239f <vector135>:
.globl vector135
vector135:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $135
  1023a1:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1023a6:	e9 a0 05 00 00       	jmp    10294b <__alltraps>

001023ab <vector136>:
.globl vector136
vector136:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $136
  1023ad:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1023b2:	e9 94 05 00 00       	jmp    10294b <__alltraps>

001023b7 <vector137>:
.globl vector137
vector137:
  pushl $0
  1023b7:	6a 00                	push   $0x0
  pushl $137
  1023b9:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1023be:	e9 88 05 00 00       	jmp    10294b <__alltraps>

001023c3 <vector138>:
.globl vector138
vector138:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $138
  1023c5:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023ca:	e9 7c 05 00 00       	jmp    10294b <__alltraps>

001023cf <vector139>:
.globl vector139
vector139:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $139
  1023d1:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023d6:	e9 70 05 00 00       	jmp    10294b <__alltraps>

001023db <vector140>:
.globl vector140
vector140:
  pushl $0
  1023db:	6a 00                	push   $0x0
  pushl $140
  1023dd:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023e2:	e9 64 05 00 00       	jmp    10294b <__alltraps>

001023e7 <vector141>:
.globl vector141
vector141:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $141
  1023e9:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023ee:	e9 58 05 00 00       	jmp    10294b <__alltraps>

001023f3 <vector142>:
.globl vector142
vector142:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $142
  1023f5:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023fa:	e9 4c 05 00 00       	jmp    10294b <__alltraps>

001023ff <vector143>:
.globl vector143
vector143:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $143
  102401:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102406:	e9 40 05 00 00       	jmp    10294b <__alltraps>

0010240b <vector144>:
.globl vector144
vector144:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $144
  10240d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102412:	e9 34 05 00 00       	jmp    10294b <__alltraps>

00102417 <vector145>:
.globl vector145
vector145:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $145
  102419:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10241e:	e9 28 05 00 00       	jmp    10294b <__alltraps>

00102423 <vector146>:
.globl vector146
vector146:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $146
  102425:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10242a:	e9 1c 05 00 00       	jmp    10294b <__alltraps>

0010242f <vector147>:
.globl vector147
vector147:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $147
  102431:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102436:	e9 10 05 00 00       	jmp    10294b <__alltraps>

0010243b <vector148>:
.globl vector148
vector148:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $148
  10243d:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102442:	e9 04 05 00 00       	jmp    10294b <__alltraps>

00102447 <vector149>:
.globl vector149
vector149:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $149
  102449:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10244e:	e9 f8 04 00 00       	jmp    10294b <__alltraps>

00102453 <vector150>:
.globl vector150
vector150:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $150
  102455:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10245a:	e9 ec 04 00 00       	jmp    10294b <__alltraps>

0010245f <vector151>:
.globl vector151
vector151:
  pushl $0
  10245f:	6a 00                	push   $0x0
  pushl $151
  102461:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102466:	e9 e0 04 00 00       	jmp    10294b <__alltraps>

0010246b <vector152>:
.globl vector152
vector152:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $152
  10246d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102472:	e9 d4 04 00 00       	jmp    10294b <__alltraps>

00102477 <vector153>:
.globl vector153
vector153:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $153
  102479:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10247e:	e9 c8 04 00 00       	jmp    10294b <__alltraps>

00102483 <vector154>:
.globl vector154
vector154:
  pushl $0
  102483:	6a 00                	push   $0x0
  pushl $154
  102485:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10248a:	e9 bc 04 00 00       	jmp    10294b <__alltraps>

0010248f <vector155>:
.globl vector155
vector155:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $155
  102491:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102496:	e9 b0 04 00 00       	jmp    10294b <__alltraps>

0010249b <vector156>:
.globl vector156
vector156:
  pushl $0
  10249b:	6a 00                	push   $0x0
  pushl $156
  10249d:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1024a2:	e9 a4 04 00 00       	jmp    10294b <__alltraps>

001024a7 <vector157>:
.globl vector157
vector157:
  pushl $0
  1024a7:	6a 00                	push   $0x0
  pushl $157
  1024a9:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1024ae:	e9 98 04 00 00       	jmp    10294b <__alltraps>

001024b3 <vector158>:
.globl vector158
vector158:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $158
  1024b5:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1024ba:	e9 8c 04 00 00       	jmp    10294b <__alltraps>

001024bf <vector159>:
.globl vector159
vector159:
  pushl $0
  1024bf:	6a 00                	push   $0x0
  pushl $159
  1024c1:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1024c6:	e9 80 04 00 00       	jmp    10294b <__alltraps>

001024cb <vector160>:
.globl vector160
vector160:
  pushl $0
  1024cb:	6a 00                	push   $0x0
  pushl $160
  1024cd:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024d2:	e9 74 04 00 00       	jmp    10294b <__alltraps>

001024d7 <vector161>:
.globl vector161
vector161:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $161
  1024d9:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024de:	e9 68 04 00 00       	jmp    10294b <__alltraps>

001024e3 <vector162>:
.globl vector162
vector162:
  pushl $0
  1024e3:	6a 00                	push   $0x0
  pushl $162
  1024e5:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024ea:	e9 5c 04 00 00       	jmp    10294b <__alltraps>

001024ef <vector163>:
.globl vector163
vector163:
  pushl $0
  1024ef:	6a 00                	push   $0x0
  pushl $163
  1024f1:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024f6:	e9 50 04 00 00       	jmp    10294b <__alltraps>

001024fb <vector164>:
.globl vector164
vector164:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $164
  1024fd:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102502:	e9 44 04 00 00       	jmp    10294b <__alltraps>

00102507 <vector165>:
.globl vector165
vector165:
  pushl $0
  102507:	6a 00                	push   $0x0
  pushl $165
  102509:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10250e:	e9 38 04 00 00       	jmp    10294b <__alltraps>

00102513 <vector166>:
.globl vector166
vector166:
  pushl $0
  102513:	6a 00                	push   $0x0
  pushl $166
  102515:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10251a:	e9 2c 04 00 00       	jmp    10294b <__alltraps>

0010251f <vector167>:
.globl vector167
vector167:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $167
  102521:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102526:	e9 20 04 00 00       	jmp    10294b <__alltraps>

0010252b <vector168>:
.globl vector168
vector168:
  pushl $0
  10252b:	6a 00                	push   $0x0
  pushl $168
  10252d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102532:	e9 14 04 00 00       	jmp    10294b <__alltraps>

00102537 <vector169>:
.globl vector169
vector169:
  pushl $0
  102537:	6a 00                	push   $0x0
  pushl $169
  102539:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10253e:	e9 08 04 00 00       	jmp    10294b <__alltraps>

00102543 <vector170>:
.globl vector170
vector170:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $170
  102545:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10254a:	e9 fc 03 00 00       	jmp    10294b <__alltraps>

0010254f <vector171>:
.globl vector171
vector171:
  pushl $0
  10254f:	6a 00                	push   $0x0
  pushl $171
  102551:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102556:	e9 f0 03 00 00       	jmp    10294b <__alltraps>

0010255b <vector172>:
.globl vector172
vector172:
  pushl $0
  10255b:	6a 00                	push   $0x0
  pushl $172
  10255d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102562:	e9 e4 03 00 00       	jmp    10294b <__alltraps>

00102567 <vector173>:
.globl vector173
vector173:
  pushl $0
  102567:	6a 00                	push   $0x0
  pushl $173
  102569:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10256e:	e9 d8 03 00 00       	jmp    10294b <__alltraps>

00102573 <vector174>:
.globl vector174
vector174:
  pushl $0
  102573:	6a 00                	push   $0x0
  pushl $174
  102575:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10257a:	e9 cc 03 00 00       	jmp    10294b <__alltraps>

0010257f <vector175>:
.globl vector175
vector175:
  pushl $0
  10257f:	6a 00                	push   $0x0
  pushl $175
  102581:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102586:	e9 c0 03 00 00       	jmp    10294b <__alltraps>

0010258b <vector176>:
.globl vector176
vector176:
  pushl $0
  10258b:	6a 00                	push   $0x0
  pushl $176
  10258d:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102592:	e9 b4 03 00 00       	jmp    10294b <__alltraps>

00102597 <vector177>:
.globl vector177
vector177:
  pushl $0
  102597:	6a 00                	push   $0x0
  pushl $177
  102599:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10259e:	e9 a8 03 00 00       	jmp    10294b <__alltraps>

001025a3 <vector178>:
.globl vector178
vector178:
  pushl $0
  1025a3:	6a 00                	push   $0x0
  pushl $178
  1025a5:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1025aa:	e9 9c 03 00 00       	jmp    10294b <__alltraps>

001025af <vector179>:
.globl vector179
vector179:
  pushl $0
  1025af:	6a 00                	push   $0x0
  pushl $179
  1025b1:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1025b6:	e9 90 03 00 00       	jmp    10294b <__alltraps>

001025bb <vector180>:
.globl vector180
vector180:
  pushl $0
  1025bb:	6a 00                	push   $0x0
  pushl $180
  1025bd:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1025c2:	e9 84 03 00 00       	jmp    10294b <__alltraps>

001025c7 <vector181>:
.globl vector181
vector181:
  pushl $0
  1025c7:	6a 00                	push   $0x0
  pushl $181
  1025c9:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025ce:	e9 78 03 00 00       	jmp    10294b <__alltraps>

001025d3 <vector182>:
.globl vector182
vector182:
  pushl $0
  1025d3:	6a 00                	push   $0x0
  pushl $182
  1025d5:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025da:	e9 6c 03 00 00       	jmp    10294b <__alltraps>

001025df <vector183>:
.globl vector183
vector183:
  pushl $0
  1025df:	6a 00                	push   $0x0
  pushl $183
  1025e1:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025e6:	e9 60 03 00 00       	jmp    10294b <__alltraps>

001025eb <vector184>:
.globl vector184
vector184:
  pushl $0
  1025eb:	6a 00                	push   $0x0
  pushl $184
  1025ed:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025f2:	e9 54 03 00 00       	jmp    10294b <__alltraps>

001025f7 <vector185>:
.globl vector185
vector185:
  pushl $0
  1025f7:	6a 00                	push   $0x0
  pushl $185
  1025f9:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025fe:	e9 48 03 00 00       	jmp    10294b <__alltraps>

00102603 <vector186>:
.globl vector186
vector186:
  pushl $0
  102603:	6a 00                	push   $0x0
  pushl $186
  102605:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10260a:	e9 3c 03 00 00       	jmp    10294b <__alltraps>

0010260f <vector187>:
.globl vector187
vector187:
  pushl $0
  10260f:	6a 00                	push   $0x0
  pushl $187
  102611:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102616:	e9 30 03 00 00       	jmp    10294b <__alltraps>

0010261b <vector188>:
.globl vector188
vector188:
  pushl $0
  10261b:	6a 00                	push   $0x0
  pushl $188
  10261d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102622:	e9 24 03 00 00       	jmp    10294b <__alltraps>

00102627 <vector189>:
.globl vector189
vector189:
  pushl $0
  102627:	6a 00                	push   $0x0
  pushl $189
  102629:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10262e:	e9 18 03 00 00       	jmp    10294b <__alltraps>

00102633 <vector190>:
.globl vector190
vector190:
  pushl $0
  102633:	6a 00                	push   $0x0
  pushl $190
  102635:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10263a:	e9 0c 03 00 00       	jmp    10294b <__alltraps>

0010263f <vector191>:
.globl vector191
vector191:
  pushl $0
  10263f:	6a 00                	push   $0x0
  pushl $191
  102641:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102646:	e9 00 03 00 00       	jmp    10294b <__alltraps>

0010264b <vector192>:
.globl vector192
vector192:
  pushl $0
  10264b:	6a 00                	push   $0x0
  pushl $192
  10264d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102652:	e9 f4 02 00 00       	jmp    10294b <__alltraps>

00102657 <vector193>:
.globl vector193
vector193:
  pushl $0
  102657:	6a 00                	push   $0x0
  pushl $193
  102659:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10265e:	e9 e8 02 00 00       	jmp    10294b <__alltraps>

00102663 <vector194>:
.globl vector194
vector194:
  pushl $0
  102663:	6a 00                	push   $0x0
  pushl $194
  102665:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10266a:	e9 dc 02 00 00       	jmp    10294b <__alltraps>

0010266f <vector195>:
.globl vector195
vector195:
  pushl $0
  10266f:	6a 00                	push   $0x0
  pushl $195
  102671:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102676:	e9 d0 02 00 00       	jmp    10294b <__alltraps>

0010267b <vector196>:
.globl vector196
vector196:
  pushl $0
  10267b:	6a 00                	push   $0x0
  pushl $196
  10267d:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102682:	e9 c4 02 00 00       	jmp    10294b <__alltraps>

00102687 <vector197>:
.globl vector197
vector197:
  pushl $0
  102687:	6a 00                	push   $0x0
  pushl $197
  102689:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10268e:	e9 b8 02 00 00       	jmp    10294b <__alltraps>

00102693 <vector198>:
.globl vector198
vector198:
  pushl $0
  102693:	6a 00                	push   $0x0
  pushl $198
  102695:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10269a:	e9 ac 02 00 00       	jmp    10294b <__alltraps>

0010269f <vector199>:
.globl vector199
vector199:
  pushl $0
  10269f:	6a 00                	push   $0x0
  pushl $199
  1026a1:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1026a6:	e9 a0 02 00 00       	jmp    10294b <__alltraps>

001026ab <vector200>:
.globl vector200
vector200:
  pushl $0
  1026ab:	6a 00                	push   $0x0
  pushl $200
  1026ad:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1026b2:	e9 94 02 00 00       	jmp    10294b <__alltraps>

001026b7 <vector201>:
.globl vector201
vector201:
  pushl $0
  1026b7:	6a 00                	push   $0x0
  pushl $201
  1026b9:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1026be:	e9 88 02 00 00       	jmp    10294b <__alltraps>

001026c3 <vector202>:
.globl vector202
vector202:
  pushl $0
  1026c3:	6a 00                	push   $0x0
  pushl $202
  1026c5:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026ca:	e9 7c 02 00 00       	jmp    10294b <__alltraps>

001026cf <vector203>:
.globl vector203
vector203:
  pushl $0
  1026cf:	6a 00                	push   $0x0
  pushl $203
  1026d1:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026d6:	e9 70 02 00 00       	jmp    10294b <__alltraps>

001026db <vector204>:
.globl vector204
vector204:
  pushl $0
  1026db:	6a 00                	push   $0x0
  pushl $204
  1026dd:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026e2:	e9 64 02 00 00       	jmp    10294b <__alltraps>

001026e7 <vector205>:
.globl vector205
vector205:
  pushl $0
  1026e7:	6a 00                	push   $0x0
  pushl $205
  1026e9:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026ee:	e9 58 02 00 00       	jmp    10294b <__alltraps>

001026f3 <vector206>:
.globl vector206
vector206:
  pushl $0
  1026f3:	6a 00                	push   $0x0
  pushl $206
  1026f5:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026fa:	e9 4c 02 00 00       	jmp    10294b <__alltraps>

001026ff <vector207>:
.globl vector207
vector207:
  pushl $0
  1026ff:	6a 00                	push   $0x0
  pushl $207
  102701:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102706:	e9 40 02 00 00       	jmp    10294b <__alltraps>

0010270b <vector208>:
.globl vector208
vector208:
  pushl $0
  10270b:	6a 00                	push   $0x0
  pushl $208
  10270d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102712:	e9 34 02 00 00       	jmp    10294b <__alltraps>

00102717 <vector209>:
.globl vector209
vector209:
  pushl $0
  102717:	6a 00                	push   $0x0
  pushl $209
  102719:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10271e:	e9 28 02 00 00       	jmp    10294b <__alltraps>

00102723 <vector210>:
.globl vector210
vector210:
  pushl $0
  102723:	6a 00                	push   $0x0
  pushl $210
  102725:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10272a:	e9 1c 02 00 00       	jmp    10294b <__alltraps>

0010272f <vector211>:
.globl vector211
vector211:
  pushl $0
  10272f:	6a 00                	push   $0x0
  pushl $211
  102731:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102736:	e9 10 02 00 00       	jmp    10294b <__alltraps>

0010273b <vector212>:
.globl vector212
vector212:
  pushl $0
  10273b:	6a 00                	push   $0x0
  pushl $212
  10273d:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102742:	e9 04 02 00 00       	jmp    10294b <__alltraps>

00102747 <vector213>:
.globl vector213
vector213:
  pushl $0
  102747:	6a 00                	push   $0x0
  pushl $213
  102749:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10274e:	e9 f8 01 00 00       	jmp    10294b <__alltraps>

00102753 <vector214>:
.globl vector214
vector214:
  pushl $0
  102753:	6a 00                	push   $0x0
  pushl $214
  102755:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10275a:	e9 ec 01 00 00       	jmp    10294b <__alltraps>

0010275f <vector215>:
.globl vector215
vector215:
  pushl $0
  10275f:	6a 00                	push   $0x0
  pushl $215
  102761:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102766:	e9 e0 01 00 00       	jmp    10294b <__alltraps>

0010276b <vector216>:
.globl vector216
vector216:
  pushl $0
  10276b:	6a 00                	push   $0x0
  pushl $216
  10276d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102772:	e9 d4 01 00 00       	jmp    10294b <__alltraps>

00102777 <vector217>:
.globl vector217
vector217:
  pushl $0
  102777:	6a 00                	push   $0x0
  pushl $217
  102779:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10277e:	e9 c8 01 00 00       	jmp    10294b <__alltraps>

00102783 <vector218>:
.globl vector218
vector218:
  pushl $0
  102783:	6a 00                	push   $0x0
  pushl $218
  102785:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10278a:	e9 bc 01 00 00       	jmp    10294b <__alltraps>

0010278f <vector219>:
.globl vector219
vector219:
  pushl $0
  10278f:	6a 00                	push   $0x0
  pushl $219
  102791:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102796:	e9 b0 01 00 00       	jmp    10294b <__alltraps>

0010279b <vector220>:
.globl vector220
vector220:
  pushl $0
  10279b:	6a 00                	push   $0x0
  pushl $220
  10279d:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1027a2:	e9 a4 01 00 00       	jmp    10294b <__alltraps>

001027a7 <vector221>:
.globl vector221
vector221:
  pushl $0
  1027a7:	6a 00                	push   $0x0
  pushl $221
  1027a9:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1027ae:	e9 98 01 00 00       	jmp    10294b <__alltraps>

001027b3 <vector222>:
.globl vector222
vector222:
  pushl $0
  1027b3:	6a 00                	push   $0x0
  pushl $222
  1027b5:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1027ba:	e9 8c 01 00 00       	jmp    10294b <__alltraps>

001027bf <vector223>:
.globl vector223
vector223:
  pushl $0
  1027bf:	6a 00                	push   $0x0
  pushl $223
  1027c1:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1027c6:	e9 80 01 00 00       	jmp    10294b <__alltraps>

001027cb <vector224>:
.globl vector224
vector224:
  pushl $0
  1027cb:	6a 00                	push   $0x0
  pushl $224
  1027cd:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027d2:	e9 74 01 00 00       	jmp    10294b <__alltraps>

001027d7 <vector225>:
.globl vector225
vector225:
  pushl $0
  1027d7:	6a 00                	push   $0x0
  pushl $225
  1027d9:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027de:	e9 68 01 00 00       	jmp    10294b <__alltraps>

001027e3 <vector226>:
.globl vector226
vector226:
  pushl $0
  1027e3:	6a 00                	push   $0x0
  pushl $226
  1027e5:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027ea:	e9 5c 01 00 00       	jmp    10294b <__alltraps>

001027ef <vector227>:
.globl vector227
vector227:
  pushl $0
  1027ef:	6a 00                	push   $0x0
  pushl $227
  1027f1:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027f6:	e9 50 01 00 00       	jmp    10294b <__alltraps>

001027fb <vector228>:
.globl vector228
vector228:
  pushl $0
  1027fb:	6a 00                	push   $0x0
  pushl $228
  1027fd:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102802:	e9 44 01 00 00       	jmp    10294b <__alltraps>

00102807 <vector229>:
.globl vector229
vector229:
  pushl $0
  102807:	6a 00                	push   $0x0
  pushl $229
  102809:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10280e:	e9 38 01 00 00       	jmp    10294b <__alltraps>

00102813 <vector230>:
.globl vector230
vector230:
  pushl $0
  102813:	6a 00                	push   $0x0
  pushl $230
  102815:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10281a:	e9 2c 01 00 00       	jmp    10294b <__alltraps>

0010281f <vector231>:
.globl vector231
vector231:
  pushl $0
  10281f:	6a 00                	push   $0x0
  pushl $231
  102821:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102826:	e9 20 01 00 00       	jmp    10294b <__alltraps>

0010282b <vector232>:
.globl vector232
vector232:
  pushl $0
  10282b:	6a 00                	push   $0x0
  pushl $232
  10282d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102832:	e9 14 01 00 00       	jmp    10294b <__alltraps>

00102837 <vector233>:
.globl vector233
vector233:
  pushl $0
  102837:	6a 00                	push   $0x0
  pushl $233
  102839:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10283e:	e9 08 01 00 00       	jmp    10294b <__alltraps>

00102843 <vector234>:
.globl vector234
vector234:
  pushl $0
  102843:	6a 00                	push   $0x0
  pushl $234
  102845:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10284a:	e9 fc 00 00 00       	jmp    10294b <__alltraps>

0010284f <vector235>:
.globl vector235
vector235:
  pushl $0
  10284f:	6a 00                	push   $0x0
  pushl $235
  102851:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102856:	e9 f0 00 00 00       	jmp    10294b <__alltraps>

0010285b <vector236>:
.globl vector236
vector236:
  pushl $0
  10285b:	6a 00                	push   $0x0
  pushl $236
  10285d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102862:	e9 e4 00 00 00       	jmp    10294b <__alltraps>

00102867 <vector237>:
.globl vector237
vector237:
  pushl $0
  102867:	6a 00                	push   $0x0
  pushl $237
  102869:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10286e:	e9 d8 00 00 00       	jmp    10294b <__alltraps>

00102873 <vector238>:
.globl vector238
vector238:
  pushl $0
  102873:	6a 00                	push   $0x0
  pushl $238
  102875:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10287a:	e9 cc 00 00 00       	jmp    10294b <__alltraps>

0010287f <vector239>:
.globl vector239
vector239:
  pushl $0
  10287f:	6a 00                	push   $0x0
  pushl $239
  102881:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102886:	e9 c0 00 00 00       	jmp    10294b <__alltraps>

0010288b <vector240>:
.globl vector240
vector240:
  pushl $0
  10288b:	6a 00                	push   $0x0
  pushl $240
  10288d:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102892:	e9 b4 00 00 00       	jmp    10294b <__alltraps>

00102897 <vector241>:
.globl vector241
vector241:
  pushl $0
  102897:	6a 00                	push   $0x0
  pushl $241
  102899:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10289e:	e9 a8 00 00 00       	jmp    10294b <__alltraps>

001028a3 <vector242>:
.globl vector242
vector242:
  pushl $0
  1028a3:	6a 00                	push   $0x0
  pushl $242
  1028a5:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1028aa:	e9 9c 00 00 00       	jmp    10294b <__alltraps>

001028af <vector243>:
.globl vector243
vector243:
  pushl $0
  1028af:	6a 00                	push   $0x0
  pushl $243
  1028b1:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1028b6:	e9 90 00 00 00       	jmp    10294b <__alltraps>

001028bb <vector244>:
.globl vector244
vector244:
  pushl $0
  1028bb:	6a 00                	push   $0x0
  pushl $244
  1028bd:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1028c2:	e9 84 00 00 00       	jmp    10294b <__alltraps>

001028c7 <vector245>:
.globl vector245
vector245:
  pushl $0
  1028c7:	6a 00                	push   $0x0
  pushl $245
  1028c9:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028ce:	e9 78 00 00 00       	jmp    10294b <__alltraps>

001028d3 <vector246>:
.globl vector246
vector246:
  pushl $0
  1028d3:	6a 00                	push   $0x0
  pushl $246
  1028d5:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028da:	e9 6c 00 00 00       	jmp    10294b <__alltraps>

001028df <vector247>:
.globl vector247
vector247:
  pushl $0
  1028df:	6a 00                	push   $0x0
  pushl $247
  1028e1:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028e6:	e9 60 00 00 00       	jmp    10294b <__alltraps>

001028eb <vector248>:
.globl vector248
vector248:
  pushl $0
  1028eb:	6a 00                	push   $0x0
  pushl $248
  1028ed:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028f2:	e9 54 00 00 00       	jmp    10294b <__alltraps>

001028f7 <vector249>:
.globl vector249
vector249:
  pushl $0
  1028f7:	6a 00                	push   $0x0
  pushl $249
  1028f9:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028fe:	e9 48 00 00 00       	jmp    10294b <__alltraps>

00102903 <vector250>:
.globl vector250
vector250:
  pushl $0
  102903:	6a 00                	push   $0x0
  pushl $250
  102905:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  10290a:	e9 3c 00 00 00       	jmp    10294b <__alltraps>

0010290f <vector251>:
.globl vector251
vector251:
  pushl $0
  10290f:	6a 00                	push   $0x0
  pushl $251
  102911:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102916:	e9 30 00 00 00       	jmp    10294b <__alltraps>

0010291b <vector252>:
.globl vector252
vector252:
  pushl $0
  10291b:	6a 00                	push   $0x0
  pushl $252
  10291d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102922:	e9 24 00 00 00       	jmp    10294b <__alltraps>

00102927 <vector253>:
.globl vector253
vector253:
  pushl $0
  102927:	6a 00                	push   $0x0
  pushl $253
  102929:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10292e:	e9 18 00 00 00       	jmp    10294b <__alltraps>

00102933 <vector254>:
.globl vector254
vector254:
  pushl $0
  102933:	6a 00                	push   $0x0
  pushl $254
  102935:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10293a:	e9 0c 00 00 00       	jmp    10294b <__alltraps>

0010293f <vector255>:
.globl vector255
vector255:
  pushl $0
  10293f:	6a 00                	push   $0x0
  pushl $255
  102941:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102946:	e9 00 00 00 00       	jmp    10294b <__alltraps>

0010294b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  10294b:	1e                   	push   %ds
    pushl %es
  10294c:	06                   	push   %es
    pushl %fs
  10294d:	0f a0                	push   %fs
    pushl %gs
  10294f:	0f a8                	push   %gs
    pushal
  102951:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102952:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102957:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102959:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  10295b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  10295c:	e8 64 f5 ff ff       	call   101ec5 <trap>

    # pop the pushed stack pointer
    popl %esp
  102961:	5c                   	pop    %esp

00102962 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102962:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102963:	0f a9                	pop    %gs
    popl %fs
  102965:	0f a1                	pop    %fs
    popl %es
  102967:	07                   	pop    %es
    popl %ds
  102968:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102969:	83 c4 08             	add    $0x8,%esp
    iret
  10296c:	cf                   	iret   

0010296d <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10296d:	55                   	push   %ebp
  10296e:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102970:	8b 45 08             	mov    0x8(%ebp),%eax
  102973:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102976:	b8 23 00 00 00       	mov    $0x23,%eax
  10297b:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  10297d:	b8 23 00 00 00       	mov    $0x23,%eax
  102982:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102984:	b8 10 00 00 00       	mov    $0x10,%eax
  102989:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  10298b:	b8 10 00 00 00       	mov    $0x10,%eax
  102990:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102992:	b8 10 00 00 00       	mov    $0x10,%eax
  102997:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102999:	ea a0 29 10 00 08 00 	ljmp   $0x8,$0x1029a0
}
  1029a0:	90                   	nop
  1029a1:	5d                   	pop    %ebp
  1029a2:	c3                   	ret    

001029a3 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  1029a3:	55                   	push   %ebp
  1029a4:	89 e5                	mov    %esp,%ebp
  1029a6:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  1029a9:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  1029ae:	05 00 04 00 00       	add    $0x400,%eax
  1029b3:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  1029b8:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  1029bf:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  1029c1:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  1029c8:	68 00 
  1029ca:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029cf:	0f b7 c0             	movzwl %ax,%eax
  1029d2:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  1029d8:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029dd:	c1 e8 10             	shr    $0x10,%eax
  1029e0:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  1029e5:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029ec:	24 f0                	and    $0xf0,%al
  1029ee:	0c 09                	or     $0x9,%al
  1029f0:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029f5:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029fc:	0c 10                	or     $0x10,%al
  1029fe:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102a03:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a0a:	24 9f                	and    $0x9f,%al
  102a0c:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102a11:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a18:	0c 80                	or     $0x80,%al
  102a1a:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102a1f:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a26:	24 f0                	and    $0xf0,%al
  102a28:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a2d:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a34:	24 ef                	and    $0xef,%al
  102a36:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a3b:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a42:	24 df                	and    $0xdf,%al
  102a44:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a49:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a50:	0c 40                	or     $0x40,%al
  102a52:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a57:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a5e:	24 7f                	and    $0x7f,%al
  102a60:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a65:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a6a:	c1 e8 18             	shr    $0x18,%eax
  102a6d:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102a72:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a79:	24 ef                	and    $0xef,%al
  102a7b:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102a80:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  102a87:	e8 e1 fe ff ff       	call   10296d <lgdt>
  102a8c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a92:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a96:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102a99:	90                   	nop
  102a9a:	c9                   	leave  
  102a9b:	c3                   	ret    

00102a9c <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a9c:	55                   	push   %ebp
  102a9d:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a9f:	e8 ff fe ff ff       	call   1029a3 <gdt_init>
}
  102aa4:	90                   	nop
  102aa5:	5d                   	pop    %ebp
  102aa6:	c3                   	ret    

00102aa7 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102aa7:	55                   	push   %ebp
  102aa8:	89 e5                	mov    %esp,%ebp
  102aaa:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102aad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102ab4:	eb 03                	jmp    102ab9 <strlen+0x12>
        cnt ++;
  102ab6:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  102ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  102abc:	8d 50 01             	lea    0x1(%eax),%edx
  102abf:	89 55 08             	mov    %edx,0x8(%ebp)
  102ac2:	0f b6 00             	movzbl (%eax),%eax
  102ac5:	84 c0                	test   %al,%al
  102ac7:	75 ed                	jne    102ab6 <strlen+0xf>
    }
    return cnt;
  102ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102acc:	c9                   	leave  
  102acd:	c3                   	ret    

00102ace <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102ace:	55                   	push   %ebp
  102acf:	89 e5                	mov    %esp,%ebp
  102ad1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102ad4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102adb:	eb 03                	jmp    102ae0 <strnlen+0x12>
        cnt ++;
  102add:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ae3:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102ae6:	73 10                	jae    102af8 <strnlen+0x2a>
  102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  102aeb:	8d 50 01             	lea    0x1(%eax),%edx
  102aee:	89 55 08             	mov    %edx,0x8(%ebp)
  102af1:	0f b6 00             	movzbl (%eax),%eax
  102af4:	84 c0                	test   %al,%al
  102af6:	75 e5                	jne    102add <strnlen+0xf>
    }
    return cnt;
  102af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102afb:	c9                   	leave  
  102afc:	c3                   	ret    

00102afd <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102afd:	55                   	push   %ebp
  102afe:	89 e5                	mov    %esp,%ebp
  102b00:	57                   	push   %edi
  102b01:	56                   	push   %esi
  102b02:	83 ec 20             	sub    $0x20,%esp
  102b05:	8b 45 08             	mov    0x8(%ebp),%eax
  102b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102b11:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b17:	89 d1                	mov    %edx,%ecx
  102b19:	89 c2                	mov    %eax,%edx
  102b1b:	89 ce                	mov    %ecx,%esi
  102b1d:	89 d7                	mov    %edx,%edi
  102b1f:	ac                   	lods   %ds:(%esi),%al
  102b20:	aa                   	stos   %al,%es:(%edi)
  102b21:	84 c0                	test   %al,%al
  102b23:	75 fa                	jne    102b1f <strcpy+0x22>
  102b25:	89 fa                	mov    %edi,%edx
  102b27:	89 f1                	mov    %esi,%ecx
  102b29:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102b2c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102b2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102b35:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102b36:	83 c4 20             	add    $0x20,%esp
  102b39:	5e                   	pop    %esi
  102b3a:	5f                   	pop    %edi
  102b3b:	5d                   	pop    %ebp
  102b3c:	c3                   	ret    

00102b3d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102b3d:	55                   	push   %ebp
  102b3e:	89 e5                	mov    %esp,%ebp
  102b40:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102b43:	8b 45 08             	mov    0x8(%ebp),%eax
  102b46:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102b49:	eb 1e                	jmp    102b69 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  102b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b4e:	0f b6 10             	movzbl (%eax),%edx
  102b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b54:	88 10                	mov    %dl,(%eax)
  102b56:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b59:	0f b6 00             	movzbl (%eax),%eax
  102b5c:	84 c0                	test   %al,%al
  102b5e:	74 03                	je     102b63 <strncpy+0x26>
            src ++;
  102b60:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  102b63:	ff 45 fc             	incl   -0x4(%ebp)
  102b66:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  102b69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b6d:	75 dc                	jne    102b4b <strncpy+0xe>
    }
    return dst;
  102b6f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b72:	c9                   	leave  
  102b73:	c3                   	ret    

00102b74 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102b74:	55                   	push   %ebp
  102b75:	89 e5                	mov    %esp,%ebp
  102b77:	57                   	push   %edi
  102b78:	56                   	push   %esi
  102b79:	83 ec 20             	sub    $0x20,%esp
  102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b8e:	89 d1                	mov    %edx,%ecx
  102b90:	89 c2                	mov    %eax,%edx
  102b92:	89 ce                	mov    %ecx,%esi
  102b94:	89 d7                	mov    %edx,%edi
  102b96:	ac                   	lods   %ds:(%esi),%al
  102b97:	ae                   	scas   %es:(%edi),%al
  102b98:	75 08                	jne    102ba2 <strcmp+0x2e>
  102b9a:	84 c0                	test   %al,%al
  102b9c:	75 f8                	jne    102b96 <strcmp+0x22>
  102b9e:	31 c0                	xor    %eax,%eax
  102ba0:	eb 04                	jmp    102ba6 <strcmp+0x32>
  102ba2:	19 c0                	sbb    %eax,%eax
  102ba4:	0c 01                	or     $0x1,%al
  102ba6:	89 fa                	mov    %edi,%edx
  102ba8:	89 f1                	mov    %esi,%ecx
  102baa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102bad:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102bb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102bb6:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102bb7:	83 c4 20             	add    $0x20,%esp
  102bba:	5e                   	pop    %esi
  102bbb:	5f                   	pop    %edi
  102bbc:	5d                   	pop    %ebp
  102bbd:	c3                   	ret    

00102bbe <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102bbe:	55                   	push   %ebp
  102bbf:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102bc1:	eb 09                	jmp    102bcc <strncmp+0xe>
        n --, s1 ++, s2 ++;
  102bc3:	ff 4d 10             	decl   0x10(%ebp)
  102bc6:	ff 45 08             	incl   0x8(%ebp)
  102bc9:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102bcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bd0:	74 1a                	je     102bec <strncmp+0x2e>
  102bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd5:	0f b6 00             	movzbl (%eax),%eax
  102bd8:	84 c0                	test   %al,%al
  102bda:	74 10                	je     102bec <strncmp+0x2e>
  102bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  102bdf:	0f b6 10             	movzbl (%eax),%edx
  102be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102be5:	0f b6 00             	movzbl (%eax),%eax
  102be8:	38 c2                	cmp    %al,%dl
  102bea:	74 d7                	je     102bc3 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102bec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bf0:	74 18                	je     102c0a <strncmp+0x4c>
  102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf5:	0f b6 00             	movzbl (%eax),%eax
  102bf8:	0f b6 d0             	movzbl %al,%edx
  102bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bfe:	0f b6 00             	movzbl (%eax),%eax
  102c01:	0f b6 c0             	movzbl %al,%eax
  102c04:	29 c2                	sub    %eax,%edx
  102c06:	89 d0                	mov    %edx,%eax
  102c08:	eb 05                	jmp    102c0f <strncmp+0x51>
  102c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c0f:	5d                   	pop    %ebp
  102c10:	c3                   	ret    

00102c11 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102c11:	55                   	push   %ebp
  102c12:	89 e5                	mov    %esp,%ebp
  102c14:	83 ec 04             	sub    $0x4,%esp
  102c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c1a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c1d:	eb 13                	jmp    102c32 <strchr+0x21>
        if (*s == c) {
  102c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c22:	0f b6 00             	movzbl (%eax),%eax
  102c25:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102c28:	75 05                	jne    102c2f <strchr+0x1e>
            return (char *)s;
  102c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c2d:	eb 12                	jmp    102c41 <strchr+0x30>
        }
        s ++;
  102c2f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102c32:	8b 45 08             	mov    0x8(%ebp),%eax
  102c35:	0f b6 00             	movzbl (%eax),%eax
  102c38:	84 c0                	test   %al,%al
  102c3a:	75 e3                	jne    102c1f <strchr+0xe>
    }
    return NULL;
  102c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c41:	c9                   	leave  
  102c42:	c3                   	ret    

00102c43 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102c43:	55                   	push   %ebp
  102c44:	89 e5                	mov    %esp,%ebp
  102c46:	83 ec 04             	sub    $0x4,%esp
  102c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c4c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c4f:	eb 0e                	jmp    102c5f <strfind+0x1c>
        if (*s == c) {
  102c51:	8b 45 08             	mov    0x8(%ebp),%eax
  102c54:	0f b6 00             	movzbl (%eax),%eax
  102c57:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102c5a:	74 0f                	je     102c6b <strfind+0x28>
            break;
        }
        s ++;
  102c5c:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  102c62:	0f b6 00             	movzbl (%eax),%eax
  102c65:	84 c0                	test   %al,%al
  102c67:	75 e8                	jne    102c51 <strfind+0xe>
  102c69:	eb 01                	jmp    102c6c <strfind+0x29>
            break;
  102c6b:	90                   	nop
    }
    return (char *)s;
  102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102c6f:	c9                   	leave  
  102c70:	c3                   	ret    

00102c71 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102c71:	55                   	push   %ebp
  102c72:	89 e5                	mov    %esp,%ebp
  102c74:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102c77:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102c7e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102c85:	eb 03                	jmp    102c8a <strtol+0x19>
        s ++;
  102c87:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8d:	0f b6 00             	movzbl (%eax),%eax
  102c90:	3c 20                	cmp    $0x20,%al
  102c92:	74 f3                	je     102c87 <strtol+0x16>
  102c94:	8b 45 08             	mov    0x8(%ebp),%eax
  102c97:	0f b6 00             	movzbl (%eax),%eax
  102c9a:	3c 09                	cmp    $0x9,%al
  102c9c:	74 e9                	je     102c87 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  102c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  102ca1:	0f b6 00             	movzbl (%eax),%eax
  102ca4:	3c 2b                	cmp    $0x2b,%al
  102ca6:	75 05                	jne    102cad <strtol+0x3c>
        s ++;
  102ca8:	ff 45 08             	incl   0x8(%ebp)
  102cab:	eb 14                	jmp    102cc1 <strtol+0x50>
    }
    else if (*s == '-') {
  102cad:	8b 45 08             	mov    0x8(%ebp),%eax
  102cb0:	0f b6 00             	movzbl (%eax),%eax
  102cb3:	3c 2d                	cmp    $0x2d,%al
  102cb5:	75 0a                	jne    102cc1 <strtol+0x50>
        s ++, neg = 1;
  102cb7:	ff 45 08             	incl   0x8(%ebp)
  102cba:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102cc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102cc5:	74 06                	je     102ccd <strtol+0x5c>
  102cc7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102ccb:	75 22                	jne    102cef <strtol+0x7e>
  102ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd0:	0f b6 00             	movzbl (%eax),%eax
  102cd3:	3c 30                	cmp    $0x30,%al
  102cd5:	75 18                	jne    102cef <strtol+0x7e>
  102cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  102cda:	40                   	inc    %eax
  102cdb:	0f b6 00             	movzbl (%eax),%eax
  102cde:	3c 78                	cmp    $0x78,%al
  102ce0:	75 0d                	jne    102cef <strtol+0x7e>
        s += 2, base = 16;
  102ce2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102ce6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102ced:	eb 29                	jmp    102d18 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  102cef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102cf3:	75 16                	jne    102d0b <strtol+0x9a>
  102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf8:	0f b6 00             	movzbl (%eax),%eax
  102cfb:	3c 30                	cmp    $0x30,%al
  102cfd:	75 0c                	jne    102d0b <strtol+0x9a>
        s ++, base = 8;
  102cff:	ff 45 08             	incl   0x8(%ebp)
  102d02:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102d09:	eb 0d                	jmp    102d18 <strtol+0xa7>
    }
    else if (base == 0) {
  102d0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d0f:	75 07                	jne    102d18 <strtol+0xa7>
        base = 10;
  102d11:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102d18:	8b 45 08             	mov    0x8(%ebp),%eax
  102d1b:	0f b6 00             	movzbl (%eax),%eax
  102d1e:	3c 2f                	cmp    $0x2f,%al
  102d20:	7e 1b                	jle    102d3d <strtol+0xcc>
  102d22:	8b 45 08             	mov    0x8(%ebp),%eax
  102d25:	0f b6 00             	movzbl (%eax),%eax
  102d28:	3c 39                	cmp    $0x39,%al
  102d2a:	7f 11                	jg     102d3d <strtol+0xcc>
            dig = *s - '0';
  102d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d2f:	0f b6 00             	movzbl (%eax),%eax
  102d32:	0f be c0             	movsbl %al,%eax
  102d35:	83 e8 30             	sub    $0x30,%eax
  102d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d3b:	eb 48                	jmp    102d85 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d40:	0f b6 00             	movzbl (%eax),%eax
  102d43:	3c 60                	cmp    $0x60,%al
  102d45:	7e 1b                	jle    102d62 <strtol+0xf1>
  102d47:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4a:	0f b6 00             	movzbl (%eax),%eax
  102d4d:	3c 7a                	cmp    $0x7a,%al
  102d4f:	7f 11                	jg     102d62 <strtol+0xf1>
            dig = *s - 'a' + 10;
  102d51:	8b 45 08             	mov    0x8(%ebp),%eax
  102d54:	0f b6 00             	movzbl (%eax),%eax
  102d57:	0f be c0             	movsbl %al,%eax
  102d5a:	83 e8 57             	sub    $0x57,%eax
  102d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d60:	eb 23                	jmp    102d85 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102d62:	8b 45 08             	mov    0x8(%ebp),%eax
  102d65:	0f b6 00             	movzbl (%eax),%eax
  102d68:	3c 40                	cmp    $0x40,%al
  102d6a:	7e 3b                	jle    102da7 <strtol+0x136>
  102d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6f:	0f b6 00             	movzbl (%eax),%eax
  102d72:	3c 5a                	cmp    $0x5a,%al
  102d74:	7f 31                	jg     102da7 <strtol+0x136>
            dig = *s - 'A' + 10;
  102d76:	8b 45 08             	mov    0x8(%ebp),%eax
  102d79:	0f b6 00             	movzbl (%eax),%eax
  102d7c:	0f be c0             	movsbl %al,%eax
  102d7f:	83 e8 37             	sub    $0x37,%eax
  102d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d88:	3b 45 10             	cmp    0x10(%ebp),%eax
  102d8b:	7d 19                	jge    102da6 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  102d8d:	ff 45 08             	incl   0x8(%ebp)
  102d90:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102d93:	0f af 45 10          	imul   0x10(%ebp),%eax
  102d97:	89 c2                	mov    %eax,%edx
  102d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d9c:	01 d0                	add    %edx,%eax
  102d9e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  102da1:	e9 72 ff ff ff       	jmp    102d18 <strtol+0xa7>
            break;
  102da6:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  102da7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102dab:	74 08                	je     102db5 <strtol+0x144>
        *endptr = (char *) s;
  102dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  102db0:	8b 55 08             	mov    0x8(%ebp),%edx
  102db3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102db5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102db9:	74 07                	je     102dc2 <strtol+0x151>
  102dbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dbe:	f7 d8                	neg    %eax
  102dc0:	eb 03                	jmp    102dc5 <strtol+0x154>
  102dc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102dc5:	c9                   	leave  
  102dc6:	c3                   	ret    

00102dc7 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102dc7:	55                   	push   %ebp
  102dc8:	89 e5                	mov    %esp,%ebp
  102dca:	57                   	push   %edi
  102dcb:	83 ec 24             	sub    $0x24,%esp
  102dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dd1:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102dd4:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  102ddb:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102dde:	88 45 f7             	mov    %al,-0x9(%ebp)
  102de1:	8b 45 10             	mov    0x10(%ebp),%eax
  102de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102de7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102dea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102dee:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102df1:	89 d7                	mov    %edx,%edi
  102df3:	f3 aa                	rep stos %al,%es:(%edi)
  102df5:	89 fa                	mov    %edi,%edx
  102df7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102dfa:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102dfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e00:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102e01:	83 c4 24             	add    $0x24,%esp
  102e04:	5f                   	pop    %edi
  102e05:	5d                   	pop    %ebp
  102e06:	c3                   	ret    

00102e07 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102e07:	55                   	push   %ebp
  102e08:	89 e5                	mov    %esp,%ebp
  102e0a:	57                   	push   %edi
  102e0b:	56                   	push   %esi
  102e0c:	53                   	push   %ebx
  102e0d:	83 ec 30             	sub    $0x30,%esp
  102e10:	8b 45 08             	mov    0x8(%ebp),%eax
  102e13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  102e1f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e25:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102e28:	73 42                	jae    102e6c <memmove+0x65>
  102e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e36:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e39:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e3f:	c1 e8 02             	shr    $0x2,%eax
  102e42:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102e44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e4a:	89 d7                	mov    %edx,%edi
  102e4c:	89 c6                	mov    %eax,%esi
  102e4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102e50:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102e53:	83 e1 03             	and    $0x3,%ecx
  102e56:	74 02                	je     102e5a <memmove+0x53>
  102e58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e5a:	89 f0                	mov    %esi,%eax
  102e5c:	89 fa                	mov    %edi,%edx
  102e5e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102e61:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e64:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102e67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102e6a:	eb 36                	jmp    102ea2 <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102e6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e6f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e75:	01 c2                	add    %eax,%edx
  102e77:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e7a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e80:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102e83:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e86:	89 c1                	mov    %eax,%ecx
  102e88:	89 d8                	mov    %ebx,%eax
  102e8a:	89 d6                	mov    %edx,%esi
  102e8c:	89 c7                	mov    %eax,%edi
  102e8e:	fd                   	std    
  102e8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e91:	fc                   	cld    
  102e92:	89 f8                	mov    %edi,%eax
  102e94:	89 f2                	mov    %esi,%edx
  102e96:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102e99:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102e9c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102ea2:	83 c4 30             	add    $0x30,%esp
  102ea5:	5b                   	pop    %ebx
  102ea6:	5e                   	pop    %esi
  102ea7:	5f                   	pop    %edi
  102ea8:	5d                   	pop    %ebp
  102ea9:	c3                   	ret    

00102eaa <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102eaa:	55                   	push   %ebp
  102eab:	89 e5                	mov    %esp,%ebp
  102ead:	57                   	push   %edi
  102eae:	56                   	push   %esi
  102eaf:	83 ec 20             	sub    $0x20,%esp
  102eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  102eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ebe:	8b 45 10             	mov    0x10(%ebp),%eax
  102ec1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102ec4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ec7:	c1 e8 02             	shr    $0x2,%eax
  102eca:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102ecc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ed2:	89 d7                	mov    %edx,%edi
  102ed4:	89 c6                	mov    %eax,%esi
  102ed6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102ed8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102edb:	83 e1 03             	and    $0x3,%ecx
  102ede:	74 02                	je     102ee2 <memcpy+0x38>
  102ee0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102ee2:	89 f0                	mov    %esi,%eax
  102ee4:	89 fa                	mov    %edi,%edx
  102ee6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102ee9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102eec:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102ef2:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102ef3:	83 c4 20             	add    $0x20,%esp
  102ef6:	5e                   	pop    %esi
  102ef7:	5f                   	pop    %edi
  102ef8:	5d                   	pop    %ebp
  102ef9:	c3                   	ret    

00102efa <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102efa:	55                   	push   %ebp
  102efb:	89 e5                	mov    %esp,%ebp
  102efd:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102f00:	8b 45 08             	mov    0x8(%ebp),%eax
  102f03:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f09:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102f0c:	eb 2e                	jmp    102f3c <memcmp+0x42>
        if (*s1 != *s2) {
  102f0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f11:	0f b6 10             	movzbl (%eax),%edx
  102f14:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f17:	0f b6 00             	movzbl (%eax),%eax
  102f1a:	38 c2                	cmp    %al,%dl
  102f1c:	74 18                	je     102f36 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102f1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f21:	0f b6 00             	movzbl (%eax),%eax
  102f24:	0f b6 d0             	movzbl %al,%edx
  102f27:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f2a:	0f b6 00             	movzbl (%eax),%eax
  102f2d:	0f b6 c0             	movzbl %al,%eax
  102f30:	29 c2                	sub    %eax,%edx
  102f32:	89 d0                	mov    %edx,%eax
  102f34:	eb 18                	jmp    102f4e <memcmp+0x54>
        }
        s1 ++, s2 ++;
  102f36:	ff 45 fc             	incl   -0x4(%ebp)
  102f39:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  102f3c:	8b 45 10             	mov    0x10(%ebp),%eax
  102f3f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f42:	89 55 10             	mov    %edx,0x10(%ebp)
  102f45:	85 c0                	test   %eax,%eax
  102f47:	75 c5                	jne    102f0e <memcmp+0x14>
    }
    return 0;
  102f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102f4e:	c9                   	leave  
  102f4f:	c3                   	ret    

00102f50 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102f50:	55                   	push   %ebp
  102f51:	89 e5                	mov    %esp,%ebp
  102f53:	83 ec 58             	sub    $0x58,%esp
  102f56:	8b 45 10             	mov    0x10(%ebp),%eax
  102f59:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f5c:	8b 45 14             	mov    0x14(%ebp),%eax
  102f5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f65:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f68:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102f6b:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102f6e:	8b 45 18             	mov    0x18(%ebp),%eax
  102f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102f74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f77:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f7d:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f8a:	74 1c                	je     102fa8 <printnum+0x58>
  102f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  102f94:	f7 75 e4             	divl   -0x1c(%ebp)
  102f97:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f9d:	ba 00 00 00 00       	mov    $0x0,%edx
  102fa2:	f7 75 e4             	divl   -0x1c(%ebp)
  102fa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102fae:	f7 75 e4             	divl   -0x1c(%ebp)
  102fb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102fb4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102fb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102fbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102fc0:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102fc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102fc6:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102fc9:	8b 45 18             	mov    0x18(%ebp),%eax
  102fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  102fd1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102fd4:	72 56                	jb     10302c <printnum+0xdc>
  102fd6:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  102fd9:	77 05                	ja     102fe0 <printnum+0x90>
  102fdb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102fde:	72 4c                	jb     10302c <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102fe0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102fe3:	8d 50 ff             	lea    -0x1(%eax),%edx
  102fe6:	8b 45 20             	mov    0x20(%ebp),%eax
  102fe9:	89 44 24 18          	mov    %eax,0x18(%esp)
  102fed:	89 54 24 14          	mov    %edx,0x14(%esp)
  102ff1:	8b 45 18             	mov    0x18(%ebp),%eax
  102ff4:	89 44 24 10          	mov    %eax,0x10(%esp)
  102ff8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ffb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  103002:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103006:	8b 45 0c             	mov    0xc(%ebp),%eax
  103009:	89 44 24 04          	mov    %eax,0x4(%esp)
  10300d:	8b 45 08             	mov    0x8(%ebp),%eax
  103010:	89 04 24             	mov    %eax,(%esp)
  103013:	e8 38 ff ff ff       	call   102f50 <printnum>
  103018:	eb 1b                	jmp    103035 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10301a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10301d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103021:	8b 45 20             	mov    0x20(%ebp),%eax
  103024:	89 04 24             	mov    %eax,(%esp)
  103027:	8b 45 08             	mov    0x8(%ebp),%eax
  10302a:	ff d0                	call   *%eax
        while (-- width > 0)
  10302c:	ff 4d 1c             	decl   0x1c(%ebp)
  10302f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103033:	7f e5                	jg     10301a <printnum+0xca>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103035:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103038:	05 70 3d 10 00       	add    $0x103d70,%eax
  10303d:	0f b6 00             	movzbl (%eax),%eax
  103040:	0f be c0             	movsbl %al,%eax
  103043:	8b 55 0c             	mov    0xc(%ebp),%edx
  103046:	89 54 24 04          	mov    %edx,0x4(%esp)
  10304a:	89 04 24             	mov    %eax,(%esp)
  10304d:	8b 45 08             	mov    0x8(%ebp),%eax
  103050:	ff d0                	call   *%eax
}
  103052:	90                   	nop
  103053:	c9                   	leave  
  103054:	c3                   	ret    

00103055 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103055:	55                   	push   %ebp
  103056:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103058:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10305c:	7e 14                	jle    103072 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10305e:	8b 45 08             	mov    0x8(%ebp),%eax
  103061:	8b 00                	mov    (%eax),%eax
  103063:	8d 48 08             	lea    0x8(%eax),%ecx
  103066:	8b 55 08             	mov    0x8(%ebp),%edx
  103069:	89 0a                	mov    %ecx,(%edx)
  10306b:	8b 50 04             	mov    0x4(%eax),%edx
  10306e:	8b 00                	mov    (%eax),%eax
  103070:	eb 30                	jmp    1030a2 <getuint+0x4d>
    }
    else if (lflag) {
  103072:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103076:	74 16                	je     10308e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  103078:	8b 45 08             	mov    0x8(%ebp),%eax
  10307b:	8b 00                	mov    (%eax),%eax
  10307d:	8d 48 04             	lea    0x4(%eax),%ecx
  103080:	8b 55 08             	mov    0x8(%ebp),%edx
  103083:	89 0a                	mov    %ecx,(%edx)
  103085:	8b 00                	mov    (%eax),%eax
  103087:	ba 00 00 00 00       	mov    $0x0,%edx
  10308c:	eb 14                	jmp    1030a2 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10308e:	8b 45 08             	mov    0x8(%ebp),%eax
  103091:	8b 00                	mov    (%eax),%eax
  103093:	8d 48 04             	lea    0x4(%eax),%ecx
  103096:	8b 55 08             	mov    0x8(%ebp),%edx
  103099:	89 0a                	mov    %ecx,(%edx)
  10309b:	8b 00                	mov    (%eax),%eax
  10309d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1030a2:	5d                   	pop    %ebp
  1030a3:	c3                   	ret    

001030a4 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1030a4:	55                   	push   %ebp
  1030a5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1030a7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1030ab:	7e 14                	jle    1030c1 <getint+0x1d>
        return va_arg(*ap, long long);
  1030ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1030b0:	8b 00                	mov    (%eax),%eax
  1030b2:	8d 48 08             	lea    0x8(%eax),%ecx
  1030b5:	8b 55 08             	mov    0x8(%ebp),%edx
  1030b8:	89 0a                	mov    %ecx,(%edx)
  1030ba:	8b 50 04             	mov    0x4(%eax),%edx
  1030bd:	8b 00                	mov    (%eax),%eax
  1030bf:	eb 28                	jmp    1030e9 <getint+0x45>
    }
    else if (lflag) {
  1030c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1030c5:	74 12                	je     1030d9 <getint+0x35>
        return va_arg(*ap, long);
  1030c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ca:	8b 00                	mov    (%eax),%eax
  1030cc:	8d 48 04             	lea    0x4(%eax),%ecx
  1030cf:	8b 55 08             	mov    0x8(%ebp),%edx
  1030d2:	89 0a                	mov    %ecx,(%edx)
  1030d4:	8b 00                	mov    (%eax),%eax
  1030d6:	99                   	cltd   
  1030d7:	eb 10                	jmp    1030e9 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1030d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030dc:	8b 00                	mov    (%eax),%eax
  1030de:	8d 48 04             	lea    0x4(%eax),%ecx
  1030e1:	8b 55 08             	mov    0x8(%ebp),%edx
  1030e4:	89 0a                	mov    %ecx,(%edx)
  1030e6:	8b 00                	mov    (%eax),%eax
  1030e8:	99                   	cltd   
    }
}
  1030e9:	5d                   	pop    %ebp
  1030ea:	c3                   	ret    

001030eb <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1030eb:	55                   	push   %ebp
  1030ec:	89 e5                	mov    %esp,%ebp
  1030ee:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1030f1:	8d 45 14             	lea    0x14(%ebp),%eax
  1030f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1030f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1030fe:	8b 45 10             	mov    0x10(%ebp),%eax
  103101:	89 44 24 08          	mov    %eax,0x8(%esp)
  103105:	8b 45 0c             	mov    0xc(%ebp),%eax
  103108:	89 44 24 04          	mov    %eax,0x4(%esp)
  10310c:	8b 45 08             	mov    0x8(%ebp),%eax
  10310f:	89 04 24             	mov    %eax,(%esp)
  103112:	e8 03 00 00 00       	call   10311a <vprintfmt>
    va_end(ap);
}
  103117:	90                   	nop
  103118:	c9                   	leave  
  103119:	c3                   	ret    

0010311a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10311a:	55                   	push   %ebp
  10311b:	89 e5                	mov    %esp,%ebp
  10311d:	56                   	push   %esi
  10311e:	53                   	push   %ebx
  10311f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103122:	eb 17                	jmp    10313b <vprintfmt+0x21>
            if (ch == '\0') {
  103124:	85 db                	test   %ebx,%ebx
  103126:	0f 84 bf 03 00 00    	je     1034eb <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  10312c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10312f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103133:	89 1c 24             	mov    %ebx,(%esp)
  103136:	8b 45 08             	mov    0x8(%ebp),%eax
  103139:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10313b:	8b 45 10             	mov    0x10(%ebp),%eax
  10313e:	8d 50 01             	lea    0x1(%eax),%edx
  103141:	89 55 10             	mov    %edx,0x10(%ebp)
  103144:	0f b6 00             	movzbl (%eax),%eax
  103147:	0f b6 d8             	movzbl %al,%ebx
  10314a:	83 fb 25             	cmp    $0x25,%ebx
  10314d:	75 d5                	jne    103124 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10314f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  103153:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10315a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10315d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103160:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103167:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10316a:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10316d:	8b 45 10             	mov    0x10(%ebp),%eax
  103170:	8d 50 01             	lea    0x1(%eax),%edx
  103173:	89 55 10             	mov    %edx,0x10(%ebp)
  103176:	0f b6 00             	movzbl (%eax),%eax
  103179:	0f b6 d8             	movzbl %al,%ebx
  10317c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10317f:	83 f8 55             	cmp    $0x55,%eax
  103182:	0f 87 37 03 00 00    	ja     1034bf <vprintfmt+0x3a5>
  103188:	8b 04 85 94 3d 10 00 	mov    0x103d94(,%eax,4),%eax
  10318f:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103191:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103195:	eb d6                	jmp    10316d <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103197:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10319b:	eb d0                	jmp    10316d <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10319d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1031a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1031a7:	89 d0                	mov    %edx,%eax
  1031a9:	c1 e0 02             	shl    $0x2,%eax
  1031ac:	01 d0                	add    %edx,%eax
  1031ae:	01 c0                	add    %eax,%eax
  1031b0:	01 d8                	add    %ebx,%eax
  1031b2:	83 e8 30             	sub    $0x30,%eax
  1031b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1031b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1031bb:	0f b6 00             	movzbl (%eax),%eax
  1031be:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1031c1:	83 fb 2f             	cmp    $0x2f,%ebx
  1031c4:	7e 38                	jle    1031fe <vprintfmt+0xe4>
  1031c6:	83 fb 39             	cmp    $0x39,%ebx
  1031c9:	7f 33                	jg     1031fe <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  1031cb:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1031ce:	eb d4                	jmp    1031a4 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1031d0:	8b 45 14             	mov    0x14(%ebp),%eax
  1031d3:	8d 50 04             	lea    0x4(%eax),%edx
  1031d6:	89 55 14             	mov    %edx,0x14(%ebp)
  1031d9:	8b 00                	mov    (%eax),%eax
  1031db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1031de:	eb 1f                	jmp    1031ff <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  1031e0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031e4:	79 87                	jns    10316d <vprintfmt+0x53>
                width = 0;
  1031e6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1031ed:	e9 7b ff ff ff       	jmp    10316d <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1031f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1031f9:	e9 6f ff ff ff       	jmp    10316d <vprintfmt+0x53>
            goto process_precision;
  1031fe:	90                   	nop

        process_precision:
            if (width < 0)
  1031ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103203:	0f 89 64 ff ff ff    	jns    10316d <vprintfmt+0x53>
                width = precision, precision = -1;
  103209:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10320c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10320f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  103216:	e9 52 ff ff ff       	jmp    10316d <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10321b:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  10321e:	e9 4a ff ff ff       	jmp    10316d <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  103223:	8b 45 14             	mov    0x14(%ebp),%eax
  103226:	8d 50 04             	lea    0x4(%eax),%edx
  103229:	89 55 14             	mov    %edx,0x14(%ebp)
  10322c:	8b 00                	mov    (%eax),%eax
  10322e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103231:	89 54 24 04          	mov    %edx,0x4(%esp)
  103235:	89 04 24             	mov    %eax,(%esp)
  103238:	8b 45 08             	mov    0x8(%ebp),%eax
  10323b:	ff d0                	call   *%eax
            break;
  10323d:	e9 a4 02 00 00       	jmp    1034e6 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  103242:	8b 45 14             	mov    0x14(%ebp),%eax
  103245:	8d 50 04             	lea    0x4(%eax),%edx
  103248:	89 55 14             	mov    %edx,0x14(%ebp)
  10324b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10324d:	85 db                	test   %ebx,%ebx
  10324f:	79 02                	jns    103253 <vprintfmt+0x139>
                err = -err;
  103251:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  103253:	83 fb 06             	cmp    $0x6,%ebx
  103256:	7f 0b                	jg     103263 <vprintfmt+0x149>
  103258:	8b 34 9d 54 3d 10 00 	mov    0x103d54(,%ebx,4),%esi
  10325f:	85 f6                	test   %esi,%esi
  103261:	75 23                	jne    103286 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  103263:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103267:	c7 44 24 08 81 3d 10 	movl   $0x103d81,0x8(%esp)
  10326e:	00 
  10326f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103272:	89 44 24 04          	mov    %eax,0x4(%esp)
  103276:	8b 45 08             	mov    0x8(%ebp),%eax
  103279:	89 04 24             	mov    %eax,(%esp)
  10327c:	e8 6a fe ff ff       	call   1030eb <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  103281:	e9 60 02 00 00       	jmp    1034e6 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  103286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10328a:	c7 44 24 08 8a 3d 10 	movl   $0x103d8a,0x8(%esp)
  103291:	00 
  103292:	8b 45 0c             	mov    0xc(%ebp),%eax
  103295:	89 44 24 04          	mov    %eax,0x4(%esp)
  103299:	8b 45 08             	mov    0x8(%ebp),%eax
  10329c:	89 04 24             	mov    %eax,(%esp)
  10329f:	e8 47 fe ff ff       	call   1030eb <printfmt>
            break;
  1032a4:	e9 3d 02 00 00       	jmp    1034e6 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1032a9:	8b 45 14             	mov    0x14(%ebp),%eax
  1032ac:	8d 50 04             	lea    0x4(%eax),%edx
  1032af:	89 55 14             	mov    %edx,0x14(%ebp)
  1032b2:	8b 30                	mov    (%eax),%esi
  1032b4:	85 f6                	test   %esi,%esi
  1032b6:	75 05                	jne    1032bd <vprintfmt+0x1a3>
                p = "(null)";
  1032b8:	be 8d 3d 10 00       	mov    $0x103d8d,%esi
            }
            if (width > 0 && padc != '-') {
  1032bd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032c1:	7e 76                	jle    103339 <vprintfmt+0x21f>
  1032c3:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1032c7:	74 70                	je     103339 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1032c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032d0:	89 34 24             	mov    %esi,(%esp)
  1032d3:	e8 f6 f7 ff ff       	call   102ace <strnlen>
  1032d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1032db:	29 c2                	sub    %eax,%edx
  1032dd:	89 d0                	mov    %edx,%eax
  1032df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032e2:	eb 16                	jmp    1032fa <vprintfmt+0x1e0>
                    putch(padc, putdat);
  1032e4:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1032e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1032eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  1032ef:	89 04 24             	mov    %eax,(%esp)
  1032f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f5:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  1032f7:	ff 4d e8             	decl   -0x18(%ebp)
  1032fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032fe:	7f e4                	jg     1032e4 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103300:	eb 37                	jmp    103339 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  103302:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103306:	74 1f                	je     103327 <vprintfmt+0x20d>
  103308:	83 fb 1f             	cmp    $0x1f,%ebx
  10330b:	7e 05                	jle    103312 <vprintfmt+0x1f8>
  10330d:	83 fb 7e             	cmp    $0x7e,%ebx
  103310:	7e 15                	jle    103327 <vprintfmt+0x20d>
                    putch('?', putdat);
  103312:	8b 45 0c             	mov    0xc(%ebp),%eax
  103315:	89 44 24 04          	mov    %eax,0x4(%esp)
  103319:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  103320:	8b 45 08             	mov    0x8(%ebp),%eax
  103323:	ff d0                	call   *%eax
  103325:	eb 0f                	jmp    103336 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  103327:	8b 45 0c             	mov    0xc(%ebp),%eax
  10332a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10332e:	89 1c 24             	mov    %ebx,(%esp)
  103331:	8b 45 08             	mov    0x8(%ebp),%eax
  103334:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103336:	ff 4d e8             	decl   -0x18(%ebp)
  103339:	89 f0                	mov    %esi,%eax
  10333b:	8d 70 01             	lea    0x1(%eax),%esi
  10333e:	0f b6 00             	movzbl (%eax),%eax
  103341:	0f be d8             	movsbl %al,%ebx
  103344:	85 db                	test   %ebx,%ebx
  103346:	74 27                	je     10336f <vprintfmt+0x255>
  103348:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10334c:	78 b4                	js     103302 <vprintfmt+0x1e8>
  10334e:	ff 4d e4             	decl   -0x1c(%ebp)
  103351:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103355:	79 ab                	jns    103302 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  103357:	eb 16                	jmp    10336f <vprintfmt+0x255>
                putch(' ', putdat);
  103359:	8b 45 0c             	mov    0xc(%ebp),%eax
  10335c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103360:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103367:	8b 45 08             	mov    0x8(%ebp),%eax
  10336a:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  10336c:	ff 4d e8             	decl   -0x18(%ebp)
  10336f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103373:	7f e4                	jg     103359 <vprintfmt+0x23f>
            }
            break;
  103375:	e9 6c 01 00 00       	jmp    1034e6 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10337a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10337d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103381:	8d 45 14             	lea    0x14(%ebp),%eax
  103384:	89 04 24             	mov    %eax,(%esp)
  103387:	e8 18 fd ff ff       	call   1030a4 <getint>
  10338c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10338f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103392:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103395:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103398:	85 d2                	test   %edx,%edx
  10339a:	79 26                	jns    1033c2 <vprintfmt+0x2a8>
                putch('-', putdat);
  10339c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10339f:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1033aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ad:	ff d0                	call   *%eax
                num = -(long long)num;
  1033af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1033b5:	f7 d8                	neg    %eax
  1033b7:	83 d2 00             	adc    $0x0,%edx
  1033ba:	f7 da                	neg    %edx
  1033bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1033c2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1033c9:	e9 a8 00 00 00       	jmp    103476 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1033ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033d5:	8d 45 14             	lea    0x14(%ebp),%eax
  1033d8:	89 04 24             	mov    %eax,(%esp)
  1033db:	e8 75 fc ff ff       	call   103055 <getuint>
  1033e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1033e6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1033ed:	e9 84 00 00 00       	jmp    103476 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1033f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033f9:	8d 45 14             	lea    0x14(%ebp),%eax
  1033fc:	89 04 24             	mov    %eax,(%esp)
  1033ff:	e8 51 fc ff ff       	call   103055 <getuint>
  103404:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103407:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10340a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  103411:	eb 63                	jmp    103476 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  103413:	8b 45 0c             	mov    0xc(%ebp),%eax
  103416:	89 44 24 04          	mov    %eax,0x4(%esp)
  10341a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  103421:	8b 45 08             	mov    0x8(%ebp),%eax
  103424:	ff d0                	call   *%eax
            putch('x', putdat);
  103426:	8b 45 0c             	mov    0xc(%ebp),%eax
  103429:	89 44 24 04          	mov    %eax,0x4(%esp)
  10342d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  103434:	8b 45 08             	mov    0x8(%ebp),%eax
  103437:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103439:	8b 45 14             	mov    0x14(%ebp),%eax
  10343c:	8d 50 04             	lea    0x4(%eax),%edx
  10343f:	89 55 14             	mov    %edx,0x14(%ebp)
  103442:	8b 00                	mov    (%eax),%eax
  103444:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103447:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10344e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103455:	eb 1f                	jmp    103476 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103457:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10345a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10345e:	8d 45 14             	lea    0x14(%ebp),%eax
  103461:	89 04 24             	mov    %eax,(%esp)
  103464:	e8 ec fb ff ff       	call   103055 <getuint>
  103469:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10346c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10346f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103476:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10347a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10347d:	89 54 24 18          	mov    %edx,0x18(%esp)
  103481:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103484:	89 54 24 14          	mov    %edx,0x14(%esp)
  103488:	89 44 24 10          	mov    %eax,0x10(%esp)
  10348c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10348f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103492:	89 44 24 08          	mov    %eax,0x8(%esp)
  103496:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10349a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1034a4:	89 04 24             	mov    %eax,(%esp)
  1034a7:	e8 a4 fa ff ff       	call   102f50 <printnum>
            break;
  1034ac:	eb 38                	jmp    1034e6 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1034ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034b5:	89 1c 24             	mov    %ebx,(%esp)
  1034b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1034bb:	ff d0                	call   *%eax
            break;
  1034bd:	eb 27                	jmp    1034e6 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1034bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034c6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1034cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1034d0:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1034d2:	ff 4d 10             	decl   0x10(%ebp)
  1034d5:	eb 03                	jmp    1034da <vprintfmt+0x3c0>
  1034d7:	ff 4d 10             	decl   0x10(%ebp)
  1034da:	8b 45 10             	mov    0x10(%ebp),%eax
  1034dd:	48                   	dec    %eax
  1034de:	0f b6 00             	movzbl (%eax),%eax
  1034e1:	3c 25                	cmp    $0x25,%al
  1034e3:	75 f2                	jne    1034d7 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  1034e5:	90                   	nop
    while (1) {
  1034e6:	e9 37 fc ff ff       	jmp    103122 <vprintfmt+0x8>
                return;
  1034eb:	90                   	nop
        }
    }
}
  1034ec:	83 c4 40             	add    $0x40,%esp
  1034ef:	5b                   	pop    %ebx
  1034f0:	5e                   	pop    %esi
  1034f1:	5d                   	pop    %ebp
  1034f2:	c3                   	ret    

001034f3 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1034f3:	55                   	push   %ebp
  1034f4:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1034f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f9:	8b 40 08             	mov    0x8(%eax),%eax
  1034fc:	8d 50 01             	lea    0x1(%eax),%edx
  1034ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  103502:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  103505:	8b 45 0c             	mov    0xc(%ebp),%eax
  103508:	8b 10                	mov    (%eax),%edx
  10350a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10350d:	8b 40 04             	mov    0x4(%eax),%eax
  103510:	39 c2                	cmp    %eax,%edx
  103512:	73 12                	jae    103526 <sprintputch+0x33>
        *b->buf ++ = ch;
  103514:	8b 45 0c             	mov    0xc(%ebp),%eax
  103517:	8b 00                	mov    (%eax),%eax
  103519:	8d 48 01             	lea    0x1(%eax),%ecx
  10351c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10351f:	89 0a                	mov    %ecx,(%edx)
  103521:	8b 55 08             	mov    0x8(%ebp),%edx
  103524:	88 10                	mov    %dl,(%eax)
    }
}
  103526:	90                   	nop
  103527:	5d                   	pop    %ebp
  103528:	c3                   	ret    

00103529 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103529:	55                   	push   %ebp
  10352a:	89 e5                	mov    %esp,%ebp
  10352c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10352f:	8d 45 14             	lea    0x14(%ebp),%eax
  103532:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10353c:	8b 45 10             	mov    0x10(%ebp),%eax
  10353f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103543:	8b 45 0c             	mov    0xc(%ebp),%eax
  103546:	89 44 24 04          	mov    %eax,0x4(%esp)
  10354a:	8b 45 08             	mov    0x8(%ebp),%eax
  10354d:	89 04 24             	mov    %eax,(%esp)
  103550:	e8 08 00 00 00       	call   10355d <vsnprintf>
  103555:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  103558:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10355b:	c9                   	leave  
  10355c:	c3                   	ret    

0010355d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  10355d:	55                   	push   %ebp
  10355e:	89 e5                	mov    %esp,%ebp
  103560:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  103563:	8b 45 08             	mov    0x8(%ebp),%eax
  103566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103569:	8b 45 0c             	mov    0xc(%ebp),%eax
  10356c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10356f:	8b 45 08             	mov    0x8(%ebp),%eax
  103572:	01 d0                	add    %edx,%eax
  103574:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103577:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10357e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103582:	74 0a                	je     10358e <vsnprintf+0x31>
  103584:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10358a:	39 c2                	cmp    %eax,%edx
  10358c:	76 07                	jbe    103595 <vsnprintf+0x38>
        return -E_INVAL;
  10358e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103593:	eb 2a                	jmp    1035bf <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103595:	8b 45 14             	mov    0x14(%ebp),%eax
  103598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10359c:	8b 45 10             	mov    0x10(%ebp),%eax
  10359f:	89 44 24 08          	mov    %eax,0x8(%esp)
  1035a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1035a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035aa:	c7 04 24 f3 34 10 00 	movl   $0x1034f3,(%esp)
  1035b1:	e8 64 fb ff ff       	call   10311a <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1035b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1035b9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1035bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1035bf:	c9                   	leave  
  1035c0:	c3                   	ret    
