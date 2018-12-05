//
//  LaunchGuideViewController.m
//  SleepHelper
//
//  Created by abc on 2018/11/29.
//

#import <JKCategories.h>
#import "AppDelegate.h"
#import "LaunchGuideViewController.h"

@interface LaunchGuideViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property(nonatomic, strong) UIButton *startButton;

@end

@implementation LaunchGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initContent];
}
- (void)initContent {
    NSArray *arr = @[@[@"launch1",@"线稿"],@[@"launch2",@"办成稿"],@[@"launch3",@"成品"]];
    int i = 0;
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    for (NSArray *c in arr) {
        UIView *content = [[UIView alloc] init];
        content.frame = CGRectMake(i * width, 0, width, height);
        for (NSString *imageName in c) {
            UIImageView *imageView = [UIImageView jk_imageViewWithImageNamed:imageName];
            if (![imageName containsString:@"launch"]) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            imageView.frame = content.bounds;
            [content addSubview:imageView];
        }
        i++;
        [self.contentScrollView addSubview:content];
        self.contentScrollView.contentSize = CGSizeMake(i * width, height);
    }
    UIImageView *whiteCircle = [UIImageView jk_imageViewWithImageNamed:@"白圈"];
    whiteCircle.contentMode = UIViewContentModeScaleAspectFit;
    whiteCircle.frame = UIScreen.mainScreen.bounds;
    [self.view addSubview:whiteCircle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.jk_height = 44;
    btn.jk_width = 200;
    btn.jk_bottom = height - 100;
    btn.jk_left = (width - 200) /2;
    
    btn.layer.cornerRadius = 22;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1;
    
    btn.titleLabel.font = [UIFont fontWithName:@"American Typewriter" size:20];
    [btn setTitle:@"Start❯" forState:(UIControlStateNormal)];
    btn.alpha = 0;
    
    [btn addTarget:self action:@selector(start:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.startButton = btn;
    [self.view addSubview:btn];
    
    self.contentScrollView.delegate = self;
}

- (void)start:(UIButton *)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    delegate.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    delegate.window.rootViewController = vc;
    [delegate.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:FirstLaunchKey];
}

#pragma 实现协议UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat moved = scrollView.contentOffset.x;
    NSInteger width = UIScreen.mainScreen.bounds.size.width;
    CGFloat alpha = (moved - width) / width;
    self.startButton.alpha = alpha;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
