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

#define MASK_Pro_One   0xaaaaaaaaU
#define MASK_Pro_Two   0x33333333U
#define MASK_Pro_Three   0xff00ff00U
//#define MASK_Pro_Head   0x40ffffffU
#define  kYDCrashProtector_Count  2
unsigned mfDlt() {
    return 16; //WORD_BIT/8;//stat info
}
void setProtector(unsigned int *p) {
    *(p-1) = MASK_Pro_One;
    *(p-2) = MASK_Pro_Two;
}
bool isProtector(unsigned int *p) {
    unsigned int *one = p-1;
    unsigned int *two = p-2;
    bool flag = (MASK_Pro_One == *one &&
                 MASK_Pro_Two == *two);
    return flag;
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
static void (*origFree)(void *);        //finished
static void newFree(void *ptr) {
    if (!ptr) {
        return;
    }
    if (isProtector(ptr)) {
        void *rprt = ptr - mfDlt();
        printf("\nwjf freem p %p;", rprt );
        origFree(rprt);
    }else {
        origFree(ptr);
        printf("\nwjf free %p;", ptr );
    }
}

static void* (*origMalloc)(size_t);     //finished
static void *newMalloc(size_t size) {
    void *ptr = origMalloc(size + mfDlt());
    memset(ptr, 0, size + mfDlt());
    void *p = ptr+mfDlt();
    setProtector(p);
    printf("\nwjf malloc %p;", ptr );
    return ptr + mfDlt();
}

static void* (*origCalloc)(size_t __count, size_t __size);
static void *newCalloc(size_t __count, size_t __size) {
    void * ptr = origCalloc(__count, __size);
    printf("\n wjf calloc %p;", ptr );
    return ptr;
}

//The obsolete function valloc() allocates size bytes
//and returns a pointer to the allocated memory.
//The memory address will be a multiple of the page size.
//It is equivalent to memalign(sysconf(_SC_PAGESIZE),size).
//static void* (*origValloc)(size_t __size);
//static void *newValloc(size_t __size) {
//    void *ptr = origValloc(__size + mfDlt());
//    valloc(<#size_t#>)
//    memset(ptr, 0, __size + mfDlt());
//    int *count = ptr;
//    *count = 1;
//    int cvalue = *count;
//    void *rprt = ptr + mfDlt();
//    return rprt;
//}

#pragma mark -- re-alloc

static void* (*origRealloc)(void *__ptr, size_t __size);
static void *newRealloc(void *__ptr, size_t __size) {
    if (!__ptr) {
        return malloc(__size);
    }
    if (isProtector(__ptr)) {
        size_t size = __size + mfDlt();
        void * lp = __ptr - mfDlt();
        void *ptr = origRealloc(lp, size);
        if (!ptr) {
            return NULL;
        }
        ptr += mfDlt();
        return ptr;
    }else {
        void *ptr = origRealloc(__ptr, __size);
        return ptr;
    }
}

static void* (*origReallocf)(void *__ptr, size_t __size);
static void *newReallocf(void *__ptr, size_t __size) {
    if (!__ptr) {
        return malloc(__size);
    }
    if (isProtector(__ptr)) {
        size_t size = __size + mfDlt();
        void * lp = __ptr - mfDlt();
        void *ptr = origReallocf(lp, size);
        if (!ptr) {
            return NULL;
        }
        ptr += mfDlt();
        return ptr;
    } else {
        return origReallocf(__ptr, __size);
    }
}

static void * (*orig_memset)(void *b, int c, size_t len);
static void * new_memset(void *b, int c, size_t len) {
    return orig_memset(b, c, len);
}
//__attribute__((constructor)) static
void crashProtectorHook() {
//     static dispatch_once_t onceTokenMalloc;
//     dispatch_once(&onceTokenMalloc, ^{
//    malloc_zone_malloc(<#malloc_zone_t *zone#>, <#size_t size#>)
    origFree = dlsym(RTLD_DEFAULT, "free");
    origMalloc = dlsym(RTLD_DEFAULT, "malloc");
    origCalloc = dlsym(RTLD_DEFAULT, "calloc");
    origRealloc = dlsym(RTLD_DEFAULT, "realloc");
    origReallocf = dlsym(RTLD_DEFAULT, "reallocf");
    
         struct rebinding rebindings[] = {
             {"free", newFree, NULL},
             {"malloc", newMalloc, NULL},
             {"calloc", newCalloc, NULL},
             {"realloc", newRealloc, NULL},
             {"reallocf", newReallocf, NULL},
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
