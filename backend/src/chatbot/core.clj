(ns chatbot.core
  (:require [clojure.edn        :as    edn]
            [compojure.core     :refer :all]
            [compojure.handler  :refer [site]]
            [ring.util.response :refer [response]]
            [ring.adapter.jetty :refer [run-jetty]]
            [clojure.data.json :as json]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.json :refer [wrap-json-body]]
            [chatbot.recognition]))


(defroutes app-routes
           (POST "/api/query" {body :body}
                 (println body)
                 (let [{timeStamp :timeStamp userId :userId userChatMessage :userChatMessage } body]
                   (let [ { quesiton :question intent :intent answer :answer} (chatbot.recognition/answer userChatMessage) ]
                     (response (json/write-str {
                                               :timeStamp timeStamp
                                               :userId userId
                                               :userChatMessage userChatMessage
                                               :statusCode 200
                                               :botChatMessage answer
                                               :intentName intent}))))
                 ))


(def app
  (-> (site app-routes)
      (wrap-json-body {:keywords? true :bigdecimals? true})
        (wrap-cors :access-control-allow-origin [#".*"]
                 :access-control-allow-methods [:get :put :post :delete]
                 :access-control-allow-headers ["Content-Type"])
      ))


(defn -main [& args]
  (run-jetty app {:port 5000}))