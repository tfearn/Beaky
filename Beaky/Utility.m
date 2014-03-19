//
//  Utility.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (id)objectNotNSNull:(id)object {
	if(object == [NSNull null])
		return nil;
	return object;
}

+(NSString *)getUUID {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
