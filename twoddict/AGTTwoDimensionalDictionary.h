//
//  AGTTwoDimensionalDictionary.h
//  Compleat Ankh-Morpork
//
//  Created by Graham Lee on 06/12/2012.
//
//

#import <Foundation/Foundation.h>

@interface AGTTwoDimensionalDictionary : NSObject

/**
 * Set a value at a particular location.
 */
- (void)setObject: (id)object atLocation: (CGPoint)location;

/**
 * Look up the object currently at a location. Returns nil if none exists.
 */
- (id)objectAtLocation: (CGPoint)location;

/**
 * Returns every object contained within the bounding rectangle specified.
 */
- (NSSet *)objectsWithinRect:(CGRect)rect;

/**
 * Remove the object at a location. It's not a problem to remove at a nonexistent key; nothing happens
 * (though this object still does the work of looking it up, so it's not a no-op.)
 */
- (void)removeObjectAtLocation: (CGPoint)location;

@end
