(ns postwalk-editer.core
  (:require
   [libpython-clj.require :refer [require-python]]
   [libpython-clj.python :refer [py. py.. py.-] :as py]
   [tech.v2.datatype :as dtype]
   [postwalk-editer.libpython-init] ;; 在加载其他libpython函数之前加载好
   [postwalk-editer.bert]
   [postwalk-editer.lmdb]
   [postwalk-editer.gensim]
   [postwalk-editer.word2vec]
   [postwalk-editer.mxnet])
  (:use markdown.core
        clomacs))

(defn my-md-to-html-string
  "Call some function from the dependency."
  [x]
  (md-to-html-string x))

(clomacs-defn emacs-version emacs-version)
(defn strong-emacs-version []
  (let [ev (.replaceAll (emacs-version) "\n" "")]
    (str "**" ev "**")))
