(ns jim-mxnet.tensorflow
  (:require
   [libpython-clj.python
    :refer
    [import-module get-item get-attr python-type
     call-attr call-attr-kw att-type-map ->py-dict
     run-simple-string] :as py]
   [clojure.pprint :as pp]))

(defn init-libpy []
  (do
    (alter-var-root
      #'libpython-clj.jna.base/*python-library*
      (constantly
        ;; Mac: (get (System/getenv) "LIBPYTHON_PATH")
        "/usr/local/Cellar/python/3.7.5/Frameworks/Python.framework/Versions/3.7/lib/libpython3.7m.dylib"))
    (py/initialize!)))

(init-libpy)

(defn py-import [module-name]
  (import-module module-name))

(defmacro $ [py-import-lib attr-name & args]
  `(call-attr
     ~py-import-lib  ~(str attr-name) ~@args))

;; (-a> ($ np ones [2 3]) shape) ;; => (2, 3)
(defmacro -a> [py-import-lib attr-name]
  `(get-attr
     ~py-import-lib  ~(str attr-name)))

;; -------------

(defonce np (import-module "numpy"))
(defonce lmdb-reader (import-module "lmdb_embeddings.reader"))

(defonce embeddings
  ($ lmdb-reader LmdbEmbeddingsReader
    "/Users/clojure/tensorflow-lmdb"))

;;(get-word-vector "python")
(defn get-word-vector [word]
  ($ embeddings get_word_vector word))

;; (dot-word "matrix" "vector") ;;=> 164.7116241455078
;; (dot-word "array" "deep") ;;=> -12.737825393676758
(defn dot-word [w1 w2]
  ($ np dot (get-word-vector w1) (get-word-vector w2)))
