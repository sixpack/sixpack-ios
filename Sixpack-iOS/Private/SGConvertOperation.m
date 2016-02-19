//
//  SGConvertOperation.m
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGConvertOperation.h"
#import "AFNetworking/AFNetworking.h"
#import "SGSixpackExperiment.h"
#import "SGNetworkQueue.h"

@implementation SGConvertOperation

- (void)run {
    if (!self.experiment.chosenAlternative) {
        SGSixpackDebugLog(@"Sixpack Error: Attempting to convert before choosing an alternative");
        return;
    }
    
    NSDictionary *parameters = @{@"client_id" : self.experiment.clientID,
                                        @"experiment" : self.experiment.name};
    
    [self.experiment.sessionManager GET:[SGSixpackOperation urlForBase:[self.experiment.url stringByAppendingString:@"convert"]
                                                              parameters:parameters]
                               parameters:nil
                               progress:nil
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      SGSixpackDebugLog(@"Sixpack Conversion Response: %@", responseObject);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      SGSixpackDebugLog(@"Sixpack Conversion Error: %@", error);
                                      if (self.experiment.sessionManager.reachabilityManager.reachable) {
                                          //give up
                                      } else {
                                          //add ourselves back to the queue.  Try again later.
                                          SGSixpackDebugLog(@"Network appears to be offline. Queuing Conversion for later");
                                          [self.networkQueue addConversionOperationFor:self.experiment];
                                      }
                                  }];
}

@end
