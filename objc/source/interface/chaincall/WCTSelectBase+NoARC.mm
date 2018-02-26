/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <WCDB/HandleStatement.hpp>
#import <WCDB/WCTBinding.h>
#import <WCDB/WCTChainCall+Private.h>
#import <WCDB/WCTCore+Private.h>
#import <WCDB/WCTSelectBase+NoARC.h>
#import <WCDB/WCTSelectBase+Private.h>
#import <WCDB/WCTSelectBase.h>

#if __has_feature(objc_arc)
#error This file should be compiled without ARC to get better performance. Please use -fno-objc-arc flag on this file.
#endif

@implementation WCTSelectBase (NoARC)

- (WCTValue *)extractValue
{
    switch (_statementHandle->getType(0)) {
        case WCTColumnTypeDouble:
            return [NSNumber numberWithDouble:_statementHandle->getValue<WCTColumnTypeDouble>(0)];
            break;
        case WCTColumnTypeInteger32:
            return [NSNumber numberWithInt:_statementHandle->getValue<WCTColumnTypeInteger32>(0)];
            break;
        case WCTColumnTypeInteger64:
            return [NSNumber numberWithLongLong:_statementHandle->getValue<WCTColumnTypeInteger64>(0)];
            break;
        case WCTColumnTypeString: {
            const char *string = _statementHandle->getValue<WCTColumnTypeString>(0);
            return string ? [NSString stringWithUTF8String:string] : nil;
        } break;
        case WCTColumnTypeBinary: {
            std::vector<unsigned char> data = _statementHandle->getValue<WCTColumnTypeBinary>(0);
            return [NSData dataWithBytes:data.data() length:data.size()];
        } break;
        case WCTColumnTypeNull: {
            return nil;
            break;
        }
        default:
            WCDB::Error::ReportInterface(_core->getTag(),
                                         _core->getPath(),
                                         WCDB::Error::InterfaceOperation::Select,
                                         WCDB::Error::InterfaceCode::Misuse,
                                         [NSString stringWithFormat:@"Extracting statement [%s] with unknown type %d", _statementHandle->getColumnName(0), (int) _statementHandle->getType(0)].UTF8String,
                                         &_error);
    }

    return nil;
}

- (BOOL)extractValueToRow:(NSMutableArray * /*WCTOneRow*/)row
{
    WCTValue *value = nil;
    for (int i = 0; i < _statementHandle->getColumnCount(); ++i) {
        switch (_statementHandle->getType(i)) {
            case WCTColumnTypeDouble:
                value = [NSNumber numberWithDouble:_statementHandle->getValue<WCTColumnTypeDouble>(i)];
                break;
            case WCTColumnTypeInteger32:
                value = [NSNumber numberWithInt:_statementHandle->getValue<WCTColumnTypeInteger32>(i)];
                break;
            case WCTColumnTypeInteger64:
                value = [NSNumber numberWithLongLong:_statementHandle->getValue<WCTColumnTypeInteger64>(i)];
                break;
            case WCTColumnTypeString: {
                const char *string = _statementHandle->getValue<WCTColumnTypeString>(i);
                value = string ? [NSString stringWithUTF8String:string] : @"";
            } break;
            case WCTColumnTypeBinary: {
                std::vector<unsigned char> data = _statementHandle->getValue<WCTColumnTypeBinary>(i);
                value = [NSData dataWithBytes:data.data() length:data.size()];
            } break;
            case WCTColumnTypeNull: {
                value = [NSNull null];
                break;
            }
            default:
                WCDB::Error::ReportInterface(_core->getTag(),
                                             _core->getPath(),
                                             WCDB::Error::InterfaceOperation::Select,
                                             WCDB::Error::InterfaceCode::Misuse,
                                             [NSString stringWithFormat:@"Extracting statement [%s] with unknown type %d", _statementHandle->getColumnName(i), (int) _statementHandle->getType(i)].UTF8String,
                                             &_error);
                return NO;
        }
        [row addObject:value];
    }
    return YES;
}

- (BOOL)extractPropertyToObject:(WCTObject *)object
                        atIndex:(int)index
              withColumnBinding:(const std::shared_ptr<WCTColumnBinding> &)columnBinding
{
    BOOL result = YES;
    const std::shared_ptr<WCTBaseAccessor> &accessor = columnBinding->accessor;
    switch (accessor->getAccessorType()) {
        case WCTAccessorCpp: {
            switch (accessor->getColumnType()) {
                case WCTColumnTypeInteger32: {
                    WCTCppAccessor<WCTColumnTypeInteger32> *i32Accessor = (WCTCppAccessor<WCTColumnTypeInteger32> *) accessor.get();
                    i32Accessor->setValue(object,
                                          _statementHandle->getValue<WCTColumnTypeInteger32>(index));
                } break;
                case WCTColumnTypeInteger64: {
                    WCTCppAccessor<WCTColumnTypeInteger64> *i64Accessor = (WCTCppAccessor<WCTColumnTypeInteger64> *) accessor.get();
                    i64Accessor->setValue(object,
                                          _statementHandle->getValue<WCTColumnTypeInteger64>(index));
                } break;
                case WCTColumnTypeDouble: {
                    WCTCppAccessor<WCTColumnTypeDouble> *floatAccessor = (WCTCppAccessor<WCTColumnTypeDouble> *) accessor.get();
                    floatAccessor->setValue(object,
                                            _statementHandle->getValue<WCTColumnTypeDouble>(index));
                } break;
                case WCTColumnTypeString: {
                    WCTCppAccessor<WCTColumnTypeString> *textAccessor = (WCTCppAccessor<WCTColumnTypeString> *) accessor.get();
                    textAccessor->setValue(object,
                                           _statementHandle->getValue<WCTColumnTypeString>(index));
                } break;
                case WCTColumnTypeBinary: {
                    WCTCppAccessor<WCTColumnTypeBinary> *blobAccessor = (WCTCppAccessor<WCTColumnTypeBinary> *) accessor.get();
                    std::vector<unsigned char> data = _statementHandle->getValue<WCTColumnTypeBinary>(index);
                    blobAccessor->setValue(object, data);
                } break;
                default:
                    WCDB::Error::ReportInterface(_core->getTag(),
                                                 _core->getPath(),
                                                 WCDB::Error::InterfaceOperation::Select,
                                                 WCDB::Error::InterfaceCode::Misuse,
                                                 [NSString stringWithFormat:@"Extracting column [%s] with unknown type %d", columnBinding->columnDef.getColumnName().c_str(), (int) accessor->getColumnType()].UTF8String,
                                                 &_error);
                    result = NO;
                    break;
            }
        } break;
        case WCTAccessorObjC: {
            WCTObjCAccessor *objcAccessor = (WCTObjCAccessor *) accessor.get();
            id value = nil;
            switch (accessor->getColumnType()) {
                case WCTColumnTypeInteger32:
                    value = [NSNumber numberWithInt:_statementHandle->getValue<WCTColumnTypeInteger32>(index)];
                    break;
                case WCTColumnTypeInteger64:
                    value = [NSNumber numberWithLongLong:_statementHandle->getValue<WCTColumnTypeInteger64>(index)];
                    break;
                case WCTColumnTypeDouble:
                    value = [NSNumber numberWithDouble:_statementHandle->getValue<WCTColumnTypeDouble>(index)];
                    break;
                case WCTColumnTypeString: {
                    const char *string = _statementHandle->getValue<WCTColumnTypeString>(index);
                    value = string ? [NSString stringWithUTF8String:string] : nil;
                } break;
                case WCTColumnTypeBinary: {
                    std::vector<unsigned char> data = _statementHandle->getValue<WCTColumnTypeBinary>(index);
                    value = [NSData dataWithBytes:data.data() length:data.size()];
                } break;
                default:
                    WCDB::Error::ReportInterface(_core->getTag(),
                                                 _core->getPath(),
                                                 WCDB::Error::InterfaceOperation::Select,
                                                 WCDB::Error::InterfaceCode::Misuse,
                                                 [NSString stringWithFormat:@"Extracting column [%s] with unknown type %d", columnBinding->columnDef.getColumnName().c_str(), (int) accessor->getColumnType()].UTF8String,
                                                 &_error);
                    result = NO;
                    break;
            }
            objcAccessor->setObject(object, value);
        } break;
        default:
            WCDB::Error::ReportInterface(_core->getTag(),
                                         _core->getPath(),
                                         WCDB::Error::InterfaceOperation::Select,
                                         WCDB::Error::InterfaceCode::Misuse,
                                         [NSString stringWithFormat:@"Extracting column [%s] with unknown accessor type %d", columnBinding->columnDef.getColumnName().c_str(), (int) accessor->getAccessorType()].UTF8String,
                                         &_error);
            result = NO;
            break;
    }
    return result;
}

@end
