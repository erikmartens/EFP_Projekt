(ns chatbot.recognition
  (:require [clojure.string :as str]
            [clojure.java.io :as io]
            [clojure.data.json :as json]
            [stemmer.snowball :as snowball]
            [chatbot.utils]))

(def stemmer (snowball/stemmer :german))

;; stopWords : List String
(def stop-words
  (json/read-str (slurp (clojure.java.io/resource"stopwords.json")) :key-fn keyword))
;; Types
;;
;; type ChatbotQuestion =
;;  { :question String
;;    :intent String
;;    :answer String
;;  }

(defn split-words
  [input]
  (clojure.string/split (clojure.string/lower-case input) #"\W+"))
; teilt ß

(defn make-hash-of-words
  "Creates hash table [:word number-of-occurencies]"
  ([input] (make-hash-of-words input {}))
  ([input hash-table]
   (reduce
    (fn [hash word] (assoc hash word (inc (get hash word 0))))
    hash-table
    (split-words input))))


(defn hash-vec-length
  [hash]
  (Math/sqrt (reduce (fn [result [_ val]] (+ result (* val val))) 0 hash)))


(defn hash-vec-product
  [hash1 hash2]
  (reduce
   (fn [result [key val]] (+ result (* val (get hash2 key 0))))
   0
   hash1))


(defn cosine-similarity-of-hashes
  [hash1 hash2]
  (let [product (future (hash-vec-product hash1 hash2))
        len1 (future (hash-vec-length hash1))
        len2 (future (hash-vec-length hash2))]
    (/ @product (* @len1 @len2))))


(defn cosine-similarity-of-strings
  [string1 string2]
  (let [hash1 (future (make-hash-of-words string1))
        hash2 (future (make-hash-of-words string2))]
    (cosine-similarity-of-hashes @hash1 @hash2)))


;;    question process functions


;; remove-punctuation : String -> String
(defn remove-punctuation [sentence]
  (clojure.string/replace sentence #"(,|\.|\?|!|-)" ""))


;; stem-sentence : String -> String
(defn stem-sentence [sentence]
  (->> (clojure.string/split sentence #" ")
       (map (fn [ word ] (stemmer word)))
       (clojure.string/join " ")))


;; spelling-correction : String -> String
(defn spelling-correction [ sentence ]
  (sentence))


(defn remove-stop-words [ question ]
  (let [ question-words (seq (split-words question)) ]
    (->> question-words
         (reduce
          (fn [ valid-question-words possible-stop-word ]
            (if
              (chatbot.utils/in? stop-words possible-stop-word)
              valid-question-words
              (conj valid-question-words possible-stop-word))) '())
         (reverse)
         (clojure.string/join " "))))


;; question : List ChatbotQuestion
(def questions
  (map (fn [ chatbot-question ] (merge chatbot-question { :question (stem-sentence(remove-stop-words(remove-punctuation (:question chatbot-question))))}))  (json/read-str (slurp (clojure.java.io/resource"questions.json")) :key-fn keyword)))

;(def questions
;  (for [ { question :question intent :intent answer :answer } (json/read-str (slurp (clojure.java.io/resource"questions.json")) :key-fn keyword) ]
;    ( { :question (remove-punctuation question) :intent intent :answer answer })))

(chatbot.utils/effect-print questions)


;(defn get-answer [question]
;  (first (sort-by :similarity >(map (fn [quest] (hash-map :question quest :similarity (cosine-similarity-of-strings quest question))) questions))))

;; answer : String -> ChatbotQuestion
(defn answer [ question ]
  (let [ question-without-punctuation (stem-sentence(remove-stop-words(remove-punctuation question))) ]
    (->> questions
       (map (fn [ faq-question ] (merge faq-question { :similarity (cosine-similarity-of-strings (:question faq-question) question-without-punctuation)})))
       (sort-by :similarity >)
       (first))))
