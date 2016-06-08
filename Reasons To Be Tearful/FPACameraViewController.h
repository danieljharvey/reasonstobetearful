//
//  FPACameraViewController.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 19/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FPAMainViewController;
#import <AVFoundation/AVFoundation.h>
@class AVCaptureSession;

@interface FPACameraViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *blurb; // label link

@property (nonatomic, strong) AVCaptureSession *session;

@end
