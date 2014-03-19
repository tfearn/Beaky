//
//  Globals.h
//  Hedge360
//
//  Created by Todd Fearn on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notifications
#define kNotificationLoginComplete          @"NotificationLoginComplete"
#define kNotificationMyLocationUpdated      @"NotificationMyLocationUpdated"

// Urls
#define kUrlFacebookPicture         @"https://graph.facebook.com/%@/picture"

// Macros
#ifndef NDEBUG
#define MyLog(s, ... ) NSLog(@"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define MyLog( s, ... )
#endif

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)


// The number of seconds the application will be delayed upon startup.  This is used to display the splash screen for a longer time.
#define kStartupDelay				0.5


@interface Globals : NSObject {
}


@end
