(ns postwalk-editer
  (:require [clojure.repl :as repl]
            [clojure.pprint]
            [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.walk])
  (:use [cemerick.pomegranate :only (add-dependencies)])
  (:import (java.io File LineNumberReader InputStreamReader
             PushbackReader FileInputStream)
           (clojure.lang RT Reflector)))

(defn use-package [name version]
  (add-dependencies
    :coordinates [[name version]]
    :repositories (merge cemerick.pomegranate.aether/maven-central
                    {"clojars" "https://clojars.org/repo"})
    :classloader (. (. (. Compiler/LOADER deref) getParent) getParent)))

(defn expand-file-name [name dir]
  (. (io/file dir name) getCanonicalPath))

(use-package 'compliment "0.3.6")
(require '[compliment.core :as compliment])

(use-package 'me.raynes/fs "1.4.6")
(require '[me.raynes.fs :as fs])

;; ------------------------

(defn postwalk-add [stri {:keys [bind-key k-key]} ]
  (->
    (clojure.walk/postwalk
      #(cond
         ;;TYPE_A: `[a b c]`的参数类型处理
         (and (vector? %)
           (every? symbol? %)
           (some (fn [a] (= a (symbol bind-key))) %))
         (vec (cons (symbol k-key) %))
         ;;TYPE_B `{:aa 11}`的类型处理
         (and (map? %) (not (empty? %)))
         (if (= (count %) 1)
           %
           (merge (apply hash-map [(keyword k-key) (symbol k-key)]) %))
         ;;TYPE_C `h/select` & `h/returning`的类型处理
         (and (list? %) (or (= (first %) (symbol "h/select"))
                          (= (first %) (symbol "h/returning"))))
         (concat % (list (keyword k-key)))
         ;;TYPE_N ....
         ;;TYPE_default
         :else %)
      (read-string stri))
    (clojure.pprint/write  :dispatch clojure.pprint/code-dispatch :stream nil)))
