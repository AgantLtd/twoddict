//
//  AGTTwoDimensionalDictionary.mm
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

#import "AGTTwoDimensionalDictionary.h"
#include <set>

typedef enum
{
    DictionaryNodeLevelX, DictionaryNodeLevelY
} DictionaryNodeLevel;

class UnknownNodeLevelException {};
class UnknownNodeException {};

class DictionaryNode
{
    private:
    DictionaryNode *left;
    DictionaryNode *right;
    DictionaryNode *parent;
    DictionaryNodeLevel level;

    DictionaryNode *findNext(CGPoint location)
    {
        DictionaryNode *next = NULL;
        switch (level)
        {
            case DictionaryNodeLevelX:
            {
                next = (location.x <= this->point.x) ? left : right;
                break;
            }
            case DictionaryNodeLevelY:
            {
                next = (location.y <= this->point.y) ? left : right;
                break;
            }
            default:
            {
                throw UnknownNodeLevelException();
            }
        }
        return next;
    }

    public:
    id object;
    CGPoint point;

    DictionaryNode(id obj, CGPoint p, DictionaryNodeLevel level, DictionaryNode *parent)
    :object(obj),
    point(p),
    level(level),
    parent(parent),
    left(NULL),
    right(NULL)
    {
    }

    ~DictionaryNode()
    {
        object = nil;
        if (left) delete left;
        if (right) delete right;
    }

    id find(CGPoint location)
    {
        if (CGPointEqualToPoint(location, this->point)) return this->object;
        DictionaryNode *next = findNext(location);
        return (next) ? next->find(location) : nil;
    }

    void insert(id object, CGPoint location)
    {
        if (CGPointEqualToPoint(location, this->point))
        {
            this->object = object;
            return;
        }
        DictionaryNode *next = findNext(location);
        if (next)
        {
            next->insert(object, location);
            return;
        }
        else
        {
            switch (level)
            {
                case DictionaryNodeLevelX:
                {
                    next = new DictionaryNode(object, location, DictionaryNodeLevelY, this);
                    if (location.x <= this->point.x)
                    {
                        left = next;
                    }
                    else
                    {
                        right = next;
                    }
                    break;
                }
                case DictionaryNodeLevelY:
                {
                    next = new DictionaryNode(object, location, DictionaryNodeLevelX, this);
                    if (location.y <= this->point.y)
                    {
                        left = next;
                    }
                    else
                    {
                        right = next;
                    }
                    break;
                }
                default:
                {
                    throw UnknownNodeLevelException();
                }
            }
        }
    }

    void replace(DictionaryNode *current, DictionaryNode *replacement)
    {
        DictionaryNode *temporary;
        if (current == left)
        {
            temporary = left;
            left = replacement;
        }
        else if (current == right)
        {
            temporary = right;
            right = replacement;
        }
        else
        {
            throw UnknownNodeException();
        }
        if (replacement)
        {
            replacement->parent = this;
        }
        temporary->clearLinks();
        delete temporary;
    }

    DictionaryNode *remove(CGPoint location)
    {
        DictionaryNode *next = this;
        while (next != NULL && !CGPointEqualToPoint(location, next->point))
        {
            next = next->findNext(location);
        }
        if (next == NULL) return this; //not found - tree is unchanged
        //Knuth §6.2.2 algorithm D.
        DictionaryNode *t = next, *q = next;
        if (t->right == NULL)
        {
            if (q->parent == NULL)
            {
                return t->left;
            }
            else
            {
                q->parent->replace(q, t->left);
                return this;
            }
        }
        else
        {
            DictionaryNode *r = t->right;
            if (r->left == NULL)
            {
                r->left = t->left;
                if (q->parent == NULL)
                {
                    return r;
                }
                else
                {
                    q->parent->replace(q, r);
                    return this;
                }
            }
            else
            {
                DictionaryNode *s = r->left;
                while (s->left != NULL)
                {
                    r = s;
                    s = r->left;
                }
                s->replace(s->left, t->left);
                r->replace(r->left, s->right);
                s->replace(s->right, t->right);
                if (q->parent == NULL)
                {
                    return s;
                }
                else
                {
                    q->parent->replace(q, s);
                    return this;
                }
            }
        }
    }

    void clearLinks()
    {
        left = NULL;
        right = NULL;
    }

    void addIfInRange(CGPoint minimum, CGPoint maximum, std::set<id>& set)
    {
        if (point.x >= minimum.x && point.x <= maximum.x && point.y >= minimum.y && point.y <= maximum.y)
        {
            set.insert(object);
        }
        switch (level)
        {
            case DictionaryNodeLevelX:
            {
                if (minimum.x <= point.x && left != NULL)
                {
                    left->addIfInRange(minimum, maximum, set);
                }
                if (point.x <= maximum.x && right != NULL)
                {
                    right->addIfInRange(minimum, maximum, set);
                }
                break;
            }
            case DictionaryNodeLevelY:
            {
                if (minimum.y <= point.y && left != NULL)
                {
                    left->addIfInRange(minimum, maximum, set);
                }
                if (point.y <= maximum.y && right != NULL)
                {
                    right->addIfInRange(minimum, maximum, set);
                }
                break;
            }
            default:
            {
                throw UnknownNodeLevelException();
            }
        }
    }

};


@implementation AGTTwoDimensionalDictionary
{
    DictionaryNode *root;
}

- (void)setObject: (id)object atLocation: (CGPoint)location
{
    NSParameterAssert(object);
    if (!root)
    {
        root = new DictionaryNode(object, location, DictionaryNodeLevelX, NULL);
    }
    else
    {
        root->insert(object, location);
    }
}

- (id)objectAtLocation: (CGPoint)location
{
    if (!root) return nil;
    return root->find(location);
}

- (void)removeObjectAtLocation:(CGPoint)location
{
    if (!root) return;
    DictionaryNode *nextRoot = root->remove(location);
    if (nextRoot != root)
    {
        DictionaryNode *oldRoot = root;
        root = nextRoot;
        oldRoot->clearLinks();
        delete oldRoot;
    }
}

- (void)dealloc
{
    if (root) delete root;
}

- (NSSet *)objectsWithinRect:(CGRect)rect
{
    if (!root) return [NSSet set];
    CGPoint min = {.x = CGRectGetMinX(rect), .y = CGRectGetMinY(rect)};
    CGPoint max = {.x = CGRectGetMaxX(rect), .y = CGRectGetMaxY(rect)};
    std::set<id> matchingObjects;
    root->addIfInRange(min, max, matchingObjects);
    NSMutableSet *result = [NSMutableSet set];
    for (std::set<id>::const_iterator i = matchingObjects.begin(); i != matchingObjects.end(); i++)
    {
        [result addObject: *i];
    }
    return result;
}

@end
