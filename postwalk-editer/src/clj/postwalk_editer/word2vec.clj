(ns postwalk-editer.word2vec
  "处理text8文件生成和词向量训练"
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

(defn write-file
  [{:keys [file-name content]}]
  (with-open [out (clojure.java.io/output-stream file-name)]
    (clojure.java.io/copy content out)))

(clomacs-defn emacs-version emacs-version)
(defn prn-emacs-version []
  (println (emacs-version)))

(defn get-git-root []
  (clomacs-eval "git-root" "(get-git-root)" false))

(defn get-git-files []
  (clojure.string/split
    (get-vc-all-git-files)
    #"\n"))

(defn generate-project-txt8-files
  "1. 生成语料库文件,给词向量训练做准备"
  []
  (let [git-root (get-git-root)
        text8-name (vc-text-file-name)
        text8-file (format "%s/%s" git-root text8-name)
        file-names (get-git-files)]
    (prn "生成语料库文件:" text8-file)
    (with-open [out (clojure.java.io/output-stream text8-file)]
      (doseq [file-name file-names]
        (let [file (format "%s/%s" git-root file-name)
              _ (prn "解析文件--->>" file)
              content (->>
                        (slurp file)
                        ((fn [st]
                           (clojure.string/replace st "_" " ")))
                        (clojure.string/lower-case)
                        (re-seq #"\w+")
                        (clojure.string/join " "))]
          (clojure.java.io/copy content out))))
    text8-file))

;; ----- elisp的函数映射列表 start -----
(clomacs-defn get-vc-all-git-files get-vc-all-git-files)
(clomacs-defn vc-text-file-name vc-text-file-name)
;; ----- elisp的函数映射列表 end -----
