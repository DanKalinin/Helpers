//
//  HLPMain.h
//  Helpers
//
//  Created by Dan Kalinin on 6/22/18.
//

#import <Foundation/Foundation.h>

#define HLPRestrictedValue(value, minValue, maxValue) (value < minValue ? minValue : (value > maxValue ? maxValue : value))

typedef void (^HLPVoidBlock)(void);
