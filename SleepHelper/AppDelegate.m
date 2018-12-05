//
//  AppDelegate.m
//  SleepHelper
//
//  Created by abc on 2018/11/29.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import "TalkingData.h"
#import <Bugly/Bugly.h>

// UMengAnalytics  5a9f528bf43e48230b0000df
#define kUMengAnalyticsAppKey @"5959b105f29d9835ac000742"
#define kUMengAnalyticsChannel @"sleepHealper"
// TalkingData
#define kTalkingDataAppKey @"DD999ECD9B5D4214A5BC846A6ECD28BA"
#define kTalkingDataChannelId @"sleepHealper"
// bugly
#define kBuglyAppID @"dfb725070c"
#define kBuglyAppkey @"74e93240-af94-4335-b228-52cf68705d7d"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self showViewController];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [Bugly startWithAppId:kBuglyAppID];
    [TalkingData sessionStarted:kTalkingDataAppKey withChannelId:kTalkingDataChannelId];
    [UMConfigure initWithAppkey:kUMengAnalyticsAppKey channel:kUMengAnalyticsChannel];
    
    return YES;
}

- (void)showViewController {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:IsFirstLaunch ? @"LaunchGuideViewController" : @"HomeViewController"];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
