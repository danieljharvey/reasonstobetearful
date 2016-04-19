//
//  FPADataFetcher.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import "FPADataFetcher.h"
#import "FPAMainViewController.h"
#import "FPAAudioPlayer.h"

@implementation FPADataFetcher

-(id)initWithViewController:(FPAMainViewController *)viewController fetcherNumber:(NSUInteger)fetcherNumber {
    FPADataFetcher *me = [super init];
    if (me) {
        me.mvc=viewController;
        me.fetcherNumber=fetcherNumber;
        me.busy=false;
    }
    me.fetchingReasons=true; // overwrite this for music ones
    return me;
}

# pragma mark App specific stuff

- (void)fetchNewReason {
//    NSLog(@"fetcher number %d fetching new reason",self.fetcherNumber);
    self.busy=true;
    NSString * urlString;
    if (self.mvc.deviceToken!=nil && self.mvc.deviceToken.length>0) {
        urlString=[[NSString alloc] initWithFormat:@"http://reasonstobetearful.com/api/?pushToken=%@",self.mvc.deviceToken];
    } else {
        urlString=@"http://reasonstobetearful.com/api/";
    }
  //  NSLog(urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)fetchNewSounds:(NSUInteger)soundID {
    self.soundID=soundID;
    if ([self loadDataFromFile]) {
    //    NSLog(@"fetcher number %d loaded from cache",self.fetcherNumber);
        [self.audioPlayer streamAudio:_responseData];
    } else {
      //  NSLog(@"fetcher number %d fetching new sounds",self.fetcherNumber);
        self.busy=true;
        NSString *urlString = [NSString stringWithFormat:@"http://reasonstobetearful.com/sounds/?soundID=%d", soundID];
//        NSLog(@"urlString is %@",urlString);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append new data on end
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // done!
    self.busy=false;
    if (self.fetchingReasons) {
  //      NSLog(@"Fetcher %d found a reason",self.fetcherNumber);
        [self.mvc gotNewReason:_responseData]; // send data back to main app
    } else {
        // its a sound
    //    NSLog(@"Fetcher %d found a sound!",self.fetcherNumber);
        NSData *immutableData = [NSData dataWithData:_responseData];
        [self saveDataToFile:immutableData];

        [self.audioPlayer streamAudio:_responseData];
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _responseData=nil; // just in case
    //NSLog(@"Error was %@",error);
    if (self.fetchingReasons) {
      //  NSLog(@"Fetcher %d couldn't find a reason",self.fetcherNumber);
        [self.mvc couldntGetReason]; // send data back to main app
    } else {
        // its a sound
        //NSLog(@"Fetcher %d couldn't find a sound",self.fetcherNumber);
        [self.mvc couldntGetSounds];
    }
    self.busy=false; // fetcher is free
}

// save downloaded data as filename
- (void)saveDataToFile:(NSData *)data {
    NSString *filePath=[self getFilePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // if file is not exist, create it.
        [data writeToFile:filePath
               atomically:YES];
    }
    
    if ([[NSFileManager defaultManager] isWritableFileAtPath:filePath]) {
        NSLog(@"Writable");
    }else {
        NSLog(@"Not Writable");
    }
}

-(NSString *)getFilePath {
    NSString * filename=[NSString stringWithFormat:@"%d.mp3",self.soundID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
//    NSLog(@"filePath %@", filePath);
    return filePath;
}


// load data from file if it exists
- (BOOL)loadDataFromFile {
    NSString *filePath=[self getFilePath];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    if (data) {
        _responseData=[NSMutableData dataWithData:data];
        return true;
    } else {
        return false;
    }
}

@end
