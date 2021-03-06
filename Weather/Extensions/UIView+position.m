//
//  UIView+position.m
//
//  Apache license
//
//  Created by Tyler Neylon on 3/19/10 (http://bynomial.com/blog/?p=24)
//  Copyleft 2010 Bynomial.
//

#import "UIView+position.h"


@implementation UIView (position)

- (CGPoint)origin {
  return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin {
  self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)newSize {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          newSize.width, newSize.height);
}

- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newX {
  self.frame = CGRectMake(newX, self.frame.origin.y,
                          self.frame.size.width, self.frame.size.height);
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newY {
  self.frame = CGRectMake(self.frame.origin.x, newY,
                          self.frame.size.width, self.frame.size.height);
}

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)newRight {
  self.frame = CGRectMake(newRight - self.frame.size.width, self.frame.origin.y,
                          self.frame.size.width, self.frame.size.height);
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newBottom {
  self.frame = CGRectMake(self.frame.origin.x, newBottom - self.frame.size.height,
                          self.frame.size.width, self.frame.size.height);
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          newWidth, self.frame.size.height);
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          self.frame.size.width, newHeight);
}

- (void)addCenteredSubview:(UIView *)subview {
    subview.left = (int)((self.bounds.size.width - subview.frame.size.width) / 2);
    subview.top = (int)((self.bounds.size.height - subview.frame.size.height) / 2);
    [self addSubview:subview];
}

- (void)moveToCenterOfSuperview {
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

    self.left = (int)((self.superview.bounds.size.width - self.frame.size.width) / 2);
    self.top = (int)((self.superview.bounds.size.height - self.frame.size.height) / 2);
}

- (void)centerVerticallyInSuperview
{
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

    self.top = (int)((self.superview.bounds.size.height - self.frame.size.height) / 2);
}

- (void)centerHorizontallyInSuperview
{
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");

    self.left = (int)((self.superview.bounds.size.width - self.frame.size.width) / 2);
}

- (CGFloat)fromRightEdge
{
	if (!self.superview) return 0;
	return (self.superview.bounds.size.width - self.left - self.width);
}

- (void)setFromRightEdge:(CGFloat)edge
{
	if (!self.superview) return;
	self.left = self.superview.bounds.size.width - self.width - edge;
}

- (CGFloat)fromBottomEdge
{
	if (!self.superview) return 0;
	return (self.superview.bounds.size.height - self.top - self.height);
}

- (void)setFromBottomEdge:(CGFloat)edge
{
	if (!self.superview) return;
	self.top = self.superview.bounds.size.height - self.height - edge;
}

@end
