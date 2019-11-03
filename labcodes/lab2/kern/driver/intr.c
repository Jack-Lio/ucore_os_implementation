#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt 打开中断 */
void
intr_enable(void) {
    sti();
}

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
    cli();
}
