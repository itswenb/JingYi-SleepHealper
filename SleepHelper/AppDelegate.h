//
//  AppDelegate.h
//  SleepHelper
//
//  Created by abc on 2018/11/29.
//

#import <UIKit/UIKit.h>

#define FirstLaunchKey [NSString stringWithFormat:@"%@_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]
#define IsFirstLaunch ![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchKey]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

