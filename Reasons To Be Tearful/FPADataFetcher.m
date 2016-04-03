//
//  FPADataFetcher.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import "FPADataFetcher.h"
#import "FPAMainViewController.h"

@implementation FPADataFetcher

-(id)initWithViewController:(FPAMainViewController *)viewController {
    FPADataFetcher *me = [super init];
    if (me) {
        me.mvc=viewController;
    }
    me.fetchingReasons=true; // overwrite this for music ones
    return me;
}

# pragma mark App specific stuff

- (void)fetchNewReason {
        NSLog(@"fetch new reason");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://reasonstobetearful.com/api/"]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)fetchNewSounds {
    NSLog(@"fetch new sounds");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://reasonstobetearful.com/sounds/"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tonycuffe.com/mp3/tail%20toddle.mp3"]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    if (self.fetchingReasons) {
        NSLog(@"found a reason");
        [self.mvc gotNewReason:_responseData]; // send data back to main app
    } else {
        // its a sound
        NSLog(@"found a sound");
        [self.mvc gotNewSounds:_responseData];
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _responseData=nil; // just in case
    NSLog(@"Error was %@",error);
    if (self.fetchingReasons) {
        NSLog(@"couldn't find a reason");
        [self.mvc couldntGetReason]; // send data back to main app
    } else {
        // its a sound
        NSLog(@"couldn't find a sound");
        [self.mvc couldntGetSounds];
    }
}

@end
