(ns jim-mxnet.libpython-init
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
   [clojure.pprint :as pp]))

(defn init-libpy []
  (do
    (alter-var-root
      #'libpython-clj.jna.base/*python-library*
      (constantly
        "/usr/local/Cellar/python/3.7.5/Frameworks/Python.framework/Versions/3.7/lib/libpython3.7m.dylib"))
    (py/initialize!)))

(init-libpy)
