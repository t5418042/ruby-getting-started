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
                    #p "ここまで1"
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
                    message = {
                        type: "text",
                        text: "様々な経済的支援を受けられます！ https://www.pref.shimane.lg.jp/medical/fukushi/hitori/hitori_oya_katei/keizaisien.html"
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
            "type": "template2",
            "altText": "this is a confirm template2",
            "template2": {
                "type": "confirm",
                "text": "どちら？",
                "actions": [
                    {
                      "type": "message",
                      # Botから送られてきたメッセージに表示される文字列
                      "label": "経済",
                      # ボタンを押した時にBotに送られる文字列
                      "text": "経済"
                    },
                    {
                      "type": "message",
                      "label": "支援",
                      "text": "支援"
 end