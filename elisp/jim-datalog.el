
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

(provide 'jim-datalog)
