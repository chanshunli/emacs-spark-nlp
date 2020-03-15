(ns postwalk-editer.lmdb
  (:require
   [clojure.java.shell :as shell]
   [libpython-clj.require :refer [require-python]]
   [libpython-clj.python
    :refer
    [py. py.. py.-
     import-module get-item get-attr python-type
     call-attr call-attr-kw att-type-map ->py-dict
     run-simple-string] :as py]
   [tech.v2.datatype :as dtype]
   [clojure.pprint :as pp])
  (:use clomacs))

(require-python '[numpy :as np])
(require-python '[lmdb_embeddings.reader :refer [LmdbEmbeddingsReader]])

(defonce embeddings
  (LmdbEmbeddingsReader
    "/Users/clojure/tensorflow-lmdb"))

(comment
  (get-word-vector "python")
  (get-word-vector "pythonx"))
(defn get-word-vector [word]
  (try
    (py. embeddings get_word_vector word)
    (catch Exception e
      (prn "当前词找不到向量")
      nil)))

(comment
  (dot-word "matrix" "vector") ;;=> 164.7116241455078
  (dot-word "array" "deep")    ;;=> -12.737825393676758
  (dot-word "arrayx" "deep")   ;;=> 0
  )
(defn dot-word [w1 w2]
  (let [[v1 v2] [(get-word-vector w1) (get-word-vector w2)] ]
    (if (and v1 v2)
      (np/dot v1 v2)
      0)))
