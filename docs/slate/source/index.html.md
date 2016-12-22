---
title: hzb API
  - <a href='http://localhost:4567'>fx</a>
language_tabs:
  - shell

toc_footers:
  - <a href='http://localhost:4567'>分销系统 API</a>

includes:
  - errors2

search: true
---

# Introduce 说明

 ■用户登陆授权访问（基于http协议头验证）

 格式样例：--header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="

 ■测试用户对应数据user_id=2

 账户： 13693099755 密码：123456  验证token：　3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA==

 ■ 统一返回数据说明

 1: 所有时间格式为: DTS(数字时间戳)

 2: 空字符: ""

 3: 所有是否的布尔值返回: 0为false,1为true

 4: 空数组为: []


■ 所有返回状态为http协议状态

　如果请求失败，返回包含如下内容的JSON字符串：

 {
     "code":     <HttpCode  int>,
     "error":   "<ErrMsg    string>"
 }

 ■ 统一分页参数（包含在meta标签中）

 *分页请求参数

  page: 页面号,per_page: 每页返回记录

 *分页返回

 包含在meta标签中

 {"meta":
   {"current_page":#当前页面,
    "next_page":null,
    "prev_page":null,
    "total_pages":#总页数,
    "total_count":#共计多少条}
 }

  测试数据

  坐标: 优米总部: 116.50729,39.919726 | 四惠地铁: 116.50729,39.919726 |上海: 121.542903,31.2284

 ■ 本api与七牛的接口实现标准一致，可参考

 http://developer.qiniu.com/docs/v6/api/reference/up/bput.html

# Part1 分销相关接口

## 1、创建分销订单

### HTTP 请求
`POST http://localhost:3000/api/v1/fx/trades`

### Request 请求参数

参数名 | 是否必需 | 描述
-----| --------| -------
trade[name]   |  是      | 订单名称
trade[number]   |  是      | 订单号
trade[total_amount]   |  是      | 订单金额
trade[amount]   |  是      | 可分配利润
trade[optype]   |  是      |1: 在线招标,2: 商城,3: 脉脉圈
trade[user_id]   |  是      |购买者用户id

### Response 响应


其他响应数据参考: 获取用户信息

```shell
  curl -i -X POST -d  "trade[number]=JSD61459865167&trade[name]=商城订单1&trade[total_amount]=1000&trade[amount]=100&trade[optype]=2&trade[user_id]=1" --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="  http://localhost:3000/api/v1/fx/trades
```
> The above command returns JSON structured like this:

```json
```

## 2、获取分销商详细信息

### HTTP 请求

`GET /api/v1/fx/users/:id`

### Request 请求参数

参数名 | 是否必需 | 描述
-----| --------| -------
id   |  是      | 用户 id

### Response 响应

参数名 | 描述
-----| -------
id| 用户id
total_amount |  分销总计获利
tax_amount |  总个人所得税
balance |  分销获利余额
bang_balance |  邦邦余额
remain_user_num | 剩余名额
rank  |万人排名
province_rank  |省份排名
distance_amount | 万人区第一名的奖金差距
distance_province_amount | 省区第一名的奖金差距
state | 分销商状态（ 0  => "待激活",2  => "审核中",1  => "通过",-1 => "未通过"）
account | 用户object(id,nickname,avatar_url)
info | 分销信息对象object
level | 级别信息object

account参数名  | 描述
-----| -------
id  | 用户id
nickname  | 昵称
avatar_url  | 头像
province_name  | 省份
city_name  | 城市


info参数名  | 描述
-----| -------
amount  | 用户消费返利
amount1  | 一级分销获利
amount2  | 二级分销获利
amount3  | 三级分销获利
dealer_count  | 总分销商数量
dealer1_count  | 1级分销商数量
dealer2_count  | 2级分销商数量
dealer3_count  | 3级分销商数量
current_month_amount  | 本月分销获利


level参数名  | 描述
-----| -------
id  | 等级id
name  | 级别名称


```shell
  curl -i  http://localhost:3000/api/v1/fx/users/3
```
> 响应数据:

```json

{"id":3,"total_amount":50,"balance":50,"account":{"id":3,"nickname":"德子hero供应商","avatar_url":"http://7xi8qz.com1.z0.glb.clouddn.com/1459830463249.3577.jpg"},"info":{"amount1":"0.0","amount2":"0.0","amount3":"0.0","current_month_amount":"0.0"},"level":{"id":2,"name":"金牌会员"}}
```


## 3、用户注册接口

### HTTP 请求 (无登陆)

`POST /api/v1/users `

```shell
    curl -i -X POST -d "user[account]=13113099715&user[password]=123456&user[nickname]=test&mcaptcha=1234&user[password_confirmation]=123456&invitation=2umqwi"  http://localhost:3000/api/v1/fx/users
```

### Request 请求参数

参数名 | 是否必需 | 描述
-----| --------| -------
user[account]   |  是      | 用户账号（手机号）|
user[nickname]   |  是      | 昵称|
user[password]   |  是      | 密码|
user[password_confirmation]   |  是      | 确认密码|
user[os_type]   |  否      | 0: web,1: ios, 2: android
mcaptcha   |  是      | 验证码
invitation   |  否      | 分销邀请码

### Response 响应

错误响应 | 描述
-----| -------
token| 登陆token



## 4、分享注册页面(html)

### HTTP 请求 (无登陆)

`GET /fx/signup `

```shell
   http://localhost:3000/fx/signup
```

## 5、获取邀请二维码

### HTTP 请求 (无登陆)

`GET /api/v1/fx/users/1/qrcode `

```shell
  curl -i  http://localhost:3000/api/v1/fx/users/1/qrcode
```
### Response 响应

参数名 | 描述
-----| -------
invitation_url| 邀请网址
invitaion_qrcode| 邀请二维码
invitaion| 邀请码

## 6、分销获利记录

### HTTP 请求 (无登陆)

`GET /api/v1/fx/users/:user_id/transations `

### Request 请求参数

参数名 | 是否必需 | 描述
-----| --------| -------
user_id   |  是      | 用户 id
user_type   |  是      | 1: 本人消费,2: 一级分销获利, 3: 二级分销获利, 4: 三级分销获利

### Response 响应

参数名 | 描述
-----| -------
total_amount| 总获利金额
transations| 记录列表object

transations参数名 | 描述
-----| -------
trade_amount |  订单金额
amount| 获利金额
trade_id |  订单id
trade_name |  订单名称
created_at |  获利时间

```shell
  curl -i -X GET -d "user_type=1" --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="  http://localhost:3000/api/v1/fx/users/3/transations
```

## 7、申请分销商

### HTTP 请求 (无登陆)

`POST /api/v1/fx/users/apply `

### Request 请求参数

无

### Response 响应

错误响应 | 描述
-----| -------
422| 你已经是xxxx会员,xxxx名终身事业合伙人已招募满员

```shell
  curl -i -X POST  -d ""  --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="  http://localhost:3000/api/v1/fx/users/apply
```
####

##8、提现税金计算(弃用)

###  HTTP 请求 (登陆未登陆)

`GET /api/v1/fx/withdraws/tax_rate_check`

参数名 | 是否必需 | 描述
-----| ------|-------
price| 是|  金额


### Response 响应
参数名 | 描述
-----| -------
state| 状态
bang_amount | 邦邦余额
price | 提现金额
available_amount | 可提现金额
tax_rate | 税金

```shell
  curl -i -X GET -d "price=1000" --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="   http://localhost:3000/api/v1/fx/withdraws/tax_rate_check
```

##8.1、邦邦提现

###  HTTP 请求 (登陆未登陆)

`POST /api/v1/fx/withdraws`

参数名 | 是否必需 | 描述
-----| ------|-------
price| 是|  金额
user_name| 是|  用户名
bank_account| 是|  银行账户
bank_name| 是|  开户行名
account_password| 是| 支付密码


### Response 响应
参数名 | 描述
-----| -------
state| 状态
bang_amount | 剩余邦邦余额



参考任务列表

```shell
  curl -i -X POST -d "price=1000&user_name=32&bank_name=招商&bank_account=111&&account_password=123456" --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="   http://localhost:3000/api/v1/fx/withdraws
```


##10、邦邦提现记录

###  HTTP 请求 (登陆未登陆)

`GET /api/v1/fx/withdraws`

### Response 响应
参数名 | 描述
-----| -------
number | 订单号
price | 提现金额
user_name | 用户名
bank_name | 银行名
bank_account | 银行账户
state| 0,#申请中 1,#已汇款 -1, #审核未通过, 2, #审核中, 3 #汇款中
created_at| 创建时间


```shell
  curl -i --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="   http://localhost:3000/api/v1/fx/withdraws
```


##11 、查看邦邦余额

###  HTTP 请求 (登陆未登陆)

`GET /api/v1/fx/withdraws/bang_amount`

### Response 响应
参数名 | 描述
-----| -------
bang_amount | 邦邦余额


##12 、返回宣传图片

###  HTTP 请求 (登陆未登陆)

`GET /api/v1/fx/posters`

###  HTTP 请求 (未登陆)

```shell
  curl -i  http://localhost:3000/api/v1/fx/posters
```

### Response 响应
参数名 | 描述
-----| -------
pic | 图片url
url | 图片超链接



##13 、返回分销信息

###  HTTP 请求 (登陆未登陆)

`GET /api/v1/fx/info`

###  HTTP 请求 (未登陆)

```shell
  curl -i  http://localhost:3000/api/v1/fx/info
```

### Response 响应

apply参数对象 | 描述
-----| -------
limit | 分销招募人数
remain | 剩余名额

##14、个人所得税

###  HTTP 请求

`GET /api/v1/fx/tax_rates`

###  HTTP 请求 (未登陆)

```shell
  curl -i --header "Authorization: Token token=3ZZbHWoiFvGkXpyioCaGN8vin+nqTrHxuaNMvHai8EkZluS3LHHK15yQykK3gFgO8ATFEm4KxFJmT0jEg5FLYA=="   http://localhost:3000/api/v1/fx/tax_rates
```

### Response 响应

参数 | 描述
-----| -------
total_amount | 总税金
tax_rates | 所得税列表

tax_rates参数对象 | 描述
-----| -------
total_amount | 总金额
amount | 税金
date | 月份
state | 0: 未交，1：已交




