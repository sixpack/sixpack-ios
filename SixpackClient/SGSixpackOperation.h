//
//  SGSixpackOperation.h
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGSixpackExperiment, SGNetworkQueue;

@interface SGSixpackOperation : NSObject

@property (weak) SGSixpackExperiment *experiment;
@property (weak) SGNetworkQueue *networkQueue;

- (void)run;
+ (NSString *)urlForBase:(NSString *)base parameters:(NSDictionary *)parameters;

@end
