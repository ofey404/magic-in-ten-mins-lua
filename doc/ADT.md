十分钟魔法练习：代数数据类型
=======================

## By 「玩火」 改写 「ofey404」

> 前置技能：lua 基础

<details><summary>Helper: 模拟一个简单的类型系统</summary>

```lua
local class = require("lib").class
local inherit = require("lib").inherit
```

</details>

## 积类型（Product type）

积类型是指同时包括多个值的类型，比如 lua 中的 table 就可以包括多个字段，可以通过 lua 提供的元表机制模拟成一个对象：


```lua
-- lua 中给表项赋值 nil 会直接删除，
-- 为展示方便用 "Nil" 作为默认值。
local Student = class("Student", {name = "Nil", id = "Nil"})

s = Student:new{name = 'ofey', id = 404}
print(s.name, s.id)
-- ofey	404
```

而上面这段代码中 Student 的类型中既有 string 类型的值也有 number 类型的值，可以表示为 string 和 number 的「积」，即 `string * number` 。

## 和类型（Sum type）

和类型是指可以是某一些类型之一的类型，在 lua 中可以简单地模拟出抽象类和继承：

```lua
-- 这里一定还有更好的模拟方法，让 SchoolPerson.name 的调用直接产生 error，只是我还没想到。
local SchoolPerson = class("SchoolPerson", {
    name = function() error("This should be implemented by subclass.") end
})

local Student = inherit(SchoolPerson, "Student", {
    name = "Nil",
    id = "Nil",
})
local Teacher = inherit(SchoolPerson, "Teacher", {
    name = "Nil",
    office = "Nil",
})
```

SchoolPerson 可能是 Student 也可能是 Teacher ，可以表示为 Student 和 Teacher 的「和」，即 `string * number + string * string` 。

而使用时可以确认表的键是否有 `id` 或者 `office` 来知道当前的 SchoolPerson 具体是 Student 还是 Teacher ，或者使用我们在 [lib.lua](./lib.lua) 中造的类型标识字段 `type`。

## 代数数据类型（ADT, Algebraic Data Type）

由和类型与积类型组合构造出的类型就是代数数据类型，其中代数指的就是和与积的操作。

利用和类型的枚举特性与积类型的组合特性，我们可以构造出 lua 中本来很基础的基础类型，比如枚举布尔的两个量来构造布尔类型：

```lua
local Bool = class('Bool', {})

local True = inherit(Bool, "True", {})
local False = inherit(Bool, "False", {})
```

然后用 `t["__tag"] == "True"` 就可以用来判定 t 作为 Bool 的值是不是 True 。

比如利用S的数量表示的自然数：

```lua
local Nat = class("Nat", {})

Z = inherit(Nat, "Z", {})
S = inherit(Nat, "S", {value = "Nil"})

function Sinc1(val)
    return S:new{value = val}
end

local three = Sinc1(Sinc1(Sinc1(Z)))
```

这里提一下自然数的皮亚诺构造，一个自然数要么是 0 (也就是上面的 Z ) 要么是比它小一的自然数 +1 (也就是上面的 S ) 。

例如 3 可以用 `Sinc1(Sinc1(Sinc1(Z)))` 来表示：

再比如链表：

```lua
local List = class("List", {})


local Nil = inherit(List, "Nil", {})
local Cons = inherit(List, "Cons", {
    value = "Nil",
    next = "Nil",
})

function Cons:link(val, list)
    self.value = val
    self.next = list
    return self
end

Cons:link(1, Cons:link(3, Cons:link(4, Nil:new{})))
```

`[1, 3, 4]` 就表示为 `Cons:link(1, Cons:link(3, Cons:link(4, Nil:new{})))`

更奇妙的是代数数据类型对应着数据类型可能的实例数量。

很显然积类型的实例数量来自各个字段可能情况的组合也就是各字段实例数量相乘，而和类型的实例数量就是各种可能类型的实例数量之和。

比如 Bool 的类型是 `1+1 `而其实例只有 True 和 False ，而 Nat 的类型是 `1+1+1+...` 其中每一个1都代表一个自然数，至于 List 的类型就是`1+x(1+x(...))` 也就是 `1+x^2+x^3...` 其中 x 就是 List 所存对象的实例数量。

## 实际运用

ADT 最适合构造树状的结构，比如解析 JSON 出的结果需要一个聚合数据结构。

```lua
local JsonValue = class("JsonValue", {value = "Nil"})

JsonBool = inherit(JsonValue, "JsonBool", {})
JsonInt = inherit(JsonValue, "JsonInt", {})
JsonString = inherit(JsonValue, "JsonString", {})
JsonArray = inherit(JsonValue, "JsonArray", {})
JsonMap = inherit(JsonValue, "JsonMap", {})
```

> 注1：lua 有用户编写的面向对象库，需要正式的面向对象能力的时候，请不吝使用。

## 参考

- [Programming in Lua | 16 – Object-Oriented Programming](https://www.lua.org/pil/16.html)
- [paulmoore/Animal.lua](https://gist.github.com/paulmoore/1429475)