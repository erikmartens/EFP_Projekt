(ns chatbot.core
  (:require [clojure.edn        :as    edn]
            [compojure.core     :refer :all]
            [compojure.handler  :refer [site]]
            [ring.util.response :refer [response]]
            [ring.adapter.jetty :refer [run-jetty]]
            [clojure.data.json :as json]
            [ring.middleware.cors :refer [wrap-cors]]))
(def reflections { :am "are" :was "were" :i "you" :i'd "you would" :i've "you have" :i'll "you will" :my "your" :are "am" :you've "I have" :you'll "I will" :your "my" :yours "mine" :you "me" :me "you"})
(def psychobabble '({ :question #"I need (.*)"
                      :answers ["Why do you need {0}?"
                                "Would it really help you to get {0}?"
                                "Are you sure you need {0}?"]}

                    { :question #"Why don\'?t you (:answers [^\?]*)\??"
                      :answers ["Do you really think I don't {0}?"
                                "Perhaps eventually I will {0}."
                                "Do you really want me to {0}?"]}

                    { :question #"Why can\'?t I (:answers [^\?]*)\??"
                      :answers ["Do you think you should be able to {0}?"
                                "If you could {0} what would you do?"
                                "I don't know -- why can't you {0}?"
                                "Have you really tried?"]}

                    { :question #"I can\'?t (.*)"
                      :answers ["How do you know you can't {0}?"
                                "Perhaps you could {0} if you tried."
                                "What would it take for you to {0}?"]}

                    { :question #"I am (.*)"
                      :answers ["Did you come to me because you are {0}?"
                                "How long have you been {0}?"
                                "How do you feel about being {0}?"]}

                    { :question #"I\'?m (.*)"
                      :answers ["How does being {0} make you feel?"
                                "Do you enjoy being {0}?"
                                "Why do you tell me you're {0}?"
                                "Why do you think you're {0}?"]}

                    { :question #"Are you ([^\?]*)\??"
                      :answers ["Why does it matter whether I am {0}?"
                                "Would you prefer it if I were not {0}?"
                                "Perhaps you believe I am {0}."
                                "I may be {0} -- what do you think?"]}

                    { :question #"What (.*)"
                      :answers ["Why do you ask?"
                                "How would an answer to that help you?"
                                "What do you think?"]}

                    { :question #"How (.*)"
                      :answers ["How do you suppose?"
                                "Perhaps you can answer your own question."
                                "What is it you're really asking?"]}

                    { :question #"Because (.*)"
                      :answers ["Is that the real reason?"
                                "What other reasons come to mind?"
                                "Does that reason apply to anything else?"
                                "If {0} what else must be true?"]}

                    { :question #"(.*) sorry (.*)"
                      :answers ["There are many times when no apology is needed."
                                "What feelings do you have when you apologize?"]}

                    { :question #"Hello(.*)"
                      :answers ["Hello... I'm glad you could drop by today."
                                "Hi there... how are you today?"
                                "Hello how are you feeling today?"]}

                    { :question #"I think (.*)"
                      :answers ["Do you doubt {0}?"
                                "Do you really think so?"
                                "But you're not sure {0}?"]}

                    { :question #"(.*) friend (.*)"
                      :answers ["Tell me more about your friends."
                                "When you think of a friend what comes to mind?"
                                "Why don't you tell me about a childhood friend?"]}

                    { :question #"(Yes)"
                      :answers ["You seem quite sure."
                                "OK but can you elaborate a bit?"]}

                    { :question #"(.*) computer(.*)"
                      :answers ["Are you really talking about me?"
                                "Does it seem strange to talk to a computer?"
                                "How do computers make you feel?"
                                "Do you feel threatened by computers?"]}

                    { :question #"Is it (.*)"
                      :answers ["Do you think it is {0}?"
                                "Perhaps it's {0} -- what do you think?"
                                "If it were {0} what would you do?"
                                "It could well be that {0}."]}

                    { :question #"It is (.*)"
                      :answers ["You seem very certain."
                                "If I told you that it probably isn't {0} what would you feel?"]}

                    { :question #"Can you ([^\?]*)\??"
                      :answers ["What makes you think I can't {0}?"
                                "If I could {0} then what?"
                                "Why do you ask if I can {0}?"]}

                    { :question #"Can I ([^\?]*)\??"
                      :answers ["Perhaps you don't want to {0}."
                                "Do you want to be able to {0}?"
                                "If you could {0} would you?"]}

                    { :question #"You are (.*)"
                      :answers ["Why do you think I am {0}?"
                                "Does it please you to think that I'm {0}?"
                                "Perhaps you would like me to be {0}."
                                "Perhaps you're really talking about yourself?"]}

                    { :question #"You\'?re (.*)"
                      :answers ["Why do you say I am {0}?"
                                "Why do you think I am {0}?"
                                "Are we talking about you or me?"]}

                    { :question #"I don\'?t (.*)"
                      :answers ["Don't you really {0}?"
                                "Why don't you {0}?"
                                "Do you want to {0}?"]}

                    { :question #"I feel (.*)"
                      :answers ["Good tell me more about these feelings."
                                "Do you often feel {0}?"
                                "When do you usually feel {0}?"
                                "When you feel {0} what do you do?"]}

                    { :question #"I have (.*)"
                      :answers ["Why do you tell me that you've {0}?"
                                "Have you really {0}?"
                                "Now that you have {0} what will you do next?"]}

                    { :question #"I would (.*)"
                      :answers ["Could you explain why you would {0}?"
                                "Why would you {0}?"
                                "Who else knows that you would {0}?"]}

                    { :question #"Is there (.*)"
                      :answers ["Do you think there is {0}?"
                                "It's likely that there is {0}."
                                "Would you like there to be {0}?"]}

                    { :question #"My (.*)"
                      :answers ["I see your {0}."
                                "Why do you say that your {0}?"
                                "When your {0} how do you feel?"]}

                    { :question #"You (.*)"
                      :answers ["We should be discussing you not me."
                                "Why do you say that about me?"
                                "Why do you care whether I {0}?"]}

                    { :question #"Why (.*)"
                      :answers ["Why don't you tell me the reason why {0}?"
                                "Why do you think {0}?"]}

                    { :question #"I want (.*)"
                      :answers ["What would it mean to you if you got {0}?"
                                "Why do you want {0}?"
                                "What would you do if you got {0}?"
                                "If you got {0} then what would you do?"]}

                    { :question #"(.*) mother(.*)"
                      :answers ["Tell me more about your mother."
                                "What was your relationship with your mother like?"
                                "How do you feel about your mother?"
                                "How does this relate to your feelings today?"
                                "Good family relations are important."]}

                    { :question #"(.*) father(.*)"
                      :answers ["Tell me more about your father."
                                "How did your father make you feel?"
                                "How do you feel about your father?"
                                "Does your relationship with your father relate to your feelings today?"
                                "Do you have trouble showing affection with your family?"]}

                    { :question #"(.*) child(.*)"
                      :answers ["Did you have close friends as a child?"
                                "What is your favorite childhood memory?"
                                "Do you remember any dreams or nightmares from childhood?"
                                "Did the other children sometimes tease you?"
                                "How do you think your childhood experiences relate to your feelings today?"]}

                    { :question #"(.*)\?"
                      :answers ["Why do you ask that?"
                                "Please consider whether you can answer your own question."
                                "Perhaps the answer lies within yourself?"
                                "Why don't you tell me?"]}

                    { :question #"(quit)"
                      :answers ["Thank you for talking with me."
                                "Good-bye."
                                "Thank you that will be $150.  Have a good day!"]}

                    { :question #"(.*)"
                      :answers ["Please tell me more."
                                "Let's change focus a bit... Tell me about your family."
                                "Can you elaborate on that?"
                                "Why do you say that {0}?"
                                "I see."
                                "Very interesting."
                                "{0}."
                                "I see.  And what does that tell you?"
                                "How does that make you feel?"
                                "How do you feel when you say that?"]}))
(defn update-reflection [answer]
  (clojure.string/join " "(map (fn [splitter]
                                 (if ((keyword splitter) reflections)
                                   ((keyword splitter) reflections)
                                   splitter)) (clojure.string/split answer #" "))))
(defn get-matching-psychobabble [psychobabbles statement]
  (first (filter (fn [psychobabble]
                   (let [{question :question answers :answers} psychobabble]
                     (re-find question statement))) psychobabbles)))
(defn prepare-answer [statement psychobabble]
  (let [{ question :question answers :answers } psychobabble]
    (let [[full-statement first-match] (re-find question statement)]
      (let [match-with-reflection (update-reflection first-match)]
        (clojure.string/replace (nth answers (rand-int (count answers))) "{0}" match-with-reflection)))))
(defn remove-punctuation [statement]
  (clojure.string/replace statement #"\?|\." ""))
(defn analyze [statement]
  (let [statement-without-punctuation (remove-punctuation statement)]
    (->> (get-matching-psychobabble psychobabble statement-without-punctuation)
         (prepare-answer statement-without-punctuation))))
(defroutes app-routes
           (GET "/api/query" {params :params}
                (get params "val")
                (response (json/write-str { :message (analyze (str (params :q)) ) }))))
(def app
  (-> (site app-routes)
      (wrap-cors :access-control-allow-origin [#".*"]
                 :access-control-allow-methods [:get :put :post :delete]
                 :access-control-allow-headers ["Content-Type"])))
(defn -main [& args]
  (run-jetty app {:port 5000}))