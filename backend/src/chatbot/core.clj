(ns chatbot.core
  (:require [clojure.edn        :as    edn]
            [compojure.core     :refer :all]
            [compojure.handler  :refer [site]]
            [ring.util.response :refer [response]]
            [ring.adapter.jetty :refer [run-jetty]]
            [clojure.data.json :as json]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.json :refer [wrap-json-body]]
            [chatbot.recognition]
            [chatbot.mongo]
            [chatbot.telegram-bot]
            [chatbot.email]))


(defroutes app-routes
  (POST "/api/query" {body :body}
    (let [{timeStamp :timeStamp userId :userId userChatMessage :userChatMessage} body]
      (let [{quesiton :question intent :intent answer :answer} (chatbot.recognition/answer userChatMessage)]
        (if (chatbot.utils/not-nil? userId)
          (chatbot.mongo/save-request userId timeStamp intent userChatMessage))
        (response (json/write-str {:timeStamp timeStamp
                                   :userId userId
                                   :userChatMessage userChatMessage
                                   :statusCode 200
                                   :botChatMessage answer
                                   :intentName intent})))))
  (POST "/api/lti" {params :params headers :headers}
                                                              (let [{lis_person_sourcedid :lis_person_sourcedid lis_person_contact_email_primary :lis_person_contact_email_primary}  (read-string (str params))]
                                                                (ring.util.response/redirect (str
                                                                                              "https://efp-chatbot.westeurope.cloudapp.azure.com/chat"
                                                                                              "?userId=" lis_person_sourcedid))))
  (POST "/api/telegram_handler" {{updates :message} :body} (chatbot.telegram-bot/botapi updates))
  (GET "/api/chat" { { userId :userId } :params }
     ;  (println (chatbot.mongo/list-user-messages userId))
       (response (json/write-str (chatbot.mongo/list-user-messages userId) :escape-unicode false)))
    )

(def app
  (-> (site app-routes)
      (wrap-json-body {:keywords? true :bigdecimals? true})
      (wrap-cors :access-control-allow-origin [#".*"]
                 :access-control-allow-methods [:get :put :post :delete]
                 :access-control-allow-headers ["Content-Type"])))


(defn -main [& args]
  (run-jetty app {:port 5000}))
