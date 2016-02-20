//
//  ViewController.h
//  Ping++支付
//
//  Created by lizhen on 16/1/29.
//  Copyright © 2016年 lizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate>{
//    UIAlertView *mAlert;
    UIAlertController *alertController;
    UITextField *mTextField;
}

@property(nonatomic, strong)NSString *channel;
@property(nonatomic, strong)UITextField *mTextField;

- (void)showAlertWait;
- (void)hideAlert;
- (void)showAlertMessage:(NSString *)message;
@end

