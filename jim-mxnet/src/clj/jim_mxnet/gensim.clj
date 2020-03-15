(ns jim-mxnet.gensim
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

(require-python '[gensim.models :refer [KeyedVectors]])

(defonce gensim-model
  (py/call-attr-kw  KeyedVectors "load_word2vec_format"
    ["/Users/clojure/text8-vector.bin"] {:binary true}))

(comment
  (word-similarity "canvas" "svg")
  (word-similarity "apple" "orange")
  (word-similarity "apple" "steve")
  (word-similarity "phone" "number")
  (word-similarity "black" "white")
  (word-similarity "more" "less")
  (word-similarity "good" "best")
  (word-similarity "take" "taken"))
(defn word-similarity [w1 w2]
  (py. gensim-model similarity w1 w2))

(comment
  (most-similar-list "svg")
  ;; => [('draggroup', 0.5903651714324951), ('bubblecanvas', 0.5453072786331177), ('blockcanvas', 0.5119982957839966), ('fecolormatrix', 0.4926156997680664), ('currentcolor', 0.49199116230010986), ('painttype', 0.4897512197494507), ('setblocksandshow', 0.4893278479576111), ('fecomponenttransfer', 0.4838906526565552), ('lengthtype', 0.4781251549720764), ('blocklywsdragsurface', 0.477472722530365)]
  (most-similar-list "apple")
  ;; => [('macintosh', 0.6729650497436523), ('iigs', 0.5870038270950317), ('imac', 0.5726022720336914), ('appleworks', 0.546027421951294), ('quickdraw', 0.5307680368423462), ('amiga', 0.5192068815231323), ('ibook', 0.5189187526702881), ('performa', 0.515857458114624), ('os', 0.5131500959396362), ('raskin', 0.5100513696670532)]

  (most-similar-list "google")
  ;; => [('pagerank', 0.5524251461029053), ('yahoo', 0.5519217252731323), ('msn', 0.5476144552230835), ('gmail', 0.5349109768867493), ('com', 0.4945995807647705), ('mapquest', 0.4935714602470398), ('search', 0.48442405462265015), ('web', 0.48306629061698914), ('usenet', 0.4807744026184082), ('geocaching', 0.4667409658432007)]
  )
(defn most-similar-list
  "返回一个代码项目词向量相似度的列表给ivy-read去选择"
  [word]
  (py. gensim-model most_similar word))

(comment
  (seq-similar ["blockly" "svg"] ["canvas" "render"])
  ;; => 17.50104303809166
  (seq-similar ["apple" "macintosh"] ["goole" "pagerank"])
  ;; => 24.409742944574358
  )
(defn seq-similar
  "两个序列的相似度: 当输入多个搜索词搜索代码时可以用来过滤掉一些低概率的序列"
  [seq1 seq2]
  (py. gensim-model wmdistance  seq1 seq2))
