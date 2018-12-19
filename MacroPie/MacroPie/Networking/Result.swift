//
//  Result.swift
//  MacroPie
//
//  Created by Basel Abdelaziz on 12/18/18.
//  Copyright © 2018 Basel Abdelaziz. All rights reserved.
//

import Foundation

enum Result<T, U> where U: Error  {
	case success(T)
	case failure(U)
}
