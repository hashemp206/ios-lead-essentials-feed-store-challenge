//
//  XCTestCase+MemoryLeakTracking.swift
//  Tests
//
//  Created by Hashem Aboonajmi on 8/13/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: Int = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: #file, line: #line)
        }
    }
}
