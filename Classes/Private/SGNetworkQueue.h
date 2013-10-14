//
//  SGNetworkQueue.h
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGSixpackExperiment;

@interface SGNetworkQueue : NSObject

- (void)startQueues;
- (void)stopQueues;

- (void)addPrefetchOperationFor:(SGSixpackExperiment *)experiment;
- (void)addParticipateOperationFor:(SGSixpackExperiment *)experiment;
- (void)addConversionOperationFor:(SGSixpackExperiment *)experiment;

@end
