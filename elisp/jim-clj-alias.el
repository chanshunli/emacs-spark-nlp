(defun eval-clj-code (clj-code)
  "in clj repl:  (eval-clj-code \"(map inc [1 2 3])\") => [2 3 4]
   in cljs repl: (eval-clj-code \"(js/console.log 11111)\")"
  (interactive)
  (thread-first
      (cider-nrepl-sync-request:eval
       clj-code)
    (nrepl-dict-get "value")
    (read)))

(defun appdb ()
  (interactive)
  (eval-clj-code "(cljs.pprint/pprint @re-frame.db/app-db)"))

(defun insert-appdb ()
  (interactive)
  (insert "(cljs.pprint/pprint @re-frame.db/app-db)"))

(defun page-reload ()
  (interactive)
  (eval-clj-code "(.reload js/location)"))

(defun clear-storage ()
  (interactive)
  (eval-clj-code "(.clear js/localStorage)"))

(defun interpreter-list ()
  "用万能的list树和Postwalk解释器算法来写算法"
  (interactive)
  (insert "(clojure.walk/postwalk-demo [[1 2] [3 4 [5 6]] [7 8]])"))

(defun postwalk-any ()
  "通过类型特征工程来cond递归解释 => 深度学习自动化特征工程"
  (interactive)
  (insert  "
  (clojure.walk/postwalk
   (fn [x]
       (cond
        (vector? x) (prn (str \"Walked: \" x))
        :else x))
   [[1 2] [3 4 [5 6]] [7 8]])
")
  )

(defun for-key ()
  (interactive)
  (insert "^{:key item}"))

(defun input-default ()
  (interactive)
  (insert "placeholder"))

(defun clojure-uniq ()
  "老是会忘记的名称: alias别名一下自己的理解的,能记住的名字"
  (interactive)
  (insert "(distinct)"))

(defun on-change-event ()
  (interactive)
  (insert "(.. e -target -value)"))

(defun is-comp? ()
  "判断一个React组件引用是否正确: util模式 => 元解释器模式开发"
  (interactive)
  (let*
      ((code (format
              "(try [(reagent.debug/assert-some %s \"Component\")] (catch :default e \"这不是一个React组件\"))"
              (thing-at-point 'symbol))))
    (let*
        ((res (format "%s" (eval-clj-code code))))
      (if (string= res "[nil]")
          (message "这是一个React组件")
        (message res)))))

(provide 'jim-clj-alias)
