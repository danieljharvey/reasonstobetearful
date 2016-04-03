//
//  FPAMainViewController.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/03/2016.
//  Copyright (c) 2016 Daniel Harvey. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FPADataFetcher;

@interface FPAMainViewController : UIViewController

@property (nonatomic, strong) FPADataFetcher * dataFetcher;
@property (nonatomic, strong) IBOutlet UILabel *blurb;
@property (nonatomic,strong) NSMutableString * reasonString;

-(void)getNewReason;
-(void)gotNewReason:(NSData *)data;
-(void)couldntGetReason;
-(void)updateLabelView;



@end
