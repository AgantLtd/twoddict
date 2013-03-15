//
//  AGTTwoDimensionalDictionary.h
//
// Copyright (c) 2013 Agant, Ltd.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
