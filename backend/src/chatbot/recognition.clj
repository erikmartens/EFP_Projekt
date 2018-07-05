(ns chatbot.recognition
  (:require [clojure.string :as str]
            [clojure.java.io :as io]
            [clojure.data.json :as json]
            [stemmer.snowball :as snowball]
            [chatbot.utils]))

(def stemmer (snowball/stemmer :german))


(def stop-words
  (json/read-str (slurp (clojure.java.io/resource"stopwords.json")) :key-fn keyword))


(defn split-words
  [input]
  (clojure.string/split (clojure.string/lower-case input) #" "))


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



(defn remove-punctuation
  "Removes all punctuation from a String. Punctuations are: ,.?!-()\" "
  [sentence]
  (clojure.string/replace sentence #"(,|\.|\?|!|-|\(|\)|\")" ""))


;; stem-sentence : String -> String
(defn stem-sentence
  "Stems all words in the sentence."
  [sentence]
  (->> (clojure.string/split sentence #" ")
       (map (fn [ word ] (stemmer word)))
       (clojure.string/join " ")))


(defn remove-stop-words
  "Removes all unnecessary words from a sentence."
  [sentence]
  (let [question-words (seq (split-words sentence))]
    (->> question-words
         (reduce
          (fn [ valid-question-words possible-stop-word ]
            (if
              (chatbot.utils/in? stop-words possible-stop-word)
              valid-question-words
              (conj valid-question-words possible-stop-word))) '())
         (reverse)
         (clojure.string/join " "))))

(defn prepare-sentence
  "Prepares a sentence to compute the cosine similarity with it."
  [ sentence ]
  (->> sentence
       (remove-punctuation)
       (remove-stop-words)
       (stem-sentence)))

(def questions
  "The faq questions are stored in a json file."
  (reduce (fn [ list item] (concat list item)) (map (fn [ { questions :questions intent :intent answer :answer } ]
              (map (fn [ question ] (hash-map :question (prepare-sentence question) :intent intent :answer answer )) questions)) (json/read-str (slurp (clojure.java.io/resource"questions.json")) :key-fn keyword))))

(def get-answer (chatbot.utils/get-thread-last "answer"))

;; answer : String -> ChatbotQuestion
(defn answer
  "Compares the question with the provided faq questions and chooses the best fitting faq answer."
  [ question ]
  (let [prepared-question (chatbot.utils/effect-print (prepare-sentence question))]
    (->> questions
       (map (fn [ faq-question ] (merge faq-question {:similarity (cosine-similarity-of-strings (:question faq-question) prepared-question)})))
       (sort-by :similarity >)
       (first))))

; answer-from-intent : String -> String
(defn answer-from-intent
  "Converts an existing intent into the corresponding faq answer."
  [ intent ]
  (->> questions
       (filter (fn [ question ] (= (:intent question) intent)))
       (first)
       (get-answer)))