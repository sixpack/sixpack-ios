//
//  SGSixpackClient.m
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGSixpackClient.h"

@interface SGSixpackClient ()
@property (strong) NSString *url;
@property (assign) NSTimeInterval timeout;
@end

@implementation SGSixpackClient

- (void)connectToHost:(NSString *)url
               timout:(NSTimeInterval)seconds {
    self.url = url;
    self.timeout = seconds;
}

- (void)setupExperiment:(NSString *)experiment alternatives:(NSArray *)alternatives {
    
}

- (void)participateIn:(NSString *)experiment onChoose:(void(^)(NSString *chosenAlternative))block {
    
}

- (void)convert:(NSString *)experiment {
    
}

#pragma mark Helper Methods



@end
