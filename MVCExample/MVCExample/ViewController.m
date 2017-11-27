//
//  ViewController.m
//  MVCExample
//
//  Created by 常立山 on 2017/11/25.
//  Copyright © 2017年 常立山. All rights reserved.
//

#import "ViewController.h"
#import <CBAiDirectSDK/CBAiDirectSDK.h>
#import <HMSegmentedControl.h>
#import <Masonry.h>
#import "CBGLLayer.h"
//设备屏幕高度
#define KNB_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

//设备屏幕宽度
#define KNB_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

//#pragma mark - 16进制色值转RGB
#define UIColorFromRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 弱引用
#define MJWeakSelf __weak typeof(self) weakSelf = self;

@interface ViewController ()<CBAiDirectSDKDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isconnect;
@property(nonatomic, strong)HMSegmentedControl * segmentedControl;
//顶部滑动条的滑动区域
@property(nonatomic, strong)UIScrollView *scrollView;
//探测的显示区
@property(nonatomic, strong)UIImageView *imageView;
//弹框
@property(nonatomic, strong)UIView *alertView;
//断线连接图片
@property(nonatomic, strong)UIImageView *connectImage;
//断线连接文字
@property(nonatomic, strong)UILabel *connectLabel;
//断线连接按钮
@property(nonatomic, strong)UIButton *connectBtn;
//拍摄按钮
@property(nonatomic, strong)UIButton *takePhotoBtn;
//底部的提醒文字
@property(nonatomic, strong)UILabel *warningLabel;

@property (nonatomic, strong) CBGLLayer *layer;
//存储三张原图的数组
@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"检测皮肤";
    
    [self setupUI];

    [CBAiDirectSDK prepareWithDelegate:self];
    
    [self addObserver:self forKeyPath:@"isconnect" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)applicationWillEnterForeground {
    [CBAiDirectSDK connect];
}

- (void)viewWillAppear:(BOOL)animated {
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [super viewWillAppear:animated];
    [CBAiDirectSDK connect];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [CBAiDirectSDK stopPreview];
    [CBAiDirectSDK switchLight:CBAiDirectLightClose];
}

- (void)dealloc {
    //移除后台监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 设置 UI
- (void)setupUI {
    
    //创建顶部的灰线
    UIView *topLine = [[UIView alloc] init];
    topLine.frame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, 5);
    topLine.backgroundColor = UIColorFromRGBHex(0xe6e6e6);
    [self.view addSubview:topLine];
    
    //创建顶部的滑动栏
    self.segmentedControl = [[HMSegmentedControl alloc ] initWithSectionTitles:@[@"底层",@"表层",@"UV"]];
    self.segmentedControl.frame = CGRectMake(0,5,KNB_SCREEN_WIDTH,50);
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : UIColorFromRGBHex(0xef508d),NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    self.segmentedControl.selectionIndicatorColor = UIColorFromRGBHex(0xef508d);
    self.segmentedControl.selectionIndicatorHeight = 2.0;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [self.segmentedControl addTarget:self action:@selector(LightTypeByClick:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    MJWeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(KNB_SCREEN_WIDTH * index, 0, KNB_SCREEN_WIDTH, 200) animated:YES];
    }];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 57, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT - 57)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(KNB_SCREEN_WIDTH * 3, 200);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(KNB_SCREEN_WIDTH, 0, KNB_SCREEN_WIDTH, 200) animated:NO];
    [self.view addSubview:self.scrollView];
    
    //创建探测显示区
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KNB_SCREEN_WIDTH - 110, KNB_SCREEN_WIDTH - 110)];
    self.imageView.backgroundColor = UIColorFromRGBHex(0xf5f5f5);
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = (KNB_SCREEN_WIDTH - 110)/2;
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.segmentedControl.mas_bottom).mas_offset(42);
        make.left.equalTo(weakSelf.view).mas_offset(55);
        make.right.equalTo(weakSelf.view).mas_offset(-55);
        make.height.equalTo(weakSelf.imageView.mas_width).multipliedBy(1.0f);
        make.centerX.mas_equalTo(weakSelf.view);
    }];
    
    //创建断线标志及文字
    self.connectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smart_icon_Not_connected"]];
    [self.imageView addSubview:_connectImage];
    
    [_connectImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.imageView).mas_offset(-20);
        make.centerX.mas_equalTo(weakSelf.imageView);
    }];
    
    self.connectLabel = [[UILabel alloc] init];
    _connectLabel.text = @"未连接到肌肤检测仪 请点击屏幕";
    _connectLabel.textColor = UIColorFromRGBHex(0x999999);
    _connectLabel.textAlignment = NSTextAlignmentCenter;
    [_connectLabel setFont:[UIFont systemFontOfSize:14.0]];
    _connectLabel.numberOfLines = 0;
    [self.imageView addSubview:_connectLabel];
    
    [_connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.connectImage.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(weakSelf.imageView);
        make.width.mas_equalTo(140);
    }];
    
    //创建断线连接按钮
    self.connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectBtn.frame = CGRectMake(0, 0, 265, 265);
    [_connectBtn addTarget:self action:@selector(connectInternetByClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectBtn];
    
    [_connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.segmentedControl.mas_bottom).mas_offset(42);
        make.left.equalTo(weakSelf.view).mas_offset(55);
        make.right.equalTo(weakSelf.view).mas_offset(-55);
        make.height.equalTo(weakSelf.connectBtn.mas_width).multipliedBy(1.0f);
        make.centerX.mas_equalTo(weakSelf.view);
    }];
    
    //创建底部的提醒文字
    self.warningLabel = [[UILabel alloc] init];
    _warningLabel.text = @"请将检测口轻贴您的肌肤";
    _warningLabel.textColor = UIColorFromRGBHex(0x666666);
    [_warningLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.view addSubview:_warningLabel];
    
    [_warningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view);
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(30);
    }];
    
    //创建底部的拍摄按钮
    self.takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _takePhotoBtn.frame = CGRectMake(0, 0, 150, 40);
    _takePhotoBtn.layer.masksToBounds = YES;
    _takePhotoBtn.layer.cornerRadius = 20;
    [_takePhotoBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    [_takePhotoBtn setTitleColor:UIColorFromRGBHex(0x666666) forState:UIControlStateNormal];
    [_takePhotoBtn setBackgroundColor:UIColorFromRGBHex(0xf5f5f5)];
    [_takePhotoBtn addTarget:self action:@selector(take) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_takePhotoBtn];
    
    _takePhotoBtn.enabled = NO;
    self.isconnect = NO;
    
    
    [_takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(weakSelf.view);
        make.bottom.mas_equalTo(weakSelf.view).mas_offset(-55);
    }];
}

#pragma mark - 按钮点击事件
/**
 点击连接网络
 */
- (void)connectInternetByClick {
    NSLog(@"Selected connect Internet");
    //跳转 wifi
#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
    NSString * urlString = @"App-Prefs:root=WIFI";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        if (iOS10) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }
    }
}

/**
 拍照
 */
- (void)take {
    
    [_takePhotoBtn setTitle:@"拍摄中..." forState:UIControlStateNormal];
    _takePhotoBtn.enabled = NO;
    [_segmentedControl setEnabled:NO];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [CBAiDirectSDK takePhotoForCheckType:CBCheckCleaningType|CBCheckPigmentType|CBCheckSensitiveType|CBCheckMoistType|CBCheckComplexionType|CBCheckSunscreenType|CBCheckFirmnessType];
}

/**
 灯光类型的选择
 
 @param button  顶部的三个灯光选择按钮
 */
- (void)LightTypeByClick:(HMSegmentedControl *)segmentedControl {
    
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    CBAiDirectLight light;
    if (selectedIndex == 0)
    {
        //polarized 偏振光
        light = CBAiDirectPolarizedLight;
    }else if (selectedIndex == 1)
    {
        //polarized 偏振光
        light = CBAiDirectWhiteLight;
        
    }else {
        //uv 紫外线光
        light = CBAiDirectUVLight;
    }
    //选择灯光
    [CBAiDirectSDK switchLight:light];
}


#pragma mark - CBAiDirectSDK Delegate Methon
- (void)aiDirectDidConnect {
    self.isconnect = YES;
}

- (void)aiDirectDidDisconnect {
    self.isconnect = NO;
}

/**
 开始预览
 
 @param pixelBuffer 预览图像
 */
- (void)aiDirectCaptureOutputSampleBufferPreview:(CVPixelBufferRef)pixelBuffer
{
    self.layer.pixelBuffer = pixelBuffer;
}

/**
 拍照成功
 
 @param imageDict 拍摄的图片
 */
- (void)aiDirectDidCaptureWithImage:(NSDictionary *)imageDict
{
    NSMutableArray *imageArray = @[].mutableCopy;
    if (imageDict) {
        UIImage *uvImage = imageDict[UVLightImageKey];
        UIImage *plImage = imageDict[PolarizedLightImageKey];
        UIImage *whiteImage = imageDict[WhiteLightImageKey];
        NSLog(@"uvImage:%@ \nplImage:%@ \nwhiteImage:%@",uvImage, plImage, whiteImage);
        if (uvImage) {
            [imageArray addObject:[NSDictionary dictionaryWithObject:uvImage forKey:@"UV"]];
        }
        if (plImage) {
            [imageArray addObject:[NSDictionary dictionaryWithObject:plImage forKey:@"底层"]];
        }
        if (whiteImage) {
            [imageArray addObject:[NSDictionary dictionaryWithObject:whiteImage forKey:@"表层"]];
        }
    }
    self.imageArray = imageArray;
    _warningLabel.text = @"拍摄成功,请移开设备";
    [_takePhotoBtn setTitle:@"分析中..." forState:UIControlStateNormal];
}

/**
 分析完成
 
 @param analysisResult 分析结果
 */
- (void)aiDirectCaptureFinishedWithResult:(NSArray<CBAnalyzeObject *> *)analysisResult
{
    MJWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    BOOL newConnect = [change objectForKey:@"NSKeyValueChangeNewKey"];
    BOOL oldConnect = [change objectForKey:@"NSKeyValueChangeOldKey"];
    if (newConnect != oldConnect) {
        if (newConnect) {
            NSLog(@"%s",__func__);
            NSLog(@"连接成功");
            [self.view layoutIfNeeded];
            [self.imageView.layer addSublayer:self.layer];
            self.connectBtn.hidden = YES;
            self.connectImage.hidden = YES;
            self.connectLabel.hidden = YES;
            self.takePhotoBtn.enabled = YES;
            [self.takePhotoBtn setBackgroundColor:UIColorFromRGBHex(0xef508d)];
            [_takePhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //选择默认灯光
            [CBAiDirectSDK switchLight:CBAiDirectPolarizedLight];
            //开始预览
            [CBAiDirectSDK startPreview];
            
        } else {
            NSLog(@"%s",__func__);
            NSLog(@"连接失败");
            [self.layer removeFromSuperlayer];
            self.connectBtn.hidden = NO;
            self.connectImage.hidden = NO;
            self.connectLabel.hidden = NO;
            self.takePhotoBtn.enabled = NO;
            [self.takePhotoBtn setBackgroundColor:UIColorFromRGBHex(0xf5f5f5)];
            [_takePhotoBtn setTitleColor:UIColorFromRGBHex(0x666666) forState:UIControlStateNormal];
            self.isconnect = NO;
            self.segmentedControl.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.warningLabel.text = @"请将检测口轻贴您的肌肤";
            [self.takePhotoBtn setTitle:@"拍摄" forState:UIControlStateNormal];
        }
    }
}

- (CBGLLayer *)layer {
    if (!_layer) {
        _layer  = [[CBGLLayer alloc]initWithFrame:self.imageView.bounds];
    }
    return _layer;
}
@end
