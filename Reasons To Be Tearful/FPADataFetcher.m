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
    return me;
}

# pragma mark App specific stuff

- (void)fetchNewReason {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://reasonstobetearful.com/api/"]];
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
    FPAMainViewController * owner = self.mvc;
    [owner gotNewReason:_responseData]; // send data back to main app
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _responseData=nil; // just in case
    NSLog(@"Error was %@",error);
}

@end
