class LinebotController < ApplicationController
  require "line/bot"  # gem "line-bot-api"
 
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
 
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
     
  def callback
    body = request.body.read
    
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    unless client.validate_signature(body, signature)
      error 400 do "Bad Request" end
    end
   
    events = client.parse_events_from(body)
   
    events.each { |event|
    case event
         when Line::Bot::Event::Message
           case event.type
           when Line::Bot::Event::MessageType::Text
                if event.message['text'] == "住まい"
                    client.reply_message(event["replyToken"], template)
                elsif event.message['text'] == "はい"
                    message = {
                        type: "text",
                        text: "島根県には特に配慮が必要な世帯に優良な住宅の供給を促進する制度があります！！\n\n" +
                              "賃貸提供：島根県地域優良賃貸住宅制度 https://www.pref.shimane.lg.jp/infra/build/jutaku/yuryo/\n" +
                              "リフォーム：しまね長寿・子育て安心住宅リフォーム助成事業 https://www.pref.shimane.lg.jp/kenchikujuutaku/shienseido/shimane_tyojunosumai_reform_jyosei.html"
                    }
                    client.reply_message(event["replyToken"], message)
                elsif event.message['text'] == "いいえ"
                    message = {
                        type: "text",
                        text: "家を探すor家を建てる https://www.kurashimanet.jp/lifestyle/house/"
                    }                    
                    client.reply_message(event["replyToken"], message)
                    
                elsif event.message['text'] == "教育"
                    client.reply_message(event["replyToken"], template2)
                elsif event.message['text'] == "経済的支援"
                    message = {
                        type: "text",
                        text: "様々な経済的支援を受けられます！ \n https://www.pref.shimane.lg.jp/medical/fukushi/hitori/hitori_oya_katei/keizaisien.html"
                    }
                    client.reply_message(event["replyToken"], message)
                elsif event.message['text'] == "直接相談"
                    message = {
                        type: "text",
                        text: "種類に応じて窓口が存在します！ \n https://www.pref.shimane.lg.jp/education/kyoiku/iinkai/sodan/"
                    }
                    client.reply_message(event["replyToken"], message)    
                
                elsif event.message['text'] == "子育て"
                    client.reply_message(event["replyToken"], template3)
                elsif event.message['text'] == "支援制度"
                    message = {
                        type: "text",
                        text: "県の情報がまとめられています！ \n https://www.kurashimanet.jp/lifestyle/child-rearing/"
                    }
                    client.reply_message(event["replyToken"], message)
                elsif event.message['text'] == "電話相談"
                    message = {
                        type: "text",
                        text: "島根では専門スタッフが相談に応じます！ \n https://www.pref.shimane.lg.jp/education/child/kodomo/gyakutai/dennwasoudannmadoguti.html"
                    }
                    client.reply_message(event["replyToken"], message)
                    
                 elsif event.message['text'] == "医療福祉"
                    client.reply_message(event["replyToken"], template4)
                elsif event.message['text'] == "福祉医療支援制度"
                    message = {
                        type: "text",
                        text: "島根県では様々な福祉医療費助成制度があります！ \n https://www.pref.shimane.lg.jp/medical/fukushi/syougai/ippan/fukushiaramashi/iryo_3.html"
                    }
                    client.reply_message(event["replyToken"], message)
                elsif event.message['text'] == "乳幼児・子ども医療支援制度"
                    message = {
                        type: "text",
                        text: "島根県では各市町村で乳幼児・子供医療で手厚い費用助成制度があります！ \n http://www.shimane-kokuho.or.jp/gb03_health/other/1-1ika_other2.pdf"
                    }
                    client.reply_message(event["replyToken"], message)
                end
           when Line::Bot::Event::MessageType::Location
             message = {
               type: "location",
               title: "高齢者世帯・障がい者世帯・子育て世帯ですか？",
               address: event.message["address"],
               latitude: event.message["latitude"],
               longitude: event.message["longitude"]
             }
             client.reply_message(event["replyToken"], message)
           end
         end
       }
   
       head :ok
     end
             private
        def template
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "高齢者世帯・障がい者世帯・子育て世帯ですか？",
                "actions": [
                    {
                      "type": "message",
                      # Botから送られてきたメッセージに表示される文字列
                      "label": "はい",
                      # ボタンを押した時にBotに送られる文字列
                      "text": "はい"
                    },
                    {
                      "type": "message",
                      "label": "いいえ",
                      "text": "いいえ"
                    }
                ]
              }
            }
         end
        def template2
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "どちらに興味がありますか？",
                "actions": [
                    {
                      "type": "message",
                      # Botから送られてきたメッセージに表示される文字列
                      "label": "経済的支援",
                      # ボタンを押した時にBotに送られる文字列
                      "text": "経済的支援"
                    },
                    {
                      "type": "message",
                      "label": "直接相談",
                      "text": "直接相談"
                    }
                ]
            }
          }
        end
        def template3
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "どちらに興味がありますか？",
                "actions": [
                    {
                      "type": "message",
                      # Botから送られてきたメッセージに表示される文字列
                      "label": "支援制度",
                      # ボタンを押した時にBotに送られる文字列
                      "text": "支援制度"
                    },
                    {
                      "type": "message",
                      "label": "電話相談",
                      "text": "電話相談"
                    }
                ]
            }
          }
        end  
        def template4
          {
            "type": "template",
            "altText": "this is a confirm template",
            "template": {
                "type": "confirm",
                "text": "どちらに興味がありますか？",
                "actions": [
                    {
                      "type": "message",
                      # Botから送られてきたメッセージに表示される文字列
                      "label": "福祉医療支援制度",
                      # ボタンを押した時にBotに送られる文字列
                      "text": "福祉医療支援制度"
                    },
                    {
                      "type": "message",
                      "label": "乳幼児・子ども医療支援制度",
                      "text": "乳幼児・子ども医療支援制度"
                    }
                ]
            }
          }
        end
 end