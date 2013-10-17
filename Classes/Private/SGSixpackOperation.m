//
//  SGSixPackOperations.m
//  SixpackClient
//
//  Created by James Van-As on 11/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import "SGSixpackOperation.h"

@implementation SGSixpackOperation

+ (NSString *)urlForBase:(NSString *)base parameters:(NSDictionary *)parameters {
    //we have to generate our own URL because the sixpack server doesn't like array escape characters
    NSString *paramStr = base.copy;
    paramStr = [base stringByAppendingString:@"?"];
    
    for (NSString *key in parameters) {
        id obj = parameters[key];
        if ([obj isKindOfClass:NSString.class]) {
            paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
        } else if ([obj isKindOfClass:NSArray.class]) {
            for (NSString *item in obj) {
                paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, item]];
            }
        }
    }
    //strip final &
    return [paramStr substringToIndex:paramStr.length-1];;
}

- (void)run{
}

@end
