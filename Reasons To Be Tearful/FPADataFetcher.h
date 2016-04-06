//
//  FPADataFetcher.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPAMainViewController;
@class FPAAudioPlayer;

@interface FPADataFetcher : NSObject<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic, weak) FPAMainViewController * mvc; // pointer to main program so we can tell it to update when data is fetched
@property (nonatomic) BOOL fetchingReasons; // sign of whether we are fetching sound or reason data (so we know where to send it after)
@property (nonatomic) NSUInteger fetcherNumber; // matches players playerNumber
@property (nonatomic, weak) FPAAudioPlayer * audioPlayer; // directly interact with audio player
@property (nonatomic) BOOL busy; // sign that this dataFetcher is currently in use and does not need more jobs
@property (nonatomic) NSUInteger soundID; // number of sound we're finding

- (id)initWithViewController:(FPAMainViewController *)mvc fetcherNumber:(NSUInteger)fetcherNumber;
- (void)fetchNewReason;
- (void)fetchNewSounds:(NSUInteger)soundID;

-(BOOL)loadDataFromFile;
-(void)saveDataToFile:(NSData *)data;
-(NSString *)getFilePath;

@end
