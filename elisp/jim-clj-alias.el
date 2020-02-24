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

(defun page-reload ()
  (interactive)
  (eval-clj-code "(.reload js/location)"))

(defun clear-storage ()
  (interactive)
  (eval-clj-code "(.clear js/localStorage)"))

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
