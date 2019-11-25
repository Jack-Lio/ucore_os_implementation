#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {     //TS自旋锁机制
    if (read_eflags() & FL_IF) {  //FL_IF 中断标志位
        intr_disable();   //关闭中断，返回一个1 表明中断已经关闭
        return 1;
    }
    return 0;       //否则表明中断标志位为0
}

static inline void
__intr_restore(bool flag) {     //如果中断标志为0，则不需要重新恢复中断，否则，将会激活中断
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */

