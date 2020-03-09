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
    ["/Users/clojure/blockly.bin"] {:binary true}))

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

(defn write-file
  [{:keys [file-name content]}]
  (with-open [out (clojure.java.io/output-stream file-name)]
    (clojure.java.io/copy content out)))

(comment
  ;; 只显示了core.clj文件
  (shell/sh
    "git" "grep" "--cached" "-Il" "\"\"")

  ;; 只是显示了project.clj的root下面的所有文件
  (shell/sh
    "git" "ls-files")

  (clomacs-defn get-vc-all-git-files get-vc-all-git-files)
  (get-vc-all-git-files) ;; => ""

  (clomacs-defn vc-text-file-name vc-text-file-name)
  (vc-text-file-name) ;; => ""
  ;; Wrong type argument: stringp, nil
  ;;   in wrapped Clojure->Elisp function: jim_mxnet.tensorflow$vc_text_file_name@40c0a4f4
  ;;   elisp: (vc-text-file-name)
  ;; => ""

  (clomacs-defn vc-root-dir vc-root-dir)
  (vc-root-dir);;=> ""

  )

(comment
  ;; 需要在emacs里面启动这个才能用emacs-version
  ;; (jim-mxnet-httpd-start)

  (clomacs-defn el-identity identity)
  (el-identity 1)
  ;; => "1"

  (clomacs-defn emacs-major-version clomacs-get-emacs-major-version)
  (emacs-major-version) ;;=> ""

  ;; ----------
  (clomacs-defn complete-auto-complete ejc-complete-auto-complete)
  ;; 成功跳转,并且插入了aaaa
  (complete-auto-complete "jim-mxnet.el" 1)

  ;; --------- 也成功了...
  (clomacs-defn complete-auto-complete-2 ejc-complete-auto-complete-2)
  ;; 成功跳转,并且插入了22222
  (complete-auto-complete-2 "jim-mxnet.el" 1)

  (clomacs-eval "message" "\"111\"" true)
  (clomacs-eval "message" "\"111\"" false)

  (clomacs-eval "vc-root-dir" "()" false)

  ;; (defun aaa (x) (+ x 100)) =>
  (clomacs-eval "aaa" "(aaa 1)" false)
  ;; => "101"

  (clomacs-eval "aaax" "(aaa 1)" false) ;=> "101"

  (clomacs-eval "aaaxdsa" "(format \"%s---\"(vc-root-dir))" true)
;; => "nil---"
  )

(clomacs-defn emacs-version emacs-version)
(defn prn-emacs-version []
  (println (emacs-version)))

(clomacs-defn vc-root-dir vc-root-dir)
(defn get-vc-root []
  (vc-root-dir))

(clomacs-defn get-vc-all-git-files get-vc-all-git-files)
(defn get-vc-git-files []
  (get-vc-all-git-files))

(clomacs-defn vc-text-file-name vc-text-file-name)
(defn get-vc-tex-file-name []
  (vc-text-file-name))
