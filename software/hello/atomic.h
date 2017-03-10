// See LICENSE for license details.

#ifndef _RISCV_ATOMIC_H
#define _RISCV_ATOMIC_H

#define SPINLOCK_INIT 0
typedef int spinlock_t;

#define disable_irqsave() clear_csr(sstatus, SSTATUS_IE)
#define enable_irqrestore(flags) set_csr(sstatus, (flags) & SSTATUS_IE)

#define atomic_read(ptr) (*(volatile typeof(*(ptr)) *)(ptr))

#define atomic_add(ptr, inc) ({ \
  long flags = disable_irqsave(); \
  typeof(ptr) res = *(volatile typeof(ptr))(ptr); \
  *(volatile typeof(ptr))(ptr) = res + (inc); \
  enable_irqrestore(flags); \
  res; })

#define atomic_swap(ptr, swp) ({ \
  long flags = disable_irqsave(); \
  typeof(ptr) res = *(volatile typeof(ptr))(ptr); \
  *(volatile typeof(ptr))(ptr) = (swp); \
  enable_irqrestore(flags); \
  res; })

#define atomic_cas(ptr, cmp, swp) ({ \
  long flags = disable_irqsave(); \
  typeof(ptr) res = *(volatile typeof(ptr))(ptr); \
  if (res == (cmp)) *(volatile typeof(ptr))(ptr) = (swp); \
  enable_irqrestore(flags); \
  res; })

static inline void spinlock_lock(spinlock_t* lock)
{
}

static inline void spinlock_unlock(spinlock_t* lock)
{
}

static inline long spinlock_lock_irqsave(spinlock_t* lock)
{
}

static inline void spinlock_unlock_irqrestore(spinlock_t* lock, long flags)
{
}

#endif
