
;; TODO: 用yasnipat来放多个参数来作为模板
(defun dl/q ()
  (interactive)
  (insert "
(d/q '[:find
       :where ]
      db)
")
  )

(defun dl/pull ()
  (interactive)
  (insert
   "
(d/pull db '[*] eid)
"
   )
  )

(defun dl/pull1 ()
  (interactive)
  (insert
   "
(d/pull db ' led-zeppelin)
"
   )
  )

;; TODO: 改成cider-eval,填入参数去全文搜索
(defun dl/search ()
  "全文搜索内容"
  (interactive)
  (insert
   "
(d/q '[:find ?entity ?name ?tx ?score
         :in $ ?search
         :where [(fulltext $ :artist/name ?search) [[?entity ?name ?tx ?score]]]]
    db \"zeppelin\")
"
   )
  )

(defun dl/search1 ()
  "TODO: 全文搜索内容 命令"
  (interactive)
  ;; 返回是非字符串的结构体导致会失败message出来
  (eval-clj-code
   "(d/q '[:find ?entity ?name ?tx ?score
         :in $ ?search
         :where [(fulltext $ :artist/name ?search) [[?entity ?name ?tx ?score]]]]
    db \"zeppelin\")"
   )
  )

;; 做编辑器的主人,所有重复性的工作全部要被自动化掉,完全自我设计 <= `要做咏春拳学的主人`哲学思想能量转化
;; 1.需要反复重复的功能: 就用emacs来自定义化掉
;; 2.避免反复切换和打断,就直接一个命令就到达了 => 就像水一样切不断, 标月指 & Lisp机大脑流的速度
(defun dl/entity ()
  "根据eid(相当于SQL表格的主键),查出所有它的属性值出来"
  (interactive)
  ;; 返回了list,需要str出来才能打印
  (let* ((code
          (format "(str (seq (d/entity (d/db conn) %s)))"
                  (read-string "eid:"))))
    (message (eval-clj-code code))))

(provide 'jim-datalog)
