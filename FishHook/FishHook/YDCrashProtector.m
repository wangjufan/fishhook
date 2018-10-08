//
//  YDCrashProtector.m
//  YDOfflineNMT
//
//  Created by jufan wang on 2018/9/6.
//

#import "YDCrashProtector.h"

#import <objc/runtime.h>
#include <dlfcn.h>
#include <libkern/OSAtomic.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#else
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#endif

#include <dlfcn.h>
#include <libkern/OSAtomic.h>
#import <malloc/malloc.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <objc/runtime.h>
//#include <unordered_map>

#   define ISMASK_FREE_COUNT   0xff000000U
#define  kYDCrashProtector_Count  2
inline unsigned mfDlt() {
    return WORD_BIT/8;
}
inline bool isProtector(unsigned *p) {
    unsigned value = (*p & ISMASK_FREE_COUNT);
    return 0 == value;
}
typedef struct{
    void* isa;
}ObjcClassPtr;

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

void rebindSymbols_for_imagename(struct rebinding rebindings[],
                                 size_t rebindings_nel,
                                 const char *imagename) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const mach_header_t* header = (const mach_header_t*)_dyld_get_image_header(i);
        const char* name = _dyld_get_image_name(i);
        const char* tmp = strrchr(name, '/');
        long slide = _dyld_get_image_vmaddr_slide(i);
        if (tmp) {
            name = tmp + 1;
        }
        if(strcmp(name,imagename) == 0){
            rebind_symbols_image((void *)header,
                                 slide,
                                 rebindings,
                                 rebindings_nel);
            break;
        }
    }
}
const char *getImageName() {
    const char* name = _dyld_get_image_name(0);
    const char* tmp = strrchr(name, '/');
    if (tmp) {
        name = tmp + 1;
    }
    return name;
}

static void (*origFree)(void *);
static void newFree(void *ptr) {
    if (!ptr) {
        return;
    }
//    static dispatch_once_t onceToken;
//    static void * protector = nil;
//    dispatch_once(&onceToken, ^{
//        protector = (__bridge void*)[YDCrashProtector class];
//    });
//    if (malloc_size(ptr) >= sizeof(ObjcClassPtr)) {
//        ObjcClassPtr *objc_ptr = (ObjcClassPtr *)ptr;
//        objc_ptr->isa = protector;
//        YDCrashProtector * pro = (__bridge id) objc_ptr;
//        [pro description];
//    }else{
//    }
    if (isProtector(ptr)) {
        void *rprt = ptr - mfDlt();
        int *count = rprt;
        int cvalue = *count;
        if (cvalue == 1) {
            *count = 0;
            origFree(rprt);
        }else {
            return;
        }
    }else {
        
    }
}

static void* (*origMalloc)(size_t);
static void *newMalloc(size_t size) {
    void *ptr = origMalloc(size + mfDlt());
    memset(ptr, 0, size + mfDlt());
    int *count = ptr;
    *count = 1;
    int cvalue = *count;
    void *rprt = ptr + mfDlt();
    return rprt;
}

static void* (*origRealloc)(void *__ptr, size_t __size);
static void *newRealloc(void *__ptr, size_t __size) {
    __ptr -= mfDlt();
    void *ptr = origRealloc(__ptr, __size + mfDlt());
    memset(ptr, 0, __size+mfDlt());
    int *count = ptr;
    *count = 1;
    int cvalue = *count;
    void *rprt = ptr + mfDlt();
    return rprt;
}

static void* (*origCalloc)(void *__ptr, size_t __size);
static void *newCalloc(void *__ptr, size_t __size) {
    unsigned long addr = __ptr;
    void * mptr = __ptr - mfDlt();
    void *ptr = origCalloc(mptr, __size + mfDlt());
    memset(ptr, 0, __size + mfDlt());
    int *count = ptr;
    *count = 1;
    int cvalue = *count;
    void *rprt = ptr + mfDlt();
    return rprt;
}

static void* (*origReallocf)(void *__ptr, size_t __size);
static void *newReallocf(void *__ptr, size_t __size) {
    __ptr -= mfDlt();
    void *ptr = origReallocf(__ptr, __size + mfDlt());
    memset(ptr, 0, __size + mfDlt());
    int *count = ptr;
    *count = 1;
    int cvalue = *count;
    void *rprt = ptr + mfDlt();
    return rprt;
}

static void* (*origValloc)(size_t __size);
static void *newValloc(size_t __size) {
    void *ptr = origValloc(__size + mfDlt());
    memset(ptr, 0, __size + mfDlt());
    int *count = ptr;
    *count = 1;
    int cvalue = *count;
    void *rprt = ptr + mfDlt();
    return rprt;
}

//void    *malloc(size_t __size)
//void    *realloc(void *__ptr, size_t __size)
//void    *calloc(size_t __count, size_t __size)
//void    *reallocf(void *__ptr, size_t __size)
//void    *valloc(size_t)

__attribute__((constructor)) static void crashProtectorHook() {
//     static dispatch_once_t onceTokenMalloc;
//     dispatch_once(&onceTokenMalloc, ^{
//    malloc_zone_malloc(<#malloc_zone_t *zone#>, <#size_t size#>)
         origFree = dlsym(RTLD_DEFAULT, "free");
         origMalloc = dlsym(RTLD_DEFAULT, "malloc");
         origRealloc = dlsym(RTLD_DEFAULT, "realloc");
         origCalloc = dlsym(RTLD_DEFAULT, "calloc");
         origReallocf = dlsym(RTLD_DEFAULT, "reallocf");
         origValloc = dlsym(RTLD_DEFAULT, "valloc");
         struct rebinding rebindings[] = {
             {"free", newFree, NULL},
             {"malloc", newMalloc, NULL},
             {"realloc", newRealloc, NULL},
             {"calloc", newCalloc, NULL},
             {"reallocf", newReallocf, NULL},
             {"valloc", newValloc, NULL},
         };
         bool flag = rebind_symbols(rebindings,
                                    sizeof(rebindings)/sizeof(rebindings[0]));
         if (flag) {
             NSLog(@"failed !!!");
         }
//     });
}
@implementation YDCrashProtector

@end
