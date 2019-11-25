#include <defs.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_fifo.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

list_entry_t pra_list_head;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 *         初始化的时候将mm_struct 的sm_priv指针指向页面访问情况记录的链表，这样之后通过
 *          mm_struct就可以实现FIFO 替换策略了。
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */

// 用于记录页访问情况相关属性，重点实现算法,不过swap_in参数没有使用啊
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add_after(head,entry);       //将页面访问情况添加到（记录所有页访问情况的列表）head之后，这样最新访问的在最前面
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
 //后一个函数用于挑选需要换出的页
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);        //断言，head不能为0
     assert(in_tick==0);          //这里使用的是被动替换机制，所以不需要使用第三个参数，应该置位为0
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     list_entry_t* elm;
     elm = head->prev;    //获得最后一个链表项，表示最早访问的那一页
     assert(head!=elm);   //由于pra_list_head的头是空的所以不能够只有head一项，否则报错
     struct Page* pg = le2page(elm,pra_page_link);
     list_del(elm);
     assert(pg !=NULL);
     //(2)  assign the value of *ptr_page to the addr of this page
     *ptr_page = pg;                //将释放掉的物理页地址返回给参数ptr_page
      return 0;
}

// //实现extended clock替换算法的核心在与修改此函数
// static int
// _fifo_swap_out_victim_extended_clock(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
// {
//      list_entry_t *head=(list_entry_t*) mm->sm_priv;
//          assert(head != NULL);        //断言，head不能为0
//      assert(in_tick==0);          //这里使用的是被动替换机制，所以不需要使用第三个参数，应该置位为0
//      /* Select the victim */
//      /*LAB3 EXERCISE 2: YOUR CODE*/
//      //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
//      list_entry_t* elm = head;
//      int find_victim = false;
//      while((elm = head->next)!=head&&!find_victim)
//      {
//        if()
//           {
//             find_victim = true;
//             break;
//           }
//      }
//      while((elm = head->next)!=head&&!find_victim)
//      {
//        if()
//           {
//             find_victim = true;
//             break;
//           }
//      }
//      while((elm = head->next)!=head&&!find_victim)
//      {
//        if()
//           {
//             find_victim = true;
//             break;
//           }
//      }
//      assert(head!=elm);   //由于pra_list_head的头是空的所以不能够只有head一项，否则报错
//      struct Page* pg = le2page(elm,pra_page_link);
//      list_del(elm);
//      assert(pg !=NULL);
//      //(2)  assign the value of *ptr_page to the addr of this page
//      *ptr_page = pg;                //将释放掉的物理页地址返回给参数ptr_page
//       return 0;
// }

static int
_fifo_check_swap(void) {
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==8);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    cprintf("write Virt Page a in fifo_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}


static int
_fifo_init(void)
{
    return 0;
}

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_fifo =
{
     .name            = "fifo swap manager",
     .init            = &_fifo_init,
     .init_mm         = &_fifo_init_mm,
     .tick_event      = &_fifo_tick_event,
     .map_swappable   = &_fifo_map_swappable,
     .set_unswappable = &_fifo_set_unswappable,
     .swap_out_victim = &_fifo_swap_out_victim,
     .check_swap      = &_fifo_check_swap,
};
