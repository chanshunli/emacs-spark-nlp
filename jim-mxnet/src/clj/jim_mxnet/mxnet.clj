(ns jim-mxnet.mxnet
  "专心于MXnet,而不是别人说用什么就用什么"
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

(require-python 'mxnet '(mxnet ndarray module io model))
(require-python '[mxnet :refer [autograd nd] :as mx])
(require-python 'cv2)
(require-python '[numpy :as np])

(def test-ary (np/array [[1 2][3 4]]))

(defn load-model
  [& {:keys [model-path checkpoint]
      :or {model-path "models/recognition/model"
           checkpoint 0}}]
  (let [[sym arg-params aux-params] (mxnet.model/load_checkpoint model-path checkpoint)
        all-layers (py. sym get_internals)
        target-layer (py/get-item all-layers "fc1_output")
        model (mxnet.module/Module :symbol target-layer
                :context (mxnet/cpu)
                :label_names nil)]
    (py. model bind :data_shapes [["data" [1 3 112 112]]])
    (py. model set_params arg-params aux-params)
    model))

(defonce model "" #_(load-model))

(defn face->feature
  [img-path]
  (py/with-gil-stack-rc-context
    (if-let [new-img (cv2/imread img-path)]
      (let [new-img (cv2/cvtColor new-img cv2/COLOR_BGR2RGB)
            new-img (np/transpose new-img [2 0 1])
            input-blob (np/expand_dims new-img :axis 0)
            data (mxnet.ndarray/array input-blob)
            batch (mxnet.io/DataBatch :data [data])]
        (py. model forward batch :is_train false)
        (-> (py. model get_outputs)
          first
          (py. asnumpy)
          (#(dtype/make-container :java-array :float32 %))))
      (throw (Exception. (format "Failed to load img: %s" img-path))))))

;; TODO函数: 输入向量变换函数输出它的梯度, 求控制流函数的梯度 => 计算函数的逻辑语义的相似度
(comment
  ;; x = nd.arange(4).reshape((4, 1))
  (def x (-> nd
           (py. arange 4)
           (py. reshape [4 1])))

  (py. x attach_grad)

  ;; 2 * nd.dot(x.T, x)
  (py/with [record (py. autograd record)]
    (let [y (py. nd multiply 2
              (py. nd dot (py.- x T) x))]
      (py. y backward)))

  (def dx (py.- x grad))
  ;; =>
  ;; [[ 0.]
  ;;  [ 4.]
  ;;  [ 8.]
  ;;  [12.]]
  ;; <NDArray 4x1 @cpu(0)>

  ;; ----------------------------
  ;;x = mx.nd.random.uniform(shape=(10,))
  (def x1 (-> nd
            (py.- random)
            (py/call-attr-kw "uniform" [] {"shape" 10})))
  ;; => [0.79172504 0.8121687  0.5288949  0.47997716 0.56804454 0.3927848
  ;;     0.92559665 0.83607876 0.07103606 0.33739617]
  ;;    <NDArray 10 @cpu(0)>

  (py. x1 attach_grad)

  ;; 求多分类控制流函数sigmoid的梯度
  (py/with [record (py. autograd record)]
    (let [m (py. nd sigmoid x1)]
      (py. m backward)))

  (def dx1 (py.- x1 grad))
  ;; => [0.21458015 0.21291625 0.23330082 0.2361367  0.23086983 0.24060014
  ;;     0.20326573 0.21093895 0.24968489 0.24301809]
  ;;    <NDArray 10 @cpu(0)>

  )
