//
//  ViewController.m
//  Ping++支付
//
//  Created by lizhen on 16/1/29.
//  Copyright © 2016年 lizhen. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import <Pingpp.h>
#import <AFNetworking.h>
#define KBtn_width        200      //支付控件的宽度
#define KBtn_height       40       //支付控件的高度
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2  //控件距离屏幕的宽度
#define KYOffSet          20       //控件间的距离

#define kWaiting          @"正在获取支付凭据,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"

#define kPlaceHolder      @"支付金额"
#define kMaxAmount        9999999   //最大支付金额

#define kUrlScheme      @"demoapp001" // 这个是你定义的 URL Scheme，支付宝、微信支付和测试模式需要。
#define kUrl            @"http://218.244.151.190/demo/charge" // 你的服务端创建并返回 charge 的 URL 地址，此地址仅供测试用。

@interface ViewController ()

@end

@implementation ViewController
@synthesize channel;
@synthesize mTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    CGRect viewRect = self.view.frame;
    //创建一个滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:viewRect];
    [scrollView setScrollEnabled:YES];
    [self.view addSubview:scrollView];
    
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    UIImage *headerImg = [UIImage imageNamed:@"home.jpg"];
    CGFloat imgViewWith = windowRect.size.width * 0.9;
    CGFloat imgViewHeight = headerImg.size.height * imgViewWith / headerImg.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:headerImg];
    //设置图片的自然分辨率
    [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    CGFloat imgx = windowRect.size.width / 2 - imgViewWith / 2;
    [imgView setFrame:CGRectMake(imgx, KYOffSet, imgViewWith, imgViewHeight)];
    [scrollView addSubview:imgView];
    //输入支付金额
    mTextField = [[UITextField alloc]initWithFrame:CGRectMake(imgx, KYOffSet + imgViewHeight + 40, imgViewWith - 40, 40)];
    mTextField.borderStyle = UITextBorderStyleRoundedRect;
    mTextField.backgroundColor = [UIColor whiteColor];
    mTextField.placeholder = kPlaceHolder;
    mTextField.keyboardType = UIKeyboardTypeNumberPad;
    mTextField.returnKeyType = UIReturnKeyDone;
    mTextField.delegate = self;
    [mTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [scrollView addSubview:mTextField];
    //点击OK按钮
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"OK" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(imgx+imgViewWith - 35, KYOffSet + imgViewHeight + 40, 40, 40)];
    [doneButton.layer setMasksToBounds:YES];
    [doneButton.layer setCornerRadius:8.0];
    [doneButton.layer setBorderWidth:1.0];
    [doneButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [scrollView addSubview:doneButton];
    //微信支付
    UIButton* wxButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [wxButton setTitle:@"微信" forState:UIControlStateNormal];
    [wxButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [wxButton setFrame:CGRectMake(imgx, KYOffSet + imgViewHeight + 90, imgViewWith, KBtn_height)];
    [wxButton.layer setMasksToBounds:YES];
    [wxButton.layer setCornerRadius:8.0];
    [wxButton.layer setBorderWidth:1.0];
    [wxButton.layer setBorderColor:[UIColor grayColor].CGColor];
    wxButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [wxButton setTag:1];
    [scrollView addSubview:wxButton];
    //支付宝支付
    UIButton* alipayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [alipayButton setTitle:@"支付宝" forState:UIControlStateNormal];
    [alipayButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [alipayButton setFrame:CGRectMake(imgx, KYOffSet + imgViewHeight + 140, imgViewWith, KBtn_height)];
    [alipayButton.layer setMasksToBounds:YES];
    [alipayButton.layer setCornerRadius:8.0];
    [alipayButton.layer setBorderWidth:1.0];
    [alipayButton.layer setBorderColor:[UIColor grayColor].CGColor];
    alipayButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [alipayButton setTag:2];
    [scrollView addSubview:alipayButton];
    //银联支付
    UIButton* upmpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [upmpButton setTitle:@"银联" forState:UIControlStateNormal];
    [upmpButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [upmpButton setFrame:CGRectMake(imgx, KYOffSet + imgViewHeight + 190, imgViewWith, KBtn_height)];
    [upmpButton.layer setMasksToBounds:YES];
    [upmpButton.layer setCornerRadius:8.0];
    [upmpButton.layer setBorderWidth:1.0];
    [upmpButton.layer setBorderColor:[UIColor grayColor].CGColor];
    upmpButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [upmpButton setTag:3];
    [scrollView addSubview:upmpButton];
    //百度钱包支付
    UIButton* bfbButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bfbButton setTitle:@"百度钱包" forState:UIControlStateNormal];
    [bfbButton addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [bfbButton setFrame:CGRectMake(imgx, KYOffSet+imgViewHeight + 240, imgViewWith, KBtn_height)];
    [bfbButton.layer setMasksToBounds:YES];
    [bfbButton.layer setCornerRadius:8.0];
    [bfbButton.layer setBorderWidth:1.0];
    [bfbButton.layer setBorderColor:[UIColor grayColor].CGColor];
    bfbButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [bfbButton setTag:4];
    [scrollView addSubview:bfbButton];
    
    [scrollView setContentSize:CGSizeMake(viewRect.size.width, KYOffSet+imgViewHeight + 260 + KBtn_height)];
}

#pragma mark - 显示等待
- (void)showAlertWait
{
    alertController = [UIAlertController alertControllerWithTitle:kWaiting message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
//    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
//    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(self.view.frame.size.width / 2.0f - 15, self.view.frame.size.height / 2.0f + 10);
//    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [self.view addSubview:aiv];
//    [alertController addSubview:aiv];
}
#pragma mark - 显示信息
- (void)showAlertMessage:(NSString*)msg
{
    alertController = [UIAlertController alertControllerWithTitle:kNote message:nil preferredStyle:1];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kNote style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
//    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
//    [mAlert show];
}
#pragma mark - 隐藏AlertView
- (void)hideAlert
{
    [alertController dismissViewControllerAnimated:YES completion:nil];
//    if (mAlert != nil)
//    {
//        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
//        mAlert = nil;
//    }
}
#pragma mark - 支付的网络请求
- (void)normalPayAction:(id)sender
{
    NSInteger tag = ((UIButton*)sender).tag;
    if (tag == 1) {
        self.channel = @"wx";
        [self normalPayAction:nil];
    } else if (tag == 2) {
        self.channel = @"alipay";
    } else if (tag == 3) {
        self.channel = @"upacp";
    } else if (tag == 4) {
        self.channel = @"bfb";
    } else {
        return;
    }
    
    [mTextField resignFirstResponder];
    
    long long amount = [[self.mTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""] longLongValue];
    if (amount == 0) {
        return;
    }
    NSString *amountStr = [NSString stringWithFormat:@"%lld", amount];
    NSURL* url = [NSURL URLWithString:kUrl];
    
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* dict = @{
                           @"channel" : self.channel,
                           @"amount"  : amountStr
                           };
    
    
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];

    ViewController * __weak weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self showAlertWait];
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            [weakSelf hideAlert];
            if (httpResponse.statusCode != 200) {
                NSLog(@"statusCode=%ld error = %@", (long)httpResponse.statusCode, connectionError);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            if (connectionError != nil) {
                NSLog(@"error = %@", connectionError);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            NSString* charge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"charge = %@", charge);
            //客户端从服务器端拿到charge对象后，调用下面的方法
            [Pingpp createPayment:charge viewController:weakSelf appURLScheme:kUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                NSLog(@"completion block: %@", result);
                if (error == nil) {
                    NSLog(@"支付成功");
                } else {
                    NSLog(@"PingppError: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
                    NSLog(@"支付失败");
                }
                [weakSelf showAlertMessage:result];
            }];
        });
    }];
}
#pragma mark - 点击OK按钮退出键盘
- (void)okButtonAction:(id)sender
{
    [mTextField resignFirstResponder];
}
#pragma mark - 实时的改变支付金额
- (void) textFieldDidChange:(UITextField *) textField
{
    NSString *text = textField.text;
    NSUInteger index = [text rangeOfString:@"."].location;
    if (index != NSNotFound) {
        double amount = [[text stringByReplacingOccurrencesOfString:@"." withString:@""] doubleValue];
        text = [NSString stringWithFormat:@"%.02f", MIN(amount, kMaxAmount)/100];
    } else {
        double amount = [text doubleValue];
        text = [NSString stringWithFormat:@"%.02f", MIN(amount, kMaxAmount)/100];
    }
    textField.text = text;
}

//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    CGRect frame = textField.frame;
//    if (self.view.frame.size.height > 480) {
//        return;
//    }
//    int offset = frame.origin.y + 45 - (self.view.frame.size.height - 216.0);
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    if(offset > 0)
//        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
//    [UIView commitAnimations];
//}
//
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
