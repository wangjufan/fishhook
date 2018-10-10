//
//  YDCrashProtector.h
//  YDOfflineNMT
//
//  Created by jufan wang on 2018/9/6.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"

#import <mach/vm_map.h>

void crashProtectorHook();

//static void crashProtectorHook(void);
@interface YDCrashProtector : NSObject
@end

//create_legacy_scalable_zone

//0  +[someclass load]
//1  call_class_loads()
//2  ::call_load_methods
//3  ::load_images(const char *path __unused, const struct mach_header *mh)
//4  dyld::notifySingle(dyld_image_states, ImageLoader const*, ImageLoader::InitializerTimingList*)
//11 _dyld_start


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
//static kern_return_t (*orig_vm_write)(
//                                      vm_map_t target_task,
//                                      vm_address_t address,
//                                      vm_offset_t data,
//                                      mach_msg_type_number_t dataCnt);
//static kern_return_t new_vm_write(
//                                  vm_map_t target_task,
//                                  vm_address_t address,
//                                  vm_offset_t data,
//                                  mach_msg_type_number_t dataCnt
//                                  ) {
//    return orig_vm_write(target_task, address, data, dataCnt);
//}
//
//static kern_return_t (*orig_vm_read)(
//                                     vm_map_t target_task,
//                                     vm_address_t address,
//                                     vm_size_t size,
//                                     vm_offset_t *data,
//                                     mach_msg_type_number_t *dataCnt);
//static kern_return_t new_vm_read(
//                                 vm_map_t target_task,
//                                 vm_address_t address,
//                                 vm_size_t size,
//                                 vm_offset_t *data,
//                                 mach_msg_type_number_t *dataCnt) {
//    return orig_vm_read(target_task, address, size, data, dataCnt);
//}
//
//static kern_return_t (*orig_vm_map)(vm_map_t target_task, vm_address_t *address, vm_size_t size, vm_address_t mask, int flags, mem_entry_name_port_t object, vm_offset_t offset, boolean_t copy, vm_prot_t cur_protection, vm_prot_t max_protection, vm_inherit_t inheritance);
//static kern_return_t new_vm_map(vm_map_t target_task, vm_address_t *address, vm_size_t size, vm_address_t mask, int flags, mem_entry_name_port_t object, vm_offset_t offset, boolean_t copy, vm_prot_t cur_protection, vm_prot_t max_protection, vm_inherit_t inheritance) {
//    return orig_vm_map(target_task, address, size, mask, flags, object, offset, copy, cur_protection, max_protection, inheritance);
//}
//
//static kern_return_t (*orig_vm_allocate)(
//                                         vm_map_t target_task,
//                                         vm_address_t *address,
//                                         vm_size_t size,
//                                         int flags);
//static kern_return_t new_vm_allocate(
//                                     vm_map_t target_task,
//                                     vm_address_t *address,
//                                     vm_size_t size,
//                                     int flags) {
//    return orig_vm_allocate(target_task, address, size, flags);
//}
