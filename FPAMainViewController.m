//
//  FPAMainViewController.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/03/2016.
//  Copyright (c) 2016 Daniel Harvey. All rights reserved.
//

#import "FPAMainViewController.h"
#import "FPADataFetcher.h"

@implementation FPAMainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.reasonString=[[NSMutableString alloc] init];
    FPADataFetcher *dataFetcher=[[FPADataFetcher alloc] initWithViewController:self];
    self.dataFetcher=dataFetcher;
    [self getNewReason];
}

-(void)getNewReason {
    [self.dataFetcher fetchNewReason];
}

-(void)gotNewReason:(NSData *)data {
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    NSLog(@"data is %@",json);
    
    
    if ([json objectForKey:@"blurb"]!=nil) {
        [self.reasonString setString:[json objectForKey:@"blurb"]];
    } else {
        [self.reasonString setString:@"Not found"];
    }

    [self updateLabelView];
}

-(void)couldntGetReason {
    // put up one of the defaults 
}

-(void)updateLabelView {
    self.blurb.text=self.reasonString;
}

@end
