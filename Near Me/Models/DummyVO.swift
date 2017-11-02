//
//  DummyVO.swift
//  Near Me
//
//  Created by Pallav Trivedi on 30/10/17.
//  Copyright © 2017 Pallav Trivedi. All rights reserved.
//

import Foundation

class DummyVO
{
    var responseDict:[String:Any]?
}
extension DummyVO:WebServiceResponseVO
{
    func setData(response: Any)
    {
        responseDict = response as? [String:Any]
    }
}
