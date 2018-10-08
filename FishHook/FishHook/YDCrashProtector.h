//
//  YDCrashProtector.h
//  YDOfflineNMT
//
//  Created by jufan wang on 2018/9/6.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"

@interface YDCrashProtector : NSObject
@end

//create_legacy_scalable_zone

//0  +[someclass load]
//1  call_class_loads()
//2  ::call_load_methods
//3  ::load_images(const char *path __unused, const struct mach_header *mh)
//4  dyld::notifySingle(dyld_image_states, ImageLoader const*, ImageLoader::InitializerTimingList*)
//11 _dyld_start

