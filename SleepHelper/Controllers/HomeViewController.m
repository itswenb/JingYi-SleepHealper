//
//  HomeViewController.m
//  SleepHelper
//
//  Created by abc on 2018/11/30.
//

#import "HomeViewController.h"
#import <JKUIKit.h>
#import <JKFoundation.h>
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>
#import "CWCarousel.h"
#import "CGXPickerView.h"
#import "ZRCircleProgressView.h"
#import "HYPlayerTool.h"
#import "HYMusic.h"

#define SelectItemPreference @"SelectItemPreference"
#define SelectedItem [NSUserDefaults.standardUserDefaults integerForKey:SelectItemPreference]

#define kViewTag 666
#define kCount 8

@interface HomeViewController ()<CWCarouselDelegate,CWCarouselDatasource>

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet UIView *timerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *timingButton;
@property (weak, nonatomic) IBOutlet ZRCircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property(nonatomic, assign) CGFloat progress;
@property(nonatomic, strong) NSString *totleTimeStr;
@property(nonatomic, assign) NSInteger totleTime;
@property(nonatomic, assign) CGFloat spendTime;
@property(nonatomic, strong) CGXPickerViewManager *pickerManager;
@property (nonatomic, strong) CWCarousel *carousel;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, assign) NSInteger curruentIndex;
@property(nonatomic, strong) UIImage *backImage;



@property(nonatomic, strong) NSTimer *timer;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginPlayMusic:) name:HYPlayerToolMusicBeginPlay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseMusic:) name:HYPlayerToolMusicPause object:nil];
    
    [self setUpData];
    
    [self remoteControlEventHandler];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.carousel selectItem:SelectedItem];
    [[HYPlayerTool sharePlayerTool] playMusicAtIndex:SelectedItem];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSArray *)items {
    if (!_items) {
        _items = @[@"图1",@"图2",@"图3",@"图4",@"图5",@"图6",@"图7",@"图8"];
    }
    return _items;
}

- (CGXPickerViewManager *)pickerManager {
    if (!_pickerManager) {
        _pickerManager = [[CGXPickerViewManager alloc] init];
    }
    return _pickerManager;
}

- (IBAction)startTiming:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CGXPickerView showDatePickerWithTitle:@"选择倒计时时间" DateType:UIDatePickerModeCountDownTimer DefaultSelValue:@"00:01" MinDateStr:@"00:01" MaxDateStr:@"06:00" IsAutoSelect:NO Manager:self.pickerManager ResultBlock:^(NSString *selectValue) {
            self.timerView.hidden = false;
            self.backButton.hidden = true;
            self.timingButton.hidden = true;
            NSArray *arr = [selectValue componentsSeparatedByString:@":"];
            self.totleTime = (((NSString *)arr.firstObject).intValue * 60 + ((NSString*)arr.lastObject).intValue) * 60;
            self.spendTime = 0;
            NSLog(@"totleTime : %ld  spendTime: %f",(long)self.totleTime,self.spendTime);
            self.progressView.backImage = self.backImage;
            self.progressView.titleColor = self.pickerManager.titleLabelColor;
            self.progressView.progressColor = self.pickerManager.titleLabelColor;
            self.totleTimeStr = [NSString stringWithFormat:@"%@:00",selectValue];
            [self makeTimer];
        }];
    });
}

- (void)makeTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)startTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progressRandom =  0.01/self.totleTime;
        self.progress += progressRandom;
        NSLog(@"正在计时%f",self.progress);
        if (self.progress >= 1) {
            [self.timer invalidate];
            [HYPlayerTool.sharePlayerTool stop];
            self.timer = nil;
        }
        self.spendTime += 0.01;
        [self.progressView setProgress:self.progress title:[NSString stringWithFormat:@"倒计时\n%@",[self timeFormatted:self.totleTime - self.spendTime]]];
    });
}

#pragma mark - 格式转换：NSDate <-- NSString
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours == 0 ) {
        
    }
    return [NSString stringWithFormat:@"%@%02d:%02d",hours == 0 ? @"":[NSString stringWithFormat:@"%02d:",hours], minutes, seconds];
}

- (IBAction)dismiss:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    self.progress = 0.0;
    self.timerView.hidden = true;
    [self selectionViewHidden:false];
}

- (void)initViews {
    _curruentIndex = SelectedItem;
    
    _backImageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [_backImageView addGestureRecognizer:tap];
    _progressView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3];
    _progressView.progressWidth = 10;
    _progressView.completionBlock = ^{
        [self dismiss:self.progressView];
    };

    CWFlowLayout *flowLayout = [[CWFlowLayout alloc] initWithStyle:CWCarouselStyle_H_2];
    // 使用layout创建视图(使用masonry 或者 系统api)
    CWCarousel *carousel = [[CWCarousel alloc] initWithFrame:CGRectZero
                                                    delegate:self
                                                  datasource:self
                                                  flowLayout:flowLayout];
    carousel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectionView addSubview:carousel];
    NSDictionary *dic = @{@"view" : carousel};
    [self.selectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:dic]];
    [self.selectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:dic]];
    carousel.isAuto = NO;
    carousel.autoTimInterval = 2;
    carousel.endless = YES;
    carousel.backgroundColor = [UIColor whiteColor];
    carousel.customPageControl = (UIView<CWCarouselPageControlProtocol> *)[[UIPageControl alloc] init];
    carousel.backgroundColor = UIColor.clearColor;
    
    [carousel registerViewClass:[UICollectionViewCell class] identifier:@"cellId"];
    [carousel freshCarousel];
    self.carousel = carousel;
}

- (void)selectionViewHidden:(BOOL)isHide {
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.selectionView.alpha = isHide? 0 : 1;
        weakSelf.backButton.hidden = !isHide;
        weakSelf.timingButton.hidden = !isHide;
    }];
}

- (NSInteger)numbersForCarousel {
    return kCount;
}


#pragma mark - Delegate
- (UICollectionViewCell *)viewForCarousel:(CWCarousel *)carousel indexPath:(NSIndexPath *)indexPath index:(NSInteger)index{
    UICollectionViewCell *cell = [carousel.carouselView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor cyanColor];
    UIImageView *imgView = [cell.contentView viewWithTag:kViewTag];
    if(!imgView) {
        imgView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imgView.tag = kViewTag;
        imgView.backgroundColor = [UIColor redColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timing)];
        [cell addGestureRecognizer:tap];
        [cell.contentView addSubview:imgView];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 8;
    }
    UIImage *img = [UIImage imageNamed:_items[index]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [imgView setImage:img];
    return cell;
}

- (void)timing {
    [self selectionViewHidden:true];
}

- (void)CWCarousel:(CWCarousel *)carousel didSelectedAtIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backImage = [UIImage imageNamed:self.items[index]];
        UIImage *image = [[self.backImage jk_lightImage] jk_blurredImageWithRadius:40];
        self.backImageView.image = image;
        self.curruentIndex = index;
        UIColor *color = [[image jk_darkImage] jk_colorAtPoint:CGPointMake(image.size.width/2, image.size.height/2)];
        self.pickerManager.leftBtnBGColor = color;
        self.pickerManager.rightBtnBGColor = color;
        self.pickerManager.leftBtnborderColor = color;
        self.pickerManager.rightBtnborderColor = color;
        self.pickerManager.titleLabelColor = color;
        self.pickerManager.pickerTitleColor = color;
        self.pickerManager.lineViewColor = color;
        NSLog(@"pickManager %@", self.pickerManager);
        [NSUserDefaults.standardUserDefaults setInteger:index forKey:SelectItemPreference];
        [[HYPlayerTool sharePlayerTool] playMusicAtIndex:SelectedItem];
    });
}

#pragma mark - 音频处理

-(void)setUpData{
    
    NSMutableArray<HYMusic*> *musicArray = [NSMutableArray array];
    NSMutableArray *urlArray = [NSMutableArray array];
    for (NSString *name in self.items) {
        NSString *path = [[NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Musics.bundle"]] pathForResource:name ofType:@"mp3"];
        [urlArray addObject:path];
    }
    for (int i=0; i<urlArray.count; i++) {
        HYMusic *music = [[HYMusic alloc] initWithTitle:[NSString stringWithFormat:@"助眠曲目第%d首",i+1] musicUrl:urlArray[i]];
        [musicArray addObject:music];
    }
    
    [HYPlayerTool sharePlayerTool].dataSourceArr = musicArray;
    
}

-(void)beginPlayMusic:(NSNotification*)noti{
    self.playButton.selected = true;
    [self.timer jk_resumeTimer];
    NSLog(@"开始播放");
}

-(void)pauseMusic:(NSNotification*)noti{
    self.playButton.selected = false;
    [self.timer jk_pauseTimer];
    NSLog(@"暂停播放");
}


#pragma mark - 音乐控制
// 在需要处理远程控制事件的具体控制器或其它类中实现
- (void)remoteControlEventHandler
{
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTarget:self action:@selector(playAction:)];
    
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    // 为暂停, 上一曲, 下一曲分别添加对应的响应事件
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAction:)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackAction:)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackAction:)];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPauseAction:)];
}


-(void)playAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] play];
//    self.playButton.selected = true;
}
-(void)pauseAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] pause];
//    self.playButton.selected = false;
}
-(void)nextTrackAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] playNext];
    [NSUserDefaults.standardUserDefaults setInteger:HYPlayerTool.sharePlayerTool.currentIndex forKey:SelectItemPreference];
    [self.carousel selectItem:HYPlayerTool.sharePlayerTool.currentIndex];
}
-(void)previousTrackAction:(id)obj{
    [[HYPlayerTool sharePlayerTool] playPre];
    [NSUserDefaults.standardUserDefaults setInteger:HYPlayerTool.sharePlayerTool.currentIndex forKey:SelectItemPreference];
    [self.carousel selectItem:HYPlayerTool.sharePlayerTool.currentIndex];
    
}
-(void)playOrPauseAction:(id)obj{
    if ([[HYPlayerTool sharePlayerTool] isPlaying]) {
        [[HYPlayerTool sharePlayerTool] pause];
    }else{
        [[HYPlayerTool sharePlayerTool] play];
    }
}
- (IBAction)clickPlayButton:(id)sender {
    [self playOrPauseAction:nil];
}

@end
