//
//  FPADataFetcher.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPAMainViewController;

@interface FPADataFetcher : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic, weak) FPAMainViewController * mvc; // pointer to main program so we can tell it to update when data is fetched

- (id)initWithViewController:(FPAMainViewController *)mvc;
- (void)fetchNewReason;

@end
