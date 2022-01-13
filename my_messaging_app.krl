ruleset my_messaging_app {
  meta {
    use module com.twilio.sdk alias sdk
      with
        authToken = meta:rulesetConfig{"auth_token"}
        sessionID = meta:rulesetConfig{"session_id"}
    shares getMessages
  }

  global {
    getMessages = function(toNum, fromNum, pageSize, page, pageToken) {
      sdk:messages(toNum, fromNum, pageSize, page, pageToken)
    }
  }

  rule send_message {
    select when message send
      toNum re#(.+)#
      fromNum re#(.+)#
      body re#(.+)#
      setting(toNum, fromNum, body)
    if true then sdk:sendMessage(toNum, fromNum, body) setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
      raise message event "sent" attributes event:attrs
    }
  }
}
