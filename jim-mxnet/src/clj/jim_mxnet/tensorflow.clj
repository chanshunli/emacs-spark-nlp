(ns jim-mxnet.tensorflow
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

(defn init-libpy []
  (do
    (alter-var-root
      #'libpython-clj.jna.base/*python-library*
      (constantly
        ;; Mac: (get (System/getenv) "LIBPYTHON_PATH")
        "/usr/local/Cellar/python/3.7.5/Frameworks/Python.framework/Versions/3.7/lib/libpython3.7m.dylib"))
    (py/initialize!)))

(init-libpy)

;; ---------- lmdb ---------------
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

;; ------ gensim -------
(require-python '[gensim.models :refer [KeyedVectors]])

(defonce gensim-model
  (py/call-attr-kw  KeyedVectors "load_word2vec_format"
    ["/Users/clojure/text8-vector.bin"] {:binary true}))

(comment
  (word-similarity "canvas" "svg")
  ;; => 0.4597845673561096
  )
(defn word-similarity [w1 w2]
  (py. gensim-model similarity w1 w2))

(comment
  (most-similar-list "svg")
  ;; => [('draggroup', 0.5903651714324951), ('bubblecanvas', 0.5453072786331177), ('blockcanvas', 0.5119982957839966), ('fecolormatrix', 0.4926156997680664), ('currentcolor', 0.49199116230010986), ('painttype', 0.4897512197494507), ('setblocksandshow', 0.4893278479576111), ('fecomponenttransfer', 0.4838906526565552), ('lengthtype', 0.4781251549720764), ('blocklywsdragsurface', 0.477472722530365)]
  )
(defn most-similar-list
  "返回一个代码项目词向量相似度的列表给ivy-read去选择"
  [word]
  (py. gensim-model most_similar word))

(comment
  (seq-similar ["blockly" "svg"] ["canvas" "render"])
  ;; => 17.50104303809166
  )
(defn seq-similar
  "两个序列的相似度: 当输入多个搜索词搜索代码时可以用来过滤掉一些低概率的序列"
  [seq1 seq2]
  (py. gensim-model wmdistance  seq1 seq2))

;; ---- 处理text8文件生成和词向量训练 -----
(defn write-file
  [{:keys [file-name content]}]
  (with-open [out (clojure.java.io/output-stream file-name)]
    (clojure.java.io/copy content out)))

(clomacs-defn emacs-version emacs-version)
(defn prn-emacs-version []
  (println (emacs-version)))

(defn get-git-root []
  (clomacs-eval "git-root" "(get-git-root)" false))

;; ----- elisp的函数映射列表 start -----
(clomacs-defn get-vc-all-git-files get-vc-all-git-files)
(clomacs-defn vc-text-file-name vc-text-file-name)
;; ----- elisp的函数映射列表 end -----

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
