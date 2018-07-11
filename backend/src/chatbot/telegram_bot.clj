(ns chatbot.telegram-bot
  (:require [chatbot.recognition]
            [morse.handlers :as handlers]
            [morse.api :as api]))

(def token "619166619:AAETbQdzarQiXd9yKUlmhs3zlVmzTceHPJU")

(defn botapi [{{id :id} :chat text :text}]
  (let [{question :question intent :intent answer :answer} (chatbot.recognition/answer text)]
    (api/send-text token id {:parse_mode "Markdown"} answer)))