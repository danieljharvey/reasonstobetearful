//
//  FPAAppDelegate.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/03/2016.
//  Copyright (c) 2016 Daniel Harvey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FPAMainViewController;

@interface FPAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) FPAMainViewController *mvc;

@end
