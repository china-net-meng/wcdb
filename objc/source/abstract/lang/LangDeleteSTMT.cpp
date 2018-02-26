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

#include <WCDB/lang.h>

namespace WCDB {

namespace lang {

DeleteSTMT::DeleteSTMT() : offset(false)
{
}

copy_on_write_string DeleteSTMT::SQL() const
{
    std::string description;
    if (!withClause.empty()) {
        description.append(withClause.description().get() + " ");
    }
    assert(!qualifiedTableName.empty());
    description.append("DELETE FROM " + qualifiedTableName.description().get());
    if (!condition.empty()) {
        description.append(" WHERE " + condition.description().get());
    }
    if (!orderingTerms.empty()) {
        description.append(" ORDER BY " + orderingTerms.description().get());
        assert(!limit.empty());
    }
    if (!limit.empty()) {
        description.append(" LIMIT " + limit.description().get());
        if (!limitParameter.empty()) {
            if (offset) {
                description.append(" OFFSET ");
            } else {
                description.append(", ");
            }
            description.append(limitParameter.description().get());
        }
    }
    return description;
}

} // namespace lang

} // namespace WCDB
