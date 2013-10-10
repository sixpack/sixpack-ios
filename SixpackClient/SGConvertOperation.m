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
    NSDictionary *parameters = @{@"client_id" : self.experiment.clientID,
                                        @"experiment" : self.experiment.name};
    
    [self.experiment.operationManager GET:@"/convert"
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSLog(@"Sixpack Conversion Response: %@", responseObject);
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      NSLog(@"Sixpack Conversion Error: %@", error);
                                      if (self.experiment.operationManager.reachabilityManager.reachable) {
                                          //give up
                                      } else {
                                          //add ourselves back to the queue.  Try again later.
                                          NSLog(@"Network appears to be offline. Queuing Conversion for later");
                                          [self.networkQueue addConversionOperationFor:self.experiment];
                                      }
                                  }];
}

@end
