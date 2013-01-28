//
//  TwoDimensionalDictionaryTests.m
//  Compleat Ankh-Morpork
//
//  Created by Graham Lee on 06/12/2012.
//
//

#import "TwoDimensionalDictionaryTests.h"
#import "AGTTwoDimensionalDictionary.h"

@implementation TwoDimensionalDictionaryTests
{
    AGTTwoDimensionalDictionary *dict;
    CGPoint CGPointOneOne;
}

- (void)setUp
{
    dict = [AGTTwoDimensionalDictionary new];
    CGPointOneOne = CGPointMake(1, 1);
}

- (void)tearDown
{
    dict = nil;
}

- (void)testAnObjectCanBeInserted
{
    NSString *greeting = @"Hello";
    STAssertNoThrow([dict setObject: greeting atLocation: CGPointZero], @"I can add an object!");
}

- (void)testObjectAddedCannotBeNil
{
    STAssertThrows([dict setObject: nil atLocation: CGPointZero], @"Cannot add nil to the dictionary");
}

- (void)testAddedObjectCanBeRetrieved
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    id returnedObject = [dict objectAtLocation: CGPointZero];
    STAssertEqualObjects(returnedObject, @"Hello", @"I got the object back!");
}

- (void)testNoObjectRetrievedWhenNothingIsAdded
{
    id returnedObject = [dict objectAtLocation: CGPointZero];
    STAssertNil(returnedObject, @"Nothing's added - what got returned? %@", returnedObject);
}

- (void)testNoObjectRetrievedForNonexistentPoint
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    id returnedObject = [dict objectAtLocation:CGPointOneOne];
    STAssertNil(returnedObject, @"I shouldn't get an object for a point that isn't in the dictionary");
}

- (void)testTwoObjectsCanBeAddedAndRetrieved
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    [dict setObject: @"Goodbye" atLocation: CGPointOneOne];
    STAssertEqualObjects([dict objectAtLocation: CGPointZero], @"Hello", @"Object at point zero remembered");
    STAssertEqualObjects([dict objectAtLocation: CGPointOneOne], @"Goodbye", @"Object at point 1,1 remembered");
}

- (void)testTwoObjectCaseInReverseOrder
{
    [dict setObject: @"Goodbye" atLocation: CGPointOneOne];
    [dict setObject: @"Hello" atLocation: CGPointZero];
    STAssertEqualObjects([dict objectAtLocation: CGPointZero], @"Hello", @"Object at point zero remembered");
    STAssertEqualObjects([dict objectAtLocation: CGPointOneOne], @"Goodbye", @"Object at point 1,1 remembered");
}

- (void)testObjectCanBeReplaced
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    [dict setObject: @"olleH" atLocation: CGPointZero];
    STAssertEqualObjects([dict objectAtLocation: CGPointZero], @"olleH", @"Test replacement object");
}

- (void)testObjectCanBeRemoved
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    [dict removeObjectAtLocation: CGPointZero];
    id returnedObject = [dict objectAtLocation: CGPointZero];
    STAssertNil(returnedObject, @"This should be nil but I got %@", returnedObject);
}

- (void)testNoEffectRemovingANonExistentKey
{
    [dict setObject: @"Hello" atLocation: CGPointZero];
    STAssertNoThrow([dict removeObjectAtLocation: CGPointOneOne], @"Removing a nonexistent location should be fine");
    id returnedObject = [dict objectAtLocation: CGPointZero];
    STAssertEqualObjects(returnedObject, @"Hello", @"Dictionary contents unmodified by no-op removal");
}

- (void)testNoEffectRemovingFromEmptyDictionary
{
    STAssertNoThrow([dict removeObjectAtLocation: CGPointZero], @"Removing from an empty dictionary is OK (but does nothing)");
}

- (void)populateFiveItemDict
{
    [dict setObject: @(0) atLocation: CGPointZero];
    [dict setObject: @(1) atLocation: CGPointOneOne];
    [dict setObject: @(-1) atLocation: CGPointMake(-1, -1)];
    [dict setObject: @(2) atLocation:CGPointMake(-1, 0.5)];
    [dict setObject: @(3) atLocation:CGPointMake(1, 2)];
}

- (void)testRemovalFromMoreComplicatedCase
{
    [self populateFiveItemDict];
    [dict removeObjectAtLocation: CGPointZero];
    STAssertEquals([dict objectAtLocation: CGPointOneOne], @(1), @"Removal left other objects intact");
    STAssertEquals([dict objectAtLocation:CGPointMake(-1, -1)], @(-1), @"Removal left other objects intact");
    STAssertEquals([dict objectAtLocation:CGPointMake(-1, 0.5)], @(2), @"Removal left other objects intact");
    STAssertEquals([dict objectAtLocation:CGPointMake(1, 2)], @(3), @"Removal left other objects intact");
    id removedObject = [dict objectAtLocation: CGPointZero];
    STAssertNil(removedObject, @"The object didn't get removed: %@", removedObject);
}

- (void)testRemovalOfLeftmostObject
{
    [self populateFiveItemDict];
    CGPoint targetPoint = CGPointMake(-1, -1);
    [dict removeObjectAtLocation: targetPoint];
    id removedObject = [dict objectAtLocation: targetPoint];
    STAssertNil(removedObject, @"location at -1, -1 not empty: %@", removedObject);
    STAssertEqualObjects([dict objectAtLocation: CGPointMake(-1, 0.5)], @(2), @"Child object still remains");
}

- (void)testRemovalOfRightmostObject
{
    [self populateFiveItemDict];
    CGPoint targetPoint = CGPointOneOne;
    [dict removeObjectAtLocation: targetPoint];
    id removedObject = [dict objectAtLocation: targetPoint];
    STAssertNil(removedObject, @"location at 1, 1 not empty: %@", removedObject);
    STAssertEqualObjects([dict objectAtLocation: CGPointMake(1, 2)], @(3), @"Child object still remains");
}

- (void)testRemovalOfALeafObject
{
    [self populateFiveItemDict];
    CGPoint targetPoint = CGPointMake(1, 2);
    [dict removeObjectAtLocation: targetPoint];
    id removedObject = [dict objectAtLocation: targetPoint];
    STAssertNil(removedObject, @"location at 1,2 not empty: %@", removedObject);
    STAssertEqualObjects([dict objectAtLocation: CGPointOneOne], @(1), @"Sanity test that the parent is still there");
}

- (void)testRemovalOfLeafOnRightOfParentWithNullLeft
{
    [self populateFiveItemDict];
    CGPoint targetPoint = CGPointMake(-1, 0.5);
    [dict removeObjectAtLocation: targetPoint];
    id removedObject = [dict objectAtLocation: targetPoint];
    STAssertNil(removedObject, @"location at -1,0.5 not empty", removedObject);
    STAssertEqualObjects([dict objectAtLocation: CGPointMake(-1, -1)], @(-1), @"Ensure the parent is still accessible");
}

- (void)testGettingObjectsWithinAParticularRange
{
    [dict setObject: @(0) atLocation: CGPointZero];
    [dict setObject: @(1) atLocation: CGPointOneOne];
    [dict setObject: @(-1) atLocation:CGPointMake(-1, -1)];
    [dict setObject: @(2) atLocation:CGPointMake(2, 1)];
    [dict setObject: @(3) atLocation:CGPointMake(0, 3)];
    CGRect interestingExtent = CGRectMake(1, 1, 1, 1);
    NSSet *interestingObjects = [dict objectsWithinRect: interestingExtent];
    STAssertEquals([interestingObjects count], (NSUInteger)2, @"-objectsWithinRect returned %ld objects but two were expected", (long)[interestingObjects count]);
    STAssertTrue([interestingObjects containsObject: @(1)], @"");
    STAssertTrue([interestingObjects containsObject: @(2)], @"");
}
@end
