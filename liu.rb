*
一、通知 notification

内容 content 							string
类型 notification_type						string  {IR Review, 项目通知，投资人动态}
是否已读 is_read						boolean
用户id user_id							integer

相关json字段 notice
项目通知：funding_id


二、我的审核 verification

类型 verification_type						string
状态 status							string
描述 desc							string
拒绝理由 rejection_reason					string
发起人 sponsor						integer
用户id user_id 						integer

审核相关json字段 verify
title： before，after
project：funding_id
company：company_id


三、BSC评分 evaluation

市场 market							integer
业务 business							integer
团队 team							integer
交易 exchange						integer
是否通会 is_agree						boolean
其他建议 other						string
评分人 user_id							integer
项目id funding_id						integer

四、question

desc								text
user_id								integer
funding_id							integer


审核

点击审核后，通过审核类型执行相应动作

如果类型是修改title，则调用title模型方法，把title改变

如果类型是BSC评分，则调用评分模型，提出问题，并开始评分

如果类型是KA申请，则调用公司模型，并将公司进入KA


审核前传

1、用户在修改title时，创建一个审核，并把审核传给相应的审核人。

创建审核方法（用户，审核类型：title修改，修改前title，修改后title）

描述：Title由“修改前title”改为“修改后title”


2、用户在启动项目BSC时，创建一个审核，并把审核传给相应的审核人。

创建审核方法（项目，审核类型：BSC评分，评分人：当前用户）

描述：【项目名称】已启动BSC


3、用户在提出KA申请时，创建一个审核，并把审核传给相应的审核人。

创建审核方法（公司，审核类型：KA申请）

描述：项目【公司名称】申请进入KA


4、用户在提出约见申请时，创建一个审核，并把审核传给相应的审核人。

创建审核方法（项目，审核类型：约见申请，约见时间）

描述：项目【项目名称】申请约见(约见时间)



审核权限

Title修改、KA申请、约见申请 		管理员
BSC评分 					管理员 投委会


判断当前用户是否为管理员 或 投委会

如果是管理员或投委会
那么可以查看所有不是我发起的审核




User.last.user_roles.find_by(role_id: 2).destroy 删除管理权限


BSC

funding has_many bsc

bsc has_one 投委会、上会团队
bsc has_many evaluate、question

状态
初始化、已启动bsc、已启动bsc投票


模型

1、bsc
status								string

值：[“active”, “evaluating”, “”]

2、投委会investment committee
opinion							  text
user_ids							array[integer]
funding_id							integer

3、上会团队conference team
opinion							text
team_ids							array[integer]
funding_id							integer

5、answer
content							text
question_id							integer
user_id								integer

6、evaluate
user_id								integer
funding_id							integer

7、question

user_id								integer
funding_id							integer



接口

1、切换bsc状态
开启bsc投票后，投委会会收到评分通知
2、投委会成员增、改、查
3、上会团队增、改、查
4、讨论意见改、查
5、答案增、删、改、查
项目组成员回答后，通知投委会
6、投票 增删改查
当所有投票完成时，计算投委会成员的投票结果，自动推进项目进入下一阶段或管理员手动推动

如果未完成，管理员发通知提醒未投票投委会成员

7、问题增删改查
投委会提问后，通知项目组成员





1、连续两次申请更改title
2、当申请更改title时，管理员手动给他改了
