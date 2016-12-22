# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Fx::Level.find_or_create_by(id: 1,name: "普通会员",label: "normal" )
Fx::Level.find_or_create_by(id: 2,name: "金牌会员",label: "gold")
Fx::Level.find_or_create_by(id: 3,name: "天使会员",label: "angle")
Fx::Level.find_or_create_by(id: 4,name: "普通合伙人",label: "parter_normal",dealer1_percent: 5,dealer2_percent: 15,dealer3_percent: 50)
Fx::Level.find_or_create_by(id: 5,name: "终身合伙人",label: "parter_always",dealer1_percent: 5,dealer2_percent: 15,dealer3_percent: 50)
Fx::Level.find_or_create_by(id: 6,name: "地区合伙人",label: "parter_city",dealer1_percent: 8,dealer2_percent: 18,dealer3_percent: 50)
Fx::Level.find_or_create_by(id: 7,name: "省级合伙人",label: "parter_province",dealer1_percent: 8,dealer2_percent: 18,dealer3_percent: 50)
Fx::Level.find_or_create_by(id: 8,name: "大区事业合伙人",label: "parter_state",dealer1_percent: 10,dealer2_percent: 20,dealer3_percent: 50)
Fx::Level.find_or_create_by(id: 9,name: "公司内部员工",label: "employee")
Fx::User.find_or_create_by(id: 1,level_id: 4 ).update_columns(account: "13693099755")
Fx::User.find_or_create_by(id: 2,level_id: 3).update_columns(account: "18811499902")
Fx::User.find_or_create_by(id: 3,level_id: 2 ).update_columns(account: "15201148063")
user = Manage::User.create id: account.id, name: '管理员'
role = Manage::Role.create name: '管理员', manage_grant: 127, manage_editor: 127, manage_role: 127
editor = Manage::Editor.create id: user.id, identifier: account.email, name: '管理员', role_id: role.id
Fx::Setting.find_or_create_by(id: 1,apply: {} )
