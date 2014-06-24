//
//  SGParticipateOperation.m
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGParticipateOperation.h"
#import "AFNetworking/AFNetworking.h"
#import "SGSixpackExperiment.h"
#import "SGNetworkQueue.h"


@implementation SGParticipateOperation

- (void)run {
    if (!self.experiment.chosenAlternative) {
        SGSixpackDebugLog(@"Sixpack Error: Attempting to participate before choosing an alternative");
        return;
    }
    
    NSMutableDictionary *parameters = @{@"client_id" : self.experiment.clientID,
                                        @"experiment" : self.experiment.name,
                                        @"alternatives" : self.experiment.alternatives }.mutableCopy;
    
    if (self.experiment.forcedAlternative) {
        parameters[@"force"] = self.experiment.forcedAlternative;
    }
    
    [self.experiment.operationManager GET:[SGSixpackOperation urlForBase:[self.experiment.url stringByAppendingString:@"participate"]
                                                              parameters:parameters]
                               parameters:nil
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      SGSixpackDebugLog(@"Sixpack Participate Response: %@", responseObject);
                                      if (responseObject[@"alternative"]) {
                                          self.experiment.chosenAlternative = responseObject[@"alternative"][@"name"];
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      SGSixpackDebugLog(@"Sixpack Participate Error: %@", error);
                                      if (self.experiment.operationManager.reachabilityManager.reachable) {
                                          //give up
                                          if (self.experiment.forcedAlternative) {
                                              self.experiment.chosenAlternative = self.experiment.forcedAlternative;
                                          } else {
                                              self.experiment.chosenAlternative = self.experiment.alternatives.firstObject;
                                          }
                                      } else {
                                          //add ourselves back to the queue.  Try again later.
                                          SGSixpackDebugLog(@"Network appears to be offline. Queuing Participate for later");
                                          [self.networkQueue addParticipateOperationFor:self.experiment];
                                      }
                                  }];
}

@end
