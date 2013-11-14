	# -*- coding: utf-8 -*-

	Plugin.create :mikutter_milk_gen do
	
		# 全角半角判定
		def isHalf? str
			(/[ -~｡-ﾟ]/ =~str)
		end
	
		command(:milk_gen,
			name: '農協牛乳ジェネレータ',
			condition: lambda{ |opt| true },
			visible: true,
			role: :postbox
		) do |opt|
			begin
				# 1文字ずつバラす
				text = Plugin[:gtk].widgetof(opt.widget).widget_post.buffer.text
				text = text.gsub( "ー", "｜" )
				text = text.gsub( "-", "|" )
				text = text.gsub(/[\r\n]/,"")
				# 改行で分ける
				message = text.split(//)
				# 半角をスペースいれて補正
				i = 0
				message.each do |line|
					if isHalf?( line )
						message[i] = line + " "
					end
					i += 1
				end
				# 配列
				dest = Array.new(i)
			
				# で、作成。
				i = 0
				tmp = ""
				result = ""
				message.each do |line|
					tmp = "　 ［二］\n"
					if i == 0
						tmp += "　_/　 /ヽ＿\n"
					else
						tmp += "　 /　 /ヽ\n"
						num = i - 1
						i2 = 0
						for i2 in 0..num do
							if  i2 == num
								tmp += "　｜#{message[i2]}｜ |＿\n"
							else
								tmp += "　｜#{message[i2]}｜ |\n"
							end
						end
					end
					tmp += "／｜#{message[i]}｜ |／\n"
					tmp += "￣￣￣￣￣\n"
								
					dest[i] = tmp
					i += 1
					result += tmp
				end
				
				# ヘッダー
				header = UserConfig[:milk_gen_header]
				if header == nil or header.empty?
					header = ""
				else
					header += "\n"
				end
			
				# スレッド作ってまでやることなのかどうかはしらん
				Thread.new {
					if UserConfig[:milk_gen_update] then
						if UserConfig[:milk_gen_update_one]
							dest = dest.reverse
							dest.each do |line|
								Post.primary_service.update(:message => header + line)
								sleep ( 1 )
							end
						else
							Post.primary_service.update(:message => result)
						end
						Plugin[:gtk].widgetof(opt.widget).widget_post.buffer.text = ""
						else
							Plugin[:gtk].widgetof(opt.widget).widget_post.buffer.text = header + result
					end
				}
			end
		end

		settings "農協牛乳ジェネレータ" do
			boolean('すぐに投稿する', :milk_gen_update)
			boolean('1つずつ投稿する', :milk_gen_update_one)
			input("ヘッダー", :milk_gen_header)
		end
	end
