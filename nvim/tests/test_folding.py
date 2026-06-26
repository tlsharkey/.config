#!/usr/bin/env python3
"""Test file for folding functionality."""

def outer_function():
    """This is an outer function."""
    x = 1
    y = 2

    def inner_function():
        """This is an inner function."""
        a = 3
        b = 4
        return a + b

    return inner_function()


class MyClass:
    """A test class."""

    def __init__(self):
        """Initialize the class."""
        self.value = 42

    def method_one(self):
        """First method."""
        if self.value > 0:
            print("positive")
        else:
            print("negative")

    def method_two(self):
        """Second method."""
        for i in range(10):
            print(i)


if __name__ == "__main__":
    obj = MyClass()
    obj.method_one()
    result = outer_function()
    print(result)
